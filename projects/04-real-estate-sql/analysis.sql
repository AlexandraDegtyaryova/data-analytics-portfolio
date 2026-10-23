/* Проект первого модуля: анализ данных для агентства недвижимости
 * Часть 2. Решаем ad hoc задачи
 * 
 * Автор: Дегтярёва Александра Владимировна
 * Дата:07.10.2025
*/



-- Задача 1: Время активности объявлений

-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS (
    SELECT f.id,
    	f.total_area, -- общ площадь 
    	f.rooms, -- кол-во комнат
    	f.balcony, -- кол-во балконов
    	f.ceiling_height,-- высота потолка 
    	f.floors_total, -- этажность дома
    	t.type , -- название типа
    	c.city, --название населённого пункта
    	a.first_day_exposition, --дата подачи объявления
    	a.days_exposition, --длительность нахождения объявления на сайте (в днях)
    	a.last_price, -- стоимость квартиры в объявлении
    	a.last_price/f.total_area AS area_1_price -- стоимость 1 м^2
    FROM real_estate.flats AS f 
    JOIN real_estate.advertisement a ON f.id=a.id 
    JOIN real_estate.city c ON c.city_id=f.city_id 
    JOIN  real_estate.type t ON t.type_id=f.type_id
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
        AND t.type='город' 
        AND a.first_day_exposition BETWEEN '2015-01-01'AND '2018-12-31'
    ),
 pre_final AS (
 	SELECT *,
    	CASE
        	WHEN days_exposition BETWEEN 1 AND 30 THEN 'до месяца'
        	WHEN days_exposition BETWEEN 31 AND 90 THEN 'от 1 до 3 месяцев'
        	WHEN days_exposition BETWEEN 91 AND 180 THEN 'от 3 месяцев до полугода'
        	WHEN days_exposition > 180 THEN 'более полугода'
        	ELSE 'без категории'
    	END AS segment_exposition,
    	CASE
    		WHEN city = 'Санкт-Петербург' THEN 'Санкт-Петербург'
    		ELSE 'Ленинградская область'
    	END AS region
	FROM filtered_id
	)
SELECT region,
	segment_exposition,
	count(*) AS total_count, --кол-во проданных 
	AVG(area_1_price) AS avg_price_1kv, -- средняя цена за 1 м^2
	AVG(total_area) AS avg_area, -- средняя площадь
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY rooms) AS mediana_rooms, -- медиана комнаты
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY balcony) AS mediana_balcony, -- медиана балконы 
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY floors_total) AS mediana_floor -- медиана кол-во этажей
FROM pre_final
GROUP BY region,segment_exposition
ORDER BY total_count DESC
	

	
	




-- Задача 2: Сезонность объявлений
-- Подредактировала чтоб вывод был только по месяцам без учета года 
-- Определим аномальные значения (выбросы) по значению перцентилей:
WITH limits AS (
    SELECT
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_CONT(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats
),
-- Найдём id объявлений, которые не содержат выбросы, также оставим пропущенные данные:
filtered_id AS (
    SELECT f.id,
    	f.total_area, -- общ площадь 
    	f.rooms, -- кол-во комнат
    	f.balcony, -- кол-во балконов
    	f.ceiling_height,-- высота потолка 
    	f.floors_total, -- этажность дома
    	t.type , -- название типа
    	c.city, --название населённого пункта
    	a.first_day_exposition, --дата подачи объявления
    	a.days_exposition, --длительность нахождения объявления на сайте (в днях)
    	a.last_price, -- стоимость квартиры в объявлении
    	a.last_price/f.total_area AS area_1_price -- стоимость 1 м^2
    FROM real_estate.flats AS f 
    JOIN real_estate.advertisement a ON f.id=a.id 
    JOIN real_estate.city c ON c.city_id=f.city_id 
    JOIN  real_estate.type t ON t.type_id=f.type_id
    WHERE
        total_area < (SELECT total_area_limit FROM limits)
        AND (rooms < (SELECT rooms_limit FROM limits) OR rooms IS NULL)
        AND (balcony < (SELECT balcony_limit FROM limits) OR balcony IS NULL)
        AND ((ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
            AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)) OR ceiling_height IS NULL)
        AND a.first_day_exposition BETWEEN '2015-01-01'AND '2018-12-31' -- нужый временной интервал
        AND days_exposition IS NOT NULL -- отсеиваем те что еще продаются 
),
-- Для каждого объявления находим месяц публикации и месяц снятия
advertisement_months AS (
    SELECT 
        id,
        total_area,
        last_price,
        area_1_price,
        first_day_exposition,
        days_exposition,
        -- Месяц публикации
        EXTRACT(MONTH FROM first_day_exposition) AS publication_month,
        -- Месяц снятия
        EXTRACT(MONTH FROM first_day_exposition + days_exposition * INTERVAL '1 day') AS removal_month
    FROM filtered_id
),
-- Статистика по месяцам публикации
publication_stats AS (
    SELECT 
        publication_month ,
        COUNT(*) AS published_count,
        AVG(area_1_price) AS avg_price_published,
        AVG(total_area) AS avg_total_area_published
    FROM advertisement_months
    GROUP BY  publication_month
),
-- Статистика по месяцам снятия 
removal_stats AS (
    SELECT 
        removal_month ,
        COUNT(*) AS removal_count,
        AVG(area_1_price) AS avg_price_removal,
        AVG(total_area) AS avg_total_area_removal
    FROM advertisement_months
    GROUP BY removal_month
    ),
    -- Общая  статистика 
combined_stats AS (
    SELECT 
        p.publication_month AS month,
        p.published_count,
        p.avg_price_published,
        p.avg_total_area_published,
        r.removal_count,
        r.avg_price_removal,
        r.avg_total_area_removal
    FROM publication_stats p
    FULL JOIN removal_stats r ON  p.publication_month = r.removal_month
)
SELECT *
FROM combined_stats
ORDER BY  month


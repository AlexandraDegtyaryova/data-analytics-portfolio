/* Проект «Секреты Тёмнолесья»
 * Цель проекта: изучить влияние характеристик игроков и их игровых персонажей 
 * на покупку внутриигровой валюты «райские лепестки», а также оценить 
 * активность игроков при совершении внутриигровых покупок
 * 
 * Автор: Дегтярёва Александра Владимировна (исправленный вариант)
 * Дата: 24.08.2025 

-- Часть 1. Исследовательский анализ данных
-- Задача 1. Исследование доли платящих игроков



-- 1.1. Доля платящих пользователей по всем данным:

WITH tablee AS (
    SELECT 
        COUNT(id) AS all_users,
        COUNT(CASE 
	        	WHEN payer = 1 
	        	THEN 1 
	        END) AS only_pay_users
    FROM fantasy.users
)
SELECT *,
       ROUND((only_pay_users::numeric / all_users),3) as per_pay_users --добавила округление
FROM tablee;



-- 1.2. Доля платящих пользователей в разрезе расы персонажа:

WITH tablee AS (
    SELECT 
        fr.race,
        COUNT(fu.id) AS all_users,
        SUM(CASE 
	        	WHEN fu.payer = 1 
	        	THEN 1 
	        	ELSE 0 
	        END) AS only_pay_users
    FROM fantasy.users AS fu
    JOIN fantasy.race AS fr ON fu.race_id = fr.race_id
    GROUP BY fr.race
)
SELECT 
    *,
    ROUND((only_pay_users::numeric / all_users),3) AS per_pay_users -- добавила округление 
FROM tablee
ORDER BY per_pay_users DESC; --добавила сортировку



-- Задача 2. Исследование внутриигровых покупок
-- 2.1. Статистические показатели по полю amount:

SELECT 
	COUNT(transaction_id ) AS transaction_count,
	SUM(amount) AS total_sum,
	MIN(amount) AS min_amount,
	MAX(amount) AS max_amount,
	AVG(amount ) AS avg_amount,
	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY amount) AS mediana_amount,
	STDDEV(amount ) AS stand_dev
FROM fantasy.events;



-- 2.2: Аномальные нулевые покупки:

WITH count_pay AS (
    SELECT 
        COUNT(transaction_id) AS transaction_count_pay --общее кол-во 
    FROM fantasy.events -- убрала исключение ненулевых покупок (теперь учитываются все)
),
count_no_pay AS (
    SELECT 
        (SELECT transaction_count_pay 
        FROM count_pay) AS transaction_count_pay,
        COUNT(transaction_id) AS transaction_count_no_pay -- кол-во нулевых 
    FROM fantasy.events
    WHERE amount = 0
)
SELECT *,
	ROUND((transaction_count_no_pay::numeric /transaction_count_pay),6) AS per_no_pay --добавила небольшое округление
FROM count_no_pay;


-- 2.3: Популярные эпические предметы:

WITH item_stats AS (
    SELECT 
        item_code,
        COUNT(DISTINCT id) AS players_count_per_item
    FROM fantasy.events
    WHERE amount <> 0
    GROUP BY item_code
),
total_unique_players AS (
    SELECT COUNT(DISTINCT id) AS total_players
    FROM fantasy.events
    WHERE amount <> 0
)
SELECT 
    fi.game_items,
    COUNT(fe.transaction_id) AS all_count, -- количество продаж абсолют 
    (COUNT(fe.transaction_id)::numeric / SUM(COUNT(fe.transaction_id)) OVER ()) AS relative_share, -- доля продаж среди всех продаж
    isc.players_count_per_item, -- количество уникальных игроков купивших предмет
    (isc.players_count_per_item::numeric / tup.total_players) AS player_share -- доля игроков, купивших предмет
FROM fantasy.events AS fe 
JOIN fantasy.items AS fi ON fi.item_code = fe.item_code
JOIN item_stats AS isc ON fe.item_code = isc.item_code
CROSS JOIN total_unique_players AS tup
WHERE fe.amount <> 0
GROUP BY fi.game_items, isc.players_count_per_item, tup.total_players
ORDER BY COUNT(fe.transaction_id) DESC;





-- Часть 2. Решение ad hoc-задачbи
-- Задача: Зависимость активности игроков от расы персонажа:
-- Напишите ваш запрос здесь

-- исли что-то будет не так то скорее всего я сильно запуталась :(

WITH tablee AS (
    SELECT 
        fr.race,
        COUNT(DISTINCT fu.id) AS all_users, -- общее количество зарегистрированных игроков
        COUNT(DISTINCT CASE WHEN fu.payer = 1 THEN fu.id END) AS pay_users, -- количество платящих игроков
        COUNT(DISTINCT CASE WHEN fe.amount > 0 THEN fu.id END) AS buyers, -- количество игроков совершающих внутриигровые покупки
        COUNT(DISTINCT CASE WHEN fu.payer = 1 AND fe.amount > 0 THEN fu.id END) AS paying_buyers, -- платящие среди покупателей 
        AVG(CASE WHEN fe.amount > 0 THEN fe.amount END) AS avg_purchase_amount, -- средний размер покупки по расам
        COUNT(*)::NUMERIC / COUNT(DISTINCT fe.id) AS avg_purchases_per_buyer, -- Среднее количество покупок на одного игрока (добавила)
        SUM(fe.amount) / COUNT(DISTINCT CASE WHEN fe.amount > 0 THEN fu.id END) AS avg_total_per_race -- Средняя сум стоимость (добавила)
    FROM fantasy.users AS fu
    JOIN fantasy.race AS fr ON fu.race_id = fr.race_id
    LEFT JOIN fantasy.events AS fe ON fu.id = fe.id 
    GROUP BY fr.race
)
SELECT 
    race,
    all_users,
    pay_users,
    buyers,
    paying_buyers,
    ROUND((buyers::numeric / all_users), 3) AS per_pay_users_1,-- доля платящих ко всем 
    ROUND((paying_buyers::numeric / buyers), 3) AS per_pay_users_2,-- доля платящих среди совершивших покупку 
    ROUND(avg_purchase_amount::NUMERIC,2) AS avg_rase_amount, -- средний размер покупки по расам 
    avg_purchases_per_buyer, -- Среднее количество покупок на одного игрока (добавила)
    avg_total_per_race -- Средняя сум стоимость (добавила)
FROM tablee;  

--запрос для последних трёх пунктов 
WITH tablee AS (
    SELECT 
        fe.id as event_id,
        fe.transaction_id,
        fe.amount,
        fu.id as user_id
    FROM fantasy.users AS fu
    JOIN fantasy.events AS fe ON fu.id = fe.id 
    WHERE fe.amount > 0 
)
SELECT 
    COUNT(transaction_id)::FLOAT / COUNT(DISTINCT user_id) AS avg_count, -- среднее количество покупок на одного игрока
    AVG(amount) AS avg_amount, -- средняя стоимость одной покупки (исправила) (эквивалентно SUM(amount)/COUNT(transaction_id))
    SUM(amount) / COUNT(DISTINCT user_id) AS avg_sum_amount, -- средняя суммарная стоимость всех покупок на одного игрока
    (SUM(amount) / COUNT(DISTINCT user_id))/(COUNT(transaction_id)::FLOAT / COUNT(DISTINCT user_id)) AS avg_amount_2 --вывела для проверки 
FROM tablee;










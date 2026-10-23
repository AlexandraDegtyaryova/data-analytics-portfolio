# Портфолио аналитика данных

**Александра Дегтярёва** · [GitHub](https://github.com/AlexandraDegtyaryova)

11 учебных проектов по исследовательскому анализу данных, статистике, A/B-тестированию, SQL и визуализации. Для каждого проекта доступны описание задачи, инструменты и материалы исследования.

**Основные инструменты:** Python · pandas · NumPy · SciPy · statsmodels · matplotlib · seaborn · SQL / PostgreSQL · DataLens.

## С чего начать

- [A/B-тест рекомендательной системы](projects/01-entertainment-app-ab-test/) — планирование эксперимента и оценка изменения продуктовой метрики.
- [Отток клиентов банка](projects/02-bank-customer-churn/) — исследовательский анализ клиентских сегментов и рекомендации по удержанию.
- [Рынок недвижимости](projects/04-real-estate-sql/) — SQL-анализ, отчёт и интерактивный дашборд.

## Все проекты

| № | Проект | Инструменты и навыки |
|---|---|---|
| 01 | [A/B-тест рекомендательной системы](projects/01-entertainment-app-ab-test/) | Python, pandas, NumPy, matplotlib, statsmodels, A/B-тестирование |
| 02 | [Отток клиентов банка](projects/02-bank-customer-churn/) | Python, pandas, matplotlib, seaborn, phik, EDA |
| 03 | [Рынок общественного питания Москвы](projects/03-moscow-food-market/) | Python, pandas, NumPy, matplotlib, seaborn, phik, EDA |
| 04 | [Рынок недвижимости Санкт-Петербурга и Ленинградской области](projects/04-real-estate-sql/) | SQL, PostgreSQL, CTE, агрегирование, DataLens |
| 05 | [Монетизация игры «Секреты Тёмнолесья»](projects/05-mobile-game-sql/) | SQL, PostgreSQL, CTE, JOIN, оконные функции |
| 06 | [Дашборд TED-конференций](projects/06-ted-dashboard/) | DataLens, дашборды, визуализация данных |
| 07 | [Книжный сервис: гипотезы и A/B-тест](projects/07-book-service-hypotheses-ab/) | Python, pandas, NumPy, SciPy, statsmodels, matplotlib |
| 08 | [Сервис самокатов GoFast: проверка гипотез](projects/08-scooter-service-statistics/) | Python, pandas, matplotlib, SciPy, статистический анализ |
| 09 | [Исследование финансирования стартапов](projects/09-startup-funding/) | Python, pandas, matplotlib, seaborn, EDA |
| 10 | [Анализ игровой индустрии](projects/10-video-game-industry/) | Python, pandas, очистка данных, категоризация |
| 11 | [Исследование ДТП в Кировской области](projects/11-road-accidents/) | Python, pandas, matplotlib, seaborn, Google Colab, EDA |

## Дашборды

- [TED-конференции — DataLens](https://datalens.ru/7bbq8qbmwsrws)
- [Рынок недвижимости — DataLens](https://datalens.ru/nti6sgixfuxg8)

Ссылки перенесены из исходных документов. Их доступность зависит от настроек публикации в DataLens.

## Как смотреть работы

Откройте папку проекта и его README. Ноутбуки `analysis.ipynb` содержат код, пояснения и сохранённые результаты. SQL-проекты содержат `analysis.sql` и отчёты; дашборды доступны по ссылкам выше.

## Повторный запуск

Для Python-проектов установите Jupyter и зависимости соответствующего проекта:

```bash
python -m pip install jupyter
python -m pip install -r projects/02-bank-customer-churn/requirements.txt
python -m jupyter notebook
```

Для каждого ноутбука перечислены нужные данные и особенности путей в README его проекта. Часть файлов загружается по URL, часть ожидается в `/datasets/` или `/content/`. Исходные датасеты и дампы БД не приложены. SQL-запросы рассчитаны на учебные схемы PostgreSQL `fantasy` и `real_estate`.

Ноутбуки и отчёты сохранены в исходном виде, включая учебные формулировки. Выводы относятся к данным учебных проектов. Повторное выполнение анализа и проверка методологии не проводились при оформлении этого репозитория.

/*добавьте сюда запрос для решения задания 2*/

CREATE MATERIALIZED VIEW restaurants_avg_checks_by_year AS
WITH avg_checks AS (
    SELECT
        EXTRACT(YEAR FROM s.sales_date) AS year,
        r.cafe_name AS cafe_name,
        r.cafe_type cafe_type,
        ROUND(AVG(s.avg_check), 2) AS avg_check
    FROM cafe.sales s
    JOIN cafe.restaurants r ON s.restaurant_uuid = r.restaurant_uuid
    WHERE EXTRACT(YEAR FROM s.sales_date) <> 2023
    GROUP BY year, r.cafe_name, r.cafe_type
),
avg_checks_lag AS (
    SELECT
        ac.year,
        ac.cafe_name,
        ac.cafe_type,
        ac.avg_check,
        LAG(ac.avg_check) OVER (PARTITION BY ac.cafe_name ORDER BY ac.year) AS prev_avg_check
    FROM avg_checks ac
)
SELECT
    acwl.year,
    acwl.cafe_name,
    acwl.cafe_type,
    acwl.avg_check,
    acwl.prev_avg_check,
    ROUND(
        CASE
            WHEN acwl.prev_avg_check IS NULL THEN NULL
            ELSE ((acwl.avg_check - acwl.prev_avg_check) / acwl.prev_avg_check) * 100
        END, 2) AS avg_check_change_percentage
FROM avg_checks_lag acwl
ORDER BY acwl.cafe_name, acwl.year;


-- Результат для задания №2.
SELECT
    year AS "Год",
    cafe_name AS "Название заведения",
    cafe_type AS "Тип заведения",
    avg_check AS "Средний чек в этом году",
    prev_avg_check AS "Изменение среднего чека в %"
FROM restaurants_avg_checks_by_year
ORDER BY year ASC;
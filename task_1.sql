/*добавьте сюда запрос для решения задания 1*/

CREATE VIEW top_restaurants_avg_checks AS
WITH avg_checks AS (
    SELECT
        r.cafe_name,
        r.cafe_type,
        ROUND(AVG(s.avg_check), 2) AS avg_check
    FROM cafe.sales s
    JOIN cafe.restaurants r ON s.restaurant_uuid = r.restaurant_uuid
    GROUP BY r.cafe_name, r.cafe_type
),
ranked_restaurants AS (
    SELECT
        ac.cafe_name,
        ac.cafe_type,
        ac.avg_check,
        ROW_NUMBER() OVER (PARTITION BY ac.cafe_type ORDER BY ac.avg_check DESC) AS rank
    FROM avg_checks ac
)
SELECT
    cafe_name,
    cafe_type,
    avg_check
FROM ranked_restaurants
WHERE rank <= 3
ORDER BY cafe_type, avg_check DESC;

-- Результат для задания №1.
SELECT
    cafe_name AS "Название заведения",
    cafe_type AS "Тип заведения",
    avg_check AS "Средний чек"
FROM top_restaurants_avg_checks
ORDER BY avg_check DESC;
/*добавьте сюда запрос для решения задания 3*/

CREATE VIEW top_restaurants_staff_turnover AS
WITH managers_count AS (
    -- Количество смен менеджеров для каждого заведения
    SELECT
        r.cafe_name,
        COUNT(DISTINCT rm.manager_uuid) AS managers_turnover
    FROM cafe.restaurants r
    JOIN cafe.restaurant_manager_work_dates rm ON r.restaurant_uuid = rm.restaurant_uuid
    GROUP BY r.cafe_name
),
ranked_restaurants AS (
    -- Ранжирование заведений по количеству смен менеджеров
    SELECT
        mc.cafe_name,
        mc.managers_turnover,
        ROW_NUMBER() OVER (ORDER BY mc.managers_turnover DESC) AS rank
    FROM managers_count mc
)
-- Выбор топ-3 заведений
SELECT
    cafe_name,
    managers_turnover
FROM ranked_restaurants
WHERE rank <= 3
ORDER BY managers_turnover DESC, cafe_name;

-- Результат выборки представления для задания №3.
SELECT
    cafe_name AS "Название заведения",
    managers_turnover AS "Сколько раз менялся менеджер" 
FROM top_restaurants_staff_turnover
ORDER BY managers_turnover DESC;

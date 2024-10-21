/*добавьте сюда запрос для решения задания 5*/

/*Test 5*/
WITH menu_cte AS (
    -- Извлекаем название кафе, тип блюда, название пиццы, цену
    SELECT 
        rm.cafe_name,
        'Пицца' AS type_food,
        menu_items.key AS pizza_name,
        menu_items.value::numeric AS pizza_price
    FROM 
        raw_data.menu rm
        JOIN jsonb_each_text(rm.menu->'Пицца') AS menu_items ON TRUE
),
menu_with_rank AS (
    -- Ранжируем пиццы по цене в каждой пиццерии
    SELECT 
        cafe_name,
        type_food,
        pizza_name,
        pizza_price,
        ROW_NUMBER() OVER (PARTITION BY cafe_name ORDER BY pizza_price DESC) AS rank
    FROM menu_cte
)
-- Выбираем самую дорогую пиццу для каждой пиццерии
SELECT 
    cafe_name AS "Название заведения",
    type_food AS "Тип блюда",
    pizza_name AS "Название пиццы",
    pizza_price AS "Цена"
FROM menu_with_rank
WHERE rank = 1
ORDER BY cafe_name;
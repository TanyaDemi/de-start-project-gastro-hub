/*добавьте сюда запрос для решения задания 4*/

/*Код обновлен, если таблица cafe.restaurants заполнена верно*/
WITH top_pizzas_menu AS (
    -- Разбираем JSON-меню и выделяем только пиццы
    SELECT 
        r.cafe_name,
        COUNT(menu_items.key) AS pizza_count
    FROM 
        cafe.restaurants r
        JOIN jsonb_each_text(r.menu_jsonb->'Пицца') AS menu_items ON TRUE
    WHERE r.cafe_type = 'pizzeria'
    GROUP BY r.cafe_name
),
ranked_pizzerias AS (
    -- Ранжируем пиццерии по количеству пицц
    SELECT
        cafe_name,
        pizza_count,
        DENSE_RANK() OVER (ORDER BY pizza_count DESC) AS rank
    FROM top_pizzas_menu
)
-- Выбираем пиццерии с максимальным количеством пицц
SELECT
    cafe_name AS "Название заведения",
    pizza_count AS "Количество пицц в меню"
FROM ranked_pizzerias
WHERE rank = 1;


/*Старый код*/
-- Посмотреть тип данных в таблице raw_data.menu в колонке menu json или jsonb.
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'menu' AND column_name = 'menu';

WITH top_pizzas_menu AS (
    -- Разбираем JSON-меню и выделяем только пиццы
    SELECT 
        rm.cafe_name,
        COUNT(menu_items.key) AS pizza_count
    FROM 
        raw_data.menu rm
        JOIN cafe.restaurants r ON rm.cafe_name = r.cafe_name
        JOIN jsonb_each_text(rm.menu->'Пицца') AS menu_items ON TRUE
    WHERE r.cafe_type = 'pizzeria'
    GROUP BY rm.cafe_name
),
ranked_pizzerias AS (
    -- Ранжируем пиццерии по количеству пицц
    SELECT
        cafe_name,
        pizza_count,
        DENSE_RANK() OVER (ORDER BY pizza_count DESC) AS rank
    FROM top_pizzas_menu
)
-- Выбираем пиццерии с максимальным количеством пицц
SELECT
    cafe_name AS "Название заведения",
    pizza_count AS "Количество пицц в меню"
FROM ranked_pizzerias
WHERE rank = 1;


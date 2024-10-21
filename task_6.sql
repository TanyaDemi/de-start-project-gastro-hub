/*добавьте сюда запросы для решения задания 6*/

/*Код обновлен*/
BEGIN;

-- Блокируем только строки, которые содержат капучино, для их обновления
WITH updated_cappuccino_prices AS (
    -- Выбираем и блокируем строки с капучино для обновления
    SELECT 
        r.cafe_name,
        menu_items.key AS cappuccino_name,
        ROUND((menu_items.value::numeric * 1.2), 2) AS new_cappuccino_price
    FROM 
        cafe.restaurants r
        JOIN jsonb_each_text(r.menu_jsonb->'Кофе') AS menu_items ON TRUE
    WHERE menu_items.key ILIKE 'Капучино'
    -- Блокируем строки с капучино для других транзакций
    FOR UPDATE
)
-- Обновляем цены на капучино, используя новые значения из CTE
UPDATE cafe.restaurants r
SET menu_jsonb = jsonb_set(
    r.menu_jsonb,
    ARRAY['Кофе', 'Капучино'],
    to_jsonb(up.new_cappuccino_price)
)
FROM updated_cappuccino_prices up
WHERE r.cafe_name = up.cafe_name;

COMMIT;




/*Блокируем строки с капучино для обновления, чтобы никто не мог их читать или изменять 
в процессе. SHARE - Разрешает другим транзакциям читать строку. Вносить изменения нельзя. 
Выражение ROW — конструктор строк, который принимает в качестве аргументов перечень полей 
и создаёт из них строку для составного типа данных или таблицы. EXCLUSIVE — совместима 
только с чтением таблицы и несовместима с любыми изменениями данных в ней, даже с 
оператором SELECT .. FOR UPDATE/SELECT .. FOR NO KEY UPDATE. Одновременно на таблице может 
быть только одна блокировка EXCLUSIVE. Пригодится, когда нужно запретить другим транзакциям 
редактировать данные в таблице, но оставить им возможность эти данные читать.*/

BEGIN;

-- Блокируем строки с капучино для обновления, чтобы никто не мог их читать или изменять в процессе
LOCK TABLE raw_data.menu IN SHARE ROW EXCLUSIVE MODE; 

-- Создаем CTE для расчета новых цен на капучино с увеличением на 20%
WITH updated_cappuccino_prices AS (
    SELECT 
        rm.cafe_name,
        'Кофе' AS type_food,
        menu_items.key AS cappuccino_name,
        ROUND((menu_items.value::numeric * 1.2), 2) AS new_cappuccino_price
    FROM 
        raw_data.menu rm
        JOIN jsonb_each_text(rm.menu->'Кофе') AS menu_items ON TRUE
    WHERE menu_items.key ILIKE 'Капучино'
)
-- Обновляем цены на капучино, используя новые значения из CTE
UPDATE raw_data.menu rm
SET menu = jsonb_set(
    rm.menu,
    ARRAY['Кофе', 'Капучино'],
    to_jsonb(up.new_cappuccino_price)
)
FROM updated_cappuccino_prices up
WHERE rm.cafe_name = up.cafe_name;

COMMIT;

/*добавьте сюда запросы для решения задания 6*/

BEGIN;

-- Блокируем таблицу cafe.managers, чтобы она была доступна только для чтения, но недоступна для изменений
LOCK TABLE cafe.managers IN SHARE ROW EXCLUSIVE MODE;

-- Сначала добавляем новое поле для массива телефонов
ALTER TABLE cafe.managers ADD COLUMN new_phones varchar[];

-- Создаем CTE для ранжирования менеджеров и определения новых номеров телефонов
WITH ranked_managers AS (
    SELECT
        m.manager_uuid,
        m.name_manager,
        m.phone,
        ROW_NUMBER() OVER (ORDER BY m.name_manager ASC) AS rank
    FROM 
        cafe.managers m
),
updated_managers_phones AS (
    SELECT
        manager_uuid,
        phone,
        CONCAT('8-800-2500-', (99 + rank)) AS new_phone,
        ARRAY[CONCAT('8-800-2500-', (99 + rank)), phone] AS new_phones_array
    FROM ranked_managers
)
-- Обновляем таблицу cafe.managers, чтобы добавить массив с новыми и старыми номерами
UPDATE cafe.managers m
SET new_phones = up.new_phones_array
FROM updated_managers_phones up
WHERE m.manager_uuid = up.manager_uuid;

-- Удаляем старое поле с телефоном
ALTER TABLE cafe.managers DROP COLUMN phone;

COMMIT;

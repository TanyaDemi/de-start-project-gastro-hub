/*Добавьте в этот файл запросы, которые наполняют данными таблицы в схеме cafe данными*/


/*Наполняем таблицу cafe.restaurants с информацией о ресторанах. 
В качестве первичного ключа использован случайно сгенерированный uuid. 
Таблица хранит: restaurant_uuid, название заведения, тип заведения, 
который вы создали на первом шаге, и меню.*/

INSERT INTO cafe.restaurants (cafe_name, cafe_type)
SELECT DISTINCT 
    s.cafe_name, 
    s.type::cafe.restaurant_type
FROM raw_data.sales s;

/*Замена кода для наполнения таблицы верно согласно задания с начала */
INSERT INTO cafe.restaurants (cafe_name, cafe_type, menu_jsonb)
SELECT DISTINCT 
    m.cafe_name AS cafe_name, 
    s.type::cafe.restaurant_type AS cafe_type,
    m.menu::jsonb AS menu_jsonb
FROM raw_data.menu m
JOIN raw_data.sales s ON s.cafe_name = m.cafe_name
GROUP BY m.cafe_name, s.type, m.menu;

   
/*Наполняем  таблицу cafe.managers с информацией о менеджерах. 
В качестве первичного ключа использован случайно сгенерированный uuid. 
Таблица хранит: manager_uuid, имя менеджера и его телефон.*/

INSERT INTO cafe.managers (name_manager, phone)
SELECT DISTINCT
    s.manager as name_manager,
    s.manager_phone as phone
FROM raw_data.sales s;


/*Наполняем таблицу cafe.restaurant_manager_work_dates. Таблица хранит: 
 restaurant_uuid, manager_uuid, дату начала работы в ресторане и дату окончания 
 работы в ресторане (придумайте названия этим полям). Задан составной первичный 
 ключ из двух полей: restaurant_uuid и manager_uuid. Работа менеджера в ресторане 
 от даты начала до даты окончания — единый период, без перерывов.*/

INSERT INTO cafe.restaurant_manager_work_dates (restaurant_uuid, manager_uuid, work_start_date, work_end_date)
SELECT 
    r.restaurant_uuid,
    m.manager_uuid,
    MIN(s.report_date) AS work_start_date,
    MAX(s.report_date) AS work_end_date
FROM raw_data.sales s
JOIN cafe.restaurants r ON s.cafe_name = r.cafe_name
JOIN cafe.managers m ON s.manager = m.name_manager
GROUP BY r.restaurant_uuid, m.manager_uuid;

/*Наполняем таблицу cafe.sales со столбцами: date, restaurant_uuid, avg_check. 
 Задан составной первичный ключ из даты и uuid ресторана.*/

INSERT INTO cafe.sales (sales_date, restaurant_uuid, avg_check)
SELECT 
    s.report_date AS sales_date,
    r.restaurant_uuid,
    AVG(s.avg_check) AS avg_check
FROM raw_data.sales s
JOIN cafe.restaurants r ON s.cafe_name = r.cafe_name
GROUP BY s.report_date, r.restaurant_uuid;

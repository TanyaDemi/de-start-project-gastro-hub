/*Добавьте в этот файл все запросы, для создания схемы сafe и
 таблиц в ней в нужном порядке*/

/*Удаляем предыдущую схему с БД Автосалон "Врум Бум" и создаем новую для Гастро Хаба*/

DROP SCHEMA raw_data CASCADE;  

CREATE SCHEMA IF NOT EXISTS raw_data;

/*Вот пошаговая инструкция:
Шаг 1. Создайте enum cafe.restaurant_type с типом заведения coffee_shop, restaurant, bar, pizzeria.*/

CREATE SCHEMA IF NOT EXISTS cafe;

CREATE TYPE cafe.restaurant_type AS ENUM 
    ('coffee_shop', 'restaurant', 'bar', 'pizzeria');

/*Шаг 2. Создайте таблицу cafe.restaurants с информацией о ресторанах. 
В качестве первичного ключа используйте случайно сгенерированный uuid. 
Таблица хранит: restaurant_uuid, название заведения, тип заведения, 
который вы создали на первом шаге, и меню.*/

CREATE TABLE cafe.restaurants (
    restaurant_uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cafe_name VARCHAR(100) NOT NULL,
    cafe_type cafe.restaurant_type NOT NULL
);

/*Вариант 1. Замена кода для создания таблицы верно согласно задания с начала */
CREATE TABLE cafe.restaurants (
    restaurant_uuid UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cafe_name VARCHAR(100) NOT NULL,
    cafe_type cafe.restaurant_type NOT NULL,
    menu_jsonb JSONB NOT NULL -- Тип данных JSONB используется для хранения меню
);
/*Вариант 2. Добавить колонку и заполнить данными */
ALTER TABLE cafe.restaurants
ADD COLUMN menu_jsonb JSONB;

UPDATE cafe.restaurants r
SET menu_jsonb = m.menu::jsonb
FROM raw_data.menu m
JOIN raw_data.sales s ON s.cafe_name = m.cafe_name
WHERE r.cafe_name = m.cafe_name;


/*Шаг 3. Создайте таблицу cafe.managers с информацией о менеджерах. 
В качестве первичного ключа используйте случайно сгенерированный uuid. 
Таблица хранит: manager_uuid, имя менеджера и его телефон.*/

CREATE TABLE cafe.managers (
    manager_uuid uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name_manager varchar(200) NOT NULL,
    phone varchar(50)
);

/*Шаг 4. Создайте таблицу cafe.restaurant_manager_work_dates. Таблица хранит: 
 restaurant_uuid, manager_uuid, дату начала работы в ресторане и дату окончания 
 работы в ресторане (придумайте названия этим полям). Задайте составной первичный 
 ключ из двух полей: restaurant_uuid и manager_uuid. Работа менеджера в ресторане 
 от даты начала до даты окончания — единый период, без перерывов.*/

CREATE TABLE cafe.restaurant_manager_work_dates (
    restaurant_uuid uuid NOT NULL,
    manager_uuid uuid NOT NULL,
    work_start_date DATE NOT NULL,
    work_end_date DATE NOT NULL,
    PRIMARY KEY (restaurant_uuid, manager_uuid),
    FOREIGN KEY (restaurant_uuid) REFERENCES cafe.restaurants(restaurant_uuid),
    FOREIGN KEY (manager_uuid) REFERENCES cafe.managers(manager_uuid)
);

/*Шаг 5. Создайте таблицу cafe.sales со столбцами: date, restaurant_uuid, avg_check. 
 Задайте составной первичный ключ из даты и uuid ресторана.*/

CREATE TABLE cafe.sales (
    sales_date DATE NOT NULL,
    restaurant_uuid UUID NOT NULL,
    avg_check NUMERIC(10, 2),
    PRIMARY KEY (sales_date, restaurant_uuid),
    FOREIGN KEY (restaurant_uuid) REFERENCES cafe.restaurants(restaurant_uuid)
);

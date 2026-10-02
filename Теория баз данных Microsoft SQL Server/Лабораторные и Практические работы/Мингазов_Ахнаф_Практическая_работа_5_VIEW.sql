/*
============================================================
Практическая работа №5
"Представления (VIEW): аналитика кулинарного сервиса"

Студент: Мингазов Ахнаф
СУБД: Microsoft SQL Server
============================================================
*/

USE master;
GO

/* Создание базы данных */
IF DB_ID('CookingDB') IS NULL
BEGIN
    CREATE DATABASE CookingDB;
END;
GO

USE CookingDB;
GO

/* Создание схемы */
IF SCHEMA_ID('kitchen') IS NULL
    EXEC('CREATE SCHEMA kitchen');
GO


/* =========================================================
   1. СОЗДАНИЕ ТАБЛИЦ
   ========================================================= */

IF OBJECT_ID('kitchen.categories', 'U') IS NULL
BEGIN
    CREATE TABLE kitchen.categories
    (
        id INT PRIMARY KEY,
        name NVARCHAR(100) NOT NULL
    );
END;
GO

IF OBJECT_ID('kitchen.dishes', 'U') IS NULL
BEGIN
    CREATE TABLE kitchen.dishes
    (
        id INT PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        category_id INT NOT NULL,
        price DECIMAL(10, 2) NOT NULL,

        CONSTRAINT FK_dishes_categories
            FOREIGN KEY (category_id)
            REFERENCES kitchen.categories(id)
    );
END;
GO

IF OBJECT_ID('kitchen.orders', 'U') IS NULL
BEGIN
    CREATE TABLE kitchen.orders
    (
        id INT PRIMARY KEY,
        customer_name NVARCHAR(100) NOT NULL,
        order_date DATE NOT NULL
    );
END;
GO

IF OBJECT_ID('kitchen.order_items', 'U') IS NULL
BEGIN
    CREATE TABLE kitchen.order_items
    (
        id INT PRIMARY KEY,
        order_id INT NOT NULL,
        dish_id INT NOT NULL,
        quantity INT NOT NULL,

        CONSTRAINT FK_order_items_orders
            FOREIGN KEY (order_id)
            REFERENCES kitchen.orders(id),

        CONSTRAINT FK_order_items_dishes
            FOREIGN KEY (dish_id)
            REFERENCES kitchen.dishes(id)
    );
END;
GO


/* =========================================================
   2. ЗАПОЛНЕНИЕ БАЗЫ ДАННЫХ
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM kitchen.categories)
BEGIN
    INSERT INTO kitchen.categories (id, name)
    VALUES
        (1, N'Пицца'),
        (2, N'Супы'),
        (3, N'Основные блюда'),
        (4, N'Десерты');
END;
GO

IF NOT EXISTS (SELECT 1 FROM kitchen.dishes)
BEGIN
    INSERT INTO kitchen.dishes
        (id, name, category_id, price)
    VALUES
        (1, N'Маргарита', 1, 550),
        (2, N'Пепперони', 1, 650),
        (3, N'Том Ям', 2, 480),
        (4, N'Крем-суп грибной', 2, 350),
        (5, N'Паста Карбонара', 3, 590),
        (6, N'Стейк с овощами', 3, 950),
        (7, N'Чизкейк', 4, 320),
        (8, N'Тирамису', 4, 380);
END;
GO

IF NOT EXISTS (SELECT 1 FROM kitchen.orders)
BEGIN
    INSERT INTO kitchen.orders
        (id, customer_name, order_date)
    VALUES
        (1, N'Анна', '2026-09-01'),
        (2, N'Иван', '2026-09-02'),
        (3, N'Мария', '2026-09-03'),
        (4, N'Алексей', '2026-09-04'),
        (5, N'Ольга', '2026-09-05');
END;
GO

IF NOT EXISTS (SELECT 1 FROM kitchen.order_items)
BEGIN
    INSERT INTO kitchen.order_items
        (id, order_id, dish_id, quantity)
    VALUES
        (1, 1, 1, 2),
        (2, 1, 7, 1),
        (3, 2, 2, 1),
        (4, 2, 5, 1),
        (5, 3, 3, 2),
        (6, 3, 8, 1),
        (7, 4, 6, 1),
        (8, 4, 4, 1),
        (9, 5, 1, 1),
        (10, 5, 8, 2);
END;
GO


/* =========================================================
   3. ПРЕДСТАВЛЕНИЕ МЕНЮ
   kitchen.menu

   Показывает:
   - название блюда
   - категорию
   - цену
   ========================================================= */

CREATE OR ALTER VIEW kitchen.menu
AS
SELECT
    d.name AS dish_name,
    c.name AS category_name,
    d.price
FROM kitchen.dishes d
JOIN kitchen.categories c
    ON d.category_id = c.id;
GO

/* Проверка представления */
SELECT *
FROM kitchen.menu;
GO


/* =========================================================
   4. ПРЕДСТАВЛЕНИЕ СОСТАВА ЗАКАЗОВ
   kitchen.order_details
   ========================================================= */

CREATE OR ALTER VIEW kitchen.order_details
AS
SELECT
    o.id AS order_id,
    o.customer_name,
    o.order_date,
    d.name AS dish_name,
    oi.quantity,
    d.price
FROM kitchen.orders o
JOIN kitchen.order_items oi
    ON o.id = oi.order_id
JOIN kitchen.dishes d
    ON oi.dish_id = d.id;
GO

/* Проверка представления */
SELECT *
FROM kitchen.order_details;
GO


/* =========================================================
   5. ПРЕДСТАВЛЕНИЕ СТОИМОСТИ ЗАКАЗОВ
   kitchen.order_totals

   Стоимость позиции:
   price * quantity

   Общая стоимость:
   SUM(price * quantity)
   ========================================================= */

CREATE OR ALTER VIEW kitchen.order_totals
AS
SELECT
    o.id AS order_id,
    o.customer_name,
    o.order_date,
    SUM(d.price * oi.quantity) AS total_price
FROM kitchen.orders o
JOIN kitchen.order_items oi
    ON o.id = oi.order_id
JOIN kitchen.dishes d
    ON oi.dish_id = d.id
GROUP BY
    o.id,
    o.customer_name,
    o.order_date;
GO

/* Проверка представления */
SELECT *
FROM kitchen.order_totals;
GO


/* =========================================================
   6. ИСПОЛЬЗОВАНИЕ ПРЕДСТАВЛЕНИЙ
   Задание 1:
   Блюда дешевле 500
   ========================================================= */

SELECT *
FROM kitchen.menu
WHERE price < 500;
GO


/* =========================================================
   Задание 2:
   Заказы стоимостью более 1000
   ========================================================= */

SELECT *
FROM kitchen.order_totals
WHERE total_price > 1000;
GO


/* =========================================================
   Задание 3:
   Самый дорогой заказ
   TOP + ORDER BY
   ========================================================= */

SELECT TOP 1
    *
FROM kitchen.order_totals
ORDER BY total_price DESC;
GO


/* =========================================================
   7. ИЗМЕНЕНИЕ ПРЕДСТАВЛЕНИЯ kitchen.menu
   ALTER VIEW

   до 500       -> Обычное
   500–700      -> Средняя цена
   более 700    -> Дорогое
   ========================================================= */

ALTER VIEW kitchen.menu
AS
SELECT
    d.name AS dish_name,
    c.name AS category_name,
    d.price,
    CASE
        WHEN d.price < 500
            THEN N'Обычное'
        WHEN d.price <= 700
            THEN N'Средняя цена'
        ELSE N'Дорогое'
    END AS price_category
FROM kitchen.dishes d
JOIN kitchen.categories c
    ON d.category_id = c.id;
GO

/* Проверка изменённого представления */
SELECT *
FROM kitchen.menu;
GO


/* =========================================================
   8. ИТОГОВЫЙ АНАЛИТИЧЕСКИЙ ЗАПРОС
   Использование VIEW kitchen.order_totals
   + оконная функция RANK()
   ========================================================= */

SELECT
    customer_name,
    total_price,
    RANK() OVER
    (
        ORDER BY total_price DESC
    ) AS rating
FROM kitchen.order_totals
ORDER BY rating, customer_name;
GO


/* =========================================================
   ДОПОЛНИТЕЛЬНАЯ ПРОВЕРКА ВСЕХ ПРЕДСТАВЛЕНИЙ
   ========================================================= */

SELECT *
FROM kitchen.menu;
GO

SELECT *
FROM kitchen.order_details;
GO

SELECT *
FROM kitchen.order_totals;
GO


/* =========================================================
   ВОПРОСЫ ДЛЯ САМОПРОВЕРКИ

   1. VIEW — это сохранённый запрос, который можно использовать
      как виртуальную таблицу.

   2. VIEW отличается от обычной таблицы тем, что представление
      хранит запрос, а не отдельный набор данных.

   3. JOIN используется для объединения данных из нескольких
      таблиц внутри представления.

   4. GROUP BY нужен в order_totals для объединения позиций
      одного заказа и расчёта его общей стоимости.

   5. CREATE VIEW создаёт новое представление,
      ALTER VIEW изменяет существующее представление.

   6. Да, к результату VIEW можно применять WHERE.

   7. VIEW удобно использовать для сложных запросов,
      чтобы не повторять один и тот же запрос каждый раз.

   8. В итоговом запросе RANK() определяет место каждого заказа
      по его стоимости.
============================================================
*/

-- Новая учебная база для практик №1–5. Не меняет существующую coffee_shop_Check_f1897f9e.
-- При наличии одноимённой базы проверьте схему вручную или используйте другое имя.
USE master;
GO
IF DB_ID(N'coffee_shop_Check_f1897f9e') IS NOT NULL
BEGIN
    RAISERROR(N'coffee_shop_Check_f1897f9e уже существует. Создание остановлено; данные не изменены.', 16, 1);
    SET NOEXEC ON;
END;
GO
CREATE DATABASE coffee_shop_Check_f1897f9e;
GO
USE coffee_shop_Check_f1897f9e;
GO
CREATE TABLE dbo.categories(id int IDENTITY PRIMARY KEY, name nvarchar(100) NOT NULL);
CREATE TABLE dbo.customers
(
    id int IDENTITY PRIMARY KEY, full_name nvarchar(200) NOT NULL,
    phone nvarchar(30) NULL, email nvarchar(254) NULL
);
CREATE TABLE dbo.products
(
    id int IDENTITY PRIMARY KEY, name nvarchar(150) NOT NULL,
    category_id int NOT NULL REFERENCES dbo.categories(id),
    price decimal(10,2) NOT NULL CHECK(price >= 0),
    is_available bit NOT NULL DEFAULT 1
);
CREATE TABLE dbo.orders
(
    id int IDENTITY PRIMARY KEY, customer_id int NOT NULL REFERENCES dbo.customers(id),
    order_date datetime2 NOT NULL DEFAULT SYSDATETIME(), status nvarchar(30) NOT NULL
);
CREATE TABLE dbo.order_items
(
    id int IDENTITY PRIMARY KEY, order_id int NOT NULL REFERENCES dbo.orders(id),
    product_id int NOT NULL REFERENCES dbo.products(id),
    quantity int NOT NULL CHECK(quantity > 0),
    unit_price decimal(10,2) NOT NULL CHECK(unit_price >= 0)
);
GO
INSERT INTO dbo.categories(name) VALUES(N'Напитки'), (N'Десерты');
INSERT INTO dbo.customers(full_name, phone, email)
VALUES(N'Иван Петров', N'+79001234567', N'ivan@example.test'),
      (N'Анна Иванова', NULL, NULL), (N'Мингазов Ахнаф', NULL, N'student@example.test');
INSERT INTO dbo.products(name, category_id, price, is_available)
VALUES(N'Эспрессо', 1, 120, 1), (N'Американо', 1, 140, 1),
      (N'Капучино', 1, 190, 1), (N'Латте', 1, 210, 1),
      (N'Чизкейк', 2, 280, 1), (N'Круассан', 2, 150, 0);
INSERT INTO dbo.orders(customer_id, order_date, status)
VALUES(1, SYSDATETIME(), N'Выдан'), (2, SYSDATETIME(), N'Новый');
INSERT INTO dbo.order_items(order_id, product_id, quantity, unit_price)
VALUES(1, 1, 2, 120), (2, 5, 1, 280);
GO

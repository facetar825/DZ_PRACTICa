/*
    Практическая работа №6
    Хранимые процедуры: управление операциями риелторской компании

    Студент: Мингазов Ахнаф
    СУБД: Microsoft SQL Server
*/

-- ============================================================
-- 1. СОЗДАНИЕ БАЗЫ ДАННЫХ
-- ============================================================

IF DB_ID(N'RealtyDB') IS NULL
BEGIN
    CREATE DATABASE RealtyDB;
END
GO

USE RealtyDB;
GO

-- ============================================================
-- 2. СОЗДАНИЕ СХЕМЫ
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'realty')
BEGIN
    EXEC(N'CREATE SCHEMA realty');
END
GO

-- ============================================================
-- 3. СОЗДАНИЕ ТАБЛИЦ
-- ============================================================

IF OBJECT_ID(N'realty.agents', N'U') IS NULL
BEGIN
    CREATE TABLE realty.agents
    (
        id INT PRIMARY KEY,
        name NVARCHAR(100) NOT NULL
    );
END
GO

IF OBJECT_ID(N'realty.clients', N'U') IS NULL
BEGIN
    CREATE TABLE realty.clients
    (
        id INT PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        phone NVARCHAR(30) NOT NULL
    );
END
GO

IF OBJECT_ID(N'realty.properties', N'U') IS NULL
BEGIN
    CREATE TABLE realty.properties
    (
        id INT PRIMARY KEY,
        address NVARCHAR(200) NOT NULL,
        property_type NVARCHAR(50) NOT NULL,
        price DECIMAL(12, 2) NOT NULL,
        rooms INT NOT NULL,
        agent_id INT NOT NULL,
        CONSTRAINT FK_properties_agents
            FOREIGN KEY (agent_id) REFERENCES realty.agents(id)
    );
END
GO

IF OBJECT_ID(N'realty.deals', N'U') IS NULL
BEGIN
    CREATE TABLE realty.deals
    (
        id INT PRIMARY KEY,
        client_id INT NOT NULL,
        property_id INT NOT NULL,
        agent_id INT NOT NULL,
        deal_date DATE NOT NULL,
        deal_price DECIMAL(12, 2) NOT NULL,
        CONSTRAINT FK_deals_clients
            FOREIGN KEY (client_id) REFERENCES realty.clients(id),
        CONSTRAINT FK_deals_properties
            FOREIGN KEY (property_id) REFERENCES realty.properties(id),
        CONSTRAINT FK_deals_agents
            FOREIGN KEY (agent_id) REFERENCES realty.agents(id)
    );
END
GO

-- ============================================================
-- 4. ЗАПОЛНЕНИЕ ТАБЛИЦ
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM realty.agents)
BEGIN
    INSERT INTO realty.agents (id, name)
    VALUES
        (1, N'Анна Смирнова'),
        (2, N'Иван Петров'),
        (3, N'Мария Орлова');
END
GO

IF NOT EXISTS (SELECT 1 FROM realty.clients)
BEGIN
    INSERT INTO realty.clients (id, name, phone)
    VALUES
        (1, N'Алексей Иванов', N'+7-900-111-11-11'),
        (2, N'Ольга Соколова', N'+7-900-222-22-22'),
        (3, N'Дмитрий Волков', N'+7-900-333-33-33'),
        (4, N'Елена Морозова', N'+7-900-444-44-44');
END
GO

IF NOT EXISTS (SELECT 1 FROM realty.properties)
BEGIN
    INSERT INTO realty.properties
        (id, address, property_type, price, rooms, agent_id)
    VALUES
        (1, N'ул. Центральная, 10', N'Квартира', 5200000, 2, 1),
        (2, N'ул. Лесная, 25', N'Квартира', 6800000, 3, 1),
        (3, N'ул. Садовая, 7', N'Дом', 9500000, 4, 2),
        (4, N'ул. Молодёжная, 18', N'Квартира', 4300000, 3, 2),
        (5, N'ул. Речная, 4', N'Дом', 12500000, 5, 3),
        (6, N'ул. Школьная, 31', N'Квартира', 3900000, 1, 3);
END
GO

-- ============================================================
-- 5. ПРОЦЕДУРА FindProperties
-- Поиск объектов по максимальной цене и количеству комнат
-- ============================================================

CREATE OR ALTER PROCEDURE realty.FindProperties
    @max_price DECIMAL(12, 2),
    @rooms INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        p.address,
        p.property_type,
        p.price,
        p.rooms,
        a.name AS agent_name
    FROM realty.properties p
    INNER JOIN realty.agents a
        ON a.id = p.agent_id
    WHERE p.price <= @max_price
      AND p.rooms = @rooms
    ORDER BY p.price;
END
GO

-- Проверка FindProperties
EXEC realty.FindProperties
    @max_price = 7000000,
    @rooms = 3;
GO

-- ============================================================
-- 6. ПРОЦЕДУРА GetClient
-- Получение информации о клиенте
-- ============================================================

CREATE OR ALTER PROCEDURE realty.GetClient
    @client_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM realty.clients
        WHERE id = @client_id
    )
    BEGIN
        SELECT
            N'Клиент с указанным ID не найден.' AS message;
        RETURN;
    END;

    SELECT
        id,
        name,
        phone
    FROM realty.clients
    WHERE id = @client_id;
END
GO

-- Проверка GetClient
EXEC realty.GetClient
    @client_id = 2;
GO

-- Проверка GetClient с отсутствующим клиентом
EXEC realty.GetClient
    @client_id = 999;
GO

-- ============================================================
-- 7. ПРОЦЕДУРА CreateDeal
-- Регистрация сделки с проверками, TRY...CATCH,
-- THROW и OUTPUT
-- ============================================================

CREATE OR ALTER PROCEDURE realty.CreateDeal
    @client_id INT,
    @property_id INT,
    @agent_id INT,
    @deal_price DECIMAL(12, 2),
    @deal_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Значение OUTPUT по умолчанию
        SET @deal_id = NULL;

        -- Проверка клиента
        IF NOT EXISTS
        (
            SELECT 1
            FROM realty.clients
            WHERE id = @client_id
        )
        BEGIN
            THROW 50001, N'Клиент не найден.', 1;
        END;

        -- Проверка объекта недвижимости
        IF NOT EXISTS
        (
            SELECT 1
            FROM realty.properties
            WHERE id = @property_id
        )
        BEGIN
            THROW 50002, N'Объект недвижимости не найден.', 1;
        END;

        -- Проверка риелтора
        IF NOT EXISTS
        (
            SELECT 1
            FROM realty.agents
            WHERE id = @agent_id
        )
        BEGIN
            THROW 50003, N'Риелтор не найден.', 1;
        END;

        -- Проверка цены
        IF @deal_price <= 0
        BEGIN
            THROW 50004, N'Цена сделки должна быть положительной.', 1;
        END;

        -- Создание новой сделки.
        -- ID рассчитывается как следующий после максимального.
        DECLARE @new_id INT;

        SELECT @new_id = ISNULL(MAX(id), 0) + 1
        FROM realty.deals;

        INSERT INTO realty.deals
        (
            id,
            client_id,
            property_id,
            agent_id,
            deal_date,
            deal_price
        )
        VALUES
        (
            @new_id,
            @client_id,
            @property_id,
            @agent_id,
            CAST(GETDATE() AS DATE),
            @deal_price
        );

        SET @deal_id = @new_id;

    END TRY
    BEGIN CATCH

        SELECT
            ERROR_NUMBER() AS error_number,
            ERROR_MESSAGE() AS error_message;

    END CATCH;
END
GO

-- ============================================================
-- 8. ПРОВЕРКА CreateDeal
-- Сценарий 1: корректная сделка
-- ============================================================

DECLARE @new_deal_id INT;

EXEC realty.CreateDeal
    @client_id = 1,
    @property_id = 2,
    @agent_id = 1,
    @deal_price = 6500000,
    @deal_id = @new_deal_id OUTPUT;

SELECT @new_deal_id AS new_deal_id;
GO

-- ============================================================
-- Сценарий 2: несуществующий клиент
-- Ожидается ошибка, новая запись не создаётся
-- ============================================================

DECLARE @bad_deal_id INT;

EXEC realty.CreateDeal
    @client_id = 999,
    @property_id = 2,
    @agent_id = 1,
    @deal_price = 6500000,
    @deal_id = @bad_deal_id OUTPUT;
GO

-- ============================================================
-- Сценарий 3: некорректная цена
-- Ожидается ошибка, новая запись не создаётся
-- ============================================================

DECLARE @bad_price_deal_id INT;

EXEC realty.CreateDeal
    @client_id = 1,
    @property_id = 2,
    @agent_id = 1,
    @deal_price = -1000,
    @deal_id = @bad_price_deal_id OUTPUT;
GO

-- ============================================================
-- 9. ПРОВЕРКА РЕЗУЛЬТАТОВ СОЗДАНИЯ СДЕЛОК
-- ============================================================

SELECT
    d.id,
    c.name AS client_name,
    p.address,
    a.name AS agent_name,
    d.deal_date,
    d.deal_price
FROM realty.deals d
INNER JOIN realty.clients c
    ON c.id = d.client_id
INNER JOIN realty.properties p
    ON p.id = d.property_id
INNER JOIN realty.agents a
    ON a.id = d.agent_id
ORDER BY d.id;
GO

-- ============================================================
-- 10. ПРОЦЕДУРА GetAgentStatistics
-- Статистика риелтора:
-- имя, количество объектов, количество сделок,
-- общая стоимость сделок
-- ============================================================

CREATE OR ALTER PROCEDURE realty.GetAgentStatistics
    @agent_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.name AS agent_name,
        COUNT(DISTINCT p.id) AS property_count,
        COUNT(DISTINCT d.id) AS deal_count,
        ISNULL(SUM(d.deal_price), 0) AS total_deal_value
    FROM realty.agents a
    LEFT JOIN realty.properties p
        ON p.agent_id = a.id
    LEFT JOIN realty.deals d
        ON d.agent_id = a.id
    WHERE a.id = @agent_id
    GROUP BY a.id, a.name;
END
GO

-- Проверка GetAgentStatistics
EXEC realty.GetAgentStatistics
    @agent_id = 1;
GO

-- Дополнительная проверка для других риелторов
EXEC realty.GetAgentStatistics
    @agent_id = 2;
GO

EXEC realty.GetAgentStatistics
    @agent_id = 3;
GO

-- ============================================================
-- 11. ИТОГОВЫЕ SELECT ДЛЯ ПРОВЕРКИ
-- ============================================================

-- Все риелторы
SELECT *
FROM realty.agents;
GO

-- Все клиенты
SELECT *
FROM realty.clients;
GO

-- Все объекты недвижимости
SELECT *
FROM realty.properties;
GO

-- Все сделки
SELECT *
FROM realty.deals;
GO

-- Полная информация о сделках
SELECT
    d.id,
    c.name AS client_name,
    p.address,
    p.property_type,
    a.name AS agent_name,
    d.deal_date,
    d.deal_price
FROM realty.deals d
INNER JOIN realty.clients c
    ON c.id = d.client_id
INNER JOIN realty.properties p
    ON p.id = d.property_id
INNER JOIN realty.agents a
    ON a.id = d.agent_id
ORDER BY d.id;
GO

/*
============================================================
ОТВЕТЫ НА ВОПРОСЫ ДЛЯ САМОПРОВЕРКИ

1. Что такое хранимая процедура?
Хранимая процедура — это сохранённый в базе данных набор SQL-команд,
который можно запускать по имени и передавать ему параметры.

2. Для чего нужны параметры процедуры?
Параметры позволяют передавать процедуре входные данные и получать
результаты через выходные параметры.

3. Зачем в CreateDeal используется OUTPUT?
OUTPUT используется для возврата ID созданной сделки вызывающему коду.

4. Для чего используется IF NOT EXISTS?
IF NOT EXISTS позволяет проверить отсутствие записи перед выполнением
операции, например перед созданием сделки.

5. Что делает TRY...CATCH?
TRY...CATCH позволяет перехватывать ошибки, возникающие во время
выполнения SQL-команд.

6. Для чего нужен THROW?
THROW позволяет самостоятельно создать и передать ошибку с заданным
номером и сообщением.

7. Чем SELECT внутри процедуры отличается от OUTPUT?
SELECT возвращает набор строк как результат запроса, а OUTPUT возвращает
конкретное значение через параметр процедуры.

8. Почему проверку входных данных удобно выполнять внутри процедуры?
Так процедура сама защищает операцию от неправильных данных независимо
от того, откуда она была вызвана.

9. Может ли процедура изменять данные в таблицах?
Да. Процедура может выполнять INSERT, UPDATE и DELETE.

10. В чём отличие процедуры от VIEW?
VIEW представляет собой сохранённый запрос для получения данных.
Процедура может принимать параметры, выполнять проверки, изменять данные,
обрабатывать ошибки и возвращать результаты.
============================================================
*/

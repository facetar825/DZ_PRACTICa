-- SQL Server Management Studio. Создание базы данных и таблиц.
-- Мингазов Александр Рашидович, группа 9/2-РПО-24/1.
-- Откройте файл в SSMS и выполните целиком (F5).

USE master;
GO

IF DB_ID(N'CollegeDB') IS NULL
    EXEC(N'CREATE DATABASE CollegeDB;');
GO

USE CollegeDB;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

IF SCHEMA_ID(N'college') IS NULL
    EXEC(N'CREATE SCHEMA college AUTHORIZATION dbo;');

-- Повторный запуск показывает результат, не изменяя существующие группы.
IF OBJECT_ID(N'college.groups', N'U') IS NOT NULL
BEGIN
    PRINT N'Таблица college.groups уже существует. Данные сохранены.';
    SELECT id, name, course FROM college.groups ORDER BY id;
    RETURN;
END;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Задание 1. Создание таблицы групп.
    CREATE TABLE college.groups
    (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        course INT NOT NULL
    );

    -- Задание 2. Добавление пяти групп разных курсов.
    INSERT INTO college.groups (name, course)
    VALUES
        (N'ИС-31', 3),
        (N'ИС-32', 3),
        (N'ПР-21', 2),
        (N'ПР-41', 4),
        (N'ДИЗ-11', 1);

    -- Задание 3. Все группы: пять строк.
    SELECT id, name, course
    FROM college.groups
    ORDER BY id;

    -- Задание 4. Группы третьего курса: ИС-31 и ИС-32.
    SELECT id, name, course
    FROM college.groups
    WHERE course = 3
    ORDER BY id;

    -- Задание 5. Переименование одной группы по первичному ключу.
    UPDATE college.groups
    SET name = N'ИС-33'
    WHERE id = 2;

    SELECT id, name, course
    FROM college.groups
    WHERE id = 2;

    -- Задание 6. Удаление одной группы — ДИЗ-11.
    DELETE FROM college.groups
    WHERE id = 5;

    -- Задание 7. Курс не может быть меньше 1.
    -- WITH CHECK проверяет также уже добавленные строки.
    ALTER TABLE college.groups WITH CHECK
    ADD CONSTRAINT CK_groups_course CHECK (course >= 1);

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- Итог: четыре группы; у группы с id = 2 название ИС-33.
SELECT id, name, course
FROM college.groups
ORDER BY id;

-- Просмотр созданного ограничения.
SELECT name, definition, is_disabled, is_not_trusted
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID(N'college.groups');

-- Задание 8. Просмотр в Object Explorer выполняется вручную в SSMS:
-- 1. Подключитесь к localhost с Windows Authentication.
-- 2. Откройте Databases -> CollegeDB -> Tables.
-- 3. Нажмите Refresh, если новая таблица не появилась.
-- 4. Раскройте college.groups -> Columns: id, name, course.
-- 5. Раскройте Constraints: CK_groups_course.
-- 6. Правой кнопкой по college.groups -> Select Top 1000 Rows.
--    Должны отображаться ИС-31, ИС-33, ПР-21 и ПР-41.
GO

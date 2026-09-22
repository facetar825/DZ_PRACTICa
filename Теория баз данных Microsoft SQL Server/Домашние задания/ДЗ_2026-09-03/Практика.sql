-- Переход от MySQL и PostgreSQL к MS SQL Server.
-- Мингазов Александр Рашидович, 9/2-РПО-24/1.
-- Запускать целиком в SSMS или sqlcmd.

USE master;
GO

IF DB_ID(N'CollegeDB') IS NULL
    EXEC(N'CREATE DATABASE CollegeDB;');
GO

USE CollegeDB;
GO

SET NOCOUNT ON;

IF SCHEMA_ID(N'college') IS NULL
    EXEC(N'CREATE SCHEMA college AUTHORIZATION dbo;');
GO

-- В условии опечатка: целое число — age, а name — Unicode-строка.
-- При повторном запуске существующая таблица и её данные сохраняются.
IF OBJECT_ID(N'college.students', N'U') IS NULL
BEGIN
    CREATE TABLE college.students
    (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        age INT NOT NULL
    );

    INSERT INTO college.students (name, age)
    VALUES
        (N'Иван', 18),
        (N'Мария', 17),
        (N'Алексей', 19),
        (N'Анна', 16),
        (N'Дмитрий', 20);
END;
GO

-- Задание 1. Вывести всех студентов.
SELECT id, name, age
FROM college.students
ORDER BY id;
GO

-- Задание 2. Вывести первых трёх студентов по идентификатору.
SELECT TOP (3) id, name, age
FROM college.students
ORDER BY id;
GO

-- Задание 3. Посчитать количество студентов через COUNT().
SELECT COUNT(*) AS StudentCount
FROM college.students;
GO

-- Задание 4. Сохранить количество в переменную T-SQL и вывести её.
DECLARE @studentCount INT;

SELECT @studentCount = COUNT(*)
FROM college.students;

SELECT @studentCount AS StudentCountFromVariable;
GO

-- Задание 5. Студенты строго старше 17 лет.
SELECT id, name, age
FROM college.students
WHERE age > 17
ORDER BY id;
GO

-- Задание 6. Текущие дата и время сервера.
SELECT GETDATE() AS CurrentDateTime;
GO

-- Задание 7. Список схем текущей базы данных.
SELECT *
FROM sys.schemas
ORDER BY name;
GO

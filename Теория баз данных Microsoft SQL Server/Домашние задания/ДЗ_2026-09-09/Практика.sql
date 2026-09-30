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

IF OBJECT_ID(N'college.students', N'U') IS NULL
BEGIN
    CREATE TABLE college.students
    (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        age INT NOT NULL,
        average_grade DECIMAL(4,2) NULL
    );
END;
GO

IF COL_LENGTH(N'college.students', N'average_grade') IS NULL
    ALTER TABLE college.students ADD average_grade DECIMAL(4,2) NULL;
GO

DECLARE @examples TABLE
(
    name NVARCHAR(100),
    age INT,
    average_grade DECIMAL(4,2)
);

INSERT INTO @examples (name, age, average_grade)
VALUES
    (N'Иван', 18, 4.70),
    (N'Мария', 17, 4.20),
    (N'Алексей', 19, 3.60),
    (N'Анна', 16, 3.20),
    (N'Дмитрий', 20, 2.80);

INSERT INTO college.students (name, age, average_grade)
SELECT e.name, e.age, e.average_grade
FROM @examples AS e
WHERE NOT EXISTS
(
    SELECT 1
    FROM college.students AS s
    WHERE s.name = e.name
);

UPDATE s
SET average_grade = e.average_grade
FROM college.students AS s
JOIN @examples AS e ON e.name = s.name
WHERE s.average_grade IS NULL;
GO

PRINT N'Задание 1';

DECLARE @studentCount INT;

SELECT @studentCount = COUNT(*)
FROM college.students;

SELECT @studentCount AS StudentCount;
GO

PRINT N'Задание 2';

DECLARE @studentId INT = 1;
DECLARE @studentName NVARCHAR(100);

SELECT @studentName = name
FROM college.students
WHERE id = @studentId;

SELECT @studentName AS StudentName;
GO

PRINT N'Задание 3';

DECLARE @studentId INT = 1;
DECLARE @age INT;

SELECT @age = age
FROM college.students
WHERE id = @studentId;

IF @age IS NULL
    PRINT N'Возраст не найден';
ELSE IF @age >= 18
    PRINT N'Совершеннолетний';
ELSE
    PRINT N'Несовершеннолетний';
GO

PRINT N'Задание 4';

SELECT id, name, age, average_grade,
    CASE
        WHEN age IS NULL THEN N'Возраст не указан'
        WHEN age >= 18 THEN N'Совершеннолетний'
        ELSE N'Несовершеннолетний'
    END AS age_status
FROM college.students
ORDER BY id;
GO

PRINT N'Задание 5';

SELECT name, average_grade,
    CASE
        WHEN average_grade IS NULL THEN N'Оценка не указана'
        WHEN average_grade >= 4.5 THEN N'Отличник'
        WHEN average_grade >= 3.5 THEN N'Хорошист'
        WHEN average_grade >= 3.0 THEN N'Успевает'
        ELSE N'Есть задолженности'
    END AS result
FROM college.students
ORDER BY id;
GO

PRINT N'Задание 6';

DECLARE @price DECIMAL(10,2) = 1500;
DECLARE @discount DECIMAL(5,2);

IF @price >= 1000
    SET @discount = 10;
ELSE
    SET @discount = 5;

SELECT @price AS [Цена],
    @discount AS [Скидка, %],
    CAST(@price - @price * @discount / 100 AS DECIMAL(10,2)) AS [Итоговая цена];
GO

PRINT N'Задание 7';

SELECT id, name, age,
    CASE
        WHEN age IS NULL THEN N'Возраст не указан'
        WHEN age < 18 THEN N'Младше 18'
        WHEN age < 20 THEN N'18–19 лет'
        ELSE N'20+'
    END AS age_group
FROM college.students
ORDER BY id;
GO

PRINT N'Задание 8';

DECLARE @studentId INT = 1;
DECLARE @studentName NVARCHAR(100);
DECLARE @age INT;
DECLARE @averageGrade DECIMAL(4,2);

SELECT @studentName = name,
    @age = age,
    @averageGrade = average_grade
FROM college.students
WHERE id = @studentId;

IF @studentName IS NULL
    PRINT N'Студент не найден';
ELSE
    SELECT @studentId AS id,
        @studentName AS name,
        @age AS age,
        @averageGrade AS average_grade,
        CASE
            WHEN @age IS NULL THEN N'Возраст не указан'
            WHEN @age < 18 THEN N'Младше 18'
            WHEN @age < 20 THEN N'18–19 лет'
            ELSE N'20+'
        END AS age_group,
        CASE
            WHEN @averageGrade IS NULL THEN N'Оценка не указана'
            WHEN @averageGrade >= 4.5 THEN N'Отличник'
            WHEN @averageGrade >= 3.5 THEN N'Хорошист'
            WHEN @averageGrade >= 3.0 THEN N'Успевает'
            ELSE N'Есть задолженности'
        END AS result;
GO

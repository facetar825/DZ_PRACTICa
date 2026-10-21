-- Практическая работа №7. Пользовательские функции в MS SQL Server.
-- Мингазов Ахнаф. Выполнять целиком в SSMS или sqlcmd на учебной CollegeDB.
USE CollegeDB;
GO
SET NOCOUNT ON;
GO

-- Подготовка: таблицы из предоставленного ранее CollegeDB_dump.sql.
SELECT * FROM college.groups;
SELECT * FROM college.students;
SELECT * FROM college.grades;
GO

-- Задание 1. Scalar-функция статуса (включая границы диапазонов).
CREATE OR ALTER FUNCTION college.GetStudentStatus(@average_grade decimal(10,4))
RETURNS nvarchar(100)
AS
BEGIN
    RETURN CASE
        WHEN @average_grade IS NULL THEN N'Нет данных'
        WHEN @average_grade < 0 OR @average_grade > 5 THEN N'Некорректный балл'
        WHEN @average_grade >= 4.5 THEN N'Отличник'
        WHEN @average_grade >= 3.5 THEN N'Хорошист'
        ELSE N'Требуется дополнительная подготовка'
    END;
END;
GO
SELECT name, average_grade, college.GetStudentStatus(average_grade) AS status
FROM college.students ORDER BY id;
SELECT college.GetStudentStatus(5.0) AS status_5,
       college.GetStudentStatus(4.2) AS status_4_2,
       college.GetStudentStatus(3.1) AS status_3_1;
GO

-- Задание 2. Итоговая стоимость, округлённая до копеек.
-- Неверная цена/процент и NULL возвращают NULL (THROW в UDF не используется).
CREATE OR ALTER FUNCTION college.CalculateDiscount
(
    @price decimal(12,2),
    @discount_percent decimal(5,2)
)
RETURNS decimal(12,2)
AS
BEGIN
    IF @price IS NULL OR @discount_percent IS NULL
       OR @price < 0 OR @discount_percent < 0 OR @discount_percent > 100
        RETURN NULL;
    RETURN CAST(ROUND(@price * (1 - @discount_percent / 100.0), 2) AS decimal(12,2));
END;
GO
SELECT college.CalculateDiscount(10000, 10) AS expected_9000,
       college.CalculateDiscount(25000, 15) AS expected_21250;
SELECT name, average_grade, college.CalculateDiscount(10000, 10) AS discounted_price
FROM college.students ORDER BY id;
GO

-- Задание 3. Использование scalar-функции и JOIN в аналитическом запросе.
SELECT s.name, g.name AS group_name, s.average_grade,
       college.GetStudentStatus(s.average_grade) AS status
FROM college.students AS s
JOIN college.groups AS g ON g.id = s.group_id
ORDER BY g.name, s.name;
-- Дополнительно: функция в WHERE.
SELECT id, name, average_grade
FROM college.students
WHERE college.GetStudentStatus(average_grade) = N'Отличник'
ORDER BY id;
GO

-- Задание 4. Inline TVF: один SELECT без промежуточной табличной переменной.
CREATE OR ALTER FUNCTION college.GetStudentsByGroup(@group_id int)
RETURNS TABLE
AS
RETURN
(
    SELECT id, name, age, average_grade, group_id
    FROM college.students
    WHERE group_id = @group_id
);
GO
SELECT * FROM college.GetStudentsByGroup(1) ORDER BY id;
SELECT * FROM college.GetStudentsByGroup(2) ORDER BY id;
SELECT * FROM college.GetStudentsByGroup(3) ORDER BY id;
SELECT * FROM college.GetStudentsByGroup(-1); -- пустой результат
GO

-- Задание 5. TVF в FROM совместно с JOIN.
SELECT s.name, g.name AS group_name, s.average_grade
FROM college.GetStudentsByGroup(1) AS s
JOIN college.groups AS g ON g.id = s.group_id
ORDER BY s.id;
GO

-- Задание 6. Возрастная категория.
CREATE OR ALTER FUNCTION college.GetAgeCategory(@age int)
RETURNS nvarchar(30)
AS
BEGIN
    RETURN CASE
        WHEN @age IS NULL THEN N'Нет данных'
        WHEN @age < 0 THEN N'Некорректный возраст'
        WHEN @age < 18 THEN N'Несовершеннолетний'
        WHEN @age <= 20 THEN N'Студент'
        ELSE N'Взрослый'
    END;
END;
GO
SELECT college.GetAgeCategory(17) AS age_17,
       college.GetAgeCategory(19) AS age_19,
       college.GetAgeCategory(25) AS age_25;
SELECT name, age, college.GetAgeCategory(age) AS age_category
FROM college.students ORDER BY id;
GO

-- Автоматические проверки границ и контрактов всех четырёх функций.
IF EXISTS
(
    SELECT 1
    FROM (VALUES
        (0.0, N'Требуется дополнительная подготовка'),
        (3.49, N'Требуется дополнительная подготовка'),
        (3.5, N'Хорошист'), (4.49, N'Хорошист'),
        (4.5, N'Отличник'), (5.0, N'Отличник'),
        (6.0, N'Некорректный балл')
    ) AS t(grade, expected)
    WHERE college.GetStudentStatus(t.grade) <> t.expected
) THROW 51071, N'Ошибка GetStudentStatus на границе диапазона.', 1;

IF college.CalculateDiscount(10000, 10) <> 9000
   OR college.CalculateDiscount(25000, 15) <> 21250
   OR college.CalculateDiscount(100, 0) <> 100
   OR college.CalculateDiscount(100, 100) <> 0
   OR college.CalculateDiscount(99.99, 15) <> 84.99
   OR college.CalculateDiscount(100, 101) IS NOT NULL
    THROW 51072, N'Ошибка CalculateDiscount.', 1;

IF EXISTS
(
    SELECT 1 FROM (VALUES
        (17, N'Несовершеннолетний'), (18, N'Студент'),
        (20, N'Студент'), (21, N'Взрослый')
    ) AS t(age, expected)
    WHERE college.GetAgeCategory(t.age) <> t.expected
) THROW 51073, N'Ошибка GetAgeCategory на границе диапазона.', 1;

IF EXISTS (SELECT * FROM college.GetStudentsByGroup(1) EXCEPT
           SELECT id, name, age, average_grade, group_id FROM college.students WHERE group_id = 1)
   OR EXISTS (SELECT id, name, age, average_grade, group_id FROM college.students WHERE group_id = 1
              EXCEPT SELECT * FROM college.GetStudentsByGroup(1))
   OR EXISTS (SELECT * FROM college.GetStudentsByGroup(-1))
    THROW 51074, N'Ошибка GetStudentsByGroup.', 1;
PRINT N'ПР №7: проверки четырёх функций пройдены.';
GO

-- Итоговое задание: статус и возрастная категория получены через функции.
SELECT s.name AS student_name, g.name AS group_name, s.age, s.average_grade,
       college.GetStudentStatus(s.average_grade) AS study_status,
       college.GetAgeCategory(s.age) AS age_category
FROM college.students AS s
JOIN college.groups AS g ON g.id = s.group_id
ORDER BY g.name, s.name;
GO

/*
    Лабораторная работа. Комплексная работа с MS SQL Server
    Студент: Мингазов Ахнаф
    Выполнять целиком в SSMS в базе CollegeDB (SQL Server 2016 SP1+).
    Нужны готовые college.groups, college.students, college.grades.
    Если базы нет, сначала выполните 00_Учебная_база.sql.
    Рейтинг строится по students.average_grade; среднее по grades
    вычисляется отдельно в задании 1. Это разные показатели.
*/
USE CollegeDB;
GO

-- Задание 1. Аналитический запрос
-- LEFT JOIN сохраняет студентов без оценок; COUNT(gr.id) даёт для них 0.
-- AVG игнорирует NULL, поэтому отсутствие оценок не превращается в ноль.
SELECT s.name AS student_name,
       g.name AS group_name,
       s.average_grade,
       COUNT(gr.id) AS grades_count,
       AVG(CAST(gr.grade AS DECIMAL(10, 4))) AS average_from_grades
FROM college.students AS s
LEFT JOIN college.groups AS g ON g.id = s.group_id
LEFT JOIN college.grades AS gr ON gr.student_id = s.id
GROUP BY s.id, s.name, g.name, s.average_grade
ORDER BY s.name, s.id;
GO

-- Задание 2. CTE и общий рейтинг
-- RANK присваивает равные места одинаковым баллам и оставляет пропуски.
;WITH StudentStatistics AS
(
    SELECT id, name, group_id, average_grade
    FROM college.students
)
SELECT name, average_grade,
       RANK() OVER (ORDER BY average_grade DESC) AS rating
FROM StudentStatistics
ORDER BY rating, name, id;
GO

-- Задание 3. Рейтинг внутри группы
;WITH StudentStatistics AS
(
    SELECT id, name, group_id, average_grade
    FROM college.students
)
SELECT s.name AS student_name,
       g.name AS group_name,
       s.average_grade,
       RANK() OVER
           (PARTITION BY s.group_id ORDER BY s.average_grade DESC) AS group_rating
FROM StudentStatistics AS s
LEFT JOIN college.groups AS g ON g.id = s.group_id
ORDER BY g.name, group_rating, s.name, s.id;
GO

-- Задание 4. Представление
CREATE OR ALTER VIEW college.StudentRating
AS
    SELECT s.id, s.name, g.name AS group_name, s.average_grade,
           RANK() OVER
               (PARTITION BY s.group_id ORDER BY s.average_grade DESC) AS group_rating
    FROM college.students AS s
    LEFT JOIN college.groups AS g ON g.id = s.group_id;
GO

SELECT * FROM college.StudentRating
ORDER BY group_name, group_rating, id;

SELECT * FROM college.StudentRating
WHERE group_name = N'ИС-31'
ORDER BY group_rating, id;
GO

-- Задание 5. Хранимая процедура
CREATE OR ALTER PROCEDURE college.GetStudentsByMinGrade
    @min_grade DECIMAL(10, 4)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT id, name, age, average_grade, group_id
    FROM college.students
    WHERE average_grade >= @min_grade
    ORDER BY average_grade DESC, id;
END;
GO

EXEC college.GetStudentsByMinGrade @min_grade = 4.5;
EXEC college.GetStudentsByMinGrade @min_grade = 3.5;
GO

-- Задание 6. Скалярная пользовательская функция
CREATE OR ALTER FUNCTION college.GetStudentStatus
(
    @average_grade DECIMAL(10, 4)
)
RETURNS NVARCHAR(100)
AS
BEGIN
    RETURN CASE
        WHEN @average_grade IS NULL THEN N'Нет данных'
        WHEN @average_grade >= 4.5 THEN N'Отличник'
        WHEN @average_grade >= 3.5 THEN N'Хорошист'
        ELSE N'Требуется дополнительная подготовка'
    END;
END;
GO

SELECT name, average_grade,
       college.GetStudentStatus(average_grade) AS status
FROM college.students
ORDER BY id;

-- Проверка порогов: 3.49 / 3.50 / 4.49 / 4.50 и NULL.
SELECT v.average_grade,
       college.GetStudentStatus(v.average_grade) AS status
FROM (VALUES (CAST(3.49 AS DECIMAL(10, 4))), (3.50), (4.49), (4.50), (NULL))
    AS v(average_grade);
GO

-- Задание 7. Inline Table-Valued Function
CREATE OR ALTER FUNCTION college.GetStudentsByGroup
(
    @group_id INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT id, name, age, average_grade
    FROM college.students
    WHERE group_id = @group_id
);
GO

SELECT * FROM college.GetStudentsByGroup(1) ORDER BY id;
SELECT * FROM college.GetStudentsByGroup(1)
WHERE average_grade >= 4.5
ORDER BY average_grade DESC, id;
GO

-- Задание 8. Таблица и триггер аудита
IF OBJECT_ID(N'college.student_changes', N'U') IS NULL
BEGIN
    CREATE TABLE college.student_changes
    (
        id INT IDENTITY(1, 1) PRIMARY KEY,
        student_id INT NOT NULL,
        old_average_grade DECIMAL(10, 4) NULL,
        new_average_grade DECIMAL(10, 4) NULL,
        change_date DATETIME2(3) NOT NULL
            CONSTRAINT DF_student_changes_change_date DEFAULT SYSDATETIME()
    );
END;
GO

CREATE OR ALTER TRIGGER college.trg_Students_AverageGradeAudit
ON college.students
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(average_grade) RETURN;

    -- Множества inserted/deleted содержат ВСЕ строки одного UPDATE.
    -- Сравнение исключает запись аудита при присваивании прежнего балла.
    INSERT INTO college.student_changes
        (student_id, old_average_grade, new_average_grade, change_date)
    SELECT i.id, d.average_grade, i.average_grade, SYSDATETIME()
    FROM inserted AS i
    INNER JOIN deleted AS d ON d.id = i.id
    WHERE i.average_grade <> d.average_grade
       OR (i.average_grade IS NULL AND d.average_grade IS NOT NULL)
       OR (i.average_grade IS NOT NULL AND d.average_grade IS NULL);
END;
GO

-- Проверка триггера: изменения и аудит видны внутри транзакции.
-- Затем ROLLBACK возвращает исходные баллы и удаляет тестовые записи.
-- Значения IDENTITY могут иметь пропуски после отката, это нормально.
-- Для проверки +0.1 у тестовых студентов должен быть запас до верхней границы.
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE college.students
    SET average_grade = average_grade + 0.1
    WHERE id = 1;

    SELECT * FROM college.student_changes ORDER BY id;

    UPDATE college.students
    SET average_grade = average_grade + 0.1
    WHERE group_id = 1;

    SELECT * FROM college.student_changes ORDER BY id;

    -- Присваивание того же значения не должно добавлять записи.
    DECLARE @before_count INT = (SELECT COUNT(*) FROM college.student_changes);
    UPDATE college.students
    SET average_grade = average_grade
    WHERE group_id = 1;

    IF (SELECT COUNT(*) FROM college.student_changes) <> @before_count
        THROW 50001, N'Аудит ошибочно записал неизменившиеся значения.', 1;

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Итоговое задание. Представление уже содержит оконный рейтинг.
-- Оценки агрегируем отдельно, чтобы JOIN не дублировал строки студентов.
;WITH GradeCounts AS
(
    SELECT student_id, COUNT(*) AS grades_count
    FROM college.grades
    GROUP BY student_id
)
SELECT r.name AS student_name,
       r.group_name,
       r.average_grade,
       college.GetStudentStatus(r.average_grade) AS status,
       r.group_rating,
       COALESCE(gc.grades_count, 0) AS grades_count
FROM college.StudentRating AS r
LEFT JOIN GradeCounts AS gc ON gc.student_id = r.id
ORDER BY r.group_name, r.group_rating, r.id;
GO

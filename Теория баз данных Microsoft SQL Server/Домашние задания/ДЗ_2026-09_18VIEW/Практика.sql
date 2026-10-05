-- Учебная работа. Выполнять в SSMS целиком, включая разделители GO.
USE [CollegeDB_HW_20261005];
GO
SET NOCOUNT ON;
GO

-- Самостоятельная работа: все студенты, в том числе без оценок.
CREATE OR ALTER VIEW college.student_statistics
AS
SELECT s.id, s.name, s.group_id, g.name AS group_name,
       COUNT(gr.id) AS grade_count,
       AVG(CAST(gr.grade AS DECIMAL(10,4))) AS average_grade,
       MIN(gr.grade) AS min_grade, MAX(gr.grade) AS max_grade
FROM college.students AS s
JOIN college.groups AS g ON g.id = s.group_id
LEFT JOIN college.grades AS gr ON gr.student_id = s.id
GROUP BY s.id, s.name, s.group_id, g.name;
GO
-- 1. Все записи.
SELECT * FROM college.student_statistics ORDER BY id;
-- 2. Средний балл не ниже 4.5.
SELECT * FROM college.student_statistics WHERE average_grade >= 4.5 ORDER BY id;
-- 3. Сортировка по среднему баллу.
SELECT * FROM college.student_statistics ORDER BY average_grade DESC, id;
-- 4. Студенты одной группы.
SELECT * FROM college.student_statistics WHERE group_id = 1 ORDER BY id;
GO
-- 5. Новая оценка сразу видна во VIEW. Откат оставляет исходные данные.
BEGIN TRANSACTION;
SELECT N'До добавления' AS stage, * FROM college.student_statistics WHERE id = 1;
INSERT INTO college.grades (student_id, subject, grade, grade_date)
VALUES (1, N'Базы данных', 5, '20261005');
SELECT N'После добавления' AS stage, * FROM college.student_statistics WHERE id = 1;
ROLLBACK TRANSACTION;
GO

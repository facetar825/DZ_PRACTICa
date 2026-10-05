-- Учебная работа. Выполнять в SSMS целиком, включая разделители GO.
USE [CollegeDB_HW_20261005];
GO
SET NOCOUNT ON;
GO

-- Обычный CTE: студенты выше общего среднего.
;WITH AverageGrade AS (
    SELECT AVG(average_grade) AS average_grade FROM college.students
)
SELECT s.id, s.name, s.average_grade
FROM college.students AS s CROSS JOIN AverageGrade AS a
WHERE s.average_grade > a.average_grade ORDER BY s.id;
-- Несколько CTE, агрегация, JOIN и зависимость второго CTE от первого.
;WITH GroupStats AS (
    SELECT group_id, COUNT(*) AS student_count, AVG(average_grade) AS group_average
    FROM college.students GROUP BY group_id
), StrongGroups AS (
    SELECT * FROM GroupStats WHERE group_average >= 4.5
)
SELECT g.name, sg.student_count, sg.group_average
FROM StrongGroups AS sg JOIN college.groups AS g ON g.id = sg.group_id ORDER BY g.id;
-- Домашнее задание: числа от 1 до 20.
;WITH Numbers AS (
    SELECT 1 AS number -- anchor member
    UNION ALL
    SELECT number + 1 FROM Numbers WHERE number < 20 -- recursive member
)
SELECT number FROM Numbers ORDER BY number OPTION (MAXRECURSION 20);
GO
-- Пример обхода дерева подразделений; тестовые данные существуют только в этом пакете.
DECLARE @departments TABLE (id INT PRIMARY KEY, name NVARCHAR(100), parent_id INT);
INSERT INTO @departments VALUES
(1,N'Колледж',NULL), (2,N'ИТ-направление',1), (3,N'Экономика',1),
(4,N'ИС-21',2), (5,N'ИС-22',2), (6,N'Подгруппа',4);
;WITH DepartmentTree AS (
    SELECT id, name, parent_id, 0 AS depth,
           CAST('/'+CAST(id AS VARCHAR(11))+'/' AS VARCHAR(4000)) AS visited
    FROM @departments WHERE id = 2
    UNION ALL
    SELECT d.id, d.name, d.parent_id, t.depth + 1,
           CAST(t.visited+CAST(d.id AS VARCHAR(11))+'/' AS VARCHAR(4000))
    FROM @departments AS d JOIN DepartmentTree AS t ON d.parent_id = t.id
    WHERE CHARINDEX('/'+CAST(d.id AS VARCHAR(11))+'/', t.visited) = 0
)
SELECT id, name, parent_id, depth FROM DepartmentTree
ORDER BY depth, id OPTION (MAXRECURSION 100);
GO

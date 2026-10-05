-- Учебная работа. Выполнять в SSMS целиком, включая разделители GO.
USE [CollegeDB_HW_20261005];
GO
SET NOCOUNT ON;
GO

-- Самостоятельная и домашняя работы: полный рейтинг, среднее группы и отклонение.
SELECT s.id, s.name, s.group_id, g.name AS group_name, s.average_grade,
       ROW_NUMBER() OVER (PARTITION BY s.group_id ORDER BY s.average_grade DESC, s.id) AS student_number,
       RANK() OVER (PARTITION BY s.group_id ORDER BY s.average_grade DESC) AS student_rank,
       AVG(s.average_grade) OVER (PARTITION BY s.group_id) AS group_average,
       s.average_grade - AVG(s.average_grade) OVER (PARTITION BY s.group_id) AS difference_from_average
FROM college.students AS s JOIN college.groups AS g ON g.id = s.group_id
ORDER BY s.group_id, student_number;
-- Три лучших студента каждой группы. AVG вычисляется ДО фильтрации топ-3.
;WITH RankedStudents AS (
SELECT s.id, s.name, s.group_id, g.name AS group_name, s.average_grade,
       ROW_NUMBER() OVER (PARTITION BY s.group_id ORDER BY s.average_grade DESC, s.id) AS student_number,
       RANK() OVER (PARTITION BY s.group_id ORDER BY s.average_grade DESC) AS student_rank,
       AVG(s.average_grade) OVER (PARTITION BY s.group_id) AS group_average,
       s.average_grade - AVG(s.average_grade) OVER (PARTITION BY s.group_id) AS difference_from_average
FROM college.students AS s JOIN college.groups AS g ON g.id = s.group_id
)
SELECT * FROM RankedStudents WHERE student_number <= 3
ORDER BY group_id, student_number;
GO
-- Одинаковые баллы: ROW_NUMBER=1,2,3,4; RANK=1,2,2,4; DENSE_RANK=1,2,2,3.
;WITH Sample AS (
    SELECT * FROM (VALUES (1,5.0),(2,4.8),(3,4.8),(4,4.2)) AS v(id,grade)
)
SELECT id, grade,
    ROW_NUMBER() OVER (ORDER BY grade DESC, id) AS row_number,
    RANK() OVER (ORDER BY grade DESC) AS rank_number,
    DENSE_RANK() OVER (ORDER BY grade DESC) AS dense_rank_number
FROM Sample ORDER BY row_number;
-- LAG/LEAD и накопительная сумма на истории реальных оценок учебной базы.
SELECT student_id, grade_date, id, grade,
    LAG(grade) OVER (PARTITION BY student_id ORDER BY grade_date,id) AS previous_grade,
    LEAD(grade) OVER (PARTITION BY student_id ORDER BY grade_date,id) AS next_grade,
    grade - LAG(grade) OVER (PARTITION BY student_id ORDER BY grade_date,id) AS difference,
    SUM(grade) OVER (PARTITION BY student_id ORDER BY grade_date,id
                    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_sum
FROM college.grades ORDER BY student_id, grade_date, id;
GO

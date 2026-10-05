-- Учебная работа. Выполнять в SSMS целиком, включая разделители GO.
USE [CollegeDB_HW_20261005];
GO
SET NOCOUNT ON;
GO

-- В PDF нет отдельного практического задания. Закрепление всех видов подзапросов.
-- 1. Скалярный подзапрос в WHERE: выше среднего по колледжу.
SELECT id, name, average_grade FROM college.students
WHERE average_grade > (SELECT AVG(average_grade) FROM college.students) ORDER BY id;
-- 2. Подзапрос в SELECT: средний балл колледжа и отклонение.
SELECT id, name, average_grade,
    (SELECT AVG(average_grade) FROM college.students) AS college_average,
    average_grade - (SELECT AVG(average_grade) FROM college.students) AS difference
FROM college.students ORDER BY id;
-- 3. IN: студенты групп третьего курса.
SELECT id, name, group_id FROM college.students
WHERE group_id IN (SELECT id FROM college.groups WHERE course = 3) ORDER BY id;
-- 4. EXISTS: студенты, у которых есть оценки.
SELECT s.id, s.name FROM college.students AS s
WHERE EXISTS (SELECT 1 FROM college.grades AS gr WHERE gr.student_id = s.id) ORDER BY s.id;
-- 5. NOT EXISTS: студенты без оценок.
SELECT s.id, s.name FROM college.students AS s
WHERE NOT EXISTS (SELECT 1 FROM college.grades AS gr WHERE gr.student_id = s.id) ORDER BY s.id;
-- 6. Корреляция: выше среднего именно своей группы.
SELECT s.id, s.name, s.group_id, s.average_grade FROM college.students AS s
WHERE s.average_grade > (SELECT AVG(s2.average_grade)
                        FROM college.students AS s2 WHERE s2.group_id = s.group_id)
ORDER BY s.group_id, s.id;
-- 7. Производная таблица в FROM.
SELECT stats.group_id, g.name AS group_name, stats.student_count, stats.group_average
FROM (SELECT group_id, COUNT(*) AS student_count, AVG(average_grade) AS group_average
      FROM college.students GROUP BY group_id) AS stats
JOIN college.groups AS g ON g.id = stats.group_id ORDER BY stats.group_id;
-- 8. Все студенты с максимальным баллом, включая равные результаты.
SELECT id, name, average_grade FROM college.students
WHERE average_grade = (SELECT MAX(average_grade) FROM college.students) ORDER BY id;
GO

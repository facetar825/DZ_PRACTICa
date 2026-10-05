USE [CollegeDB_HW_20261005];
GO
SET NOCOUNT ON;
-- Проверки результата, а не только успешного создания объектов.
IF (SELECT COUNT(*) FROM college.student_statistics) <> 12
    THROW 51001, N'VIEW потерял студентов.', 1;
IF NOT EXISTS (SELECT 1 FROM college.student_statistics
               WHERE id = 12 AND grade_count = 0 AND average_grade IS NULL
                 AND min_grade IS NULL AND max_grade IS NULL)
    THROW 51002, N'Неверная обработка студента без оценок.', 1;
IF NOT EXISTS (SELECT 1 FROM college.student_statistics
               WHERE id = 1 AND grade_count = 3
                 AND ABS(average_grade - 4.666666) < 0.00001)
    THROW 51003, N'Неверное дробное среднее.', 1;

BEGIN TRANSACTION;
INSERT INTO college.grades (student_id, subject, grade, grade_date)
VALUES (1, N'Тест VIEW', 5, '20261005');
IF NOT EXISTS (SELECT 1 FROM college.student_statistics
               WHERE id = 1 AND grade_count = 4 AND average_grade = 4.75)
BEGIN
    ROLLBACK;
    THROW 51004, N'VIEW не отражает новую оценку.', 1;
END;
ROLLBACK;

DECLARE @stats TABLE (name NVARCHAR(100), group_name NVARCHAR(50), grade_count INT,
                     average_grade DECIMAL(38,6), min_grade INT, max_grade INT);
INSERT INTO @stats EXEC college.GetStudentStatistics @student_id = 1;
IF NOT EXISTS (SELECT 1 FROM @stats WHERE name = N'Алексей Иванов' AND grade_count = 3
               AND min_grade = 4 AND max_grade = 5)
    THROW 51005, N'Процедура вернула неверную статистику.', 1;
DECLARE @caught BIT = 0;
BEGIN TRY
    EXEC college.GetStudentStatistics @student_id = -1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 50001 THROW;
    SET @caught = 1;
END CATCH;
IF @caught = 0 THROW 51006, N'Процедура не отклонила отсутствующего студента.', 1;
DECLARE @count INT, @status INT;
EXEC @status = college.GetStudentCount @group_id = 1, @student_count = @count OUTPUT;
IF @count <> 5 OR @status <> 0 THROW 51007, N'Неверные OUTPUT/RETURN.', 1;

IF EXISTS (
    SELECT 1 FROM (VALUES (CAST(NULL AS DECIMAL(4,2)),0), (3.99,0), (4.00,3000),
                         (4.49,3000), (4.50,4000), (4.79,4000), (4.80,5000),
                         (5.00,5000), (5.01,0)) AS v(grade,expected)
    WHERE college.GetScholarship(v.grade) <> v.expected)
    THROW 51008, N'Неверная граница стипендии.', 1;
IF (SELECT COUNT(*) FROM college.GetStudentsByMinGrade(4.5)) <> 7
    THROW 51009, N'Неверная выборка TVF.', 1;
IF EXISTS (SELECT 1 FROM college.GetStudentsByMinGrade(NULL))
    THROW 51010, N'TVF с NULL должна вернуть пустой набор.', 1;

BEGIN TRANSACTION;
DECLARE @old_count INT = (SELECT COUNT(*) FROM college.student_changes);
UPDATE college.students SET average_grade = average_grade + 0.1 WHERE group_id = 1;
IF (SELECT COUNT(*) FROM college.student_changes) <> @old_count + 5
BEGIN
    ROLLBACK;
    THROW 51011, N'Аудит не обработал многострочный UPDATE.', 1;
END;
UPDATE college.students SET name = name WHERE group_id = 1;
IF (SELECT COUNT(*) FROM college.student_changes) <> @old_count + 5
BEGIN
    ROLLBACK;
    THROW 51012, N'Аудит записал неизменённый балл.', 1;
END;
UPDATE college.students SET average_grade = 4.00 WHERE id = 12;
UPDATE college.students SET average_grade = NULL WHERE id = 12;
IF (SELECT COUNT(*) FROM college.student_changes WHERE student_id = 12) <> 2
BEGIN
    ROLLBACK;
    THROW 51013, N'Аудит не учитывает переходы NULL.', 1;
END;
DECLARE @audit_count INT = (SELECT COUNT(*) FROM college.student_audit);
INSERT INTO college.students (name, age, average_grade, group_id)
VALUES (N'Проверка INSERT 1',18,4.00,1), (N'Проверка INSERT 2',18,4.00,1);
IF (SELECT COUNT(*) FROM college.student_audit) <> @audit_count + 2
BEGIN
    ROLLBACK;
    THROW 51014, N'Аудит не обработал многострочный INSERT.', 1;
END;
ROLLBACK;

SET @caught = 0;
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE college.students SET average_grade = 5.5 WHERE group_id = 1;
    ROLLBACK;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    IF ERROR_NUMBER() <> 50002 THROW;
    SET @caught = 1;
END CATCH;
IF @caught = 0 THROW 51015, N'Триггер не отклонил недопустимый UPDATE.', 1;
SET @caught = 0;
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO college.students (name, age, average_grade, group_id)
    VALUES (N'Некорректный INSERT',18,5.5,1);
    ROLLBACK;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK;
    IF ERROR_NUMBER() <> 50002 THROW;
    SET @caught = 1;
END CATCH;
IF @caught = 0 THROW 51016, N'Триггер не отклонил недопустимый INSERT.', 1;

DECLARE @numbers TABLE (number INT);
;WITH Numbers AS (
    SELECT 1 AS number
    UNION ALL SELECT number + 1 FROM Numbers WHERE number < 20
)
INSERT INTO @numbers SELECT number FROM Numbers OPTION (MAXRECURSION 20);
IF (SELECT COUNT(*) FROM @numbers) <> 20
   OR (SELECT SUM(number) FROM @numbers) <> 210
   OR (SELECT MIN(number) FROM @numbers) <> 1
   OR (SELECT MAX(number) FROM @numbers) <> 20
    THROW 51017, N'Неверная последовательность CTE.', 1;

DECLARE @top TABLE (id INT, group_id INT, student_number BIGINT, group_average DECIMAL(38,6));
;WITH Ranked AS (
    SELECT id, group_id,
        ROW_NUMBER() OVER (PARTITION BY group_id ORDER BY average_grade DESC,id) AS student_number,
        AVG(average_grade) OVER (PARTITION BY group_id) AS group_average
    FROM college.students
)
INSERT INTO @top SELECT id, group_id, student_number, group_average
FROM Ranked WHERE student_number <= 3;
IF (SELECT COUNT(*) FROM @top) <> 9
   OR EXISTS (SELECT group_id FROM @top GROUP BY group_id HAVING COUNT(*) <> 3)
    THROW 51018, N'Неверный топ-3.', 1;
IF NOT EXISTS (SELECT 1 FROM @top WHERE group_id=1 AND group_average=4.6)
    THROW 51019, N'Среднее группы посчитано после отбора топ-3.', 1;
DECLARE @ranks TABLE (id INT, rn BIGINT, rnk BIGINT, dense BIGINT);
INSERT INTO @ranks
SELECT id, ROW_NUMBER() OVER (ORDER BY grade DESC,id),
           RANK() OVER (ORDER BY grade DESC), DENSE_RANK() OVER (ORDER BY grade DESC)
FROM (VALUES (1,5.0),(2,4.8),(3,4.8),(4,4.2)) AS v(id,grade);
IF EXISTS (
    SELECT 1 FROM @ranks AS r
    JOIN (VALUES (1,1,1,1),(2,2,2,2),(3,3,2,2),(4,4,4,3)) AS e(id,rn,rnk,dense)
      ON e.id=r.id WHERE r.rn<>e.rn OR r.rnk<>e.rnk OR r.dense<>e.dense)
    THROW 51020, N'Неверная обработка одинаковых баллов.', 1;
IF (SELECT COUNT(*) FROM college.students) <> 12
   OR (SELECT COUNT(*) FROM college.grades) <> 30
   OR EXISTS (SELECT 1 FROM college.student_changes)
   OR EXISTS (SELECT 1 FROM college.student_audit)
    THROW 51021, N'После демонстраций остались изменения.', 1;
SELECT N'Все проверки пройдены' AS result;
GO

-- Учебная работа. Выполнять в SSMS целиком, включая разделители GO.
USE [CollegeDB_HW_20261005];
GO
SET NOCOUNT ON;
GO

CREATE OR ALTER FUNCTION college.GetScholarship (@average_grade DECIMAL(4,2))
RETURNS INT
AS
BEGIN
    -- NULL и баллы вне допустимого диапазона не дают стипендию.
    RETURN CASE
        WHEN @average_grade IS NULL OR @average_grade < 0 OR @average_grade > 5 THEN 0
        WHEN @average_grade >= 4.8 THEN 5000
        WHEN @average_grade >= 4.5 THEN 4000
        WHEN @average_grade >= 4.0 THEN 3000
        ELSE 0 END;
END;
GO
SELECT name, average_grade, college.GetScholarship(average_grade) AS scholarship
FROM college.students ORDER BY id;
GO
CREATE OR ALTER FUNCTION college.GetStudentsByMinGrade (@min_grade DECIMAL(4,2))
RETURNS TABLE
AS
RETURN (
    SELECT s.id, s.name, s.group_id, g.name AS group_name, s.average_grade
    FROM college.students AS s JOIN college.groups AS g ON g.id = s.group_id
    WHERE s.average_grade >= @min_grade
);
GO
SELECT * FROM college.GetStudentsByMinGrade(4.5) ORDER BY average_grade DESC, id;
-- Проверка всех границ стипендии.
SELECT v.grade, college.GetScholarship(v.grade) AS scholarship
FROM (VALUES (CAST(NULL AS DECIMAL(4,2))), (3.99), (4.00), (4.49),
             (4.50), (4.79), (4.80), (5.00), (5.01)) AS v(grade);
GO
-- Учебный пример Multi-Statement TVF.
CREATE OR ALTER FUNCTION college.GetScholarshipReport (@group_id INT)
RETURNS @result TABLE (id INT, name NVARCHAR(100), scholarship INT)
AS
BEGIN
    INSERT INTO @result (id, name, scholarship)
    SELECT id, name, college.GetScholarship(average_grade)
    FROM college.students WHERE group_id = @group_id;
    RETURN;
END;
GO
SELECT * FROM college.GetScholarshipReport(1) ORDER BY id;
GO

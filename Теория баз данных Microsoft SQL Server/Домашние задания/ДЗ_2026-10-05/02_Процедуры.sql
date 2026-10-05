-- Учебная работа. Выполнять в SSMS целиком, включая разделители GO.
USE [CollegeDB_HW_20261005];
GO
SET NOCOUNT ON;
GO

CREATE OR ALTER PROCEDURE college.GetStudentStatistics @student_id INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM college.students WHERE id = @student_id)
            THROW 50001, N'Студент с указанным идентификатором не найден.', 1;
        SELECT s.name, g.name AS group_name, COUNT(gr.id) AS grade_count,
               AVG(CAST(gr.grade AS DECIMAL(10,4))) AS average_grade,
               MIN(gr.grade) AS min_grade, MAX(gr.grade) AS max_grade
        FROM college.students AS s
        JOIN college.groups AS g ON g.id = s.group_id
        LEFT JOIN college.grades AS gr ON gr.student_id = s.id
        WHERE s.id = @student_id
        GROUP BY s.id, s.name, g.name;
        RETURN 0;
    END TRY
    BEGIN CATCH
        THROW; -- Передаём исходную ошибку вызывающему коду.
    END CATCH;
END;
GO
EXEC college.GetStudentStatistics @student_id = 1;
EXEC college.GetStudentStatistics @student_id = 12; -- 0 оценок, AVG/MIN/MAX = NULL.
BEGIN TRY
    EXEC college.GetStudentStatistics @student_id = -1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 50001 THROW;
    SELECT ERROR_NUMBER() AS expected_error, ERROR_MESSAGE() AS message;
END CATCH;
GO
-- Дополнительный пример OUTPUT и RETURN.
CREATE OR ALTER PROCEDURE college.GetStudentCount
    @group_id INT = 1, @student_count INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT @student_count = COUNT(*) FROM college.students WHERE group_id = @group_id;
    RETURN 0;
END;
GO
DECLARE @count INT, @status INT;
EXEC @status = college.GetStudentCount @student_count = @count OUTPUT;
SELECT @count AS student_count, @status AS return_code;
GO

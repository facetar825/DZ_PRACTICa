-- Учебная работа. Выполнять в SSMS целиком, включая разделители GO.
USE [CollegeDB_HW_20261005];
GO
SET NOCOUNT ON;
GO

IF OBJECT_ID(N'college.student_changes', N'U') IS NULL
    CREATE TABLE college.student_changes (
        id INT IDENTITY PRIMARY KEY, student_id INT NOT NULL,
        old_average_grade DECIMAL(4,2) NULL,
        new_average_grade DECIMAL(4,2) NULL,
        change_date DATETIME2 NOT NULL
    );
IF OBJECT_ID(N'college.student_audit', N'U') IS NULL
    CREATE TABLE college.student_audit (
        id INT IDENTITY PRIMARY KEY, student_id INT NOT NULL,
        student_name NVARCHAR(100) NOT NULL,
        action_type NVARCHAR(20) NOT NULL, action_date DATETIME2 NOT NULL
    );
GO
CREATE OR ALTER TRIGGER college.trg_Students_GradeUpdate
ON college.students AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO college.student_changes
        (student_id, old_average_grade, new_average_grade, change_date)
    SELECT d.id, d.average_grade, i.average_grade, SYSDATETIME()
    FROM deleted AS d JOIN inserted AS i ON i.id = d.id
    WHERE d.average_grade <> i.average_grade
       OR (d.average_grade IS NULL AND i.average_grade IS NOT NULL)
       OR (d.average_grade IS NOT NULL AND i.average_grade IS NULL);
END;
GO
CREATE OR ALTER TRIGGER college.trg_Students_CheckGrade
ON college.students AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE average_grade > 5)
        THROW 50002, N'Средний балл не может быть больше 5.', 1;
END;
GO
CREATE OR ALTER TRIGGER college.trg_Students_AuditInsert
ON college.students AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO college.student_audit (student_id, student_name, action_type, action_date)
    SELECT id, name, N'INSERT', SYSDATETIME() FROM inserted;
END;
GO
BEGIN TRANSACTION;
UPDATE college.students SET average_grade = average_grade + 0.1 WHERE group_id = 1;
SELECT * FROM college.student_changes ORDER BY id;
-- Изменилось сразу 5 студентов, журнал содержит 5 новых строк.
INSERT INTO college.students (name, age, average_grade, group_id)
VALUES (N'Тестовый студент 1',18,4.00,1), (N'Тестовый студент 2',18,4.10,1);
SELECT * FROM college.student_audit ORDER BY id;
ROLLBACK TRANSACTION;
GO
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE college.students SET average_grade = 5.5 WHERE id = 1;
    ROLLBACK TRANSACTION;
    THROW 51001, N'Ошибка: недопустимый балл не был отклонён.', 1;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    IF ERROR_NUMBER() <> 50002 THROW;
    SELECT ERROR_NUMBER() AS expected_error, ERROR_MESSAGE() AS message;
END CATCH;
GO

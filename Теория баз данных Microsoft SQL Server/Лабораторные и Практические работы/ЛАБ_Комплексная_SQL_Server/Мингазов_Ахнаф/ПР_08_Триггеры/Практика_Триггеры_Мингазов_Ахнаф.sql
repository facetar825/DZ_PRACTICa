-- Практическая работа №8. Триггеры в MS SQL Server. Мингазов Ахнаф.
-- Учебная CollegeDB из CollegeDB_dump.sql. Запускать весь файл в SSMS/sqlcmd.
-- Данные проверок откатываются; определения объектов остаются в базе.
USE CollegeDB;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
SELECT * FROM college.students ORDER BY id;
GO

-- Задание 1. Совместимо с таблицей аудита прежней комплексной лабораторной.
IF OBJECT_ID(N'college.student_changes', N'U') IS NULL
BEGIN
    CREATE TABLE college.student_changes
    (
        id int IDENTITY(1,1) PRIMARY KEY,
        student_id int NOT NULL,
        old_average_grade decimal(10,4) NULL,
        new_average_grade decimal(10,4) NULL,
        change_date datetime2(3) NOT NULL DEFAULT SYSDATETIME()
    );
END;
GO

-- Задание 2. Исходный аудит только фактических изменений среднего балла.
CREATE OR ALTER TRIGGER college.trg_Students_AverageGradeAudit
ON college.students
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(average_grade) RETURN;
    INSERT INTO college.student_changes
        (student_id, old_average_grade, new_average_grade, change_date)
    SELECT i.id, d.average_grade, i.average_grade, SYSDATETIME()
    FROM inserted AS i
    JOIN deleted AS d ON d.id = i.id
    WHERE i.average_grade <> d.average_grade
       OR (i.average_grade IS NULL AND d.average_grade IS NOT NULL)
       OR (i.average_grade IS NOT NULL AND d.average_grade IS NULL);
END;
GO

-- Задание 3. Одна строка. Сначала устанавливаем известное начальное значение,
-- затем сравниваем прирост журнала; все тестовые изменения отменяем.
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM college.students WHERE id = 1)
        THROW 51080, N'Для примеров нужны студенты id=1,2,3 из учебного дампа.', 1;
    UPDATE college.students SET average_grade = 4.7 WHERE id = 1;
    DECLARE @before bigint = (SELECT COUNT_BIG(*) FROM college.student_changes);
    DECLARE @last int = ISNULL((SELECT MAX(id) FROM college.student_changes), 0);
    UPDATE college.students SET average_grade = 4.8 WHERE id = 1;
    IF (SELECT COUNT_BIG(*) FROM college.student_changes) <> @before + 1
        THROW 51081, N'Ожидалась одна запись аудита.', 1;
    SELECT * FROM college.student_changes WHERE id > @last ORDER BY id;
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Задание 4. UPDATE нескольких строк: один запуск триггера, запись для каждой.
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE college.students SET average_grade = 4.0 WHERE group_id = 1;
    DECLARE @expected int = (SELECT COUNT(*) FROM college.students WHERE group_id = 1);
    IF @expected < 2 THROW 51082, N'Для проверки нужны несколько студентов группы 1.', 1;
    DECLARE @before bigint = (SELECT COUNT_BIG(*) FROM college.student_changes);
    DECLARE @last int = ISNULL((SELECT MAX(id) FROM college.student_changes), 0);
    UPDATE college.students SET average_grade = average_grade + 0.1 WHERE group_id = 1;
    IF (SELECT COUNT_BIG(*) FROM college.student_changes) <> @before + @expected
        THROW 51083, N'Неверное количество записей многострочного аудита.', 1;
    SELECT * FROM college.student_changes WHERE id > @last ORDER BY student_id;
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Задание 5. Проверка всех строк inserted, а не одного произвольного значения.
CREATE OR ALTER TRIGGER college.trg_Students_ValidateGrade
ON college.students
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE average_grade < 0 OR average_grade > 5)
        THROW 51008, N'Средний балл должен находиться в диапазоне от 0 до 5.', 1;
END;
GO

-- Задание 6а. Корректный балл.
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM college.students WHERE id = 2)
        THROW 51080, N'В учебной базе отсутствует студент id=2.', 1;
    UPDATE college.students SET average_grade = 4.5 WHERE id = 2;
    IF NOT EXISTS (SELECT 1 FROM college.students WHERE id = 2 AND average_grade = 4.5)
        THROW 51084, N'Корректный балл не сохранён.', 1;
    SELECT * FROM college.students WHERE id = 2;
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Задание 6б. Некорректный балл: ожидаем именно нашу ошибку 51008.
DECLARE @original decimal(4,2) = (SELECT average_grade FROM college.students WHERE id = 2);
DECLARE @audit_before bigint = (SELECT COUNT_BIG(*) FROM college.student_changes);
DECLARE @rejected bit = 0;
BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE college.students SET average_grade = 6 WHERE id = 2;
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    IF ERROR_NUMBER() <> 51008 THROW;
    SET @rejected = 1;
    PRINT N'Ожидаемая ошибка: ' + ERROR_MESSAGE();
END CATCH;
IF @rejected = 0 THROW 51085, N'Некорректный балл не был отклонён.', 1;
IF (SELECT average_grade FROM college.students WHERE id = 2) <> @original
   OR (SELECT COUNT_BIG(*) FROM college.student_changes) <> @audit_before
    THROW 51086, N'После отклонённого UPDATE остались изменения.', 1;
SELECT * FROM college.students WHERE id = 2;
GO

-- Задание 7. Объяснение:
-- deleted хранит строки ДО UPDATE; inserted хранит строки ПОСЛЕ UPDATE.
-- JOIN по id сопоставляет старое и новое состояние каждого студента.
-- Audit: AFTER UPDATE, использует deleted и inserted.
-- ValidateGrade: AFTER INSERT, UPDATE, проверяет inserted.
-- SQL-команда обрабатывает множество строк, триггер вызывается на оператор.

-- Итоговое задание. Расширяем существующую таблицу без удаления журнала.
IF COL_LENGTH(N'college.student_changes', N'old_age') IS NULL
    ALTER TABLE college.student_changes ADD old_age int NULL;
IF COL_LENGTH(N'college.student_changes', N'new_age') IS NULL
    ALTER TABLE college.student_changes ADD new_age int NULL;
GO
CREATE OR ALTER TRIGGER college.trg_Students_AverageGradeAudit
ON college.students
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT (UPDATE(average_grade) OR UPDATE(age)) RETURN;
    INSERT INTO college.student_changes
        (student_id, old_average_grade, new_average_grade, old_age, new_age, change_date)
    SELECT i.id, d.average_grade, i.average_grade, d.age, i.age, SYSDATETIME()
    FROM inserted AS i
    JOIN deleted AS d ON d.id = i.id
    -- EXCEPT считает два NULL равными и обнаруживает изменение любого поля.
    WHERE EXISTS (SELECT i.average_grade, i.age EXCEPT SELECT d.average_grade, d.age);
END;
GO

BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM college.students WHERE id = 3)
        THROW 51080, N'В учебной базе отсутствует студент id=3.', 1;
    UPDATE college.students SET average_grade = 4.2 WHERE id = 3;
    DECLARE @before bigint = (SELECT COUNT_BIG(*) FROM college.student_changes);
    DECLARE @last int = ISNULL((SELECT MAX(id) FROM college.student_changes), 0);
    UPDATE college.students
    SET age = age + 1, average_grade = average_grade + 0.1 WHERE id = 3;
    IF (SELECT COUNT_BIG(*) FROM college.student_changes) <> @before + 1
        THROW 51087, N'Ожидалась одна запись после изменения возраста и балла.', 1;
    IF NOT EXISTS (SELECT 1 FROM college.student_changes
                   WHERE id > @last AND student_id = 3
                     AND new_age = old_age + 1 AND new_average_grade = old_average_grade + 0.1)
        THROW 51088, N'Журнал не сохранил оба изменения.', 1;
    SELECT * FROM college.student_changes WHERE id > @last ORDER BY id;

    -- Отдельно проверяем изменение только возраста и UPDATE без изменения.
    SET @before = (SELECT COUNT_BIG(*) FROM college.student_changes);
    UPDATE college.students SET age = age + 1 WHERE id = 3;
    IF (SELECT COUNT_BIG(*) FROM college.student_changes) <> @before + 1
        THROW 51089, N'Изменение только возраста не записано.', 1;
    SET @before = (SELECT COUNT_BIG(*) FROM college.student_changes);
    UPDATE college.students SET age = age, average_grade = average_grade WHERE group_id = 1;
    IF (SELECT COUNT_BIG(*) FROM college.student_changes) <> @before
        THROW 51090, N'UPDATE без изменения ошибочно попал в журнал.', 1;
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

-- Дополнительная проверка INSERT с недопустимым баллом.
DECLARE @students_before bigint = (SELECT COUNT_BIG(*) FROM college.students);
DECLARE @rejected bit = 0;
BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO college.students(name, age, average_grade, group_id)
    VALUES(N'Тест отклонённой вставки', 18, -1, 1);
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    IF ERROR_NUMBER() <> 51008 THROW;
    SET @rejected = 1;
    PRINT N'Ожидаемая ошибка INSERT: ' + ERROR_MESSAGE();
END CATCH;
IF @rejected = 0 OR (SELECT COUNT_BIG(*) FROM college.students) <> @students_before
    THROW 51091, N'Проверка недопустимого INSERT не пройдена.', 1;
PRINT N'ПР №8: проверки триггеров пройдены. Тестовые изменения отменены.';
GO

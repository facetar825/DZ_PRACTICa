/* Дополнительная учебная база для запуска лабораторной с нуля.
   Это демонстрационные данные, а не восстановление базы преподавателя.
   Скрипт выполняется только если CollegeDB ещё не существует.
   В SSMS запускайте весь файл целиком.
*/
USE master;
GO
IF DB_ID(N'CollegeDB') IS NOT NULL
BEGIN
    RAISERROR(N'CollegeDB уже существует. Учебная база не создана.', 16, 1);
    SET NOEXEC ON;
END;
GO
CREATE DATABASE CollegeDB;
GO
USE CollegeDB;
GO
CREATE SCHEMA college;
GO
CREATE TABLE college.groups
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    name NVARCHAR(20) NOT NULL,
    specialty NVARCHAR(100) NOT NULL
);
CREATE TABLE college.students
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    age INT NOT NULL CHECK (age > 0),
    average_grade DECIMAL(4, 2) NULL CHECK (average_grade BETWEEN 2 AND 5),
    group_id INT NOT NULL REFERENCES college.groups(id)
);
CREATE TABLE college.grades
(
    id INT IDENTITY(1, 1) PRIMARY KEY,
    student_id INT NOT NULL REFERENCES college.students(id),
    subject NVARCHAR(100) NOT NULL,
    grade INT NOT NULL CHECK (grade BETWEEN 2 AND 5),
    grade_date DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE)
);

INSERT INTO college.groups (name, specialty)
VALUES (N'ИС-31', N'Информационные системы и программирование'),
       (N'ИС-32', N'Информационные системы и программирование');

INSERT INTO college.students (name, age, average_grade, group_id)
VALUES (N'Мингазов Ахнаф', 19, 4.50, 1),
       (N'Иванов Алексей', 19, 4.50, 1),
       (N'Петрова Мария', 18, 3.50, 1),
       (N'Сидоров Иван', 20, 3.00, 2),
       (N'Смирнова Анна', 19, 4.75, 2),
       (N'Кузнецов Павел', 18, NULL, 2);

INSERT INTO college.grades (student_id, subject, grade, grade_date)
VALUES (1, N'Базы данных', 5, '20260928'),
       (1, N'Программирование', 4, '20260929'),
       (2, N'Базы данных', 4, '20260928'),
       (2, N'Программирование', 5, '20260929'),
       (3, N'Базы данных', 3, '20260928'),
       (3, N'Программирование', 4, '20260929'),
       (4, N'Базы данных', 3, '20260928'),
       (4, N'Программирование', 3, '20260929'),
       (5, N'Базы данных', 5, '20260928'),
       (5, N'Программирование', 5, '20260929'),
       (5, N'Математика', 5, '20260930'),
       (5, N'Английский язык', 4, '20260930');
GO
SET NOEXEC OFF;
GO

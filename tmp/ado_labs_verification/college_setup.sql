USE master;
GO

IF DB_ID(N'CollegeDB_Check_f1897f9e') IS NOT NULL
BEGIN
    RAISERROR(N'База уже существует. Повторное создание отменено.', 16, 1);
    SET NOEXEC ON;
END;
GO

CREATE DATABASE CollegeDB_Check_f1897f9e;
GO

USE CollegeDB_Check_f1897f9e;
GO

IF SCHEMA_ID(N'college') IS NULL
    EXEC(N'CREATE SCHEMA college');
GO

CREATE TABLE college.groups
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(50) NOT NULL,
    specialty NVARCHAR(150) NOT NULL
);
GO

CREATE TABLE college.students
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    age INT NOT NULL,
    average_grade DECIMAL(4,2) NOT NULL,
    group_id INT NOT NULL,

    CONSTRAINT FK_students_groups
        FOREIGN KEY (group_id)
        REFERENCES college.groups(id)
);
GO

CREATE TABLE college.grades
(
    id INT IDENTITY(1,1) PRIMARY KEY,
    student_id INT NOT NULL,
    subject NVARCHAR(100) NOT NULL,
    grade INT NOT NULL,
    grade_date DATE NOT NULL,

    CONSTRAINT FK_grades_students
        FOREIGN KEY (student_id)
        REFERENCES college.students(id)
);
GO

INSERT INTO college.groups (name, specialty)
VALUES
(N'ИС-31', N'Информационные системы и программирование'),
(N'ПР-31', N'Программирование'),
(N'СА-31', N'Сетевое и системное администрирование');
GO

INSERT INTO college.students
    (name, age, average_grade, group_id)
VALUES
(N'Алексей Иванов',   18, 4.70, 1),
(N'Мария Петрова',    17, 4.90, 1),
(N'Дмитрий Соколов',  18, 4.20, 1),
(N'Анна Морозова',    17, 4.50, 1),

(N'Илья Волков',      18, 4.80, 2),
(N'Екатерина Орлова', 18, 4.60, 2),
(N'Максим Кузнецов',  17, 3.90, 2),
(N'София Васильева',  18, 4.40, 2),

(N'Никита Смирнов',   18, 4.10, 3),
(N'Полина Фёдорова',  17, 4.70, 3);
GO

INSERT INTO college.grades
    (student_id, subject, grade, grade_date)
VALUES
 
(1,  N'Базы данных',       5, '2026-09-01'),
(1,  N'Программирование',  5, '2026-09-03'),
(1,  N'Сети',              4, '2026-09-05'),

(2,  N'Базы данных',       5, '2026-09-01'),
(2,  N'Программирование',  5, '2026-09-03'),
(2,  N'Сети',              5, '2026-09-05'),

(3,  N'Базы данных',       4, '2026-09-01'),
(3,  N'Программирование',  4, '2026-09-03'),
(3,  N'Сети',              4, '2026-09-05'),

(4,  N'Базы данных',       5, '2026-09-01'),
(4,  N'Программирование',  4, '2026-09-03'),
(4,  N'Сети',              5, '2026-09-05'),

(5,  N'Базы данных',       5, '2026-09-01'),
(5,  N'Программирование',  5, '2026-09-03'),
(5,  N'Сети',              5, '2026-09-05'),

(6,  N'Базы данных',       5, '2026-09-01'),
(6,  N'Программирование',  4, '2026-09-03'),
(6,  N'Сети',              5, '2026-09-05'),

(7,  N'Базы данных',       4, '2026-09-01'),
(7,  N'Программирование',  3, '2026-09-03'),
(7,  N'Сети',              4, '2026-09-05'),

(8,  N'Базы данных',       4, '2026-09-01'),
(8,  N'Программирование',  5, '2026-09-03'),
(8,  N'Сети',              4, '2026-09-05'),

(9,  N'Базы данных',       4, '2026-09-01'),
(9,  N'Программирование',  4, '2026-09-03'),
(9,  N'Сети',              4, '2026-09-05'),

(10, N'Базы данных',       5, '2026-09-01'),
(10, N'Программирование',  4, '2026-09-03'),
(10, N'Сети',              5, '2026-09-05');
GO

SET NOEXEC OFF;
GO

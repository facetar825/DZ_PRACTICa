from pathlib import Path
import json, re

ROOT = Path('Теория баз данных Microsoft SQL Server/Домашние задания/ДЗ_2026-10-05')
ROOT.mkdir(parents=True, exist_ok=True)
DB = 'CollegeDB_HW_20261005'
def write(name, text):
    (ROOT/name).write_text(text.strip()+'\n', encoding='utf-8-sig')
def sql(name, text):
    write(name, f'-- Учебная работа. Выполнять в SSMS целиком, включая разделители GO.\nUSE [{DB}];\nGO\nSET NOCOUNT ON;\nGO\n'+text)

source = Path('Теория баз данных Microsoft SQL Server/Лабораторные и Практические работы/ЛАБ_Комплексная_SQL_Server/Мингазов_Ахнаф/01_База_для_локального_запуска.sql').read_text(encoding='utf-8-sig')
# Повторное выполнение подготовки не изменяет уже созданную учебную базу.
source = source.replace('CollegeDB_ComplexLab', DB).replace("RAISERROR(N'База уже существует. Повторное создание отменено.', 16, 1);", "PRINT N'Учебная база уже существует. Подготовка пропущена.';")
source = source.replace('name NVARCHAR(50) NOT NULL,', 'name NVARCHAR(50) NOT NULL,\n    course INT NOT NULL DEFAULT 3,', 1)
source = source.replace('average_grade DECIMAL(4,2) NOT NULL,', 'average_grade DECIMAL(4,2) NULL,')
source = source.replace('subject NVARCHAR(100) NOT NULL,', "subject NVARCHAR(100) NOT NULL DEFAULT N'Базы данных',")
source = source.replace('grade INT NOT NULL,', 'grade INT NOT NULL CHECK (grade BETWEEN 2 AND 5),')
source = source.replace('SET NOEXEC OFF;', "INSERT INTO college.students (name, age, average_grade, group_id)\nVALUES (N'Артём Сергеев', 18, 4.70, 1),\n       (N'Студент без оценок', 18, NULL, 3);\nGO\n\nSET NOEXEC OFF;")
write('00_Подготовка_базы.sql', source)

sql('01_VIEW.sql', '''
-- Самостоятельная работа: все студенты, в том числе без оценок.
CREATE OR ALTER VIEW college.student_statistics
AS
SELECT s.id, s.name, s.group_id, g.name AS group_name,
       COUNT(gr.id) AS grade_count,
       AVG(CAST(gr.grade AS DECIMAL(10,4))) AS average_grade,
       MIN(gr.grade) AS min_grade, MAX(gr.grade) AS max_grade
FROM college.students AS s
JOIN college.groups AS g ON g.id = s.group_id
LEFT JOIN college.grades AS gr ON gr.student_id = s.id
GROUP BY s.id, s.name, s.group_id, g.name;
GO
-- 1. Все записи.
SELECT * FROM college.student_statistics ORDER BY id;
-- 2. Средний балл не ниже 4.5.
SELECT * FROM college.student_statistics WHERE average_grade >= 4.5 ORDER BY id;
-- 3. Сортировка по среднему баллу.
SELECT * FROM college.student_statistics ORDER BY average_grade DESC, id;
-- 4. Студенты одной группы.
SELECT * FROM college.student_statistics WHERE group_id = 1 ORDER BY id;
GO
-- 5. Новая оценка сразу видна во VIEW. Откат оставляет исходные данные.
BEGIN TRANSACTION;
SELECT N'До добавления' AS stage, * FROM college.student_statistics WHERE id = 1;
INSERT INTO college.grades (student_id, subject, grade, grade_date)
VALUES (1, N'Базы данных', 5, '20261005');
SELECT N'После добавления' AS stage, * FROM college.student_statistics WHERE id = 1;
ROLLBACK TRANSACTION;
GO
''')

sql('02_Процедуры.sql', '''
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
''')

sql('03_Функции.sql', '''
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
''')

sql('04_Триггеры.sql', '''
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
''')

sql('05_Подзапросы.sql', '''
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
''')

sql('06_CTE.sql', '''
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
''')

ranking = '''SELECT s.id, s.name, s.group_id, g.name AS group_name, s.average_grade,
       ROW_NUMBER() OVER (PARTITION BY s.group_id ORDER BY s.average_grade DESC, s.id) AS student_number,
       RANK() OVER (PARTITION BY s.group_id ORDER BY s.average_grade DESC) AS student_rank,
       AVG(s.average_grade) OVER (PARTITION BY s.group_id) AS group_average,
       s.average_grade - AVG(s.average_grade) OVER (PARTITION BY s.group_id) AS difference_from_average
FROM college.students AS s JOIN college.groups AS g ON g.id = s.group_id'''
sql('07_Оконные_функции.sql', f'''
-- Самостоятельная и домашняя работы: полный рейтинг, среднее группы и отклонение.
{ranking}
ORDER BY s.group_id, student_number;
-- Три лучших студента каждой группы. AVG вычисляется ДО фильтрации топ-3.
;WITH RankedStudents AS (
{ranking}
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
''')

ANSWERS = [
'''VIEW - именованный запрос, доступный как виртуальная таблица.
Таблица хранит строки физически; обычное VIEW хранит определение запроса и получает строки из исходных объектов.
Определение хранится в метаданных базы; его можно посмотреть через sys.sql_modules или OBJECT_DEFINITION(OBJECT_ID(N'college.student_statistics')).
CREATE VIEW schema.name AS SELECT ...; команда создания должна начинать отдельный пакет.
ALTER VIEW schema.name AS SELECT ...; также доступно CREATE OR ALTER VIEW.
DROP VIEW schema.name; исходные таблицы при этом не удаляются.
Да, можно объединять несколько таблиц с помощью JOIN.
Да, доступны AVG, COUNT, SUM, MIN, MAX и GROUP BY.
Да, например RANK() OVER (ORDER BY average_grade DESC).
Обычное VIEW не содержит самостоятельной копии строк; результат зависит от текущих данных источников.
Оптимизатор работает с базовыми объектами; сохранение текста запроса не устраняет JOIN и вычисления. Индексированное представление - отдельный механизм.
Для повторных отчётов, общего интерфейса чтения, скрытия сложных JOIN и выдачи ограниченного набора столбцов.
VIEW используется в FROM и определяет выборку; процедура вызывается через EXEC и выполняет последовательность действий.
VIEW не принимает параметры; функция принимает параметры и возвращает скаляр или таблицу.
Создать VIEW только с разрешёнными столбцами/строками и выдать SELECT на него. Одновременно нужно исключить прямой доступ к таблице; само создание VIEW права не ограничивает.''',
'''Именованный объект базы с последовательностью SQL-инструкций для выполнения операции.
CREATE PROCEDURE schema.name @parameter INT AS BEGIN ... END; создание отделяется GO от других пакетов.
EXEC schema.name @parameter = 1; либо EXECUTE.
Для передачи значений, от которых зависит действие процедуры: идентификатора, порога, даты и других условий.
Да; их перечисляют через запятую, а при вызове удобно указывать имена.
Параметр с OUTPUT возвращает значение в переменную вызывающего кода.
SELECT возвращает результирующий набор строк и столбцов, OUTPUT - значение через параметр. OUTPUT нужен и в объявлении, и при вызове для получения значения.
Для завершения процедуры и возврата целочисленного кода состояния; например 0 - успех.
Выполняет код TRY и передаёт управление в CATCH при перехватываемой ошибке.
В CATCH возвращает текст текущей ошибки; вне CATCH возвращает NULL.
THROW 50001, N'Сообщение', 1 вызывает собственную ошибку; THROW; внутри CATCH повторно передаёт исходную ошибку.
CREATE создаёт новый объект; ALTER меняет существующий. CREATE OR ALTER поддерживает оба случая.
Да, процедура может выполнять INSERT, UPDATE, DELETE и управлять транзакциями.
Процедура исполняет сценарий с параметрами и логикой; VIEW - сохранённая выборка для использования в запросах.
Процедура вызывается через EXEC и может менять данные; функция возвращает определённый тип результата и используется в выражении или FROM.''',
'''Объект базы, принимающий параметры и возвращающий вычисленное значение либо таблицу.
Функция используется внутри запроса и не изменяет постоянные таблицы; процедура выполняет отдельную операцию и может изменять их.
Одно значение объявленного типа, например INT или NVARCHAR.
RETURNS объявляет тип возвращаемого значения либо структуру возвращаемой таблицы.
SELECT college.GetScholarship(4.80); имя скалярной функции указывают со схемой.
Функция, возвращающая набор строк и столбцов, который используется как источник данных.
Inline TVF возвращает один SELECT через RETURN (...); Multi-Statement TVF объявляет табличную переменную, заполняет её инструкциями и возвращает через RETURN.
Потому что её результат имеет табличную структуру: SELECT * FROM college.GetStudentsByMinGrade(4.5).
Когда нужны входные параметры или повторяемое вычисление; VIEW параметры не принимает.
Когда требуется вставка/изменение/удаление постоянных данных, транзакция или обработка ошибок сценария.
Таблицу нельзя подставить как одно значение: запрос завершится ошибкой. Нужно FROM или подзапрос с выбором отдельного столбца и гарантированно одной строки.
Чтобы хранить правила в одном месте, избегать копирования CASE и единообразно обновлять вычисления.''',
'''Объект базы, автоматически выполняемый при определённом событии; в этой теме рассматриваются DML-триггеры.
Триггер связан с событием таблицы/представления и запускается этой операцией, а не прямым EXEC.
INSERT, UPDATE и DELETE.
AFTER запускается после успешного выполнения операции и проверок ограничений, оставаясь в той же транзакции. INSTEAD OF выполняет свою логику вместо операции.
Логическая таблица новых строк при INSERT или новых версий строк при UPDATE.
Логическая таблица удалённых строк при DELETE или старых версий при UPDATE.
Новые значения всех строк, затронутых UPDATE.
Старые значения всех строк, затронутых UPDATE.
Один оператор может изменить множество строк; DML-триггер работает на оператор, а не отдельно на каждую строку.
Соединить inserted и deleted по неизменяемому первичному ключу и выбрать старые/новые поля. Для nullable полей отдельно учесть переходы из/в NULL.
Для истории добавлений, удалений и изменений: кто/что изменено, прежние/новые значения и время.
Для простого условия над строкой, например age >= 16 или price > 0; CHECK проще и явно описывает ограничение.
Процедуру явно вызывает клиент через EXEC; триггер автоматически реагирует на событие и использует inserted/deleted.
Скрытые цепочки действий, рекурсия и зависимость от порядка усложняют диагностику и увеличивают стоимость изменений.''',
'''SQL-запрос, вложенный в другой SQL-запрос.
Его результат используется внешним запросом как значение, набор значений, таблица либо проверка существования.
Подзапрос с одним столбцом и не более чем одной строкой; отсутствие строк даёт NULL в скалярном контексте.
В SELECT, WHERE, HAVING и FROM, а также в других допустимых выражениях.
SQL Server выдаст ошибку о нескольких значениях скалярного подзапроса; нужно IN либо агрегирование, если оно соответствует задаче.
Для проверки принадлежности значения набору значений, возвращённому подзапросом.
Есть ли хотя бы одна строка в результате подзапроса.
Содержимое строки не требуется; константа 1 подчёркивает проверку наличия, а не извлечение данных.
IN сравнивает значение с набором, EXISTS проверяет наличие строки, часто по связи с внешним запросом. При NULL особенно различаются NOT IN и NOT EXISTS.
Подзапрос, ссылающийся на столбцы внешнего запроса.
Из текущей строки внешнего запроса через его псевдоним, например s.group_id.
Некоррелированный не зависит от внешней строки; коррелированный логически вычисляется в её контексте. Реальный план может преобразовать такую обработку.
Когда промежуточный результат нужен только в одном выражении запроса и не нужно отдельное состояние переменной.
Да, он образует производную таблицу: FROM (SELECT ...) AS stats.
Псевдоним именует источник и позволяет обращаться к его столбцам; для производной таблицы в SQL Server он обязателен.''',
'''Common Table Expression - именованное выражение запроса, доступное следующему оператору.
Для объявления одного или нескольких CTE: ;WITH Name AS (SELECT ...) SELECT ... FROM Name.
CTE не хранит самостоятельные строки и не является постоянным объектом базы. Это описание результата, а не обычная таблица.
Область видимости ограничена одним следующим оператором SELECT/INSERT/UPDATE/DELETE/MERGE; после него имя недоступно.
Да, CTE можно соединять с таблицами и другими доступными CTE.
Да, через запятую после одного WITH: WITH A AS (...), B AS (...) SELECT ... .
Да, можно ссылаться на ранее объявленный CTE; вперёд ссылаться нельзя. Рекурсивный CTE может ссылаться на себя.
При последовательных этапах фильтрации, агрегации, расчёта рейтинга и последующей фильтрации по нему.
CTE, рекурсивная часть которого ссылается на это же CTE для получения следующего уровня результата.
Начальная часть (anchor member) и рекурсивная часть (recursive member).
Объединяет начальный результат с результатами следующих шагов без удаления повторов; в типовом рекурсивном CTE связывает начальную и рекурсивную части.
Начальная выборка, которая задаёт стартовые строки и не ссылается на сам CTE.
Выборка, использующая предыдущий уровень CTE для построения следующего.
В деревьях категорий, подразделений, сотрудников, комментариев и для генерации последовательностей.
Чтобы новые строки перестали появляться; иначе возможны циклы и превышение лимита рекурсии. Для графов полезна проверка уже посещённых узлов.
Ограничивает число рекурсивных шагов. По умолчанию 100; допустимы 0..32767, где 0 снимает лимит. Лимит не заменяет корректную остановку.
Обычный CTE не ссылается на себя; рекурсивный получает следующие строки через обращение к собственному предыдущему уровню.
В anchor выбрать корень, затем JOIN детей по child.parent_id = parent.id, увеличивая глубину, пока дочерних строк больше нет.''',
'''Функция, вычисляющая значение по набору строк (окну) и сохраняющая отдельные строки результата.
GROUP BY сворачивает строки в группы; оконная функция добавляет результат расчёта каждой исходной строке.
OVER описывает окно: разделение строк, порядок и, для подходящих функций, рамку окна.
Делит строки на независимые разделы; расчёт начинается отдельно для каждого раздела.
Определяет порядок для расчёта функции внутри окна; итоговую сортировку задают отдельным ORDER BY.
ROW_NUMBER даёт уникальные номера; RANK даёт равным значениям одинаковые места и пропускает следующие позиции.
RANK пропускает позиции после равных мест, DENSE_RANK не пропускает: для 5, 4.8, 4.8, 4.2 получаем 1,2,2,4 и 1,2,2,3.
Они получают одно место; следующая позиция увеличивается с учётом количества строк. Равенство определяется всеми выражениями ORDER BY окна.
Для получения значения предыдущей строки в заданном порядке, по умолчанию со смещением 1.
Для получения значения следующей строки в заданном порядке, по умолчанию со смещением 1.
Если предыдущей строки нет, возвращается NULL либо указанный третий аргумент default.
Если следующей строки нет, возвращается NULL либо заданное значение default.
Да: AVG(average_grade) OVER (PARTITION BY group_id).
Оконный AVG повторяет среднее рядом с каждым студентом; GROUP BY возвращает одну агрегированную строку на группу.
Чтобы во внешнем запросе фильтровать уже вычисленные номера или ранги.
WHERE логически обрабатывается раньше SELECT и оконных вычислений; псевдоним и результат ещё недоступны.
Топ-N в группе, нумерация, страницы результатов, выбор первой/последней записи, устранение дублей. Для стабильности при равенстве нужен дополнительный ключ.
Сравнение продаж, баланса, оценок или игровых результатов между соседними датами; поиск изменений и промежутков.'''
]

NOTES = [
'''Представление (VIEW) сохраняет запрос и предоставляет его результат как виртуальную таблицу. Обычное VIEW не создаёт копию данных и автоматически отражает изменения исходных таблиц. Оно полезно для повторяющихся отчётов, сложных JOIN и единого интерфейса чтения.

Создание: `CREATE VIEW ... AS SELECT ...`; изменение: `ALTER VIEW`; удаление: `DROP VIEW`. В практических скриптах используется `CREATE OR ALTER VIEW`, позволяющий повторный запуск. Определение модуля должно начинать отдельный пакет, поэтому применяются разделители `GO`.

Внутри допустимы JOIN, агрегаты, CTE и оконные функции. Сортировку результата задают при обращении к VIEW. Параметры VIEW не принимает. Возможность изменения данных зависит от определения; вычисляемые агрегаты напрямую обновлять нельзя.

VIEW само по себе не ускоряет запрос. Для ограничения доступа создают выборку нужных строк/столбцов и настраивают права; наличие VIEW без ограничения прямого доступа к таблицам недостаточно.

Практика: создано `college.student_statistics` со всеми требуемыми полями и пятью проверками. LEFT JOIN сохраняет студентов без оценок: COUNT(gr.id)=0, AVG/MIN/MAX=NULL. Оценки INT преобразованы в DECIMAL перед AVG, чтобы среднее не потеряло дробную часть.''',
'''Хранимая процедура хранит последовательность инструкций и вызывается командой EXEC. Она предназначена для операции: получить параметры, проверить данные, выполнить действия и вернуть результат. Допускает несколько параметров, значения по умолчанию, переменные и IF/ELSE.

Создание: `CREATE PROCEDURE`; изменение: `ALTER PROCEDURE`; удаление: `DROP PROCEDURE`. Табличный результат возвращает SELECT; отдельное значение можно получить через OUTPUT. RETURN возвращает целочисленный код состояния. OUTPUT при получении результата указывают и в объявлении, и при вызове.

TRY/CATCH позволяет обработать ошибку; ERROR_NUMBER, ERROR_MESSAGE, ERROR_LINE и ERROR_PROCEDURE помогают диагностике. THROW с номером от 50000 создаёт пользовательскую ошибку; THROW без аргументов в CATCH повторно передаёт исходную.

Практика: `college.GetStudentStatistics` принимает идентификатор, проверяет наличие студента и возвращает имя, группу, количество, среднюю, минимальную и максимальную оценку. Отсутствующий студент вызывает ошибку 50001. Студент без оценок остаётся в результате. Дополнительно показаны OUTPUT и RETURN.''',
'''Пользовательская функция принимает параметры и возвращает результат для использования внутри SQL-запроса. Scalar-функция возвращает одно значение; табличная функция возвращает строки и столбцы. RETURNS объявляет тип результата, RETURN возвращает его.

Inline TVF описывает результат одним SELECT; Multi-Statement TVF объявляет табличную переменную и наполняет её инструкциями. Для простой выборки обычно достаточно Inline TVF. Scalar вызывают в выражении со схемой, TVF - в FROM либо APPLY.

Функция не предназначена для изменения постоянных таблиц. Для операций изменения и полноценного сценария обработки ошибок используют процедуру. Для выборки без параметров подходит VIEW.

Практика: `GetScholarship` выдаёт 5000 при 4.80..5.00, 4000 при 4.50..4.79, 3000 при 4.00..4.49 и 0 ниже 4.00. Тип DECIMAL(4,2) соответствует границам с двумя знаками. Для NULL и недопустимого балла принят результат 0. Inline TVF `GetStudentsByMinGrade` отбирает студентов по порогу включительно. Дополнительно приведён пример Multi-Statement TVF.''',
'''DML-триггер запускается автоматически при INSERT, UPDATE или DELETE. AFTER работает после операции и проверок ограничений, INSTEAD OF выполняется вместо операции. Триггер участвует в той же транзакции; откат отменяет и изменения, и записи аудита.

inserted содержит новые строки, deleted - старые. При UPDATE доступны обе таблицы; их соединяют по первичному ключу. Они содержат набор строк, поэтому триггер необходимо писать через INSERT ... SELECT и EXISTS, не выбирая один id в переменную.

Типичные сценарии: журнал изменений, аудит добавлений и контроль сложных бизнес-правил. Простые правила лучше выражать CHECK, FOREIGN KEY и NOT NULL. SET NOCOUNT ON исключает лишние сообщения о количестве строк.

Практика: таблица `student_changes` содержит все требуемые поля. Триггер записывает реальные изменения балла, включая переходы NULL. Дополнительный триггер запрещает балл >5 через THROW. Выполнено домашнее закрепление: аудит INSERT и UPDATE, пример изменения нескольких студентов одним оператором.''',
'''Подзапрос - запрос внутри другого запроса. Он используется в SELECT, WHERE, HAVING или FROM. Скалярный подзапрос даёт один столбец и не более одной строки; несколько строк в скалярном контексте приводят к ошибке. При отсутствии строк результат равен NULL.

IN проверяет наличие значения в наборе, EXISTS - наличие хотя бы одной строки. SELECT 1 в EXISTS показывает, что важен факт существования. NOT IN с NULL может дать UNKNOWN; для проверки отсутствия связанных строк обычно удобен NOT EXISTS.

Коррелированный подзапрос обращается к внешней строке, например к s.group_id. Это позволяет сравнить балл студента со средним именно его группы. Логическая зависимость не означает обязательного физического выполнения по одному разу на строку: оптимизатор выбирает план.

Подзапрос в FROM называется производной таблицей и требует псевдоним. В PDF нет отдельного самостоятельного/домашнего SQL-задания; для полного закрепления подготовлены восемь запросов по всем основным видам.

Уточнение примера PDF: AVG по всем college.students - среднее колледжа; среднее конкретной группы требует условия по group_id.''',
'''CTE (Common Table Expression) задаёт именованный результат для одного следующего оператора. Синтаксис: `;WITH Name AS (...) SELECT ... FROM Name`. Точка с запятой завершает предыдущий оператор. Несколько CTE перечисляют через запятую, а последующий может ссылаться на предыдущий.

CTE упрощает этапы агрегации, соединения, фильтрации и рейтинга, но не является постоянной таблицей и не гарантирует материализацию или ускорение. После завершающего оператора его имя недоступно.

Рекурсивный CTE состоит из anchor member и recursive member, соединённых UNION ALL. Anchor задаёт начало, recursive обращается к предыдущему уровню. Рекурсия завершается, когда следующий шаг не возвращает строк. Для дерева JOIN связывает child.parent_id с parent.id.

MAXRECURSION ограничивает число рекурсивных шагов (по умолчанию 100); 0 снимает ограничение. Нужны корректное условие остановки и защита от циклов при обходе графа.

Домашняя практика: anchor возвращает 1; recursive добавляет 1, пока number<20. Когда получено 20, следующего шага нет. Запрос возвращает 20 чисел 1..20. Дополнительно приведены обычные CTE, несколько CTE с JOIN и обход дерева с глубиной и проверкой посещённых узлов.''',
'''Оконные функции вычисляют результат по окну, сохраняя отдельные строки. OVER описывает PARTITION BY, порядок ORDER BY и при необходимости рамку ROWS. PARTITION BY разделяет студентов на группы. ORDER BY окна управляет вычислением; итоговый порядок задаётся отдельно.

ROW_NUMBER выдаёт уникальные номера. Для стабильного выбора при равных баллах добавлен id. RANK даёт равным баллам одинаковое место с пропусками; DENSE_RANK - без пропусков. В RANK и DENSE_RANK id не добавляется, иначе одинаковые баллы перестанут считаться равными.

LAG получает предыдущее значение, LEAD - следующее. На границах без указанного default возвращается NULL. AVG, SUM, COUNT, MIN и MAX также работают с OVER. Для накопительной суммы явно задано ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW.

WHERE применяется раньше оконных вычислений, поэтому фильтрацию топ-3 выполняют во внешнем запросе над CTE. Среднее по группе вычисляется внутри CTE до отбора трёх студентов, чтобы не превратиться в среднее только лидеров.

Практика: полный рейтинг содержит имя, группу, балл, номер, место, среднее группы и отклонение; отдельный CTE выбирает три лучших. На баллах 5.0,4.8,4.8,4.2 показаны номера 1,2,3,4; ранги 1,2,2,4; плотные ранги 1,2,2,3. Дополнительно показаны LAG/LEAD и накопительная сумма. Уточнение PDF: разность 128-135 равна -7.'''
]
titles = ['Представления VIEW','Хранимые процедуры','Пользовательские функции','Триггеры','Подзапросы EXISTS и корреляция','CTE и рекурсивные запросы','Оконные функции']
for idx, (title, notes, answers) in enumerate(zip(titles, NOTES, ANSWERS), 1):
    qs = json.loads(Path(f'tmp/pdfs/{idx:02}_questions.json').read_text(encoding='utf-8'))
    # Убираем попавшие между страницами колонтитулы.
    for j, q in enumerate(qs):
        for prefix in ['Что ', 'Чем ', 'Где ', 'Как ', 'Для ', 'Можно ', 'Может ', 'Почему ', 'В ', 'Зачем ', 'Какие ', 'Сколько ', 'Из ', 'Откуда ']:
            if prefix in q and not q.startswith(prefix):
                pos = q.find(prefix)
                if pos > 25: qs[j] = q[pos:]; break
    aa = answers.splitlines()
    assert len(qs) == len(aa), (idx,len(qs),len(aa))
    content = f'# {idx}. {title}\n\n## Конспект\n\n{notes}\n\n## Ответы на вопросы для самопроверки\n\n'
    for j, (q,a) in enumerate(zip(qs,aa),1):
        content += f'### {j}. {q}\n\n{a}\n\n'
    content += f'## Практическая часть\n\nРешение находится в SQL-файле с номером {idx:02} в этой папке. Порядок запуска описан в README.md.\n'
    write(f'{idx:02}_Конспект_и_ответы.md', content)

write('README.md', f'''# SQL Server: решения по семи темам

Подготовлены конспекты, ответы на все 107 вопросов для самопроверки, самостоятельные и домашние SQL-задания, включая дополнительные упражнения. Каждой теме соответствует SQL-файл и файл «Конспект и ответы». Нумерация совпадает с порядком присланных PDF.

## Запуск

1. Подключиться в SSMS к локальному SQL Server с правами создания учебной базы.
2. Выполнить `00_Подготовка_базы.sql` целиком. Он создаёт отдельную `{DB}` со схемой college, 3 группами, 12 студентами и 30 оценками. При повторном запуске существующая база не пересоздаётся.
3. Выполнить SQL-файлы `01`..`07` в порядке номеров. Объекты создаются через CREATE OR ALTER; демонстрационные изменения откатываются транзакциями.
4. Выполнить `08_Проверки.sql`; итог должен быть «Все проверки пройдены».

SQL рассчитан на Microsoft SQL Server 2016 SP1 или новее. GO - разделитель пакетов SSMS/sqlcmd, а не оператор T-SQL. Для запуска через другой клиент нужен режим выполнения скрипта с обработкой GO.

## Особенности исходной базы

В доступной локальной CollegeDB отсутствуют college.grades и students.group_id, поэтому без подготовки выполнить задания из PDF в ней нельзя. Решения проверяются в отдельной учебной базе. Для CollegeDB преподавателя можно заменить строку USE в тематических SQL-файлах, если её схема содержит groups(id,name), students(id,name,group_id,average_grade,age) и grades(id,student_id,grade,grade_date,subject). Пример IN дополнительно использует groups.course.

`students.average_grade` - сохранённый средний балл из уроков про функции/триггеры/окна. `student_statistics.average_grade` рассчитывается из grades. Это два разных источника: добавление оценки обновляет результат VIEW, но автоматически не меняет сохранённый балл students. Триггер синхронизации не входит в задания. Студент без оценок и равные баллы добавлены для проверки пограничных случаев.

## Содержание практики

- 01: VIEW статистики, фильтры, сортировка, группа, добавление оценки и просмотр изменений.
- 02: процедура статистики, THROW при отсутствии студента, OUTPUT и RETURN.
- 03: стипендия, Inline TVF по минимальному баллу, Multi-Statement TVF, границы диапазонов.
- 04: журнал изменения балла, многострочный UPDATE, аудит INSERT, запрет балла >5.
- 05: подзапросы в WHERE/SELECT/FROM, IN, EXISTS/NOT EXISTS и корреляция. В исходном PDF отдельного практического задания нет; примеры подготовлены для закрепления.
- 06: обычные и связанные CTE, последовательность 1..20, дерево подразделений с глубиной.
- 07: рейтинг группы, среднее и отклонение, топ-3, сравнение трёх видов ранга, LAG/LEAD и накопительная сумма.

## Проверка выполнения

Результаты запуска и проверки записываются в `Проверка_выполнения.md`. Ошибки 50001 и 50002 в демонстрациях ожидаемы и перехватываются TRY/CATCH.
''')
print(ROOT.resolve())

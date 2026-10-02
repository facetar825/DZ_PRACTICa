/*==============================================================
  Практическая работа №2. Подзапросы, EXISTS и коррелированные подзапросы
  Студент: Мингазов Ахнаф
  База данных: CollegeDB, схема: college
==============================================================*/

USE CollegeDB;
GO

/*==============================================================
  ПОДГОТОВКА ДАННЫХ
  Скрипт безопасен для повторного запуска: существующие данные
  не дублируются, недостающие создаются.
==============================================================*/

-- Таблица групп (если ещё не создана)
IF OBJECT_ID(N'college.groups', N'U') IS NULL
BEGIN
    CREATE TABLE college.groups (
        id   INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(50) NOT NULL
    );
END
GO

-- Столбец group_id в таблице студентов (если его ещё нет)
IF COL_LENGTH(N'college.students', N'group_id') IS NULL
BEGIN
    ALTER TABLE college.students ADD group_id INT NULL;
END
GO

-- Группы
INSERT INTO college.groups (name)
SELECT v.name
FROM (VALUES (N'ИС-21'), (N'ПР-21'), (N'СА-21')) AS v(name)
WHERE NOT EXISTS (SELECT 1 FROM college.groups g WHERE g.name = v.name);
GO

-- Студенты: добавляем недостающих (по имени) сразу с группой
INSERT INTO college.students (name, age, average_grade, group_id)
SELECT v.name, v.age, v.average_grade, g.id
FROM (VALUES
        (N'Иван',    18, 4.7, N'ИС-21'),
        (N'Мария',   17, 4.2, N'ИС-21'),
        (N'Алексей', 18, 3.6, N'ИС-21'),
        (N'Анна',    19, 4.9, N'ПР-21'),
        (N'Дмитрий', 17, 2.8, N'ПР-21'),
        (N'Елена',   18, 4.5, N'СА-21'),
        (N'Максим',  19, 3.9, N'СА-21')
     ) AS v(name, age, average_grade, group_name)
JOIN college.groups AS g ON g.name = v.group_name
WHERE NOT EXISTS (SELECT 1 FROM college.students s WHERE s.name = v.name);
GO

-- Студентам, добавленным на прошлых занятиях (без группы), проставляем группу
UPDATE s
SET s.group_id = g.id
FROM college.students AS s
JOIN (VALUES
        (N'Иван',    N'ИС-21'),
        (N'Мария',   N'ИС-21'),
        (N'Алексей', N'ИС-21'),
        (N'Анна',    N'ПР-21'),
        (N'Дмитрий', N'ПР-21'),
        (N'Елена',   N'СА-21'),
        (N'Максим',  N'СА-21')
     ) AS v(name, group_name) ON v.name = s.name
JOIN college.groups AS g ON g.name = v.group_name
WHERE s.group_id IS NULL;
GO

-- Проверка содержимого таблиц
SELECT * FROM college.groups;
SELECT * FROM college.students;
GO

/*==============================================================
  БЛОК 1. ПРОСТОЙ ПОДЗАПРОС
==============================================================*/

-- Задание 1. Средний балл выше среднего балла всех студентов
SELECT name, average_grade
FROM college.students
WHERE average_grade > (
    SELECT AVG(average_grade)
    FROM college.students
);
GO

-- Задание 2. Возраст выше среднего возраста всех студентов
-- AVG от INT возвращает INT (дробная часть отбрасывается),
-- поэтому приводим age к DECIMAL, чтобы среднее было точным.
SELECT name, age
FROM college.students
WHERE age > (
    SELECT AVG(CAST(age AS DECIMAL(5,2)))
    FROM college.students
);
GO

-- Задание 3. Средний балл равен максимальному среди всех студентов
SELECT name, average_grade
FROM college.students
WHERE average_grade = (
    SELECT MAX(average_grade)
    FROM college.students
);
GO

/*==============================================================
  БЛОК 2. ПОДЗАПРОС С IN
==============================================================*/

-- Задание 4. Студенты групп, в названии которых есть «ИС»
SELECT name, group_id
FROM college.students
WHERE group_id IN (
    SELECT id
    FROM college.groups
    WHERE name LIKE N'%ИС%'
);
GO

-- Задание 5. Студенты групп, название которых заканчивается на «21»
SELECT name, group_id
FROM college.students
WHERE group_id IN (
    SELECT id
    FROM college.groups
    WHERE name LIKE N'%21'
);
GO

-- Задание 6. Группы, где есть студент со средним баллом выше 4.5 (IN)
SELECT name
FROM college.groups
WHERE id IN (
    SELECT group_id
    FROM college.students
    WHERE average_grade > 4.5
);
GO

/*==============================================================
  БЛОК 3. EXISTS
==============================================================*/

-- Задание 7. Группы, где есть студент со средним баллом выше 4.5
SELECT g.name
FROM college.groups AS g
WHERE EXISTS (
    SELECT 1
    FROM college.students AS s
    WHERE s.group_id = g.id
      AND s.average_grade > 4.5
);
GO

-- Задание 8. Группы, где есть студент младше 18 лет
SELECT g.name
FROM college.groups AS g
WHERE EXISTS (
    SELECT 1
    FROM college.students AS s
    WHERE s.group_id = g.id
      AND s.age < 18
);
GO

-- Задание 9. Группы, где нет студентов со средним баллом ниже 3.0 (NOT EXISTS)
-- Примечание: пустые группы (без студентов) тоже попадут в результат.
SELECT g.name
FROM college.groups AS g
WHERE NOT EXISTS (
    SELECT 1
    FROM college.students AS s
    WHERE s.group_id = g.id
      AND s.average_grade < 3.0
);
GO

/*==============================================================
  БЛОК 4. КОРРЕЛИРОВАННЫЕ ПОДЗАПРОСЫ
==============================================================*/

-- Задание 10. Средний балл выше среднего балла своей группы
SELECT s.name, s.average_grade, s.group_id
FROM college.students AS s
WHERE s.average_grade > (
    SELECT AVG(s2.average_grade)
    FROM college.students AS s2
    WHERE s2.group_id = s.group_id
);
GO

-- Задание 11. Возраст выше среднего возраста своей группы
SELECT s.name, s.age, s.group_id
FROM college.students AS s
WHERE s.age > (
    SELECT AVG(CAST(s2.age AS DECIMAL(5,2)))
    FROM college.students AS s2
    WHERE s2.group_id = s.group_id
);
GO

-- Задание 12. Средний балл ниже среднего балла своей группы
SELECT s.name, s.average_grade, s.group_id
FROM college.students AS s
WHERE s.average_grade < (
    SELECT AVG(s2.average_grade)
    FROM college.students AS s2
    WHERE s2.group_id = s.group_id
);
GO

/*==============================================================
  БЛОК 5. СРАВНЕНИЕ IN И EXISTS
==============================================================*/

-- Задание 13.1. Группы со студентом со средним баллом >= 4.5 — через IN
SELECT name
FROM college.groups
WHERE id IN (
    SELECT group_id
    FROM college.students
    WHERE average_grade >= 4.5
);
GO

-- Задание 13.2. То же самое — через EXISTS
SELECT g.name
FROM college.groups AS g
WHERE EXISTS (
    SELECT 1
    FROM college.students AS s
    WHERE s.group_id = g.id
      AND s.average_grade >= 4.5
);
GO

-- Сравнение результатов: если оба запроса дают одинаковые наборы,
-- запрос ниже вернёт 0 строк (разница множеств в обе стороны пуста).
(
    SELECT name FROM college.groups
    WHERE id IN (SELECT group_id FROM college.students WHERE average_grade >= 4.5)
    EXCEPT
    SELECT g.name FROM college.groups AS g
    WHERE EXISTS (SELECT 1 FROM college.students AS s
                  WHERE s.group_id = g.id AND s.average_grade >= 4.5)
)
UNION ALL
(
    SELECT g.name FROM college.groups AS g
    WHERE EXISTS (SELECT 1 FROM college.students AS s
                  WHERE s.group_id = g.id AND s.average_grade >= 4.5)
    EXCEPT
    SELECT name FROM college.groups
    WHERE id IN (SELECT group_id FROM college.students WHERE average_grade >= 4.5)
);
-- Вывод: результаты совпадают, это два способа решить одну задачу.
GO

/*==============================================================
  БЛОК 6. КОМБИНАЦИЯ УСЛОВИЙ
==============================================================*/

-- Задание 14. Студенты группы ПР-21 со средним баллом выше среднего по группе
SELECT s.name, s.average_grade
FROM college.students AS s
WHERE s.group_id IN (
    SELECT id
    FROM college.groups
    WHERE name = N'ПР-21'
)
AND s.average_grade > (
    SELECT AVG(s2.average_grade)
    FROM college.students AS s2
    WHERE s2.group_id = s.group_id
);
GO

-- Задание 15. Младше среднего возраста своей группы И средний балл выше 4.0
SELECT s.name, s.age, s.average_grade, s.group_id
FROM college.students AS s
WHERE s.age < (
    SELECT AVG(CAST(s2.age AS DECIMAL(5,2)))
    FROM college.students AS s2
    WHERE s2.group_id = s.group_id
)
AND s.average_grade > 4.0;
GO

/*==============================================================
  БЛОК 7. ИТОГОВОЕ ЗАДАНИЕ
  Задание 16. Анализ успеваемости
  Студенты, чей средний балл выше среднего балла их группы.
  Средний балл группы получаем коррелированным подзапросом.
==============================================================*/

SELECT
    s.name          AS [Студент],
    s.average_grade AS [Средний балл],
    g.name          AS [Группа],
    (
        SELECT CAST(AVG(s2.average_grade) AS DECIMAL(3,2))
        FROM college.students AS s2
        WHERE s2.group_id = s.group_id
    )               AS [Средний балл группы]
FROM college.students AS s
JOIN college.groups   AS g ON g.id = s.group_id
WHERE s.average_grade > (
    SELECT AVG(s2.average_grade)
    FROM college.students AS s2
    WHERE s2.group_id = s.group_id
);
GO

/*==============================================================
  ОТВЕТЫ НА ВОПРОСЫ ДЛЯ САМОПРОВЕРКИ
==============================================================

1. Подзапрос — это запрос SELECT, вложенный в другой запрос и
   заключённый в круглые скобки. Его результат используется внешним запросом.

2. Подзапрос может находиться в WHERE, HAVING, в списке SELECT,
   в предложении FROM (как производная таблица), а также в
   INSERT / UPDATE / DELETE.

3. Внешний запрос — основной, он формирует итоговый результат.
   Внутренний (подзапрос) — вложенный; он поставляет внешнему значение,
   список значений или признак наличия строк.

4. При использовании = (а также >, <, >=, <=, <>) подзапрос должен
   вернуть ровно одно значение (один столбец, одна строка). Если строк
   больше одной, возникает ошибка.

5. IN проверяет, входит ли значение в список, возвращённый подзапросом
   (или заданный явно), и подходит, когда подзапрос возвращает много значений.

6. = сравнивает с одним значением, а IN — с набором значений:
   x IN (1, 2, 3) равносильно x = 1 OR x = 2 OR x = 3.
   Подзапрос с = должен вернуть одно значение, с IN — может несколько.

7. EXISTS проверяет, возвращает ли подзапрос хотя бы одну строку.
   Возвращает TRUE, если строка есть, иначе FALSE.

8. Внутри EXISTS важен только факт наличия строки, а не её данные,
   поэтому пишут SELECT 1 (константу): это короче и показывает, что
   значения столбцов не нужны. Результат от выбора столбцов не зависит.

9. NOT EXISTS возвращает TRUE, если подзапрос не вернул ни одной строки,
   то есть подходящих записей не существует.

10. Коррелированный подзапрос — подзапрос, который ссылается на столбцы
    внешнего запроса и вычисляется заново для каждой его строки.

11. Обычный подзапрос независим: его можно выполнить отдельно, и он
    вычисляется один раз. Коррелированный зависит от текущей строки
    внешнего запроса и отдельно выполнен быть не может.

12. Когда одна таблица используется и во внешнем, и во внутреннем запросе
    (например, students AS s и students AS s2), нужны псевдонимы, чтобы
    различать столбцы (s.group_id и s2.group_id) и однозначно указать,
    к какой строке относится ссылка.

13. Да, в одном запросе может быть несколько подзапросов (в разных
    условиях, объединённых через AND/OR, или вложенных друг в друга) —
    как в задании 14 и итоговом задании 16.

14. Подзапрос с AVG() удобен, когда нужно сравнить значение с
    агрегатом: со средним по всем записям или по группе
    (оценка выше среднего, возраст выше среднего и т. п.).

15. EXISTS удобен, когда нужно проверить наличие связанных записей
    (есть ли в группе студенты, есть ли отличники) и когда нужны только
    факты наличия, а не значения. NOT EXISTS — для проверки отсутствия.
    Также он безопаснее NOT IN при наличии NULL.

16. Подзапрос становится зависимым, когда в его условии (WHERE) есть
    ссылка на столбец внешнего запроса, например s2.group_id = s.group_id.
==============================================================*/

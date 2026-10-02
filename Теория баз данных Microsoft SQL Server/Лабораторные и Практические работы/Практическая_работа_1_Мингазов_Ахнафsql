/*==============================================================
  Практическая работа №1. T-SQL: переменные, условия и вычисления
  Студент: Фамилия Имя
  База данных: CollegeDB, таблица: college.students
==============================================================*/

USE CollegeDB;
GO
SET NOCOUNT ON;
GO

-- Проверка наличия данных
SELECT * FROM college.students;
GO

-- Если таблица пустая, добавляем тестовых студентов
IF NOT EXISTS (SELECT 1 FROM college.students)
BEGIN
    INSERT INTO college.students (name, age, average_grade)
    VALUES
        (N'Иван',    18, 4.7),
        (N'Мария',   17, 4.2),
        (N'Алексей', 18, 3.6),
        (N'Анна',    19, 4.9),
        (N'Дмитрий', 17, 2.8);
END
GO

/*==============================================================
  БЛОК 1. РАБОТА С ПЕРЕМЕННЫМИ
==============================================================*/

-- Задание 1. Создание переменной
DECLARE @age INT = 18;
SELECT @age AS age;
GO

-- Задание 2. Изменение значения
DECLARE @age INT = 18;
SET @age = 19;
SELECT @age AS age;
GO

-- Задание 3. Несколько переменных
DECLARE @name         NVARCHAR(100) = N'Иван';
DECLARE @age          INT           = 18;
DECLARE @averageGrade DECIMAL(3,2)  = 4.70;

SELECT @name         AS name,
       @age          AS age,
       @averageGrade AS average_grade;
GO

/*==============================================================
  БЛОК 2. ПОЛУЧЕНИЕ ДАННЫХ ИЗ ТАБЛИЦЫ
==============================================================*/

-- Задание 4. Получаем имя студента
DECLARE @studentName NVARCHAR(100);

SELECT @studentName = name
FROM college.students
WHERE id = 1;

SELECT @studentName AS student_name;
GO

-- Задание 5. Получаем несколько значений одним SELECT
DECLARE @studentName  NVARCHAR(100);
DECLARE @studentAge   INT;
DECLARE @studentGrade DECIMAL(3,2);

SELECT @studentName  = name,
       @studentAge   = age,
       @studentGrade = average_grade
FROM college.students
WHERE id = 1;

SELECT @studentName  AS name,
       @studentAge   AS age,
       @studentGrade AS average_grade;
GO

-- Задание 6. Количество студентов
DECLARE @studentCount INT;

SELECT @studentCount = COUNT(*)
FROM college.students;

SELECT @studentCount AS student_count;
GO

/*==============================================================
  БЛОК 3. АРИФМЕТИЧЕСКИЕ ВЫЧИСЛЕНИЯ
==============================================================*/

-- Задание 7. Расчёт возраста
DECLARE @age INT = 18;

SELECT @age     AS current_age,
       @age + 5 AS future_age;
GO

-- Задание 8. Расчёт среднего значения
-- 8.1. Целочисленные переменные: деление нацело (результат 4, дробная часть теряется)
DECLARE @grade1 INT = 5;
DECLARE @grade2 INT = 4;
DECLARE @grade3 INT = 4;

SELECT (@grade1 + @grade2 + @grade3) / 3 AS average_int;
GO

-- 8.2. DECIMAL: результат с дробной частью (4.333333)
DECLARE @grade1 DECIMAL(4,2) = 5;
DECLARE @grade2 DECIMAL(4,2) = 4;
DECLARE @grade3 DECIMAL(4,2) = 4;

SELECT (@grade1 + @grade2 + @grade3) / 3 AS average_decimal;
GO

-- Задание 9. Расчёт скидки
DECLARE @price      DECIMAL(10,2) = 1500;
DECLARE @discount   INT           = 10;
DECLARE @finalPrice DECIMAL(10,2);

SET @finalPrice = @price - (@price * @discount / 100);

PRINT N'Цена:          ' + CAST(@price AS NVARCHAR(20));
PRINT N'Скидка:        ' + CAST(@discount AS NVARCHAR(10)) + N'%';
PRINT N'Итоговая цена: ' + CAST(@finalPrice AS NVARCHAR(20));
GO

/*==============================================================
  БЛОК 4. IF ... ELSE
==============================================================*/

-- Задание 10. Проверка возраста
DECLARE @age INT = 18;

IF @age >= 18
    PRINT N'Совершеннолетний';
ELSE
    PRINT N'Несовершеннолетний';
GO

-- Задание 11. Проверка оценки
DECLARE @grade DECIMAL(3,2) = 3.5;

IF @grade >= 3
    PRINT N'Студент успевает';
ELSE
    PRINT N'Есть задолженность';
GO

-- Задание 12. Проверка стоимости
DECLARE @price DECIMAL(10,2) = 6000;

IF @price >= 5000
    PRINT N'Большая покупка';
ELSE
    PRINT N'Обычная покупка';
GO

/*==============================================================
  БЛОК 5. НЕСКОЛЬКО УСЛОВИЙ
==============================================================*/

-- Задание 13. Возрастная категория
DECLARE @age INT = 18;

IF @age < 18
    PRINT N'Несовершеннолетний';
ELSE IF @age BETWEEN 18 AND 19
    PRINT N'18–19 лет';
ELSE
    PRINT N'20+';
GO

-- Задание 14. Результат обучения
DECLARE @averageGrade DECIMAL(3,2) = 4.70;

IF @averageGrade >= 4.5
    PRINT N'Отличник';
ELSE IF @averageGrade >= 3.5
    PRINT N'Хорошист';
ELSE IF @averageGrade >= 3.0
    PRINT N'Успевает';
ELSE
    PRINT N'Есть задолженности';
GO

/*==============================================================
  БЛОК 6. CASE
==============================================================*/

-- Задание 15. Возрастная группа
SELECT
    name,
    age,
    CASE
        WHEN age < 18             THEN N'Младше 18'
        WHEN age BETWEEN 18 AND 19 THEN N'18–19 лет'
        ELSE                           N'20+'
    END AS age_group
FROM college.students;
GO

-- Задание 16. Результат обучения
SELECT
    name,
    average_grade,
    CASE
        WHEN average_grade >= 4.5 THEN N'Отличник'
        WHEN average_grade >= 3.5 THEN N'Хорошист'
        WHEN average_grade >= 3.0 THEN N'Успевает'
        ELSE                           N'Есть задолженности'
    END AS result
FROM college.students;
GO

-- Задание 17. Совершеннолетие
SELECT
    name,
    age,
    CASE
        WHEN age >= 18 THEN N'Совершеннолетний'
        ELSE                N'Несовершеннолетний'
    END AS age_status
FROM college.students;
GO

/*==============================================================
  БЛОК 7. РАБОТА С ДАННЫМИ ТАБЛИЦЫ
==============================================================*/

-- Задание 18. Средний балл группы
DECLARE @averageGroupGrade DECIMAL(3,2);

SELECT @averageGroupGrade = AVG(average_grade)
FROM college.students;

SELECT @averageGroupGrade AS average_group_grade;
GO

-- Задание 19. Проверка результатов группы
DECLARE @averageGroupGrade DECIMAL(3,2);

SELECT @averageGroupGrade = AVG(average_grade)
FROM college.students;

IF @averageGroupGrade >= 4.5
    PRINT N'Группа показывает отличный результат';
ELSE IF @averageGroupGrade >= 3.5
    PRINT N'Группа показывает хороший результат';
ELSE IF @averageGroupGrade >= 3.0
    PRINT N'Группа успевает';
ELSE
    PRINT N'Группе необходимо улучшить результаты';
GO

/*==============================================================
  БЛОК 8. ИТОГОВОЕ ЗАДАНИЕ
  Задание 20. Анализ студента
==============================================================*/

DECLARE @studentId    INT = 1;        -- id выбранного студента (можно изменить)
DECLARE @studentName  NVARCHAR(100);
DECLARE @studentAge   INT;
DECLARE @studentGrade DECIMAL(3,2);
DECLARE @ageGroup     NVARCHAR(30);
DECLARE @result       NVARCHAR(30);

-- Получаем данные студента
SELECT @studentName  = name,
       @studentAge   = age,
       @studentGrade = average_grade
FROM college.students
WHERE id = @studentId;

IF @studentName IS NULL
BEGIN
    PRINT N'Студент с id = ' + CAST(@studentId AS NVARCHAR(10)) + N' не найден';
END
ELSE
BEGIN
    -- Возрастная категория
    SET @ageGroup = CASE
                        WHEN @studentAge < 18              THEN N'Младше 18'
                        WHEN @studentAge BETWEEN 18 AND 19 THEN N'18–19 лет'
                        ELSE                                    N'20+'
                    END;

    -- Результат обучения
    SET @result = CASE
                      WHEN @studentGrade >= 4.5 THEN N'Отличник'
                      WHEN @studentGrade >= 3.5 THEN N'Хорошист'
                      WHEN @studentGrade >= 3.0 THEN N'Успевает'
                      ELSE                           N'Есть задолженности'
                  END;

    -- Вывод информации
    PRINT N'-----------------------------------';
    PRINT N'Информация о студенте';
    PRINT N'-----------------------------------';
    PRINT N'';
    PRINT N'Имя: '              + @studentName;
    PRINT N'Возраст: '          + CAST(@studentAge   AS NVARCHAR(10));
    PRINT N'Возрастная группа: ' + @ageGroup;
    PRINT N'Средний балл: '     + CAST(@studentGrade AS NVARCHAR(10));
    PRINT N'Результат: '        + @result;
END
GO

/*==============================================================
  ОТВЕТЫ НА КОНТРОЛЬНЫЕ ВОПРОСЫ
==============================================================

1. DECLARE объявляет переменную: задаёт её имя (с @), тип данных и,
   при желании, начальное значение. Пример: DECLARE @age INT = 18;

2. SET присваивает (или изменяет) значение уже объявленной переменной.
   Пример: SET @age = 19;

3. Через SELECT: SELECT @name = name FROM college.students WHERE id = 1;
   Либо через подзапрос: SET @name = (SELECT name FROM ... WHERE id = 1);
   Запрос должен возвращать одну строку: если строк несколько, в
   переменную попадёт значение последней обработанной.

4. Переменные хранят промежуточные значения и результаты запросов,
   позволяют переиспользовать их в вычислениях, условиях и выводе,
   делают скрипт читаемым и параметризуемым.

5. IF — управляющая конструкция: выбирает, какой оператор или блок
   выполнить. CASE — выражение: возвращает значение и используется
   внутри SELECT, SET, ORDER BY и т. д. (в том числе построчно).

6. ELSE IF проверяет следующее условие, если предыдущее оказалось
   ложным, — так строится цепочка из нескольких взаимоисключающих веток.

7. Несколько условий проверяют через ELSE IF / вложенные IF, через
   несколько WHEN в CASE, а также объединяя условия с помощью AND, OR, NOT.

8. AND — логическое «И»: результат истинен, только если истинны оба условия.
   Пример: age >= 18 AND average_grade >= 4.5

9. OR — логическое «ИЛИ»: результат истинен, если истинно хотя бы одно
   условие. Пример: age < 18 OR average_grade < 3.0

10. CASE проверяет условия сверху вниз и возвращает результат первого
    выполнившегося WHEN. Если порядок неверный (например, сначала
    average_grade >= 3.0), более широкое условие «перехватит» значения,
    которые должны попасть в более узкую ветку (4.8 станет «Успевает»,
    а не «Отличник»).

11. Если ни одно WHEN не выполнилось и ELSE нет, CASE вернёт NULL.

12. ELSE задаёт значение по умолчанию для всех случаев, не подошедших
    под WHEN, и защищает от неожиданных NULL.

13. Арифметическое выражение — комбинация значений, переменных, столбцов
    и операторов (+, -, *, /, %), которая вычисляется в одно значение.
    Пример: @price - (@price * @discount / 100)

14. Если оба операнда целые (INT), деление целочисленное: 10 / 3 = 3,
    дробная часть отбрасывается. Для 3.33 нужно привести хотя бы один
    операнд к DECIMAL: 10 / 3.0 или CAST(10 AS DECIMAL(5,2)) / 3.

15. DECIMAL(p, s) — тип точных чисел с фиксированной дробной частью
    (p — общее число цифр, s — число знаков после запятой). Нужен для
    оценок, цен и других значений, где важны дробная часть и точность.

16. CAST() и CONVERT() явно преобразуют значение из одного типа в
    другой: CAST(@x AS NVARCHAR(10)), CONVERT(NVARCHAR(10), @x).
    CAST соответствует стандарту SQL, CONVERT — специфична для T-SQL и
    имеет параметр стиля (удобно для форматирования дат).
==============================================================*/

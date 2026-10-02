/*==============================================================
  Практическая работа №3. SQL-квест: исследование иерархии с помощью CTE
  Студент: Мингазов Ахнаф
  База данных: CollegeDB, схема: game
==============================================================*/

USE CollegeDB;
GO

/*==============================================================
  СТРУКТУРА БАЗЫ И ИСХОДНЫЕ ДАННЫЕ
  Скрипт можно запускать повторно: таблица пересоздаётся.
==============================================================*/

-- Схема game (создаём, только если её ещё нет)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'game')
    EXEC (N'CREATE SCHEMA game');
GO

-- Таблица локаций
DROP TABLE IF EXISTS game.locations;
GO

CREATE TABLE game.locations
(
    id            INT           PRIMARY KEY,
    name          NVARCHAR(100) NOT NULL,
    parent_id     INT           NULL,          -- NULL = корневая локация
    location_type NVARCHAR(50)  NOT NULL,
    difficulty    INT           NOT NULL,
    reward        INT           NOT NULL,
    CONSTRAINT FK_locations_parent
        FOREIGN KEY (parent_id) REFERENCES game.locations (id)
);
GO

-- Заполнение игрового мира
INSERT INTO game.locations
    (id, name, parent_id, location_type, difficulty, reward)
VALUES
    (1,  N'Королевство',     NULL, N'Мир',        1,  0),

    (2,  N'Северные земли',  1,    N'Регион',     2,  0),
    (3,  N'Южные земли',     1,    N'Регион',     2,  0),

    (4,  N'Лес',             2,    N'Локация',    3,  100),
    (5,  N'Горная крепость', 2,    N'Локация',    5,  300),

    (6,  N'Древние руины',   4,    N'Подземелье', 6,  500),
    (7,  N'Логово волков',   4,    N'Подземелье', 4,  250),
    (8,  N'Пещера дракона',  5,    N'Подземелье', 10, 1000),

    (9,  N'Пустыня',         3,    N'Локация',    3,  100),
    (10, N'Город',           3,    N'Локация',    2,  50),

    (11, N'Храм песков',     9,    N'Подземелье', 7,  600),
    (12, N'Таверна',         10,   N'Здание',     1,  20),
    (13, N'Рынок',           10,   N'Здание',     1,  30);
GO

-- Проверка данных
SELECT * FROM game.locations;
GO

/*==============================================================
-- Блок 1. Карта игрового мира
   Обычный CTE: локации со сложностью 5 и выше
==============================================================*/
WITH DangerousLocations AS
(
    SELECT
        id,
        name,
        difficulty,
        reward
    FROM game.locations
    WHERE difficulty >= 5
)
SELECT *
FROM DangerousLocations;
GO

/*==============================================================
-- Блок 2. Статистика игрового мира
   CTE LocationStatistics считает по каждой родительской локации:
   количество прямых дочерних, среднюю сложность и макс. награду.
   Рекурсия не нужна. Как в примере из задания, выводим локации
   типа «Локация» (Лес, Горная крепость, Пустыня, Город).
   Чтобы увидеть все локации, имеющие потомков, уберите условие
   WHERE l.location_type = N'Локация'.
==============================================================*/
WITH LocationStatistics AS
(
    SELECT
        parent_id,
        COUNT(*)                                              AS child_count,
        CAST(AVG(CAST(difficulty AS DECIMAL(5,2))) AS DECIMAL(4,2)) AS avg_difficulty,
        MAX(reward)                                           AS max_reward
    FROM game.locations
    WHERE parent_id IS NOT NULL
    GROUP BY parent_id
)
SELECT
    l.name             AS [Локация],
    s.child_count      AS [Количество дочерних],
    s.avg_difficulty   AS [Средняя сложность],
    s.max_reward       AS [Максимальная награда]
FROM game.locations AS l
JOIN LocationStatistics AS s ON s.parent_id = l.id
WHERE l.location_type = N'Локация'
ORDER BY l.id;
GO

/*==============================================================
-- Блок 3. Поиск опасных зон
   Регионы, внутри которых есть локация со сложностью >= 7.
   «Внутри» = на любой глубине вложенности (а не только прямые
   дети): среди прямых детей регионов максимум 5, поэтому
   потомков собираем рекурсивным CTE RegionTree, затем
   JOIN + GROUP BY + MAX + HAVING.
==============================================================*/
WITH RegionTree AS
(
    -- Якорь: каждый регион — корень своей ветки
    SELECT
        id AS root_id,
        id,
        difficulty,
        0  AS [level]
    FROM game.locations
    WHERE location_type = N'Регион'

    UNION ALL

    -- Рекурсия: все вложенные локации региона
    SELECT
        t.root_id,
        c.id,
        c.difficulty,
        t.[level] + 1
    FROM game.locations AS c
    JOIN RegionTree     AS t ON c.parent_id = t.id
)
SELECT
    r.name              AS [Регион],
    r.difficulty        AS [Сложность региона],
    MAX(t.difficulty)   AS [Макс. сложность внутри]
FROM game.locations AS r
JOIN RegionTree     AS t ON t.root_id = r.id
WHERE t.[level] > 0                    -- сам регион не учитываем
GROUP BY r.id, r.name, r.difficulty
HAVING MAX(t.difficulty) >= 7;
GO

/*==============================================================
-- Блок 4. Начинаем строить навигатор
   Рекурсивный CTE LocationTree: ветка, начиная с «Северные земли»
==============================================================*/
WITH LocationTree AS
(
    -- Начальная локация
    SELECT id, name, parent_id
    FROM game.locations
    WHERE name = N'Северные земли'

    UNION ALL

    -- Поиск дочерних локаций (child.parent_id = parent.id)
    SELECT child.id, child.name, child.parent_id
    FROM game.locations AS child
    JOIN LocationTree   AS parent ON child.parent_id = parent.id
)
SELECT *
FROM LocationTree;
GO

/*==============================================================
-- Блок 5. Определяем уровень локации
   Добавляем столбец level: 0 для начальной, level + 1 для потомков
==============================================================*/
WITH LocationTree AS
(
    SELECT id, name, parent_id, 0 AS [level]
    FROM game.locations
    WHERE name = N'Северные земли'

    UNION ALL

    SELECT child.id, child.name, child.parent_id, parent.[level] + 1
    FROM game.locations AS child
    JOIN LocationTree   AS parent ON child.parent_id = parent.id
)
SELECT
    name      AS [Локация],
    [level]   AS [Уровень]
FROM LocationTree
ORDER BY [level], id;
GO

/*==============================================================
-- Блок 6. Игровой радар
   Все локации внутри текущей области: уровень, тип, сложность, награда
==============================================================*/
WITH LocationTree AS
(
    SELECT id, name, parent_id, location_type, difficulty, reward,
           0 AS [level]
    FROM game.locations
    WHERE name = N'Северные земли'

    UNION ALL

    SELECT child.id, child.name, child.parent_id, child.location_type,
           child.difficulty, child.reward, parent.[level] + 1
    FROM game.locations AS child
    JOIN LocationTree   AS parent ON child.parent_id = parent.id
)
SELECT
    name          AS [Локация],
    [level]       AS [Уровень],
    location_type AS [Тип],
    difficulty    AS [Сложность],
    reward        AS [Награда]
FROM LocationTree
ORDER BY [level], id;
GO

/*==============================================================
-- Блок 7. Поиск максимальной награды
   Самая ценная локация в ветке «Северные земли»:
   1) дерево локаций, 2) MAX(reward), 3) соответствующая локация
==============================================================*/
WITH LocationTree AS
(
    SELECT id, name, parent_id, difficulty, reward
    FROM game.locations
    WHERE name = N'Северные земли'

    UNION ALL

    SELECT child.id, child.name, child.parent_id, child.difficulty, child.reward
    FROM game.locations AS child
    JOIN LocationTree   AS parent ON child.parent_id = parent.id
),
MaxReward AS
(
    SELECT MAX(reward) AS max_reward
    FROM LocationTree
)
SELECT
    t.name       AS [Название локации],
    t.reward     AS [Награда],
    t.difficulty AS [Сложность]
FROM LocationTree AS t
JOIN MaxReward    AS m ON t.reward = m.max_reward;
GO

/*==============================================================
-- Блок 8. SQL-карта мира
   display_name — название с отступом по уровню.
   sort_path — путь из id (с ведущими нулями): сортировка по нему
   выводит локации именно в порядке обхода дерева
   (родитель, затем все его потомки).
==============================================================*/
WITH LocationTree AS
(
    SELECT
        id, name, parent_id,
        0 AS [level],
        CAST(RIGHT(N'0000' + CAST(id AS NVARCHAR(10)), 4) AS NVARCHAR(900)) AS sort_path
    FROM game.locations
    WHERE name = N'Северные земли'

    UNION ALL

    SELECT
        child.id, child.name, child.parent_id,
        parent.[level] + 1,
        CAST(parent.sort_path + N'/' + RIGHT(N'0000' + CAST(child.id AS NVARCHAR(10)), 4) AS NVARCHAR(900))
    FROM game.locations AS child
    JOIN LocationTree   AS parent ON child.parent_id = parent.id
)
SELECT
    REPLICATE(N'    ', [level]) + name AS display_name
FROM LocationTree
ORDER BY sort_path;
GO

/*==============================================================
-- Финальный блок. «Исследование подземелья»
   Один итоговый запрос: полная карта мира, начиная с «Королевство».
   Название, тип, уровень, сложность, награда, название в виде дерева.
==============================================================*/
WITH LocationTree AS
(
    -- Начальная локация: корень мира
    SELECT
        id, name, parent_id, location_type, difficulty, reward,
        0 AS [level],
        CAST(RIGHT(N'0000' + CAST(id AS NVARCHAR(10)), 4) AS NVARCHAR(900)) AS sort_path
    FROM game.locations
    WHERE name = N'Королевство'

    UNION ALL

    -- Дочерние локации
    SELECT
        child.id, child.name, child.parent_id, child.location_type,
        child.difficulty, child.reward,
        parent.[level] + 1,
        CAST(parent.sort_path + N'/' + RIGHT(N'0000' + CAST(child.id AS NVARCHAR(10)), 4) AS NVARCHAR(900))
    FROM game.locations AS child
    JOIN LocationTree   AS parent ON child.parent_id = parent.id
)
SELECT
    REPLICATE(N'    ', [level]) + name AS display_name,
    location_type                      AS [Тип],
    [level]                            AS [Уровень],
    difficulty                         AS [Сложность],
    reward                             AS [Награда]
FROM LocationTree
ORDER BY sort_path
OPTION (MAXRECURSION 100);   -- защита от зацикливания данных
GO

/*==============================================================
-- Дополнительная миссия. Определение опасности локации (CASE)
   1–3 Безопасная, 4–6 Опасная, 7–9 Очень опасная, 10 Босс
==============================================================*/
WITH LocationTree AS
(
    SELECT
        id, name, parent_id, location_type, difficulty, reward,
        0 AS [level],
        CAST(RIGHT(N'0000' + CAST(id AS NVARCHAR(10)), 4) AS NVARCHAR(900)) AS sort_path
    FROM game.locations
    WHERE name = N'Королевство'

    UNION ALL

    SELECT
        child.id, child.name, child.parent_id, child.location_type,
        child.difficulty, child.reward,
        parent.[level] + 1,
        CAST(parent.sort_path + N'/' + RIGHT(N'0000' + CAST(child.id AS NVARCHAR(10)), 4) AS NVARCHAR(900))
    FROM game.locations AS child
    JOIN LocationTree   AS parent ON child.parent_id = parent.id
)
SELECT
    REPLICATE(N'    ', [level]) + name AS display_name,
    location_type                      AS [Тип],
    [level]                            AS [Уровень],
    difficulty                         AS [Сложность],
    reward                             AS [Награда],
    CASE
        WHEN difficulty <= 3 THEN N'Безопасная'
        WHEN difficulty <= 6 THEN N'Опасная'
        WHEN difficulty <= 9 THEN N'Очень опасная'
        ELSE                      N'Босс'
    END                                AS danger_level
FROM LocationTree
ORDER BY sort_path
OPTION (MAXRECURSION 100);
GO

/*==============================================================
-- Бонусная миссия. Суммарная награда всех дочерних локаций
   Для каждой локации: рекурсивно собираем всех её потомков
   (root_id — «корень» ветки) и суммируем награды (сам корень
   не учитывается).
==============================================================*/
WITH BranchTree AS
(
    -- Якорь: каждая локация — корень своей ветки
    SELECT
        id AS root_id,
        id,
        reward,
        0  AS [level]
    FROM game.locations

    UNION ALL

    SELECT
        b.root_id,
        c.id,
        c.reward,
        b.[level] + 1
    FROM game.locations AS c
    JOIN BranchTree     AS b ON c.parent_id = b.id
)
SELECT
    l.name AS [Локация],
    SUM(CASE WHEN b.[level] > 0 THEN b.reward ELSE 0 END) AS [Суммарная награда потомков]
FROM game.locations AS l
JOIN BranchTree     AS b ON b.root_id = l.id
GROUP BY l.id, l.name
ORDER BY l.id
OPTION (MAXRECURSION 100);
GO

-- Бонус: разбивка по ветке «Лес» с итогом (ожидается Итого: 750)
WITH LocationTree AS
(
    SELECT id, name, reward, 0 AS [level]
    FROM game.locations
    WHERE name = N'Лес'

    UNION ALL

    SELECT child.id, child.name, child.reward, parent.[level] + 1
    FROM game.locations AS child
    JOIN LocationTree   AS parent ON child.parent_id = parent.id
)
SELECT name AS [Локация], reward AS [Награда]
FROM LocationTree
WHERE [level] > 0
UNION ALL
SELECT N'Итого:', SUM(reward)
FROM LocationTree
WHERE [level] > 0;
GO

/*==============================================================
  ОТВЕТЫ НА ВОПРОСЫ ДЛЯ САМОПРОВЕРКИ
==============================================================

1. CTE (Common Table Expression, обобщённое табличное выражение) —
   именованный временный результат запроса, который существует только
   на время выполнения одного оператора (SELECT/INSERT/UPDATE/DELETE).

2. WITH вводит CTE: задаёт ему имя (и при необходимости список столбцов)
   и запрос, результат которого затем используется в основном запросе.

3. CTE не хранится в базе и не занимает места: это не объект БД, а
   часть одного запроса, действует только в нём. Таблица (обычная или
   временная) создаётся командой CREATE TABLE / #temp, хранит данные
   и может использоваться в разных запросах.

4. CTE оправдан, когда нужно разбить сложный запрос на читаемые шаги,
   не повторять один и тот же подзапрос несколько раз, использовать
   результат агрегации как источник для дальнейших вычислений и,
   главное, при обходе иерархий (рекурсия).

5. Да. CTE перечисляются через запятую после одного WITH, и последующие
   могут ссылаться на предыдущие (как LocationTree и MaxReward в блоке 7).

6. Рекурсивный CTE — это CTE, который ссылается сам на себя и поэтому
   может шаг за шагом обходить иерархические данные (деревья, графы).

7. Из двух частей, соединённых UNION ALL: якорной (начальной) части и
   рекурсивной части, которая обращается к самому CTE.

8. UNION ALL объединяет результат якорной части с результатами каждого
   шага рекурсии без удаления дубликатов (и без лишней сортировки).
   Это обязательный оператор между якорем и рекурсивной частью.

9. Начальная (якорная) часть — запрос, не обращающийся к CTE; он
   выполняется один раз и задаёт стартовые строки (например,
   «Северные земли» или корень parent_id IS NULL).

10. Рекурсивная часть — запрос, который JOIN-ом обращается к самому CTE
    и на каждом шаге находит строки следующего уровня (потомков тех
    строк, что получены на предыдущем шаге).

11. По условию соединения: child.parent_id = parent.id — строка является
    дочерней, если её parent_id равен id уже найденной строки.

12. parent_id хранит ссылку на id родительской записи и задаёт структуру
    дерева. У корня parent_id = NULL.

13. Добавить в CTE столбец level: в якоре 0, в рекурсивной части
    parent.level + 1.

14. Без условия завершения рекурсия могла бы продолжаться бесконечно
    (например, при цикле в данных). Естественное условие завершения —
    рекурсивная часть перестаёт возвращать строки (у листьев нет детей);
    дополнительно можно ограничить глубину условием по level.

15. OPTION (MAXRECURSION n) ограничивает число шагов рекурсии
    (по умолчанию 100; 0 — без ограничения). Это защита от зацикливания:
    при превышении запрос завершается ошибкой.

16. Иерархия категорий товаров, организационная структура компании
    (руководитель—подчинённый), файловая система (папки), комментарии
    с ответами, меню сайта, административно-территориальное деление,
    состав изделия (BOM), игровые карты, как в этой работе.
==============================================================*/

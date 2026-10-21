# 03. Выполнение SQL-запросов с помощью SqlCommand

Источник: `Выполнение SQL-запросов с помощью SqlCommand.pdf`.

## Краткий конспект

SqlCommand создаёт описание операции, но не выполняет её в конструкторе. ExecuteNonQuery выполняет команду без чтения набора строк, ExecuteScalar получает одно значение, ExecuteReader открывает последовательное чтение результата.

INSERT/UPDATE/DELETE обычно выполняют через ExecuteNonQuery, COUNT/MAX/DB_NAME — через ExecuteScalar, список товаров — через ExecuteReader. Выбор определяется необходимым результатом: INSERT с OUTPUT может потребовать ExecuteReader. Одно открытое соединение можно последовательно использовать для нескольких команд; активный reader следует закрыть перед следующей командой.

## Вопросы из лекции

1. Для чего используется SqlCommand?

2. Выполняется ли SQL запрос сразу после создания SqlCommand?

3. Для чего используется ExecuteNonQuery()?

4. Что возвращает ExecuteNonQuery()?

5. В каких ситуациях удобно использовать ExecuteScalar()?

6. Чем ExecuteScalar() отличается от ExecuteReader()?

7. Какой метод следует использовать для INSERT?

8. Какой метод использовать для SELECT COUNT(*)?

9. Какой метод использовать для получения списка товаров ?

10. Зачем одному SqlConnection может соответствовать несколько SqlCommand?

## Ответы по порядку

1. Для подготовки и выполнения SQL-команд на соединении с SQL Server.

2. Нет, выполнение начинается при вызове ExecuteNonQuery, ExecuteScalar, ExecuteReader или их асинхронных аналогов.

3. Для выполнения команды, когда набор строк не нужен, например UPDATE.

4. Обычно количество затронутых строк DML; для других команд или при SET NOCOUNT ON результат может быть -1. Триггеры также могут влиять на счётчик.

5. Для COUNT, MAX, DB_NAME и других запросов с одним нужным значением.

6. Scalar возвращает одно значение; Reader — объект для чтения строк и столбцов.

7. Обычный INSERT без возвращаемого результата — ExecuteNonQuery.

8. ExecuteScalar.

9. ExecuteReader.

10. Разные операции используют один сеанс; повторно открывать соединение для каждой последовательной команды не требуется.

## Выполненная практическая часть

Все семь операций из самостоятельного задания реализованы в Program.cs. Учебные изменения выполняются в транзакции и откатываются; счётчик IDENTITY при откате не восстанавливается.

| Операция | SQL | Метод |
|---|---|---|
| Добавить товар | `INSERT INTO products(name, price, is_available) VALUES(N'Учебный товар', 150, 1)` | ExecuteNonQuery |
| Количество клиентов | `SELECT COUNT(*) FROM customers` | ExecuteScalar |
| Максимальная цена | `SELECT MAX(price) FROM products` | ExecuteScalar |
| Список товаров | `SELECT id, name, price FROM products ORDER BY id` | ExecuteReader |
| Изменить цену | `UPDATE products SET price = 175 WHERE id = @id` | ExecuteNonQuery |
| Удалить товар | `DELETE FROM products WHERE id = @id` | ExecuteNonQuery |
| Название базы | `SELECT DB_NAME()` | ExecuteScalar |

Исходный код: [Program.cs](Program.cs). Общая конфигурация и обработка ошибок: [Db.cs](../Shared/Db.cs).

Запуск из папки «Домашние задания»:

```powershell
dotnet run --project "03_SqlCommand/Homework.csproj"
```

Для подключения сначала выполните настройку из [общей инструкции](../README.md).

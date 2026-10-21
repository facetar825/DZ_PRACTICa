using System.Data;
using Microsoft.Data.SqlClient;

PracticeSupport.ConsoleEncoding();
try
{
    using var configuration = PracticeSupport.LoadConfiguration();
    string connectionString = PracticeSupport.ConnectionString(configuration);
    await PracticeSupport.MenuAsync("Асинхронный каталог кофейни", """
        1. Все товары
        2. Только доступные товары
        3. Поиск по части названия
        4. Число клиентов
        5. Изменить доступность товара
        6. Количество товаров (отмена через 5 секунд)
        7. Товары с ценой от заданной
        8. Заказы выбранного клиента (JOIN)
        """, async choice =>
    {
        switch (choice)
        {
            case "1": await Timed(token => ShowProductsAsync(connectionString, token)); break;
            case "2": await Timed(token => ReadProductsAsync(connectionString, "WHERE is_available = 1 ORDER BY name, id", null, token)); break;
            case "3":
                string search = PracticeSupport.Text("Часть названия: ");
                await Timed(token => ReadProductsAsync(connectionString, "WHERE name LIKE @search ORDER BY name, id", c => c.Parameters.Add("@search", SqlDbType.NVarChar, 302).Value = "%" + search + "%", token));
                break;
            case "4": await Timed(async token => Console.WriteLine($"Клиентов: {await CountAsync(connectionString, "SELECT COUNT(*) FROM customers", token)}")); break;
            case "5":
                int id = PracticeSupport.Id("ID товара: ");
                bool available = PracticeSupport.Bool("Доступен (1/0): ");
                await Timed(token => UpdateProductAvailabilityAsync(connectionString, id, available, token));
                break;
            case "6": await Timed(async token => Console.WriteLine($"Количество товаров: {await GetProductCountAsync(connectionString, token)}")); break;
            case "7":
                decimal minPrice = PracticeSupport.Price("Минимальная цена: ");
                await Timed(token => ShowProductsFromPriceAsync(connectionString, minPrice, token));
                break;
            case "8":
                int customer = PracticeSupport.Id("ID клиента: ");
                await Timed(token => GetCustomerOrdersAsync(connectionString, customer, token));
                break;
            default: throw new ArgumentException("Неизвестный пункт меню.");
        }
    });
    return 0;
}
catch (Exception ex) when (PracticeSupport.KnownError(ex)) { PracticeSupport.Error(ex); return 1; }

static async Task Timed(Func<CancellationToken, Task> operation)
{
    using CancellationTokenSource source = new();
    source.CancelAfter(TimeSpan.FromSeconds(5));
    await operation(source.Token);
}

static Task<int> GetProductCountAsync(string connectionString, CancellationToken token = default)
    => CountAsync(connectionString, "SELECT COUNT(*) FROM products", token);

static async Task<int> CountAsync(string connectionString, string sql, CancellationToken token)
{
    await using SqlConnection connection = new(connectionString);
    await connection.OpenAsync(token);
    using SqlCommand command = new(sql, connection);
    return (int)(await command.ExecuteScalarAsync(token))!;
}

static Task ShowProductsAsync(string connectionString, CancellationToken token = default)
    => ReadProductsAsync(connectionString, "ORDER BY name, id", null, token);

static Task ShowProductsFromPriceAsync(string connectionString, decimal minPrice, CancellationToken token = default)
    => ReadProductsAsync(connectionString, "WHERE price >= @min_price ORDER BY price, id", c =>
    {
        SqlParameter parameter = c.Parameters.Add("@min_price", SqlDbType.Decimal);
        parameter.Precision = 10; parameter.Scale = 2; parameter.Value = minPrice;
    }, token);

static async Task ReadProductsAsync(string connectionString, string clause, Action<SqlCommand>? parameters, CancellationToken token)
{
    // clause выбирается только из фиксированных вариантов в коде, ввод идёт в параметры.
    await using SqlConnection connection = new(connectionString);
    await connection.OpenAsync(token);
    using SqlCommand command = new("SELECT id, name, price, is_available FROM products " + clause, connection);
    parameters?.Invoke(command);
    await using SqlDataReader reader = await command.ExecuteReaderAsync(token);
    bool found = false;
    while (await reader.ReadAsync(token))
    {
        found = true;
        Console.WriteLine($"{reader.GetInt32(0)}. {reader.GetString(1)} — {reader.GetDecimal(2):F2} руб. | {(reader.GetBoolean(3) ? "Есть" : "Нет")}");
    }
    if (!found) Console.WriteLine("Товары не найдены.");
}

static async Task UpdateProductAvailabilityAsync(string connectionString, int productId, bool isAvailable, CancellationToken token = default)
{
    await using SqlConnection connection = new(connectionString);
    await connection.OpenAsync(token);
    using SqlCommand command = new("UPDATE products SET is_available = @is_available WHERE id = @id", connection);
    command.Parameters.Add("@id", SqlDbType.Int).Value = productId;
    command.Parameters.Add("@is_available", SqlDbType.Bit).Value = isAvailable;
    int count = await command.ExecuteNonQueryAsync(token);
    Console.WriteLine(count == 0 ? "Товар не найден." : $"Изменено строк: {count}");
}

static async Task GetCustomerOrdersAsync(string connectionString, int customerId, CancellationToken token = default)
{
    await using SqlConnection connection = new(connectionString);
    await connection.OpenAsync(token);
    using SqlCommand command = new("""
        SELECT o.id, o.order_date, o.status
        FROM orders AS o JOIN customers AS c ON c.id = o.customer_id
        WHERE c.id = @customer_id ORDER BY o.id;
        """, connection);
    command.Parameters.Add("@customer_id", SqlDbType.Int).Value = customerId;
    await using SqlDataReader reader = await command.ExecuteReaderAsync(token);
    bool found = false;
    while (await reader.ReadAsync(token))
    {
        found = true;
        Console.WriteLine($"Заказ №{reader.GetInt32(0)} | {reader.GetDateTime(1):dd.MM.yyyy HH:mm} | {reader.GetString(2)}");
    }
    if (!found) Console.WriteLine("Заказы клиента не найдены.");
}

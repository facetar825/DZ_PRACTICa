using System.Data;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

PracticeSupport.ConsoleEncoding();
try
{
    using var configuration = PracticeSupport.LoadConfiguration();
    string connectionString = PracticeSupport.ConnectionString(configuration);
    string title = configuration["Application:Title"] ?? "Приложение";
    if (!bool.TryParse(configuration["Application:ShowPrices"], out bool showPrices))
        throw new InvalidOperationException("Application:ShowPrices должен быть true или false.");
    await PracticeSupport.MenuAsync(title, """
        1. Проверить подключение
        2. Статистика: товары, клиенты, заказы
        3. Доступные товары
        4. Поиск по части названия
        5. Настройки приложения
        """, async choice =>
    {
        switch (choice)
        {
            case "1": await CheckConnectionAsync(connectionString); break;
            case "2": await ShowStatisticsAsync(connectionString); break;
            case "3": await ShowCatalogAsync(connectionString, showPrices, null); break;
            case "4": await ShowCatalogAsync(connectionString, showPrices, PracticeSupport.Text("Часть названия: ")); break;
            case "5": Console.WriteLine($"Название: {title}\nПоказывать цены: {showPrices}"); break;
            default: throw new ArgumentException("Неизвестный пункт меню.");
        }
    });
    return 0;
}
catch (Exception ex) when (PracticeSupport.KnownError(ex)) { PracticeSupport.Error(ex); return 1; }

static async Task CheckConnectionAsync(string connectionString)
{
    await using SqlConnection connection = new(connectionString);
    await connection.OpenAsync();
    using SqlCommand command = new("SELECT DB_NAME()", connection);
    Console.WriteLine($"Подключено к базе: {await command.ExecuteScalarAsync()}");
}

static async Task ShowStatisticsAsync(string connectionString)
{
    await using SqlConnection connection = new(connectionString);
    await connection.OpenAsync();
    Console.WriteLine("Статистика кофейни");
    foreach (var (label, sql) in new[]
    {
        ("Товаров", "SELECT COUNT(*) FROM products"),
        ("Клиентов", "SELECT COUNT(*) FROM customers"),
        ("Заказов", "SELECT COUNT(*) FROM orders")
    })
    {
        using SqlCommand command = new(sql, connection);
        Console.WriteLine($"{label}: {await command.ExecuteScalarAsync()}");
    }
}

static async Task ShowCatalogAsync(string connectionString, bool showPrices, string? search)
{
    string sql = search is null
        ? "SELECT name, price FROM products WHERE is_available = 1 ORDER BY name, id"
        : "SELECT name, price FROM products WHERE name LIKE @search ORDER BY name, id";
    await using SqlConnection connection = new(connectionString);
    await connection.OpenAsync();
    using SqlCommand command = new(sql, connection);
    if (search is not null) command.Parameters.Add("@search", SqlDbType.NVarChar, 302).Value = "%" + search + "%";
    await using SqlDataReader reader = await command.ExecuteReaderAsync();
    bool found = false;
    while (await reader.ReadAsync())
    {
        found = true;
        Console.WriteLine(showPrices ? $"{reader.GetString(0)} — {reader.GetDecimal(1):F2} руб." : reader.GetString(0));
    }
    if (!found) Console.WriteLine("Товары не найдены.");
}

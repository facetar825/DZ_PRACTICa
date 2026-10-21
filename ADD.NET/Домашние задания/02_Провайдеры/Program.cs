using Microsoft.Data.SqlClient;

return await Db.Run(() =>
{
    Console.WriteLine("Статистика: 1 — клиенты, 2 — товары, 3 — заказы, 4 — всё");
    string? choice = Console.ReadLine();
    // Имена таблиц берутся только из фиксированного списка, а не из ввода.
    string[] tables = choice switch
    {
        "1" => ["customers"], "2" => ["products"], "3" => ["orders"],
        "4" => ["customers", "products", "orders"],
        _ => throw new ArgumentException("Выберите пункт от 1 до 4.")
    };
    using SqlConnection connection = Db.Connect();
    connection.Open();
    foreach (string table in tables)
    {
        using SqlCommand command = new($"SELECT COUNT(*) FROM dbo.[{table}];", connection);
        Console.WriteLine($"{table}: {command.ExecuteScalar()}");
    }
    return Task.CompletedTask;
});

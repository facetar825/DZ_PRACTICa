using Microsoft.Data.SqlClient;

Console.OutputEncoding = System.Text.Encoding.UTF8;
Db.Guard(() =>
{
    using SqlConnection connection = Db.Open();
    Console.WriteLine("Соединение с базой данных установлено.");
    Console.WriteLine("=== Информация о базе данных ===");
    foreach (var (label, sql) in new[]
    {
        ("База данных", "SELECT DB_NAME();"),
        ("SQL Server", "SELECT @@SERVERNAME;"),
        ("Дата и время сервера", "SELECT GETDATE();"),
        ("Количество товаров", "SELECT COUNT(*) FROM products;"),
        ("Минимальная цена", "SELECT MIN(price) FROM products;"),
        ("Максимальная цена", "SELECT MAX(price) FROM products;"),
        ("Самый дорогой товар", "SELECT TOP (1) name FROM products ORDER BY price DESC, id;")
    })
    {
        using SqlCommand command = new(sql, connection);
        Console.WriteLine($"{label}: {Db.Display(command.ExecuteScalar())}");
    }
});

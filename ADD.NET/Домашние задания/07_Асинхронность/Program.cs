using System.Data;
using Microsoft.Data.SqlClient;

return await Db.Run(async () =>
{
    int id = Db.ReadId("ID товара для асинхронного поиска: ");
    using CancellationTokenSource cts = new(TimeSpan.FromSeconds(5));
    Console.WriteLine($"Доступных товаров: {await GetAvailableProductCountAsync(cts.Token)}");
    Product? product = await GetProductByIdAsync(id, cts.Token);
    Console.WriteLine(product is null ? "Товар не найден." : $"{product.Id}: {product.Name} — {product.Price:F2} руб.");
});

static async Task<int> GetAvailableProductCountAsync(CancellationToken cancellationToken = default)
{
    await using SqlConnection connection = Db.Connect();
    await connection.OpenAsync(cancellationToken);
    using SqlCommand command = new("SELECT COUNT(*) FROM products WHERE is_available = 1;", connection);
    return (int)(await command.ExecuteScalarAsync(cancellationToken))!;
}

static async Task<Product?> GetProductByIdAsync(int id, CancellationToken cancellationToken = default)
{
    await using SqlConnection connection = Db.Connect();
    await connection.OpenAsync(cancellationToken);
    using SqlCommand command = new("SELECT id, name, price FROM products WHERE id = @id;", connection);
    command.Parameters.Add("@id", SqlDbType.Int).Value = id;
    await using SqlDataReader reader = await command.ExecuteReaderAsync(cancellationToken);
    return await reader.ReadAsync(cancellationToken)
        ? new Product(reader.GetInt32(0), reader.GetString(1), reader.GetDecimal(2))
        : null;
}

internal sealed record Product(int Id, string Name, decimal Price);

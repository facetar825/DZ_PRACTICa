using Microsoft.Data.SqlClient;

return await Db.Run(() =>
{
    using SqlConnection connection = Db.Connect();
    connection.Open();
    // Изменения учебного товара откатываются, поэтому повторный запуск безопасен.
    using SqlTransaction transaction = connection.BeginTransaction();
    try
    {
        using SqlCommand insert = new("INSERT INTO products(name, price, is_available) VALUES(N'Учебный товар', 150, 1); SET @newId = CAST(SCOPE_IDENTITY() AS int);", connection, transaction);
        var newId = insert.Parameters.Add("@newId", System.Data.SqlDbType.Int);
        newId.Direction = System.Data.ParameterDirection.Output;
        Console.WriteLine($"INSERT: {insert.ExecuteNonQuery()} строк.");
        int id = (int)newId.Value;
        using SqlCommand count = new("SELECT COUNT(*) FROM customers;", connection, transaction);
        Console.WriteLine($"Клиентов: {count.ExecuteScalar()}");
        using SqlCommand max = new("SELECT MAX(price) FROM products;", connection, transaction);
        Console.WriteLine($"Максимальная цена: {max.ExecuteScalar()}");
        using (SqlCommand list = new("SELECT id, name, price FROM products ORDER BY id;", connection, transaction))
        using (SqlDataReader reader = list.ExecuteReader())
            while (reader.Read()) Console.WriteLine($"{reader.GetInt32(0)}: {reader.GetString(1)} — {reader.GetDecimal(2):F2}");
        using SqlCommand update = new("UPDATE products SET price = 175 WHERE id = @id;", connection, transaction);
        update.Parameters.Add("@id", System.Data.SqlDbType.Int).Value = id;
        Console.WriteLine($"UPDATE: {update.ExecuteNonQuery()} строк.");
        using SqlCommand delete = new("DELETE FROM products WHERE id = @id;", connection, transaction);
        delete.Parameters.Add("@id", System.Data.SqlDbType.Int).Value = id;
        Console.WriteLine($"DELETE: {delete.ExecuteNonQuery()} строк.");
        using SqlCommand database = new("SELECT DB_NAME();", connection, transaction);
        Console.WriteLine($"База: {database.ExecuteScalar()}");
    }
    finally
    {
        transaction.Rollback();
        Console.WriteLine("Учебные изменения отменены (счётчик IDENTITY может увеличиться).");
    }
    return Task.CompletedTask;
});

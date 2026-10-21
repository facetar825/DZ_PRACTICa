using Microsoft.Data.SqlClient;

return await Db.Run(() =>
{
    decimal price = Db.ReadPrice();
    using SqlConnection connection = Db.Connect();
    using SqlCommand command = new("SELECT id, name, price, is_available FROM products WHERE is_available = 1 AND price > @price ORDER BY price, id;", connection);
    Db.Price(command, price);
    connection.Open();
    using SqlDataReader reader = command.ExecuteReader();
    if (!reader.HasRows) Console.WriteLine("Доступных товаров дороже заданной цены нет.");
    while (reader.Read())
        Console.WriteLine($"{reader.GetInt32(0)}: {reader.GetString(1)} — {reader.GetDecimal(2):F2} руб.; доступен: {reader.GetBoolean(3)}");
    return Task.CompletedTask;
});

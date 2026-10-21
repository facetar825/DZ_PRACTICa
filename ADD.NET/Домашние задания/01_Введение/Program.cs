using Microsoft.Data.SqlClient;

return await Db.Run(() =>
{
    using SqlConnection connection = Db.Connect();
    connection.Open();
    using SqlCommand command = new("SELECT DB_NAME();", connection);
    Console.WriteLine($"Текущая база данных: {command.ExecuteScalar()}");
    return Task.CompletedTask;
});

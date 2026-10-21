using System.Data;
using Microsoft.Data.SqlClient;

return await Db.Run(() =>
{
    Console.WriteLine("1 — поиск товара, 2 — изменить цену, 3 — добавить клиента, 4 — удалить клиента");
    string? choice = Console.ReadLine();
    using SqlConnection connection = Db.Connect();
    switch (choice)
    {
        case "1":
        {
            int id = Db.ReadId("ID товара: ");
            using SqlCommand command = new("SELECT id, name, price FROM products WHERE id = @id;", connection);
            command.Parameters.Add("@id", SqlDbType.Int).Value = id;
            connection.Open();
            using SqlDataReader reader = command.ExecuteReader();
            if (reader.Read()) Console.WriteLine($"{reader.GetInt32(0)}: {reader.GetString(1)} — {reader.GetDecimal(2):F2}");
            else Console.WriteLine("Товар не найден.");
            break;
        }
        case "2":
        {
            int id = Db.ReadId("ID товара: ");
            decimal price = Db.ReadPrice();
            using SqlCommand command = new("UPDATE products SET price = @price WHERE id = @id;", connection);
            command.Parameters.Add("@id", SqlDbType.Int).Value = id;
            Db.Price(command, price);
            connection.Open();
            Console.WriteLine($"Изменено строк: {command.ExecuteNonQuery()}");
            break;
        }
        case "3":
        {
            Console.Write("ФИО: "); string name = (Console.ReadLine() ?? "").Trim();
            Console.Write("Телефон (можно пустой): "); string phone = (Console.ReadLine() ?? "").Trim();
            Console.Write("Email (можно пустой): "); string email = (Console.ReadLine() ?? "").Trim();
            if (name.Length is 0 or > 200 || phone.Length > 30 || email.Length > 254)
                throw new ArgumentException("ФИО обязательно (до 200 символов), телефон до 30, email до 254.");
            using SqlCommand command = new("INSERT INTO customers(full_name, phone, email) VALUES(@full_name, @phone, @email);", connection);
            command.Parameters.Add("@full_name", SqlDbType.NVarChar, 200).Value = name;
            command.Parameters.Add("@phone", SqlDbType.NVarChar, 30).Value = phone.Length == 0 ? DBNull.Value : phone;
            command.Parameters.Add("@email", SqlDbType.NVarChar, 254).Value = email.Length == 0 ? DBNull.Value : email;
            connection.Open();
            Console.WriteLine($"Добавлено строк: {command.ExecuteNonQuery()}");
            break;
        }
        case "4":
        {
            int id = Db.ReadId("ID клиента: ");
            using SqlCommand command = new("DELETE FROM customers WHERE id = @id;", connection);
            command.Parameters.Add("@id", SqlDbType.Int).Value = id;
            connection.Open();
            Console.WriteLine($"Удалено строк: {command.ExecuteNonQuery()}");
            break;
        }
        default: throw new ArgumentException("Выберите пункт от 1 до 4.");
    }
    return Task.CompletedTask;
});

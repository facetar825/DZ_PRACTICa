using Microsoft.Data.SqlClient;

internal static class Catalog
{
    public static void Product(SqlDataReader reader) => Console.WriteLine(
        $"{reader.GetInt32(0)}. {reader.GetString(1)} — {reader.GetDecimal(2):F2} руб." +
        (reader.FieldCount > 3 ? $"; доступен: {(reader.GetBoolean(3) ? "Да" : "Нет")}" : ""));

    public static void Customer(SqlDataReader reader) => Console.WriteLine(
        $"{reader.GetInt32(0)}. {reader.GetString(1)}; телефон: {(reader.IsDBNull(2) ? "Не указан" : reader.GetString(2))}; email: {(reader.IsDBNull(3) ? "Не указан" : reader.GetString(3))}");

    public static void Order(SqlDataReader reader) => Console.WriteLine(
        $"Заказ {reader.GetInt32(0)}; клиент {reader.GetInt32(1)}; {reader.GetDateTime(2):dd.MM.yyyy HH:mm}; {reader.GetString(3)}");

    public static void Products(string condition = "", params (string Name, object Value)[] parameters)
        => Db.Rows("SELECT id, name, price, is_available FROM products " + condition, Product, parameters);

    public static void Customers(string condition = "", params (string Name, object Value)[] parameters)
        => Db.Rows("SELECT id, full_name, phone, email FROM customers " + condition, Customer, parameters);

    public static void Orders(string condition = "", params (string Name, object Value)[] parameters)
        => Db.Rows("SELECT id, customer_id, order_date, status FROM orders " + condition, Order, parameters);

    public static void AddProduct()
    {
        string name = Db.Text("Название товара: ");
        int category = Db.Id("ID категории: ");
        decimal price = Db.Price();
        using SqlConnection connection = Db.Open();
        using SqlCommand command = new("INSERT INTO products(name, category_id, price) VALUES(@name, @category_id, @price);", connection);
        // Явные типы и размер в соответствии с дополнительным заданием №3.
        command.Parameters.Add("@name", System.Data.SqlDbType.NVarChar, 150).Value = name;
        command.Parameters.Add("@category_id", System.Data.SqlDbType.Int).Value = category;
        SqlParameter parameter = command.Parameters.Add("@price", System.Data.SqlDbType.Decimal);
        parameter.Precision = 10; parameter.Scale = 2; parameter.Value = price;
        Console.WriteLine($"Добавлено строк: {command.ExecuteNonQuery()}");
    }

    public static void UpdatePrice()
    {
        int id = Db.Id("ID товара: "); decimal price = Db.Price("Новая цена: ");
        Db.NonQuery("UPDATE products SET price = @price WHERE id = @id;", ("@id", id), ("@price", price));
    }

    public static void DeleteProduct() => Db.NonQuery("DELETE FROM products WHERE id = @id;", ("@id", Db.Id("ID товара: ")));

    public static void OrderReport() => Db.Rows("""
        SELECT o.id, c.full_name, o.order_date, o.status
        FROM orders AS o JOIN customers AS c ON c.id = o.customer_id ORDER BY o.id;
        """, reader => Console.WriteLine($"Заказ {reader.GetInt32(0)}; {reader.GetString(1)}; {reader.GetDateTime(2):dd.MM.yyyy HH:mm}; {reader.GetString(3)}"));
}

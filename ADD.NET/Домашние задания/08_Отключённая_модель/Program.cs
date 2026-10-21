using System.Data;
using Microsoft.Data.SqlClient;

return await Db.Run(() =>
{
    using DataSet data = new("CoffeeShop");
    using (SqlConnection connection = Db.Connect())
    {
        connection.Open();
        using SqlDataAdapter categories = new("SELECT id, name FROM categories;", connection);
        using SqlDataAdapter products = new("SELECT id, name, price, is_available, category_id FROM products;", connection);
        categories.Fill(data, "categories");
        products.Fill(data, "products");
    } // Соединение закрыто. Дальнейшая обработка выполняется только в памяти.
    DataTable table = data.Tables["products"]!;
    data.Relations.Add("category_products", data.Tables["categories"]!.Columns["id"]!, table.Columns["category_id"]!);
    Console.WriteLine("Доступные товары по возрастанию цены (после закрытия подключения):");
    DataRow[] available = table.Select("is_available = true", "price ASC, id ASC");
    if (available.Length == 0) Console.WriteLine("Доступных товаров нет.");
    foreach (DataRow row in available)
        Console.WriteLine($"{row["id"]}: {row["name"]} — {row["price"]:F2}");
    foreach (DataRow category in data.Tables["categories"]!.Rows)
    {
        Console.WriteLine($"Категория: {category["name"]}");
        foreach (DataRow row in category.GetChildRows("category_products"))
            Console.WriteLine($"  {row["name"]}");
    }
    if (table.Rows.Count > 0)
    {
        DataRow row = table.Rows[0];
        Console.WriteLine($"До изменения: {row.RowState}");
        row["price"] = row.Field<decimal>("price") == 250m ? 251m : 250m;
        Console.WriteLine($"Цена в памяти: {row["price"]}; состояние: {row.RowState}");
        Console.WriteLine($"Исходная цена: {row["price", DataRowVersion.Original]}");
        row.RejectChanges();
        Console.WriteLine($"После RejectChanges: {row.RowState}, цена {row["price"]}");
    }
    else Console.WriteLine("Таблица пуста — изменять нечего.");
    Console.WriteLine("Изменения в SQL Server не отправлялись.");
    return Task.CompletedTask;
});

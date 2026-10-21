using Microsoft.Data.SqlClient;

Db.Menu("COFFEE SHOP / SqlCommand", """
    1. Количество товаров
    2. Список товаров
    3. Количество клиентов
    4. Количество заказов
    5. Самый дорогой товар
    6. Добавить собственный товар
    7. Учебный сценарий: добавить Мокка, изменить цену, удалить
    8. Средняя и минимальная цена
    9. Количество выданных заказов
    10. Название текущей базы
    11. Количество доступных товаров
    """, choice =>
{
    switch (choice)
    {
        case "1": Console.WriteLine($"Количество товаров: {Db.Scalar("SELECT COUNT(*) FROM products;")}"); break;
        case "2": Catalog.Products("ORDER BY id;"); break;
        case "3": Console.WriteLine($"Количество клиентов: {Db.Scalar("SELECT COUNT(*) FROM customers;")}"); break;
        case "4": Console.WriteLine($"Количество заказов: {Db.Scalar("SELECT COUNT(*) FROM orders;")}"); break;
        case "5":
            object? result = Db.Scalar("SELECT MAX(price) FROM products;");
            if (result is DBNull or null) Console.WriteLine("Товары не найдены.");
            else { decimal maxPrice = Convert.ToDecimal(result); Console.WriteLine($"Максимальная цена: {maxPrice:F2}"); }
            break;
        case "6": Catalog.AddProduct(); break;
        case "7": Demo(); break;
        case "8":
            Console.WriteLine($"Средняя цена: {Db.Display(Db.Scalar("SELECT AVG(price) FROM products;"))}");
            Console.WriteLine($"Минимальная цена: {Db.Display(Db.Scalar("SELECT MIN(price) FROM products;"))}");
            break;
        case "9": Console.WriteLine($"Выданных заказов: {Db.Scalar("SELECT COUNT(*) FROM orders WHERE status = N'Выдан';")}"); break;
        case "10": Console.WriteLine($"База данных: {Db.Scalar("SELECT DB_NAME();")}"); break;
        case "11": Console.WriteLine($"Доступных товаров: {Db.Scalar("SELECT COUNT(*) FROM products WHERE is_available = 1;")}"); break;
        default: throw new ArgumentException("Неизвестный пункт меню.");
    }
});

static void Demo()
{
    using SqlConnection connection = Db.Open();
    using SqlCommand insert = new("""
        INSERT INTO products(name, category_id, price) VALUES(N'Мокка', 1, 240.00);
        SET @new_id = CAST(SCOPE_IDENTITY() AS int);
        """, connection);
    SqlParameter id = insert.Parameters.Add("@new_id", System.Data.SqlDbType.Int);
    id.Direction = System.Data.ParameterDirection.Output;
    Console.WriteLine($"Добавлено строк: {insert.ExecuteNonQuery()}");
    Console.WriteLine($"ID учебного товара: {id.Value}");
    using SqlCommand update = new("UPDATE products SET price = 250.00 WHERE id = @id;", connection);
    Db.Add(update, "@id", (int)id.Value);
    Console.WriteLine($"Изменено строк: {update.ExecuteNonQuery()}");
    using SqlCommand check = new("SELECT price FROM products WHERE id = @id;", connection);
    Db.Add(check, "@id", (int)id.Value);
    Console.WriteLine($"Цена после изменения: {check.ExecuteScalar()}");
    using SqlCommand delete = new("DELETE FROM products WHERE id = @id;", connection);
    Db.Add(delete, "@id", (int)id.Value);
    Console.WriteLine($"Удалено строк: {delete.ExecuteNonQuery()}");
}

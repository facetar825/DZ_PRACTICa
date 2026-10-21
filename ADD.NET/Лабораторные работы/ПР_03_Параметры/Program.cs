Db.Menu("УПРАВЛЕНИЕ ТОВАРАМИ", """
    1. Найти товар по ID
    2. Найти товар по точному названию
    3. Добавить товар
    4. Изменить цену
    5. Удалить товар
    6. Найти товары с ценой от заданной
    7. Количество товаров с ценой от заданной
    8. Найти клиента по части ФИО
    """, choice =>
{
    switch (choice)
    {
        case "1": Catalog.Products("WHERE id = @id;", ("@id", Db.Id("ID товара: "))); break;
        case "2": Catalog.Products("WHERE name = @name ORDER BY id;", ("@name", Db.Text("Название: "))); break;
        case "3": Catalog.AddProduct(); break;
        case "4": Catalog.UpdatePrice(); break;
        case "5": Catalog.DeleteProduct(); break;
        case "6": Catalog.Products("WHERE price >= @min_price ORDER BY price, id;", ("@min_price", Db.Price("Минимальная цена: "))); break;
        case "7": Console.WriteLine($"Количество: {Db.Scalar("SELECT COUNT(*) FROM products WHERE price >= @min_price;", ("@min_price", Db.Price("Минимальная цена: ")))}"); break;
        case "8": Catalog.Customers("WHERE full_name LIKE @search ORDER BY id;", ("@search", "%" + Db.Text("Часть ФИО: ", 200) + "%")); break;
        default: throw new ArgumentException("Неизвестный пункт меню.");
    }
});

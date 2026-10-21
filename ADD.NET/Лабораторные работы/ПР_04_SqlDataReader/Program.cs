Db.Menu("ЧТЕНИЕ ДАННЫХ / SqlDataReader", """
    1. Все товары
    2. Найти товар по ID
    3. Поиск по части названия товара
    4. Клиенты с обработкой NULL
    5. Заказы
    6. Доступные товары по возрастанию цены
    7. Товары дороже заданной цены
    8. Найти клиента по части ФИО
    9. Заказы с заданным статусом
    10. Заказы с именами клиентов (JOIN)
    """, choice =>
{
    switch (choice)
    {
        case "1": Catalog.Products("ORDER BY id;"); break;
        case "2": Catalog.Products("WHERE id = @id;", ("@id", Db.Id("ID товара: "))); break;
        case "3": Catalog.Products("WHERE name LIKE @search ORDER BY id;", ("@search", "%" + Db.Text("Часть названия: ") + "%")); break;
        case "4": Catalog.Customers("ORDER BY id;"); break;
        case "5": Catalog.Orders("ORDER BY id;"); break;
        case "6": Catalog.Products("WHERE is_available = 1 ORDER BY price, id;"); break;
        case "7": Catalog.Products("WHERE price > @price ORDER BY price, id;", ("@price", Db.Price("Минимальная цена (строго больше): "))); break;
        case "8": Catalog.Customers("WHERE full_name LIKE @search ORDER BY id;", ("@search", "%" + Db.Text("Часть ФИО: ", 200) + "%")); break;
        case "9": Catalog.Orders("WHERE status = @status ORDER BY id;", ("@status", Db.Text("Статус заказа: ", 30))); break;
        case "10": Catalog.OrderReport(); break;
        default: throw new ArgumentException("Неизвестный пункт меню.");
    }
});

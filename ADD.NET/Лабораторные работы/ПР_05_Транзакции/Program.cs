using Microsoft.Data.SqlClient;

HashSet<int> sessionOrders = [];
Db.Menu("ТРАНЗАКЦИИ", """
    1. Изменить цены двух товаров и подтвердить
    2. Проверить откат цен с принудительной ошибкой
    3. Создать заказ с одной позицией
    4. Создать заказ с двумя позициями
    5. Проверить откат заказа после вставки заголовка
    6. Отменить тестовый заказ текущего запуска
    7. Проверить откат отмены заказа с ошибкой
    8. Показать клиентов и товары
    9. Показать заказы с позициями
    """, choice =>
{
    switch (choice)
    {
        case "1": ChangePrices(false); break;
        case "2": ChangePrices(true); break;
        case "3": CreateOrder(1, false); break;
        case "4": CreateOrder(2, false); break;
        case "5": CreateOrder(1, true); break;
        case "6": CancelOrder(false); break;
        case "7": CancelOrder(true); break;
        case "8": Catalog.Customers("ORDER BY id;"); Catalog.Products("ORDER BY id;"); break;
        case "9": Db.Rows("""
            SELECT o.id, o.order_date, o.status, oi.product_id, oi.quantity, oi.unit_price
            FROM orders AS o JOIN order_items AS oi ON oi.order_id = o.id ORDER BY o.id, oi.id;
            """, r => Console.WriteLine($"Заказ {r.GetInt32(0)}; {r.GetDateTime(1):dd.MM.yyyy HH:mm}; {r.GetString(2)}; товар {r.GetInt32(3)}; {r.GetInt32(4)} × {r.GetDecimal(5):F2}")); break;
        default: throw new ArgumentException("Неизвестный пункт меню.");
    }
});

void ChangePrices(bool fail)
{
    int first = Db.Id("ID первого товара: "); decimal firstPrice = Db.Price("Первая новая цена: ");
    int second = Db.Id("ID второго товара: "); decimal secondPrice = Db.Price("Вторая новая цена: ");
    if (first == second) throw new ArgumentException("Выберите два разных товара.");
    using SqlConnection connection = Db.Open();
    using SqlTransaction transaction = connection.BeginTransaction();
    try
    {
        Update(first, firstPrice);
        if (fail) throw new InvalidOperationException("Тестовая ошибка после первого изменения цены.");
        Update(second, secondPrice);
        transaction.Commit();
        Console.WriteLine("COMMIT: обе цены сохранены.");
    }
    catch { Rollback(transaction); throw; }

    void Update(int id, decimal price)
    {
        using SqlCommand command = new("UPDATE products SET price = @price WHERE id = @id;", connection, transaction);
        Db.Add(command, "@id", id); Db.Add(command, "@price", price);
        if (command.ExecuteNonQuery() != 1) throw new InvalidOperationException($"Товар {id} не найден. Обе цены должны остаться прежними.");
    }
}

void CreateOrder(int count, bool fail)
{
    int customer = Db.Id("ID клиента: ");
    List<(int Id, int Quantity)> items = [];
    for (int i = 0; i < count; i++)
        items.Add((Db.Id($"ID товара позиции {i + 1}: "), Db.Id("Количество: ")));
    using SqlConnection connection = Db.Open();
    using SqlTransaction transaction = connection.BeginTransaction();
    try
    {
        using SqlCommand customerCheck = new("SELECT COUNT(*) FROM customers WHERE id = @id;", connection, transaction);
        Db.Add(customerCheck, "@id", customer);
        if ((int)customerCheck.ExecuteScalar()! != 1) throw new InvalidOperationException("Клиент не найден.");

        // Проверяем товары и получаем цены в той же транзакции, без ввода пользователя.
        List<(int Id, int Quantity, decimal Price)> checkedItems = [];
        foreach (var item in items)
        {
            using SqlCommand product = new("SELECT price FROM products WITH (HOLDLOCK) WHERE id = @id AND is_available = 1;", connection, transaction);
            Db.Add(product, "@id", item.Id);
            object? value = product.ExecuteScalar();
            if (value is null or DBNull) throw new InvalidOperationException($"Товар {item.Id} не найден или недоступен.");
            checkedItems.Add((item.Id, item.Quantity, (decimal)value));
        }

        using SqlCommand order = new("""
            INSERT INTO orders(customer_id, order_date, status)
            VALUES(@customer_id, SYSDATETIME(), N'Новый');
            SELECT CAST(SCOPE_IDENTITY() AS int);
            """, connection, transaction);
        Db.Add(order, "@customer_id", customer);
        int orderId = (int)order.ExecuteScalar()!;
        if (fail) throw new InvalidOperationException("Тестовая ошибка после создания заказа, до добавления позиций.");
        decimal total = 0;
        foreach (var item in checkedItems)
        {
            using SqlCommand command = new("""
                INSERT INTO order_items(order_id, product_id, quantity, unit_price)
                VALUES(@order_id, @product_id, @quantity, @unit_price);
                """, connection, transaction);
            Db.Add(command, "@order_id", orderId); Db.Add(command, "@product_id", item.Id);
            Db.Add(command, "@quantity", item.Quantity); Db.Add(command, "@unit_price", item.Price);
            if (command.ExecuteNonQuery() != 1) throw new InvalidOperationException("Позиция заказа не добавлена.");
            total += item.Quantity * item.Price;
        }
        transaction.Commit();
        sessionOrders.Add(orderId);
        Console.WriteLine($"COMMIT: заказ №{orderId} создан; позиций: {count}; итоговая сумма: {total:F2} руб.");
    }
    catch { Rollback(transaction); throw; }
}

void CancelOrder(bool fail)
{
    Console.WriteLine($"Тестовые заказы текущего запуска: {string.Join(", ", sessionOrders.Order())}");
    int id = Db.Id("ID отменяемого заказа: ");
    if (!sessionOrders.Contains(id)) throw new ArgumentException("Можно отменять только тестовый заказ, созданный в текущем запуске программы.");
    using SqlConnection connection = Db.Open();
    using SqlTransaction transaction = connection.BeginTransaction();
    try
    {
        using SqlCommand items = new("DELETE FROM order_items WHERE order_id = @id;", connection, transaction);
        Db.Add(items, "@id", id);
        int deleted = items.ExecuteNonQuery();
        if (fail) throw new InvalidOperationException("Тестовая ошибка отмены после удаления позиций.");
        using SqlCommand order = new("DELETE FROM orders WHERE id = @id;", connection, transaction);
        Db.Add(order, "@id", id);
        if (order.ExecuteNonQuery() != 1) throw new InvalidOperationException("Заказ не найден.");
        transaction.Commit();
        sessionOrders.Remove(id);
        Console.WriteLine($"COMMIT: заказ {id} и его позиции ({deleted}) удалены.");
    }
    catch { Rollback(transaction); throw; }
}

static void Rollback(SqlTransaction transaction)
{
    try { transaction.Rollback(); Console.WriteLine("ROLLBACK: все изменения операции отменены."); }
    catch (Exception ex) { Console.WriteLine($"Ошибка отката: {ex.Message}"); }
}

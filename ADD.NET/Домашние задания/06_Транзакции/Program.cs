using System.Data;
using Microsoft.Data.SqlClient;

return await Db.Run(() =>
{
    int customer = Db.ReadId("ID клиента: ");
    int first = Db.ReadId("ID первого товара: ");
    int second = Db.ReadId("ID второго товара: ");
    Console.Write("Проверить откат ошибкой во второй позиции? (да/нет): ");
    bool fail = string.Equals(Console.ReadLine()?.Trim(), "да", StringComparison.OrdinalIgnoreCase);
    using SqlConnection connection = Db.Connect();
    connection.Open();
    using SqlTransaction transaction = connection.BeginTransaction();
    try
    {
        using SqlCommand order = new("INSERT INTO orders(customer_id, order_date, status) VALUES(@customer, SYSDATETIME(), N'Новый'); SELECT CAST(SCOPE_IDENTITY() AS int);", connection, transaction);
        order.Parameters.Add("@customer", SqlDbType.Int).Value = customer;
        int orderId = (int)order.ExecuteScalar()!;
        AddItem(first, 1);
        AddItem(second, fail ? 0 : 1); // CHECK quantity > 0 вызывает ошибку для проверки отката.
        transaction.Commit();
        Console.WriteLine($"Заказ №{orderId} с двумя позициями сохранён.");

        void AddItem(int productId, int quantity)
        {
            using SqlCommand item = new("""
                INSERT INTO order_items(order_id, product_id, quantity, unit_price)
                SELECT @order, id, @quantity, price FROM products
                WHERE id = @product AND is_available = 1;
                """, connection, transaction);
            item.Parameters.Add("@order", SqlDbType.Int).Value = orderId;
            item.Parameters.Add("@product", SqlDbType.Int).Value = productId;
            item.Parameters.Add("@quantity", SqlDbType.Int).Value = quantity;
            if (item.ExecuteNonQuery() != 1)
                throw new InvalidOperationException($"Товар {productId} не найден или недоступен.");
        }
    }
    catch
    {
        try { transaction.Rollback(); Console.WriteLine("Заказ и обе позиции отменены."); }
        catch (Exception ex) { Console.Error.WriteLine($"Ошибка отката: {ex.Message}"); }
        throw;
    }
    return Task.CompletedTask;
});

using System.Data;
using Microsoft.Data.SqlClient;

PracticeSupport.ConsoleEncoding();
DataSet? data = null;
try
{
    using var configuration = PracticeSupport.LoadConfiguration();
    string connectionString = PracticeSupport.ConnectionString(configuration);
    await PracticeSupport.MenuAsync("Каталог кофейни в памяти", """
        1. Загрузить / перезагрузить товары и категории
        2. Все товары из памяти
        3. Доступные товары по возрастанию цены
        4. Сортировка всех товаров по убыванию цены
        5. Товары выбранной категории
        6. Изменить цену товара в памяти и показать RowState
        7. Загрузить новую копию из базы и сравнить цену
        8. Товары дороже 200 и количество доступных товаров
        9. Категории и связанные товары
        10. Количество товаров по категориям (по убыванию)
        """, choice =>
    {
        if (choice == "1")
        {
            DataSet loaded = LoadCatalog(connectionString);
            data?.Dispose(); data = loaded;
            Console.WriteLine($"Загружено таблиц: {data.Tables.Count}; товаров: {data.Tables["products"]!.Rows.Count}; категорий: {data.Tables["categories"]!.Rows.Count}.");
            Console.WriteLine("Соединение закрыто. Каталог находится в памяти.");
            return Task.CompletedTask;
        }
        if (data is null) throw new InvalidOperationException("Сначала загрузите данные пунктом 1.");
        DataTable products = data.Tables["products"]!;
        DataTable categories = data.Tables["categories"]!;
        switch (choice)
        {
            case "2": Print(products.Select("", "id ASC")); break;
            case "3": Print(products.Select("is_available = true", "price ASC, id ASC")); break;
            case "4": Print(products.Select("", "price DESC, id ASC")); break;
            case "5":
                int categoryId = PracticeSupport.Id("ID категории: ");
                DataRow? category = categories.Rows.Find(categoryId);
                if (category is null) Console.WriteLine("Категория не найдена.");
                else Print(category.GetChildRows("category_products"));
                break;
            case "6":
                int id = PracticeSupport.Id("ID товара: ");
                decimal price = PracticeSupport.Price("Новая локальная цена: ");
                DataRow row = products.Rows.Find(id) ?? throw new ArgumentException("Товар не найден.");
                Console.WriteLine($"До: {row["price"]}; состояние: {row.RowState}");
                row["price"] = price;
                Console.WriteLine($"После: {row["price"]}; RowState: {row.RowState}; исходная цена: {row["price", DataRowVersion.Original]}");
                break;
            case "7":
                int compareId = PracticeSupport.Id("ID товара: ");
                DataRow local = products.Rows.Find(compareId) ?? throw new ArgumentException("Товар не найден в локальном каталоге.");
                using (DataTable fresh = LoadProducts(connectionString))
                {
                    DataRow? server = fresh.Rows.Find(compareId);
                    Console.WriteLine(server is null ? "Товар отсутствует в базе." : $"Локальная цена: {local["price"]}; цена в базе: {server["price"]}; совпадают: {Equals(local["price"], server["price"])}");
                }
                break;
            case "8":
                Print(products.Select("price > 200", "price ASC, id ASC"));
                Console.WriteLine($"Доступных товаров: {products.Select("is_available = true").Length}");
                break;
            case "9":
                if (categories.Rows.Count == 0) Console.WriteLine("Категории не найдены.");
                foreach (DataRow categoryRow in categories.Rows)
                {
                    Console.WriteLine($"Категория: {categoryRow["name"]}");
                    Print(categoryRow.GetChildRows("category_products"));
                }
                break;
            case "10":
                if (categories.Rows.Count == 0) Console.WriteLine("Категории не найдены.");
                foreach (var item in categories.AsEnumerable()
                    .Select(row => new { Name = row.Field<string>("name"), Count = row.GetChildRows("category_products").Length })
                    .OrderByDescending(item => item.Count).ThenBy(item => item.Name))
                    Console.WriteLine($"{item.Name}: {item.Count}");
                break;
            default: throw new ArgumentException("Неизвестный пункт меню.");
        }
        return Task.CompletedTask;
    });
    return 0;
}
catch (Exception ex) when (PracticeSupport.KnownError(ex)) { PracticeSupport.Error(ex); return 1; }
finally { data?.Dispose(); }

static DataTable LoadProducts(string connectionString)
{
    using SqlConnection connection = new(connectionString);
    using SqlDataAdapter adapter = new("SELECT id, name, category_id, price, is_available FROM products ORDER BY id", connection);
    adapter.MissingSchemaAction = MissingSchemaAction.AddWithKey;
    DataTable table = new("products");
    try
    {
        adapter.Fill(table);
        table.PrimaryKey = [table.Columns["id"]!];
        return table;
    }
    catch { table.Dispose(); throw; }
}

static DataSet LoadCatalog(string connectionString)
{
    DataSet data = new("coffee_shop");
    try
    {
        data.Tables.Add(LoadProducts(connectionString));
        using SqlConnection connection = new(connectionString);
        using SqlDataAdapter adapter = new("SELECT id, name FROM categories ORDER BY id", connection);
        adapter.MissingSchemaAction = MissingSchemaAction.AddWithKey;
        adapter.Fill(data, "categories");
        data.Tables["categories"]!.PrimaryKey = [data.Tables["categories"]!.Columns["id"]!];
        data.Relations.Add("category_products", data.Tables["categories"]!.Columns["id"]!, data.Tables["products"]!.Columns["category_id"]!);
        return data;
    }
    catch { data.Dispose(); throw; }
}

static void Print(DataRow[] rows)
{
    if (rows.Length == 0) Console.WriteLine("Товары не найдены.");
    foreach (DataRow row in rows)
        Console.WriteLine($"{row.Field<int>("id")}. {row.Field<string>("name")} — {row.Field<decimal>("price"):F2} руб. | {(row.Field<bool>("is_available") ? "Доступен" : "Недоступен")}");
}

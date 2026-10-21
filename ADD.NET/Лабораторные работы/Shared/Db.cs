using System.Data;
using System.Globalization;
using System.Text.Json;
using Microsoft.Data.SqlClient;

internal static class Db
{
    public static SqlConnection Open()
    {
        string? text = Environment.GetEnvironmentVariable("ConnectionStrings__CoffeeShop");
        if (text is null)
        {
            using JsonDocument json = JsonDocument.Parse(File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "appsettings.json")));
            text = json.RootElement.GetProperty("ConnectionStrings").GetProperty("CoffeeShop").GetString();
        }
        if (string.IsNullOrWhiteSpace(text)) throw new InvalidOperationException("Не задана строка подключения CoffeeShop.");
        SqlConnection connection = new(text);
        try { connection.Open(); return connection; }
        catch { connection.Dispose(); throw; }
    }

    public static string Text(string prompt, int maxLength = 150)
    {
        Console.Write(prompt);
        string value = (Console.ReadLine() ?? "").Trim();
        if (value.Length == 0 || value.Length > maxLength)
            throw new ArgumentException($"Нужно от 1 до {maxLength} символов.");
        return value;
    }

    public static int Id(string prompt)
    {
        if (!int.TryParse(Text(prompt, 10), out int value) || value <= 0)
            throw new ArgumentException("Введите положительное целое число.");
        return value;
    }

    public static decimal Price(string prompt = "Цена: ")
    {
        string text = Text(prompt, 30).Replace(',', '.');
        if (!decimal.TryParse(text, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out decimal value)
            || value < 0 || value > 99999999.99m || decimal.Round(value, 2) != value)
            throw new ArgumentException("Цена должна быть от 0 до 99999999,99 с точностью до копейки.");
        return value;
    }

    public static void Add(SqlCommand command, string name, object value)
    {
        SqlParameter parameter = value switch
        {
            int => command.Parameters.Add(name, SqlDbType.Int),
            decimal => command.Parameters.Add(name, SqlDbType.Decimal),
            string text => command.Parameters.Add(name, SqlDbType.NVarChar, Math.Max(1, text.Length)),
            _ => throw new ArgumentException("Неподдерживаемый тип параметра.")
        };
        if (value is decimal) { parameter.Precision = 10; parameter.Scale = 2; }
        parameter.Value = value;
    }

    public static void Menu(string title, string choices, Action<string> operation)
    {
        Console.OutputEncoding = System.Text.Encoding.UTF8;
        Console.InputEncoding = System.Text.Encoding.UTF8;
        while (true)
        {
            Console.WriteLine($"\n=== {title} ===\n{choices}\n0. Выход");
            string? choice = Console.ReadLine()?.Trim();
            if (choice is null or "0") return;
            Guard(() => operation(choice));
        }
    }

    public static void Guard(Action action)
    {
        try { action(); }
        catch (SqlException ex) { Console.WriteLine($"Ошибка SQL Server: {ex.Message}"); }
        catch (Exception ex) when (ex is ArgumentException or InvalidOperationException or IOException or JsonException)
        { Console.WriteLine($"Ошибка: {ex.Message}"); }
    }

    public static void Rows(string sql, Action<SqlDataReader> print, params (string Name, object Value)[] parameters)
    {
        using SqlConnection connection = Open();
        using SqlCommand command = new(sql, connection);
        foreach (var parameter in parameters) Add(command, parameter.Name, parameter.Value);
        using SqlDataReader reader = command.ExecuteReader();
        if (!reader.HasRows) Console.WriteLine("Записи не найдены.");
        while (reader.Read()) print(reader);
    }

    public static object? Scalar(string sql, params (string Name, object Value)[] parameters)
    {
        using SqlConnection connection = Open();
        using SqlCommand command = new(sql, connection);
        foreach (var parameter in parameters) Add(command, parameter.Name, parameter.Value);
        return command.ExecuteScalar();
    }

    public static void NonQuery(string sql, params (string Name, object Value)[] parameters)
    {
        using SqlConnection connection = Open();
        using SqlCommand command = new(sql, connection);
        foreach (var parameter in parameters) Add(command, parameter.Name, parameter.Value);
        Console.WriteLine($"Изменено строк: {command.ExecuteNonQuery()}");
    }

    public static string Display(object? value) => value is null or DBNull ? "Нет данных" : Convert.ToString(value, CultureInfo.CurrentCulture)!;
}

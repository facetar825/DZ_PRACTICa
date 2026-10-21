using System.Data;
using System.Globalization;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

internal static class Db
{
    public static SqlConnection Connect()
    {
        IConfiguration config = new ConfigurationBuilder()
            .SetBasePath(AppContext.BaseDirectory)
            .AddJsonFile("appsettings.json", optional: true)
            .AddEnvironmentVariables()
            .Build();
        string? value = config.GetConnectionString("CoffeeShop");
        if (string.IsNullOrWhiteSpace(value))
            throw new InvalidOperationException("Не найдена настройка ConnectionStrings:CoffeeShop.");
        return new SqlConnection(value);
    }

    public static int ReadId(string prompt)
    {
        Console.Write(prompt);
        if (!int.TryParse(Console.ReadLine(), out int id) || id <= 0)
            throw new ArgumentException("Идентификатор должен быть положительным целым числом.");
        return id;
    }

    public static decimal ReadPrice()
    {
        Console.Write("Цена (руб.): ");
        string text = (Console.ReadLine() ?? "").Trim().Replace(',', '.');
        if (!decimal.TryParse(text, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out decimal price)
            || price < 0 || price > 99999999.99m || decimal.Round(price, 2) != price)
            throw new ArgumentException("Введите цену от 0 до 99999999,99 с точностью до копейки.");
        return price;
    }

    public static void Price(SqlCommand command, decimal price)
    {
        SqlParameter parameter = command.Parameters.Add("@price", SqlDbType.Decimal);
        parameter.Precision = 10;
        parameter.Scale = 2;
        parameter.Value = price;
    }

    public static async Task<int> Run(Func<Task> action)
    {
        Console.OutputEncoding = System.Text.Encoding.UTF8;
        try { await action(); return 0; }
        catch (OperationCanceledException) { Console.Error.WriteLine("Операция отменена."); return 2; }
        catch (SqlException ex) { Console.Error.WriteLine($"Ошибка SQL Server: {ex.Message}"); return 1; }
        catch (Exception ex) when (ex is ArgumentException or InvalidOperationException or IOException or FormatException)
        { Console.Error.WriteLine(ex.Message); return 1; }
    }
}

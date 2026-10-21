using System.Globalization;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

internal static class PracticeSupport
{
    public static ConfigurationRoot LoadConfiguration() => (ConfigurationRoot)new ConfigurationBuilder()
        .SetBasePath(AppContext.BaseDirectory)
        .AddJsonFile("appsettings.json", optional: false)
        .AddJsonFile("appsettings.Development.json", optional: true)
        .AddEnvironmentVariables()
        .Build();

    public static string ConnectionString(IConfiguration configuration)
    {
        string? value = configuration.GetConnectionString("CoffeeShop");
        return !string.IsNullOrWhiteSpace(value) ? value
            : throw new InvalidOperationException("Строка подключения CoffeeShop не найдена или пуста.");
    }

    public static void ConsoleEncoding()
    {
        Console.OutputEncoding = System.Text.Encoding.UTF8;
        Console.InputEncoding = System.Text.Encoding.UTF8;
    }

    public static string Text(string prompt, int maxLength = 150)
    {
        Console.Write(prompt);
        string text = (Console.ReadLine() ?? "").Trim();
        if (text.Length == 0 || text.Length > maxLength)
            throw new ArgumentException($"Введите от 1 до {maxLength} символов.");
        return text;
    }

    public static int Id(string prompt)
    {
        if (!int.TryParse(Text(prompt, 10), out int id) || id <= 0)
            throw new ArgumentException("Введите положительное целое число.");
        return id;
    }

    public static decimal Price(string prompt = "Цена: ")
    {
        string text = Text(prompt, 30).Replace(',', '.');
        if (!decimal.TryParse(text, NumberStyles.AllowDecimalPoint, CultureInfo.InvariantCulture, out decimal price)
            || price < 0 || price > 99999999.99m || decimal.Round(price, 2) != price)
            throw new ArgumentException("Цена должна быть от 0 до 99999999,99 с точностью до копейки.");
        return price;
    }

    public static bool Bool(string prompt)
    {
        return Text(prompt, 5).ToLowerInvariant() switch
        {
            "1" or "да" or "true" => true,
            "0" or "нет" or "false" => false,
            _ => throw new ArgumentException("Введите 1/0 или да/нет.")
        };
    }

    public static async Task MenuAsync(string title, string menu, Func<string, Task> action)
    {
        while (true)
        {
            Console.WriteLine($"\n=== {title} ===\n{menu}\n0. Выход");
            string? choice = Console.ReadLine()?.Trim();
            if (choice is null or "0") return;
            try { await action(choice); }
            catch (Exception ex) when (KnownError(ex)) { Error(ex); }
        }
    }

    public static bool KnownError(Exception ex) => ex is SqlException or OperationCanceledException
        or ArgumentException or InvalidOperationException or IOException or System.Data.DataException;

    public static void Error(Exception ex) => Console.WriteLine(ex switch
    {
        OperationCanceledException => "Операция отменена.",
        SqlException => $"Ошибка SQL Server: {ex.Message}",
        _ => $"Ошибка: {ex.Message}"
    });
}

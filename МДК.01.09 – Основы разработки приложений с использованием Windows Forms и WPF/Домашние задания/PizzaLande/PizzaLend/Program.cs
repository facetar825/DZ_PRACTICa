namespace PizzaLend
{
    internal static class Program
    {
        
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            ApplicationConfiguration.Initialize();
            Application.Run(new PizzaTime());
        }
    }

    static class Variables
    {
        static public string filePath = @"./users.db";
        static public List<Pizza> pizzas = new List<Pizza>();
        static public string paymentMethod;
    }

    public class Pizza
    { 
        public string Name { get; set; }

        public int Count { get; set; }

        public List<string> Addities { get; set; }

        public Pizza(string name, int count, List<string> addities)
        {
            Name = name;
            Count = count;
            Addities = addities;
        }

        public string GetFullPizza()
        {
            string additiesString = string.Empty;

            foreach (var addity in Addities)
            {
                additiesString += $"{addity}, ";
            }

            return $"Pizza: {Name}, Count: {Count}, Addities: {additiesString}";
        }


    }
}
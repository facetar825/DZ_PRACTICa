using System;
using System.Windows;
using System.Windows.Controls;

namespace DailyExpenses
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void CalcButton_Click(object sender, RoutedEventArgs e)
        {
            // Считываем и парсим
            double mon = ParseDouble(MondayBox.Text);
            double tue = ParseDouble(TuesdayBox.Text);
            double wed = ParseDouble(WednesdayBox.Text);
            double thu = ParseDouble(ThursdayBox.Text);
            double fri = ParseDouble(FridayBox.Text);
            double sat = ParseDouble(SaturdayBox.Text);
            double sun = ParseDouble(SundayBox.Text);

            double[] expenses = { mon, tue, wed, thu, fri, sat, sun };

            double sum = 0;
            double max = double.MinValue;
            foreach (double val in expenses)
            {
                sum += val;
                if (val > max) max = val;
            }
            double average = sum / expenses.Length;

            // Отображаем
            SumResult.Text = $"Общая сумма: {sum:F2}";
            AvgResult.Text = $"Средний расход в день: {average:F2}";
            MaxResult.Text = $"Максимальный расход за день: {max:F2}";
        }

        private double ParseDouble(string input)
        {
            if (string.IsNullOrWhiteSpace(input))
                return 0;
            if (double.TryParse(input, out double result))
                return result;
            return 0;
        }
    }
}
using System;
using System.Windows;
using System.Windows.Controls;

namespace credit_calculation
{
    public partial class MainWindow : Window
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            string loanamount = LoanAmount.Text;
            string monthpayment = MonthPayment.Text;

            if (float.TryParse(loanamount, out float loanamountf) && float.TryParse(monthpayment, out float monthpaymentf))
            {
                float result_in_months = loanamountf / monthpaymentf;
                InMonths.Text = result_in_months.ToString(); // было Content

                float result_in_years = result_in_months / 12;
                InYears.Text = result_in_years.ToString();   // было Content
            }
        }

        // Пустые обработчики можно удалить или оставить
        // private void TextBox_TextChanged(object sender, TextChangedEventArgs e) { }
        // private void TextBox_TextChanged_1(object sender, TextChangedEventArgs e) { }
    }
}
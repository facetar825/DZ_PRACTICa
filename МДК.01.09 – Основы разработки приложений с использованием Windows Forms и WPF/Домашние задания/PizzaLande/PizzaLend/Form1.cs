using SQLite;
using System.Runtime.CompilerServices;
using System.Xml.Linq;

namespace PizzaLend
{
    public partial class PizzaTime : Form
    {
        public PizzaTime()
        {
            InitializeComponent();
            lblLoginError.Visible = false;
            
            tabOrder.Enabled = false;
            tabPay.Enabled = false;
        }
  
        private void btnLogin_Click(object sender, EventArgs e)
        {
            string email = tBxEmail.Text;
            string password = tBxPassword.Text;

            if (string.IsNullOrEmpty(email)) tBxEmail.BackColor = Color.Red;
            else tBxEmail.BackColor = Color.White;

            if (string.IsNullOrEmpty(password)) tBxPassword.BackColor = Color.Red;
            else tBxPassword.BackColor = Color.White;

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password)) return;


        }

        private void btnAddPizza_Click(object sender, EventArgs e)
        {
            string typeOfPizza = comboBoxPizzas.Text;
            int count = (int)numericUpDownCount.Value;

            if (string.IsNullOrEmpty(typeOfPizza) || count == 0) return;

            List<string> addities = new List<string>();

            foreach (object it in checkedListBoxAddities.CheckedItems)
                addities.Add(it?.ToString() ?? string.Empty);

            Pizza newPizza = new Pizza(typeOfPizza, count, addities);
            comboBoxOrder.Items.Add(newPizza.GetFullPizza());
            Variables.pizzas.Add(newPizza);
        }

        private void checkedListBoxAddities_SelectedIndexChanged(object sender, EventArgs e)
        {

        }

        private void btnOrderPizza_Click(object sender, EventArgs e)
        {
            if (Variables.pizzas.Count == 0)
                MessageBox.Show($"Order is empty.");

            string message = string.Empty;

            foreach (Pizza pizza in Variables.pizzas)
                message += pizza.GetFullPizza();

            tabControl.SelectTab(3);
            MessageBox.Show($"Accept of order: \n {message}");
        }

        private void panel2_Paint(object sender, PaintEventArgs e)
        {

        }

        private void tableLayoutPanel1_Paint(object sender, PaintEventArgs e)
        {

        }

        private void btnOrderPay_Click(object sender, EventArgs e)
        {

        }

        private void tableLayoutPanel3_Paint(object sender, PaintEventArgs e)
        {

        }
    }
}

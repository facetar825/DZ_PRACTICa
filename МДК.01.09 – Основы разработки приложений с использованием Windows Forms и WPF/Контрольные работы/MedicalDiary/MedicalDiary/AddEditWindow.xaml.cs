using System;
using System.Windows;


namespace MedicalDiary
{

    public partial class AddEditWindow : Window
    {

        public MedicalRecord Record { get; set; }

        public AddEditWindow(MedicalRecord record = null)
        {

            InitializeComponent();
            if (record != null)
            {

                Record = record;
                SystolicBox.Text = record.Systolic.ToString();
                DiastolicBox.Text = record.Diastolic.ToString();
                PulseBox.Text = record.Pulse.ToString();
                SugarBox.Text = record.Sugar.ToString();
                CommentBox.Text = record.Comment;



                foreach (var item in MealBox.Items)
                {

                    var combo =
                    (System.Windows.Controls.ComboBoxItem)item;


                    if (combo.Content.ToString() == record.MealType)
                    {

                        MealBox.SelectedItem = item;

                    }
                }
            }
        }



        private void Save_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                int sys = int.Parse(SystolicBox.Text);
                int dia = int.Parse(DiastolicBox.Text);
                int pulse = int.Parse(PulseBox.Text);
                double sugar = double.Parse(SugarBox.Text);

                if (sys < 60 || sys > 250)
                {

                    MessageBox.Show("Систолическое давление 60-250");
                    return;

                }

                if (dia < 40 || dia > 150)
                {

                    MessageBox.Show("Диастолическое 40-150");
                    return;

                }

                if (pulse < 30 || pulse > 200)
                {

                    MessageBox.Show("Пульс 30-200");
                    return;

                }


                if (sugar < 1 || sugar > 30)
                {

                    MessageBox.Show("Сахар 1-30");
                    return;

                }

                if (Record == null)
                {

                    Record = new MedicalRecord();

                }
                Record.DateTime = DateTime.Now;

                Record.Systolic = sys;

                Record.Diastolic = dia;

                Record.Pulse = pulse;

                Record.Sugar = sugar;

                Record.MealType =
                (MealBox.SelectedItem as System.Windows.Controls.ComboBoxItem)
                .Content.ToString();
                Record.Comment = CommentBox.Text;
                DialogResult = true;
                Close();

            }

            catch
            {
                MessageBox.Show("Ошибка ввода");
            }



        }


    }

}
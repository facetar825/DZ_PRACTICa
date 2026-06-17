using System;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Text.Json;
using System.Windows;
using LiveChartsCore;
using LiveChartsCore.SkiaSharpView;
using LiveChartsCore.Kernel.Sketches;
using LiveChartsCore;
using LiveChartsCore.Kernel;
using PdfSharpCore.Drawing;
using PdfSharpCore.Pdf;
namespace MedicalDiary
{


    public partial class MainWindow : Window
    {


        ObservableCollection<MedicalRecord> records =
        new ObservableCollection<MedicalRecord>();



        public MainWindow()
        {

            InitializeComponent();


            RecordsGrid.ItemsSource = records;
            UpdateCharts();


        }




        // ДОБАВИТЬ

        private void Add_Click(object sender, RoutedEventArgs e)
        {


            AddEditWindow window =
            new AddEditWindow();
            if (window.ShowDialog() == true)
            {

                records.Add(window.Record);
                Sort();
                UpdateCharts();
            }
        }

        // УДАЛИТЬ


        private void Delete_Click(object sender, RoutedEventArgs e)
        {
            if (RecordsGrid.SelectedItem is MedicalRecord record)
            {
                records.Remove(record);

            }


        }
        // ИЗМЕНИТЬ

        private void Edit_Click(object sender, RoutedEventArgs e)
        {


            if (RecordsGrid.SelectedItem is MedicalRecord record)
            {
                AddEditWindow window =
                new AddEditWindow(record);
                window.ShowDialog();
                RecordsGrid.Items.Refresh();
                Sort();
            }
            else
            {
                MessageBox.Show("Выберите запись");

            }


        }






        // СОРТИРОВКА


        private void Sort()
        {


            var list = records
            .OrderByDescending(x => x.DateTime)
            .ToList();


            records.Clear();



            foreach (var item in list)
                records.Add(item);



        }







        // СОХРАНЕНИЕ JSON



        private void Save_Click(object sender, RoutedEventArgs e)
        {


            string json =
            JsonSerializer.Serialize(records);



            File.WriteAllText(
            "records.json",
            json);



            MessageBox.Show("Сохранено");



        }









        // ЗАГРУЗКА JSON



        private void Load_Click(object sender, RoutedEventArgs e)
        {


            if (File.Exists("records.json"))
            {


                string json = File.ReadAllText("records.json");



                var data = JsonSerializer.Deserialize<ObservableCollection<MedicalRecord>>(json);

                records.Clear();
                foreach (var item in data)
                {

                    records.Add(item);

                }
            }



        }
        private void UpdateCharts()
        {

            PressureChart.Series =
            new ISeries[]
            {

        new LineSeries<int>
        {
            Name = "Систолическое",

            Values = records
                .Select(x => x.Systolic)
                .ToList()
        },


        new LineSeries<int>
        {
            Name = "Диастолическое",

            Values = records
                .Select(x => x.Diastolic)
                .ToList()
        }

            };





            SugarChart.Series = new ISeries[]
            {
                new LineSeries<double>
                {
                    Name = "Сахар",
                    Values = records
                    .Select(x => x.Sugar)
                    .ToList(),
                    GeometrySize = 15
                }



            };





        }
        private void Pdf_Click(object sender, RoutedEventArgs e)
        {

            try
            {

                PdfDocument document = new PdfDocument();


                document.Info.Title = "Медицинский дневник";


                PdfPage page = document.AddPage();


                XGraphics gfx =
                    XGraphics.FromPdfPage(page);



                XFont font = new XFont("Arial",12,XFontStyle.Regular);



                int y = 40;



                gfx.DrawString(
                    "Медицинский дневник",
                    new XFont("Arial", 16),
                    XBrushes.Black,
                    new XPoint(40, y)
                );


                y += 40;



                foreach (MedicalRecord r in records)
                {

                    string line =
                        $"{r.DateTime:dd.MM.yyyy HH:mm}  " +
                        $"{r.Systolic}/{r.Diastolic}  " +
                        $"Пульс:{r.Pulse}  " +
                        $"Сахар:{r.Sugar}  " +
                        $"{r.MealType}";


                    gfx.DrawString(
                        line,
                        font,
                        XBrushes.Black,
                        new XPoint(40, y)
                    );


                    y += 25;



                    if (y > 750)
                    {

                        page = document.AddPage();

                        gfx = XGraphics.FromPdfPage(page);

                        y = 40;

                    }


                }



                string path = Path.Combine(
                      AppDomain.CurrentDomain.BaseDirectory,
                      "MedicalReport.pdf"
                      );

                document.Save(path);

                MessageBox.Show(
                    $"PDF сохранён:\n{path}"
                );



                MessageBox.Show(
                    "PDF успешно создан!"
                );



            }
            catch (Exception ex)
            {

                MessageBox.Show(
                    ex.Message
                );

            }

        }
    }
}

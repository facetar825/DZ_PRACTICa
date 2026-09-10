using System;
using System.Collections.Generic;
using System.Drawing;
using System.Globalization;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace CurrencyConverter
{
    public partial class Form1 : Form
    {
        private readonly HttpClient httpClient = new HttpClient();

        private Dictionary<string, decimal> rates = new Dictionary<string, decimal>();

        private ComboBox comboFrom;
        private ComboBox comboTo;
        private TextBox textAmount;
        private Button buttonConvert;
        private Button buttonRefresh;
        private Label labelResult;
        private Label labelStatus;
        private DataGridView ratesGrid;

        public Form1()
        {
            InitializeComponent();
            CreateInterface();

            Load += async (sender, e) =>
            {
                await LoadRates();
            };
        }

        private void CreateInterface()
        {
            Text = "Конвертер валют";
            StartPosition = FormStartPosition.CenterScreen;
            Size = new Size(800, 600);
            MinimumSize = new Size(700, 500);

            // Заголовок
            Label title = new Label();
            title.Text = "Конвертер валют";
            title.Font = new Font("Segoe UI", 18, FontStyle.Bold);
            title.Location = new Point(25, 20);
            title.AutoSize = true;

            Controls.Add(title);

            // Сумма
            Label amountLabel = new Label();
            amountLabel.Text = "Сумма:";
            amountLabel.Location = new Point(30, 80);
            amountLabel.AutoSize = true;

            textAmount = new TextBox();
            textAmount.Location = new Point(30, 105);
            textAmount.Width = 180;
            textAmount.Text = "100";

            Controls.Add(amountLabel);
            Controls.Add(textAmount);

            // Из какой валюты
            Label fromLabel = new Label();
            fromLabel.Text = "Из валюты:";
            fromLabel.Location = new Point(240, 80);
            fromLabel.AutoSize = true;

            comboFrom = new ComboBox();
            comboFrom.Location = new Point(240, 105);
            comboFrom.Width = 150;
            comboFrom.DropDownStyle = ComboBoxStyle.DropDownList;

            // В какую валюту
            Label toLabel = new Label();
            toLabel.Text = "В валюту:";
            toLabel.Location = new Point(410, 80);
            toLabel.AutoSize = true;

            comboTo = new ComboBox();
            comboTo.Location = new Point(410, 105);
            comboTo.Width = 150;
            comboTo.DropDownStyle = ComboBoxStyle.DropDownList;

            Controls.Add(fromLabel);
            Controls.Add(comboFrom);
            Controls.Add(toLabel);
            Controls.Add(comboTo);

            // Кнопка конвертации
            buttonConvert = new Button();
            buttonConvert.Text = "Конвертировать";
            buttonConvert.Location = new Point(580, 103);
            buttonConvert.Width = 150;
            buttonConvert.Height = 30;
            buttonConvert.Click += ButtonConvert_Click;

            Controls.Add(buttonConvert);

            // Результат
            Label resultTitle = new Label();
            resultTitle.Text = "Результат:";
            resultTitle.Location = new Point(30, 155);
            resultTitle.AutoSize = true;

            labelResult = new Label();
            labelResult.Text = "Введите сумму и нажмите «Конвертировать»";
            labelResult.Location = new Point(30, 180);
            labelResult.Font = new Font("Segoe UI", 12, FontStyle.Bold);
            labelResult.AutoSize = true;

            Controls.Add(resultTitle);
            Controls.Add(labelResult);

            // Кнопка обновления
            buttonRefresh = new Button();
            buttonRefresh.Text = "Обновить курсы";
            buttonRefresh.Location = new Point(30, 225);
            buttonRefresh.Width = 150;
            buttonRefresh.Height = 30;
            buttonRefresh.Click += async (sender, e) =>
            {
                await LoadRates();
            };

            Controls.Add(buttonRefresh);

            // Статус
            labelStatus = new Label();
            labelStatus.Text = "Загрузка курсов...";
            labelStatus.Location = new Point(200, 232);
            labelStatus.AutoSize = true;

            Controls.Add(labelStatus);

            // Заголовок таблицы
            Label ratesTitle = new Label();
            ratesTitle.Text = "Текущие курсы валют";
            ratesTitle.Font = new Font("Segoe UI", 12, FontStyle.Bold);
            ratesTitle.Location = new Point(30, 275);
            ratesTitle.AutoSize = true;

            Controls.Add(ratesTitle);

            // Таблица
            ratesGrid = new DataGridView();

            ratesGrid.Location = new Point(30, 310);
            ratesGrid.Size = new Size(700, 210);

            ratesGrid.AllowUserToAddRows = false;
            ratesGrid.AllowUserToDeleteRows = false;
            ratesGrid.ReadOnly = true;
            ratesGrid.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
            ratesGrid.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
            ratesGrid.RowHeadersVisible = false;

            ratesGrid.Columns.Add("Currency", "Валюта");
            ratesGrid.Columns.Add("Rate", "Курс к USD");

            Controls.Add(ratesGrid);

            // Заполняем валюты
            string[] currencies =
            {
                "USD",
                "EUR",
                "RUB",
                "GBP",
                "CNY",
                "JPY"
            };

            comboFrom.Items.AddRange(currencies);
            comboTo.Items.AddRange(currencies);

            comboFrom.SelectedItem = "USD";
            comboTo.SelectedItem = "RUB";
        }

        private async Task LoadRates()
        {
            try
            {
                labelStatus.Text = "Загрузка...";

                buttonRefresh.Enabled = false;
                buttonConvert.Enabled = false;

                string url = "https://open.er-api.com/v6/latest/USD";

                string json = await httpClient.GetStringAsync(url);

                using JsonDocument document = JsonDocument.Parse(json);

                JsonElement root = document.RootElement;

                if (!root.TryGetProperty("result", out JsonElement result))
                {
                    throw new Exception("Сервер вернул неправильный ответ.");
                }

                if (result.GetString() != "success")
                {
                    throw new Exception("Не удалось получить курсы валют.");
                }

                JsonElement ratesElement = root.GetProperty("rates");

                rates.Clear();

                foreach (JsonProperty property in ratesElement.EnumerateObject())
                {
                    if (property.Value.TryGetDecimal(out decimal value))
                    {
                        rates[property.Name] = value;
                    }
                }

                UpdateRatesTable();

                labelStatus.Text =
                    "Курсы обновлены: " + DateTime.Now.ToString("dd.MM.yyyy HH:mm:ss");

                buttonConvert.Enabled = true;
            }
            catch (HttpRequestException)
            {
                labelStatus.Text = "Ошибка подключения к интернету";

                MessageBox.Show(
                    "Не удалось получить курсы валют.\n\nПроверь подключение к интернету.",
                    "Ошибка",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
            catch (Exception ex)
            {
                labelStatus.Text = "Ошибка загрузки";

                MessageBox.Show(
                    "Произошла ошибка:\n\n" + ex.Message,
                    "Ошибка",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
            finally
            {
                buttonRefresh.Enabled = true;
                buttonConvert.Enabled = rates.Count > 0;
            }
        }

        private void UpdateRatesTable()
        {
            ratesGrid.Rows.Clear();

            string[] currencies =
            {
                "USD",
                "EUR",
                "RUB",
                "GBP",
                "CNY",
                "JPY"
            };

            foreach (string currency in currencies)
            {
                if (rates.TryGetValue(currency, out decimal rate))
                {
                    ratesGrid.Rows.Add(
                        currency,
                        rate.ToString("0.####", CultureInfo.InvariantCulture)
                    );
                }
            }
        }

        private void ButtonConvert_Click(object sender, EventArgs e)
        {
            try
            {
                if (rates.Count == 0)
                {
                    MessageBox.Show(
                        "Курсы валют ещё не загружены.",
                        "Ошибка",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning
                    );

                    return;
                }

                if (!decimal.TryParse(
                    textAmount.Text.Replace(',', '.'),
                    NumberStyles.Any,
                    CultureInfo.InvariantCulture,
                    out decimal amount))
                {
                    MessageBox.Show(
                        "Введите корректную сумму.",
                        "Ошибка",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning
                    );

                    textAmount.Focus();
                    return;
                }

                if (amount < 0)
                {
                    MessageBox.Show(
                        "Сумма не может быть отрицательной.",
                        "Ошибка",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning
                    );

                    return;
                }

                string fromCurrency = comboFrom.SelectedItem?.ToString();
                string toCurrency = comboTo.SelectedItem?.ToString();

                if (string.IsNullOrEmpty(fromCurrency) ||
                    string.IsNullOrEmpty(toCurrency))
                {
                    MessageBox.Show(
                        "Выберите валюты.",
                        "Ошибка",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning
                    );

                    return;
                }

                if (!rates.ContainsKey(fromCurrency) ||
                    !rates.ContainsKey(toCurrency))
                {
                    MessageBox.Show(
                        "Для выбранной валюты отсутствует курс.",
                        "Ошибка",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning
                    );

                    return;
                }

                decimal fromRate = rates[fromCurrency];
                decimal toRate = rates[toCurrency];

                // Переводим сначала в USD,
                // затем из USD в нужную валюту.
                decimal amountInUsd = amount / fromRate;
                decimal result = amountInUsd * toRate;

                labelResult.Text =
                    $"{amount:N2} {fromCurrency} = {result:N2} {toCurrency}";
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    "Ошибка при конвертации:\n\n" + ex.Message,
                    "Ошибка",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
        }

        protected override void OnFormClosed(FormClosedEventArgs e)
        {
            httpClient.Dispose();
            base.OnFormClosed(e);
        }
    }
}
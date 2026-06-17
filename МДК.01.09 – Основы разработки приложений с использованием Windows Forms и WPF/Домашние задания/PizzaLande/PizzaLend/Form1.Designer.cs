namespace PizzaLend
{
    partial class PizzaTime
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(PizzaTime));
            tabPay = new TabPage();
            flowLayoutPanel1 = new FlowLayoutPanel();
            tabOrder = new TabPage();
            splitContainer1 = new SplitContainer();
            tableLayoutPanel1 = new TableLayoutPanel();
            panelPizza1 = new Panel();
            pictureBoxPizza1 = new PictureBox();
            lblPizza1 = new Label();
            lblDiscriptionPizza1 = new Label();
            panel1 = new Panel();
            pictureBox1 = new PictureBox();
            label5 = new Label();
            label4 = new Label();
            panel2 = new Panel();
            pictureBox2 = new PictureBox();
            label7 = new Label();
            label6 = new Label();
            tableLayoutPanel2 = new TableLayoutPanel();
            numericUpDownCount = new NumericUpDown();
            label9 = new Label();
            btnOrderPizza = new Button();
            btnAddPizza = new Button();
            comboBoxOrder = new ComboBox();
            checkedListBoxAddities = new CheckedListBox();
            comboBoxPizzas = new ComboBox();
            label8 = new Label();
            label10 = new Label();
            tabRegister = new TabPage();
            tabLogin = new TabPage();
            groupBoxLogin = new GroupBox();
            tableLayoutLogin = new TableLayoutPanel();
            lblLoginError = new Label();
            tBxPassword = new TextBox();
            tBxEmail = new TextBox();
            label1 = new Label();
            label2 = new Label();
            btnLogin = new Button();
            tabControl = new TabControl();
            tabPay.SuspendLayout();
            tabOrder.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)splitContainer1).BeginInit();
            splitContainer1.Panel1.SuspendLayout();
            splitContainer1.Panel2.SuspendLayout();
            splitContainer1.SuspendLayout();
            tableLayoutPanel1.SuspendLayout();
            panelPizza1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)pictureBoxPizza1).BeginInit();
            panel1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)pictureBox1).BeginInit();
            panel2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)pictureBox2).BeginInit();
            tableLayoutPanel2.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)numericUpDownCount).BeginInit();
            tabLogin.SuspendLayout();
            groupBoxLogin.SuspendLayout();
            tableLayoutLogin.SuspendLayout();
            tabControl.SuspendLayout();
            SuspendLayout();
            // 
            // tabPay
            // 
            tabPay.BackColor = Color.MediumPurple;
            tabPay.BackgroundImageLayout = ImageLayout.None;
            tabPay.Controls.Add(flowLayoutPanel1);
            tabPay.Location = new Point(4, 29);
            tabPay.Margin = new Padding(3, 2, 3, 2);
            tabPay.Name = "tabPay";
            tabPay.Size = new Size(676, 539);
            tabPay.TabIndex = 2;
            tabPay.Text = "Pay";
            // 
            // flowLayoutPanel1
            // 
            flowLayoutPanel1.Dock = DockStyle.Fill;
            flowLayoutPanel1.FlowDirection = FlowDirection.TopDown;
            flowLayoutPanel1.Location = new Point(0, 0);
            flowLayoutPanel1.Margin = new Padding(3, 2, 3, 2);
            flowLayoutPanel1.Name = "flowLayoutPanel1";
            flowLayoutPanel1.Padding = new Padding(44, 38, 44, 38);
            flowLayoutPanel1.RightToLeft = RightToLeft.No;
            flowLayoutPanel1.Size = new Size(676, 539);
            flowLayoutPanel1.TabIndex = 0;
            // 
            // tabOrder
            // 
            tabOrder.BackColor = Color.MediumPurple;
            tabOrder.Controls.Add(splitContainer1);
            tabOrder.Location = new Point(4, 29);
            tabOrder.Margin = new Padding(3, 2, 3, 2);
            tabOrder.Name = "tabOrder";
            tabOrder.Padding = new Padding(3, 2, 3, 2);
            tabOrder.Size = new Size(676, 539);
            tabOrder.TabIndex = 1;
            tabOrder.Text = "Order";
            // 
            // splitContainer1
            // 
            splitContainer1.Dock = DockStyle.Fill;
            splitContainer1.Location = new Point(3, 2);
            splitContainer1.Margin = new Padding(3, 2, 3, 2);
            splitContainer1.Name = "splitContainer1";
            // 
            // splitContainer1.Panel1
            // 
            splitContainer1.Panel1.Controls.Add(tableLayoutPanel2);
            // 
            // splitContainer1.Panel2
            // 
            splitContainer1.Panel2.Controls.Add(tableLayoutPanel1);
            splitContainer1.Size = new Size(670, 535);
            splitContainer1.SplitterDistance = 261;
            splitContainer1.TabIndex = 0;
            // 
            // tableLayoutPanel1
            // 
            tableLayoutPanel1.BackColor = Color.MediumTurquoise;
            tableLayoutPanel1.ColumnCount = 1;
            tableLayoutPanel1.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));
            tableLayoutPanel1.Controls.Add(panel2, 0, 2);
            tableLayoutPanel1.Controls.Add(panel1, 0, 1);
            tableLayoutPanel1.Controls.Add(panelPizza1, 0, 0);
            tableLayoutPanel1.Dock = DockStyle.Fill;
            tableLayoutPanel1.Location = new Point(0, 0);
            tableLayoutPanel1.Margin = new Padding(3, 2, 3, 2);
            tableLayoutPanel1.Name = "tableLayoutPanel1";
            tableLayoutPanel1.Padding = new Padding(4);
            tableLayoutPanel1.RowCount = 5;
            tableLayoutPanel1.RowStyles.Add(new RowStyle(SizeType.Percent, 20F));
            tableLayoutPanel1.RowStyles.Add(new RowStyle(SizeType.Percent, 20F));
            tableLayoutPanel1.RowStyles.Add(new RowStyle(SizeType.Percent, 20F));
            tableLayoutPanel1.RowStyles.Add(new RowStyle(SizeType.Percent, 20F));
            tableLayoutPanel1.RowStyles.Add(new RowStyle(SizeType.Percent, 20F));
            tableLayoutPanel1.Size = new Size(405, 535);
            tableLayoutPanel1.TabIndex = 1;
            tableLayoutPanel1.Paint += tableLayoutPanel1_Paint;
            // 
            // panelPizza1
            // 
            panelPizza1.BackColor = Color.MediumSlateBlue;
            panelPizza1.Controls.Add(lblDiscriptionPizza1);
            panelPizza1.Controls.Add(lblPizza1);
            panelPizza1.Controls.Add(pictureBoxPizza1);
            panelPizza1.Dock = DockStyle.Fill;
            panelPizza1.Location = new Point(7, 6);
            panelPizza1.Margin = new Padding(3, 2, 3, 2);
            panelPizza1.Name = "panelPizza1";
            panelPizza1.Padding = new Padding(9, 8, 9, 8);
            panelPizza1.Size = new Size(391, 101);
            panelPizza1.TabIndex = 0;
            // 
            // pictureBoxPizza1
            // 
            pictureBoxPizza1.Dock = DockStyle.Left;
            pictureBoxPizza1.Image = Properties.Resources.pipironi;
            pictureBoxPizza1.Location = new Point(9, 8);
            pictureBoxPizza1.Margin = new Padding(3, 2, 3, 2);
            pictureBoxPizza1.Name = "pictureBoxPizza1";
            pictureBoxPizza1.Size = new Size(102, 85);
            pictureBoxPizza1.SizeMode = PictureBoxSizeMode.Zoom;
            pictureBoxPizza1.TabIndex = 0;
            pictureBoxPizza1.TabStop = false;
            // 
            // lblPizza1
            // 
            lblPizza1.AutoSize = true;
            lblPizza1.Dock = DockStyle.Top;
            lblPizza1.Font = new Font("Segoe UI", 15F, FontStyle.Bold);
            lblPizza1.ForeColor = Color.White;
            lblPizza1.Location = new Point(111, 8);
            lblPizza1.Name = "lblPizza1";
            lblPizza1.Size = new Size(98, 28);
            lblPizza1.TabIndex = 1;
            lblPizza1.Text = "PIPIRONI";
            // 
            // lblDiscriptionPizza1
            // 
            lblDiscriptionPizza1.AutoSize = true;
            lblDiscriptionPizza1.Dock = DockStyle.Fill;
            lblDiscriptionPizza1.Font = new Font("Segoe UI", 12F);
            lblDiscriptionPizza1.ForeColor = Color.Snow;
            lblDiscriptionPizza1.Location = new Point(111, 36);
            lblDiscriptionPizza1.Name = "lblDiscriptionPizza1";
            lblDiscriptionPizza1.Size = new Size(99, 21);
            lblDiscriptionPizza1.TabIndex = 2;
            lblDiscriptionPizza1.Text = "Pizza for you";
            // 
            // panel1
            // 
            panel1.BackColor = Color.MediumSlateBlue;
            panel1.Controls.Add(label4);
            panel1.Controls.Add(label5);
            panel1.Controls.Add(pictureBox1);
            panel1.Dock = DockStyle.Fill;
            panel1.Location = new Point(7, 111);
            panel1.Margin = new Padding(3, 2, 3, 2);
            panel1.Name = "panel1";
            panel1.Padding = new Padding(9, 8, 9, 8);
            panel1.Size = new Size(391, 101);
            panel1.TabIndex = 1;
            // 
            // pictureBox1
            // 
            pictureBox1.Dock = DockStyle.Left;
            pictureBox1.Image = Properties.Resources.Four_cheese;
            pictureBox1.Location = new Point(9, 8);
            pictureBox1.Margin = new Padding(3, 2, 3, 2);
            pictureBox1.Name = "pictureBox1";
            pictureBox1.Size = new Size(102, 85);
            pictureBox1.SizeMode = PictureBoxSizeMode.Zoom;
            pictureBox1.TabIndex = 0;
            pictureBox1.TabStop = false;
            // 
            // label5
            // 
            label5.AutoSize = true;
            label5.Dock = DockStyle.Top;
            label5.Font = new Font("Segoe UI", 15F, FontStyle.Bold);
            label5.ForeColor = Color.White;
            label5.Location = new Point(111, 8);
            label5.Name = "label5";
            label5.Size = new Size(141, 28);
            label5.TabIndex = 1;
            label5.Text = "FOUR CHEESE";
            // 
            // label4
            // 
            label4.AutoSize = true;
            label4.Dock = DockStyle.Fill;
            label4.Font = new Font("Segoe UI", 12F);
            label4.ForeColor = Color.Snow;
            label4.Location = new Point(111, 36);
            label4.Name = "label4";
            label4.Size = new Size(99, 21);
            label4.TabIndex = 2;
            label4.Text = "Pizza for you";
            // 
            // panel2
            // 
            panel2.BackColor = Color.MediumSlateBlue;
            panel2.Controls.Add(label6);
            panel2.Controls.Add(label7);
            panel2.Controls.Add(pictureBox2);
            panel2.Dock = DockStyle.Fill;
            panel2.Location = new Point(7, 216);
            panel2.Margin = new Padding(3, 2, 3, 2);
            panel2.Name = "panel2";
            panel2.Padding = new Padding(9, 8, 9, 8);
            panel2.Size = new Size(391, 101);
            panel2.TabIndex = 2;
            panel2.Paint += panel2_Paint;
            // 
            // pictureBox2
            // 
            pictureBox2.Dock = DockStyle.Left;
            pictureBox2.Image = Properties.Resources.Margarita;
            pictureBox2.Location = new Point(9, 8);
            pictureBox2.Margin = new Padding(3, 2, 3, 2);
            pictureBox2.Name = "pictureBox2";
            pictureBox2.Size = new Size(102, 85);
            pictureBox2.SizeMode = PictureBoxSizeMode.Zoom;
            pictureBox2.TabIndex = 0;
            pictureBox2.TabStop = false;
            // 
            // label7
            // 
            label7.AutoSize = true;
            label7.Dock = DockStyle.Top;
            label7.Font = new Font("Segoe UI", 15F, FontStyle.Bold);
            label7.ForeColor = Color.White;
            label7.Location = new Point(111, 8);
            label7.Name = "label7";
            label7.Size = new Size(130, 28);
            label7.TabIndex = 1;
            label7.Text = "MARGARITA";
            // 
            // label6
            // 
            label6.AutoSize = true;
            label6.Dock = DockStyle.Fill;
            label6.Font = new Font("Segoe UI", 12F);
            label6.ForeColor = Color.Snow;
            label6.Location = new Point(111, 36);
            label6.Name = "label6";
            label6.Size = new Size(99, 21);
            label6.TabIndex = 2;
            label6.Text = "Pizza for you";
            // 
            // tableLayoutPanel2
            // 
            tableLayoutPanel2.BackColor = Color.MediumTurquoise;
            tableLayoutPanel2.ColumnCount = 1;
            tableLayoutPanel2.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));
            tableLayoutPanel2.Controls.Add(label10, 0, 4);
            tableLayoutPanel2.Controls.Add(label8, 0, 0);
            tableLayoutPanel2.Controls.Add(comboBoxPizzas, 0, 1);
            tableLayoutPanel2.Controls.Add(checkedListBoxAddities, 0, 5);
            tableLayoutPanel2.Controls.Add(comboBoxOrder, 0, 7);
            tableLayoutPanel2.Controls.Add(btnAddPizza, 0, 8);
            tableLayoutPanel2.Controls.Add(btnOrderPizza, 0, 9);
            tableLayoutPanel2.Controls.Add(label9, 0, 2);
            tableLayoutPanel2.Controls.Add(numericUpDownCount, 0, 3);
            tableLayoutPanel2.Dock = DockStyle.Fill;
            tableLayoutPanel2.Location = new Point(0, 0);
            tableLayoutPanel2.Margin = new Padding(3, 2, 3, 2);
            tableLayoutPanel2.Name = "tableLayoutPanel2";
            tableLayoutPanel2.Padding = new Padding(9, 8, 9, 8);
            tableLayoutPanel2.RowCount = 10;
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 10F));
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 10F));
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 10F));
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 10F));
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 10F));
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 10F));
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 10F));
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 10F));
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 10F));
            tableLayoutPanel2.RowStyles.Add(new RowStyle(SizeType.Percent, 10F));
            tableLayoutPanel2.Size = new Size(261, 535);
            tableLayoutPanel2.TabIndex = 0;
            // 
            // numericUpDownCount
            // 
            numericUpDownCount.Location = new Point(12, 163);
            numericUpDownCount.Margin = new Padding(3, 2, 3, 2);
            numericUpDownCount.Maximum = new decimal(new int[] { 10, 0, 0, 0 });
            numericUpDownCount.Minimum = new decimal(new int[] { 1, 0, 0, 0 });
            numericUpDownCount.Name = "numericUpDownCount";
            numericUpDownCount.Size = new Size(35, 25);
            numericUpDownCount.TabIndex = 3;
            numericUpDownCount.Value = new decimal(new int[] { 1, 0, 0, 0 });
            // 
            // label9
            // 
            label9.AutoSize = true;
            label9.Dock = DockStyle.Bottom;
            label9.Font = new Font("Segoe UI", 12F, FontStyle.Bold);
            label9.ForeColor = Color.White;
            label9.Location = new Point(12, 140);
            label9.Name = "label9";
            label9.Size = new Size(237, 21);
            label9.TabIndex = 9;
            label9.Text = "Count pizzas";
            // 
            // btnOrderPizza
            // 
            btnOrderPizza.BackColor = Color.CornflowerBlue;
            btnOrderPizza.Dock = DockStyle.Fill;
            btnOrderPizza.FlatStyle = FlatStyle.Flat;
            btnOrderPizza.Font = new Font("Segoe UI", 15F, FontStyle.Bold);
            btnOrderPizza.ForeColor = Color.White;
            btnOrderPizza.Location = new Point(18, 475);
            btnOrderPizza.Margin = new Padding(9, 8, 9, 8);
            btnOrderPizza.Name = "btnOrderPizza";
            btnOrderPizza.Size = new Size(225, 44);
            btnOrderPizza.TabIndex = 8;
            btnOrderPizza.Text = "ORDER";
            btnOrderPizza.UseVisualStyleBackColor = false;
            btnOrderPizza.Click += btnOrderPizza_Click;
            // 
            // btnAddPizza
            // 
            btnAddPizza.BackColor = Color.CornflowerBlue;
            btnAddPizza.Dock = DockStyle.Fill;
            btnAddPizza.FlatStyle = FlatStyle.Flat;
            btnAddPizza.Font = new Font("Segoe UI", 15F, FontStyle.Bold);
            btnAddPizza.ForeColor = Color.White;
            btnAddPizza.Location = new Point(18, 424);
            btnAddPizza.Margin = new Padding(9, 8, 9, 8);
            btnAddPizza.Name = "btnAddPizza";
            btnAddPizza.Size = new Size(225, 35);
            btnAddPizza.TabIndex = 7;
            btnAddPizza.Text = "ADD PIZZA";
            btnAddPizza.UseVisualStyleBackColor = false;
            btnAddPizza.Click += btnAddPizza_Click;
            // 
            // comboBoxOrder
            // 
            comboBoxOrder.Dock = DockStyle.Fill;
            comboBoxOrder.FormattingEnabled = true;
            comboBoxOrder.Location = new Point(12, 367);
            comboBoxOrder.Margin = new Padding(3, 2, 3, 2);
            comboBoxOrder.Name = "comboBoxOrder";
            comboBoxOrder.Size = new Size(237, 25);
            comboBoxOrder.TabIndex = 6;
            // 
            // checkedListBoxAddities
            // 
            checkedListBoxAddities.Dock = DockStyle.Fill;
            checkedListBoxAddities.FormattingEnabled = true;
            checkedListBoxAddities.Items.AddRange(new object[] { "Double Cheese", "Mayo", "Tomate", "Onion", "Peper", "Cucumber", "" });
            checkedListBoxAddities.Location = new Point(12, 265);
            checkedListBoxAddities.Margin = new Padding(3, 2, 3, 2);
            checkedListBoxAddities.Name = "checkedListBoxAddities";
            tableLayoutPanel2.SetRowSpan(checkedListBoxAddities, 2);
            checkedListBoxAddities.Size = new Size(237, 98);
            checkedListBoxAddities.TabIndex = 5;
            checkedListBoxAddities.SelectedIndexChanged += checkedListBoxAddities_SelectedIndexChanged;
            // 
            // comboBoxPizzas
            // 
            comboBoxPizzas.BackColor = Color.Plum;
            comboBoxPizzas.Dock = DockStyle.Fill;
            comboBoxPizzas.FlatStyle = FlatStyle.Flat;
            comboBoxPizzas.Font = new Font("Segoe UI", 11F);
            comboBoxPizzas.ForeColor = SystemColors.Window;
            comboBoxPizzas.FormattingEnabled = true;
            comboBoxPizzas.Items.AddRange(new object[] { "PIPIRONI", "FOUR CHEESE", "MARGARITA" });
            comboBoxPizzas.Location = new Point(12, 61);
            comboBoxPizzas.Margin = new Padding(3, 2, 3, 2);
            comboBoxPizzas.Name = "comboBoxPizzas";
            comboBoxPizzas.Size = new Size(237, 28);
            comboBoxPizzas.TabIndex = 1;
            // 
            // label8
            // 
            label8.AutoSize = true;
            label8.Dock = DockStyle.Bottom;
            label8.Font = new Font("Segoe UI", 12F, FontStyle.Bold);
            label8.ForeColor = Color.White;
            label8.Location = new Point(12, 38);
            label8.Name = "label8";
            label8.Size = new Size(237, 21);
            label8.TabIndex = 0;
            label8.Text = "Type of pizza";
            // 
            // label10
            // 
            label10.AutoSize = true;
            label10.Dock = DockStyle.Bottom;
            label10.Font = new Font("Segoe UI", 12F, FontStyle.Bold);
            label10.ForeColor = Color.White;
            label10.Location = new Point(12, 242);
            label10.Name = "label10";
            label10.Size = new Size(237, 21);
            label10.TabIndex = 10;
            label10.Text = "Addities";
            // 
            // tabRegister
            // 
            tabRegister.BackColor = Color.MediumSlateBlue;
            tabRegister.Location = new Point(4, 29);
            tabRegister.Margin = new Padding(3, 2, 3, 2);
            tabRegister.Name = "tabRegister";
            tabRegister.Padding = new Padding(88, 75, 88, 75);
            tabRegister.Size = new Size(676, 539);
            tabRegister.TabIndex = 3;
            tabRegister.Text = "Sing Up";
            // 
            // tabLogin
            // 
            tabLogin.BackColor = Color.DarkSlateBlue;
            tabLogin.Controls.Add(groupBoxLogin);
            tabLogin.ForeColor = Color.Black;
            tabLogin.Location = new Point(4, 29);
            tabLogin.Margin = new Padding(3, 2, 3, 2);
            tabLogin.Name = "tabLogin";
            tabLogin.Padding = new Padding(175, 150, 175, 150);
            tabLogin.Size = new Size(676, 539);
            tabLogin.TabIndex = 0;
            tabLogin.Text = "Login";
            // 
            // groupBoxLogin
            // 
            groupBoxLogin.Controls.Add(tableLayoutLogin);
            groupBoxLogin.Dock = DockStyle.Fill;
            groupBoxLogin.Font = new Font("Segoe UI", 20F, FontStyle.Bold);
            groupBoxLogin.ForeColor = Color.White;
            groupBoxLogin.Location = new Point(175, 150);
            groupBoxLogin.Margin = new Padding(3, 2, 3, 2);
            groupBoxLogin.Name = "groupBoxLogin";
            groupBoxLogin.Padding = new Padding(26, 11, 26, 11);
            groupBoxLogin.Size = new Size(326, 239);
            groupBoxLogin.TabIndex = 0;
            groupBoxLogin.TabStop = false;
            groupBoxLogin.Text = "Login";
            // 
            // tableLayoutLogin
            // 
            tableLayoutLogin.ColumnCount = 4;
            tableLayoutLogin.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 25F));
            tableLayoutLogin.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 25F));
            tableLayoutLogin.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 25F));
            tableLayoutLogin.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 25F));
            tableLayoutLogin.Controls.Add(btnLogin, 1, 5);
            tableLayoutLogin.Controls.Add(label2, 0, 3);
            tableLayoutLogin.Controls.Add(label1, 0, 1);
            tableLayoutLogin.Controls.Add(tBxEmail, 1, 1);
            tableLayoutLogin.Controls.Add(tBxPassword, 1, 3);
            tableLayoutLogin.Controls.Add(lblLoginError, 1, 4);
            tableLayoutLogin.Dock = DockStyle.Fill;
            tableLayoutLogin.Location = new Point(26, 47);
            tableLayoutLogin.Margin = new Padding(3, 2, 3, 2);
            tableLayoutLogin.Name = "tableLayoutLogin";
            tableLayoutLogin.RowCount = 6;
            tableLayoutLogin.RowStyles.Add(new RowStyle(SizeType.Percent, 16.666666F));
            tableLayoutLogin.RowStyles.Add(new RowStyle(SizeType.Percent, 16.666666F));
            tableLayoutLogin.RowStyles.Add(new RowStyle(SizeType.Percent, 16.666666F));
            tableLayoutLogin.RowStyles.Add(new RowStyle(SizeType.Percent, 16.666666F));
            tableLayoutLogin.RowStyles.Add(new RowStyle(SizeType.Percent, 16.666666F));
            tableLayoutLogin.RowStyles.Add(new RowStyle(SizeType.Percent, 16.666666F));
            tableLayoutLogin.Size = new Size(274, 181);
            tableLayoutLogin.TabIndex = 5;
            // 
            // lblLoginError
            // 
            lblLoginError.AutoSize = true;
            tableLayoutLogin.SetColumnSpan(lblLoginError, 2);
            lblLoginError.Dock = DockStyle.Fill;
            lblLoginError.Font = new Font("Segoe UI", 8F, FontStyle.Bold);
            lblLoginError.ForeColor = Color.Red;
            lblLoginError.Location = new Point(71, 120);
            lblLoginError.Name = "lblLoginError";
            lblLoginError.Size = new Size(130, 30);
            lblLoginError.TabIndex = 5;
            lblLoginError.Text = "Incorrect data";
            lblLoginError.TextAlign = ContentAlignment.MiddleCenter;
            lblLoginError.Visible = false;
            // 
            // tBxPassword
            // 
            tableLayoutLogin.SetColumnSpan(tBxPassword, 3);
            tBxPassword.Dock = DockStyle.Fill;
            tBxPassword.Font = new Font("Segoe UI", 15F, FontStyle.Bold);
            tBxPassword.Location = new Point(71, 92);
            tBxPassword.Margin = new Padding(3, 2, 3, 2);
            tBxPassword.Name = "tBxPassword";
            tBxPassword.Size = new Size(200, 34);
            tBxPassword.TabIndex = 1;
            // 
            // tBxEmail
            // 
            tableLayoutLogin.SetColumnSpan(tBxEmail, 3);
            tBxEmail.Dock = DockStyle.Fill;
            tBxEmail.Font = new Font("Segoe UI", 15F, FontStyle.Bold);
            tBxEmail.Location = new Point(71, 32);
            tBxEmail.Margin = new Padding(3, 2, 3, 2);
            tBxEmail.Name = "tBxEmail";
            tBxEmail.Size = new Size(200, 34);
            tBxEmail.TabIndex = 0;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Dock = DockStyle.Right;
            label1.Font = new Font("Segoe UI", 7F, FontStyle.Bold);
            label1.Location = new Point(31, 30);
            label1.Name = "label1";
            label1.Size = new Size(34, 30);
            label1.TabIndex = 3;
            label1.Text = "e-mail";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Dock = DockStyle.Right;
            label2.Font = new Font("Segoe UI", 7F, FontStyle.Bold);
            label2.Location = new Point(17, 90);
            label2.Name = "label2";
            label2.Size = new Size(48, 30);
            label2.TabIndex = 4;
            label2.Text = "password";
            // 
            // btnLogin
            // 
            btnLogin.BackColor = Color.CornflowerBlue;
            tableLayoutLogin.SetColumnSpan(btnLogin, 2);
            btnLogin.Dock = DockStyle.Fill;
            btnLogin.FlatStyle = FlatStyle.Flat;
            btnLogin.Font = new Font("Segoe UI", 15F, FontStyle.Bold);
            btnLogin.Location = new Point(71, 152);
            btnLogin.Margin = new Padding(3, 2, 3, 2);
            btnLogin.Name = "btnLogin";
            btnLogin.Size = new Size(130, 27);
            btnLogin.TabIndex = 2;
            btnLogin.Text = "LOG IN";
            btnLogin.UseVisualStyleBackColor = false;
            btnLogin.Click += btnLogin_Click;
            // 
            // tabControl
            // 
            tabControl.Controls.Add(tabLogin);
            tabControl.Controls.Add(tabRegister);
            tabControl.Controls.Add(tabOrder);
            tabControl.Controls.Add(tabPay);
            tabControl.Dock = DockStyle.Fill;
            tabControl.Font = new Font("Segoe UI", 10F, FontStyle.Bold);
            tabControl.ItemSize = new Size(60, 25);
            tabControl.Location = new Point(0, 0);
            tabControl.Margin = new Padding(3, 2, 3, 2);
            tabControl.Name = "tabControl";
            tabControl.SelectedIndex = 0;
            tabControl.Size = new Size(684, 572);
            tabControl.TabIndex = 0;
            // 
            // PizzaTime
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.Indigo;
            ClientSize = new Size(684, 572);
            Controls.Add(tabControl);
            FormBorderStyle = FormBorderStyle.FixedSingle;
            Icon = (Icon)resources.GetObject("$this.Icon");
            Margin = new Padding(3, 2, 3, 2);
            Name = "PizzaTime";
            Text = "PizzaTime";
            tabPay.ResumeLayout(false);
            tabOrder.ResumeLayout(false);
            splitContainer1.Panel1.ResumeLayout(false);
            splitContainer1.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)splitContainer1).EndInit();
            splitContainer1.ResumeLayout(false);
            tableLayoutPanel1.ResumeLayout(false);
            panelPizza1.ResumeLayout(false);
            panelPizza1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)pictureBoxPizza1).EndInit();
            panel1.ResumeLayout(false);
            panel1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)pictureBox1).EndInit();
            panel2.ResumeLayout(false);
            panel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)pictureBox2).EndInit();
            tableLayoutPanel2.ResumeLayout(false);
            tableLayoutPanel2.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)numericUpDownCount).EndInit();
            tabLogin.ResumeLayout(false);
            groupBoxLogin.ResumeLayout(false);
            tableLayoutLogin.ResumeLayout(false);
            tableLayoutLogin.PerformLayout();
            tabControl.ResumeLayout(false);
            ResumeLayout(false);
        }

        #endregion

        private TabPage tabPay;
        private FlowLayoutPanel flowLayoutPanel1;
        private TabPage tabOrder;
        private SplitContainer splitContainer1;
        private TableLayoutPanel tableLayoutPanel2;
        private Label label10;
        private Label label8;
        private ComboBox comboBoxPizzas;
        private CheckedListBox checkedListBoxAddities;
        private ComboBox comboBoxOrder;
        private Button btnAddPizza;
        private Button btnOrderPizza;
        private Label label9;
        private NumericUpDown numericUpDownCount;
        private TableLayoutPanel tableLayoutPanel1;
        private Panel panel2;
        private Label label6;
        private Label label7;
        private PictureBox pictureBox2;
        private Panel panel1;
        private Label label4;
        private Label label5;
        private PictureBox pictureBox1;
        private Panel panelPizza1;
        private Label lblDiscriptionPizza1;
        private Label lblPizza1;
        private PictureBox pictureBoxPizza1;
        private TabPage tabRegister;
        private TabPage tabLogin;
        private GroupBox groupBoxLogin;
        private TableLayoutPanel tableLayoutLogin;
        private Button btnLogin;
        private Label label2;
        private Label label1;
        private TextBox tBxEmail;
        private TextBox tBxPassword;
        private Label lblLoginError;
        private TabControl tabControl;
    }
}

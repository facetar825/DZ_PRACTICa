namespace comp_info
{
    partial class Form1
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
            components = new System.ComponentModel.Container();
            tableLayoutPanel1 = new TableLayoutPanel();
            label2 = new Label();
            label3 = new Label();
            label4 = new Label();
            label5 = new Label();
            pbCpu = new ProgressBar();
            pbGpu = new ProgressBar();
            lblCpuVal = new Label();
            lblGpuVal = new Label();
            lblRamVal = new Label();
            lblDiskVal = new Label();
            pbDisk = new ProgressBar();
            pbRam = new ProgressBar();
            timerUpdate = new System.Windows.Forms.Timer(components);
            tableLayoutPanel1.SuspendLayout();
            SuspendLayout();
            // 
            // tableLayoutPanel1
            // 
            tableLayoutPanel1.ColumnCount = 8;
            tableLayoutPanel1.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 12.5F));
            tableLayoutPanel1.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 12.5F));
            tableLayoutPanel1.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 12.5F));
            tableLayoutPanel1.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 12.5F));
            tableLayoutPanel1.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 12.5F));
            tableLayoutPanel1.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 12.5F));
            tableLayoutPanel1.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 12.5F));
            tableLayoutPanel1.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 12.5F));
            tableLayoutPanel1.Controls.Add(label2, 0, 1);
            tableLayoutPanel1.Controls.Add(label3, 2, 1);
            tableLayoutPanel1.Controls.Add(label4, 4, 1);
            tableLayoutPanel1.Controls.Add(label5, 6, 1);
            tableLayoutPanel1.Controls.Add(pbCpu, 1, 2);
            tableLayoutPanel1.Controls.Add(pbGpu, 3, 2);
            tableLayoutPanel1.Controls.Add(lblCpuVal, 0, 2);
            tableLayoutPanel1.Controls.Add(lblGpuVal, 2, 2);
            tableLayoutPanel1.Controls.Add(lblRamVal, 4, 2);
            tableLayoutPanel1.Controls.Add(lblDiskVal, 6, 2);
            tableLayoutPanel1.Controls.Add(pbDisk, 7, 2);
            tableLayoutPanel1.Controls.Add(pbRam, 5, 2);
            tableLayoutPanel1.Dock = DockStyle.Fill;
            tableLayoutPanel1.Location = new Point(0, 0);
            tableLayoutPanel1.Name = "tableLayoutPanel1";
            tableLayoutPanel1.RowCount = 4;
            tableLayoutPanel1.RowStyles.Add(new RowStyle(SizeType.Percent, 21.11111F));
            tableLayoutPanel1.RowStyles.Add(new RowStyle(SizeType.Percent, 40.88889F));
            tableLayoutPanel1.RowStyles.Add(new RowStyle(SizeType.Percent, 8.444445F));
            tableLayoutPanel1.RowStyles.Add(new RowStyle(SizeType.Percent, 29.333334F));
            tableLayoutPanel1.Size = new Size(800, 450);
            tableLayoutPanel1.TabIndex = 0;
            // 
            // label2
            // 
            label2.AutoSize = true;
            tableLayoutPanel1.SetColumnSpan(label2, 2);
            label2.Dock = DockStyle.Fill;
            label2.Font = new Font("Segoe UI Light", 18F, FontStyle.Bold);
            label2.Location = new Point(3, 95);
            label2.Name = "label2";
            label2.Size = new Size(194, 184);
            label2.TabIndex = 1;
            label2.Text = "CPU usage";
            label2.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // label3
            // 
            label3.AutoSize = true;
            tableLayoutPanel1.SetColumnSpan(label3, 2);
            label3.Dock = DockStyle.Fill;
            label3.Font = new Font("Segoe UI Light", 18F, FontStyle.Bold);
            label3.Location = new Point(203, 95);
            label3.Name = "label3";
            label3.Size = new Size(194, 184);
            label3.TabIndex = 2;
            label3.Text = "GPU usage";
            label3.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // label4
            // 
            label4.AutoSize = true;
            tableLayoutPanel1.SetColumnSpan(label4, 2);
            label4.Dock = DockStyle.Fill;
            label4.Font = new Font("Segoe UI Light", 18F, FontStyle.Bold);
            label4.Location = new Point(403, 95);
            label4.Name = "label4";
            label4.Size = new Size(194, 184);
            label4.TabIndex = 3;
            label4.Text = "RAM usage";
            label4.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // label5
            // 
            label5.AutoSize = true;
            tableLayoutPanel1.SetColumnSpan(label5, 2);
            label5.Dock = DockStyle.Fill;
            label5.Font = new Font("Segoe UI Light", 18F, FontStyle.Bold);
            label5.Location = new Point(603, 95);
            label5.Name = "label5";
            label5.Size = new Size(194, 184);
            label5.TabIndex = 4;
            label5.Text = "Disk usage";
            label5.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // pbCpu
            // 
            pbCpu.Dock = DockStyle.Fill;
            pbCpu.Location = new Point(103, 282);
            pbCpu.Name = "pbCpu";
            pbCpu.Size = new Size(94, 32);
            pbCpu.TabIndex = 5;
            // 
            // pbGpu
            // 
            pbGpu.Dock = DockStyle.Fill;
            pbGpu.Location = new Point(303, 282);
            pbGpu.Name = "pbGpu";
            pbGpu.Size = new Size(94, 32);
            pbGpu.TabIndex = 6;
            // 
            // lblCpuVal
            // 
            lblCpuVal.AutoSize = true;
            lblCpuVal.Dock = DockStyle.Fill;
            lblCpuVal.Font = new Font("Segoe UI", 20F);
            lblCpuVal.Location = new Point(3, 279);
            lblCpuVal.Name = "lblCpuVal";
            lblCpuVal.Size = new Size(94, 38);
            lblCpuVal.TabIndex = 8;
            lblCpuVal.Text = "0";
            lblCpuVal.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // lblGpuVal
            // 
            lblGpuVal.AutoSize = true;
            lblGpuVal.Dock = DockStyle.Fill;
            lblGpuVal.Font = new Font("Segoe UI", 20F);
            lblGpuVal.Location = new Point(203, 279);
            lblGpuVal.Name = "lblGpuVal";
            lblGpuVal.Size = new Size(94, 38);
            lblGpuVal.TabIndex = 9;
            lblGpuVal.Text = "0";
            lblGpuVal.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // lblRamVal
            // 
            lblRamVal.AutoSize = true;
            lblRamVal.Dock = DockStyle.Fill;
            lblRamVal.Font = new Font("Segoe UI", 20F);
            lblRamVal.Location = new Point(403, 279);
            lblRamVal.Name = "lblRamVal";
            lblRamVal.Size = new Size(94, 38);
            lblRamVal.TabIndex = 10;
            lblRamVal.Text = "0";
            lblRamVal.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // lblDiskVal
            // 
            lblDiskVal.AutoSize = true;
            lblDiskVal.Dock = DockStyle.Fill;
            lblDiskVal.Font = new Font("Segoe UI", 20F);
            lblDiskVal.Location = new Point(603, 279);
            lblDiskVal.Name = "lblDiskVal";
            lblDiskVal.Size = new Size(94, 38);
            lblDiskVal.TabIndex = 11;
            lblDiskVal.Text = "0";
            lblDiskVal.TextAlign = ContentAlignment.MiddleCenter;
            // 
            // pbDisk
            // 
            pbDisk.Dock = DockStyle.Fill;
            pbDisk.Location = new Point(703, 282);
            pbDisk.Name = "pbDisk";
            pbDisk.Size = new Size(94, 32);
            pbDisk.TabIndex = 12;
            // 
            // pbRam
            // 
            pbRam.Dock = DockStyle.Fill;
            pbRam.Location = new Point(503, 282);
            pbRam.Name = "pbRam";
            pbRam.Size = new Size(94, 32);
            pbRam.TabIndex = 7;
            // 
            // timerUpdate
            // 
            timerUpdate.Enabled = true;
            timerUpdate.Interval = 1000;
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            BackColor = Color.White;
            ClientSize = new Size(800, 450);
            Controls.Add(tableLayoutPanel1);
            Name = "Form1";
            Text = "Form1";
            tableLayoutPanel1.ResumeLayout(false);
            tableLayoutPanel1.PerformLayout();
            ResumeLayout(false);
        }

        #endregion

        private TableLayoutPanel tableLayoutPanel1;
        private Label label2;
        private Label label3;
        private Label label4;
        private Label label5;
        private ProgressBar pbCpu;
        private ProgressBar pbGpu;
        private ProgressBar pbRam;
        private Label lblCpuVal;
        private Label lblGpuVal;
        private Label lblRamVal;
        private Label lblDiskVal;
        private ProgressBar pbDisk;
        private System.Windows.Forms.Timer timerUpdate;
    }
}

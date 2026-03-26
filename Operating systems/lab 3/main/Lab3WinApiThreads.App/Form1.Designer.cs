namespace Lab3WinApiThreads.App;

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
        groupBox1 = new GroupBox();
        btnStart = new Button();
        btnPause = new Button();
        btnStop = new Button();
        label1 = new Label();
        cmbPriority = new ComboBox();
        label2 = new Label();
        lblState = new Label();
        label3 = new Label();
        lblCounter = new Label();
        groupBox2 = new GroupBox();
        label4 = new Label();
        txtParentToChild = new TextBox();
        btnSend = new Button();
        label5 = new Label();
        txtChildToParent = new TextBox();
        groupBox1.SuspendLayout();
        groupBox2.SuspendLayout();
        SuspendLayout();
        // 
        // groupBox1
        // 
        groupBox1.Controls.Add(btnStart);
        groupBox1.Controls.Add(btnPause);
        groupBox1.Controls.Add(btnStop);
        groupBox1.Controls.Add(label1);
        groupBox1.Controls.Add(cmbPriority);
        groupBox1.Controls.Add(label2);
        groupBox1.Controls.Add(lblState);
        groupBox1.Controls.Add(label3);
        groupBox1.Controls.Add(lblCounter);
        groupBox1.Location = new Point(12, 12);
        groupBox1.Name = "groupBox1";
        groupBox1.Size = new Size(776, 150);
        groupBox1.TabIndex = 0;
        groupBox1.TabStop = false;
        groupBox1.Text = "Дочерний поток (WinAPI)";
        // 
        // btnStart
        // 
        btnStart.Location = new Point(16, 30);
        btnStart.Name = "btnStart";
        btnStart.Size = new Size(120, 35);
        btnStart.TabIndex = 0;
        btnStart.Text = "Пуск";
        btnStart.UseVisualStyleBackColor = true;
        btnStart.Click += btnStart_Click;
        // 
        // btnPause
        // 
        btnPause.Location = new Point(142, 30);
        btnPause.Name = "btnPause";
        btnPause.Size = new Size(120, 35);
        btnPause.TabIndex = 1;
        btnPause.Text = "Пауза";
        btnPause.UseVisualStyleBackColor = true;
        btnPause.Click += btnPause_Click;
        // 
        // btnStop
        // 
        btnStop.Location = new Point(268, 30);
        btnStop.Name = "btnStop";
        btnStop.Size = new Size(120, 35);
        btnStop.TabIndex = 2;
        btnStop.Text = "Стоп";
        btnStop.UseVisualStyleBackColor = true;
        btnStop.Click += btnStop_Click;
        // 
        // label1
        // 
        label1.AutoSize = true;
        label1.Location = new Point(410, 38);
        label1.Name = "label1";
        label1.Size = new Size(140, 20);
        label1.TabIndex = 3;
        label1.Text = "Приоритет потока:";
        // 
        // cmbPriority
        // 
        cmbPriority.DropDownStyle = ComboBoxStyle.DropDownList;
        cmbPriority.FormattingEnabled = true;
        cmbPriority.Location = new Point(556, 35);
        cmbPriority.Name = "cmbPriority";
        cmbPriority.Size = new Size(200, 28);
        cmbPriority.TabIndex = 4;
        cmbPriority.SelectedIndexChanged += cmbPriority_SelectedIndexChanged;
        // 
        // label2
        // 
        label2.AutoSize = true;
        label2.Location = new Point(16, 90);
        label2.Name = "label2";
        label2.Size = new Size(60, 20);
        label2.TabIndex = 5;
        label2.Text = "Статус:";
        // 
        // lblState
        // 
        lblState.AutoSize = true;
        lblState.Location = new Point(82, 90);
        lblState.Name = "lblState";
        lblState.Size = new Size(111, 20);
        lblState.TabIndex = 6;
        lblState.Text = "не запущен(а)";
        // 
        // label3
        // 
        label3.AutoSize = true;
        label3.Location = new Point(410, 90);
        label3.Name = "label3";
        label3.Size = new Size(69, 20);
        label3.TabIndex = 7;
        label3.Text = "Счётчик:";
        // 
        // lblCounter
        // 
        lblCounter.AutoSize = true;
        lblCounter.Location = new Point(485, 90);
        lblCounter.Name = "lblCounter";
        lblCounter.Size = new Size(17, 20);
        lblCounter.TabIndex = 8;
        lblCounter.Text = "0";
        // 
        // groupBox2
        // 
        groupBox2.Controls.Add(label4);
        groupBox2.Controls.Add(txtParentToChild);
        groupBox2.Controls.Add(btnSend);
        groupBox2.Controls.Add(label5);
        groupBox2.Controls.Add(txtChildToParent);
        groupBox2.Location = new Point(12, 168);
        groupBox2.Name = "groupBox2";
        groupBox2.Size = new Size(776, 130);
        groupBox2.TabIndex = 1;
        groupBox2.TabStop = false;
        groupBox2.Text = "Обмен данными (родитель ↔ дочерний)";
        // 
        // label4
        // 
        label4.AutoSize = true;
        label4.Location = new Point(16, 35);
        label4.Name = "label4";
        label4.Size = new Size(205, 20);
        label4.TabIndex = 0;
        label4.Text = "Родитель → дочерний (int):";
        // 
        // txtParentToChild
        // 
        txtParentToChild.Location = new Point(227, 32);
        txtParentToChild.Name = "txtParentToChild";
        txtParentToChild.Size = new Size(160, 27);
        txtParentToChild.TabIndex = 1;
        txtParentToChild.Text = "1";
        // 
        // btnSend
        // 
        btnSend.Location = new Point(393, 30);
        btnSend.Name = "btnSend";
        btnSend.Size = new Size(120, 30);
        btnSend.TabIndex = 2;
        btnSend.Text = "Передать";
        btnSend.UseVisualStyleBackColor = true;
        btnSend.Click += btnSend_Click;
        // 
        // label5
        // 
        label5.AutoSize = true;
        label5.Location = new Point(16, 78);
        label5.Name = "label5";
        label5.Size = new Size(205, 20);
        label5.TabIndex = 3;
        label5.Text = "Дочерний → родитель (int):";
        // 
        // txtChildToParent
        // 
        txtChildToParent.Location = new Point(227, 75);
        txtChildToParent.Name = "txtChildToParent";
        txtChildToParent.ReadOnly = true;
        txtChildToParent.Size = new Size(160, 27);
        txtChildToParent.TabIndex = 4;
        // 
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(800, 450);
        Controls.Add(groupBox2);
        Controls.Add(groupBox1);
        FormBorderStyle = FormBorderStyle.FixedSingle;
        MaximizeBox = false;
        Name = "Form1";
        Text = "ЛР3: Потоки + обмен (WinAPI)";
        FormClosing += Form1_FormClosing;
        groupBox1.ResumeLayout(false);
        groupBox1.PerformLayout();
        groupBox2.ResumeLayout(false);
        groupBox2.PerformLayout();
        ResumeLayout(false);
    }

    #endregion

    private GroupBox groupBox1;
    private Button btnStart;
    private Button btnPause;
    private Button btnStop;
    private Label label1;
    private ComboBox cmbPriority;
    private Label label2;
    private Label lblState;
    private Label label3;
    private Label lblCounter;
    private GroupBox groupBox2;
    private Label label4;
    private TextBox txtParentToChild;
    private Button btnSend;
    private Label label5;
    private TextBox txtChildToParent;
}

namespace MainApp;

partial class Form1
{
    private System.ComponentModel.IContainer components = null;

    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }
        base.Dispose(disposing);
    }

    #region Windows Form Designer generated code

    private void InitializeComponent()
    {
        calculateButton = new Button();
        showDllFormButton = new Button();
        resultLabel = new Label();
        input_a = new TextBox();
        input_b = new TextBox();
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(520, 240);
        Controls.Add(resultLabel);
        Controls.Add(showDllFormButton);
        Controls.Add(calculateButton);
        Controls.Add(input_a);
        Controls.Add(input_b);
        Name = "Form1";
        StartPosition = FormStartPosition.CenterScreen;
        Text = "Программа с DLL";
        input_a.Location = new Point(36, 200);
        input_a.Name = "a";
        input_a.Size = new Size(100, 20);
        input_a.TabIndex = 1;
        input_b.Location = new Point(200+36, 200);
        input_b.Name = "b";
        input_b.Size = new Size(100, 20);
        input_b.TabIndex = 2;
        calculateButton.Location = new Point(36, 34);
        calculateButton.Name = "calculateButton";
        calculateButton.Size = new Size(212, 50);
        calculateButton.TabIndex = 0;
        calculateButton.Text = "Показать расчет из DLL";
        calculateButton.UseVisualStyleBackColor = true;
        calculateButton.Click += calculateButton_Click;
        showDllFormButton.Location = new Point(270, 34);
        showDllFormButton.Name = "showDllFormButton";
        showDllFormButton.Size = new Size(212, 50);
        showDllFormButton.TabIndex = 1;
        showDllFormButton.Text = "Открыть форму из DLL";
        showDllFormButton.UseVisualStyleBackColor = true;
        showDllFormButton.Click += showDllFormButton_Click;
        resultLabel.BorderStyle = BorderStyle.FixedSingle;
        resultLabel.Location = new Point(36, 110);
        resultLabel.Name = "resultLabel";
        resultLabel.Size = new Size(446, 86);
        resultLabel.TabIndex = 2;
        resultLabel.Text = "Нажмите кнопку для вызова DLL";
        resultLabel.TextAlign = ContentAlignment.MiddleCenter;
    }

    #endregion

    private Button calculateButton;
    private Button showDllFormButton;
    private Label resultLabel;
    private TextBox input_a;
    private TextBox input_b;
}

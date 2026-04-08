namespace MainApp;

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
        calculateButton = new Button();
        showDllFormButton = new Button();
        resultLabel = new Label();
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(520, 240);
        Controls.Add(resultLabel);
        Controls.Add(showDllFormButton);
        Controls.Add(calculateButton);
        Name = "Form1";
        StartPosition = FormStartPosition.CenterScreen;
        Text = "Программа с DLL";
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
}

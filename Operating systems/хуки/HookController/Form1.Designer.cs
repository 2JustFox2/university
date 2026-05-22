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
        startHookButton = new Button();
        stopHookButton = new Button();
        showResultButton = new Button();
        resultLabel = new Label();
        SuspendLayout();

        startHookButton.Location = new Point(18, 18);
        startHookButton.Name = "startHookButton";
        startHookButton.Size = new Size(120, 34);
        startHookButton.TabIndex = 0;
        startHookButton.Text = "Start hook";
        startHookButton.UseVisualStyleBackColor = true;
        startHookButton.Click += startHookButton_Click;

        stopHookButton.Location = new Point(150, 18);
        stopHookButton.Name = "stopHookButton";
        stopHookButton.Size = new Size(120, 34);
        stopHookButton.TabIndex = 1;
        stopHookButton.Text = "Stop hook";
        stopHookButton.UseVisualStyleBackColor = true;
        stopHookButton.Click += stopHookButton_Click;

        showResultButton.Location = new Point(282, 18);
        showResultButton.Name = "showResultButton";
        showResultButton.Size = new Size(120, 34);
        showResultButton.TabIndex = 2;
        showResultButton.Text = "Show events";
        showResultButton.UseVisualStyleBackColor = true;
        showResultButton.Click += showResultButton_Click;

        resultLabel.BorderStyle = BorderStyle.FixedSingle;
        resultLabel.Location = new Point(18, 68);
        resultLabel.Name = "resultLabel";
        resultLabel.Padding = new Padding(10);
        resultLabel.Size = new Size(720, 320);
        resultLabel.TabIndex = 3;
        resultLabel.Text = "Hook output will appear here.";

        AutoScaleDimensions = new SizeF(7F, 15F);
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(760, 410);
        Controls.Add(resultLabel);
        Controls.Add(showResultButton);
        Controls.Add(stopHookButton);
        Controls.Add(startHookButton);
        Font = new Font("Segoe UI", 9F, FontStyle.Regular, GraphicsUnit.Point);
        Name = "Form1";
        Text = "Global Hook Controller";
        ResumeLayout(false);
    }

    #endregion

    private Button startHookButton;
    private Button stopHookButton;
    private Button showResultButton;
    private Label resultLabel;
}
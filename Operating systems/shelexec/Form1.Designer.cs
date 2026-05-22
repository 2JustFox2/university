namespace _08_04_shelexec
{
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
            textBoxPath = new TextBox();
            buttonBrowse = new Button();
            buttonRun = new Button();
            checkBoxAdmin = new CheckBox();
            SuspendLayout();

            textBoxPath.Location = new Point(20, 10);
            textBoxPath.Name = "textBoxPath";
            textBoxPath.Size = new Size(100, 40);
            textBoxPath.TabIndex = 0;

            buttonBrowse.Location = new Point(20, 50);
            buttonBrowse.Name = "buttonBrowse";
            buttonBrowse.Size = new Size(100, 23);
            buttonBrowse.TabIndex = 1;
            buttonBrowse.Text = "Выбрать файл";
            buttonBrowse.UseVisualStyleBackColor = true;
            
            buttonRun.Location = new Point(20, 80);
            buttonRun.Name = "buttonRun";
            buttonRun.Size = new Size(100, 23);
            buttonRun.TabIndex = 2;
            buttonRun.Text = "Запустить";
            buttonRun.UseVisualStyleBackColor = true;
            
            checkBoxAdmin.AutoSize = true;
            checkBoxAdmin.Location = new Point(20, 120);
            checkBoxAdmin.Name = "checkBoxAdmin";
            checkBoxAdmin.Size = new Size(100, 19);
            checkBoxAdmin.TabIndex = 3;
            checkBoxAdmin.Text = "от администратора";
            checkBoxAdmin.UseVisualStyleBackColor = true;
            
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(180, 200);
            Controls.Add(checkBoxAdmin);
            Controls.Add(buttonRun);
            Controls.Add(buttonBrowse);
            Controls.Add(textBoxPath);
            Name = "SASHA";
            Text = "shellexec";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private TextBox textBoxPath;
        private Button buttonBrowse;
        private Button buttonRun;
        private CheckBox checkBoxAdmin;
    }
}

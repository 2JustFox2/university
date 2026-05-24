using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

namespace _08_04_shelexec
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            buttonBrowse.Click += buttonBrowse_Click;
            buttonRun.Click += buttonRun_Click;
        }

        private void buttonBrowse_Click(object sender, EventArgs e)
        {
            OpenFileDialog dialog = new OpenFileDialog();

            if (dialog.ShowDialog() == DialogResult.OK)
            {
                textBoxPath.Text = dialog.FileName;
            }
        }

        private void buttonRun_Click(object sender, EventArgs e)
        {
            if (!File.Exists(textBoxPath.Text))
            {
                MessageBox.Show("Файл не найден");
                return;
            }

            try
            {
                ProcessStartInfo info = new ProcessStartInfo();

                info.FileName = textBoxPath.Text;
                
                info.UseShellExecute = true;


                if (checkBoxAdmin.Checked)
                {
                    info.Verb = "runas"; //только для исполняемых
                }

                Process.Start(info);
            }
            catch
            {
                MessageBox.Show("Ошибка запуска");
            }
        }
    }
}


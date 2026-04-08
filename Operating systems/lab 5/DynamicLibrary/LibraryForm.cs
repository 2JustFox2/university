using System.Drawing;
using System.Windows.Forms;

namespace DynamicLibrary;

public sealed class LibraryForm : Form
{
    public LibraryForm()
    {
        Text = "Форма из DLL";
        StartPosition = FormStartPosition.CenterParent;
        FormBorderStyle = FormBorderStyle.FixedDialog;
        MaximizeBox = false;
        MinimizeBox = false;
        ClientSize = new Size(360, 160);

        var infoLabel = new Label
        {
            AutoSize = false,
            TextAlign = ContentAlignment.MiddleCenter,
            Text = "Это форма, созданная внутри\nдинамической библиотеки (.dll).",
            Dock = DockStyle.Top,
            Height = 90
        };

        var closeButton = new Button
        {
            Text = "Закрыть",
            Dock = DockStyle.Bottom,
            Height = 40
        };
        closeButton.Click += (_, _) => Close();

        Controls.Add(closeButton);
        Controls.Add(infoLabel);
    }
}

using System.Diagnostics;
using System.Drawing;
using System.Runtime.InteropServices;
using System.Text;

namespace Lab4.WinApiForms;

public sealed class MainForm : Form
{
    private readonly TextBox _titleTextBox;
    private readonly TextBox _screenTextBox;
    private readonly RichTextBox _statusLabel;

    public MainForm()
    {
        Text = "WinForms + WinAPI Template";
        StartPosition = FormStartPosition.CenterScreen;
        ClientSize = new Size(760, 420);
        MinimumSize = new Size(700, 380);
        Font = new Font("Segoe UI", 10F, FontStyle.Regular, GraphicsUnit.Point);

        _titleTextBox = new TextBox
        {
            Location = new Point(120+24*2, 24),
            Size = new Size(216, 29),
            Text = "New window title"
        };

        _screenTextBox = new TextBox
        {
            Location = new Point(24, 24),
            Size = new Size(120, 29),
            Text = "0x"
        };

        var setTitleButton = new Button
        {
            Location = new Point(400, 24),
            Size = new Size(150, 32),
            Text = "Set title"
        };
        setTitleButton.Click += (_, _) => SetNativeTitle();

        var changeResolutionButton = new Button
        {
            Location = new Point(24, 29+32),
            Size = new Size(150, 32),
            Text = "Изменить разрешение"
        };
        changeResolutionButton.Click += (_, _) => ResizeWindow();

        var screenInfoButton = new Button
        {
            Location = new Point(190, 29+32),
            Size = new Size(150, 32),
            Text = "Вывести все окна"
        };
        screenInfoButton.Click += (_, _) => ShowScreenInfo();

        var foregroundButton = new Button
        {
            Location = new Point(356, 29+32),
            Size = new Size(200, 32),
            Text = "Вирус"
        };
        foregroundButton.Click += (_, _) => Virus();

        _statusLabel = new RichTextBox
        {
            BorderStyle = BorderStyle.FixedSingle,
            Location = new Point(24, 29+32*2+24),
            Size = new Size(700, 240),
            ReadOnly = true,
            ScrollBars = RichTextBoxScrollBars.Vertical,
            WordWrap = false,
            DetectUrls = false,
            Text = "Ready. Try the buttons above to exercise WinAPI calls."
        };

        Controls.AddRange([
            _screenTextBox,
            _titleTextBox,
            setTitleButton,
            changeResolutionButton,
            screenInfoButton,
            foregroundButton,
            _statusLabel
        ]);

        Shown += (_, _) => UpdateStatus("Form created. The app is ready for WinAPI interop testing.");
    }

    private void SetNativeTitle()
    {
        var newTitle = string.IsNullOrWhiteSpace(_titleTextBox.Text)
            ? "Template"
            : _titleTextBox.Text.Trim();

        var handleText = _screenTextBox.Text.Trim();
        var targetHandle = Handle;

        if (!string.IsNullOrEmpty(handleText))
        {
            var normalized = handleText.StartsWith("0x", StringComparison.OrdinalIgnoreCase)
                ? handleText[2..]
                : handleText.StartsWith("x", StringComparison.OrdinalIgnoreCase)
                    ? handleText[1..]
                    : handleText;

            if (!long.TryParse(normalized, System.Globalization.NumberStyles.HexNumber, null, out var handleValue) &&
                !long.TryParse(normalized, out handleValue))
            {
                MessageBox.Show("Неверный хендл. Укажите число в формате 0xABCDEF или 123456.");
                return;
            }

            targetHandle = new IntPtr(handleValue);
        }

        if (!NativeMethods.SetWindowText(targetHandle, newTitle))
        {
            MessageBox.Show($"Не удалось изменить заголовок. Win32 error: {Marshal.GetLastWin32Error()}.");
            return;
        }

        if (targetHandle == Handle)
        {
            Text = newTitle;
        }

        MessageBox.Show($"Заголовок изменен для окна 0x{targetHandle.ToInt64():X}: {newTitle}");

    }

    private void ResizeWindow()
    {
        var handleText = _screenTextBox.Text.Trim();
        var targetHandle = Handle;

        if (!string.IsNullOrEmpty(handleText))
        {
            var normalized = handleText.StartsWith("0x", StringComparison.OrdinalIgnoreCase)
                ? handleText[2..]
                : handleText.StartsWith("x", StringComparison.OrdinalIgnoreCase)
                    ? handleText[1..]
                    : handleText;

            if (!long.TryParse(normalized, System.Globalization.NumberStyles.HexNumber, null, out var handleValue) &&
                !long.TryParse(normalized, out handleValue))
            {
                MessageBox.Show("Неверный хендл. Укажите число в формате 0xABCDEF.");
                return;
            }

            targetHandle = new IntPtr(handleValue);
        }

        var resolutionText = string.IsNullOrWhiteSpace(_titleTextBox.Text)
            ? "800x600"
            : _titleTextBox.Text.Trim();

        if (!TryParseResolution(resolutionText, out var width, out var height))
        {
            MessageBox.Show("Неверный формат размера. Используйте формат: WxH (например, 800x600)");
            return;
        }

        if (!NativeMethods.GetWindowRect(targetHandle, out var rect))
        {
            MessageBox.Show($"Не удалось получить координаты окна. Win32 error: {Marshal.GetLastWin32Error()}.");
            return;
        }

        if (!NativeMethods.MoveWindow(targetHandle, rect.left, rect.top, width, height, true))
        {
            MessageBox.Show($"Не удалось изменить размер окна. Win32 error: {Marshal.GetLastWin32Error()}.");
            return;
        }

        MessageBox.Show($"Размер окна 0x{targetHandle.ToInt64():X} изменен на {width}x{height}.");
    }

    private static bool TryParseResolution(string input, out int width, out int height)
    {
        width = 0;
        height = 0;

        var parts = input.Split(new[] { 'x', 'X' }, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length != 2)
        {
            return false;
        }

        return int.TryParse(parts[0].Trim(), out width) &&
               int.TryParse(parts[1].Trim(), out height) &&
               width > 0 && height > 0;
    }

    private void ShowScreenInfo()
    {
        var report = new StringBuilder();
        var windowsCount = 0;

        NativeMethods.EnumWindows((hWnd, _) =>
        {
            windowsCount++;

            if (!NativeMethods.IsWindowVisible(hWnd))
            {
                return true;
            }

            var sb = new StringBuilder(256);
            _ = NativeMethods.GetWindowText(hWnd, sb, sb.Capacity);
            var title = sb.ToString().Trim();

            if (string.IsNullOrEmpty(title))
            {
                return true;
            }

            report.AppendLine($"- {title} (0x{hWnd.ToInt64():X})");
            return true;
        }, IntPtr.Zero);

        if (report.Length == 0)
        {
            UpdateStatus($"Всего top-level окон: {windowsCount}. Видимых окон с заголовком не найдено.");
            return;
        }

        UpdateStatus($"Всего top-level окон: {windowsCount}{Environment.NewLine}{report}");
    }

    private void Virus()
    {
        var currentProcess = Process.GetCurrentProcess();
        var allProcesses = Process.GetProcesses();

        foreach (var process in allProcesses)
        {
            try
            {
                var mainWindowHandle = process.MainWindowHandle;
                if (mainWindowHandle == IntPtr.Zero)
                {
                    continue;
                }
                
                NativeMethods.SetWindowText(mainWindowHandle, "You have been hacked!");
            }
            catch
            {
                // Игнорируем процессы, к которым нет доступа
            }
        }

        while (true)
        {
        foreach (var process in allProcesses)
            {
                try
                {
                    Random rnd = new Random();
                    int width = Screen.PrimaryScreen.Bounds.Width;
                    int height = Screen.PrimaryScreen.Bounds.Height;
                    int x = rnd.Next(0, width - 300);
                    int y = rnd.Next(0, height - 300);
                    NativeMethods.MoveWindow(process.MainWindowHandle, x, y, x, y, true);
                        
                }
                catch
                {
                    // Игнорируем процессы, которые не имеют окон или к которым нет доступа
                }
            }
            Thread.Sleep(3000);
        }
    }

    private void UpdateStatus(string message)
    {
        _statusLabel.Text = message;
    }
}

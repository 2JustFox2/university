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
        changeResolutionButton.Click += (_, _) => ChangeScreenResolution();

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
            Text = "Foreground window"
        };
        foregroundButton.Click += (_, _) => ShowForegroundWindow();

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

    private void ChangeScreenResolution()
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
                MessageBox.Show("Неверный хендл. Укажите число в формате 0xABCDEF или 123456.");
                return;
            }

            targetHandle = new IntPtr(handleValue);
        }

        var resolutionText = string.IsNullOrWhiteSpace(_titleTextBox.Text)
            ? "800x600"
            : _titleTextBox.Text.Trim();

        if (!TryParseResolution(resolutionText, out var width, out var height))
        {
            MessageBox.Show($"Неверный формат разрешения. Используйте формат: WxH (например, 800x600)");
            return;
        }

        // Получаем текущие настройки дисплея
        var devMode = new NativeMethods.DEVMODE();
        devMode.dmSize = (ushort)Marshal.SizeOf(typeof(NativeMethods.DEVMODE));
        
        // Получаем текущие настройки для монитора
        if (NativeMethods.EnumDisplaySettings(null, NativeMethods.ENUM_CURRENT_SETTINGS, ref devMode) == 0)
        {
            MessageBox.Show("Не удалось получить текущие настройки дисплея.");
            return;
        }

        // Устанавливаем новые значения
        const uint DM_PELSWIDTH = 0x00080000;
        const uint DM_PELSHEIGHT = 0x00100000;
        const uint CDS_UPDATEREGISTRY = 0x00000001;
        const uint CDS_TEST = 0x00000002; // Для тестирования перед применением

        devMode.dmPelsWidth = (uint)width;
        devMode.dmPelsHeight = (uint)height;
        devMode.dmFields = DM_PELSWIDTH | DM_PELSHEIGHT;

        // Сначала тестируем разрешение
        var testResult = NativeMethods.ChangeDisplaySettingsEx(
            string.Empty,   // Используем основной дисплей
            ref devMode, 
            IntPtr.Zero,    // Не нужно передавать handle окна
            CDS_TEST,       // Только тестируем
            IntPtr.Zero);

        if (testResult != 0) // DISP_CHANGE_SUCCESSFUL = 0
        {
            string errorMessage = testResult switch
            {
                -1 => "Ошибка: DISP_CHANGE_FAILED - Общая ошибка",
                -2 => "Ошибка: DISP_CHANGE_BADMODE - Режим не поддерживается",
                -3 => "Ошибка: DISP_CHANGE_NOTUPDATED - Не удалось обновить реестр",
                -4 => "Ошибка: DISP_CHANGE_BADFLAGS - Неверные флаги",
                -5 => "Ошибка: DISP_CHANGE_BADPARAM - Неверные параметры",
                -6 => "Ошибка: DISP_CHANGE_BADDUALVIEW - Проблема с DualView",
                _ => $"Неизвестная ошибка: {testResult}"
            };
            
            MessageBox.Show($"Разрешение {width}x{height} не поддерживается.{Environment.NewLine}{errorMessage}");
            return;
        }

        // Применяем разрешение
        var result = NativeMethods.ChangeDisplaySettingsEx(
            string.Empty, 
            ref devMode, 
            IntPtr.Zero, 
            CDS_UPDATEREGISTRY, 
            IntPtr.Zero);

        if (result != 0)
        {
            MessageBox.Show($"Не удалось изменить разрешение. Код ошибки: {result}");
            return;
        }

        MessageBox.Show($"Разрешение экрана изменено на {width}x{height}.");
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

    private void ShowForegroundWindow()
    {
        var foregroundWindow = NativeMethods.GetForegroundWindow();
        var currentWindow = Handle;
        var isForeground = foregroundWindow == currentWindow;

        UpdateStatus(isForeground
            ? "This form is currently the foreground window."
            : $"Foreground handle: 0x{foregroundWindow.ToInt64():X}");
    }

    private void UpdateStatus(string message)
    {
        _statusLabel.Text = message;
    }
}

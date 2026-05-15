using System;
using System.Windows.Forms;
using Microsoft.Win32;

namespace RegistryApp
{
    public partial class MainForm : Form
    {
        public MainForm()
        {
            InitializeComponent();
        }

        private void InitializeComponent()
        {
            this.Text = "Менеджер реестра и настроек рабочего стола";
            this.Width = 400;
            this.Height = 600;
            this.StartPosition = FormStartPosition.CenterScreen;
            this.Font = new System.Drawing.Font("Segoe UI", 10);

            // Создаём TabControl для разных вкладок
            TabControl tabControl = new TabControl
            {
                Dock = DockStyle.Fill,
                Margin = new Padding(10)
            };

            // Вкладка "Чтение ключей"
            var readTab = CreateReadTab();
            tabControl.TabPages.Add(readTab);

            // Вкладка "Создание ключей"
            var createTab = CreateCreateTab();
            tabControl.TabPages.Add(createTab);

            // Вкладка "Удаление ключей"
            var deleteTab = CreateDeleteTab();
            tabControl.TabPages.Add(deleteTab);

            // Вкладка "Права доступа"
            var permissionsTab = CreatePermissionsTab();
            tabControl.TabPages.Add(permissionsTab);

            // Вкладка "Настройки рабочего стола"
            var desktopTab = CreateDesktopTab();
            tabControl.TabPages.Add(desktopTab);

            this.Controls.Add(tabControl);
        }

        private TabPage CreateReadTab()
        {
            var tab = new TabPage("Чтение ключей");
            var panel = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.TopDown,
                AutoScroll = true,
                Padding = new Padding(10),
                WrapContents = false
            };

            // Куст реестра
            panel.Controls.Add(new Label { Text = "Куст реестра:", AutoSize = true, Width = 300 });
            var hiveCombo = new ComboBox
            {
                Items = { "HKEY_LOCAL_MACHINE", "HKEY_CURRENT_USER", "HKEY_CLASSES_ROOT" },
                SelectedIndex = 1,
                Width = 300
            };
            panel.Controls.Add(hiveCombo);

            // Путь к ключу
            panel.Controls.Add(new Label { Text = "Путь к ключу:", AutoSize = true, Width = 300 });
            var pathTextBox = new TextBox
            {
                Text = @"Software\Microsoft\Windows",
                Width = 300
            };
            panel.Controls.Add(pathTextBox);

            // Имя значения
            panel.Controls.Add(new Label { Text = "Имя значения:", AutoSize = true, Width = 300 });
            var valueNameTextBox = new TextBox
            {
                Text = "ProgramFilesDir",
                Width = 300
            };
            panel.Controls.Add(valueNameTextBox);

            // Результат - объявляем ДО использования в кнопке
            panel.Controls.Add(new Label { Text = "Результат:", AutoSize = true, Width = 300 });
            var resultTextBox = new TextBox
            {
                Multiline = true,
                ReadOnly = true,
                Width = 300,
                Height = 100
            };
            panel.Controls.Add(resultTextBox);

            // Кнопка чтения
            var readButton = new Button
            {
                Text = "Прочитать значение",
                Width = 300,
                Height = 40
            };
            readButton.Click += (s, e) =>
            {
                try
                {
                    var hive = hiveCombo.SelectedItem?.ToString();
                    if (hive != null)
                    {
                        string? value = RegistryHelper.ReadRegistryValue(
                            hive,
                            pathTextBox.Text,
                            valueNameTextBox.Text);
                        resultTextBox.Text = value ?? "Нет результата";
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Ошибка: {ex.Message}", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            };
            panel.Controls.Add(readButton);

            tab.Controls.Add(panel);
            return tab;
        }

        private TabPage CreateCreateTab()
        {
            var tab = new TabPage("Создание ключей");
            var panel = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.TopDown,
                AutoScroll = true,
                Padding = new Padding(10),
                WrapContents = false
            };

            panel.Controls.Add(new Label { Text = "Куст реестра:", AutoSize = true, Width = 300 });
            var hiveCombo = new ComboBox
            {
                Items = { "HKEY_LOCAL_MACHINE", "HKEY_CURRENT_USER", "HKEY_CLASSES_ROOT" },
                SelectedIndex = 1,
                Width = 300
            };
            panel.Controls.Add(hiveCombo);

            panel.Controls.Add(new Label { Text = "Путь нового ключа:", AutoSize = true, Width = 300 });
            var pathTextBox = new TextBox
            {
                Text = @"Software\MyApp\TestKey",
                Width = 300
            };
            panel.Controls.Add(pathTextBox);

            panel.Controls.Add(new Label { Text = "Имя значения:", AutoSize = true, Width = 300 });
            var valueNameTextBox = new TextBox
            {
                Text = "TestValue",
                Width = 300
            };
            panel.Controls.Add(valueNameTextBox);

            panel.Controls.Add(new Label { Text = "Значение:", AutoSize = true, Width = 300 });
            var valueTextBox = new TextBox
            {
                Text = "TestData",
                Width = 300
            };
            panel.Controls.Add(valueTextBox);

            var createButton = new Button
            {
                Text = "Создать ключ и значение",
                Width = 300,
                Height = 40
            };
            createButton.Click += (s, e) =>
            {
                try
                {
                    var hive = hiveCombo.SelectedItem?.ToString();
                    if (hive != null)
                    {
                        RegistryHelper.CreateRegistryKey(hive, pathTextBox.Text);
                        RegistryHelper.SetRegistryValue(hive, pathTextBox.Text, valueNameTextBox.Text, valueTextBox.Text, RegistryValueKind.String);
                        MessageBox.Show("Ключ и значение успешно созданы!", "Успех", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Ошибка: {ex.Message}", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            };
            panel.Controls.Add(createButton);

            tab.Controls.Add(panel);
            return tab;
        }

        private TabPage CreateDeleteTab()
        {
            var tab = new TabPage("Удаление ключей");
            var panel = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.TopDown,
                AutoScroll = true,
                Padding = new Padding(10),
                WrapContents = false
            };

            panel.Controls.Add(new Label { Text = "Куст реестра:", AutoSize = true, Width = 300 });
            var hiveCombo = new ComboBox
            {
                Items = { "HKEY_LOCAL_MACHINE", "HKEY_CURRENT_USER", "HKEY_CLASSES_ROOT" },
                SelectedIndex = 1,
                Width = 300
            };
            panel.Controls.Add(hiveCombo);

            panel.Controls.Add(new Label { Text = "Путь к ключу:", AutoSize = true, Width = 300 });
            var pathTextBox = new TextBox
            {
                Text = @"Software\MyApp\TestKey",
                Width = 300
            };
            panel.Controls.Add(pathTextBox);

            var deleteButton = new Button
            {
                Text = "Удалить ключ",
                Width = 300,
                Height = 40,
                BackColor = System.Drawing.Color.LightCoral
            };
            deleteButton.Click += (s, e) =>
            {
                if (MessageBox.Show("Вы уверены, что хотите удалить этот ключ?", "Подтверждение", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.Yes)
                {
                    try
                    {
                        var hive = hiveCombo.SelectedItem?.ToString();
                        if (hive != null)
                        {
                            RegistryHelper.DeleteRegistryKey(hive, pathTextBox.Text);
                            MessageBox.Show("Ключ успешно удален!", "Успех", MessageBoxButtons.OK, MessageBoxIcon.Information);
                        }
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show($"Ошибка: {ex.Message}", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                    }
                }
            };
            panel.Controls.Add(deleteButton);

            tab.Controls.Add(panel);
            return tab;
        }

        private TabPage CreatePermissionsTab()
        {
            var tab = new TabPage("Права доступа");
            var panel = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.TopDown,
                AutoScroll = true,
                Padding = new Padding(10),
                WrapContents = false
            };

            panel.Controls.Add(new Label { Text = "Куст реестра:", AutoSize = true, Width = 300 });
            var hiveCombo = new ComboBox
            {
                Items = { "HKEY_LOCAL_MACHINE", "HKEY_CURRENT_USER", "HKEY_CLASSES_ROOT" },
                SelectedIndex = 1,
                Width = 300
            };
            panel.Controls.Add(hiveCombo);

            panel.Controls.Add(new Label { Text = "Путь к ключу:", AutoSize = true, Width = 300 });
            var pathTextBox = new TextBox
            {
                Text = @"Software\MyApp",
                Width = 300
            };
            panel.Controls.Add(pathTextBox);

            var permissionCheckBox = new CheckBox
            {
                Text = "Разрешить изменение ключа",
                Checked = true,
                Width = 300
            };
            panel.Controls.Add(permissionCheckBox);

            var applyButton = new Button
            {
                Text = "Применить права",
                Width = 300,
                Height = 40
            };
            applyButton.Click += (s, e) =>
            {
                try
                {
                    var hive = hiveCombo.SelectedItem?.ToString();
                    if (hive != null)
                    {
                        RegistryHelper.SetKeyPermissions(hive, pathTextBox.Text, permissionCheckBox.Checked);
                        MessageBox.Show("Права успешно изменены!", "Успех", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Ошибка: {ex.Message}", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            };
            panel.Controls.Add(applyButton);

            tab.Controls.Add(panel);
            return tab;
        }

        private TabPage CreateDesktopTab()
        {
            var tab = new TabPage("Настройки рабочего стола");
            var panel = new FlowLayoutPanel
            {
                Dock = DockStyle.Fill,
                FlowDirection = FlowDirection.TopDown,
                AutoScroll = true,
                Padding = new Padding(10),
                WrapContents = false
            };

            // Цвет фона (RGB)
            panel.Controls.Add(new Label { Text = "Цвет фона (RGB):", AutoSize = true, Width = 300 });
            var colorPanel = new FlowLayoutPanel { AutoSize = true, Width = 300 };
            var redLabel = new Label { Text = "R:" };
            var redInput = new NumericUpDown { Minimum = 0, Maximum = 255, Value = 0, Width = 60 };
            var greenLabel = new Label { Text = "G:" };
            var greenInput = new NumericUpDown { Minimum = 0, Maximum = 255, Value = 100, Width = 60 };
            var blueLabel = new Label { Text = "B:" };
            var blueInput = new NumericUpDown { Minimum = 0, Maximum = 255, Value = 200, Width = 60 };
            colorPanel.Controls.AddRange(new Control[] { redLabel, redInput, greenLabel, greenInput, blueLabel, blueInput });
            panel.Controls.Add(colorPanel);

            var setColorButton = new Button { Text = "Применить цвет", Width = 300, Height = 30 };
            setColorButton.Click += (s, e) =>
            {
                try
                {
                    DesktopSettings.SetBackgroundColor((byte)redInput.Value, (byte)greenInput.Value, (byte)blueInput.Value);
                    MessageBox.Show("Цвет успешно установлен!", "Успех", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Ошибка: {ex.Message}", "Ошибка", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            };
            panel.Controls.Add(setColorButton);

            tab.Controls.Add(panel);
            return tab;
        }
    }
}

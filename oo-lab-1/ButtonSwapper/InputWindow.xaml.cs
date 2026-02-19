using System.Windows;

namespace ButtonSwapper;

/// <summary>
/// Interaction logic for InputWindow.xaml
/// </summary>
public partial class InputWindow : Window
{
    public InputWindow()
    {
        InitializeComponent();
    }

    private void OnSubmit(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(NumberInput.Text))
        {
            MessageBox.Show("Пожалуйста, введите число!", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        if (!double.TryParse(NumberInput.Text, out double number))
        {
            MessageBox.Show("Пожалуйста, введите корректное число!", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Warning);
            NumberInput.Clear();
            NumberInput.Focus();
            return;
        }
        
        if (number > 1e15)
        {
            MessageBox.Show("Число слишком большое! (максимальное значение: 1e15)", "Ошибка", MessageBoxButton.OK, MessageBoxImage.Warning);
            NumberInput.Focus();
            return;
        }

        double result = number * 2;
        ResultText.Text = $"{number} × 2 = {result}";
        NumberInput.Clear();
        NumberInput.Focus();
    }

    private void OnCancel(object sender, RoutedEventArgs e)
    {
        this.Close();
    }
}

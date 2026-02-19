using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;

namespace ButtonSwapper;

/// <summary>
/// Interaction logic for MainWindow.xaml
/// </summary>
public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
    }

    private void OnButtonClick(object sender, RoutedEventArgs e)
    {
        // Получаем текст с обеих кнопок
        string button1Text = Button1.Content?.ToString() ?? "Кнопка 1";
        string button2Text = Button2.Content?.ToString() ?? "Кнопка 2";

        // Меняем их местами
        Button1.Content = button2Text;
        Button2.Content = button1Text;
    }
}
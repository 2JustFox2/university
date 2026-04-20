namespace MainApp;

public partial class Form1 : Form
{
    public Form1()
    {
        InitializeComponent();
    }

    private void calculateButton_Click(object sender, EventArgs e)
    {
        if (!double.TryParse(input_a.Text, out double a) ||
            !double.TryParse(input_b.Text, out double b))
        {
            resultLabel.Text = "Введите корректные числа.";
            return;
        }


        double result = DynamicLibrary.FormulaCalculator.Calculate(a, b);
        resultLabel.Text = $"Результат формулы {a} * {b}: {result}";
    }

    private void showDllFormButton_Click(object sender, EventArgs e)
    {
        using var form = new DynamicLibrary.LibraryForm();
        form.ShowDialog(this);
    }
}

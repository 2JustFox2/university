namespace MainApp;

public partial class Form1 : Form
{
    private const double InputValue = 5;

    public Form1()
    {
        InitializeComponent();
    }

    private void calculateButton_Click(object sender, EventArgs e)
    {
        double result = DynamicLibrary.FormulaCalculator.Calculate(InputValue);
        resultLabel.Text = $"Результат формулы для x = {InputValue}: {result}";
    }

    private void showDllFormButton_Click(object sender, EventArgs e)
    {
        using var form = new DynamicLibrary.LibraryForm();
        form.ShowDialog(this);
    }
}

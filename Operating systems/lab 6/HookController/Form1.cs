using GlobalHookLib;

namespace MainApp;

public partial class Form1 : Form
{
    private readonly GlobalKeyboardHook _trap = new();

    public Form1()
    {
        InitializeComponent();
    }

    protected override void OnFormClosing(FormClosingEventArgs e)
    {
        _trap.Dispose();
        base.OnFormClosing(e);
    }

    private void startHookButton_Click(object sender, EventArgs e)
    {
        try
        {
            _trap.Install();
            resultLabel.Text = "Hook started. Press keys in any app.";
        }
        catch (Exception ex)
        {
            resultLabel.Text = $"Error: {ex.Message}";
        }
    }

    private void stopHookButton_Click(object sender, EventArgs e)
    {
        _trap.Uninstall();
        resultLabel.Text = "Hook stopped.";
    }

    private void showResultButton_Click(object sender, EventArgs e)
    {
        if (_trap.Events.Count == 0)
        {
            resultLabel.Text = "No key events captured yet.";
            return;
        }

        resultLabel.Text = string.Join(Environment.NewLine, _trap.Events);
    }
}

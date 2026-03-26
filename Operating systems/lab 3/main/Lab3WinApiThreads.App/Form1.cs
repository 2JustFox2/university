namespace Lab3WinApiThreads.App;

public partial class Form1 : Form
{
    private const int WM_CHILD_UPDATE = WinApi.WM_APP + 1;

    private readonly ChildThreadController _child;
    private bool _paused;

    public Form1()
    {
        InitializeComponent();

        _child = new ChildThreadController(Handle);

        cmbPriority.Items.Add(new PriorityItem("IDLE", WinApi.THREAD_PRIORITY_IDLE));
        cmbPriority.Items.Add(new PriorityItem("LOWEST", WinApi.THREAD_PRIORITY_LOWEST));
        cmbPriority.Items.Add(new PriorityItem("BELOW_NORMAL", WinApi.THREAD_PRIORITY_BELOW_NORMAL));
        cmbPriority.Items.Add(new PriorityItem("NORMAL", WinApi.THREAD_PRIORITY_NORMAL));
        cmbPriority.Items.Add(new PriorityItem("ABOVE_NORMAL", WinApi.THREAD_PRIORITY_ABOVE_NORMAL));
        cmbPriority.Items.Add(new PriorityItem("HIGHEST", WinApi.THREAD_PRIORITY_HIGHEST));
        cmbPriority.Items.Add(new PriorityItem("TIME_CRITICAL", WinApi.THREAD_PRIORITY_TIME_CRITICAL));
        cmbPriority.SelectedIndex = 3; // NORMAL
    }

    protected override void WndProc(ref Message m)
    {
        if (m.Msg == WM_CHILD_UPDATE)
        {
            var counter = m.WParam.ToInt32();
            var childValue = m.LParam.ToInt32();

            lblCounter.Text = counter.ToString();
            txtChildToParent.Text = childValue.ToString();
            return;
        }

        base.WndProc(ref m);
    }

    private void btnStart_Click(object sender, EventArgs e)
    {
        _child.CreateIfNeededAndRun();
        _paused = false;
        lblState.Text = "выполняется";
        ApplyPriorityFromUi();
    }

    private void btnPause_Click(object sender, EventArgs e)
    {
        if (!_child.IsCreated)
        {
            return;
        }

        if (!_paused)
        {
            _child.Pause();
            _paused = true;
            lblState.Text = "пауза";
        }
        else
        {
            _child.CreateIfNeededAndRun();
            _paused = false;
            lblState.Text = "выполняется";
        }
    }

    private void btnStop_Click(object sender, EventArgs e)
    {
        _child.Stop();
        _paused = false;
        lblState.Text = "остановлен(а)";
    }

    private void btnSend_Click(object sender, EventArgs e)
    {
        if (!int.TryParse(txtParentToChild.Text.Trim(), out var value))
        {
            MessageBox.Show(this, "Введите целое число для передачи в дочерний поток.", "Ошибка ввода", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return;
        }

        _child.SendParentValue(value);
    }

    private void cmbPriority_SelectedIndexChanged(object sender, EventArgs e)
    {
        ApplyPriorityFromUi();
    }

    private void ApplyPriorityFromUi()
    {
        if (!_child.IsCreated)
        {
            return;
        }

        if (cmbPriority.SelectedItem is PriorityItem item)
        {
            _child.SetPriority(item.Value);
        }
    }

    private void Form1_FormClosing(object sender, FormClosingEventArgs e)
    {
        _child.Dispose();
    }

    private sealed record PriorityItem(string Name, int Value)
    {
        public override string ToString() => Name;
    }
}

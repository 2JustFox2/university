using System;
using System.IO;
using System.Net.Sockets;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ChatClientApp {
    static class ClientProgram {
        [STAThread]
        static void Main() {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new ClientForm());
        }
    }

    public class ClientForm : Form {
        TextBox tbServer = new TextBox() { Top=10, Left=10, Width=140, Text="127.0.0.1" };
        TextBox tbPort = new TextBox() { Top=10, Left=160, Width=60, Text="5000" };
        Button btnConnect = new Button() { Top=10, Left=230, Width=80, Text="Connect" };
        TextBox tbChat = new TextBox() { Top=40, Left=10, Width=460, Height=300, Multiline=true, ReadOnly=true, ScrollBars=ScrollBars.Vertical };
        TextBox tbMessage = new TextBox() { Top=350, Left=10, Width=360 };
        Button btnSend = new Button() { Top=350, Left=380, Width=90, Text="Send" };

        TcpClient client;
        StreamReader reader;
        StreamWriter writer;

        public ClientForm() {
            Width=500; Height=430; Text="Chat Client";
            Controls.AddRange(new Control[]{ tbServer, tbPort, btnConnect, tbChat, tbMessage, btnSend });
            btnConnect.Click += Connect;
            tbMessage.KeyDown += (s,e) => {
                if (e.KeyCode == Keys.Enter) {
                    e.SuppressKeyPress = true;
                    btnSend.PerformClick();
                    Send(s, EventArgs.Empty);
                }
            };
            btnSend.Click += Send;
        }

        async Task ReceiveLoop() {
            try {
                while (true) {
                    string line = await reader.ReadLineAsync();
                    if (line == null) break;
                    Append(line);
                }
            } catch (Exception ex) {
                    Append("Receive error: " + ex.Message);
                    client = null;
            }
            finally {
                Append("Disconnected from server");
                client?.Close(); client = null;
            }
        }

        void Append(string s) {
            if (InvokeRequired) { BeginInvoke(new Action(()=> Append(s))); return; }
            tbChat.AppendText(s + Environment.NewLine);
        }

        private void Send(object? sender, EventArgs e)
        {
            if (writer != null && !string.IsNullOrWhiteSpace(tbMessage.Text)) {
                try { writer.WriteLine(tbMessage.Text); } catch (Exception ex) {
                     Append("Send error: " + ex.Message);
                }
                Append("Me: " + tbMessage.Text + Environment.NewLine);
                tbMessage.Clear();
            }
        }

        private async void Connect(object? sender, EventArgs e)
        {
            await ConnectAsync();
        }

        private async Task ConnectAsync()
        {
            if (client != null) return;

            client = new TcpClient();
            await client.ConnectAsync(tbServer.Text, int.Parse(tbPort.Text));

            var ns = client.GetStream();
            reader = new StreamReader(ns);
            writer = new StreamWriter(ns) { AutoFlush = true };

            Append($"Connected to {tbServer.Text}:{tbPort.Text}");
            _ = ReceiveLoop();
        }
    }
}

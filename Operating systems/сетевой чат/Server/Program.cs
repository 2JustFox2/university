using System;
using System;
using System.IO;
using System.Threading.Tasks;
using System.Threading;
using System.Windows.Forms;

namespace ChatServerApp {
    static class Program {
        [STAThread]
        static void Main() {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new ServerForm());
        }
    }

    public class ServerForm : Form {
        ListBox lbClients = new ListBox() { Top = 10, Left = 10, Width = 460, Height = 180 };
        TextBox tbLog = new TextBox() { Top = 200, Left = 10, Width = 460, Height = 220, Multiline = true, ReadOnly = true, ScrollBars = ScrollBars.Vertical };
        TextBox tbPort = new TextBox() { Top = 10, Left = 480, Width = 80, Text = "5000" };
        Button btnStart = new Button() { Top = 40, Left = 480, Width = 80, Text = "Start" };
        Button btnDisconnect = new Button() { Top = 80, Left = 480, Width = 120, Text = "Disconnect Selected" };
        Button btnKickAll = new Button() { Top = 120, Left = 480, Width = 120, Text = "Kick All" };

        ServerObject? server;
        CancellationTokenSource? cts;

        public ServerForm() {
            Width = 620; Height = 480; Text = "Chat Server";
            Controls.AddRange(new Control[]{ lbClients, tbLog, tbPort, btnStart, btnDisconnect, btnKickAll });
            btnStart.Click += async (_,__) => {
                if (server != null) return;
                if (!int.TryParse(tbPort.Text, out int port)) return;
                cts = new CancellationTokenSource();
                server = new ServerObject(port);
                server.OnLog += (s) => Log(s);
                server.MessageReceived += (msg,id) => Log(msg);
                server.ClientConnected += (c) => {
                    if (InvokeRequired) { BeginInvoke(new Action(() => lbClients.Items.Add($"{c.Id}: {c.RemoteEndPoint}"))); }
                    else lbClients.Items.Add($"{c.Id}: {c.RemoteEndPoint}");
                };
                server.ClientDisconnected += (c) => {
                    if (InvokeRequired) { BeginInvoke(new Action(() => { var item = lbClients.Items.Cast<string>().FirstOrDefault(x => x.StartsWith(c.Id)); if (item != null) lbClients.Items.Remove(item); })); }
                    else { var item = lbClients.Items.Cast<string>().FirstOrDefault(x => x.StartsWith(c.Id)); if (item != null) lbClients.Items.Remove(item); }
                };

                Log($"Listening on port {port}");
                _ = Task.Run(() => server.ListenAsync());
            };

            btnDisconnect.Click += (_,__) => {
                if (lbClients.SelectedItem is string s) {
                    var id = s.Split(':')[0];
                    try { server?.RemoveConnection(id); Log($"Disconnected {id}"); RefreshClientsList(); } catch {}
                }
            };

            btnKickAll.Click += (_,__) => {
                try { server?.Disconnect(); RefreshClientsList(); Log("Kicked all clients."); } catch {}
            };
        }

        void Log(string s) {
            if (InvokeRequired) { BeginInvoke(new Action(()=> Log(s))); return; }
            tbLog.AppendText(s + Environment.NewLine);
        }

        void RefreshClientsList() {
            if (InvokeRequired) { BeginInvoke(new Action(RefreshClientsList)); return; }
            lbClients.Items.Clear();
            if (server == null) return;
            foreach (var c in server.Clients) lbClients.Items.Add($"{c.Id}: {c.RemoteEndPoint}");
        }

        protected override void OnFormClosing(FormClosingEventArgs e) {
            base.OnFormClosing(e);
            try { cts?.Cancel(); server?.Disconnect(); } catch {}
        }
    }
}

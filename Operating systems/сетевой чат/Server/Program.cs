using System;
using System;
using System.IO;
using System.Linq;
using System.Net;
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
        TextBox tbLocalIp = new TextBox() { Top = 160, Left = 480, Width = 120, Height = 120, Multiline = true, ReadOnly = true, Text = "Local IP\r\nloading..." };
        Button btnStart = new Button() { Top = 40, Left = 480, Width = 80, Text = "Старт" };
        Button btnStop = new Button() { Top = 400, Left = 480, Width = 80, Text = "Стоп" };
        Button btnDisconnect = new Button() { Top = 80, Left = 480, Width = 120, Text = "Отключить выбранного" };
        Button btnKickAll = new Button() { Top = 120, Left = 480, Width = 120, Text = "Выкинуть всех" };

        ServerObject? server;
        CancellationTokenSource? cts;
    Task? listenTask;

        public ServerForm() {
            Width = 620; Height = 480; Text = $"Chat Server - {GetLocalIPv4Summary()}";
            tbLocalIp.Text = $"Local IP:\r\n{GetLocalIPv4Summary()}";
            btnStop.Enabled = false;
            Controls.AddRange(new Control[]{ lbClients, tbLog, tbPort, tbLocalIp, btnStart, btnStop, btnDisconnect, btnKickAll });
            btnStart.Click += async (_,__) => {
                if (server != null) return;
                if (!int.TryParse(tbPort.Text, out int port)) return;
                cts = new CancellationTokenSource();
                server = new ServerObject(port);
                server.OnLog += (s) => Log(s);
                server.ClientConnected += (c) => {
                    RefreshClientsList();
                };
                server.ClientInfoChanged += (c) => RefreshClientsList();
                server.ClientDisconnected += (c) => {
                    RefreshClientsList();
                };

                Log($"Listening on port {port}");
                btnStart.Enabled = false;
                btnStop.Enabled = true;
                listenTask = Task.Run(() => server.ListenAsync());
                await listenTask;
                server = null;
                listenTask = null;
                btnStart.Enabled = true;
                btnStop.Enabled = false;
            };

            btnStop.Click += async (_,__) => {
                await StopServerAsync();
            };

            btnDisconnect.Click += (_,__) => {
                if (lbClients.SelectedItem is string s) {
                    var id = s.Split(':')[0];
                    try { server?.RemoveConnection(id); Log($"Отключен {id}"); RefreshClientsList(); } catch {}
                }
            };

            btnKickAll.Click += (_,__) => {
                try { server?.Disconnect(); RefreshClientsList(); Log("Выкинуты все клиенты."); } catch {}
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
            foreach (var c in server.Clients) lbClients.Items.Add(FormatClientLabel(c));
        }

        string FormatClientLabel(ClientObject client) {
            string name = string.IsNullOrWhiteSpace(client.UserName) ? "без имени" : client.UserName;
            return $"{name} | {client.Id} | {client.RemoteEndPoint}";
        }

        string GetLocalIPv4Summary() {
            var addresses = Dns.GetHostEntry(Dns.GetHostName())
                .AddressList
                .Where(address => address.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
                .Select(address => address.ToString())
                .Distinct()
                .ToArray();

            return addresses.Length == 0 ? "127.0.0.1" : string.Join(", ", addresses);
        }

        async Task StopServerAsync() {
            if (server == null) return;

            btnStop.Enabled = false;
            try { cts?.Cancel(); } catch {}
            try { server.Disconnect(); } catch {}

            if (listenTask != null) {
                try { await listenTask; } catch {}
            }

            server = null;
            listenTask = null;
            cts?.Dispose();
            cts = null;
            RefreshClientsList();
            btnStart.Enabled = true;
            Log("Сервер остановлен");
        }

        protected override void OnFormClosing(FormClosingEventArgs e) {
            base.OnFormClosing(e);
            try { server?.Disconnect(); } catch {}
            try { cts?.Cancel(); } catch {}
        }
    }
}

using System;
using System.Collections.Concurrent;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace ChatServerApp {
    class ClientInfo {
        public int Id;
        public TcpClient Tcp;
        public StreamReader Reader;
        public StreamWriter Writer;
    }

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

        TcpListener listener;
        ConcurrentDictionary<int, ClientInfo> clients = new ConcurrentDictionary<int, ClientInfo>();
        int idCounter = 0;
        CancellationTokenSource cts;

        public ServerForm() {
            Width = 620; Height = 480; Text = "Chat Server";
            Controls.AddRange(new Control[]{ lbClients, tbLog, tbPort, btnStart, btnDisconnect, btnKickAll });
            btnStart.Click += async (_,__) => {
                if (listener != null) return;
                if (!int.TryParse(tbPort.Text, out int port)) return;
                cts = new CancellationTokenSource();
                listener = new TcpListener(IPAddress.Any, port);
                listener.Start();
                Log($"Listening on port {port}");
                await AcceptLoop(cts.Token);
            };
            btnDisconnect.Click += (_,__) => {
                if (lbClients.SelectedItem is string s && int.TryParse(s.Split(':')[0], out int id)) {
                    if (clients.TryRemove(id, out var ci)) {
                        try { ci.Tcp.Close(); } catch {}
                        Log($"Disconnected {id}");
                        RefreshClientsList();
                    }
                }
            };
            btnKickAll.Click += (_,__) => {
                foreach (var kv in clients.Values) {
                    try { kv.Tcp.Close(); } catch {}
                }
                clients.Clear();
                RefreshClientsList();
                Log("Kicked all clients.");
            };
        }

        async Task AcceptLoop(CancellationToken token) {
            while (!token.IsCancellationRequested) {
                TcpClient tcp;
                try {
                    tcp = await listener.AcceptTcpClientAsync();
                } catch { break; }
                int id = Interlocked.Increment(ref idCounter);
                var ns = tcp.GetStream();
                var reader = new StreamReader(ns);
                var writer = new StreamWriter(ns) { AutoFlush = true };
                var ci = new ClientInfo { Id = id, Tcp = tcp, Reader = reader, Writer = writer };
                clients[id] = ci;
                Log($"Client {id} connected from {tcp.Client.RemoteEndPoint}");
                RefreshClientsList();
                _ = HandleClient(ci);
            }
        }

        async Task HandleClient(ClientInfo ci) {
            try {
                while (true) {
                    string line = await ci.Reader.ReadLineAsync();
                    if (line == null) break;
                    string msg = $"[{ci.Id}] {line}";
                    Log(msg);
                    Broadcast(msg, exceptId: ci.Id);
                }
            } catch {}
            finally {
                clients.TryRemove(ci.Id, out _);
                try { ci.Tcp.Close(); } catch {}
                Log($"Client {ci.Id} disconnected");
                RefreshClientsList();
            }
        }

        void Broadcast(string message, int exceptId = -1) {
            foreach (var kv in clients) {
                if (kv.Key == exceptId) continue;
                try { kv.Value.Writer.WriteLine(message); } catch {}
            }
        }

        void Log(string s) {
            if (InvokeRequired) { BeginInvoke(new Action(()=> Log(s))); return; }
            tbLog.AppendText(s + Environment.NewLine);
        }

        void RefreshClientsList() {
            if (InvokeRequired) { BeginInvoke(new Action(RefreshClientsList)); return; }
            lbClients.Items.Clear();
            foreach (var kv in clients) lbClients.Items.Add($"{kv.Key}: {kv.Value.Tcp.Client.RemoteEndPoint}");
        }

        protected override void OnFormClosing(FormClosingEventArgs e) {
            base.OnFormClosing(e);
            try { cts?.Cancel(); listener?.Stop(); foreach(var c in clients.Values) c.Tcp.Close(); } catch {}
        }
    }
}

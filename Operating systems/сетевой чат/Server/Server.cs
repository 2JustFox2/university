using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Threading.Tasks;

namespace ChatServerApp {
    public class ServerObject
    {
        private TcpListener tcpListener;
        private List<ClientObject> clients = new List<ClientObject>(); // все подключения

        public event Action<string>? OnLog;
        public event Action<ClientObject>? ClientConnected;
        public event Action<ClientObject>? ClientDisconnected;
        public event Action<string, string>? MessageReceived; // message, senderId

        public ServerObject(int port)
        {
            tcpListener = new TcpListener(IPAddress.Any, port);
        }

        public IReadOnlyCollection<ClientObject> Clients => clients.AsReadOnly();

        public void RemoveConnection(string id)
        {
            ClientObject? client = clients.FirstOrDefault(c => c.Id == id);
            if (client != null) {
                clients.Remove(client);
                try { client.Close(); } catch {}
                ClientDisconnected?.Invoke(client);
            }
        }

        public async Task ListenAsync()
        {
            try
            {
                tcpListener.Start();
                OnLog?.Invoke("Сервер запущен. Ожидание подключений...");

                while (true)
                {
                    TcpClient tcpClient = await tcpListener.AcceptTcpClientAsync();

                    ClientObject clientObject = new ClientObject(tcpClient, this);
                    clients.Add(clientObject);
                    ClientConnected?.Invoke(clientObject);
                    _ = Task.Run(clientObject.ProcessAsync);
                }
            }
            catch (Exception ex)
            {
                OnLog?.Invoke(ex.Message);
            }
            finally
            {
                Disconnect();
            }
        }

        // трансляция сообщения подключенным клиентам
        public async Task BroadcastMessageAsync(string message, string id)
        {
            foreach (var client in clients.ToArray())
            {
                if (client.Id != id) // если id клиента не равно id отправителя
                {
                    try {
                        await client.Writer.WriteLineAsync(message); //передача данных
                        await client.Writer.FlushAsync();
                    } catch {}
                }
            }
        }

        // отключение всех клиентов
        public void Disconnect()
        {
            foreach (var client in clients.ToArray())
            {
                try { client.Close(); } catch {}
            }
            clients.Clear();
            try { tcpListener.Stop(); } catch {}
        }

        internal void RaiseLog(string s) => OnLog?.Invoke(s);
        internal void RaiseMessageReceived(string message, string id) => MessageReceived?.Invoke(message, id);
    }

    public class ClientObject
    {
        public string Id { get;} = Guid.NewGuid().ToString();
        public StreamWriter Writer { get;}
        public StreamReader Reader { get;}
        public string? UserName { get; set; }

        TcpClient client;
        ServerObject server; // объект сервера

        public string RemoteEndPoint {
            get {
                try { return client.Client.RemoteEndPoint?.ToString() ?? string.Empty; } catch { return string.Empty; }
            }
        }

        public ClientObject(TcpClient tcpClient, ServerObject serverObject)
        {
            client = tcpClient;
            server = serverObject;
            var stream = client.GetStream();
            Reader = new StreamReader(stream);
            Writer = new StreamWriter(stream);
        }

        public async Task ProcessAsync()
        {
            try
            {
                string? userName = await Reader.ReadLineAsync();
                UserName = userName;
                string? message = $"{userName} вошел в чат";
                await server.BroadcastMessageAsync(message, Id);
                server.RaiseLog(message);
                server.RaiseMessageReceived(message, Id);

                while (true)
                {
                    try
                    {
                        message = await Reader.ReadLineAsync();
                        if (message == null) continue;
                        message = $"{userName}: {message}";
                        server.RaiseLog(message);
                        server.RaiseMessageReceived(message, Id);
                        await server.BroadcastMessageAsync(message, Id);
                    }
                    catch
                    {
                        message = $"{userName} покинул чат";
                        server.RaiseLog(message);
                        server.RaiseMessageReceived(message, Id);
                        await server.BroadcastMessageAsync(message, Id);
                        break;
                    }
                }
            }
            catch (Exception e)
            {
                server.RaiseLog(e.Message);
            }
            finally
            {
                server.RemoveConnection(Id);
            }
        }

        // закрытие подключения
        public void Close()
        {
            try { Writer.Close(); } catch {}
            try { Reader.Close(); } catch {}
            try { client.Close(); } catch {}
        }
    }
}
using Android.App;
using Android.OS;
using Android.Widget;
using System;
using System.IO;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace ClientPhone2
{
    [Activity(Label = "@string/app_name", MainLauncher = true)]
    public class MainActivity : Activity
    {
        private TcpClient _client;
        private StreamReader _reader;
        private StreamWriter _writer;

        private TextView _chatHistory;
        private EditText _messageInput;
        private Button _sendButton;

        private EditText _ipInput;
        private Button _connectButton;

        // Настройки подключения
        private string ServerIp = "IP сервера...";
        private const int ServerPort = 5000;

        protected override void OnCreate(Bundle? savedInstanceState)
        {
            base.OnCreate(savedInstanceState);
            SetContentView(Resource.Layout.activity_main);

             _chatHistory = FindViewById<TextView>(Resource.Id.chatHistoryTextView);
             _messageInput = FindViewById<EditText>(Resource.Id.messageEditText);
             _sendButton = FindViewById<Button>(Resource.Id.sendButton);
             _ipInput = FindViewById<EditText>(Resource.Id.ipEditText);
             _connectButton = FindViewById<Button>(Resource.Id.connectButton);

            _sendButton.Click += SendButton_Click;
            _connectButton.Click += ConnectButton_Click;
            _sendButton.Enabled = false;
        }

        private void ConnectButton_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(_ipInput.Text))
            {
                ServerIp = _ipInput.Text.Trim();
                _connectButton.Enabled = false;
                ConnectToServerAsync();
            }
            else
            {
                Toast.MakeText(this, "Введите IP-адрес", ToastLength.Short).Show();
            }
        }

        private async void ConnectToServerAsync()
        {
            try
            {
                _client = new TcpClient();
                await _client.ConnectAsync(ServerIp, ServerPort);

                var stream = _client.GetStream();
                _reader = new StreamReader(stream, Encoding.UTF8);
                _writer = new StreamWriter(stream, Encoding.UTF8) { AutoFlush = true };

                RunOnUiThread(() =>
                {
                     _chatHistory.Text += "Подключено к серверу\n";
                    _chatHistory.Text += "Первое сообщение которое вы напишите будет вашим ником\n";
                    Toast.MakeText(this, "Подключено!", ToastLength.Short).Show();
                    _sendButton.Enabled = true;
                });

                _ = ReceiveMessagesAsync();
            }
            catch (Exception ex)
            {
                RunOnUiThread(() =>
                {
                     _chatHistory.Text += $"Ошибка подключения: {ex.Message}\n";
                     _connectButton.Enabled = true;
                });
            }
        }

        private async Task ReceiveMessagesAsync()
        {
            try
            {
                while (_client != null && _client.Connected)
                {
                    string message = await _reader.ReadLineAsync();
                    if (message != null)
                    {
                        RunOnUiThread(() =>
                        {
                             _chatHistory.Text += $"Собеседник: {message}\n";
                        });
                    }
                    else
                    {
                        break;
                    }
                }
            }
            catch (Exception)
            {
            }
            finally
            {
                 RunOnUiThread(() =>
                 {
                      if (!IsFinishing)
                      {
                           _chatHistory.Text += "Отключено от сервера.\n";
                           _connectButton.Enabled = true;
                           _sendButton.Enabled = false;
                      }
                 });

                 _client?.Close();
                 _client = null;
            }
        }

        private async void SendButton_Click(object sender, EventArgs e)
        {
            string message = _messageInput.Text;
            if (!string.IsNullOrWhiteSpace(message) && _client != null && _client.Connected)
            {
                try
                {
                    await _writer.WriteLineAsync(message);

                    _chatHistory.Text += $"Вы: {message}\n";
                    _messageInput.Text = string.Empty;
                }
                catch (Exception ex)
                {
                    Toast.MakeText(this, $"Ошибка отправки: {ex.Message}", ToastLength.Short).Show();
                }
            }
        }

        protected override void OnDestroy()
        {
            _reader?.Close();
            _writer?.Close();
            _client?.Close();

            base.OnDestroy();
        }
    }
}
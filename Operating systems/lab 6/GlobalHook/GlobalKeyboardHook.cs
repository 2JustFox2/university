using System.ComponentModel;
using System.Runtime.InteropServices;

namespace GlobalHookLib;

public sealed class GlobalKeyboardHook : IDisposable
{
    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;
    private const int WM_SYSKEYDOWN = 0x0104;
    private const int WM_QUIT = 0x0012;
    private const int VK_SHIFT = 0x10;
    private const int VK_CONTROL = 0x11;
    private const int VK_MENU = 0x12;
    private const int VK_CAPITAL = 0x14;
    private const int VK_NUMLOCK = 0x90;
    private const int VK_SCROLL = 0x91;

    private readonly object _sync = new();
    private readonly List<string> _events = new();
    private readonly ManualResetEventSlim _ready = new(false);
    private LowLevelKeyboardProc? _proc;
    private Thread? _hookThread;
    private IntPtr _hookId = IntPtr.Zero;
    private int _hookThreadId;
    private Exception? _startupException;

    public IReadOnlyList<string> Events
    {
        get
        {
            lock (_sync)
            {
                return _events.ToArray();
            }
        }
    }

    public void Install()
    {
        if (_hookThread != null)
        {
            return;
        }

        _proc = HookCallback;
        _startupException = null;
        _ready.Reset();

        _hookThread = new Thread(HookThreadProc)
        {
            IsBackground = true,
            Name = "GlobalKeyboardHook"
        };

        _hookThread.Start();
        _ready.Wait();

        if (_startupException != null)
        {
            Thread? failedThread = _hookThread;
            _hookThread = null;
            failedThread?.Join();
            throw _startupException;
        }
    }

    public void Uninstall()
    {
        if (_hookThread == null)
        {
            return;
        }

        PostThreadMessage(_hookThreadId, WM_QUIT, IntPtr.Zero, IntPtr.Zero);
        _hookThread.Join();
        _hookThread = null;
        _hookId = IntPtr.Zero;
    }

    public void Dispose()
    {
        Uninstall();
        _ready.Dispose();
    }

    private void HookThreadProc()
    {
        try
        {
            _hookThreadId = GetCurrentThreadId();
            _hookId = SetWindowsHookEx(WH_KEYBOARD_LL, _proc!, GetModuleHandle(null), 0);

            if (_hookId == IntPtr.Zero)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error());
            }
        }
        catch (Exception ex)
        {
            _startupException = ex;
            _ready.Set();
            return;
        }

        _ready.Set();

        try
        {
            while (GetMessage(out MSG message, IntPtr.Zero, 0, 0) != 0)
            {
                TranslateMessage(ref message);
                DispatchMessage(ref message);
            }
        }
        finally
        {
            if (_hookId != IntPtr.Zero)
            {
                UnhookWindowsHookEx(_hookId);
            }
        }
    }

    private IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (nCode >= 0 && (wParam == (IntPtr)WM_KEYDOWN || wParam == (IntPtr)WM_SYSKEYDOWN))
        {
            var keyboardHookStruct = Marshal.PtrToStructure<KBDLLHOOKSTRUCT>(lParam);
            string keyText = TranslateKeyToText(keyboardHookStruct.vkCode, keyboardHookStruct.scanCode);
            string entry = $"Key pressed: {keyText} (VK {keyboardHookStruct.vkCode}) at {DateTime.Now:HH:mm:ss}";

            lock (_sync)
            {
                _events.Add(entry);
            }

            Console.WriteLine(entry);
        }

        return CallNextHookEx(_hookId, nCode, wParam, lParam);
    }

    private static string TranslateKeyToText(uint vkCode, uint scanCode)
    {
        IntPtr keyboardLayout = GetKeyboardLayout(GetWindowThreadProcessId(GetForegroundWindow(), out _));
        byte[] keyboardState = BuildKeyboardState();
        uint scanCodeForTranslation = scanCode != 0 ? scanCode : MapVirtualKeyEx(vkCode, 0, keyboardLayout);
        char[] buffer = new char[8];
        int result = ToUnicodeEx(vkCode, scanCodeForTranslation, keyboardState, buffer, buffer.Length, 0, keyboardLayout);

        if (result > 0)
        {
            return new string(buffer, 0, result);
        }

        return $"VK {vkCode}";
    }

    private static byte[] BuildKeyboardState()
    {
        byte[] keyboardState = new byte[256];

        for (int key = 0; key < keyboardState.Length; key++)
        {
            if ((GetAsyncKeyState(key) & 0x8000) != 0)
            {
                keyboardState[key] |= 0x80;
            }
        }

        ApplyToggleState(keyboardState, VK_CAPITAL);
        ApplyToggleState(keyboardState, VK_NUMLOCK);
        ApplyToggleState(keyboardState, VK_SCROLL);

        return keyboardState;
    }

    private static void ApplyToggleState(byte[] keyboardState, int virtualKey)
    {
        if ((GetKeyState(virtualKey) & 0x0001) != 0)
        {
            keyboardState[virtualKey] |= 0x01;
        }
    }

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("user32.dll")]
    private static extern int GetMessage(out MSG lpMsg, IntPtr hWnd, uint wMsgFilterMin, uint wMsgFilterMax);

    [DllImport("user32.dll")]
    private static extern bool TranslateMessage(ref MSG lpMsg);

    [DllImport("user32.dll")]
    private static extern IntPtr DispatchMessage(ref MSG lpMsg);

    [DllImport("user32.dll")]
    private static extern bool GetKeyboardState(byte[] lpKeyState);

    [DllImport("user32.dll")]
    private static extern short GetAsyncKeyState(int vKey);

    [DllImport("user32.dll")]
    private static extern short GetKeyState(int nVirtKey);

    [DllImport("user32.dll")]
    private static extern short ToUnicodeEx(uint wVirtKey, uint wScanCode, byte[] lpKeyState, [Out] char[] pwszBuff, int cchBuff, uint wFlags, IntPtr dwhkl);

    [DllImport("user32.dll")]
    private static extern uint MapVirtualKeyEx(uint uCode, uint uMapType, IntPtr dwhkl);

    [DllImport("user32.dll")]
    private static extern IntPtr GetKeyboardLayout(uint idThread);

    [DllImport("user32.dll")]
    private static extern IntPtr GetForegroundWindow();

    [DllImport("user32.dll")]
    private static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool PostThreadMessage(int idThread, int Msg, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string? lpModuleName);

    [DllImport("kernel32.dll")]
    private static extern int GetCurrentThreadId();

    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);

    [StructLayout(LayoutKind.Sequential)]
    private struct KBDLLHOOKSTRUCT
    {
        public uint vkCode;
        public uint scanCode;
        public uint flags;
        public uint time;
        public UIntPtr dwExtraInfo;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct MSG
    {
        public IntPtr hwnd;
        public uint message;
        public IntPtr wParam;
        public IntPtr lParam;
        public uint time;
        public POINT pt;
        public uint lPrivate;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct POINT
    {
        public int x;
        public int y;
    }
}
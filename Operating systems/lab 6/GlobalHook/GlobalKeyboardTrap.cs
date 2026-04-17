using System.Collections.Concurrent;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace GlobalHook;

public sealed class GlobalKeyboardTrap : IDisposable
{
    private const int WhKeyboardLl = 13;
    private const int WmKeyDown = 0x0100;
    private const int WmSysKeyDown = 0x0104;
    private const uint LlkhfInjected = 0x00000010;

    private readonly ConcurrentQueue<HookEventInfo> _events = new();
    private readonly HookProc _callback;
    private readonly object _sync = new();

    private nint _hookHandle;
    private bool _disposed;

    public GlobalKeyboardTrap()
    {
        _callback = HookCallback;
    }

    public bool IsLoaded => _hookHandle != nint.Zero;

    public event EventHandler<HookEventInfo>? KeyCaptured;

    public void Load()
    {
        ThrowIfDisposed();

        lock (_sync)
        {
            if (IsLoaded)
            {
                return;
            }

            nint moduleHandle = GetModuleHandle(Process.GetCurrentProcess().MainModule?.ModuleName);
            _hookHandle = SetWindowsHookEx(WhKeyboardLl, _callback, moduleHandle, 0);
            if (_hookHandle == nint.Zero)
            {
                throw new InvalidOperationException($"SetWindowsHookEx failed with error {Marshal.GetLastWin32Error()}.");
            }
        }
    }

    public void Unload()
    {
        ThrowIfDisposed();

        lock (_sync)
        {
            if (!IsLoaded)
            {
                return;
            }

            if (!UnhookWindowsHookEx(_hookHandle))
            {
                throw new InvalidOperationException($"UnhookWindowsHookEx failed with error {Marshal.GetLastWin32Error()}.");
            }

            _hookHandle = nint.Zero;
        }
    }

    public IReadOnlyList<HookEventInfo> DrainEvents()
    {
        ThrowIfDisposed();

        var result = new List<HookEventInfo>();
        while (_events.TryDequeue(out HookEventInfo? item))
        {
            result.Add(item);
        }

        return result;
    }

    private nint HookCallback(int code, nint wParam, nint lParam)
    {
        if (code >= 0)
        {
            int message = unchecked((int)wParam);
            if (message == WmKeyDown || message == WmSysKeyDown)
            {
                Kbdllhookstruct data = Marshal.PtrToStructure<Kbdllhookstruct>(lParam);
                int currentPid = Environment.ProcessId;
                var evt = new HookEventInfo(
                    Timestamp: DateTime.Now,
                    VirtualKeyCode: unchecked((int)data.vkCode),
                    IsKeyDown: true,
                    IsInjected: (data.flags & LlkhfInjected) != 0,
                    ProcessId: currentPid
                );

                _events.Enqueue(evt);
                KeyCaptured?.Invoke(this, evt);
            }
        }

        return CallNextHookEx(_hookHandle, code, wParam, lParam);
    }

    private void ThrowIfDisposed()
    {
        if (_disposed)
        {
            throw new ObjectDisposedException(nameof(GlobalKeyboardTrap));
        }
    }

    public void Dispose()
    {
        if (_disposed)
        {
            return;
        }

        if (IsLoaded)
        {
            Unload();
        }

        _disposed = true;
        GC.SuppressFinalize(this);
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct Kbdllhookstruct
    {
        public uint vkCode;
        public uint scanCode;
        public uint flags;
        public uint time;
        public nint dwExtraInfo;
    }

    private delegate nint HookProc(int code, nint wParam, nint lParam);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern nint SetWindowsHookEx(int idHook, HookProc lpfn, nint hMod, uint dwThreadId);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool UnhookWindowsHookEx(nint hhk);

    [DllImport("user32.dll")]
    private static extern nint CallNextHookEx(nint hhk, int nCode, nint wParam, nint lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern nint GetModuleHandle(string? lpModuleName);
}

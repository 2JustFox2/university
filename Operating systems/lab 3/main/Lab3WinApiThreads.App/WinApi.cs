using System.Runtime.InteropServices;

namespace Lab3WinApiThreads.App;

internal static class WinApi
{
    internal const uint INFINITE = 0xFFFFFFFF;
    internal const uint WAIT_OBJECT_0 = 0x00000000;
    internal const uint WAIT_TIMEOUT = 0x00000102;
    internal const uint WAIT_FAILED = 0xFFFFFFFF;

    internal const uint EVENT_MODIFY_STATE = 0x0002;
    internal const uint SYNCHRONIZE = 0x00100000;

    internal const int THREAD_PRIORITY_IDLE = -15;
    internal const int THREAD_PRIORITY_LOWEST = -2;
    internal const int THREAD_PRIORITY_BELOW_NORMAL = -1;
    internal const int THREAD_PRIORITY_NORMAL = 0;
    internal const int THREAD_PRIORITY_ABOVE_NORMAL = 1;
    internal const int THREAD_PRIORITY_HIGHEST = 2;
    internal const int THREAD_PRIORITY_TIME_CRITICAL = 15;

    internal const int WM_APP = 0x8000;

    [Flags]
    internal enum CreateEventFlags : uint
    {
        ManualReset = 0x00000001,
        InitialSet = 0x00000002,
    }

    [UnmanagedFunctionPointer(CallingConvention.StdCall)]
    internal delegate uint ThreadProc(IntPtr parameter);

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern IntPtr CreateThread(
        IntPtr lpThreadAttributes,
        nuint dwStackSize,
        IntPtr lpStartAddress,
        IntPtr lpParameter,
        uint dwCreationFlags,
        out uint lpThreadId);

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern bool CloseHandle(IntPtr hObject);

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern uint WaitForSingleObject(IntPtr hHandle, uint dwMilliseconds);

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern uint WaitForMultipleObjects(uint nCount, IntPtr[] lpHandles, bool bWaitAll, uint dwMilliseconds);

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern IntPtr CreateEventW(IntPtr lpEventAttributes, bool bManualReset, bool bInitialState, string? lpName);

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern bool SetEvent(IntPtr hEvent);

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern bool ResetEvent(IntPtr hEvent);

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern IntPtr CreateMutexW(IntPtr lpMutexAttributes, bool bInitialOwner, string? lpName);

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern bool ReleaseMutex(IntPtr hMutex);

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern bool SetThreadPriority(IntPtr hThread, int nPriority);

    [DllImport("kernel32.dll", SetLastError = true)]
    internal static extern int GetThreadPriority(IntPtr hThread);

    [DllImport("kernel32.dll")]
    internal static extern void Sleep(uint dwMilliseconds);

    [DllImport("user32.dll", SetLastError = true)]
    internal static extern bool PostMessageW(IntPtr hWnd, int Msg, IntPtr wParam, IntPtr lParam);
}


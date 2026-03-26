using System.ComponentModel;
using System.Runtime.InteropServices;

namespace Lab3WinApiThreads.App;

internal sealed class ChildThreadController : IDisposable
{
    [StructLayout(LayoutKind.Sequential)]
    private struct SharedData
    {
        public int Counter;
        public int ParentToChild;
        public int ChildToParent;
        public int LastOp; // 0-none, 1-parent->child consumed, 2-child->parent produced
    }

    private readonly IntPtr _hwnd;

    private IntPtr _thread = IntPtr.Zero;
    private uint _threadId;

    private IntPtr _evtCanRun = IntPtr.Zero;        // manual-reset: set => running, reset => paused
    private IntPtr _evtStop = IntPtr.Zero;          // manual-reset: set => stop requested
    private IntPtr _evtParentToChild = IntPtr.Zero; // auto-reset: parent posted new data
    private IntPtr _mutex = IntPtr.Zero;

    private IntPtr _shared = IntPtr.Zero;

    private WinApi.ThreadProc? _proc;
    private GCHandle _procHandle;

    public bool IsCreated => _thread != IntPtr.Zero;

    public ChildThreadController(IntPtr hwnd)
    {
        _hwnd = hwnd;
    }

    public void CreateIfNeededAndRun()
    {
        if (!IsCreated)
        {
            CreateInternal();
        }

        if (_evtCanRun != IntPtr.Zero)
        {
            WinApi.SetEvent(_evtCanRun);
        }
    }

    public void Pause()
    {
        if (_evtCanRun != IntPtr.Zero)
        {
            WinApi.ResetEvent(_evtCanRun);
        }
    }

    public void Stop()
    {
        if (!IsCreated)
        {
            return;
        }

        if (_evtStop != IntPtr.Zero)
        {
            WinApi.SetEvent(_evtStop);
        }

        if (_evtCanRun != IntPtr.Zero)
        {
            WinApi.SetEvent(_evtCanRun); // wake from pause
        }

        _ = WinApi.WaitForSingleObject(_thread, 2000);

        CleanupHandles();
    }

    public void SetPriority(int priority)
    {
        if (!IsCreated)
        {
            return;
        }

        if (!WinApi.SetThreadPriority(_thread, priority))
        {
            throw new Win32Exception(Marshal.GetLastWin32Error(), "SetThreadPriority failed");
        }
    }

    public int GetPriorityOrDefault()
    {
        if (!IsCreated)
        {
            return WinApi.THREAD_PRIORITY_NORMAL;
        }

        return WinApi.GetThreadPriority(_thread);
    }

    public void SendParentValue(int value)
    {
        if (!IsCreated)
        {
            return;
        }

        if (_mutex == IntPtr.Zero || _shared == IntPtr.Zero || _evtParentToChild == IntPtr.Zero)
        {
            return;
        }

        _ = WinApi.WaitForSingleObject(_mutex, WinApi.INFINITE);
        try
        {
            var data = Marshal.PtrToStructure<SharedData>(_shared);
            data.ParentToChild = value;
            data.LastOp = 0;
            Marshal.StructureToPtr(data, _shared, false);
        }
        finally
        {
            WinApi.ReleaseMutex(_mutex);
        }

        WinApi.SetEvent(_evtParentToChild);
    }

    private void CreateInternal()
    {
        _evtCanRun = WinApi.CreateEventW(IntPtr.Zero, bManualReset: true, bInitialState: false, lpName: null);
        if (_evtCanRun == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error(), "CreateEvent(canRun) failed");

        _evtStop = WinApi.CreateEventW(IntPtr.Zero, bManualReset: true, bInitialState: false, lpName: null);
        if (_evtStop == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error(), "CreateEvent(stop) failed");

        _evtParentToChild = WinApi.CreateEventW(IntPtr.Zero, bManualReset: false, bInitialState: false, lpName: null);
        if (_evtParentToChild == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error(), "CreateEvent(parentToChild) failed");

        _mutex = WinApi.CreateMutexW(IntPtr.Zero, bInitialOwner: false, lpName: null);
        if (_mutex == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error(), "CreateMutex failed");

        _shared = Marshal.AllocHGlobal(Marshal.SizeOf<SharedData>());
        Marshal.StructureToPtr(new SharedData { Counter = 0, ParentToChild = 0, ChildToParent = 0, LastOp = 0 }, _shared, false);

        _proc = ThreadMain;
        _procHandle = GCHandle.Alloc(_proc);
        var start = Marshal.GetFunctionPointerForDelegate(_proc);

        var param = GCHandle.Alloc(this);
        try
        {
            _thread = WinApi.CreateThread(
                IntPtr.Zero,
                0,
                start,
                GCHandle.ToIntPtr(param),
                0,
                out _threadId);
            if (_thread == IntPtr.Zero)
            {
                throw new Win32Exception(Marshal.GetLastWin32Error(), "CreateThread failed");
            }
        }
        catch
        {
            param.Free();
            throw;
        }
    }

    private static uint ThreadMain(IntPtr parameter)
    {
        var gch = GCHandle.FromIntPtr(parameter);
        var self = (ChildThreadController)gch.Target!;
        try
        {
            return self.RunLoop();
        }
        finally
        {
            gch.Free();
        }
    }

    private uint RunLoop()
    {
        var gate = new[] { _evtStop, _evtCanRun };

        while (true)
        {
            var gateWait = WinApi.WaitForMultipleObjects(2, gate, bWaitAll: false, WinApi.INFINITE);
            if (gateWait == WinApi.WAIT_OBJECT_0)
            {
                break; // stop
            }

            if (gateWait != WinApi.WAIT_OBJECT_0 + 1)
            {
                break; // failed/unexpected
            }

            int counter;
            int childValue;

            _ = WinApi.WaitForSingleObject(_mutex, WinApi.INFINITE);
            try
            {
                var data = Marshal.PtrToStructure<SharedData>(_shared);

                data.Counter++;

                var gotParent = WinApi.WaitForSingleObject(_evtParentToChild, 0) == WinApi.WAIT_OBJECT_0;
                if (gotParent)
                {
                    // dynamic parent->child usage + modification
                    data.ChildToParent = data.ParentToChild + data.Counter;
                    data.LastOp = 2;
                }

                counter = data.Counter;
                childValue = data.ChildToParent;

                Marshal.StructureToPtr(data, _shared, false);
            }
            finally
            {
                WinApi.ReleaseMutex(_mutex);
            }

            // Notify UI thread via WinAPI message: wParam=counter, lParam=childValue
            WinApi.PostMessageW(_hwnd, WinApi.WM_APP + 1, (IntPtr)counter, (IntPtr)childValue);

            WinApi.Sleep(100);
        }

        return 0;
    }

    private void CleanupHandles()
    {
        if (_thread != IntPtr.Zero)
        {
            WinApi.CloseHandle(_thread);
            _thread = IntPtr.Zero;
        }

        if (_evtCanRun != IntPtr.Zero)
        {
            WinApi.CloseHandle(_evtCanRun);
            _evtCanRun = IntPtr.Zero;
        }

        if (_evtStop != IntPtr.Zero)
        {
            WinApi.CloseHandle(_evtStop);
            _evtStop = IntPtr.Zero;
        }

        if (_evtParentToChild != IntPtr.Zero)
        {
            WinApi.CloseHandle(_evtParentToChild);
            _evtParentToChild = IntPtr.Zero;
        }

        if (_mutex != IntPtr.Zero)
        {
            WinApi.CloseHandle(_mutex);
            _mutex = IntPtr.Zero;
        }

        if (_shared != IntPtr.Zero)
        {
            Marshal.FreeHGlobal(_shared);
            _shared = IntPtr.Zero;
        }

        if (_procHandle.IsAllocated)
        {
            _procHandle.Free();
        }

        _proc = null;
        _threadId = 0;
    }

    public void Dispose()
    {
        Stop();
        CleanupHandles();
        GC.SuppressFinalize(this);
    }
}


namespace GlobalHook;

public sealed record HookEventInfo(
    DateTime Timestamp,
    int VirtualKeyCode,
    bool IsKeyDown,
    bool IsInjected,
    int ProcessId
);

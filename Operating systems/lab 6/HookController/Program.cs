using GlobalHook;

Console.WriteLine("Global keyboard trap controller");
Console.WriteLine("Commands: load, events, unload, exit");

using var trap = new GlobalKeyboardTrap();

while (true)
{
	Console.Write("> ");
	string? command = Console.ReadLine()?.Trim().ToLowerInvariant();

	if (string.IsNullOrWhiteSpace(command))
	{
		continue;
	}

	try
	{
		switch (command)
		{
			case "load":
				trap.Load();
				Console.WriteLine("Trap loaded. Press keys in any app, then use 'events'.");
				break;

			case "events":
				IReadOnlyList<HookEventInfo> events = trap.DrainEvents();
				if (events.Count == 0)
				{
					Console.WriteLine("No captured events.");
					break;
				}

				foreach (HookEventInfo evt in events)
				{
					Console.WriteLine(
						$"[{evt.Timestamp:HH:mm:ss.fff}] VK={evt.VirtualKeyCode}, down={evt.IsKeyDown}, injected={evt.IsInjected}, pid={evt.ProcessId}");
				}

				break;

			case "unload":
				trap.Unload();
				Console.WriteLine("Trap unloaded.");
				break;

			case "exit":
				if (trap.IsLoaded)
				{
					trap.Unload();
				}

				return;

			default:
				Console.WriteLine("Unknown command. Use: load, events, unload, exit");
				break;
		}
	}
	catch (Exception ex)
	{
		Console.WriteLine($"Error: {ex.Message}");
	}
}

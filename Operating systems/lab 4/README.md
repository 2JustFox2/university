# Lab 4 - WinForms + WinAPI template

A small .NET 8 Windows Forms starter that demonstrates direct WinAPI interop from C#.

## What it includes

- A clean WinForms entry point without the designer.
- A sample form with buttons for common `user32.dll` calls.
- A dedicated `NativeMethods` class for P/Invoke declarations.

## Build and run

Open the folder in Visual Studio or run:

```powershell
dotnet run
```

## Notes

This template targets `net8.0-windows` and uses Windows Forms, so it must be built on Windows.

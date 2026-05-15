using System;
using System.Runtime.InteropServices;
using System.Collections.Generic;

namespace RegistryApp
{
    /// <summary>
    /// Класс для изменения настроек рабочего стола
    /// </summary>
    public class DesktopSettings
    {
        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool SystemParametersInfo(uint uiAction, uint uiParam, IntPtr pvParam, uint fWinIni);

        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        private static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, IntPtr lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);

        [DllImport("user32.dll")]
        private static extern bool InvalidateRect(IntPtr hWnd, IntPtr lpRect, bool bErase);

        [DllImport("user32.dll")]
        private static extern IntPtr GetDesktopWindow();

        private const uint SPI_SETDESKWALLPAPER = 20;
        private const uint SPI_GETDESKWALLPAPER = 73;
        private const uint SPIF_UPDATEINIFILE = 0x01;
        private const uint SPIF_SENDCHANGE = 0x02;
        private const uint WM_SETTINGCHANGE = 0x001A;
        private const uint HWND_BROADCAST = 0xFFFF;
        private const uint SMTO_ABORTIFHUNG = 0x0002;

        public enum WallpaperStyle
        {
            Tiled = 0,
            Centered = 1,
            Stretched = 2,
            Fit = 6,
            Fill = 10
        }

        /// <summary>
        /// Установка цвета фона рабочего стола
        /// </summary>
        public static bool SetBackgroundColor(byte red, byte green, byte blue)
        {
            try
            {
                // Удаляем обойму, чтобы цвет был виден
                RegistryHelper.SetRegistryValue("HKCU", 
                    @"Control Panel\Desktop", 
                    "Wallpaper", 
                    "", 
                    Microsoft.Win32.RegistryValueKind.String);
                
                // Устанавливаем стиль на пустой/заполненный
                RegistryHelper.SetRegistryValue("HKCU", 
                    @"Control Panel\Desktop", 
                    "WallpaperStyle", 
                    "10", 
                    Microsoft.Win32.RegistryValueKind.String);
                
                // Устанавливаем цвет (BGR формат!)
                string colorValue = $"{blue} {green} {red}";
                RegistryHelper.SetRegistryValue("HKCU", 
                    @"Control Panel\Colors", 
                    "Background", 
                    colorValue, 
                    Microsoft.Win32.RegistryValueKind.String);
                
                // Явно обновляем обои через SystemParametersInfo
                IntPtr ptrEmpty = Marshal.StringToHGlobalUni("");
                SystemParametersInfo(SPI_SETDESKWALLPAPER, 0, ptrEmpty, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                Marshal.FreeHGlobal(ptrEmpty);
                
                System.Threading.Thread.Sleep(100);
                
                return true;
            }
            catch (Exception ex)
            {
                throw new Exception($"Ошибка при установке цвета: {ex.Message}");
            }
        }
    }
}

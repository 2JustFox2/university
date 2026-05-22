using Microsoft.Win32;
using System;
using System.Security.AccessControl;
using System.Security.Principal;

namespace RegistryApp
{
    public class RegistryHelper
    {
        public static string? ReadRegistryValue(string hive, string path, string valueName)
        {
            try
            {
                RegistryKey baseKey = GetHiveKey(hive);
                using (RegistryKey? key = baseKey.OpenSubKey(path))
                {
                    if (key != null)
                    {
                        object? value = key.GetValue(valueName);
                        return value?.ToString() ?? "Значение не найдено";
                    }
                    return "Ключ не найден";
                }
            }
            catch (Exception ex)
            {
                return $"Ошибка: {ex.Message}";
            }
        }

        public static bool CreateRegistryKey(string hive, string path)
        {
            try
            {
                RegistryKey baseKey = GetHiveKey(hive);
                using (RegistryKey key = baseKey.CreateSubKey(path))
                {
                    return key != null;
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Ошибка при создании ключа: {ex.Message}");
            }
        }

        public static bool SetRegistryValue(string hive, string path, string valueName, object value, RegistryValueKind kind)
        {
            try
            {
                RegistryKey baseKey = GetHiveKey(hive);
                using (RegistryKey? key = baseKey.OpenSubKey(path, true))
                {
                    if (key != null)
                    {
                        key.SetValue(valueName, value, kind);
                        return true;
                    }
                    return false;
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Ошибка при установке значения: {ex.Message}");
            }
        }

        public static bool DeleteRegistryKey(string hive, string path)
        {
            try
            {
                RegistryKey baseKey = GetHiveKey(hive);
                baseKey.DeleteSubKey(path, false);
                return true;
            }
            catch (Exception ex)
            {
                throw new Exception($"Ошибка при удалении ключа: {ex.Message}");
            }
        }

        public static bool DeleteRegistryValue(string hive, string path, string valueName)
        {
            try
            {
                RegistryKey baseKey = GetHiveKey(hive);
                using (RegistryKey? key = baseKey.OpenSubKey(path, true))
                {
                    if (key != null)
                    {
                        key.DeleteValue(valueName, false);
                        return true;
                    }
                    return false;
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Ошибка при удалении значения: {ex.Message}");
            }
        }

        public static bool SetKeyPermissions(string hive, string path, bool allowModification)
        {
            try
            {
                RegistryKey baseKey = GetHiveKey(hive);
                using (RegistryKey? key = baseKey.OpenSubKey(path, RegistryKeyPermissionCheck.ReadWriteSubTree, RegistryRights.ChangePermissions))
                {
                    if (key != null)
                    {
                        RegistrySecurity registrySecurity = key.GetAccessControl();
                        string? user = WindowsIdentity.GetCurrent().User?.Value;
                        
                        if (user != null)
                        {
                            if (allowModification)
                            {
                                registrySecurity.AddAccessRule(new RegistryAccessRule(
                                    new SecurityIdentifier(user),
                                    RegistryRights.FullControl,
                                    InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit,
                                    PropagationFlags.None,
                                    AccessControlType.Allow));
                            }
                            else
                            {
                                registrySecurity.RemoveAccessRule(new RegistryAccessRule(
                                    new SecurityIdentifier(user),
                                    RegistryRights.FullControl,
                                    InheritanceFlags.ContainerInherit | InheritanceFlags.ObjectInherit,
                                    PropagationFlags.None,
                                    AccessControlType.Allow));
                            }
                            
                            key.SetAccessControl(registrySecurity);
                        }
                        return true;
                    }
                    return false;
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Ошибка при изменении прав: {ex.Message}");
            }
        }

        private static RegistryKey GetHiveKey(string hive)
        {
            return hive.ToUpper() switch
            {
                "HKEY_LOCAL_MACHINE" or "HKLM" => Registry.LocalMachine,
                "HKEY_CURRENT_USER" or "HKCU" => Registry.CurrentUser,
                "HKEY_CLASSES_ROOT" or "HKCR" => Registry.ClassesRoot,
                "HKEY_USERS" or "HKU" => Registry.Users,
                "HKEY_CURRENT_CONFIG" or "HKCC" => Registry.CurrentConfig,
                _ => throw new ArgumentException($"Неизвестный куст реестра: {hive}")
            };
        }

        public static string[] GetSubKeyNames(string hive, string path)
        {
            try
            {
                RegistryKey baseKey = GetHiveKey(hive);
                using (RegistryKey? key = baseKey.OpenSubKey(path))
                {
                    if (key != null)
                    {
                        return key.GetSubKeyNames();
                    }
                    return Array.Empty<string>();
                }
            }
            catch (Exception)
            {
                return Array.Empty<string>();
            }
        }
    }
}

# Менеджер реестра и настроек рабочего стола на C#

## Описание

Это полнофункциональное Windows-приложение на C# с графическим интерфейсом (Windows Forms), которое позволяет:

1. **Чтение ключей реестра** - чтение значений из различных кустов реестра Windows
2. **Создание ключей реестра** - создание новых ключей и установка значений
3. **Удаление ключей реестра** - удаление существующих ключей с подтверждением
4. **Изменение прав доступа** - управление правами на изменение ключей реестра
5. **Настройки рабочего стола** - изменение цвета фона, стиля обоев, экранной заставки и т.д.

## Требования

- .NET 8.0 или выше
- Windows 7/8/10/11
- Права администратора для некоторых операций

## Установка

### 1. Клонирование или создание проекта

```bash
cd "Operating systems\registry"
```

### 2. Восстановление зависимостей

```bash
dotnet restore
```

### 3. Сборка проекта

```bash
dotnet build
```

## Запуск приложения

```bash
dotnet run
```

Или для режима Release:

```bash
dotnet run -c Release
```

## Структура проекта

### Файлы

- **Program.cs** - точка входа в приложение
- **MainForm.cs** - главное окно приложения с графическим интерфейсом
- **RegistryHelper.cs** - вспомогательный класс для работы с реестром Windows
- **DesktopSettings.cs** - класс для управления настройками рабочего стола
- **RegistryApp.csproj** - файл конфигурации проекта

## Использование

### Вкладка "Чтение ключей"

1. Выберите куст реестра (HKEY_LOCAL_MACHINE, HKEY_CURRENT_USER и т.д.)
2. Введите путь к ключу (например: `Software\Microsoft\Windows`)
3. Введите имя значения (например: `ProgramFilesDir`)
4. Нажмите кнопку "Прочитать значение"
5. Результат появится в поле внизу

**Примеры путей:**

- `Software\Microsoft\Windows` - настройки Windows
- `Software\Microsoft\Windows\CurrentVersion` - информация о версии
- `Control Panel\Desktop` - настройки рабочего стола

### Вкладка "Создание ключей"

1. Выберите куст реестра
2. Введите путь для нового ключа (например: `Software\MyApp\Settings`)
3. Введите имя значения (например: `ConfigValue`)
4. Введите значение (например: `MyValue`)
5. Нажмите кнопку "Создать ключ и значение"

**Внимание:** Некоторые области реестра защищены и требуют прав администратора!

### Вкладка "Удаление ключей"

1. Выберите куст реестра
2. Введите полный путь к ключу для удаления
3. Нажмите кнопку "Удалить ключ"
4. Подтвердите удаление в диалоговом окне

**Предупреждение:** Удаление может быть необратимым. Будьте осторожны!

### Вкладка "Права доступа"

1. Выберите куст реестра
2. Введите путь к ключу
3. Установите флажок "Разрешить изменение ключа" или оставьте его пустым для запрета
4. Нажмите кнопку "Применить права"

### Вкладка "Настройки рабочего стола"

Позволяет изменять следующие параметры:

#### Цвет фона

- Выберите значения RGB (0-255)
- Нажмите "Применить цвет"

#### Стиль обоев

- Tiled (мозаика)
- Centered (по центру)
- Stretched (растянуто)
- Fit (вписать)
- Fill (заполнить)

#### Экранная заставка

- Установите время ожидания в секундах (0-3600)
- Включите или отключите экранную заставку
- Примените настройки

## Примеры кода

### Чтение значения из реестра

```csharp
string value = RegistryHelper.ReadRegistryValue(
    "HKEY_CURRENT_USER",
    @"Software\Microsoft\Windows",
    "ProgramFilesDir");
Console.WriteLine(value);
```

### Создание ключа

```csharp
bool success = RegistryHelper.CreateRegistryKey(
    "HKEY_CURRENT_USER",
    @"Software\MyApp\Settings");
```

### Установка значения

```csharp
bool success = RegistryHelper.SetRegistryValue(
    "HKEY_CURRENT_USER",
    @"Software\MyApp",
    "ConfigKey",
    "ConfigValue",
    RegistryValueKind.String);
```

### Удаление ключа

```csharp
bool success = RegistryHelper.DeleteRegistryKey(
    "HKEY_CURRENT_USER",
    @"Software\MyApp\Settings");
```

### Изменение цвета рабочего стола

```csharp
// RGB: 255, 128, 64 (оранжевый)
bool success = DesktopSettings.SetBackgroundColor(255, 128, 64);
```

### Установка стиля обоев

```csharp
bool success = DesktopSettings.SetWallpaperStyle(DesktopSettings.WallpaperStyle.Stretched);
```

## Поддерживаемые кусты реестра

- **HKEY_LOCAL_MACHINE (HKLM)** - локальные настройки машины
- **HKEY_CURRENT_USER (HKCU)** - настройки текущего пользователя
- **HKEY_CLASSES_ROOT (HKCR)** - информация о типах файлов и расширениях
- **HKEY_USERS (HKU)** - информация о всех пользователях
- \*\*HKEY_CURRENT_CONFIG (HKCC)- информация о текущей конфигурации

## Важная информация о безопасности

⚠️ **Внимание!** Реестр Windows - это критическая база данных операционной системы.
Неправильные изменения могут привести к нестабильности или неработоспособности системы.

### Советы по безопасности:

1. **Создавайте резервные копии реестра перед важными операциями**
2. **Работайте с собственными ключами, а не системными**
3. **Используйте права администратора только когда это необходимо**
4. **Протестируйте операции в безопасной среде перед использованием на производстве**
5. **Всегда читайте пути ключей внимательно перед удалением**

## API-функции RegistryHelper

### ReadRegistryValue()

Читает значение из реестра.

```csharp
public static string ReadRegistryValue(string hive, string path, string valueName)
```

### CreateRegistryKey()

Создает новый ключ в реестре.

```csharp
public static bool CreateRegistryKey(string hive, string path)
```

### SetRegistryValue()

Устанавливает значение в ключе реестра.

```csharp
public static bool SetRegistryValue(string hive, string path, string valueName,
    object value, RegistryValueKind kind)
```

### DeleteRegistryKey()

Удаляет ключ из реестра.

```csharp
public static bool DeleteRegistryKey(string hive, string path)
```

### DeleteRegistryValue()

Удаляет значение из ключа.

```csharp
public static bool DeleteRegistryValue(string hive, string path, string valueName)
```

### SetKeyPermissions()

Изменяет права доступа к ключу.

```csharp
public static bool SetKeyPermissions(string hive, string path, bool allowModification)
```

### GetSubKeyNames()

Получает список подключей.

```csharp
public static string[] GetSubKeyNames(string hive, string path)
```

## API-функции DesktopSettings

### SetWallpaper()

Устанавливает обои рабочего стола.

```csharp
public static bool SetWallpaper(string imagePath)
```

### SetWallpaperStyle()

Устанавливает стиль обоев.

```csharp
public static bool SetWallpaperStyle(WallpaperStyle style)
```

### SetBackgroundColor()

Устанавливает цвет фона рабочего стола (RGB).

```csharp
public static bool SetBackgroundColor(byte red, byte green, byte blue)
```

### SetScreenSaverTimeout()

Устанавливает время ожидания экранной заставки.

```csharp
public static bool SetScreenSaverTimeout(int seconds)
```

### EnableScreenSaver()

Включает/отключает экранную заставку.

```csharp
public static bool EnableScreenSaver(bool enable)
```

## Типы значений реестра

При установке значений можно использовать следующие типы:

- **String** - текстовая строка
- **DWord** - 32-битное целое число
- **QWord** - 64-битное целое число
- **Binary** - бинарные данные
- **MultiString** - массив текстовых строк
- **ExpandString** - строка с переменными окружения

## Решение проблем

### "Доступ запрещен"

- Запустите приложение от администратора
- Проверьте, не защищен ли ключ реестра

### "Ключ не найден"

- Проверьте правильность пути
- Убедитесь, что ключ существует
- Проверьте выбранный куст реестра

### Изменения не применяются

- Перезагрузитесь или выйдите/войдите в систему
- Закройте все программы, которые могут использовать измененные параметры
- Проверьте права доступа

## Лицензия

Этот проект предоставляется в образовательных целях.

## Автор

Создано для обучения работе с реестром Windows и Windows Forms на C#.

## Дополнительные ресурсы

- [Microsoft Registry Documentation](https://docs.microsoft.com/en-us/windows/win32/sysinfo/registry)
- [C# RegistryKey Class](https://docs.microsoft.com/en-us/dotnet/api/microsoft.win32.registrykey)
- [Windows Forms Documentation](https://docs.microsoft.com/en-us/dotnet/desktop/winforms/)

# Быстрый старт

## Установка и запуск

### 1. Сборка проекта

Откройте PowerShell и перейдите в папку проекта:

```powershell
cd "c:\Users\alexv\OneDrive\projects\labs\Operating systems\registry"
```

Восстановите зависимости и постройте проект:

```powershell
dotnet restore
dotnet build
```

### 2. Запуск приложения

```powershell
dotnet run
```

## Основные функции

### 1️⃣ Чтение значений реестра

**Шаги:**

1. Перейдите на вкладку "Чтение ключей"
2. Выберите куст: `HKEY_CURRENT_USER`
3. Укажите путь: `Software\Microsoft\Windows`
4. Укажите значение: `ProgramFilesDir`
5. Нажмите "Прочитать значение"

**Результат:** Вы увидите путь к папке Program Files

### 2️⃣ Создание ключа

**Шаги:**

1. Перейдите на вкладку "Создание ключей"
2. Выберите куст: `HKEY_CURRENT_USER`
3. Укажите путь: `Software\MyTestApp\Settings`
4. Укажите имя значения: `MyParam`
5. Укажите значение: `MyValue`
6. Нажмите "Создать ключ и значение"

### 3️⃣ Удаление ключа

**Шаги:**

1. Перейдите на вкладку "Удаление ключей"
2. Выберите куст: `HKEY_CURRENT_USER`
3. Укажите путь: `Software\MyTestApp\Settings`
4. Нажмите "Удалить ключ"
5. Подтвердите удаление

### 4️⃣ Изменение прав доступа

**Шаги:**

1. Перейдите на вкладку "Права доступа"
2. Выберите куст: `HKEY_CURRENT_USER`
3. Укажите путь к ключу
4. Отметьте/отмените "Разрешить изменение ключа"
5. Нажмите "Применить права"

### 5️⃣ Настройки рабочего стола

#### Изменить цвет фона:

1. На вкладке "Настройки рабочего стола"
2. Установите RGB (например: R=255, G=100, B=50)
3. Нажмите "Применить цвет"

#### Установить стиль обоев:

1. Выберите стиль из списка
2. Нажмите "Применить стиль"

#### Включить экранную заставку:

1. Установите время ожидания (например: 600 секунд = 10 минут)
2. Отметьте "Включить экранную заставку"
3. Нажмите "Применить"

## Примеры путей в реестре

| Куст | Путь                                      | Назначение                  |
| ---- | ----------------------------------------- | --------------------------- |
| HKCU | Software\Microsoft\Windows\CurrentVersion | Информация о версии Windows |
| HKCU | Control Panel\Desktop                     | Параметры рабочего стола    |
| HKCU | Control Panel\Colors                      | Цвета интерфейса            |
| HKCU | Software\Microsoft\Windows\Explorer       | Параметры обозревателя      |
| HKLM | Software\Microsoft\Windows\CurrentVersion | Глобальные параметры версии |
| HKLM | SYSTEM\CurrentControlSet\Control          | Параметры системы           |

## Интеграция в собственный код

```csharp
// Подключите пространство имен
using RegistryApp;

// Пример 1: Чтение значения
string value = RegistryHelper.ReadRegistryValue(
    "HKEY_CURRENT_USER",
    @"Software\MyApp",
    "Setting");

// Пример 2: Создание ключа
RegistryHelper.CreateRegistryKey(
    "HKEY_CURRENT_USER",
    @"Software\MyApp\Config");

// Пример 3: Установка значения
RegistryHelper.SetRegistryValue(
    "HKEY_CURRENT_USER",
    @"Software\MyApp",
    "Version",
    "1.0.0",
    Microsoft.Win32.RegistryValueKind.String);

// Пример 4: Удаление значения
RegistryHelper.DeleteRegistryValue(
    "HKEY_CURRENT_USER",
    @"Software\MyApp",
    "TempSetting");

// Пример 5: Изменение цвета рабочего стола
DesktopSettings.SetBackgroundColor(200, 150, 100);

// Пример 6: Установка стиля обоев
DesktopSettings.SetWallpaperStyle(
    DesktopSettings.WallpaperStyle.Stretched);
```

## Типичные ошибки

### ❌ "Доступ запрещен"

**Решение:** Запустите приложение как администратор

```powershell
Start-Process dotnet run -Verb RunAs
```

### ❌ "Ключ не найден"

**Проверьте:**

- Правильность пути к ключу
- Выбран ли правильный куст
- Существует ли ключ (прочитайте сначала через приложение)

### ❌ Изменения не видны сразу

**Решение:** Перезагрузитесь или повторно войдите в систему

## Режимы сборки

### Debug (разработка)

```powershell
dotnet run
```

### Release (оптимизация)

```powershell
dotnet run -c Release
```

### Создание исполняемого файла

```powershell
dotnet publish -c Release -o ./publish
```

Исполняемый файл будет в папке `publish\`.

## Резервная копия реестра

Перед началом работы создайте резервную копию:

```powershell
# Экспорт раздела
reg export "HKEY_CURRENT_USER\Software\MyApp" "backup.reg"

# Импорт при необходимости
reg import backup.reg
```

## Дополнительная информация

📖 Документация: [README.md](README.md)
🔧 Исходный код: Все файлы .cs содержат комментарии на русском
⚠️ Безопасность: Всегда проверяйте пути перед удалением!

---

Успехов в работе с реестром Windows! 🚀

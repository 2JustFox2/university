import re
from window import AppWindow
import tkinter as tk
import sys

def parse_data(file_path):
    try: 
        with open(file_path, 'r') as file:
            data = file.readlines()
            return [re.sub(r'\s+', ' ', line).strip().split(' ') for line in data]
    except FileNotFoundError:
        print(f"Файл {file_path} не найден")
        return []
    except Exception as e:
        print(f"Ошибка при чтении файла: {e}")
        return []

def validate_data(data):
    if not data:
        return False, "Файл пустой"

    if len(data) < 2:
        return False, "В файле должна быть строка заголовков и хотя бы одна строка данных"

    expected_len = len(data[0])
    if expected_len < 2:
        return False, "В заголовке должно быть минимум два столбца"

    for row_index, row in enumerate(data):
        if len(row) != expected_len:
            return False, f"Строка {row_index + 1} содержит {len(row)} элементов вместо {expected_len}"

    try:
        [float(value) for value in data[0][1:]]
        [float(row[0]) for row in data[1:]]
        for row in data[1:]:
            [float(value) for value in row[1:]]
    except ValueError:
        return False, "Все значения кроме первой ячейки в заголовке должны быть числами"

    if len(data) - 1 != len(data[0]) - 1:
        return False, "Количество строк данных должно совпадать с количеством столбцов заголовка"

    return True, ""

def main():
    print("Программа запущена")
    data = parse_data('data.csv')
    print(data)
    
    is_valid, error_message = validate_data(data)
    if not is_valid:
        print(f"Ошибка данных: {error_message}", file=sys.stderr)
        sys.exit(1)
    
    root = tk.Tk()
    AppWindow(root, data)
    root.mainloop()

if __name__ == "__main__":
    main()
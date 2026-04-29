import re
from window import AppWindow
import tkinter as tk

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

def main():
    print("Программа запущена")
    data = parse_data('data.csv')
    print(data)
    
    if not data:
        print("Нет данных для отображения. ")
        return
    
    root = tk.Tk()
    AppWindow(root, data)
    root.mainloop()

if __name__ == "__main__":
    main()
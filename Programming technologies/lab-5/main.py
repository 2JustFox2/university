# Сапунков Александр Андреевич 18
"""
2. Short
3. Вопросительный
3. Повторить ввод или остановиться
(Yes/No)
1. Нет


XVI. ln(x)/(y – 2) Пx Пy
П – Произвольный (Пх, Пy)

Пример Пх: Заданы все значения хi (i=0.. Nx -1) в возрастающем порядке. (Данные задаются только
пользователем(!), а не программно)
"""

import tkinter as tk
from tkinter import ttk, messagebox
import math
from logger import Logger
from method import Calculate, Calculate

class window:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Сапунков Александр Андреевич 18")
        self.root.geometry("350x550")
        self.style = ttk.Style()
        self.style.configure("TButton")
        self.style.configure("Active.TButton", font=('Arial', 8, 'bold'), foreground='blue')
        self.logger = Logger()
        self.logger.init()
        self.calculate = Calculate()
        
        self.data = {}  # Словарь для хранения данных каждой формы, ключ - номер формы, значение - данные формы
        
        # Canvas для отображения номера формы с горизонтальным скроллом
        self.canvas_form_number = tk.Canvas(self.root, height=20)
        self.canvas_form_number.grid(row=0, column=0, columnspan=3, pady=10, padx=10, sticky="ew")
        
        # Скроллбар для Canvas
        self.scrollbar_form_number = ttk.Scrollbar(self.root, orient=tk.HORIZONTAL, command=self.canvas_form_number.xview)
        self.scrollbar_form_number.grid(row=1, column=0, columnspan=3, sticky="ew", padx=10)
        self.canvas_form_number.config(xscrollcommand=self.scrollbar_form_number.set)
        
        # Фрейм внутри Canvas
        self.frame_form_number = ttk.Frame(self.canvas_form_number)
        self.canvas_form_number.create_window(0, 0, window=self.frame_form_number, anchor="nw")
        
        # Изначально отображаем номер первой формы
        self.current_form_number = 1
        self.active_form = 1
        self.labels_form_number = [ttk.Button(self.frame_form_number, text=self.current_form_number, width=3, command=lambda: self.switch_form(1), takefocus=False, style="Active.TButton")]
        self.labels_form_number[-1].pack(side=tk.LEFT, padx=5)
        # от 3-х
        self.create_form()
        self.create_form()
        
        # Обновляем область прокрутки Canvas
        self.frame_form_number.update_idletasks()
        self.canvas_form_number.config(scrollregion=self.canvas_form_number.bbox("all"))

        # Кнопки для добавления и удаления форм
        self.button_add_data_sets = ttk.Button(text="+", command=self.create_form)
        self.button_add_data_sets.grid(row=2, column=0, pady=10, padx=20)
        self.button_remove_data_sets = ttk.Button(text="-", command=self.remove_form)
        self.button_remove_data_sets.grid(row=2, column=1, pady=10, padx=20)

        # Поля для ввода данных и отображения результатов
        self.label_x = ttk.Label(text="x:")
        self.label_x.grid(row=3, column=0, sticky="w", padx=20)
        self.label_y = ttk.Label(text="y:")
        self.label_y.grid(row=3, column=1, sticky="w", padx=20)
        self.message_box_x = tk.Text(self.root, height=10, width=10)
        self.message_box_x.grid(row=3, column=0, pady=10, padx=20)
        self.message_box_y = tk.Text(self.root, height=10, width=10)
        self.message_box_y.grid(row=3, column=1, pady=10, padx=20)
        
        self.message_box_result = tk.Text(self.root, height=10, width=35)
        self.message_box_result.grid(row=5, column=0, pady=10, padx=20, columnspan=2)

        # Кнопки для расчета, отмены и отображения точек
        self.button_calculation = ttk.Button(text="Расчет", command=lambda: self.calculation())
        self.button_calculation.grid(row=4, column=0, pady=10, padx=20)
        self.button_cancellation = ttk.Button(text="Отмена")
        self.button_cancellation.grid(row=4, column=1, pady=10, padx=20)
    
    def calculation(self):
        try:
            self.save_form_data(self.active_form)
            results = self.calculate(self.data)
            if not results:
                raise ValueError("Не удалось выполнить расчет. Проверьте корректность введенных данных.")
            self.message_box_result.delete("1.0", tk.END)
            
            output_text = ""
            for form_id, result_list in results.items():
                output_text += f"- Форма {form_id} -\n"
                if not result_list:
                    output_text += "Нет данных\n\n"
                    continue
                
                if result_list[0]:
                    output_text += "y\\x"
                    for point in result_list[0]:
                        output_text += f"\t{point['x']:.2g}"
                    output_text += "\n"
                
                for row in result_list[1:]:
                    if row:
                        output_text += f"{row[0]['y']:.2g}"
                        for point in row:
                            # Проверяем, является ли результат NaN
                            if math.isnan(point['f']):
                                output_text += f"\tNaN"
                            else:
                                output_text += f"\t{point['f']:.2g}"
                        output_text += "\n"
                
                output_text += "\n"
            
            self.message_box_result.insert("1.0", output_text)
            self.logger.log(f"Расчет завершен успешно для {len(results)} форм.")
        except Exception as e:
            self.logger.error(f"Ошибка при расчете: {e}")
            self.message_box_result.delete("1.0", tk.END)
            self.message_box_result.insert("1.0", f"Ошибка: {e}")
            self.show_error_dialog(str(e))

    def show_error_dialog(self, error_text):
        answer = messagebox.askyesno(
            "Ошибка",
            f"{error_text}\n\nYes - Повторить ввод\nNo - Остановиться"
        )

        if answer:
            self.message_box_x.focus_set()
        else:
            self.root.destroy()
    
    def save_form_data(self, form_number=None):
        if form_number is None:
            form_number = self.active_form
        x_data = self.message_box_x.get("1.0", tk.END).strip().splitlines()
        y_data = self.message_box_y.get("1.0", tk.END).strip().splitlines()
        self.data[form_number] = {"x": x_data, "y": y_data}
        return self.data[form_number]

    def set_form_data(self, form_number=None):
        if form_number is None:
            form_number = self.active_form
        data = self.data.get(form_number, {"x": [], "y": []})
        self.message_box_x.delete("1.0", tk.END)
        self.message_box_y.delete("1.0", tk.END)
        self.message_box_x.insert("1.0", "\n".join(data["x"]))
        self.message_box_y.insert("1.0", "\n".join(data["y"]))
    
    def update_form_buttons(self):
        for i, button in enumerate(self.labels_form_number, start=1):
            if i == self.active_form:
                button.config(style="Active.TButton") 
            else:
                button.config(style="TButton") 

    def switch_form(self, form_number):
        self.save_form_data(self.active_form)
        self.active_form = form_number
        self.set_form_data(form_number)
        self.update_form_buttons()
        
    def create_form(self):
        self.current_form_number += 1
        form_num = self.current_form_number
        self.labels_form_number.append(ttk.Button(self.frame_form_number, text=form_num, width=3, command=lambda: self.switch_form(form_num), takefocus=False))
        self.labels_form_number[-1].pack(side=tk.LEFT, padx=5)
        # Обновляем область прокрутки
        self.frame_form_number.update_idletasks()
        self.canvas_form_number.config(scrollregion=self.canvas_form_number.bbox("all"))
    

    def remove_form(self):
        if self.current_form_number > 1:
            self.labels_form_number.pop().destroy()
            self.current_form_number -= 1
            # Обновляем область прокрутки
            self.frame_form_number.update_idletasks()
            self.canvas_form_number.config(scrollregion=self.canvas_form_number.bbox("all"))
        
    def mainloop(self):
        self.root.mainloop()


if __name__ == "__main__":
    app = window()
    app.mainloop()
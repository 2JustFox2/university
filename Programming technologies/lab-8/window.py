import tkinter as tk
from tkinter import ttk, messagebox
import pandas as pd
import numpy as np

class AppWindow:
    def __init__(self, root, data):
        self.root = root
        self.root.title("8 Лабораторная работа")
        self.root.geometry("900x900")

        self.tr_values = [float(x) for x in data[0][1:]]
        self.pr_values = [float(data[i][0]) for i in range(1, len(data))]
        print("Tr values:", self.tr_values)
        print("Pr values:", self.pr_values)
        
        self.z0_matrix = np.zeros((len(self.tr_values), len(self.pr_values)))
        for i in range(len(data) - 1):
            self.z0_matrix[i] = [float(x) for x in data[i+1][1:]]

        # Создаём вкладки
        self.notebook = ttk.Notebook(root)
        self.notebook.pack(fill='both', expand=True, padx=5, pady=5)

        # Вкладка 1: Основная (прицел, выбор строки/столбца)
        self.main_tab = ttk.Frame(self.notebook)
        self.notebook.add(self.main_tab, text="Основная")

        # Вкладка 2: Настройки (действия при некорректных значениях)
        self.settings_tab = ttk.Frame(self.notebook)
        self.notebook.add(self.settings_tab, text="Настройки")

        # Вкладка 3: Результаты расчёта Z
        self.results_tab = ttk.Frame(self.notebook)
        self.notebook.add(self.results_tab, text="Результаты")

        # Переменная для выбранного типа сообщения
        self.error_action = tk.StringVar(value="info")

        self.create_main_tab()
        self.create_settings_tab()

    def create_main_tab(self):
        self.row_label_var = tk.StringVar(value="Tr = 0.5")
        self.col_label_var = tk.StringVar(value="Pr = 0.7")

        # Фрейм для матрицы
        matrix_frame = ttk.LabelFrame(self.main_tab, text="Матрица Z0 (5×5)", padding=10)
        matrix_frame.pack(fill='x', padx=10, pady=10)

        # Заголовок строк
        ttk.Label(matrix_frame, text="Tr\\Pr", font=('Arial', 10, 'bold')).grid(row=0, column=0, padx=5, pady=5)
        
        for j, pr in enumerate(self.pr_values):
            ttk.Label(matrix_frame, text=str(pr), font=('Arial', 10, 'bold')).grid(row=0, column=j+1, padx=5, pady=5)
        
        for i, tr in enumerate(self.tr_values):
            ttk.Label(matrix_frame, text=str(tr), font=('Arial', 10, 'bold')).grid(row=i+1, column=0, padx=5, pady=5)
            for j, val in enumerate(self.z0_matrix[i]):
                ttk.Label(matrix_frame, text=str(val), relief='ridge', width=8).grid(row=i+1, column=j+1, padx=2, pady=2)


        target_frame = ttk.LabelFrame(self.main_tab, text="Прицел выбора", padding=10)
        target_frame.pack(fill='x', padx=10, pady=10)

        # Выбор строки
        ttk.Label(target_frame, text="Выбор строки (Tr):").grid(row=0, column=0, padx=5, pady=5, sticky='w')
        self.row_scroll = tk.Scale(target_frame, from_=0, to=4, orient='horizontal', length=300,
                                command=self.update_selection_display, tickinterval=1, resolution=1)
        self.row_scroll.grid(row=0, column=1, padx=5, pady=5)
        ttk.Label(target_frame, textvariable=self.get_row_label()).grid(row=0, column=2, padx=5, pady=5)

        # Выбор столбца
        ttk.Label(target_frame, text="Выбор столбца (Pr):").grid(row=1, column=0, padx=5, pady=5, sticky='w')
        self.col_scroll = tk.Scale(target_frame, from_=0, to=4, orient='horizontal', length=300,
                                command=self.update_selection_display, tickinterval=1, resolution=1)
        self.col_scroll.grid(row=1, column=1, padx=5, pady=5)
        ttk.Label(target_frame, textvariable=self.get_col_label()).grid(row=1, column=2, padx=5, pady=5)

        # Кнопка для расчёта
        ttk.Button(target_frame, text="Выполнить расчёт Z", command=self.calculate_z).grid(row=2, column=0, columnspan=3, pady=15)

        display_frame = ttk.LabelFrame(self.main_tab, text="Выбранные данные из матрицы", padding=10)
        display_frame.pack(fill='both', expand=True, padx=10, pady=10)

        self.listbox = tk.Listbox(display_frame, height=10, width=50)
        self.listbox.pack(side='left', fill='both', expand=True, padx=5, pady=5)

        scrollbar = ttk.Scrollbar(display_frame, orient='vertical', command=self.listbox.yview)
        scrollbar.pack(side='right', fill='y')
        self.listbox.config(yscrollcommand=scrollbar.set)

        # Combobox для w
        omega_frame = ttk.LabelFrame(self.main_tab, text="Фактор ацентричности w", padding=10)
        omega_frame.pack(fill='x', padx=10, pady=10)

        self.omega_combobox = ttk.Combobox(omega_frame, values=[], width=20)
        self.omega_combobox.pack(side='left', padx=5, pady=5)

        # Кнопки для работы с Combobox
        ttk.Button(omega_frame, text="Добавить", command=self.add_omega).pack(side='left', padx=5)
        ttk.Button(omega_frame, text="Удалить", command=self.delete_omega).pack(side='left', padx=5)
        ttk.Button(omega_frame, text="Очистить всё", command=self.clear_omega).pack(side='left', padx=5)

        # Инициализация начальными значениями w
        self.omega_list = ["0.00", "0.10", "0.20", "0.30"]
        self.update_omega_combobox()

    def get_row_label(self):
        return self.row_label_var

    def get_col_label(self):
        return self.col_label_var

    def update_selection_display(self, event=None):
        row_idx = int(self.row_scroll.get())
        col_idx = int(self.col_scroll.get())

        self.row_label_var.set(f"Tr = {self.tr_values[row_idx]}")
        self.col_label_var.set(f"Pr = {self.pr_values[col_idx]}")

        self.listbox.delete(0, tk.END)

        self.listbox.insert(tk.END, f"Выбранная строка (Tr = {self.tr_values[row_idx]}):")
        for j, pr in enumerate(self.pr_values):
            self.listbox.insert(tk.END, f"  Pr={pr}: Z0 = {self.z0_matrix[row_idx][j]}")

        self.listbox.insert(tk.END, f"Выбранный столбец (Pr = {self.pr_values[col_idx]}):")
        for i, tr in enumerate(self.tr_values):
            self.listbox.insert(tk.END, f"  Tr={tr}: Z0 = {self.z0_matrix[i][col_idx]}")

    def add_omega(self):
        new_value = self.omega_combobox.get().strip()
        if new_value and new_value not in self.omega_list:
            try:
                float(new_value)
                self.omega_list.append(new_value)
                self.update_omega_combobox()
            except ValueError:
                self.show_error_message("Некорректное значение", "Введите числовое значение для w")
        else:
            if new_value in self.omega_list:
                self.show_error_message("Дубликат", "Такое значение уже существует")

    def delete_omega(self):
        current = self.omega_combobox.get()
        if current in self.omega_list:
            self.omega_list.remove(current)
            self.update_omega_combobox()

    def clear_omega(self):
        self.omega_list.clear()
        self.update_omega_combobox()

    def update_omega_combobox(self):
        self.omega_combobox['values'] = self.omega_list
        if self.omega_list:
            self.omega_combobox.set(self.omega_list[0])
        else:
            self.omega_combobox.set('')

    def create_settings_tab(self):
        frame = ttk.LabelFrame(self.settings_tab, text="Настройки обработки некорректных значений Z0", padding=20)
        frame.pack(fill='x', padx=20, pady=20)

        ttk.Label(frame, text="Выберите действие при обнаружении некорректных значений Z0:").grid(row=0, column=0, columnspan=3, pady=10, sticky='w')

        ttk.Radiobutton(frame, text="Информационное сообщение", variable=self.error_action, value="info").grid(row=1, column=0, sticky='w', padx=20, pady=5)
        ttk.Radiobutton(frame, text="Критическое сообщение (ошибка)", variable=self.error_action, value="error").grid(row=2, column=0, sticky='w', padx=20, pady=5)
        ttk.Radiobutton(frame, text="Восклицание (предупреждение)", variable=self.error_action, value="warning").grid(row=3, column=0, sticky='w', padx=20, pady=5)

    def show_error_message(self, title, message, action_type=None):
        if action_type is None:
            action_type = self.error_action.get()

        if action_type == "info":
            messagebox.showinfo(title, message)
        elif action_type == "error":
            messagebox.showerror(title, message)
        elif action_type == "warning":
            messagebox.showwarning(title, message)

    def is_valid_z0(self, value):
        # [0.5, 1.5]
        return 0.5 <= value <= 1.5

    def calculate_z(self):
        row_idx = int(self.row_scroll.get())
        col_idx = int(self.col_scroll.get())

        tr = self.tr_values[row_idx]
        pr = self.pr_values[col_idx]

        z0_value = self.z0_matrix[row_idx][col_idx]

        # Проверка корректности Z0
        if not self.is_valid_z0(z0_value):
            self.show_error_message("Некорректное значение Z0",
                                    f"Значение Z0 = {z0_value} для Tr={tr}, Pr={pr} выходит за допустимые пределы [0.5, 1.5]")
            return

        # Получение w из Combobox
        try:
            omega = float(self.omega_combobox.get())
        except (ValueError, tk.TclError):
            self.show_error_message("Ошибка", "Выберите или введите корректное значение w")
            return

        # Проверка условий для расчёта Z1
        if tr > 0.6 and pr < 1.0:
            z1 = z0_value - 1
            z = z0_value + omega * z1
            self.show_results(z, tr, pr, omega, z0_value, z1, "успешно")
        else:
            self.show_results(None, tr, pr, omega, z0_value, None, f"Расчёт не производится (условие: Tr>0.6 и Pr<1.0)\nТекущие: Tr={tr}, Pr={pr}")

    def show_results(self, z, tr, pr, omega, z0, z1, status_message):
        # Очищаем предыдущие результаты
        for widget in self.results_tab.winfo_children():
            widget.destroy()

        frame = ttk.Frame(self.results_tab, padding=20)
        frame.pack(fill='both', expand=True)

        # Заголовок
        ttk.Label(frame, text="Результаты расчёта Z-фактора", font=('Arial', 14, 'bold')).pack(pady=10)

        # Информация о входных параметрах
        info_frame = ttk.LabelFrame(frame, text="Исходные данные", padding=10)
        info_frame.pack(fill='x', pady=10)

        ttk.Label(info_frame, text=f"Приведённая температура (Tr): {tr}").pack(anchor='w')
        ttk.Label(info_frame, text=f"Приведённое давление (Pr): {pr}").pack(anchor='w')
        ttk.Label(info_frame, text=f"Фактор ацентричности (w): {omega}").pack(anchor='w')
        ttk.Label(info_frame, text=f"Z0 (из матрицы): {z0}").pack(anchor='w')

        # Результат
        result_frame = ttk.LabelFrame(frame, text="Результат расчёта", padding=10)
        result_frame.pack(fill='x', pady=10)

        if z is not None:
            ttk.Label(result_frame, text=f"Z1 = Z0 - 1 = {z1:.4f}", font=('Arial', 10)).pack(anchor='w')
            ttk.Label(result_frame, text=f"Z = Z0 + w·Z1 = {z:.4f}", font=('Arial', 12, 'bold')).pack(anchor='w', pady=5)
        else:
            ttk.Label(result_frame, text=status_message, font=('Arial', 10, 'bold'), foreground='red').pack(anchor='w', pady=5)

        calc_frame = ttk.LabelFrame(frame, text="Матрица рассчитанных значений Z (для всех комбинаций)", padding=10)
        calc_frame.pack(fill='both', expand=True, pady=10)

        columns = ['Tr/Pr'] + [str(pr) for pr in self.pr_values]
        tree = ttk.Treeview(calc_frame, columns=columns, show='headings', height=8)

        tree.heading('Tr/Pr', text='Tr \\ Pr')
        tree.column('Tr/Pr', width=80, anchor='center')

        for j, pr in enumerate(self.pr_values):
            tree.heading(str(pr), text=str(pr))
            tree.column(str(pr), width=80, anchor='center')

        # Заполнение данными
        for i, tr in enumerate(self.tr_values):
            row_data = [str(tr)]
            for j, pr in enumerate(self.pr_values):
                z0_val = self.z0_matrix[i][j]
                if self.is_valid_z0(z0_val) and tr > 0.6 and pr < 1.0:
                    try:
                        omega_val = float(self.omega_combobox.get()) if self.omega_combobox.get() else 0.0
                        z1_calc = z0_val - 1
                        z_calc = z0_val + omega_val * z1_calc
                        row_data.append(f"{z_calc:.4f}")
                    except:
                        row_data.append("Null")
                else:
                    row_data.append(f"Null")
            tree.insert('', 'end', values=row_data)

        scrollbar_y = ttk.Scrollbar(calc_frame, orient='vertical', command=tree.yview)
        scrollbar_x = ttk.Scrollbar(calc_frame, orient='horizontal', command=tree.xview)
        tree.configure(yscrollcommand=scrollbar_y.set, xscrollcommand=scrollbar_x.set)

        tree.grid(row=0, column=0, sticky='nsew')
        scrollbar_y.grid(row=0, column=1, sticky='ns')
        scrollbar_x.grid(row=1, column=0, sticky='ew')

        calc_frame.grid_rowconfigure(0, weight=1)
        calc_frame.grid_columnconfigure(0, weight=1)

        # Переключаемся на вкладку результатов
        self.notebook.select(self.results_tab)
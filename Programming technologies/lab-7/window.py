import tkinter as tk
from tkinter import Variable, ttk, messagebox, filedialog as fd
import re

from method import check

class AppWindow:
    def __init__(self, root, data):
        self.root = root
        self.root.title("Лабораторная работа №7 - Сапунков Александр Андреевич 20")
        self.root.geometry("500x220")
        
        # Список и выбор всех веществ
        data_var = tk.StringVar(value=data)
        self.substences_frame = ttk.Frame(self.root)
        self.substences_frame.grid(row=0, column=0, padx=10, pady=10)
        self.substences_label = ttk.Label(self.substences_frame, text="Вещества:")
        self.substences_label.pack(anchor="w")
        self.substences_list_box = tk.Listbox(self.substences_frame, listvariable=data_var, height=10, width=20)
        self.substences_list_box.pack(pady=10)
        
        # Выбор кооэффициента, добавление и удаление веществ
        self.buttons_frame = ttk.Frame(self.root)
        self.buttons_frame.grid(row=0, column=1, ipady=40)
        self.spinner_label = ttk.Label(self.buttons_frame, text="Коэффициент:")
        self.spinner_label.grid(row=0, column=0, sticky="w")
        self.spinner = ttk.Spinbox(self.buttons_frame, from_=1, to=10, width=5, increment=1)
        self.spinner.grid(row=1, column=0, pady=5, sticky="w")

        self.starting_buttons_row = ttk.Frame(self.buttons_frame)
        self.starting_buttons_row.grid(row=2, column=0, pady=5, sticky="w")
        
        self.starting_add_button = ttk.Button(self.starting_buttons_row, text="+", command=lambda: self.add_substance(self.starting_materials), width=3)
        self.starting_add_button.pack(side="left", padx=(0, 2))
        self.starting_decrease_button = ttk.Button(self.starting_buttons_row, text="-", command=lambda: self.decrease_substance(self.starting_materials), width=3)
        self.starting_decrease_button.pack(side="left", padx=2)
        self.starting_remove_button = ttk.Button(self.starting_buttons_row, text="X", command=lambda: self.remove_substance(self.starting_materials), width=3)
        self.starting_remove_button.pack(side="left", padx=(2, 0))
        
        self.result_buttons_row = ttk.Frame(self.buttons_frame)
        self.result_buttons_row.grid(row=3, column=0, pady=15, sticky="w")
        
        self.result_add_button = ttk.Button(self.result_buttons_row, text="+", command=lambda: self.add_substance(self.result_list_materials), width=3)
        self.result_add_button.pack(side="left", padx=(0, 2))
        self.result_decrease_button = ttk.Button(self.result_buttons_row, text="-", command=lambda: self.decrease_substance(self.result_list_materials), width=3)
        self.result_decrease_button.pack(side="left", padx=2)
        self.result_remove_button = ttk.Button(self.result_buttons_row, text="X", command=lambda: self.remove_substance(self.result_list_materials), width=3)
        self.result_remove_button.pack(side="left", padx=(2, 0))
        
        # Исходные и Конечные вещества
        self.result_frame = ttk.Frame(self.root)
        self.result_frame.grid(row=0, column=3, columnspan=2, padx=10)
        self.starting_label = ttk.Label(self.result_frame, text="Исходные вещества:")
        self.starting_label.grid(row=0, column=0, sticky="w")
        self.starting_materials = tk.Entry(self.result_frame, width=35)
        self.starting_materials.grid(row=1, column=0, pady=5)
        self.result_label = ttk.Label(self.result_frame, text="Конечные вещества:")
        self.result_label.grid(row=2, column=0, sticky="w")
        self.result_list_materials = tk.Entry(self.result_frame, width=35)
        self.result_list_materials.grid(row=3, column=0, pady=5)

        self.starting_materials.bind("<KeyRelease>", self._update_check_button_state)
        self.result_list_materials.bind("<KeyRelease>", self._update_check_button_state)
        self.starting_materials.bind("<FocusOut>", self._update_check_button_state)
        self.result_list_materials.bind("<FocusOut>", self._update_check_button_state)
        
        self.buttons_frame = ttk.Frame(self.result_frame)
        self.buttons_frame.grid(row=4, column=0, pady=10)
        self.button_load = ttk.Button(self.buttons_frame, text="Загрузить", command=self.load_data)
        self.button_load.grid(row=0, column=1, pady=10)
        self.button_check = ttk.Button(self.buttons_frame, text="Проверить", command=self.check_result)
        self.button_check.grid(row=0, column=2, pady=5)
        self.button_cancel = ttk.Button(self.buttons_frame, text="Отмена", command=self.cancel)
        self.button_cancel.grid(row=0, column=3, pady=5)

        self._update_check_button_state()
        
    def load_data(self):
        file_path = fd.askopenfilename(title="Выберите файл с веществами", filetypes=[("Text files", "*.sbt"), ("All files", "*.*")])
        
        if file_path:
            try:
                with open(file_path, "r") as file:
                    lines = file.readlines()
                    self.substences_list_box.delete(0, tk.END)
                    for line in lines:
                        substance = line.strip().replace(",", "")
                        if substance:
                            self.substences_list_box.insert(tk.END, substance)
            except Exception as e:
                messagebox.showerror("Загрузка данных", f"Ошибка при загрузке файла: {str(e)}")
    
    def check_result(self):
        starting_materials = self.starting_materials.get().strip(' + ')
        result_materials = self.result_list_materials.get().strip(' + ')

        if not self._is_check_input_valid():
            messagebox.showwarning("Проверка", "Заполните оба поля корректными формулами веществ.")
            return
    
        try:
            if check(starting_materials, result_materials):
                messagebox.showinfo("Проверка", "Уравнение сбалансировано.")
            else:
                messagebox.showwarning("Проверка", "Уравнение не сбалансировано.")
        except Exception as e:
            messagebox.showerror("Проверка", f"Ошибка при проверке уравнения: {str(e)}")

    
    def cancel(self):
        self.starting_materials.delete(0, tk.END)
        self.result_list_materials.delete(0, tk.END)
        self._update_check_button_state()
    
    def add_substance(self, target_entry):
        selected_substance = self._get_selected_substance()
        if selected_substance is None:
            return

        coefficient = self._get_coefficient()
        if coefficient is None:
            return

        chemicals = self._get_entry_parts(target_entry)
        chemicals.append(self._format_substance(selected_substance, coefficient))
        self._set_entry_parts(target_entry, chemicals)
        self._update_check_button_state()
    
    def decrease_substance(self, target_entry):
        selected_substance = self._get_selected_substance()
        if selected_substance is None:
            return

        coefficient = self._get_coefficient()
        if coefficient is None:
            return

        chemicals = self._get_entry_parts(target_entry)
        target_chemical = self._format_substance(selected_substance, coefficient)
        if target_chemical not in chemicals:
            messagebox.showwarning("Уменьшение вещества", f"Вещество {target_chemical} не найдено в списке.")
            return
        chemicals.remove(target_chemical)
        self._set_entry_parts(target_entry, chemicals)
        self._update_check_button_state()
    
    def remove_substance(self, target_entry):
        target_entry.delete(0, tk.END)
        self._update_check_button_state()

    def _get_selected_substance(self):
        selected = self.substences_list_box.curselection()
        if not selected:
            messagebox.showwarning("Выбор вещества", "Сначала выберите вещество в списке слева.")
            return None
        return self.substences_list_box.get(selected[0])

    def _get_coefficient(self):
        raw_value = self.spinner.get().strip()
        try:
            value = int(raw_value)
        except ValueError:
            messagebox.showerror("Коэффициент", "Коэффициент должен быть целым числом.")
            return None

        if value < 1:
            messagebox.showerror("Коэффициент", "Коэффициент должен быть не меньше 1.")
            return None
        return value

    def _get_entry_parts(self, entry):
        raw = entry.get().strip()
        if not raw:
            return []
        return [part.strip() for part in raw.split("+") if part.strip()]

    def _set_entry_parts(self, entry, parts):
        entry.delete(0, tk.END)
        entry.insert(0, " + ".join(parts))

    def _format_substance(self, substance, coefficient):
        if coefficient == 1:
            return substance
        return f"{coefficient}{substance}"

    def _is_check_input_valid(self):
        left_parts = self._get_entry_parts(self.starting_materials)
        right_parts = self._get_entry_parts(self.result_list_materials)

        if not left_parts or not right_parts:
            return False

        return all(self._is_valid_substance_token(token) for token in left_parts + right_parts)

    def _is_valid_substance_token(self, token):
        if not re.fullmatch(r"\d*[A-Z][A-Za-z0-9()]*", token):
            return False

        balance = 0
        for ch in token:
            if ch == "(":
                balance += 1
            elif ch == ")":
                balance -= 1
                if balance < 0:
                    return False
        return balance == 0

    def _update_check_button_state(self, event=None):
        if self._is_check_input_valid():
            self.button_check.config(state="normal")
        else:
            self.button_check.config(state="disabled")
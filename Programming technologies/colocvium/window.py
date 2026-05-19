import tkinter as tk
from tkinter import ttk
from tkinter import messagebox
from tkinter import filedialog

class MainWindow:
    def __init__(self, root):
        self.root = root
        self.root.title("Tkinter Application")
        self.root.geometry("650x280")
        self.patches = []
        self.data = [
            ("1", "Иван Иванов", "Разработчик"),
            ("2", "Анна Петрова", "Дизайнер"),
            ("3", "Петр Сидоров", "Тестировщик"),
            ("4", "Анна Петрова", "Дизайнер"),
            ("5", "Петр Сидоров", "Тестировщик"),
            ("6", "Анна Петрова", "Дизайнер"),
            ("7", "Петр Сидоров", "Тестировщик")
        ]
        
        self.create_widgets()
    
    def create_widgets(self):
        style = ttk.Style()
        style.theme_use('clam')
        
        self.treeview_6 = ttk.Notebook(self.root)
        self.treeview_6.place(x=24, y=24)
        
        # 1-ый фрейм
        self.calculate_widget()
        
        # 2-ой фрейм
        self.file_widget()
    
    def calculate_widget(self):
        self.calculation_frame = ttk.Frame(self.treeview_6, width=500, height=200)
        self.treeview_6.add(self.calculation_frame, text="Расчет")
        
        self.spinbox = ttk.Spinbox(self.calculation_frame, from_=0, to=100)
        self.spinbox.place(x=24, y=24, width=50, height=30)
        self.spinbox.set(0)
        
        self.label = ttk.Label(self.calculation_frame, text="Предельная размерность матрицы")
        self.label.place(x=24+50+8, y=24)

        self.patch = ttk.Entry(self.calculation_frame)
        self.patch.place(x=24, y=24+30, width=300, height=30)

        self.review = ttk.Button(self.calculation_frame, text="Обзор", command=self.browse_file)
        self.review.place(x=350, y=24+30, width=100, height=30)

        self.calculation_button = ttk.Button(self.calculation_frame, text="Расчет", command=self.calculation)
        self.calculation_button.place(x=350, y=24+30+30+24, width=100, height=30)

        self.button_cancel = ttk.Button(self.root, text="Отмена", command=self.cancel)
        self.button_cancel.place(x=540, y=223, width=100, height=30)
    
    def file_widget(self):
        self.file_frame = ttk.Frame(self.treeview_6, width=500, height=200)
        self.treeview_6.add(self.file_frame, text="Из файла")
        
        self.combobox = ttk.Combobox(self.file_frame, values=self.patches)
        self.combobox.place(x=24, y=24, width=300, height=30)
        
        self.review = ttk.Button(self.file_frame, text="Обзор", command=self.browse_file)
        self.review.place(x=350, y=24, width=100, height=30)

        self.find_button = ttk.Button(self.file_frame, text="Считать", command=self.calculation)
        self.find_button.place(x=350, y=24+30+24, width=100, height=30)
        
        columns = ("id", "name", "role")
        self.tree_view = ttk.Treeview(self.file_frame, columns=columns, show="headings")
        self.tree_view.place(x=24, y=24+30+8, width=300, height=100)
        scrollbar = ttk.Scrollbar(self.file_frame, orient=tk.VERTICAL, command=self.tree_view.yview)
        self.tree_view.configure(yscrollcommand=scrollbar.set)
        scrollbar.place(x=300+24, y=24+30+8, height=100)

        for col in columns:
            self.tree_view.heading(col, text=col.capitalize())
            self.tree_view.column(col, width=100)
        
        for row in self.data:
            self.tree_view.insert("", tk.END, values=row)


    def browse_file(self):
        file_path = filedialog.askopenfilename(
            title="Выберите файл для обзора",
            filetypes=(("Текстовые файлы", "*.txt"), ("Все файлы", "*.*"))
        )
        
        if file_path:
            self.patch.delete(0, tk.END)
            self.patch.insert(0, file_path)
            self.patches.append(file_path)
            self.combobox['values'] = self.patches

    def calculation(self):
        messagebox.showinfo("Button Clicked", "You clicked the button_2 button!")
        
    def cancel(self):
        self.root.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = MainWindow(root)
    root.mainloop()

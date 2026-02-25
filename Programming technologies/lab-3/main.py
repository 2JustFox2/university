import math
import tkinter as tk
from tkinter import ttk, messagebox

# 4 Вариант
# ln(1-x)   sh(-3/x)    ln(sin(1/(1-x)))    do...while

accuracy = 1e-6

def calculate(x0):
    if x0 >= 1:
        raise ValueError(f"x должен быть < 1, получено x={x0}")
    if x0 == 0:
        raise ValueError("x не может быть равен 0")
    
    def f1(x):
        try:
            return math.log(1-x)
        except Exception as e:
            raise ValueError(f"Ошибка при вычислении f1: {e}")

    def f2(x):
        try:
            return math.sinh(-3/x)
        except Exception as e:
            raise ValueError(f"Ошибка при вычислении f2: {e}")

    def f4(x):
        try:
            summ = 0
            for i in range(1, 1000001):
                term = 1 / (x + math.sqrt(i))
                summ += term
                if abs(term) < accuracy:
                    break
            return summ
        except Exception as e:
            raise ValueError(f"Ошибка при вычислении f4: {e}")

    # f3(x) = log(1/(1-x)) = -log(1-x) = -f1(x)
    f1_val = f1(x0)
    f2_val = f2(x0)
    f3_val = -f1_val
    f4_val = f4(x0)

    return f1_val + f2_val + f3_val + f4_val


def widget(master):
    master.title('My App')
    master.geometry('480x360')
    master.resizable(False, False)
    header = ttk.Label(master, text="Вычисление функции F(x) = F1(x) + F2(x) + F3(x) + F4(x)", font=("Segoe UI", 10, "bold"))
    header.pack(pady=(15, 5))
    main_frame = ttk.Frame(master, padding="15 10")
    main_frame.pack(fill="both", expand=True)
    ttk.Label(main_frame, text="x начальное:").grid(row=0, column=0, sticky="w", pady=5)
    x0_var = tk.DoubleVar(value=-1400.5)
    ttk.Entry(main_frame, textvariable=x0_var, width=10).grid(row=0, column=1, sticky="w", padx=10)
    ttk.Label(main_frame, text="x конечное:").grid(row=1, column=0, sticky="w", pady=5)
    x1_var = tk.DoubleVar(value=-100.5)
    ttk.Entry(main_frame, textvariable=x1_var, width=10).grid(row=1, column=1, sticky="w", padx=10)
    
    text_widget = tk.Text(main_frame, height=12, width=60, font=("Consolas", 10), wrap=tk.WORD)
    text_widget.grid(row=3, column=0, columnspan=2, pady=15)

    scrollbar = ttk.Scrollbar(main_frame, orient=tk.VERTICAL)
    scrollbar.grid(row=3, column=2, sticky="ns")
    text_widget.config(yscrollcommand=scrollbar.set)
    scrollbar.config(command=text_widget.yview)
    
    def on_calculate():
        try:
            x0 = x0_var.get()
            x1 = x1_var.get()
            
            # Проверка на минимальное количество значений (1000)
            num_values = len(range(int(x0), int(x1) + 1))
            
            if x0 > x1:
                messagebox.showerror("Ошибка", "Начальное значение x должно быть меньше или равно конечному.")
                return
            elif num_values < 1000:
                messagebox.showerror("Ошибка", f"Количество значений x должно быть не менее 1000. Получено: {num_values}")
                return
            
            result = []
            errors = []
            
            # Оптимизированный перебор значений
            x = x0
            while True:
                try:
                    value = calculate(x)
                    result.append({f"x={x}: {value}"})
                except Exception as e:
                    result.append({f"x={x}": f"Ошибка: {e}"})
                    errors.append((x, str(e)))
                x += 1
                if x > x1:
                    break
            
            text_widget.delete(1.0, tk.END)
            for item in result:
                text_widget.insert(tk.END, f"{item}\n")
            
            if errors:
                error_msg = "Обнаружены ошибки при вычислении функции:\n\n"
                for x, err in errors[:10]:
                    error_msg += f"x={x}: {err}\n"
                if len(errors) > 10:
                    error_msg += f"\n... и еще {len(errors) - 10} ошибок"
                messagebox.showwarning("Предупреждение", error_msg)
        except Exception as e:
            messagebox.showerror("Ошибка", f"Ошибка при вычислении: {e}")
    
    ttk.Button(main_frame, text="Вычислить", command=on_calculate).grid(row=2, column=0, columnspan=2, pady=15)


def main():
    root = tk.Tk()
    widget(root)
    root.mainloop()

if __name__ == '__main__':
    main()
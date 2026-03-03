import math
import tkinter as tk
from tkinter import ttk, messagebox
from multiprocessing import Pool, cpu_count
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor
import os

# 4 Вариант
# ln(1-x)   sh(-3/x)    ln(sin(1/(1-x)))    do...while

def compute_f4_sequential(x):
    try:
        max_i = 1000000
        total_sum = 0
        i = 1
        while i <= max_i:
            term = 1 / (x + math.sqrt(i))
            total_sum += term
            i += 1
        return total_sum
    except Exception as e:
        raise ValueError(f"Ошибка при вычислении f4: {e}")

def calculate_single_x(x):
    try:
        if x >= 1:
            raise ValueError(f"x должен быть < 1, получено x={x}")
        if x == 0:
            raise ValueError("x не может быть равен 0")
        
        f1_val = math.log(1-x)
        f2_val = math.sinh(-3/x)
        f3_val = -f1_val
        f4_val = compute_f4_sequential(x)
        
        return f"x={x}: {f1_val + f2_val + f3_val + f4_val}"
    except Exception as e:
        return f"x={x}: Ошибка: {e}"

def calculate_parallel(x_values):
    with Pool(processes=cpu_count()) as pool:
        results = pool.map(calculate_single_x, x_values)
    return results

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
        x0 = x0_var.get()
        x1 = x1_var.get()
        
        x_values = []
        current_x = x0
        while current_x <= x1:
            x_values.append(current_x)
            current_x += 1.0 
        
        num_values = len(x_values)
        
        if x0 > x1:
            messagebox.showerror("Ошибка", "Начальное значение x должно быть меньше или равно конечному.")
            return
        elif num_values < 1000:
            messagebox.showerror("Ошибка", f"Количество значений x должно быть не менее 1000. Получено: {num_values}")
            return
        
        calculate_btn.config(state="disabled")
        text_widget.delete(1.0, tk.END)
        text_widget.insert(tk.END, "Вычисление... Пожалуйста, подождите.\n")
        master.update()
        
        try:
            results = calculate_parallel(x_values)
            
            text_widget.delete(1.0, tk.END)
            for item in results:
                text_widget.insert(tk.END, f"{item}\n")
            
            errors = [(i, item.split(": Ошибка: ")[1]) for i, item in enumerate(results) if "Ошибка" in item]
            if errors:
                error_msg = "Обнаружены ошибки при вычислении функции:\n\n"
                for idx, err in errors[:10]:
                    error_msg += f"x={x_values[idx]}: {err}\n"
                if len(errors) > 10:
                    error_msg += f"\n... и еще {len(errors) - 10} ошибок"
                messagebox.showwarning("Предупреждение", error_msg)
                
        except Exception as e:
            messagebox.showerror("Ошибка", f"Произошла ошибка при вычислениях: {e}")
        finally:
            calculate_btn.config(state="normal")
    
    calculate_btn = ttk.Button(main_frame, text="Вычислить", command=on_calculate)
    calculate_btn.grid(row=2, column=0, columnspan=2, pady=15)


def main():
    root = tk.Tk()
    widget(root)
    root.mainloop()

if __name__ == '__main__':
    main()
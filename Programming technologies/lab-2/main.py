import tkinter as tk
from tkinter import ttk, messagebox

PROGRAM_NAME = "Расчёт критической температуры смеси газов"
VERSION = "1.0.1"
LAST_UPDATE = "25 февраля 2026 г."

CRITICAL_TEMPERATURES = {
    "CO":   132.9,
    "CO2":  304.2,
    "CH4":  190.6
}

# Пары, для которых требуется проверка условия 0.5 < Tc_i / Tc_j < 2
BINARY_PAIRS_TO_CHECK = [
    ("CO", "CO2"),
    ("CO", "CH4"),
    ("CO2", "CH4")
]


class PseudoCriticalTempCalculator:
    def __init__(self, master):
        self.master = master
        master.title(PROGRAM_NAME)
        master.geometry("480x480")
        master.resizable(False, False)

        self.create_widgets()
        self.show_header_info()

    def create_widgets(self):
        header = ttk.Label(self.master, text=PROGRAM_NAME, font=("Segoe UI", 14, "bold"))
        header.pack(pady=(15, 5))

        ver = f"вер. {VERSION} - {LAST_UPDATE}"
        ttk.Label(self.master, text=ver, font=("Segoe UI", 9)).pack()

        main_frame = ttk.Frame(self.master, padding="15 10")
        main_frame.pack(fill=tk.BOTH, expand=True)

        ttk.Label(main_frame, text="Первый компонент:", font=("Segoe UI", 10)).grid(row=0, column=0, sticky="e", pady=6, padx=(0,8))
        self.comp1_var = tk.StringVar(value="CO")
        comp1_combo = ttk.Combobox(main_frame, textvariable=self.comp1_var, 
        values=list(CRITICAL_TEMPERATURES.keys()), state="readonly", width=12)
        comp1_combo.grid(row=0, column=1, sticky="w")

        ttk.Label(main_frame, text="Второй компонент:", font=("Segoe UI", 10)).grid(row=1, column=0, sticky="e", pady=6, padx=(0,8))
        self.comp2_var = tk.StringVar(value="CO2")
        comp2_combo = ttk.Combobox(main_frame, textvariable=self.comp2_var, 
        values=list(CRITICAL_TEMPERATURES.keys()), state="readonly", width=12)
        comp2_combo.grid(row=1, column=1, sticky="w")

        ttk.Label(main_frame, text="y (мольная доля первого):", font=("Segoe UI", 10)).grid(row=2, column=0, sticky="e", pady=6, padx=(0,8))
        self.y1_var = tk.DoubleVar(value=0.3)
        ttk.Entry(main_frame, textvariable=self.y1_var, width=10).grid(row=2, column=1, sticky="w")

        calc_btn = ttk.Button(main_frame, text="Рассчитать", command=self.calculate, width=20)
        calc_btn.grid(row=3, column=0, columnspan=2, pady=(20,10))

        self.result_text = tk.Text(main_frame, height=12, width=60, font=("Consolas", 10), wrap=tk.WORD)
        self.result_text.grid(row=4, column=0, columnspan=2, pady=(10,0))
        self.result_text.config(state="disabled")

    def show_header_info(self):
        txt = f"Программа: {PROGRAM_NAME}\n\n"
        txt += f"Метод: линейное правило смешения Кея\n"
        txt += f"Tc_m = y_i·Tc_i + y_j·Tc_j\n"
        txt += f"Доступные вещества и их Tc (K):\n"
        
        for name, tc in CRITICAL_TEMPERATURES.items():
            txt += f"{name} : {tc} K\n"

        self.result_text.config(state="normal")
        self.result_text.insert(tk.END, txt)
        self.result_text.config(state="disabled")

    def calculate(self):
        try:
            comp1 = self.comp1_var.get()
            comp2 = self.comp2_var.get()
            y1 = self.y1_var.get()

            if comp1 == comp2:
                raise ValueError("Выбраны одинаковые компоненты")

            if not 0 <= y1 <= 1:
                raise ValueError("Мольная доля должна быть в интервале [0, 1]")

            y2 = 1.0 - y1

            Tc1 = CRITICAL_TEMPERATURES[comp1]
            Tc2 = CRITICAL_TEMPERATURES[comp2]

            Tc_mix = y1 * Tc1 + y2 * Tc2

            ratio = max(Tc1, Tc2) / min(Tc1, Tc2)
            condition_ok = 0.5 < ratio < 2.0

            result = PROGRAM_NAME
            result += f"\nКомпоненты: {comp1}  +  {comp2}\n"
            result += f"Tc({comp1}) = {Tc1} K\n"
            result += f"Tc({comp2}) = {Tc2} K\n"
            result += f"y({comp1})  = {y1}\n"
            result += f"y({comp2})  = {y2}\n"
            result += f"Tc смеси = {Tc_mix:6.3f} K\n\n"
            result += f"Отношение Tc_max / Tc_min = {ratio:6.3f}\n"
            if condition_ok:
                result += "Условие 0.5 < Tc_i / Tc_j < 2 ВЫПОЛНЯЕТСЯ\n"
            else:
                result += "Условие 0.5 < Tc_i / Tc_j < 2 НЕ ВЫПОЛНЯЕТСЯ\n"

            self.result_text.config(state="normal")
            self.result_text.delete("1.0", tk.END)
            self.result_text.insert(tk.END, result)
            self.result_text.config(state="disabled")

        except ValueError as e:
            messagebox.showwarning("Ошибка ввода", str(e))
        except Exception as e:
            messagebox.showerror("Ошибка", f"Произошла ошибка:\n{str(e)}")


def main():
    root = tk.Tk()
    PseudoCriticalTempCalculator(root)
    root.mainloop()


if __name__ == "__main__":
    main()
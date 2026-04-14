# Сапунков Александр Андреевич  вариант 20
import tkinter as tk
from window import AppWindow


class MainApp:
    def __init__(self, root):
        self.root = root
        self.window = AppWindow(self.root, data=["H2", "O2", "H2O", "Ca(OH)2", "SO3", "CaSO4"])
        

if __name__ == "__main__":
    root = tk.Tk()
    app = MainApp(root)
    root.mainloop()
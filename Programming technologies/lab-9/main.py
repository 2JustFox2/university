import re
from window import AppWindow
import tkinter as tk
import sys

"""
    18 вариант
    1,5,3,6
"""
    

class Main():
    def __init__(self):
        print("Программа запущена")
        root = tk.Tk()
        AppWindow(root)
        root.mainloop()
    

if __name__ == "__main__":
    main = Main
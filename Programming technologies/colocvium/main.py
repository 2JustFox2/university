import tkinter as tk
from tkinter import StringVar, ttk

class MainWindow:
    def __init__(self, root):
        self.root = root
        self.root.title("Tkinter Application")
        self.root.geometry("412x468")
        # Массив в который я помещаю все вкладки в результате
        self.widgets = []
        self.selected = 1
        self.max_widgets = 20
        self.hide = "Скрыть"
        self.display = "Отобразить"
        self.restriction = StringVar(value=self.display)
        self.create_display()
    
    def create_display(self):
        style = ttk.Style()
        style.theme_use('clam')
        
        self.main_notebook = ttk.Notebook(self.root)
        self.main_notebook.place(x=24, y=24)
        
        # 1-ый фрейм
        self.choise_widget()
        
        # 2-ой фрейм
        self.do_widget()
        
        # 3-ой фрейм
        self.result_widget()
        
        
        self.button_for_all_widget = ttk.Button(text="Выполнить для всех вкладок", command=self.do_for_all_widget)
        self.button_for_all_widget.place(x=24, y=424)
        
        self.button_for_all_widget = ttk.Button(text="Ок", command=self.fine)
        self.button_for_all_widget.place(x=212, y=424)
        
        self.button_for_all_widget = ttk.Button(text="Отмена", command=self.cancel)
        self.button_for_all_widget.place(x=304, y=424)
        
    def choise_widget(self):
        self.do_fram = ttk.Frame(self.main_notebook, width=360, height=360)
        self.main_notebook.add(self.do_fram, text="Выбор")
        
        self.spinbox = ttk.Spinbox(self.do_fram, from_=1, to=self.max_widgets, command=self.fill_widgets)
        self.spinbox.place(x=24, y=24, width=100, height=30)
        self.spinbox.set(self.max_widgets)
        
        all_widget = ttk.Label(self.do_fram, text="Всего вкладок")
        all_widget.place(x=24+100+12, y=24)
    
        
        start_label = ttk.Label(self.do_fram, text="1")
        start_label.place(x=24, y=30+48)
        
        self.final_label = ttk.Label(self.do_fram, text=self.max_widgets)
        self.final_label.place(x=309, y=30+48)
        
        self.scale = ttk.Scale(self.do_fram, from_=1, to=self.max_widgets, orient='horizontal', value=1, command=self.change_scale)
        self.scale.place(x=24, y=30+64, width=300, height=45)
        
        self.value_scale = ttk.Label(self.do_fram, text=1)
        self.value_scale.place(x=24, y=96+45+12)

        from_to_label = ttk.Label(self.do_fram, text=f"От 1 до {self.max_widgets} вкладок")
        from_to_label.place(x=24+24, y=96+45+12)
        
    
    def change_scale(self, val):
        self.selected = round(float(val))
        self.value_scale["text"] = self.selected
        self.on_tab_selected()
    
    def do_widget(self):
        self.do_frame = ttk.Frame(self.main_notebook, width=360, height=360)
        self.main_notebook.add(self.do_frame, text="Действия")
        
        label = ttk.Label(self.do_frame, text="Ограничения")
        label.place(x=24, y=24)
        
        hide_btn = ttk.Radiobutton(self.do_frame, text=self.hide, value=self.hide, variable=self.restriction, command=self.on_restriction_changed)
        hide_btn.place(x=24, y=48)
        
        display_btn = ttk.Radiobutton(self.do_frame, text=self.display, value=self.display, variable=self.restriction, command=self.on_restriction_changed)
        display_btn.place(x=24, y=66)
    
    
    def result_widget(self):
        self.result_frame = ttk.Frame(self.main_notebook, width=360, height=360)
        self.main_notebook.add(self.result_frame, text="Результат")
        
        self.widgets_notebook = ttk.Notebook(self.result_frame)
        self.widgets_notebook.place(x=24, y=24, width=300, height=300)
        
        # Создание виджетов в результате
        self.fill_widgets()
    
    def fill_widgets(self):
        count = int(self.spinbox.get())
        self.max_widgets = count
        self.scale["to"] = self.max_widgets
        self.final_label["text"] = self.max_widgets
        
        while len(self.widgets) < count:
            frame = ttk.Frame(self.widgets_notebook, width=300, height=260)
            frame.pack_propagate(False)
            self.widgets.append({
                "i": len(self.widgets),
                "frame": frame,
                "restriction": self.display,
            })
            self.widgets[-1]["label"] = ttk.Label(self.widgets[-1]["frame"], text=f"Виджет {self.widgets[-1]['i']+1}")
            self.widgets[-1]["entry"] = ttk.Entry(self.widgets[-1]["frame"])

        while len(self.widgets) > count:
            widget = self.widgets.pop()
            frame = widget["frame"]
            self.widgets_notebook.forget(frame)
            frame.destroy()

        self.display_widgets()
        self.on_tab_selected()
    
    def display_widgets(self):
        for tab_id in self.widgets_notebook.tabs():
            self.widgets_notebook.forget(tab_id)
        
        for widget in self.widgets:
            if widget["restriction"] != self.hide:
                self.widgets_notebook.add(widget["frame"], text=f"P {widget['i']+1}")
                widget["label"].pack()
                widget["entry"].pack()

    def on_tab_selected(self):
        self.restriction.set(self.widgets[int(self.selected) - 1]["restriction"])
    
    def on_restriction_changed(self):
        self.widgets[int(self.selected) - 1]["restriction"] = self.restriction.get()
        
        self.display_widgets()
    
    def do_for_all_widget(self):
        for widget in self.widgets:
            widget["restriction"] = self.restriction.get()

        self.display_widgets()
    
    def fine(self):
        self.fill_widgets()
        self.display_widgets()
        
    def cancel(self):
        self.root.destroy()

if __name__ == "__main__":
    root = tk.Tk()
    app = MainWindow(root)
    root.mainloop()

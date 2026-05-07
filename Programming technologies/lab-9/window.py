from tkinter import BOTH, RIGHT, Button, DoubleVar, HORIZONTAL, IntVar, Scale, Spinbox, StringVar, Tk, W, X, LEFT, Canvas
from tkinter import ttk
from tkinter import colorchooser
import numpy as np
import pandas as pd
from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2Tk # pyright: ignore[reportPrivateImportUsage]

class SeriesData:
    def __init__(self, series_id):
        self.series_id = series_id
        self.line_color = StringVar(value="#000080")
        self.marker_edge_color = StringVar(value="#000000")
        self.marker_face_color = StringVar(value="#b22222")
        self.line_width = DoubleVar(value=2.0)
        self.level = DoubleVar(value=0.0)

class AppWindow:
    def __init__(self, root):
        self.root = root
        self.root.title("9 Лабораторная работа")
        self.root.geometry("1400x700")
        
        self.background = "#1a1a2e"
        self.foreground = "#eeeeee"
        # Style constants
        self.input_bg = "#2d2d44"
        self.input_fg = self.foreground
        self.btn_bg = "#1a1a2e"
        self.remove_btn_bg = "#c41e3a"
        
        self.SettingStyle = ttk.Style()
        self.SettingStyle.configure("Main.TFrame", background="#e0e0e0", padding=10)
        self.SettingStyle.configure("Settings.TFrame", background=self.background, foreground=self.foreground, padding=15)
        self.SettingStyle.configure("Settings.TLabel", 
                                font=("Segoe UI", 11),
                                foreground=self.foreground, 
                                background=self.background)
        self.SettingStyle.configure("Graph.TFrame", background="white", padding=5)
        self.SettingStyle.configure("Settings.TSpinbox", fieldbackground=self.input_bg, foreground=self.input_fg)
        self.SettingStyle.configure("Settings.TScale", background=self.background, troughcolor=self.input_bg, foreground=self.input_fg)
        # self.SettingStyle.configure("Settings.TButton", background=background, troughcolor="#2d2d44", foreground=foreground)
        
        self.MainContainer = ttk.Frame(self.root, style="Main.TFrame")
        self.MainContainer.pack(fill=BOTH, expand=True)
        
        self.MainContainer.columnconfigure(0, weight=0)
        self.MainContainer.columnconfigure(1, weight=1)
        self.MainContainer.rowconfigure(0, weight=1)
        
        self.Settings = ttk.Frame(self.MainContainer, width=300, style="Settings.TFrame")
        self.Settings.grid(row=0, column=0, sticky="ns")
        self.Settings.grid_propagate(False)
        
        self.GraphsContainer = ttk.Notebook(self.MainContainer)
        self.GraphsContainer.grid(row=0, column=1, sticky="nsew", padx=(2, 0))
        
        self.series_list = []
        self.series_count = 0
        self.add_series()
        
        self.CreateSettingsWidgets()
        self.CreateGraphsWidgets()
    
    def F(self, x, y):
        return 4*np.exp(-1/4*y**2)*np.sin(2*x)
    
    def add_series(self):
        self.series_count += 1
        series = SeriesData(self.series_count)
        self.series_list.append(series)
        return series
    
    def remove_series(self, series_id):
        self.series_list = [s for s in self.series_list if s.series_id != series_id]
        self.rebuild_series_controls()
        self.UpdatePlot()
    
    def CreateSettingsWidgets(self):
        def UpdateGraph():
            self.UpdatePlot()
        
        canvas = ttk.Frame(self.Settings, style="Settings.TFrame")
        canvas.pack(fill=BOTH, expand=True, side=LEFT)
        
        self.canvas_scroll = Canvas(canvas, highlightthickness=0, bg=self.background, highlightbackground=self.background)
        scrollbar = ttk.Scrollbar(canvas, orient="vertical", command=self.canvas_scroll.yview)
        self.canvas_scroll.configure(yscrollcommand=scrollbar.set)
        self.canvas_scroll.pack(side=LEFT, fill=BOTH, expand=True)
        scrollbar.pack(side=RIGHT, fill="y")
        
        scrollable_frame = ttk.Frame(self.canvas_scroll, style="Settings.TFrame")
        canvas_window = self.canvas_scroll.create_window((0, 0), window=scrollable_frame, anchor="nw")
        
        def on_frame_configure(event=None):
            self.canvas_scroll.configure(scrollregion=self.canvas_scroll.bbox("all"))
            self.canvas_scroll.itemconfig(canvas_window, width=self.canvas_scroll.winfo_width())
        
        scrollable_frame.bind("<Configure>", on_frame_configure)
        
        def on_mousewheel(event):
            self.canvas_scroll.yview_scroll(int(-1*(event.delta/120)), "units")
        self.canvas_scroll.bind_all("<MouseWheel>", on_mousewheel)
        
        param_frame = ttk.Frame(scrollable_frame, style="Settings.TFrame")
        param_frame.pack(fill=X, pady=5)
        
        label1 = ttk.Label(param_frame, text="Количество точек:", style="Settings.TLabel")
        label1.pack(anchor=W, pady=(10, 5))
        
        self.points_count = IntVar(value=100)
        points_spin = Spinbox(param_frame, from_=10, to=500, 
                            textvariable=self.points_count,
                            width=15, background=self.input_bg, foreground=self.input_fg,
                            buttonbackground=self.btn_bg, insertbackground=self.input_fg)
        points_spin.pack(fill=X, pady=(0, 10))

        self.level_value = DoubleVar(value=0.0)
        level_scale = Scale(param_frame, from_=-4.0, to=4.0,
                    orient=HORIZONTAL,
                    variable=self.level_value,
                    resolution=0.1,
                    length=200, background=self.input_bg, foreground=self.input_fg,
                troughcolor=self.background, highlightthickness=0, command=lambda x: self.UpdatePlot())
        level_scale.pack(fill=X, pady=(0, 15))

        label_tol = ttk.Label(param_frame, text="Допуск уровня:", style="Settings.TLabel")
        label_tol.pack(anchor=W, pady=(5, 5))

        self.level_tolerance = DoubleVar(value=0.2)
        tol_scale = Scale(param_frame, from_=0.01, to=1.0,
                orient=HORIZONTAL,
                variable=self.level_tolerance,
                resolution=0.01,
                length=200, background=self.input_bg, foreground=self.input_fg,
            troughcolor=self.background, highlightthickness=0, command=lambda x: self.UpdatePlot())
        tol_scale.pack(fill=X, pady=(0, 15))
        
        label_series = ttk.Label(param_frame, text="Управление сериями:", style="Settings.TLabel")
        label_series.pack(anchor=W, pady=(10, 5))
        
        btn_add_series = ttk.Button(param_frame, text="+ Добавить серию", command=lambda: (self.add_series(), self.rebuild_series_controls(), self.UpdatePlot()), style="Settings.TButton")
        btn_add_series.pack(fill=X, pady=(0, 5))

        self.series_frame = ttk.Frame(param_frame, style="Settings.TFrame")
        self.series_frame.pack(fill=BOTH, expand=True, pady=(0, 10))
        
        self.rebuild_series_controls()
        
        update_btn = ttk.Button(scrollable_frame, text="обновить график", style="Settings.TButton",
                            command=UpdateGraph)
        update_btn.pack(pady=(10, 0), fill=X)
        
        self.root.update_idletasks()
        on_frame_configure()
    
    def rebuild_series_controls(self):
        for widget in self.series_frame.winfo_children():
            widget.destroy()
        
        def choose_color(var, btn):
            col = colorchooser.askcolor(title="Выберите цвет", initialcolor=var.get())
            if col and col[1]:
                var.set(col[1])
                try:
                    btn.config(bg=col[1])
                except Exception:
                    pass
        
        for idx, series in enumerate(self.series_list):
            series_header = ttk.Frame(self.series_frame, style="Settings.TFrame")
            series_header.pack(fill=X, pady=(5, 3))
            
            lbl_series = ttk.Label(series_header, text=f"Серия {series.series_id}:", style="Settings.TLabel")
            lbl_series.pack(side=LEFT)
            
            if len(self.series_list) > 1:
                btn_remove = Button(series_header, text="✕", width=2, bg=self.remove_btn_bg, fg="white",
                                command=lambda sid=series.series_id: self.remove_series(sid))
                btn_remove.pack(side=RIGHT, padx=(5, 0))
            
            # Параметры серии
            colors_subframe = ttk.Frame(self.series_frame, style="Settings.TFrame")
            colors_subframe.pack(fill=X, padx=(10, 0), pady=(0, 10))
            
            # Уровень для этой серии
            lbl_series_level = ttk.Label(colors_subframe, text="Уровень серии:", style="Settings.TLabel")
            lbl_series_level.grid(row=0, column=0, sticky=W, pady=2)
            series_level_scale = Scale(colors_subframe, from_=-4.0, to=4.0, orient=HORIZONTAL,
                                    variable=series.level, resolution=0.1, length=150,
                                    background=self.input_bg, foreground=self.input_fg,
                                    troughcolor=self.background, highlightthickness=0,
                                    command=lambda x: self.UpdatePlot())
            series_level_scale.grid(row=0, column=1, sticky="ew", padx=6)
            
            # Цвет линии
            lbl_line_col = ttk.Label(colors_subframe, text="Цвет линии:", style="Settings.TLabel")
            lbl_line_col.grid(row=1, column=0, sticky=W, pady=2)
            btn_line_col = Button(colors_subframe, bg=series.line_color.get(), width=3, 
                                command=lambda var=series.line_color: (choose_color(var, btn_line_col), self.UpdatePlot()))
            btn_line_col.grid(row=1, column=1, padx=6)
            
            # Толщина линии
            lbl_line_width = ttk.Label(colors_subframe, text="Толщина:", style="Settings.TLabel")
            lbl_line_width.grid(row=2, column=0, sticky=W, pady=2)
            spin_line_width = Spinbox(colors_subframe, from_=0.5, to=10.0, increment=0.5, 
                                textvariable=series.line_width, width=6, background=self.input_bg,
                                foreground=self.input_fg, buttonbackground=self.btn_bg, insertbackground=self.input_fg)
            spin_line_width.grid(row=2, column=1, sticky=W, padx=6)
            
            # Цвет заливки маркеров
            lbl_marker_face = ttk.Label(colors_subframe, text="Заливка маркеров:", style="Settings.TLabel")
            lbl_marker_face.grid(row=3, column=0, sticky=W, pady=2)
            btn_marker_face = Button(colors_subframe, bg=series.marker_face_color.get(), width=3,
                                    command=lambda var=series.marker_face_color: (choose_color(var, btn_marker_face), self.UpdatePlot()))
            btn_marker_face.grid(row=3, column=1, padx=6)
            
            # Цвет обводки маркеров
            lbl_marker_edge = ttk.Label(colors_subframe, text="Обводка маркеров:", style="Settings.TLabel")
            lbl_marker_edge.grid(row=4, column=0, sticky=W, pady=2)
            btn_marker_edge = Button(colors_subframe, bg=series.marker_edge_color.get(), width=3,
                                    command=lambda var=series.marker_edge_color: (choose_color(var, btn_marker_edge), self.UpdatePlot()))
            btn_marker_edge.grid(row=4, column=1, padx=6)
    
    def CreateGraphsWidgets(self):
        # Вкладка 1
        tab1 = ttk.Frame(self.GraphsContainer, style="Graph.TFrame")
        self.GraphsContainer.add(tab1, text="18 Вариант 2D Диаграмма")
        
        left_frame = ttk.Frame(tab1, style="Graph.TFrame")
        left_frame.pack(fill=BOTH, expand=True)
        
        self.fig_left = Figure(figsize=(5.5, 6), dpi=100)
        self.ax_left = self.fig_left.add_subplot(111)
        self.canvas_left = FigureCanvasTkAgg(self.fig_left, master=left_frame)
        self.canvas_left.draw()
        self.canvas_left.get_tk_widget().pack(fill=BOTH, expand=True)
        self.toolbar_left = NavigationToolbar2Tk(self.canvas_left, left_frame)
        self.toolbar_left.update()
        
        # Вкладка 2
        tab2 = ttk.Frame(self.GraphsContainer, style="Graph.TFrame")
        self.GraphsContainer.add(tab2, text="18 Вариант 3D Поверхность")

        right_frame = ttk.Frame(tab2, style="Graph.TFrame")
        right_frame.pack(fill=BOTH, expand=True)
        
        self.fig_right = Figure(figsize=(5.5, 6), dpi=100)
        self.ax_right = self.fig_right.add_subplot(111, projection="3d")
        self.canvas_right = FigureCanvasTkAgg(self.fig_right, master=right_frame)
        self.canvas_right.draw()
        self.canvas_right.get_tk_widget().pack(fill=BOTH, expand=True)
        self.toolbar_right = NavigationToolbar2Tk(self.canvas_right, right_frame)
        self.toolbar_right.update()
        
        self.UpdatePlot()
    
    def UpdatePlot(self):
        try:
            n_points = self.points_count.get()
            x = np.linspace(0, 4 * np.pi, n_points)
            y = np.linspace(-3, 3, n_points)
            X, Y = np.meshgrid(x, y)
            Z = self.F(X, Y)
            
            # точечная диаграмма уровней
            self.ax_left.clear()
            
            if np.any(Z):
                for idx, series in enumerate(self.series_list):
                    level = series.level.get()
                    tolerance = self.level_tolerance.get()
                    mask = np.abs(Z - level) <= tolerance
                    
                    if np.any(mask):
                        edge_color_val = series.marker_edge_color.get()
                        face_color_val = series.marker_face_color.get()
                        # Небольшое смещение
                        offset_x = (idx - len(self.series_list) / 2) * 0.1
                        offset_y = (idx - len(self.series_list) / 2) * 0.1
                        self.ax_left.scatter(X[mask] + offset_x, Y[mask] + offset_y, s=35, facecolors=face_color_val, 
                                            edgecolors=edge_color_val, alpha=0.7, 
                                            linewidths=max(0.1, series.line_width.get() * 0.2),
                                            label=f"Серия {series.series_id} (уровень {level:.2f})")
                        self.ax_left.contour(X, Y, Z, levels=[level], colors=series.line_color.get(), 
                                            linewidths=series.line_width.get())
            else:
                self.ax_left.text(0.5, 0.5,
                                "Нет данных для отображения",
                                ha='center', va='center', transform=self.ax_left.transAxes)
            
            self.ax_left.set_title("Вариант 18 (Точечная диаграмма)")
            self.ax_left.set_xlabel("Ось X")
            self.ax_left.set_ylabel("Ось Y")
            if len(self.series_list) > 1:
                self.ax_left.legend(loc='upper right', fontsize=8)
            self.fig_left.tight_layout()
            self.canvas_left.draw()
            
            self.ax_right.clear()
            self.ax_right.plot_surface( # type: ignore
                X, Y, Z,
                cmap="viridis",
                edgecolor=self.series_list[0].marker_edge_color.get() if self.series_list else "#000000",
                linewidth=max(0.1, (self.series_list[0].line_width.get() if self.series_list else 2.0) * 0.2),
                alpha=0.9,
                antialiased=True,
            )
            self.ax_right.set_title("Вариант 18 (3D Поверхность)")
            self.ax_right.set_xlabel("Ось X")
            self.ax_right.set_ylabel("Ось Y")
            self.ax_right.set_zlabel("F(x,y)") # type: ignore
            self.fig_right.tight_layout()
            self.canvas_right.draw()
            
            print("Графики обновлены")
            
        except Exception as e:
            print(f"Ошибка: {e}")

# Запуск приложения
if __name__ == "__main__":
    root = Tk()
    app = AppWindow(root)
    root.mainloop()
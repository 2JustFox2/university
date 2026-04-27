from tkinter import *
from tkinter import ttk

def AppWindow(data):
    root = Tk()
    root.title("8 Лабараторная работа")
    root.geometry("400x300")
    
    listbox_frame = Frame(root)
    listbox_frame.pack(padx=10, pady=10)
    
    t_frame = Frame(listbox_frame)
    t_frame.grid(row=0, column=0, padx=5, pady=5)
    label_T = Label(t_frame, text="T:")
    label_T.grid(row=0, column=0, columnspan=2, pady=(0, 5))
    listbox_T = Listbox(t_frame, width=4)
    for item in data[1:]:
        listbox_T.insert(END, item[0])
    listbox_T.grid(row=1, column=0)
    scrollbar_T = Scrollbar(t_frame, orient=VERTICAL, command=listbox_T.yview)
    scrollbar_T.grid(row=1, column=1, sticky='ns')
    listbox_T.config(yscrollcommand=scrollbar_T.set)
    scrollbar_T.config(command=listbox_T.yview)
    
    r_frame = Frame(listbox_frame)
    r_frame.grid(row=0, column=1, padx=5, pady=5)
    label_R = Label(r_frame, text="R:")
    label_R.grid(row=0, column=0, columnspan=2, pady=(0, 5))
    listbox_R = Listbox(r_frame, width=4)
    for item in data[0][1:]:
        listbox_R.insert(END, item)
    listbox_R.grid(row=1, column=0)
    scrollbar_R = Scrollbar(r_frame, orient=VERTICAL, command=listbox_R.yview)
    scrollbar_R.grid(row=1, column=1, sticky='ns')
    listbox_R.config(yscrollcommand=scrollbar_R.set)
    scrollbar_R.config(command=listbox_R.yview)

    root.mainloop()
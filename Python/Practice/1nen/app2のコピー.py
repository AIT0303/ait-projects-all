import tkinter as tk

root = tk.Tk()
root.geometory("200×100")

lbl = tk.Label(text="LABEL")
btn = tk.Button(text="push")

lbl.pack()
btn.pack()
tk.mainloop()

import tkinter as tk

def execute():
    txt = "こんにちは"
    lbl.configure(text=txt)

root = tk.Tk()
root.title("こんにちはテストです。")
root.geometry("200x100")

lbl = tk.Label(text="")
btn = tk.Button(text="実行", command= execute)

lbl.pack()
btn.pack()
tk.mainloop()
import PySimpleGUI as sg

layout = [[sg.I("ふたば", key="in")],
          [sg.B("実行", key="btn")],
          [sg.T(k="txt")]]
win = sg.Window("あいさつテスト", layout)

def execute():
    txt = "こんにちは、"+v["in"] + "さん！"
    win["txt"].update(txt)

while True:
    e, v = win.read()
    if e == "btn":
        execute()
    if e == None:
        break
win.close()
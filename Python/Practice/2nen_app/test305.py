import PySimpleGUI as sg
sg.theme("red")

layout = [[sg.T("金額と人数を入力してください。")],
          [sg.T("金額"), sg.I(k="in1")],
          [sg.T("人数"), sg.I(k="in2")],
          [sg.B("実行", k="btn"),sg.T(k="txt")]]
win = sg.Window("割り勘アプリ", layout,
                font=(None,14), size=(320,150))

def execute():
    in1 = int(v["in1"])
    in2 = int(v["in2"])
    txt = f"1人、{in1 / in2 :.0f}円です。"
    win["txt"].update(txt)

while True:
    e, v = win.read()
    if e == "btn":
        execute()
    if e == None:
        break
win.close()
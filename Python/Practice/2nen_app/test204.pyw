import PySimpleGUI as sg
sg.theme("Green")

layout = [[sg.I("ゆずか", key="in")], 
          [sg.I("こうき", key="in")],
          [sg.B("実行", key="btn"), sg.B("結果", key="btn")],
          [sg.T(k="txt")]]
win = sg.Window("要素レイアウトテスト", layout,
                font=(None,14), size=(400,200))

def execute():
    txt = "こんにちは、"+v["in"] + "さん！"
    win["txt"].update(txt)

while True:
    e, v = win.read()
    if e == "btn":
        execute()
    if e == None:
        break
win.close
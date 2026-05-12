import PySimpleGUI as sg

layout = [[sg.Input("ゆずか", key="in")],
         [sg.Button("実行", key="btn")],
         [sg.Text(key="txt")]]
window = sg.Window("test", layout)


def execute():
    txt = "こんにちは"+values["in"]+"さん！"
    window["txt"].update(txt)

while True:
    event, values = window.read()
    if event == "btn":
        execute()
    if event == None:
        break
    window.close
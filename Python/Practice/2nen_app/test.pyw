import PySimpleGUI as sg

layout = [[sg.Input("ふたば")],
          [sg.Button("実行")],
          [sg.Text("こんにちは")]]
window = sg.Window("test",layout)

event, valus = window.read()
window.close()
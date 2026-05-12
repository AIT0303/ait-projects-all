import PySimpleGUI as sg

layout = [[sg.T("ABCDE", size=(30,1), justification="left")],
          [sg.T("実行", size=(30,1), justification="center")],
          [sg.ML("複数行のテキスト\n田中弘輝\n田中柚香", size=(30,3))]]

win = sg.Window("文字列レイアウト", layout,
                font=(None,14), size=(500,300))

e, v = win.read()
win.close()






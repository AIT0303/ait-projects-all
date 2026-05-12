from flask import Flask, render_template_string
import datetime

app = Flask(__name__)

@app.route('/')
def show_time():
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    return render_template_string('<html><body><h1>現在の時刻: {{ time }}</h1><button onclick="window.location.reload();">時刻を更新</button></body></html>', time=current_time)

if __name__ == '__main__':
    app.run(debug=True)

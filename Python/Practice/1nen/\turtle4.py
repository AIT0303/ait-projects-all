import requests
from bs4 import BeautifulSoup

def basic_scraping(url):
    # URLからデータを取得
    response = requests.get(url)
    # 正常なレスポンスを確認
    if response.status_code == 200:
        # BeautifulSoupを使用してHTMLを解析
        soup = BeautifulSoup(response.text, 'html.parser')
        return soup
    else:
        return None

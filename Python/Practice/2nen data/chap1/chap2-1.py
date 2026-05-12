import requests
from bs4 import BeautifulSoup

load_url = "https://www.ymori.com/books/python2nen/test2.html"
html = requests.get(load_url)
soup = BeautifulSoup(html.content, "html.parser")

chap2 = soup.find(id="chap2")
for element in chap2.find_all("li"):
    print(element.text)

"""
print(soup.find_all("li").text)
print(soup.find("li").text)
print(soup.find("h2").text)
"""
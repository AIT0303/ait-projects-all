import ebooklib
from ebooklib import epub
import bs4

def read_epub_file(file_path):
    book = epub.read_epub(file_path)
    content = []
    for item in book.get_items():
        if item.get_type() == ebooklib.ITEM_DOCUMENT:
            soup = bs4.BeautifulSoup(item.content, 'html.parser')
            text = soup.get_text()
            content.append(text)
    return '\n'.join(content)

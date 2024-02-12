from selenium import webdriver
from bs4 import BeautifulSoup as bs

url ='https://thelist.group/realist/condo/'

browser = webdriver.Chrome()
browser.set_window_size(390, 844)
browser.get("http://google.com")
browser.get(url)
soup = bs(browser.page_source, 'html.parser')
browser.close()
head = soup.head
script = head.find_all('script')
script = script[19]
if "https://www.googletagmanager.com/gtm.js?id=" in str(script):
    print(f"script -- ok")
else:
    print(f"script -- not found")
body = soup.body
noscript = body.find('noscript')
if "https://www.googletagmanager.com/ns.html?id=GTM-55LVRBZ" in str(noscript):
    print(f"noscript -- ok")
else:
    print(f"noscript -- not found")
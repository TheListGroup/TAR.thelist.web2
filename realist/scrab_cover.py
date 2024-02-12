from selenium import webdriver
from bs4 import BeautifulSoup as bs
import time
from selenium.webdriver.common.by import By
import pandas as pd

url = "http://159.223.51.33:8080/realist/condo/list/spotlight/คอนโดเปิดตัว-2022/"

cover_list = []
browser = webdriver.Chrome()
browser.maximize_window()
browser.get("http://google.com")
browser.get(url)

browser.execute_script("window.scrollTo(0, 850)")
element = browser.find_element(By.XPATH ,("//label[@for='all']"))
element.click()
time.sleep(3)
soup = bs(browser.page_source, 'html.parser')
condo_list = soup.find('div' ,{'id':"intial-condo-list"})
for i , each_list in enumerate(condo_list.find_all('div' ,{'style':"padding-top: 4px; padding-bottom: 4px; width: 100%;"})):
    info = each_list.find('div' ,{'class':"container"})
    condo = info.find('div' ,{'class':"col pl-0 show-single-line condo-list-name font-weight-bold"})
    condo_name = condo.text.strip()
    link = condo.get('onclick')
    link = link.replace("gotoCondo","")
    link = link.replace('"',"").replace('"',"")
    link = link[1:-1]
    link = ("http://159.223.51.33:8080/realist/condo/proj/",link)
    link = "".join(link)
    code = link.split("-")
    code = code[-1]
    condo_dict = {"CODE" : code, "CONDO_NAME" : condo_name, "LINK" : link}

    browser.execute_script("window.open();")
    browser.switch_to.window(browser.window_handles[1])
    browser.get(link)
    time.sleep(3)
    soup_in = bs(browser.page_source, 'html.parser')
    cover = soup_in.find('picture' ,{'style':"z-index: -2; position: absolute;"})
    cover_link = cover.find('source')
    cover_link = cover_link.get('srcset')
    browser.close()
    browser.switch_to.window(browser.window_handles[0])
    condo_dict["COVER"] = cover_link
    cover_list.append(condo_dict)
browser.close()
cover_df = pd.DataFrame(cover_list)
cover_df.to_csv('cover.csv')
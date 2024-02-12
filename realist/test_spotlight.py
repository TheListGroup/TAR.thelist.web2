from selenium import webdriver
from bs4 import BeautifulSoup as bs
import pandas as pd
import time
import re
from selenium.webdriver import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.common.actions.wheel_input import ScrollOrigin
from selenium.webdriver.common.actions.action_builder import ActionBuilder
from selenium.webdriver.common.actions.mouse_button import MouseButton

#urls = 'http://thelist.group/realist/condo/list/spotlight/คอนโดพร้อมอยู่/'
#urls = 'http://157.245.195.151/realist/condo/list/spotlight/คอนโดพร้อมอยู่/'
urls = 'http://157.245.195.151/realist/condo/list/spotlight/คอนโดโซน-CBD/'

#code_condo = pd.read_csv("code.csv", encoding='utf-8')
condo_list = []
browser = webdriver.Chrome()
browser.get("http://google.com")
browser.get(urls)
browser.maximize_window()
time.sleep(2)

spotlight_1 = ['คอนโดพร้อมอยู่','คอนโดโซน CBD','คอนโดใกล้สถานีรถไฟฟ้า','คอนโดใกล้สถานี Interchange','คอนโดใกล้สถานี BTS','คอนโดใกล้สถานี MRT','คอนโดใกล้สถานี Airport Link','คอนโดวิวสวน']
browser.execute_script("window.scrollTo(0, 900)")
time.sleep(4)
map = browser.find_element(By.XPATH ,("//label[@for='all']"));
time.sleep(2)
ActionChains(browser)\
    .click(map)\
    .perform()
time.sleep(3)
listing_condo = browser.find_element(By.ID, 'nearby_box')
time.sleep(2)
list_move = ScrollOrigin.from_element(listing_condo, 0, 0)
x=0
while x in range(40):
    ActionChains(browser)\
        .scroll_from_origin(list_move, 0, 2000)\
        .perform()
    time.sleep(3)
    x += 1
    if x == 40:
            break
soup = bs(browser.page_source, 'html.parser')
browser.close()
#code_condo.insert(1,spotlight_1[1],"")
condo = soup.find('div', {'id': 'intial-condo-list'})
for l, list_condo in enumerate(condo.find_all('div', {'class': "container lazyloaded"})):
    link_in = list_condo.get('id')
    code = link_in.split("-")
    code = code[-1]
    condo_dict = {'code' : code}
    condo_list.append(condo_dict)
#    index = code.replace("CD","")
#   index = int(index)
#    if index in range(code_condo.index.size):
#        code_condo.iloc[index, 1] = 1
#print(code_condo)
condo_df = pd.DataFrame(condo_list)
condo_df.to_csv('condo_cbd.csv')
print('done')
#code_condo.to_csv('spotlight_done.csv')
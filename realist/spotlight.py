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
from urllib.parse import urlparse, urljoin

#url = "http://thelist.group/realist/condo/"
url ='http://157.245.195.151/realist/condo/'

code_condo = pd.read_csv("code.csv", encoding='utf-8')
browser = webdriver.Chrome()
browser.get("http://google.com")
browser.get(url)
browser.maximize_window()
time.sleep(2)

soup = bs(browser.page_source, 'html.parser')
browser.close()
#get url of all spotlight
spotlight = soup.find('div', {'id': 'top-spotlight'})
for i , list in enumerate(spotlight.find_all('div' ,{'class':"py-1"})) :
    if list:
        spotlight_section = list.find('a')
        number = list.find('p')
        if spotlight_section:
            spotlight_name = spotlight_section.text.strip()
            spotlight_link = spotlight_section.get('href')
#            urls = ("http://thelist.group",spotlight_link)
            urls = ("http://157.245.195.151",spotlight_link)
            urls = "".join(urls)
            code_condo.insert(i+1,spotlight_name,"")
            #print(f"{spotlight_name} === {urls}")
        if number:
            num = number.text.strip()
            num = num.replace("(","")
            num = num.replace(")","")
            num = num.replace(",","")
            num = int(num)
    #print(f"{i} -- {spotlight_name}")
    
            browser = webdriver.Chrome()
            browser.get(urls)
            browser.maximize_window()
            time.sleep(2)
            browser.execute_script("window.scrollTo(0, 900)")
            time.sleep(4)
            listing_condo = browser.find_element(By.ID, 'nearby_box')
            time.sleep(2)
            map = browser.find_element(By.XPATH ,("//label[@for='all']"));
            time.sleep(2)
            ActionChains(browser)\
                .click(map)\
                .perform()
            time.sleep(3)
            
            #scroll for find all condo
            list_move = ScrollOrigin.from_element(listing_condo, 0, 0)
            x = 0
            if num > 2000:
                while x in range(120):
                    ActionChains(browser)\
                        .scroll_from_origin(list_move, 0, 2000)\
                        .perform()
                    time.sleep(3)
                    x += 1
                    if x == 120:
                            break
            if num > 1000:
                while x in range(65):
                    ActionChains(browser)\
                        .scroll_from_origin(list_move, 0, 2000)\
                        .perform()
                    time.sleep(3)
                    x += 1
                    if x == 65:
                            break
            if num > 500:
                while x in range(40):
                    ActionChains(browser)\
                        .scroll_from_origin(list_move, 0, 2000)\
                        .perform()
                    time.sleep(3)
                    x += 1
                    if x == 40:
                            break
            if num > 200:
                while x in range(23):
                    ActionChains(browser)\
                        .scroll_from_origin(list_move, 0, 2000)\
                        .perform()
                    time.sleep(3)
                    x += 1
                    if x == 23:
                            break
            if num > 100:
                while x in range(15):
                    ActionChains(browser)\
                        .scroll_from_origin(list_move, 0, 1500)\
                        .perform()
                    time.sleep(3)
                    x += 1
                    if x == 15:
                            break
            if num > 10:
                while x in range(10):
                    ActionChains(browser)\
                        .scroll_from_origin(list_move, 0, 1500)\
                        .perform()
                    time.sleep(3)
                    x += 1
                    if x == 10:
                            break
            else:
                while x in range(2):
                    ActionChains(browser)\
                        .scroll_from_origin(list_move, 0, 2500)\
                        .perform()
                    time.sleep(3)
                    x += 1
                    if x == 2:
                            break
                            
        soup_in = bs(browser.page_source, 'html.parser')
        browser.close()
        #find condo code
        condo = soup_in.find('div', {'id': 'intial-condo-list'})
        for l, list_condo in enumerate(condo.find_all('div', {'class': "container lazyloaded"})):
            link_in = list_condo.get('id')
            code = link_in.split("-")
            code = code[-1] 
            #print(code)
            print(f"{l}--{code}")
            index = code.replace("CD","")
            index = int(index)
            #print(index)
            #check code in spotlight 
            if index in range(code_condo.index.size):
                code_condo.iloc[index, i+1] = 1
print('done')
code_condo.to_csv('spotlight_done.csv')
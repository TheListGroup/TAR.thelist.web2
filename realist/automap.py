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
url ='http://159.223.51.33/realist/condo/'

mark_list = []
browser = webdriver.Chrome()
browser.get("http://google.com")
browser.get(url)
browser.maximize_window()
time.sleep(2)

soup = bs(browser.page_source, 'html.parser')
browser.close()
#lisiting spotlight
spotlight = soup.find('div', {'id': 'top-spotlight'})
for i , list in enumerate(spotlight.find_all('div' ,{'class':"py-1"})) :
    if list:
        spotlight_section = list.find('a')
        if spotlight_section:
            spotlight_name = spotlight_section.text.strip()
            spotlight_link = spotlight_section.get('href')
#            urls = ("http://thelist.group",spotlight_link)
            urls = ("http://159.223.51.33",spotlight_link)
            urls = "".join(urls)
            mark_dict = {"LISTING": spotlight_name, "condo_mark_s": "", "near_mark_s": "", "condo_mark_l": "", "near_mark_l": ""}
    
            browser = webdriver.Chrome()  
            browser.get(urls)
            browser.maximize_window()
            time.sleep(2)
            browser.execute_script("window.scrollTo(0, 900)")
            time.sleep(3)
            map = browser.find_element(By.XPATH ,("//label[@for='all']"));
            time.sleep(1)
            ActionChains(browser)\
                .click(map)\
                .perform()
            time.sleep(5)
            soup_in = bs(browser.page_source, 'html.parser')
            browser.close()
            spotlight_mark_s = soup_in.find('div', {'class': 'condo-marker-s'})
            spotlight_near_s = soup_in.find('div', {'class': 'poi-overlay-marker-s'})
            spotlight_mark_l = soup_in.find('div', {'class': 'condo-marker-l'})
            spotlight_near_l = soup_in.find('div', {'class': 'poi-overlay-marker-l'})
            if spotlight_mark_s:
                mark_dict['condo_mark_s'] = 1
            if spotlight_near_s:
                mark_dict['near_mark_s'] = 1
            if spotlight_mark_l:
                mark_dict['condo_mark_l'] = 1
            if spotlight_near_l:
                mark_dict['near_mark_l'] = 1
            mark_list.append(mark_dict)

#listing price
price = soup.find('div', {'id': 'top-price'})
for i , list in enumerate(price.find_all('div' ,{'class':"py-1"})) :
    if list:
        price_section = list.find('a')
        if price_section:
            price_name = price_section.text.strip()
            price_link = price_section.get('href')
            #urls = ("http://thelist.group",price_link)
            urls = ("http://159.223.51.33",price_link)
            urls = "".join(urls)
            mark_dict = {"LISTING": price_name}

            browser = webdriver.Chrome()
            browser.get(urls)
            browser.maximize_window()
            time.sleep(2)
            browser.execute_script("window.scrollTo(0, 900)")
            time.sleep(4)
            map = browser.find_element(By.XPATH ,("//label[@for='all']"));
            time.sleep(1)
            ActionChains(browser)\
                .click(map)\
                .perform()
            time.sleep(5)
            soup_in = bs(browser.page_source, 'html.parser')
            browser.close()
            price_mark_s = soup_in.find('div', {'class': 'condo-marker-s'})
            price_near_s = soup_in.find('div', {'class': 'poi-overlay-marker-s'})
            price_mark_l = soup_in.find('div', {'class': 'condo-marker-l'})
            price_near_l = soup_in.find('div', {'class': 'poi-overlay-marker-l'})
            if price_mark_s:
                mark_dict['condo_mark_s'] = 1
            if price_near_s:
                mark_dict['near_mark_s'] = 1
            if price_mark_l:
                mark_dict['condo_mark_l'] = 1
            if price_near_l:
                mark_dict['near_mark_l'] = 1
            mark_list.append(mark_dict)

#listing train            
train = soup.find('div', {'id': 'top-train'})
for i , list in enumerate(train.find_all('div' ,{'class':"py-1"})) :
    if list:
        train_section = list.find('a')
        if train_section:
            train_name = train_section.text.strip()
            train_link = train_section.get('href')
            #urls = ("http://thelist.group",train_link)
            urls = ("http://159.223.51.33",train_link)
            urls = "".join(urls)
            mark_dict = {"LISTING": train_name}
            browser = webdriver.Chrome()
            browser.get(urls)
            browser.maximize_window()
            time.sleep(2)
            browser.execute_script("window.scrollTo(0, 900)")
            time.sleep(4)
            map = browser.find_element(By.XPATH ,("//label[@for='all']"));
            time.sleep(1)
            ActionChains(browser)\
                .click(map)\
                .perform()
            time.sleep(5)
            soup_in = bs(browser.page_source, 'html.parser')
            browser.close()
            train_mark_s = soup_in.find('div', {'class': 'condo-marker-s'})
            train_near_s = soup_in.find('div', {'class': 'poi-overlay-marker-s'})
            train_mark_l = soup_in.find('div', {'class': 'condo-marker-l'})
            train_near_l = soup_in.find('div', {'class': 'poi-overlay-marker-l'})
            if train_mark_s:
                mark_dict['condo_mark_s'] = 1
            if train_near_s:
                mark_dict['near_mark_s'] = 1
            if train_mark_l:
                mark_dict['condo_mark_l'] = 1
            if train_near_l:
                mark_dict['near_mark_l'] = 1
            mark_list.append(mark_dict)
#train cause 1 station not same element
ex = train.find('div' ,{'class':"pt-1 pb-0"})
train_section = ex.find('a')
train_name = train_section.text.strip()
train_link = train_section.get('href')
#urls = ("http://thelist.group",train_link)
urls = ("http://159.223.51.33",train_link)
urls = "".join(urls)
mark_dict = {"LISTING": train_name}
browser = webdriver.Chrome()
browser.get(urls)
browser.maximize_window()
time.sleep(2)
browser.execute_script("window.scrollTo(0, 900)")
time.sleep(4)
map = browser.find_element(By.XPATH ,("//label[@for='all']"));
time.sleep(1)
ActionChains(browser)\
    .click(map)\
    .perform()
time.sleep(5)
soup_in = bs(browser.page_source, 'html.parser')
browser.close()
train_mark_s = soup_in.find('div', {'class': 'condo-marker-s'})
train_near_s = soup_in.find('div', {'class': 'poi-overlay-marker-s'})
train_mark_l = soup_in.find('div', {'class': 'condo-marker-l'})
train_near_l = soup_in.find('div', {'class': 'poi-overlay-marker-l'})
if train_mark_s:
    mark_dict['condo_mark_s'] = 1
    if train_near_s:
        mark_dict['near_mark_s'] = 1
    if train_mark_l:
        mark_dict['condo_mark_l'] = 1
    if train_near_l:
        mark_dict['near_mark_l'] = 1
    mark_list.append(mark_dict)
#listing trian (station)
for a , station in  enumerate(train.find_all('div' ,{'class':"py-0"})) :
    if station:
        train_section = station.find('a')
        if train_section:
            train_name = train_section.text.strip()
            train_link = train_section.get('href')
            #urls = ("http://thelist.group",train_link)
            urls = ("http://159.223.51.33",train_link)
            urls = "".join(urls)
            mark_dict = {"LISTING": train_name}
            browser = webdriver.Chrome()
            browser.get(urls)
            browser.maximize_window()
            time.sleep(2)
            browser.execute_script("window.scrollTo(0, 900)")
            time.sleep(4)
            map = browser.find_element(By.XPATH ,("//label[@for='all']"));
            time.sleep(1)
            ActionChains(browser)\
                .click(map)\
                .perform()
            time.sleep(5)
            soup_in = bs(browser.page_source, 'html.parser')
            browser.close()
            train_mark_s = soup_in.find('div', {'class': 'condo-marker-s'})
            train_near_s = soup_in.find('div', {'class': 'poi-overlay-marker-s'})
            train_mark_l = soup_in.find('div', {'class': 'condo-marker-l'})
            train_near_l = soup_in.find('div', {'class': 'poi-overlay-marker-l'})
            if train_mark_s:
                mark_dict['condo_mark_s'] = 1
            if train_near_s:
                mark_dict['near_mark_s'] = 1
            if train_mark_l:
                mark_dict['condo_mark_l'] = 1
            if train_near_l:
                mark_dict['near_mark_l'] = 1
            mark_list.append(mark_dict)

#listing place            
place = soup.find('div', {'id': 'top-place'})
for i , list in enumerate(place.find_all('div' ,{'class':"py-1"})) :
    if list:
        place_section = list.find('a')
        if place_section:
            place_name = place_section.text.strip()
            place_link = place_section.get('href')
            #urls = ("http://thelist.group",place_link)
            urls = ("http://159.223.51.33",place_link)
            urls = "".join(urls)
            mark_dict = {"LISTING": place_name}

            browser = webdriver.Chrome()
            browser.get(urls)
            browser.maximize_window()
            time.sleep(2)
            browser.execute_script("window.scrollTo(0, 900)")
            time.sleep(4)
            map = browser.find_element(By.XPATH ,("//label[@for='all']"));
            time.sleep(1)
            ActionChains(browser)\
                .click(map)\
                .perform()
            time.sleep(5)
            soup_in = bs(browser.page_source, 'html.parser')
            browser.close()
            place_mark_s = soup_in.find('div', {'class': 'condo-marker-s'})
            place_near_s = soup_in.find('div', {'class': 'poi-overlay-marker-s'})
            place_mark_l = soup_in.find('div', {'class': 'condo-marker-l'})
            place_near_l = soup_in.find('div', {'class': 'poi-overlay-marker-l'})
            if place_mark_s:
                mark_dict['condo_mark_s'] = 1
            if place_near_s:
                mark_dict['near_mark_s'] = 1
            if place_mark_l:
                mark_dict['condo_mark_l'] = 1
            if place_near_l:
                mark_dict['near_mark_l'] = 1
            mark_list.append(mark_dict)

#listing developer            
developer = soup.find('div', {'id': 'top-developer'})
for i , list in enumerate(developer.find_all('div' ,{'class':"py-1"})) :
    if list:
        developer_section = list.find('a')
        if developer_section:
            developer_name = developer_section.text.strip()
            developer_link = developer_section.get('href')
            #urls = ("http://thelist.group",developer_link)
            urls = ("http://159.223.51.33",developer_link)
            urls = "".join(urls)
            mark_dict = {"LISTING": developer_name}

            browser = webdriver.Chrome()
            browser.get(urls)
            browser.maximize_window()
            time.sleep(2)
            browser.execute_script("window.scrollTo(0, 900)")
            time.sleep(4)
            map = browser.find_element(By.XPATH ,("//label[@for='all']"));
            time.sleep(1)
            ActionChains(browser)\
                .click(map)\
                .perform()
            time.sleep(5)
            soup_in = bs(browser.page_source, 'html.parser')
            browser.close()
            developer_mark_s = soup_in.find('div', {'class': 'condo-marker-s'})
            developer_near_s = soup_in.find('div', {'class': 'poi-overlay-marker-s'})
            developer_mark_l = soup_in.find('div', {'class': 'condo-marker-l'})
            developer_near_l = soup_in.find('div', {'class': 'poi-overlay-marker-l'})
            if developer_mark_s:
                mark_dict['condo_mark_s'] = 1
            if developer_near_s:
                mark_dict['near_mark_s'] = 1
            if developer_mark_l:
                mark_dict['condo_mark_l'] = 1
            if developer_near_l:
                mark_dict['near_mark_l'] = 1
            mark_list.append(mark_dict)

#listing brand            
brand = soup.find('div', {'id': 'top-brand'})
for i , list in enumerate(brand.find_all('div' ,{'class':"py-1"})) :
    if list:
        brand_section = list.find('a')
        if brand_section:
            brand_name = brand_section.text.strip()
            brand_link = brand_section.get('href')
            #urls = ("http://thelist.group",brand_link)
            urls = ("http://159.223.51.33",brand_link)
            urls = "".join(urls)
            mark_dict = {"LISTING": brand_name}

            browser = webdriver.Chrome()
            browser.get(urls)
            browser.maximize_window()
            time.sleep(2)
            browser.execute_script("window.scrollTo(0, 900)")
            time.sleep(4)
            map = browser.find_element(By.XPATH ,("//label[@for='all']"));
            time.sleep(1)
            ActionChains(browser)\
                .click(map)\
                .perform()
            time.sleep(5)
            soup_in = bs(browser.page_source, 'html.parser')
            browser.close()
            brand_mark_s = soup_in.find('div', {'class': 'condo-marker-s'})
            brand_near_s = soup_in.find('div', {'class': 'poi-overlay-marker-s'})
            brand_mark_l = soup_in.find('div', {'class': 'condo-marker-l'})
            brand_near_l = soup_in.find('div', {'class': 'poi-overlay-marker-l'})
            if brand_mark_s:
                mark_dict['condo_mark_s'] = 1
            if brand_near_s:
                mark_dict['near_mark_s'] = 1
            if brand_mark_l:
                mark_dict['condo_mark_l'] = 1
            if brand_near_l:
                mark_dict['near_mark_l'] = 1
            mark_list.append(mark_dict)

mark_df = pd.DataFrame(mark_list)
mark_df.to_csv('mark.csv')         
print("done")
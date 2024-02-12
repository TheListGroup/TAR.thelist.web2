from selenium import webdriver
import time
from bs4 import BeautifulSoup as bs
import pandas as pd

def open_browser():
    browser = webdriver.Chrome()  
    browser.maximize_window()
    browser.get("https://www.ddproperty.com/โครงการ-คอนโด/ค้นหาคอนโด/")
    #browser.refresh()
    time.sleep(3)

    soup = bs(browser.page_source, 'html.parser')
    page = soup.find('ul', {'class': 'pagination'})
    for i, last_page in enumerate(page.find_all('li')):
        if i == 4:
            page = last_page.text.strip()
            break
    page = int(page)

    def get_link():
        content = soup.find('div', {'class': 'listing-widget-new'})
        for i, lists in enumerate(content.find_all('div', class_=lambda x: x and x.startswith('listing-card'))):
            condo = False
            link = lists.find('h3')
            link = link.find('a')
            link = link.get('href')
            link = 'https://www.ddproperty.com/' + link
            for j, all_tag in enumerate(lists.find_all('li')):
                tag = all_tag.text.strip()
                if 'คอนโด' in tag:
                    condo = True
                    link_dict = {'LINK': link}
                    link_list.append(link_dict)
                    break
            if not condo:
                pass
        browser.close()

    x = 1
    while x <= page :
        if x == 1:
            get_link()
        else:
            browser = webdriver.Chrome()  
            browser.maximize_window()
            browser.get(f"https://www.ddproperty.com/โครงการ-คอนโด/ค้นหาคอนโด/{x}")
            #browser.refresh()
            time.sleep(3)
            soup = bs(browser.page_source, 'html.parser')
            get_link()
        print(f"PAGE {x}")
        x += 1
        if x > page: 
            break


link_list = []
file_name = "D:\PYTHON\TAR.thelist.web-2\dd\dd_link.csv"

open_browser()

link_df = pd.DataFrame(link_list)
link_df.to_csv(file_name, encoding='utf-8')
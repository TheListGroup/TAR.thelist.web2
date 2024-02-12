from selenium import webdriver
from bs4 import BeautifulSoup as bs
import pandas as pd
import time
from selenium.webdriver.common.by import By
def link():

    url = "https://thelist.group/realist/condo/"
    #url ='http://159.223.51.33:8080/realist/condo/'

    condo_list=[]

    browser = webdriver.Chrome()
    browser.get("http://google.com")
    browser.get(url)
    browser.maximize_window()
    time.sleep(2)

    soup = bs(browser.page_source, 'html.parser')
    browser.close()
    province = soup.find('div', {'id': 'top-place'})
    province = province.find('div', {'class': 'col-2'})
    for i, list in enumerate(province.find_all('a')):
        province_name = list.text.strip()
        province_link = list.get('href')
        urls = ("http://thelist.group",province_link)
    #    urls = ("http://159.223.51.33",province_link)
        urls = "".join(urls)
        print(f"{province_name} === {urls}")
        
        browser = webdriver.Chrome()
        browser.get(urls)
        browser.maximize_window()
        #browser.execute_script("window.scrollTo(0, 900)")
        browser.execute_script("window.scrollTo(0, 650)")
        time.sleep(2)
        map = browser.find_element(By.XPATH ,("//label[@for='all']"));
        map.click()
        time.sleep(2)

        soup_in = bs(browser.page_source, 'html.parser')
        browser.close()
        condo = soup_in.find('div', {'id': 'intial-condo-list'})
        for l, list_condo in enumerate(condo.find_all('div', {'style': "padding-top: 4px; padding-bottom: 4px; width: 100%;"})):
            link = list_condo.find('div',{'class':"col pl-0 show-single-line condo-list-name font-weight-bold"})
            link_in = link.get('onclick')
            name = link.get('title')
            name = name.replace("null","")
            name = name.strip()
            link = link_in.replace("gotoCondo","")
            link = link.replace('"',"")
            link = link.replace('"',"")
            link = link[1:-1]
            urls_in = ("https://thelist.group/realist/condo/proj/",link)
    #        urls_in = ("http://159.223.51.33:8080/realist/condo/proj/",link)
            urls_in = "".join(urls_in)
            code = link.split("-")
            code = code[-1]
            print(f"{l}--{code}--{name}--{urls_in}")
            condo_dict = {'code': code, 'condo name': name, 'link': urls_in}
            condo_list.append(condo_dict)
    condo_df = pd.DataFrame(condo_list)
    condo_df.to_csv('realist_link.csv')
    print('link done')
link()
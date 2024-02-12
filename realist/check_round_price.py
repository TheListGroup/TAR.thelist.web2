from selenium import webdriver
from bs4 import BeautifulSoup as bs
import time
from selenium.webdriver.common.by import By
import pandas as pd

urls ='http://159.223.51.33/realist/condo/'

test_list = []
check_list = []
result_list = []
price_list = []

def open():
    browser.get(urls)
    browser.maximize_window()
    time.sleep(2)
    browser.refresh()
    time.sleep(2)

browser = webdriver.Chrome()
open()

browser.execute_script("window.scrollTo(0, 10400)")
map = browser.find_element(By.XPATH ,("//label[@for='all']"))
map.click()
time.sleep(2)
soup = bs(browser.page_source, 'html.parser')

condo_list = soup.find('div' ,{'id':"intial-condo-list"})
if condo_list:
    for i , condo in enumerate(condo_list.find_all('div' ,{'class':"container lazyload-div"})):
        info = condo.find('div' ,{'class':"container"})
        if info:
            price = info.find('span')
            price = price.text.strip()
            if price[-3:] == '000' or price == "N/A":
                check_dict = {'check' : 1}
            else:
                check_dict = {'check' : "NOT"}
            check_list.append(check_dict)
    if "NOT" in check_list:
        result_list.append("home -- found_error")
    else:
        result_list.append("home -- ok")
else:
    result_list.append("home -- error")
    
browser.close()
template_list = []
top_condo = soup.find('div', {'id': 'toptabContent'})
if top_condo:
    for i , condo_template_link in enumerate(top_condo.find_all('div' ,{'class':"py-1"})) :
        if i in range (0,54):
            condo_link = condo_template_link.find('a')
            condo_link = condo_link.get('href')
            condo_link = ("http://159.223.51.33",condo_link)
            urls = "".join(condo_link)

            browser = webdriver.Chrome()
            open()
            soup_in = bs(browser.page_source, 'html.parser')
            check_finished = soup_in.find('div' ,{'class':"col-12 col-lg-6 d-none d-lg-block align-self-center pr-0"})
            if check_finished:
                map = browser.find_element(By.XPATH ,("//label[@for='all']"))
                map.click()
                time.sleep(2)
                soup_template = bs(browser.page_source, 'html.parser')
                browser.close()
                condo_list = soup_template.find('div' ,{'id':"intial-condo-list"})
                if condo_list:
                    for b , condo in enumerate(condo_list.find_all('div' ,{'style':" padding-top: 4px; padding-bottom: 4px; width: 100%;"})):
                        info = condo.find('div' ,{'class':"container"})
                        if info:
                            price = info.find('span')
                            price = price.text.strip()
                            if price[-3:] == '000' or price == "N/A":
                                template_dict = {'check' : 1}
                            else:
                                template_dict = {'check' : "NOT"}
                            template_list.append(template_dict)
            else:
                template_dict = {'check' : 1}
                template_list.append(template_dict)
    if "NOT" in template_list:
        result_list.append("template -- found_error")
    else:
        result_list.append("template -- ok")
else:
    result_list.append("template -- error")
    
#listing_all = soup.find('div' ,{'id':"toptabContent"})
listing_list = []
place = soup.find('div' ,{'id':"top-place"}) ##
#if listing_all:
#    for i , listing in enumerate(listing_all.find_all('div' ,{'class':"tab-pane fade"})):
if place: ##
    provice = place.find('div' ,{'class':"col-2"})  ##
    for i , each_listing in enumerate(provice.find_all('div' ,{'class':"py-1"})): ##
#        for j , each_listing in enumerate(listing.find_all('div' ,{'class':"py-1"})):
            listing_link = each_listing.find('a')
            if listing_link:
                listing_link = listing_link.get('href')
                listing_link = ("http://159.223.51.33",listing_link)
                urls = "".join(listing_link)

                browser = webdriver.Chrome()            
                open()
                soup_in = bs(browser.page_source, 'html.parser')
                check_finished = soup_in.find('div' ,{'class':"col-12 col-lg-6 d-none d-lg-block align-self-center pr-0"})
                if check_finished:
                    map = browser.find_element(By.XPATH ,("//label[@for='all']"))
                    map.click()
                    time.sleep(2)
                    soup_listing = bs(browser.page_source, 'html.parser')
                    browser.close()
                    condo_list = soup_listing.find('div' ,{'id':"intial-condo-list"})
                    if condo_list:
                        for a , each_list in enumerate(condo_list.find_all('div' ,{'style':"padding-top: 4px; padding-bottom: 4px; width: 100%;"})):
                            info = each_list.find('div' ,{'class':"container"})
                            if info:
                                price = info.find('span')
                                price = price.text.strip()
                                if price[-3:] == '000' or price == "N/A":
                                    listing_dict = {'check' : 1}
                                else:
                                    listing_dict = {'check' : "NOT"}
                                listing_list.append(listing_dict)
                                condo = info.find('div' ,{'class':"col pl-0 show-single-line condo-list-name font-weight-bold"})
                                condo_name = condo.text.strip()
                                link = condo.get('onclick')
                                link = link.replace("gotoCondo","")
                                link = link.replace('"',"")
                                link = link.replace('"',"")
                                link = link[1:-1]
                                link = ("http://159.223.51.33/realist/condo/proj/",link)
                                link = "".join(link)
                                code = link.split("-")
                                code = code[-1]
                                price_dict = {"CODE" : code, "CONDO_NAME" : condo_name, "PRICE" : price, "LINK" : link}
                                price_list.append(price_dict)
                else:
                    listing_dict = {'check' : 1}
                    listing_list.append(listing_dict)
        
#        if i == 2:
#            for k , station in  enumerate(listing.find_all('div' ,{'class':"py-0"})):
#                listing_link = station.find('a')
#                listing_link = listing_link.get('href')
#                listing_link = ("http://159.223.51.33",listing_link)
#                urls = "".join(listing_link)
                
#                browser = webdriver.Chrome()            
#                open()
#                soup_in = bs(browser.page_source, 'html.parser')
#                check_finished = soup_in.find('div' ,{'class':"col-12 col-lg-6 d-none d-lg-block align-self-center pr-0"})
#                if check_finished:
#                    map = browser.find_element(By.XPATH ,("//label[@for='all']"))
#                    map.click()
#                    time.sleep(2)
#                    soup_listing = bs(browser.page_source, 'html.parser')
#                    browser.close()
#                    condo_list = soup_listing.find('div' ,{'id':"intial-condo-list"})
#                    if condo_list:
#                        for a , each_list in enumerate(condo_list.find_all('div' ,{'style':"padding-top: 4px; padding-bottom: 4px; width: 100%;"})):
#                            info = condo.find('div' ,{'class':"container"})
#                            if info:
#                                price = info.find('span')
#                                price = price.text.strip()
#                                if price[-3:] == '000' or price == "N/A":
#                                    listing_dict = {'check' : 1}
#                                else:
#                                    listing_dict = {'check' : "NOT"}
#                                listing_list.append(listing_dict)
#                else:
#                    listing_dict = {'check' : 1}
#                    listing_list.append(listing_dict)
    if "NOT" in listing_list:
        result_list.append("listing -- found_error")
    else:
        result_list.append("listing -- ok")
else:
    result_list.append("listing -- error")
print(result_list)
price_df = pd.DataFrame(price_list)
price_df.to_csv('check_price_sqm.csv')
print('done')
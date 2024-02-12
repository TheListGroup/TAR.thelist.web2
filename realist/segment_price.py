from selenium import webdriver
from bs4 import BeautifulSoup as bs
import time
from selenium.webdriver.common.by import By
import pandas as pd

url = 'http://159.223.51.33:8080/realist/condo/'

browser = webdriver.Chrome()
browser.maximize_window()
browser.get("http://google.com")
browser.get(url)

soup = bs(browser.page_source, 'html.parser')
browser.close()

price_list = soup.find('div' ,{'id':"top-price"})
if price_list:
    segment_list = price_list.find('div' ,{'class':"row m-0"})
    for i , segment in enumerate(segment_list.find_all('div' ,{'class':"col-6 pl-0 menu-content"})):
        link_list = segment.find('a')
        if link_list:
            listing_link = listing_link.get('href')
            listing_link = ("http://159.223.51.33:8080",listing_link)
            urls = "".join(listing_link)
            
            browser = webdriver.Chrome()
            browser.maximize_window()
            browser.get("http://google.com")
            browser.get(url)
            soup_in = bs(browser.page_source, 'html.parser')
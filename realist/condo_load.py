from selenium import webdriver
from bs4 import BeautifulSoup as bs
import pandas as pd
import re
from selenium.webdriver.chrome.options import Options
import time
urls = pd.read_csv("realist_link.csv")
check_list = []

prv_condo = pd.read_csv("condo_load2.csv")
for ind in prv_condo.index:
    check_dict = prv_condo.iloc[ind].to_dict()
    check_list.append(check_dict)
ind = len(check_list)-1
no = len(urls.index)
while ind in urls.index:
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--window-size=1920x1080")
    browser = webdriver.Chrome(options=chrome_options)
    url = urls.iloc[ind][2]
    start_time = time.time()
    browser.get(url)
    end_time = time.time()
    load_time = end_time - start_time
    code = url.split("-")
    code = code[-1]
    code = code.replace("/","")
    print(f"{ind} : {code} : {url}")
    soup = bs(browser.page_source, 'html.parser')
    condo_name = soup.find('title')
    condo_name_eng = condo_name.text.strip()
    condo_name_eng = re.sub(r"\([^()]*\)", "", condo_name_eng)
    condo_name_eng = condo_name_eng.replace("REALIST","")
    condo_name_eng = condo_name_eng.replace("|","")
    condo_name_eng = condo_name_eng.strip()
    if condo_name:
        check_dict = {"Condo_Code" : code, 'Condo_ENName': condo_name_eng, 'url': url, 'run' : load_time}
    footer = soup.find('div', {'class': 'row align-items-center justify-content-end'})
    if footer:
        check_dict['load'] = 1
    else:
        check_dict['load'] = 'unload'
    if ind == 400:
        break
    ind += 1
    check_list.append(check_dict)
    data_info_df = pd.DataFrame(check_list)
    data_info_df.to_csv('condo_load2.csv')
print('done')
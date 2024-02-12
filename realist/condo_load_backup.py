from selenium import webdriver
from bs4 import BeautifulSoup as bs
import pandas as pd
import re
from selenium.webdriver.chrome.options import Options
import time
check_list = []
urls = 'https://thelist.group/realist/condo/proj/Cloud-Residences-Skv23-CD2511/'
chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--window-size=1920x1080")
browser = webdriver.Chrome(options=chrome_options)
browser.get(urls)
browser.refresh()
time.sleep(2)
soup = bs(browser.page_source, 'html.parser')
code = urls.split("-")
code = code [-1]
code = code.replace("/","")
code = code.strip()
condo_name = soup.find('title')
condo_name_eng = condo_name.text.strip()
condo_name_eng = re.sub(r"\([^()]*\)", "", condo_name_eng)
condo_name_eng = condo_name_eng.replace("REALIST","")
condo_name_eng = condo_name_eng.replace("|","")
condo_name_eng = condo_name_eng.strip()
urls_in = soup.find('link',{'rel':"canonical"})
urls_in = urls_in.get('href')
if condo_name:
    check_dict = {"Condo_Code" : "BACKUP", 'Condo_ENName': "BACKUP", 'url': urls_in}
    
footer = soup.find('div', {'class': 'row align-items-center justify-content-end'})
if footer:
    check_dict['load'] = 1
else:
    check_dict['load'] = 'unload'
check_list.append(check_dict)
data_info_df = pd.DataFrame(check_list)
data_info_df.to_csv('condo_load2.csv')
print('done')
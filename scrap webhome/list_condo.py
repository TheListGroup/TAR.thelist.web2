from selenium import webdriver
import time
from bs4 import BeautifulSoup as bs
import pandas as pd

data_list = []
link_file = r"C:\PYTHON\TAR.thelist.web2\scrap webhome\condo_link.csv"
file_name = r"C:\PYTHON\TAR.thelist.web2\scrap webhome\list_condo.csv"

data = pd.read_csv(link_file, encoding='utf-8')
try:
    prv_link = pd.read_csv(file_name)
    for ind in prv_link.index:
        data_dict = prv_link.iloc[ind].to_dict()
        data_list.append(data_dict)
    ind = len(data_list)
except:
    ind = 0
browser = webdriver.Chrome()  
browser.maximize_window()

while ind in range(data.index.size):
    url = data.iloc[ind, 1]
    browser.execute_script(f"window.open('{url}', '_blank');")
    browser.switch_to.window(browser.window_handles[-1])
    browser.refresh()
    time.sleep(3)
    
    soup_condo = bs(browser.page_source, 'html.parser')
    name_section = soup_condo.find('div', {'class': 'sc-qy3aqj-13 hqrLJw w-full'})
    name_th = name_section.find('h1').text.strip()
    name_eng = name_section.find('div', {'class': 'title-eng'}).text.strip()
    date_update = name_section.find('div', {'class': 'title-update-date'}).text.strip()
    condo_url = browser.current_url
    condo_id = condo_url.split("/")[-1].split("-")[-1]
    coordinate = soup_condo.find('a', {'class': 'map-button'})
    coordinate = coordinate.get("href").split("/")[-2]
    lat = coordinate.split(",")[0]
    long = coordinate.split(",")[1]
    data_dict = {'Condo_ID': condo_id, 'Date_Update': date_update, 'Name_TH': name_th, 'Name_Eng': name_eng, 'Condo_URL': condo_url, 'Latitude': lat, 'Longitude':long}
    data_list.append(data_dict)
    browser.close()
    browser.switch_to.window(browser.window_handles[0])

    link_df = pd.DataFrame(data_list)
    link_df.to_csv(file_name, encoding='utf-8')
    print(f"Link {ind+1} Done")
    ind += 1
print("DONE")
from selenium import webdriver
import time
from bs4 import BeautifulSoup as bs
import pandas as pd
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
import json
from datetime import datetime
import pandas as pd
import re

def scrap_data(browser):
    soup = bs(browser.page_source, 'html.parser')
    classified_list = soup.find('ul', {'class': 'sc-1a1poy3-0 ebxoTx'})
    condo = classified_list.find_all('li', {'class': 'sc-15whpuu-1 eYvSuW'})
    if not condo:
        condo = classified_list.find_all('li', {'class': 'sc-15whpuu-1 hinqYl'})
    for data in condo:
        data_condo = data.find('div', {'class': 'sc-15whpuu-2 cuLCdX'})
        get_link = data_condo.find('div', {'class': 'sc-15whpuu-5 gcrHzr'})
        link = get_link.find('a')
        link = link.get('href')
        link = re.sub('เช่า','ขาย',link)
        if link not in project_list:
            project_list.append(link)
            browser.execute_script(f"window.open('{link}', '_blank');")
            browser.switch_to.window(browser.window_handles[-1])
            soup_in = bs(browser.page_source, 'html.parser')
            try:
                json_data = soup_in.find('script', {'id': '__NEXT_DATA__'})
                json_text = json_data.text.strip()
                data = json.loads(json_text)
                condo_id = data["props"]["pageProps"]["project"]["id"]
                condo_name = data["props"]["pageProps"]["project"]["name"]
                condo_enname = data["props"]["pageProps"]["project"]["nameEnglish"]
                condo_lat = data["props"]["pageProps"]["project"]["location"]["lat"]
                condo_long = data["props"]["pageProps"]["project"]["location"]["lng"]
                parsed_date = datetime.strptime(data["props"]["pageProps"]["project"]["updatedAt"], "%Y-%m-%dT%H:%M:%S.%fZ")
                update_date = parsed_date.strftime("%Y-%m-%d %H:%M:%S")
                room_count = data["props"]["pageProps"]["listings"]["pagination"]["totalCount"]
                condo_date = data["props"]["pageProps"]["project"]["projectInfo"]["completedYear"]
                data_dict = {'Condo_ID': condo_id, 'Date_Update': update_date, 'Name_TH': condo_name, 'Name_Eng': condo_enname, 'Condo_URL': link, 'Latitude': condo_lat, 'Longitude': condo_long, 'Room_Count': room_count, 'Finished_Date': condo_date}
                data_list.append(data_dict)
            except:
                print(link)
                error_list.append(link)
            browser.close()
            time.sleep(2)
            browser.switch_to.window(browser.window_handles[0])

def open_browser():
    browser = webdriver.Chrome()  
    browser.maximize_window()
    browser.get("https://propertyhub.in.th/เช่าคอนโด")
    browser.refresh()
    time.sleep(3)

    element = browser.find_element(By.XPATH ,("//ul[@class='sc-sp6oqm-0 jYFgje']"))
    total_page = element.find_elements(By.TAG_NAME, "li")
    max_page = int(total_page[-2].text.strip())
    click_next_page = total_page[-1]

    page = 0
    while page < max_page:
        scrap_data(browser)
        actions = ActionChains(browser)
        actions.move_to_element(click_next_page).perform()
        click_next_page.click()
        time.sleep(3)
        page += 1
        print(f'Page {page} OF {max_page}')
    browser.close()

data_list = []
error_list = []
file_name = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\propertyhub\condo_link2.csv"


try:
    sale_link = pd.read_csv(r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\propertyhub\condo_link.csv", encoding='utf-8')
    project_list = sale_link.iloc[:, 4].tolist()
except:
    project_list = []

open_browser()
print(error_list)

link_df = pd.DataFrame(data_list)
link_df.to_csv(file_name, encoding='utf-8')
print("DONE")
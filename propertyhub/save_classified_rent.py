import pandas as pd
import re
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains
import time
from bs4 import BeautifulSoup as bs
import json
from datetime import datetime

all_link = pd.read_csv(r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\propertyhub\all_link.csv", encoding='utf-8')
save_file = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\propertyhub\classified_all_rent.csv"
error_file = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\propertyhub\error.csv"
resume = True
data_list = []
error_list = []
try:
    prv_link = pd.read_csv(save_file, encoding='utf-8')
    proj_check = set(prv_link['Project_ID'])
    classified_id_check = set(prv_link['Classified_ID'])
    data_list = prv_link.to_dict(orient='records')
    ind = len(proj_check) - 1
    
    seen = set()
    unique_list = []
    for d in data_list:
        key = (d['Project_ID'], d['Classified_ID'])
        if key not in seen:
            seen.add(key)
            unique_list.append(d)
    link_df = pd.DataFrame(unique_list)
    link_df.to_csv(save_file, encoding='utf-8')
except:
    ind = 0

def new_tab(url):
    browser.execute_script(f"window.open('{url}', '_blank');")
    browser.switch_to.window(browser.window_handles[-1])

def scrap_data():
    classified_link = classified_check.find("a").get("href")
    id_check = int(classified_link.split("---")[-1])
    if id_check not in classified_id_check:
        new_tab(classified_link)
        time.sleep(2)
        soup_classified_in = bs(browser.page_source, 'html.parser')
        if 'listings' in browser.current_url:
            try:
                about_section = soup_classified_in.find('div', {'class': 'sc-rqf8dv-2 gHVmth'})
                classified_id = about_section.find('p', {'class': 'sc-rqf8dv-12 klYNRA'}).text.strip()
                clasified_date_field = about_section.find('p', {'class': 'sc-rqf8dv-9 dmgffO'}).text.strip()
                classified_date = clasified_date_field.split(' ')[0].split('/')[-1]+ '-' + clasified_date_field.split(' ')[0].split('/')[1] + '-' \
                                + clasified_date_field.split(' ')[0].split('/')[0] + ' ' + clasified_date_field.split(' ')[-1]
                
                sale, rent, classified_price_rent = 0, 0, None
                classified_price_sale, classified_size_value, bedroom_value, bathroom_value = None, None, None, None
                classified_data = soup_classified_in.find('ul', {'class': 'sc-ejnaz6-2 fuLHNZ'})
                for x, each_data in enumerate(classified_data.find_all('li')):
                    try:
                        section = each_data.find('label').text.strip()
                    except:
                        section = ''
                    if section == 'ราคา':
                        try:
                            classified_price_rent = int(re.findall(r'\d+', re.sub(',', '', each_data.find('span', {'class': 'rent-price'}).text))[0])
                            rent = 1
                        except:
                            classified_price_rent = None
                    elif section == 'ขนาดพื้นที่ห้อง':
                        try:
                            classified_size_value = "{:.1f}".format(float(re.sub('ตร.ม.', '', each_data.find('span').text).strip()))
                        except:
                            classified_size_value = None
                    elif section == 'จำนวนห้องนอน':
                        try:
                            bedroom_value = int(re.sub('ห้องนอน', '', each_data.find('span').text).strip())
                        except:
                            bedroom_value = None
                    elif section == 'จำนวนห้องน้ำ':
                        try:
                            bathroom_value = int(re.sub('ห้องน้ำ', '', each_data.find('span').text).strip())
                        except:
                            bathroom_value = None
                data_dict = {'Project_ID': code, 'Classified_ID': classified_id, 'Sale': sale, 'Rent': rent, 'Price_Sale': classified_price_sale
                            , 'Price_Rent': classified_price_rent, 'Bedroom': bedroom_value, 'Bathroom': bathroom_value, 'Size': classified_size_value, 'Date': classified_date}
                data_list.append(data_dict)
                save_csv()
            except:
                error_dict = {'Project_ID': code, 'Link': classified_link, 'Reason': "Data Happen"}
                error_list.append(error_dict)
                save_error()
        elif browser.current_url == 'https://propertyhub.in.th/':   ###
            error_dict = {'Project_ID': code, 'Link': classified_link, 'Reason': "Home Link"}
            error_list.append(error_dict)
            save_error()
        browser.close()
        browser.switch_to.window(browser.window_handles[-1])

def save_csv():
    link_df = pd.DataFrame(data_list)
    link_df.to_csv(save_file, encoding='utf-8')

def save_error():
    error_df = pd.DataFrame(error_list)
    error_df.to_csv(error_file, encoding='utf-8')

browser = webdriver.Chrome()  
browser.maximize_window()

while ind in range(all_link.index.size):
    code = int(all_link.iloc[ind, 0])
    update_date = all_link.iloc[ind, 1]
    link = re.sub('ขาย','เช่า',all_link.iloc[ind, 4])
    browser.execute_script(f"window.open('{link}', '_blank');")
    browser.switch_to.window(browser.window_handles[-1])
    time.sleep(2)
    try:
        classified_page = browser.find_element(By.XPATH ,("//ul[@class='sc-1p20b44-0 IoRRS']"))
        total_page = classified_page.find_elements(By.TAG_NAME, "li")
        max_page = int(total_page[-2].text.strip())
        click_next_page = total_page[-1]
    except:
        max_page = 1
    
    page = 0
    while page < max_page:
        soup = bs(browser.page_source, 'html.parser')
        classified_section = soup.find('div', {'class': 'sc-m8nysy-4 sc-m8nysy-5 gZMuCg'})
        if classified_section:
            if page < 1 and not resume:
                json_data = soup.find('script', {'id': '__NEXT_DATA__'})
                json_text = json_data.text.strip()
                data = json.loads(json_text)
                all_classified = data["props"]["pageProps"]["listings"]["listings"]
                for classified in all_classified:
                    classified_id = classified['id']
                    sale, rent, classified_price_sale = 0, 0, None
                    classified_price_rent, classified_size_value, bedroom_value, bathroom_value = None, None, None, None
                    parsed_date = datetime.strptime(classified['updatedAt'], "%Y-%m-%dT%H:%M:%S.%fZ")
                    classified_date = parsed_date.strftime("%Y-%m-%d %H:%M:%S")
                    try:
                        classified_price_rent = int(classified['price']['forRent']['monthly']['price'])
                        rent = 1
                    except:
                        classified_price_rent = None
                    try:
                        bedroom_value = int(classified['roomInformation']['numberOfBed'])
                    except:
                        bedroom_value = None
                    try:
                        bathroom_value = int(classified['roomInformation']['numberOfBath'])
                    except:
                        bathroom_value = None
                    try:
                        classified_size_value = "{:.1f}".format(float(classified['roomInformation']['roomArea']))
                    except:
                        classified_size_value = None
                    data_dict = {'Project_ID': code, 'Classified_ID': classified_id, 'Sale': sale, 'Rent': rent, 'Price_Sale': classified_price_sale
                    , 'Price_Rent': classified_price_rent, 'Bedroom': bedroom_value, 'Bathroom': bathroom_value, 'Size': classified_size_value, 'Date': classified_date}
                    data_list.append(data_dict)
                save_csv()
            else:
                for classified_check in classified_section.find_all('div', {'class': 'sc-152o12i-0 tLuGm sc-i5hg7z-1 iokjfP'}):
                    scrap_data()
                for classified_check in classified_section.find_all('div', {'class': 'sc-152o12i-0 tLuGm sc-i5hg7z-1 hwrlNi'}):
                    scrap_data()
        else:
            data_dict = {'Project_ID': code, 'Classified_ID': None, 'Sale': None, 'Rent': None, 'Price_Sale': None
                , 'Price_Rent': None, 'Bedroom': None, 'Bathroom': None, 'Size': None, 'Date': None}
            data_list.append(data_dict)
            save_csv()
        if max_page > 1:
            actions = ActionChains(browser)
            actions.move_to_element(click_next_page).perform()
            click_next_page.click()
            time.sleep(3)
        page += 1
    browser.close()
    browser.switch_to.window(browser.window_handles[0])
    time.sleep(2)
    
    ind += 1
    print(f'Link {ind} of {all_link.index.size}')
    resume = False
print("DONE")
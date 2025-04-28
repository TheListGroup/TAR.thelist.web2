from selenium import webdriver
import time
from bs4 import BeautifulSoup as bs
import pandas as pd
import re
from selenium.webdriver.common.by import By

file = pd.read_excel(r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield\Plus\plus.xlsx")
save_file = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield\Plus\plus_data.csv"
data_list = []

browser = webdriver.Chrome()  
browser.maximize_window()

for i in range(file.index.size):
    excel_data = 0
    image_list = []
    condo_code = file.iloc[i, 12]
    proj_id = file.iloc[i, 13]
    if str(condo_code) != '0':
        code = file.iloc[i, 0]
        print(code)
        link = "https://www.plus.co.th/unit/xxx/" + code
        browser.execute_script(f"window.open('{link}', '_blank');")
        browser.switch_to.window(browser.window_handles[-1])
        time.sleep(5)
        soup = bs(browser.page_source, 'html.parser')
        detail = soup.find('section', {'id': 'detail'})
        price = detail.find('div', {'class': 'item'}).text.strip()
        if "-" not in price:
            try:
                price = int(re.sub("(ซื้อ : ฿|,)", '', price))
            except:
                price = int(re.sub(",", '', file.iloc[i, 8]))
                excel_data = 1
            try:
                title = detail.find('h1', {'class': 'unit-title text-primary'}).text.strip()
            except:
                title = None
            try:    
                description = detail.find('div', {'class': 'unit-description'}).text.strip()
            except:
                description = None
            room_detail = detail.find('div', {'class': 'row detail-facility-wrapper'})
            for x, data in enumerate(room_detail.find_all('div', {'class': 'facility-item detail-item'})):
                if x == 0:
                    try:
                        bedroom = int(data.find('div', {'class': 'facility-number'}).text.strip())
                    except:
                        bedroom = int(file.iloc[i, 5])
                        excel_data = 1
                else:
                    try:
                        bathroom = int(data.find('div', {'class': 'facility-number'}).text.strip())
                    except:
                        bathroom = int(file.iloc[i, 6])
                        excel_data = 1
            try:
                room_size = re.sub("ตร.ม.", '',room_detail.find('div', {'class': 'detail-item area-item'}).text).strip()
            except:
                room_size = file.iloc[i, 3]
                excel_data = 1
            
            image_open = browser.find_element(By.XPATH, "//span[@class='text' and @data-v-ad5e81c8]")
            image_open.click()
            time.sleep(2)
            soup_image = bs(browser.page_source, 'html.parser')
            image_section = soup_image.find('div', {'class': 'vue-lb-container'})
            image_lists = image_section.find('div', {'class': 'vue-lb-thumbnail'})
            for j, image in enumerate(image_lists.find_all('div', class_=lambda x: x and 'vue-lb-modal-thumbnail' in x)):
                image_url = image['data-src']
                image_list.append(image_url)
            
            data_dict = {'Prop_ID': code, 'Project_ID': proj_id, 'Title': title, 'Condo_Code': condo_code, 'Sale': 1, 'Rent': 0, 'Price': price, 'Bedroom': bedroom
                        , 'Bathroom': bathroom, 'Size': room_size, 'Description': description, 'Image_Urls': image_list, 'Excel': excel_data}
            data_list.append(data_dict)
            
        browser.close()
        browser.switch_to.window(browser.window_handles[0])
browser.close()

link_df = pd.DataFrame(data_list)
link_df.to_csv(save_file, encoding='utf-8')
print('Done')
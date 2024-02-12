from selenium import webdriver
from bs4 import BeautifulSoup as bs
import time
from selenium.webdriver.common.by import By
from collections import Counter
import pandas as pd
from selenium.webdriver.common.action_chains import ActionChains
import math

url ='https://assessprice.treasury.go.th/'
scrab_list = []
prv_condo = pd.read_csv("condo_from_thanarak_Samut-Sakorn.csv")
for ind in prv_condo.index:
    scrab_dict = prv_condo.iloc[ind].to_dict()
    scrab_list.append(scrab_dict)
browser = webdriver.Chrome()
browser.maximize_window()
browser.get("http://google.com")
browser.get(url)
time.sleep(3)
browser.refresh()
time.sleep(5)
element = browser.find_element(By.XPATH ,("//div[@class='amos-dialog-toolbar amos-dialog-icon-close amos-icon-x']"))
onscreen = element.is_displayed();
if onscreen:
    element.click()
    time.sleep(3)
element = browser.find_element(By.XPATH ,("//button[@class='dropbtn GIS5-WF05']"))
element.click()
time.sleep(3)
element = browser.find_element(By.XPATH ,("//div[@data-dojo-attach-point='rightIconContainer']"))
element.click()
time.sleep(3)
element = browser.find_element(By.XPATH ,("//li[@data-amos-prop-displayed-value='สมุทรสาคร']"))
element.click()
time.sleep(3)
element = browser.find_element(By.XPATH ,("//div[@class='amos-button-container']"))
element.click()
time.sleep(3)
element = browser.find_element(By.XPATH ,("//div[@class='cookie-policy_accept']"))
element.click()
time.sleep(3)
soup = bs(browser.page_source, 'html.parser')
for p , page in enumerate(soup.find_all('span', {'class': 'page-number page-disabled'})):
    if p == 3:
        page = page.text.strip()
        page = int(page)
num_condo = prv_condo['CONDO NUMBER'].max() ###
num_page = math.ceil(num_condo/20) ###
n = 1 #change page
while n < num_page:
    w = 1 #while loop when long load
    while w <= 10:
        try:
            change_page = browser.find_element(By.XPATH ,("//span[@class='amos-icon-angle-right']"))
            change_page.click()
            break
        except:
            time.sleep(60)
            w+=1
    time.sleep(3)
    n+=1
i = num_page
x = num_condo+1 #condo_number
y = num_condo%20 #condo_continue
z = 1
header = ["BUILDING","FLOOR","PRICE","TYPE","ROOM NUMBER"]
while i <= page:
    condo = browser.find_elements(By.XPATH ,("//div[@class='divCollapes']"))
    element_counts = Counter(condo)
    for element, count in element_counts.items():
        element.click()
        time.sleep(1)
    time.sleep(8)
    info = browser.find_elements(By.XPATH ,("//div[@title='w3c']"))
    info_counts = Counter(info)
    for paper, count in info_counts.items():
        if z > y :
            paper.click()
            browser.switch_to.window(browser.window_handles[-1])
            time.sleep(5)
            w = 1 #while loop when long load
            while w <= 10:
                soup_in = bs(browser.page_source, 'html.parser')
                check = soup_in.find('thead', {'class': 'zone-header'})
                if check:
                    break
                else:
                    browser.refresh()
                    time.sleep(30)
                    w+=1
            try:
                soup_in = bs(browser.page_source, 'html.parser')
                date = soup_in.find('span', {'name': 'ENFORCEMENT_DATE'})
                date = date.text.strip() ##
                name = soup_in.find('div', {'name': 'CONDO_NAME'})
                name = name.text.strip() ##
                road = soup_in.find('div', {'name': 'CONDO_ROAD'})
                road = road.text.strip() ##
                subdistrict = soup_in.find('div', {'name': 'TUMB_NAME'})
                subdistrict = subdistrict.text.strip() ##
                district = soup_in.find('div', {'name': 'AMPH_NAME'})
                district = district.text.strip() ##
                province = soup_in.find('div', {'name': 'PROV_NAME'})
                province = province.text.strip() ##
                browser.close()
                browser.switch_to.window(browser.window_handles[0])
                use_long = ''  ##
                use_lat = ''   ##
                map = browser.find_element(By.ID ,("PARCEL_GRAPHIC_HILIGHT_layer"))
                onscreen = map.is_displayed();
                if onscreen:
                    actions = ActionChains(browser)
                    actions.move_to_element(map).perform()
                    soup_out = bs(browser.page_source, 'html.parser')
                    coordinates = soup_out.find('div', {'class': 'point-display'})
                    for l , lat_long in enumerate(coordinates.find_all('span', {'style': 'padding-left: 2px; width: 100px; display: inline-block;'})):
                        for c , num in enumerate(lat_long.find_all('span')):
                            if l == 0:
                                long = num.text.strip()
                                use_long = use_long+long
                            elif l == 1:
                                lat = num.text.strip()
                                use_lat = use_lat+lat
                data = soup_in.find('tbody', {'class': 'zone-data'})
                for j , row_data in enumerate(data.find_all('tr', {'class': 'row-data'})):
                    scrab_dict = {"CONDO NUMBER":x,"NAME":name,"DATE":date,"PROVINCE":province,"DISTRICT":district,"SUBDISTRICT":subdistrict,"ROAD":road,"LATITUDE":use_lat,"LONGTITUDE":use_long}
                    for k , data_in in enumerate(row_data.find_all('td')):
                        if k > 0:
                            section_data = data_in.text.strip()
                            scrab_dict[header[k-1]] = section_data
                    scrab_list.append(scrab_dict)
                x+=1
                z+=1
                scrab_df = pd.DataFrame(scrab_list)
                scrab_df.to_csv('condo_from_thanarak_Samut-Sakorn.csv')
            except:
                browser.close()
                browser.switch_to.window(browser.window_handles[0])
                x+=1
                z+=1
        else:
            z+=1
    if i < page:
        change_page = browser.find_element(By.XPATH ,("//span[@class='amos-icon-angle-right']"))
        change_page.click()
        time.sleep(3)
    i += 1
    if i > page:
        break
browser.close()
print('done')
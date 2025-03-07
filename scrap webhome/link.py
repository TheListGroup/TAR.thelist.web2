from selenium import webdriver
import time
from bs4 import BeautifulSoup as bs
import pandas as pd
from selenium.webdriver.common.by import By
from selenium.webdriver.common.action_chains import ActionChains

def scrap_data(browser):
    soup_in = bs(browser.page_source, 'html.parser')
    #ทำทีละคอนโด
    condos = soup_in.find_all('div', {'class': 'mb-4 col-xl-6 col-lg-6 col-md-6 col-sm-12 col-12'})
    for each_condo in condos:
        condo = each_condo.find('a')
        condo_link = condo.get('href')
        full_condo_link = 'https://www.home.co.th' + condo_link
        condo_id = full_condo_link.split("/")[-1].split("-")[-1]
        data_list.append((condo_id, full_condo_link))

def open_browser():
    browser = webdriver.Chrome()  
    browser.maximize_window()
    browser.get("https://www.home.co.th/area")
    browser.refresh()
    time.sleep(3)

    soup = bs(browser.page_source, 'html.parser')
    #เลือกทีละย่านจากหน้าย่านทั้งหมด
    district = 0
    big_area = soup.find_all('div', {'class': 'mb-3 mt-3 col-xl-12 col-lg-12 col-md-12 col-sm-12 col-12'})
    for medium_area in big_area[:7]:
        area_list = medium_area.find_all('div', {'class': 'mb-3 col-xl-6 col-lg-6 col-md-12 col-sm-12 col-12'})
        for use_area in area_list:
            area = use_area.find('a')
            link = area.get('href')
            link = 'https://www.home.co.th' + link
            browser.execute_script(f"window.open('{link}', '_blank');")
            
            #เลือกหมวดคอนโด
            browser.switch_to.window(browser.window_handles[-1])
            browser.execute_script("window.scrollBy(0, 300);")
            found = False
            icons = browser.find_elements(By.CLASS_NAME, 'hometype-icon-sum')
            soup_condo = bs(browser.page_source, 'html.parser')
            condo_check = soup_condo.find_all('div', {'class': 'hometype-icon-sum'})
            for j, icon in enumerate(icons):
                check = condo_check[j].find('div', {'class': 'text-project-type'})
                check = check.text.strip()
                if "คอนโดมิเนียม" in check:
                    icon.click()
                    found = True
                    break
            time.sleep(3)
            
            if found:
                #หาจำนวนหน้า
                element = browser.find_element(By.CLASS_NAME, "MuiPagination-ul")
                total_page = element.find_elements(By.TAG_NAME, "li")
                if len(total_page) > 3:
                    max_page = int(total_page[-2].text.strip())
                else:
                    max_page = 1
                click_next_page = total_page[-1]
            
                #ทำทีละหน้า
                page = 0
                while page < max_page:
                    scrap_data(browser)
                    actions = ActionChains(browser)
                    actions.move_to_element(click_next_page).perform()
                    browser.execute_script("window.scrollBy(0, 200);")
                    click_next_page.click()
                    time.sleep(3)
                    print(f"District {district+1} -- Page {page+1} Done")
                    page += 1
                browser.close()
                browser.switch_to.window(browser.window_handles[0])
                time.sleep(3)
            district += 1
    browser.close()

data_list = []
file_name = r"C:\PYTHON\TAR.thelist.web2\scrap webhome\condo_link.csv"

open_browser()

data_list = list(set(data_list))
link_df = pd.DataFrame(data_list)
link_df.to_csv(file_name, encoding='utf-8')
print("DONE")
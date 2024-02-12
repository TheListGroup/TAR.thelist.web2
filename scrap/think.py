from selenium import webdriver
import time
from selenium.webdriver.common.by import By
from collections import Counter

def prop_type(proptype):
    property_type = browser.find_element(By.XPATH ,("//input[@data-test='property-type-input']"))
    property_type.click()
    house = browser.find_element(By.XPATH ,(f"//a[@data-test='property-type-selector-{proptype}']"))
    house.click()
    time.sleep(5)
    x = 0
    while x < 100:
        try:
            slide = browser.find_element(By.XPATH ,("//span[@class='Icon__BaseIcon-sc-394gxl-0 Icon-sc-394gxl-1 bVuOLd iYcFvC slick-arrow slick-next']"))
            slide.click()
            time.sleep(4)
            x += 1
        except:
            break

def get_link(pp):
    link = browser.find_elements(By.XPATH ,(f"//div[@style='{pp}']"))
    element_counts = Counter(link)
    for element, count in element_counts.items():
        try:
            link_in = element.find_element("tag name", "a")
            link_in = link_in.get_attribute("href")
        except:
            pass
        link_list.append(link_in)
        province_list.append(link_in)
        
browser = webdriver.Chrome()  
browser.maximize_window()
browser.get("https://thinkofliving.com/")
time.sleep(3)
link_list = []
province = ["ชลบุรี","สมุทรปราการ","เชียงใหม่","ระยอง","นนทบุรี","นครราชสีมา","ปทุมธานี","นครปฐม","ขอนแก่น","สมุทรสาคร"]
#"กรุงเทพมหานคร",
for i in province:
    province_list = []
    search = browser.find_element(By.XPATH ,("//button[@class='btn-search']"))
    search.click()
    search_box = browser.find_element(By.XPATH ,("//input[@data-test='desktop-search-input']"))
    search_box.send_keys(i)
    time.sleep(2)
    result = browser.find_element(By.XPATH ,(f"//h5[@class='item-title' and text()='{i}']"))
    result.click()
    time.sleep(2)
    prop_type("HS")
    get_link("outline:none")
    get_link("outline: none;")
    prop_type("TH")
    get_link("outline:none")
    get_link("outline: none;")
    link_list = list(set(link_list))
    print(f"{i} -- {len(province_list)}")
print(len(link_list))
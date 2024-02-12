from selenium import webdriver
import time
from selenium.webdriver import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.common.actions.wheel_input import ScrollOrigin

def sc6():
    url = 'http://159.223.51.33/realist/condo/proj/Ideo-O2-CD1225/'
    browser = webdriver.Chrome()
    browser.set_window_size(390, 844)
    browser.get("http://google.com")
    browser.get(url)
    time.sleep(3)

    map_click = browser.find_element(By.XPATH ,("//div[@onclick='show_map_mobile()']"))
    map_click.click()
    time.sleep(3)
    element = browser.find_element(By.XPATH ,("//div[@aria-label='Map']"))
    time.sleep(2)
    zoom = ScrollOrigin.from_element(element, 0, 0)
    actions = ActionChains(browser)
    i = 0
    while i < 5:
        actions.scroll_from_origin(zoom, 0, -100).perform()
        time.sleep(1)
        i+=1
    i = 0
    while i < 3:
        actions.click_and_hold(element).move_by_offset(100,0).release().perform()
        i+=1
    time.sleep(2)
    element.click()
    time.sleep(2)
    browser.save_screenshot("D:\PYTHON\script_test\check_cover_mobile\cover.png")
    browser.close()
    print('sc6 done')
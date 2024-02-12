from selenium import webdriver
from selenium.webdriver.common.by import By
import time
from selenium.webdriver.common.action_chains import ActionChains
def sc5():

    def zoom():
        time.sleep(3)
        i=0
        while i < 5:
            zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
            zoom_in.click()
            time.sleep(1)
            i+=1
    def move(x,y):
        map = browser.find_element(By.XPATH ,("//div[@aria-label='Map']"))
        actions = ActionChains(browser)
        i = 0
        while i < 3:
            actions.click_and_hold(map).move_by_offset(x,y).release().perform()
            i+=1
        time.sleep(3)
    def save(z):
        map = browser.find_element(By.XPATH ,("//div[@aria-label='Map']"))
        actions = ActionChains(browser)
        actions.move_to_element(map).perform();
        browser.save_screenshot("D:\PYTHON\script_test\check_boundary\condo_"+z+"_boundary.png")
        browser.close()
    def open():
        browser.maximize_window()
        browser.get("http://google.com")
        browser.get(url)
    def work(x,y,z):
        zoom()
        move(x,y)
        save(z)
    #home
    url = "http://159.223.51.33:8080/realist/condo/"
    browser = webdriver.Chrome()
    open()
    browser.execute_script("window.scrollTo(0, 5000)")
    time.sleep(3)
    browser.execute_script("window.scrollTo(0, 3700)")
    work(30,-320,"home")
    #condo template
    url = "http://159.223.51.33:8080/realist/condo/proj/Ashton-Silom-CD0852/"
    browser = webdriver.Chrome()
    open()
    browser.execute_script("window.scrollTo(0, 3400)")
    work(-30,400,"template")
    #condo listing
    url = "http://159.223.51.33:8080/realist/condo/list/spotlight/คอนโดใกล้สถานีรถไฟฟ้า/"
    browser = webdriver.Chrome()
    open()
    browser.execute_script("window.scrollTo(0, 850)")
    work(30,300,"listing")
    print('sc5 done')
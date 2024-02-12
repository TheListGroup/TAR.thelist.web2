from selenium import webdriver
from selenium.webdriver.common.by import By
import time
from selenium.webdriver.common.action_chains import ActionChains
from collections import Counter
def sc3():

    url = "http://159.223.51.33:8080/realist/condo/"
    browser = webdriver.Chrome()
    browser.maximize_window()
    browser.get("http://google.com")
    browser.get(url)
    browser.execute_script("window.scrollTo(0, 5000)")
    time.sleep(3)
    browser.execute_script("window.scrollTo(0, 3700)")
    time.sleep(3)

    i=0
    while i < 4:
        zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
        zoom_out.click()
        time.sleep(1)
        i+=1
    all = browser.find_element(By.XPATH ,("//label[@for='all']"));
    all.click()
    time.sleep(2)

    province = browser.find_elements(By.XPATH ,("//div[@class='container p-2']"))
    element_counts = Counter(province)
    actions = ActionChains(browser)
    place = ["Bangkok","Nonthaburi","Samut-Prakarn","Pathom-Thanee","Nakorn-Pathom","Samut-Sakorn"]
    x = 0
    for element, count in element_counts.items():
        if x > 0:
            actions.move_to_element(element).perform();
            browser.save_screenshot("D:\PYTHON\script_test\hover\screenshot_"+place[x-1]+".png")
        x+=1

    browser.close()
    print('sc3 done')
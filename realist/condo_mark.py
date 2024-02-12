from selenium import webdriver
import time
from selenium.webdriver.common.by import By
import pandas as pd

def sc2():
    url = "http://159.223.51.33:8080/realist/condo/proj/Chewathai-Residence-Thonglor-CD1172/"

    check_list = []
    browser = webdriver.Chrome()
    browser.maximize_window()
    browser.get("http://google.com")
    browser.get(url)

    check_dict = {"TOPIC" : "script2 : Condo_Mark"}
    #scroll to map
    browser.execute_script("window.scrollTo(0, 3400)")
    time.sleep(3)
    #click zoom in 3 times
    for i in range(0,3):
        zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
        zoom_in.click()
        time.sleep(1)
        i+=1
    #click close eye
    eye = browser.find_element(By.XPATH ,("//i[@id='btn-eye-condo-toggle']"))
    eye.click()
    #click zoom out 1 time
    zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
    zoom_out.click()
    #check_condo_mark
    try:
        mark = browser.find_element(By.XPATH ,("//div[@style='position: absolute; top: -31px; left: -19px;']"))
        onscreen = mark.is_displayed();
        if onscreen:
            #print('ok')
            check_dict["Condo_Mark_Close_Eye"] = 1
        else:
            #print('error found but not onscreen')
            check_dict["Condo_Mark_Close_Eye"] = 'error found but not onscreen'
    except:
        #print('error not found')
        check_dict["Condo_Mark_Close_Eye"] = 'error not found'
    browser.close()
    check_list.append(check_dict)
    check_df = pd.DataFrame(check_list)
    check_df.to_csv('check_often_error.csv')
    print("script2 done")
from selenium import webdriver
import time
from selenium.webdriver.common.by import By
import pandas as pd
from bs4 import BeautifulSoup as bs
from selenium.webdriver.common.action_chains import ActionChains

url = "http://159.223.51.33:8080/realist/condo/"
poi_dict = {}
result_list = []
browser = webdriver.Chrome()
browser.maximize_window()
browser.get("http://google.com")
browser.get(url)

browser.execute_script("window.scrollTo(0, 5000)")
time.sleep(3)
browser.execute_script("window.scrollTo(0, 3700)")
time.sleep(3)

poi_dict = {"PAGE" : "HOME DEFUALT"}
defualt_list = []
soup = bs(browser.page_source, 'html.parser')
#collect all poi
for i , poi in enumerate(soup.find_all('div', {'class': 'poi-overlay-marker-s'})):
    all_poi = poi.get('style')
    all_poi = all_poi.split(";")[1].split(":")[1].strip()
    defualt_list.append(all_poi)
hospital = defualt_list.count("rgb(157, 207, 60)")
school = defualt_list.count("rgb(227, 95, 80)")
train = defualt_list.count("rgb(121, 145, 148)")
mall = defualt_list.count("rgb(255, 181, 25)")
road = defualt_list.count("rgb(159, 189, 193)")
port = defualt_list.count("rgb(194, 212, 214)")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] == 20:
            poi_dict[text] = 1
        else:
            poi_dict[text] = "ERROR"
result_list.append(poi_dict)


poi_dict = {"PAGE" : "HOME ZOOM 1"}
zoom1_list = []
zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
zoom_in.click()
time.sleep(1)
soup_zoom1 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_zoom1.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        zoom1_list.append(all_poi)
hospital = zoom1_list.count("#9DCF3C")
school = zoom1_list.count("#E35F50")
train = zoom1_list.count("#799194")
mall = zoom1_list.count("#FFB519")
road = zoom1_list.count("#9FBDC1")
port = zoom1_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME ZOOM 2"}
zoom2_list = []
zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
zoom_in.click()
time.sleep(1)
soup_zoom2 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_zoom2.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        zoom1_list.append(all_poi)
hospital = zoom2_list.count("#9DCF3C")
school = zoom2_list.count("#E35F50")
train = zoom2_list.count("#799194")
mall = zoom2_list.count("#FFB519")
road = zoom2_list.count("#9FBDC1")
port = zoom2_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME ZOOM OUT 1"}
zoomout1_list = []
zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
zoom_out.click()
time.sleep(1)
soup_zoomout1 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_zoomout1.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        zoomout1_list.append(all_poi)
hospital = zoomout1_list.count("#9DCF3C")
school = zoomout1_list.count("#E35F50")
train = zoomout1_list.count("#799194")
mall = zoomout1_list.count("#FFB519")
road = zoomout1_list.count("#9FBDC1")
port = zoomout1_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME ZOOM OUT 2"}
zoomout2_list = []
zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
zoom_out.click()
time.sleep(1)
soup_zoomout2 = bs(browser.page_source, 'html.parser')
#collect all poi
for i , poi in enumerate(soup_zoomout2.find_all('div', {'class': 'poi-overlay-marker-s'})):
    all_poi = poi.get('style')
    all_poi = all_poi.split(";")[1].split(":")[1].strip()
    zoomout2_list.append(all_poi)
hospital = zoomout2_list.count("rgb(157, 207, 60)")
school = zoomout2_list.count("rgb(227, 95, 80)")
train = zoomout2_list.count("rgb(121, 145, 148)")
mall = zoomout2_list.count("rgb(255, 181, 25)")
road = zoomout2_list.count("rgb(159, 189, 193)")
port = zoomout2_list.count("rgb(194, 212, 214)")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] == 20:
            poi_dict[text] = 1
        else:
            poi_dict[text] = "ERROR"
result_list.append(poi_dict)

mark = browser.find_element(By.XPATH ,("//div[@id='map-test']"))
actions = ActionChains(browser)
i = 0
while i < 3:
    actions.click_and_hold(mark).move_by_offset(0,400).release().perform()
    i+=1
poi_dict = {"PAGE" : "HOME MOVE UP"}
moveup_list = []
soup_moveup = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveup.find_all('div', {'class': 'poi-overlay-marker-s'})):
    all_poi = poi.get('style')
    all_poi = all_poi.split(";")[1].split(":")[1].strip()
    moveup_list.append(all_poi)
hospital = moveup_list.count("rgb(157, 207, 60)")
school = moveup_list.count("rgb(227, 95, 80)")
train = moveup_list.count("rgb(121, 145, 148)")
mall = moveup_list.count("rgb(255, 181, 25)")
road = moveup_list.count("rgb(159, 189, 193)")
port = moveup_list.count("rgb(194, 212, 214)")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] == 20:
            poi_dict[text] = 1
        else:
            poi_dict[text] = "ERROR"
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVEUP ZOOM 1"}
moveup_zoom1_list = []
zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
zoom_in.click()
time.sleep(1)
soup_moveup_zoom1 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveup_zoom1.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        moveup_zoom1_list.append(all_poi)
hospital = moveup_zoom1_list.count("#9DCF3C")
school = moveup_zoom1_list.count("#E35F50")
train = moveup_zoom1_list.count("#799194")
mall = moveup_zoom1_list.count("#FFB519")
road = moveup_zoom1_list.count("#9FBDC1")
port = moveup_zoom1_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVEUP ZOOM 2"}
moveup_zoom2_list = []
zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
zoom_in.click()
time.sleep(1)
soup_moveup_zoom2 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveup_zoom2.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        moveup_zoom2_list.append(all_poi)
hospital = moveup_zoom2_list.count("#9DCF3C")
school = moveup_zoom2_list.count("#E35F50")
train = moveup_zoom2_list.count("#799194")
mall = moveup_zoom2_list.count("#FFB519")
road = moveup_zoom2_list.count("#9FBDC1")
port = moveup_zoom2_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVEUP ZOOM OUT 1"}
moveup_zoomout1_list = []
zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
zoom_out.click()
time.sleep(1)
soup_moveup_zoomout1 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveup_zoomout1.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        moveup_zoomout1_list.append(all_poi)
hospital = moveup_zoomout1_list.count("#9DCF3C")
school = moveup_zoomout1_list.count("#E35F50")
train = moveup_zoomout1_list.count("#799194")
mall = moveup_zoomout1_list.count("#FFB519")
road = moveup_zoomout1_list.count("#9FBDC1")
port = moveup_zoomout1_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVEUP ZOOM OUT 2"}
moveup_zoomout2_list = []
zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
zoom_out.click()
time.sleep(1)
soup_moveup_zoomout2 = bs(browser.page_source, 'html.parser')
#collect all poi
for i , poi in enumerate(soup_moveup_zoomout2.find_all('div', {'class': 'poi-overlay-marker-s'})):
    all_poi = poi.get('style')
    all_poi = all_poi.split(";")[1].split(":")[1].strip()
    moveup_zoomout2_list.append(all_poi)
hospital = moveup_zoomout2_list.count("rgb(157, 207, 60)")
school = moveup_zoomout2_list.count("rgb(227, 95, 80)")
train = moveup_zoomout2_list.count("rgb(121, 145, 148)")
mall = moveup_zoomout2_list.count("rgb(255, 181, 25)")
road = moveup_zoomout2_list.count("rgb(159, 189, 193)")
port = moveup_zoomout2_list.count("rgb(194, 212, 214)")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] == 20:
            poi_dict[text] = 1
        else:
            poi_dict[text] = "ERROR"
result_list.append(poi_dict)
            
mark = browser.find_element(By.XPATH ,("//div[@id='map-test']"))
actions = ActionChains(browser)
i = 0
while i < 3:
    actions.click_and_hold(mark).move_by_offset(800,0).release().perform()
    i+=1
poi_dict = {"PAGE" : "HOME MOVE LEFT"}
moveleft_list = []
soup_moveleft = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveleft.find_all('div', {'class': 'poi-overlay-marker-s'})):
    all_poi = poi.get('style')
    all_poi = all_poi.split(";")[1].split(":")[1].strip()
    moveleft_list.append(all_poi)
hospital = moveleft_list.count("rgb(157, 207, 60)")
school = moveleft_list.count("rgb(227, 95, 80)")
train = moveleft_list.count("rgb(121, 145, 148)")
mall = moveleft_list.count("rgb(255, 181, 25)")
road = moveleft_list.count("rgb(159, 189, 193)")
port = moveleft_list.count("rgb(194, 212, 214)")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] == 20:
            poi_dict[text] = 1
        else:
            poi_dict[text] = "ERROR"
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVELEFT ZOOM 1"}
moveleft_zoom1_list = []
zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
zoom_in.click()
time.sleep(1)
soup_moveleft_zoom1 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveleft_zoom1.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        moveleft_zoom1_list.append(all_poi)
hospital = moveleft_zoom1_list.count("#9DCF3C")
school = moveleft_zoom1_list.count("#E35F50")
train = moveleft_zoom1_list.count("#799194")
mall = moveleft_zoom1_list.count("#FFB519")
road = moveleft_zoom1_list.count("#9FBDC1")
port = moveleft_zoom1_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVELEFT ZOOM 2"}
moveleft_zoom2_list = []
zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
zoom_in.click()
time.sleep(1)
soup_moveleft_zoom2 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveleft_zoom2.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        moveleft_zoom2_list.append(all_poi)
hospital = moveleft_zoom2_list.count("#9DCF3C")
school = moveleft_zoom2_list.count("#E35F50")
train = moveleft_zoom2_list.count("#799194")
mall = moveleft_zoom2_list.count("#FFB519")
road = moveleft_zoom2_list.count("#9FBDC1")
port = moveleft_zoom2_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVELEFT ZOOM OUT 1"}
moveleft_zoomout1_list = []
zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
zoom_out.click()
time.sleep(1)
soup_moveleft_zoomout1 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveleft_zoomout1.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        moveleft_zoomout1_list.append(all_poi)
hospital = moveleft_zoomout1_list.count("#9DCF3C")
school = moveleft_zoomout1_list.count("#E35F50")
train = moveleft_zoomout1_list.count("#799194")
mall = moveleft_zoomout1_list.count("#FFB519")
road = moveleft_zoomout1_list.count("#9FBDC1")
port = moveleft_zoomout1_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVELEFT ZOOM OUT 2"}
moveleft_zoomout2_list = []
zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
zoom_out.click()
time.sleep(1)
soup_moveleft_zoomout2 = bs(browser.page_source, 'html.parser')
#collect all poi
for i , poi in enumerate(soup_moveleft_zoomout2.find_all('div', {'class': 'poi-overlay-marker-s'})):
    all_poi = poi.get('style')
    all_poi = all_poi.split(";")[1].split(":")[1].strip()
    moveleft_zoomout2_list.append(all_poi)
hospital = moveleft_zoomout2_list.count("rgb(157, 207, 60)")
school = moveleft_zoomout2_list.count("rgb(227, 95, 80)")
train = moveleft_zoomout2_list.count("rgb(121, 145, 148)")
mall = moveleft_zoomout2_list.count("rgb(255, 181, 25)")
road = moveleft_zoomout2_list.count("rgb(159, 189, 193)")
port = moveleft_zoomout2_list.count("rgb(194, 212, 214)")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] == 20:
            poi_dict[text] = 1
        else:
            poi_dict[text] = "ERROR"
result_list.append(poi_dict)

mark = browser.find_element(By.XPATH ,("//div[@id='map-test']"))
actions = ActionChains(browser)
i = 0
while i < 3:
    actions.click_and_hold(mark).move_by_offset(0,-400).release().perform()
    i+=1
poi_dict = {"PAGE" : "HOME MOVE DOWN"}
movedown_list = []
soup_movedown = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_movedown.find_all('div', {'class': 'poi-overlay-marker-s'})):
    all_poi = poi.get('style')
    all_poi = all_poi.split(";")[1].split(":")[1].strip()
    movedown_list.append(all_poi)
hospital = movedown_list.count("rgb(157, 207, 60)")
school = movedown_list.count("rgb(227, 95, 80)")
train = movedown_list.count("rgb(121, 145, 148)")
mall = movedown_list.count("rgb(255, 181, 25)")
road = movedown_list.count("rgb(159, 189, 193)")
port = movedown_list.count("rgb(194, 212, 214)")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] == 20:
            poi_dict[text] = 1
        else:
            poi_dict[text] = "ERROR"
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVEDOWN ZOOM 1"}
movedown_zoom1_list = []
zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
zoom_in.click()
time.sleep(1)
soup_movedown_zoom1 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_movedown_zoom1.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        movedown_zoom1_list.append(all_poi)
hospital = movedown_zoom1_list.count("#9DCF3C")
school = movedown_zoom1_list.count("#E35F50")
train = movedown_zoom1_list.count("#799194")
mall = movedown_zoom1_list.count("#FFB519")
road = movedown_zoom1_list.count("#9FBDC1")
port = movedown_zoom1_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVEDOWN ZOOM 2"}
movedown_zoom2_list = []
zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
zoom_in.click()
time.sleep(1)
soup_movedown_zoom2 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_movedown_zoom2.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        movedown_zoom2_list.append(all_poi)
hospital = movedown_zoom2_list.count("#9DCF3C")
school = movedown_zoom2_list.count("#E35F50")
train = movedown_zoom2_list.count("#799194")
mall = movedown_zoom2_list.count("#FFB519")
road = movedown_zoom2_list.count("#9FBDC1")
port = movedown_zoom2_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVEDOWN ZOOM OUT 1"}
movedown_zoomout1_list = []
zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
zoom_out.click()
time.sleep(1)
soup_movedown_zoomout1 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_movedown_zoomout1.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        movedown_zoomout1_list.append(all_poi)
hospital = movedown_zoomout1_list.count("#9DCF3C")
school = movedown_zoomout1_list.count("#E35F50")
train = movedown_zoomout1_list.count("#799194")
mall = movedown_zoomout1_list.count("#FFB519")
road = movedown_zoomout1_list.count("#9FBDC1")
port = movedown_zoomout1_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVEDOWN ZOOM OUT 2"}
movedown_zoomout2_list = []
zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
zoom_out.click()
time.sleep(1)
soup_movedown_zoomout2 = bs(browser.page_source, 'html.parser')
#collect all poi
for i , poi in enumerate(soup_movedown_zoomout2.find_all('div', {'class': 'poi-overlay-marker-s'})):
    all_poi = poi.get('style')
    all_poi = all_poi.split(";")[1].split(":")[1].strip()
    movedown_zoomout2_list.append(all_poi)
hospital = movedown_zoomout2_list.count("rgb(157, 207, 60)")
school = movedown_zoomout2_list.count("rgb(227, 95, 80)")
train = movedown_zoomout2_list.count("rgb(121, 145, 148)")
mall = movedown_zoomout2_list.count("rgb(255, 181, 25)")
road = movedown_zoomout2_list.count("rgb(159, 189, 193)")
port = movedown_zoomout2_list.count("rgb(194, 212, 214)")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] == 20:
            poi_dict[text] = 1
        else:
            poi_dict[text] = "ERROR"
result_list.append(poi_dict)

mark = browser.find_element(By.XPATH ,("//div[@id='map-test']"))
actions = ActionChains(browser)
i = 0
while i < 3:
    actions.click_and_hold(mark).move_by_offset(-600,0).release().perform()
    i+=1
poi_dict = {"PAGE" : "HOME MOVE RIGHT"}
moveright_list = []
soup_moveright = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveright.find_all('div', {'class': 'poi-overlay-marker-s'})):
    all_poi = poi.get('style')
    all_poi = all_poi.split(";")[1].split(":")[1].strip()
    moveright_list.append(all_poi)
hospital = moveright_list.count("rgb(157, 207, 60)")
school = moveright_list.count("rgb(227, 95, 80)")
train = moveright_list.count("rgb(121, 145, 148)")
mall = moveright_list.count("rgb(255, 181, 25)")
road = moveright_list.count("rgb(159, 189, 193)")
port = moveright_list.count("rgb(194, 212, 214)")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] == 20:
            poi_dict[text] = 1
        else:
            poi_dict[text] = "ERROR"
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVERIGHT ZOOM 1"}
moveright_zoom1_list = []
zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
zoom_in.click()
time.sleep(1)
soup_moveright_zoom1 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveright_zoom1.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        moveright_zoom1_list.append(all_poi)
hospital = moveright_zoom1_list.count("#9DCF3C")
school = moveright_zoom1_list.count("#E35F50")
train = moveright_zoom1_list.count("#799194")
mall = moveright_zoom1_list.count("#FFB519")
road = moveright_zoom1_list.count("#9FBDC1")
port = moveright_zoom1_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVERIGHT ZOOM 2"}
moveright_zoom2_list = []
zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
zoom_in.click()
time.sleep(1)
soup_moveright_zoom2 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveright_zoom2.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        moveright_zoom2_list.append(all_poi)
hospital = moveright_zoom2_list.count("#9DCF3C")
school = moveright_zoom2_list.count("#E35F50")
train = moveright_zoom2_list.count("#799194")
mall = moveright_zoom2_list.count("#FFB519")
road = moveright_zoom2_list.count("#9FBDC1")
port = moveright_zoom2_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVERIGHT ZOOM OUT 1"}
moveright_zoomout1_list = []
zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
zoom_out.click()
time.sleep(1)
soup_moveright_zoomout1 = bs(browser.page_source, 'html.parser')
for i , poi in enumerate(soup_moveright_zoomout1.find_all('div', {'class': 'poi-overlay-marker-l'})):
    for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
        all_poi = poi_in.get('style')
        all_poi = all_poi.split(";")[3].split(":")[1].strip()
        moveright_zoomout1_list.append(all_poi)
hospital = moveright_zoomout1_list.count("#9DCF3C")
school = moveright_zoomout1_list.count("#E35F50")
train = moveright_zoomout1_list.count("#799194")
mall = moveright_zoomout1_list.count("#FFB519")
road = moveright_zoomout1_list.count("#9FBDC1")
port = moveright_zoomout1_list.count("#C2D4D6")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] > 20:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
result_list.append(poi_dict)

poi_dict = {"PAGE" : "HOME MOVERIGHT ZOOM OUT 2"}
moveright_zoomout2_list = []
zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
zoom_out.click()
time.sleep(1)
soup_moveright_zoomout2 = bs(browser.page_source, 'html.parser')
#collect all poi
for i , poi in enumerate(soup_moveright_zoomout2.find_all('div', {'class': 'poi-overlay-marker-s'})):
    all_poi = poi.get('style')
    all_poi = all_poi.split(";")[1].split(":")[1].strip()
    moveright_zoomout2_list.append(all_poi)
hospital = moveright_zoomout2_list.count("rgb(157, 207, 60)")
school = moveright_zoomout2_list.count("rgb(227, 95, 80)")
train = moveright_zoomout2_list.count("rgb(121, 145, 148)")
mall = moveright_zoomout2_list.count("rgb(255, 181, 25)")
road = moveright_zoomout2_list.count("rgb(159, 189, 193)")
port = moveright_zoomout2_list.count("rgb(194, 212, 214)")
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
for i , text in enumerate(title):
    if i != 2:
        if count_list[i] > 6:
            poi_dict[text] = "ERROR"
        else:
            poi_dict[text] = 1
    else:
        if count_list[i] == 20:
            poi_dict[text] = 1
        else:
            poi_dict[text] = "ERROR"
result_list.append(poi_dict)

poi_df = pd.DataFrame(result_list)
poi_df.to_csv('poi.csv')
browser.close()
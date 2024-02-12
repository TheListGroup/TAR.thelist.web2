from selenium import webdriver
import time
from selenium.webdriver.common.by import By
import pandas as pd
from bs4 import BeautifulSoup as bs
from selenium.webdriver.common.action_chains import ActionChains
#url = "http://128.199.207.198/realist/condo/"
poi_dict = {}
result_list = []
#browser = webdriver.Chrome()
#browser.maximize_window()
#browser.get("http://google.com")
#browser.get(url)
#browser.execute_script("window.scrollTo(0, 5000)")
#time.sleep(3)
#browser.execute_script("window.scrollTo(0, 3700)")
#time.sleep(3)
hospital = 0
school = 0
train = 0
mall = 0
road = 0
port = 0
count_list = [hospital,school,train,mall,road,port]
title = ["HOSPITAL","SCHOOL","TRAIN","MALL","ROAD","PORT"]
scolor = ["rgb(157, 207, 60)","rgb(227, 95, 80)","rgb(121, 145, 148)","rgb(255, 181, 25)","rgb(159, 189, 193)","rgb(194, 212, 214)"]
lcolor = ["#9DCF3C","#E35F50","#799194","#FFB519","#9FBDC1","#C2D4D6"]
#move map
def move(x,y):
    mark = browser.find_element(By.XPATH ,("//div[@id='map-test']"))
    actions = ActionChains(browser)
    i = 0
    while i < 3:
        actions.click_and_hold(mark).move_by_offset(x,y).release().perform()
        i+=1
    time.sleep(2)
def zoomin():
    zoom_in = browser.find_element(By.XPATH ,("//button[@title='Zoom in']"))
    zoom_in.click()
    time.sleep(2)
def zoomout():
    zoom_out = browser.find_element(By.XPATH ,("//button[@title='Zoom out']"))
    zoom_out.click()
    time.sleep(2)
#poi check smark
def marks(x,y):
    poi_dict = {"PAGE" : x}
    countpoi_list = []
    soup = bs(browser.page_source, 'html.parser')
    for i , poi in enumerate(soup.find_all('div', {'class': 'poi-overlay-marker-s'})):
        all_poi = poi.get('style')
        all_poi = all_poi.split(";")[1].split(":")[1].strip()
        countpoi_list.append(all_poi)
    i = 0
    while i < 6:
        count_list[i] = countpoi_list.count(scolor[i])
        i+=1
    for i , text in enumerate(title):
        if i != 2:
            if count_list[i] > 6:
                poi_dict[text] = "ERROR"
            else:
                poi_dict[text] = 1
        else:
            if count_list[i] == y:
                poi_dict[text] = 1
            else:
                poi_dict[text] = "ERROR"
    result_list.append(poi_dict)
#poi check lmark 
def markl(x,y):
    poi_dict = {"PAGE" : x}
    countpoi_list = []
    soup = bs(browser.page_source, 'html.parser')
    for i , poi in enumerate(soup.find_all('div', {'class': 'poi-overlay-marker-l'})):
        for j , poi_in in enumerate(poi.find_all('div', {'class': 'text-center'})):
            all_poi = poi_in.get('style')
            all_poi = all_poi.split(";")[3].split(":")[1].strip()
            countpoi_list.append(all_poi)
    i = 0
    while i < 6:
        count_list[i] = countpoi_list.count(lcolor[i])
        i+=1
    for i , text in enumerate(title):
        if i != 2:
            if count_list[i] > 6:
                poi_dict[text] = "ERROR"
            else:
                poi_dict[text] = 1
        else:
            if count_list[i] != y:
                poi_dict[text] = "ERROR"
            else:
                poi_dict[text] = 1
    result_list.append(poi_dict)
def move2(x,y):
    mark = browser.find_element(By.XPATH ,("//div[@id='map-full']"))
    actions = ActionChains(browser)
    i = 0
    while i < 3:
        actions.click_and_hold(mark).move_by_offset(x,y).release().perform()
        i+=1
    time.sleep(2)
##home_defualt
#marks("HOME DEFUALT",20)
##home_zoom1
#zoomin()
#markl("HOME ZOOM 1",11)
##home_zoom2
#zoomin()
#markl("HOME ZOOM 2",3)
##home_zoomout1
#zoomout()
#markl("HOME ZOOM OUT 1",11)
##home_zoomout2
#zoomout()
#marks("HOME ZOOM OUT 2",20)
##moveup_default
#move(0,400)
#marks("HOME MOVEUP",20)
##moveup_zoom1
#zoomin()
#markl("HOME MOVEUP ZOOM 1",7)
##moveup_zoom2
#zoomin()
#markl("HOME MOVEUP ZOOM 2",2)
##moveup_zoomout1
#zoomout()
#markl("HOME MOVEUP ZOOM OUT 1",7)
##moveup_zoomout2
#zoomout()
#marks("HOME MOVEUP ZOOM OUT 2",20)
##move_left default
#move(800,0)
#marks("HOME MOVELEFT",20)
##move_left zoom 1
#zoomin()
#markl("HOME MOVELEFT ZOOM 1",8)
##move_left zoom 2
#zoomin()
#markl("HOME MOVELEFT ZOOM 2",0)
##move_left zoomout 1
#zoomout()
#markl("HOME MOVELEFT ZOOM OUT 1",8)
##move_left zoomout 2
#zoomout()
#marks("HOME MOVELEFT ZOOM OUT 2",20)
##movedown
#move(0,-400)
#marks("HOME MOVEDOWN",20)
##movedown zoom1
#zoomin()
#markl("HOME MOVEDOWN ZOOM 1",9)
##movedown zoom2
#zoomin()
#markl("HOME MOVEDOWN ZOOM 2",4)
##movedown zoom out 1
#zoomout()
#markl("HOME MOVEDOWN ZOOM OUT 1",9)
##movedown zoom out 2
#zoomout()
#marks("HOME MOVEDOWN ZOOM OUT 2",20)
##moveright
#move(-600,0)
#marks("HOME MOVERIGHT",20)
##moveright zoom1
#zoomin()
#markl("HOME MOVERIGHT ZOOM 1",15)
##moveright zoom2
#zoomin()
#markl("HOME MOVERIGHT ZOOM 2",2)
##moveright zoom out 1
#zoomout()
#markl("HOME MOVERIGHT ZOOM OUT 1",15)
##moveright zoom out 2
#zoomout()
#marks("HOME MOVERIGHT ZOOM OUT 2",20)
#browser.close()
###listing
url = "http://128.199.207.198/realist/condo/list/spotlight/คอนโดใกล้สถานีรถไฟฟ้า"
browser = webdriver.Chrome()
browser.maximize_window()
browser.get("http://google.com")
browser.get(url)
browser.execute_script("window.scrollTo(0, 900)")
time.sleep(3)
#listing default
marks("LISTING DEFUALT",20)
#listing zoom1
zoomin()
marks("LISTING ZOOM 1",20)
#listing zoom2
zoomin()
markl("LISTING ZOOM 2",7)
#listing zoom out 1
zoomout()
marks("LISTING ZOOM OUT 1",20)
#listing zoom out 2
zoomout()
marks("LISTING ZOOM OUT 2",20)
#listing moveup_default
move(0,400)
marks("LISTING MOVEUP",20)
#listing moveup zoom1
zoomin()
marks("LISTING MOVEUP ZOOM 1",20)
#listing moveup zoom2
zoomin()
markl("LISTING MOVEUP ZOOM 2",7)
#listing moveup zoom out 1
zoomout()
marks("LISTING MOVEUP ZOOM OUT 1",20)
#listing moveup zoom out 2
zoomout()
marks("LISTING MOVEUP OUT 2",20)
#listing moveleft
move(800,0)
marks("LISTING MOVELEFT",16)
#listing move_left zoom 1
zoomin()
marks("LISTING MOVELEFT ZOOM 1",2)
#listing move_left zoom 2
zoomin()
markl("LISTING MOVELEFT ZOOM 2",0)
#listing move_left zoomout 1
zoomout()
marks("LISTING MOVELEFT ZOOM OUT 1",2)
#listing move_left zoomout 2
zoomout()
marks("LISTING MOVELEFT ZOOM OUT 2",16)
#listing movedown
move(0,-400)
marks("LISTING MOVEDOWN",20)
#listing movedown zoom1
zoomin()
marks("LISTING MOVEDOWN ZOOM 1",6)
#listing movedown zoom2
zoomin()
markl("LISTING MOVEDOWN ZOOM 2",0)
#listing movedown zoom out 1
zoomout()
marks("LISTING MOVEDOWN ZOOM OUT 1",6)
#listing movedown zoom out 2
zoomout()
marks("LISTING MOVEDOWN ZOOM OUT 2",20)
#listing moveright
move(-600,0)
marks("LISTING MOVERIGHT",20)
#listing moveright zoom1
zoomin()
marks("LISTING MOVERIGHT ZOOM 1",20)
#listing moveright zoom2
zoomin()
markl("LISTING MOVERIGHT ZOOM 2",19)
#listing moveright zoom out 1
zoomout()
marks("LISTING MOVERIGHT ZOOM OUT 1",20)
#listing moveright zoom out 2
zoomout()
marks("LISTING MOVERIGHT ZOOM OUT 2",20)
browser.close()
###condo_template
#url = "http://128.199.207.198/realist/condo/proj/Culture-Thonglor-CD2592/"
#browser = webdriver.Chrome()
#browser.maximize_window()
#browser.get("http://google.com")
#browser.get(url)
#browser.execute_script("window.scrollTo(0, 3100)")
#time.sleep(3)
##condo template default
#marks("CONDO TEMPLATE DEFUALT",20)
##condo template zoom1
#zoomin()
#markl("CONDO TEMPLATE ZOOM 1",12)
##condo template zoom2
#zoomin()
#markl("CONDO TEMPLATE ZOOM 2",3)
##condo template zoom out 1
#zoomout()
#markl("CONDO TEMPLATE ZOOM OUT 1",12)
##condo template zoom out 2
#zoomout()
#marks("CONDO TEMPLATE ZOOM OUT 2",20)
##condo template moveup default
#move2(0,400)
poi_df = pd.DataFrame(result_list)
poi_df.to_csv('poi.csv')
#browser.close()
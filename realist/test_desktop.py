###test function###
    #cover -- defualt or own pic
    #menu_1
        #menu open list
        #pic png
    #menu_2 -- condo_data
    #menu_3 -- realist_blog
    #menu_4 -- facebook
    #menu_5 -- youtube
    #menu_6 -- instagram
    #menu_7 -- line@
    #title
    #amount
    #text info
    #stat header
    #stat name
    #stat_1 -- ราคาเฉลี่ย
    #stat_2 -- ราคาเฉลี่ย/ยูนิต
    #stat_3
        #จำนวนคอนโด
        #จำนวนยูนิตรวม
        #จำนวนยูนิตเฉลี่ย / โครงการ
        #ขนาดห้องเฉลี่ย
        #อัตราส่วนที่จอดรถต่อห้อง
    #stat_4
        #ค่าส่วนกลางเฉลี่ย
        #ค่าเช่าเฉลี่ย
        #Rental Yield
    #stat_5
        #ยอดขาย
        #ยอดโอน
    #stat_6_1 -- คอนโดสร้างแล้วเสร็จ
    #stat6_2 -- คอนโดใหม่/กำลังก่อสร้าง
    #result_text
    #result_symbol
    #search symbol

    ###test_function_2###
        #bottom head
        #bottom text
        #bottom title
        #condo list
        #sort text
        #sort list
        #list mode row
        #list mode
        #left map box
            #icon
            #text
            #condo amount
        #map menu
            #similar
            #recommand
            #all
                #all amount count
        #satellite
        #realist in map

###test_function_3###        
#condo box   
#expand map
    #left
    #right
#condo_mark
    #condo_mark color
    #click_condo_mark
        #condo_mark_icon_bg
        #condo_mark_icon
        #condo_mark_icon_color
        #condo_mark_name
#home button
    #home_link
    #home_button
    #home_listing_text

from selenium import webdriver
from bs4 import BeautifulSoup as bs
import pandas as pd
import time
import re
from selenium.webdriver import ActionChains
from selenium.webdriver.common.by import By
from random import randint

url ='http://159.223.51.33/realist/condo/'

test_list = []
x = 0
browser = webdriver.Chrome()
browser.get("http://google.com")
browser.get(url)
browser.maximize_window()
time.sleep(2)
soup = bs(browser.page_source, 'html.parser')
browser.close()

def test_function(a):
    def test_function_2():
        #bottom head -- bottom text
        bothead_text = soup_in.find('div', {'class': 'search-result-head-text text-right'})
        if bothead_text:
            bothead_text = bothead_text.text.strip()
            if bothead_text == "ผลลัพธ์ของ":
                check_dict["BOTTEXT"] = 1
            else:
                check_dict["BOTTEXT"] = "NOT CORRECT"
        else:
            check_dict["BOTTEXT"] = "NOT FOUND"
        #bottom head -- bottom title
        bot_title = soup_in.find('div', {'class': 'col-lg-7 col-xl-6 bg-white show-single-line search-result-head-text text-left'})
        if bot_title:
            bot_title = bot_title.find('span')
            if bot_title:
                bot_title = bot_title.text.strip()
                bot_title = bot_title.replace('"',"")
                bot_title = bot_title.strip()
                if bot_title == name:
                    check_dict["BOT TITLE"] = 1
                else:
                    check_dict["BOT TITLE"] = "NOT CORRECT"
            else:
                check_dict["BOT TITLE"] = "NOT FOUND"
        else:
            check_dict["BOT TITLE"] = "NOT FOUND"
            
        #condo list
        condo_list = soup_in.find('div', {'id': 'condo-side-head-block'})
        if condo_list:
            condo_list = condo_list.text.strip()
            if condo_list == "รายชื่อคอนโด":
                check_dict["CONDO LIST"] = 1
            else:
                check_dict["CONDO LIST"] = "NOT CORRECT"
        else:
            check_dict["CONDO LIST"] = "NOT FOUND"
            
        #sort text
        sort_text = soup_in.find('div', {'class': 'mobile-sort-text font-weight-bold'})
        if sort_text:
            sort_text = sort_text.text.strip()
            if sort_text == "เรียงตาม":
                check_dict["SORT TEXT"] = 1
            else:
                check_dict["SORT TEXT"] = "NOT CORRECT"
        else:
            check_dict["SORT TEXT"] = "NOT FOUND"
            
        #sort list    
        s_list = soup_in.find('select', {'id': 'condo_select_order'})
        if s_list:
            for d, sort_list in enumerate(s_list.find_all('option')) :
                if sort_list:
                    sort_list_text = sort_list.text.strip()
                    if d == 0:
                        if sort_list_text == "ยอดนิยม":
                            check_dict["LIST HOT"] = 1
                        else:
                            check_dict["LIST HOT"] = "NOT CORRECT"
                    if d == 1:
                        if sort_list_text == "ราคา : น้อย > มาก":
                            check_dict["price_asc"] = 1
                        else:
                            check_dict["price_asc"] = "NOT CORRECT"
                    if d == 2:
                        if sort_list_text == "ราคา : มาก > น้อย":
                            check_dict["price_desc"] = 1
                        else:
                            check_dict["price_desc"] = "NOT CORRECT"
                    if d == 3:
                        if sort_list_text == "ปี : ใหม่ > เก่า":
                            check_dict["year_asc"] = 1
                        else:
                            check_dict["year_asc"] = "NOT CORRECT"
                    if d == 4:
                        if sort_list_text == "ปี : เก่า > ใหม่":
                            check_dict["year_desc"] = 1
                        else:
                            check_dict["year_desc"] = "NOT CORRECT"
            
        #list mode row                    
        mode_row = soup_in.find('i', {'class': 'fa-solid fa-list'})
        if mode_row:
            check_dict["LIST ROW"] = 1
        else:
            check_dict["LIST ROW"] = "NOT FOUND"
            
        #list mode    
        list_mode = soup_in.find('i', {'class': 'fa-solid fa-border-all'})
        if list_mode:
            check_dict["LIST MODE"] = 1
        else:
            check_dict["LIST MODE"] = "NOT FOUND"
            
        #left map box -- icon, text, condo amount    
        left_map_box = soup_in.find('div', {'id': 'map-left-panel-ads'})
        #left map box -- icon
        if left_map_box:
            icon = left_map_box.find('i', {'class': 'fa-solid fa-building'})
            if icon:
                check_dict["ICON"] = 1
            else:
                check_dict["ICON"] = "NOT CORRECT"
            #left map box -- text    
            left_map_text = left_map_box.find('span', {'id': 'left-condo-caption-text'})
            if left_map_text:
                left_map_text = left_map_text.text.strip()
                if left_map_text == "Condo":
                    check_dict["LEFT MAP TEXT"] = 1
                else:
                    check_dict["LEFT MAP TEXT"] = "NOT CORRECT"
            else:
                check_dict["LEFT MAP TEXT"] = "NOT FOUND"
            #left map box -- condo amount
            left_map_amount = left_map_box.find('div', {'class': 'condo-search-left-mode-result-block condo-search-left-mode-result-text total_condo_found'})
            if left_map_amount:
                left_map_amount = left_map_amount.text.strip()
                if left_map_amount == count:
                    check_dict["LEFT MAP COUNT"] = 1
                else:
                    check_dict["LEFT MAP COUNT"] = "NOT CORRECT"
            else:
                check_dict["LEFT MAP COUNT"] = "NOT FOUND"
        else:
            check_dict["ICON"] = "NOT FOUND"
            check_dict["LEFT MAP TEXT"] = "NOT FOUND"
        
        #map menu -- similar, recommand, all   
        map_menu = soup_in.find('div', {'class': 'switcher shadow'})
        if map_menu:
            check_dict["MAP MENU"] = 1
            for m, map_section in enumerate(map_menu.find_all('label')) :
                if map_section:
                    #similar
                    if m == 0:
                        s_icon = map_section.find('i', {'class': 'fas fa-clone'})
                        if s_icon:
                            check_dict["SIMILAR ICON"] = 1
                        else:
                            check_dict["SIMILAR ICON"] = "NOT CORRECT"
                        s_name = map_section.text.strip()
                        if s_name == "คล้ายกัน":
                            check_dict["SIMILAR TEXT"] = 1
                        else:
                            check_dict["SIMILAR TEXT"] = "NOT CORRECT"
                    #recommand
                    elif m == 1:
                        r_icon = map_section.find('i', {'class': 'fas fa-thumbs-up'})
                        if r_icon:
                            check_dict["RECOMMAND ICON"] = 1
                        else:
                            check_dict["RECOMMAND ICON"] = "NOT CORRECT"
                        r_name = map_section.text.strip()
                        r_name = re.sub(r"\([^()]*\)", "", r_name).strip()
                        if r_name == "ยอดนิยม":
                            check_dict["RECOMMAND TEXT"] = 1
                        else:
                            check_dict["RECOMMAND TEXT"] = "NOT CORRECT"
                        r_amount = map_section.find("span")
                        r_amount = r_amount.text.strip()
                        r_amount = r_amount.replace("(","")
                        r_amount = r_amount.replace(")","")
                        r_amount = int(r_amount)
                        if r_amount:
                            check_dict["RECOMMAND AMOUNT"] = 1
                        else:
                            check_dict["RECOMMAND AMOUNT"] = "NOT CORRECT"
                    #all
                    else:
                        a_icon = map_section.find('i', {'class': 'fas fa-compass'})
                        if a_icon:
                            check_dict["ALL ICON"] = 1
                        else:
                            check_dict["ALL ICON"] = "NOT CORRECT"
                        a_name = map_section.text.strip()
                        a_name = re.sub(r"\([^()]*\)", "", a_name).strip()
                        if a_name == "ทั้งหมด":
                            check_dict["ALL TEXT"] = 1
                        else:
                            check_dict["ALL TEXT"] = "NOT CORRECT"
                        a_amount = map_section.find("span")
                        a_amount = a_amount.text.strip()
                        a_amount = a_amount.replace("(","")
                        a_amount = a_amount.replace(")","")
                        if a_amount:
                            check_dict["ALL AMOUNT"] = 1
                            if a_amount == count:
                                check_dict["ALL AMOUNT COUNT"] = 1
                            else:
                                check_dict["ALL AMOUNT COUNT"] = "NOT CORRECT"
                        else:
                            check_dict["ALL AMOUNT"] = "NOT FOUND"
                            check_dict["ALL AMOUNT COUNT"] = "NOT FOUND"
                else:
                    check_dict["SIMILAR ICON"] = "NOT FOUND"
                    check_dict["SIMILAR TEXT"] = "NOT FOUND"
                    check_dict["RECOMMAND ICON"] = "NOT FOUND"
                    check_dict["RECOMMAND TEXT"] = "NOT FOUND"
                    check_dict["RECOMMAND AMOUNT"] = "NOT FOUND"
                    check_dict["ALL ICON"] = "NOT FOUND"
                    check_dict["ALL TEXT"] = "NOT FOUND"
                    check_dict["ALL AMOUNT"] = "NOT FOUND"
                    check_dict["ALL AMOUNT COUNT"] = "NOT FOUND"
        else:
            check_dict["MAP MENU"] = "NOT FOUND"
            check_dict["SIMILAR ICON"] = "NOT FOUND"
            check_dict["SIMILAR TEXT"] = "NOT FOUND"
            check_dict["RECOMMAND ICON"] = "NOT FOUND"
            check_dict["RECOMMAND TEXT"] = "NOT FOUND"
            check_dict["RECOMMAND AMOUNT"] = "NOT FOUND"
            check_dict["ALL ICON"] = "NOT FOUND"
            check_dict["ALL TEXT"] = "NOT FOUND"
            check_dict["ALL AMOUNT"] = "NOT FOUND"
            check_dict["ALL AMOUNT COUNT"] = "NOT FOUND"
        
        #satellite
        satellite = soup_in.find('div', {'id': 'standard_mode_btn'})
        if satellite:
            satellite = satellite.find('img')
            if satellite:
                satellite = satellite.get('src')
                if satellite == "/realist/assets/images/sattellite_icon.png":
                    check_dict["SATELLITE"] = 1
                else:
                    check_dict["SATELLITE"] = "NOT CORRECT"
            else:
                check_dict["SATELLITE"] = "NOT FOUND"
        else:
            check_dict["SATELLITE"] = "NOT FOUND"
            
        #realist in map
        sticker = soup_in.find('div', {'id': 'map-full'})
        if sticker:
            sticker = sticker.find('img')
            if sticker:
                sticker = sticker.get('src')
                if sticker == "/realist/assets/images/logo-green-black.png":
                    check_dict["STICKER"] = 1
                else:
                    check_dict["STICKER"] = "NOT CORRECT"
            else:
                check_dict["STICKER"] = "NOT FOUND"
        else:
            check_dict["STICKER"] = "NOT FOUND"
            
    #cover -- defualt or own pic
    cover = soup_in.find('source', {'media': '(min-width: 1920px)'})
    if cover:
        file = cover.get('srcset')
        if file == 'http://159.223.51.33/realist/condo/uploads/cover/'+a+'-Default-H-1920.jpg':
            check_dict["COVER"] = 'DEFAULT'
        else:
            check_dict["COVER"] = 1
    else:
        check_dict["COVER"] = "NOT FOUND"
                
    #menu_1 -- menu open list
    bar = soup_in.find('div', {'class': 'row align-items-center pt-1 m-0'})
    if bar:
        bar_1 = bar.find('div', {'class': 'col-2'})
        if bar_1:
            bar_1_s = bar_1.find('button', {'type': 'button'})
            if bar_1_s:
                check_dict["MENU_1"] = 1
            else:
                check_dict["MENU_1"] = "NOT CORRECT"
            #menu_1 -- pic png
            bar_1_name = bar_1.find('button', {'type': 'button'})
            if bar_1_name:
                bar_1_name = bar_1.find('img', {'alt': 'logo'})
                if bar_1_name:
                    bar_1_name = bar_1_name.get('src')
                    if bar_1_name:
                        check_dict["MENU_1_PIC"] = 1
                    else:
                        check_dict["MENU_1_PIC"] = "NOT CORRECT"
                else:
                    check_dict["MENU_1_PIC"] = "NOT FOUND"
            else:
                check_dict["MENU_1_PIC"] = "NOT FOUND"
        else:
            check_dict["MENU_1"] = "NOT FOUND"
            check_dict["MENU_1_PIC"] = "NOT FOUND"
    else:
        check_dict["MENU_1"] = "NOT FOUND"
        check_dict["MENU_1_PIC"] = "NOT FOUND"

    #menu2-7
    if bar:
        for b , bar_list in enumerate(bar.find_all('div' ,{'class':"col-auto"})) :
            if bar_list:
                #menu_2 -- condo_data
                if b == 1:
                    bar_2 = bar_list.text.strip()
                    if bar_2 == "Condo Data":
                        check_dict["MENU_2"] = 1
                    else:
                        check_dict["MENU_2"] = "NOT CORRECT"
                #menu_3 -- realist_blog
                elif b == 2:
                    bar_3 = bar_list.text.strip()
                    if bar_3 == "realist blog":
                        check_dict["MENU_3"] = 1
                    else:
                        check_dict["MENU_3"] = "NOT CORRECT"
                #menu_4 -- facebook
                elif b == 3:
                    bar_4 = bar_list.text.strip()
                    if bar_4 == "facebook":
                        check_dict["MENU_4"] = 1
                    else:
                        check_dict["MENU_4"] = "NOT CORRECT"
                #menu_5 -- youtube
                elif b == 4:
                    bar_5 = bar_list.text.strip()
                    if bar_5 == "youtube":
                        check_dict["MENU_5"] = 1
                    else:
                        check_dict["MENU_5"] = "NOT CORRECT"
                #menu_6 -- instagram
                elif b == 5:
                    bar_6 = bar_list.text.strip()
                    if bar_6 == "instagram":
                        check_dict["MENU_6"] = 1
                    else:
                        check_dict["MENU_6"] = "NOT CORRECT"
                #menu_7 -- line@
                elif b == 6:
                    bar_7 = bar_list.text.strip()
                    if bar_7 == "line@":
                        check_dict["MENU_7"] = 1
                    else:
                        check_dict["MENU_7"] = "NOT CORRECT"
            else:
                check_dict["MENU_2"] = "NOT FOUND"
                check_dict["MENU_3"] = "NOT FOUND"
                check_dict["MENU_4"] = "NOT FOUND"
                check_dict["MENU_5"] = "NOT FOUND"
                check_dict["MENU_6"] = "NOT FOUND"
                check_dict["MENU_7"] = "NOT FOUND"
    else:
        check_dict["MENU_2"] = "NOT FOUND"
        check_dict["MENU_3"] = "NOT FOUND"
        check_dict["MENU_4"] = "NOT FOUND"
        check_dict["MENU_5"] = "NOT FOUND"
        check_dict["MENU_6"] = "NOT FOUND"
        check_dict["MENU_7"] = "NOT FOUND"
                    
    #title
    info = soup_in.find('div', {'class': 'col-12 col-lg-6 px-0'})
    if info:
        info = info.find('h2')
        if info:
            title = info.text.strip()
            title = title.replace('"',"")
            title = title.strip()
            if title == name:
                check_dict["TITLE"] = 1
            else:
                check_dict["TITLE"] = "NOT CORRECT"
        else:
            check_dict["TITLE"] = "NOT FOUND"
    else:
        check_dict["TITLE"] = "NOT FOUND"
            
    #amount        
    amount = soup_in.find('div', {'class': 'col-lg-6 col-12 p-0'})
    if amount:
        amount = amount.find('span')
        if amount:
            amount = amount.text.strip()
            if amount == count:
                check_dict["COUNT"] = 1
            else:
                check_dict["COUNT"] = "NOT CORRECT"
        else:
            check_dict["AMOUNT"] = "NOT FOUND"
    else:
        check_dict["AMOUNT"] = "NOT FOUND"
            
    #text info    
    text_title = soup_in.find('p', {'class': 'text-realist-white'})
    if text_title:
        text_title = text_title.text.strip()
        if text_title:
            check_dict["TEXT TITLE"] = 1
        else:
            check_dict["TEXT TITLE"] = "DONT HAVE TEXT"
    else:
        check_dict["TEXT TITLE"] = "NOT FOUND"
            
    #stat header    
    stat = soup_in.find('div', {'class': 'stat-section'})
    if stat:
        stat_header = stat.find('p')
        if stat_header:
            stat_header = stat_header.text.strip()
            if stat_header == "สรุปข้อมูลคอนโด ( 5 ปีล่าสุด )":
                check_dict["STAT HEADER"] = 1
            else:
                check_dict["STAT HEADER"] = "NOT CORRECT"
        else:
            check_dict["STAT HEADER"] = "NOT FOUND"
    else:
        check_dict["STAT HEADER"] = "NOT FOUND"
            
    #stat name    
    stat_name = stat.find('h2')
    if stat_name:
        stat_name = stat_name.text.strip()
        if stat_name == name:
            check_dict["STAT NAME"] = 1
        else:
            check_dict["STAT NAME"] = "NOT CORRECT"
    else:
        check_dict["STAT NAME"] = "NOT FOUND"
            
    #stat_1 -- ราคาเฉลี่ย    
    stat_1 = soup_in.find('div', {'class': 'row align-items-center m-0'})
    if stat_1:
        stat_section = stat_1.find('div', {'class': 'col-6 text-center pl-0 pr-1'})
        if stat_section:
            stat_section = stat_section.find('p')
            if stat_section:
                stat_section = stat_section.text.strip()
                if stat_section == "ราคาเฉลี่ย":
                    check_dict["AVG_PRICE"] = 1
                else:
                    check_dict["AVF_PRICE"] = "NOT CORRECT"
            else:
                check_dict["AVF_PRICE"] = "NOT FOUND"
        else:
            check_dict["AVF_PRICE"] = "NOT FOUND"
    else:
        check_dict["AVF_PRICE"] = "NOT FOUND"
            
    #stat_2 -- ราคาเฉลี่ย/ยูนิต    
    stat_2 = stat_1.find('div', {'class': 'col-6 text-center pr-0 pl-1'})
    if stat_2:
        stat_section = stat_2.find('p')
        if stat_section:
            stat_section = stat_section.text.strip()
            if stat_section == "ราคาเฉลี่ย/ยูนิต":
                check_dict["AVG_PRICE/UNIT"] = 1
            else:
                check_dict["AVG_PRICE/UNIT"] = "NOT CORRECT"
        else:
            check_dict["AVG_PRICE/UNIT"] = "NOT FOUND"
    else:
        check_dict["AVG_PRICE/UNIT"] = "NOT FOUND"
            
    #stat_3 -- จำนวนคอนโด, จำนวนยูนิตรวม, จำนวนยูนิตเฉลี่ย / โครงการ, ขนาดห้องเฉลี่ย, อัตราส่วนที่จอดรถต่อห้อง
    #stat_4 -- ค่าส่วนกลางเฉลี่ย, ค่าเช่าเฉลี่ย, Rental Yield
    for l , stat_list in enumerate(stat_1.find_all('div' ,{'class':"col-lg-12 mt-2 p-0"})) :
        if stat_list:
            c = 0
            for c, stat_3 in enumerate(stat_list.find_all('div' ,{'class':"row mx-0 my-2"})) :
                if stat_3:
                    stat_3 = stat_3.find('div' ,{'class':"col-6 pr-0 text-realist-white text-left"})
                    if stat_3:
                        stat_3 = stat_3.text.strip()
                        if l == 0:
                            #stat_3 -- จำนวนคอนโด
                            if c == 0:
                                if stat_3 == "จำนวนคอนโด":
                                    check_dict["CONDO_COUNT_5_YEAR"] = 1
                                else:
                                    check_dict["CONDO_COUNT_5_YEAR"] = "NOT CORRECT"
                            #stat_3 -- จำนวนยูนิตรวม
                            elif c == 1:
                                if stat_3 == "จำนวนยูนิตรวม":
                                    check_dict["UNIT_COUNT_5_YEAR"] = 1
                                else:
                                    check_dict["UNIT_COUNT_5_YEAR"] = "NOT CORRECT"
                            #stat_3 -- จำนวนยูนิตเฉลี่ย / โครงการ
                            elif c == 2:
                                if stat_3 == "จำนวนยูนิตเฉลี่ย / โครงการ":
                                    check_dict["AVG_UNIT_COUNT_5_YEAR"] = 1
                                else:
                                    check_dict["AVG_UNIT_COUNT_5_YEAR"] = "NOT CORRECT"
                            #stat_3 -- ขนาดห้องเฉลี่ย
                            elif c == 3:
                                if stat_3 == "ขนาดห้องเฉลี่ย":
                                    check_dict["ROOM_5_YEAR"] = 1
                                else:
                                    check_dict["ROOM_5_YEAR"] = "NOT CORRECT"
                            #stat_3 -- อัตราส่วนที่จอดรถต่อห้อง
                            else:
                                if stat_3 == "อัตราส่วนที่จอดรถต่อห้อง":
                                    check_dict["PARKING_5_YEAR"] = 1
                                else:
                                    check_dict["PARKING_5_YEAR"] = "NOT CORRECT"
                        elif l == 1:
                            #stat_4 -- ค่าส่วนกลางเฉลี่ย
                            if c == 0:
                                if stat_3 == "ค่าส่วนกลางเฉลี่ย":
                                    check_dict["COMMONFEE"] = 1
                                else:
                                    check_dict["COMMONFEE"] = "NOT CORRECT"
                            #stat_4 -- ค่าเช่าเฉลี่ย        
                            elif c == 1:
                                if stat_3 == "ค่าเช่าเฉลี่ย":
                                    check_dict["RENT"] = 1
                                else:
                                    check_dict["RENT"] = "NOT CORRECT"
                            #stat_4 -- Rental Yield        
                            elif c == 2:
                                if stat_3 == "Rental Yield":
                                    check_dict["Rental Yield"] = 1
                                else:
                                    check_dict["Rental Yield"] = "NOT CORRECT"
                    else:
                        check_dict["CONDO_COUNT_5_YEAR"] = "NOT FOUND"
                        check_dict["UNIT_COUNT_5_YEAR"] = "NOT FOUND"
                        check_dict["AVG_UNIT_COUNT_5_YEAR"] = "NOT FOUND"
                        check_dict["ROOM_5_YEAR"] = "NOT FOUND"
                        check_dict["PARKING_5_YEAR"] = "NOT FOUND"
                        check_dict["COMMONFEE"] = "NOT FOUND"
                        check_dict["RENT"] = "NOT FOUND"
                        check_dict["Rental Yield"] = "NOT FOUND"
                else:
                    check_dict["CONDO_COUNT_5_YEAR"] = "NOT FOUND"
                    check_dict["UNIT_COUNT_5_YEAR"] = "NOT FOUND"
                    check_dict["AVG_UNIT_COUNT_5_YEAR"] = "NOT FOUND"
                    check_dict["ROOM_5_YEAR"] = "NOT FOUND"
                    check_dict["PARKING_5_YEAR"] = "NOT FOUND"
                    check_dict["COMMONFEE"] = "NOT FOUND"
                    check_dict["RENT"] = "NOT FOUND"
                    check_dict["Rental Yield"] = "NOT FOUND"
        else:
            check_dict["CONDO_COUNT_5_YEAR"] = "NOT FOUND"
            check_dict["UNIT_COUNT_5_YEAR"] = "NOT FOUND"
            check_dict["AVG_UNIT_COUNT_5_YEAR"] = "NOT FOUND"
            check_dict["ROOM_5_YEAR"] = "NOT FOUND"
            check_dict["PARKING_5_YEAR"] = "NOT FOUND"
            check_dict["COMMONFEE"] = "NOT FOUND"
            check_dict["RENT"] = "NOT FOUND"
            check_dict["Rental Yield"] = "NOT FOUND"
    #stat_5 -- ยอดขาย, ยอดโอน
    stat_5 = stat_1.find('div', {'class': 'col-12 mt-2 p-0'})
    if stat_5:
        for j , stat_5_list in enumerate(stat_5.find_all('div' ,{'class':"row align-items-center mx-0 my-2"})) :
            if stat_5_list:
                stat_5_in = stat_5_list.find('p')
                if stat_5_in:
                    stat_5_in = stat_5_in.text.strip()
                    #stat_5 -- ยอดขาย
                    if j == 0:
                        if stat_5_in == "ยอดขาย":
                            check_dict["SALE"] = 1
                        else:
                            check_dict["SALE"] = "NOT CORRECT"
                    #stat_5 -- ยอดโอน
                    elif j == 1:
                        if stat_5_in == "ยอดโอน":
                            check_dict["TRANSFER"] = 1
                        else:
                            check_dict["TRANSFER"] = "NOT CORRECT"
                else:
                    check_dict["SALE"] = "NOT FOUND"
                    check_dict["TRANSFER"] = "NOT FOUND"
            else:
                check_dict["SALE"] = "NOT FOUND"
                check_dict["TRANSFER"] = "NOT FOUND"
    else:
        check_dict["SALE"] = "NOT FOUND"
        check_dict["TRANSFER"] = "NOT FOUND"
            
    #stat_6_1 -- คอนโดสร้างแล้วเสร็จ
    #stat6_2 -- คอนโดใหม่/กำลังก่อสร้าง    
    stat_6 = stat_1.find('div', {'class': 'col-lg-12 mt-2 p-0 d-none d-lg-block'})
    if stat_6:
        #stat_6_1 -- คอนโดสร้างแล้วเสร็จ
        stat_6_1 = stat_6.find('div', {'class': 'col-5 text-right p-0'})
        if stat_6_1:
            stat_6_1 = stat_6_1.find('p')
            if stat_6_1:
                stat_6_1 = stat_6_1.text.strip()
                if stat_6_1 == "คอนโดสร้างแล้วเสร็จ":
                    check_dict["FINISHED_BUILD"] = 1
                else:
                    check_dict["FINISHED_BUILD"] = "NOT CORRECT"
            else:
                check_dict["FINISHED_BUILD"] = "NOT FOUND"
        else:
            check_dict["FINISHED_BUILD"] = "NOT FOUND"
        #stat6_2 -- คอนโดใหม่/กำลังก่อสร้าง
        stat_6_2 = stat_6.find('div', {'class': 'col-5 p-0 text-left'})
        if stat_6_2:
            stat_6_2 = stat_6_2.find('p')
            if stat_6_2:
                stat_6_2 = stat_6_2.text.strip()
                if stat_6_2 == "คอนโดใหม่/กำลังก่อสร้าง":
                    check_dict["NEW/UNDER CONSTRUCTION"] = 1
                else:
                    check_dict["NEW/UNDER CONSTRUCTION"] = "NOT CORRECT"
            else:
                check_dict["NEW/UNDER CONSTRUCTION"] = "NOT FOUND"
        else:
            check_dict["NEW/UNDER CONSTRUCTION"] = "NOT FOUND"
    else:
        check_dict["FINISHED_BUILD"] = "NOT FOUND"
        check_dict["NEW/UNDER CONSTRUCTION"] = "NOT FOUND"
            
    #result_text
    #result_symbol   
    search = soup_in.find('button', {'class': 'search-result-button text-realist-white'})
    #result_text
    if search:
        search_text = search.text.strip()
        if search_text ==  "ดูผลการค้นหา":
            check_dict["RESULT_TEXT"] = 1
        else:
            check_dict["RESULT_TEXT"] = "NOT CORRECT"
        #result_symbol
        search_text_s = search.find('i')
        if search_text_s:
            check_dict["RESULT SYMBOL"] = 1
        else:
            check_dict["RESULT SYMBOL"] = "NOT CORRECT"
    else:
        check_dict["RESULT_TEXT"] = "NOT FOUND"
        check_dict["RESULT SYMBOL"] = "NOT FOUND"
            
    #search symbol 
    glasses = soup_in.find('button', {'class': 'bg-transparent border-0 topbar-search-button'})
    if glasses:
        glasses_s = glasses.find('i', {'class': 'fa-solid fa-magnifying-glass text-realist-white'})
        if glasses_s:
            check_dict["SEARCH"] = 1
        else:
            check_dict["SEARCH"] = "NOT CORRECT"
    else:
        check_dict["SEARCH"] = "NOT FOUND"
            
    test_function_2()
    
def test_function_3():
    #condo box    
        condo = soup_in.find('div', {'id': 'intial-condo-list'})
        if condo:
            condo = condo.find('div', {'class': 'container lazyload'})
            if condo:
                check_dict["CONDO BOX"] = 1
            else:
                check_dict["CONDO BOX"] = "NOT CORRECT"
        else:
            check_dict["CONDO BOX"] = "NOT FOUND"
            
        #expand map -- left, right
        #left
        left = soup_in.find('div', {'id': 'btn-open-full-map-left'})
        if left:
            left = left.find('i', {'class': 'fas fa-angle-left'})
            check_dict["LEFT"] = 1
            if left:
                check_dict["LEFT ICON"] = 1
            else:
                check_dict["LEFT ICON"] = "NOT FOUND"
        else:
            check_dict["LEFT"] = "NOT FOUND"
            check_dict["LEFT ICON"] = "NOT FOUND"
        #right        
        right = soup_in.find('div', {'id': 'btn-open-full-map-right'})
        if right:
            right = right.find('i', {'class': 'fas fa-angle-right'})
            check_dict["RIGHT"] = 1
            if right:
                check_dict["RIGHT ICON"] = 1
            else:
                check_dict["RIGHT ICON"] = "NOT FOUND"
        else:
            check_dict["RIGHT"] = "NOT FOUND"
            check_dict["RIGHT ICON"] = "NOT FOUND"
        
        #for condo_mark#
        map_menu = soup_in.find('div', {'class': 'switcher shadow'})
        for map, map_section in enumerate(map_menu.find_all('label')) :
            if map == 1:
                r_amount = map_section.find("span")
                r_amount = r_amount.text.strip()
                r_amount = r_amount.replace("(","")
                r_amount = r_amount.replace(")","")
                r_amount = int(r_amount)
        #########################################################################
        
        #condo_mark
        condo_mark = soup_in.find('div', {'aria-label': 'Map'})
        if condo_mark:
            for k, condo in enumerate(condo_mark.find_all('div' ,{'class':"condo-marker-s"})) :
                r_amount = r_amount
            if k == r_amount-1:
                check_dict["CONDO MARK"] = 1
            else:
                check_dict["CONDO MARK"] = "NOT CORRECT"
        else:
            check_dict["CONDO MARK"] = "NOT FOUND"
            
        #condo mark color
        element = browser.find_element(By.CSS_SELECTOR , 'div.condo-marker-s')
        if element:
            background_color = element.value_of_css_property("background-color")
            rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
            hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
            if hex_color == "#26b7be":
                check_dict["CONDO MARK COLOR"] = 1
            else:
                check_dict["CONDO MARK COLOR"] = "NOT CORRECT"
        else:
            check_dict["CONDO MARK COLOR"] = "NOT FOUND"
            
        #click condo_mark -- condo_mark_icon_bg, condo_mark_icon, condo_mark_icon_color, condo_mark_name
        element = browser.find_element(By.CLASS_NAME , 'condo-marker-s')
        ActionChains(browser)\
            .click(element)\
            .perform()
        time.sleep(1)
        soup_inn = bs(browser.page_source, 'html.parser')
        mark_condo = soup_inn.find('div' ,{'class':"gm-style-iw-d"})
        for mark , m_condo in enumerate(mark_condo.find_all('td')) :
            if m_condo:
                icon_bg_condo = m_condo.find('div')
                #condo_mark_icon_bg
                if icon_bg_condo:
                    icon_bg_condo = icon_bg_condo.get('style')
                    icon_bg_condo = icon_bg_condo.split(";")[4]
                    icon_bg_condo = icon_bg_condo.replace("background:","")
                    icon_bg_condo = icon_bg_condo.strip()
                    if icon_bg_condo == "#26b7be":
                        check_dict["CONDO_MARK_ICON_BG"] = 1
                    else:
                        check_dict["CONDO_MARK_ICON_BG"] = "NOT CORRECT"
                    #condo_mark_icon
                    icon_condo = m_condo.find('i')
                    icon_condo = icon_condo.get('class')
                    i_condo = icon_condo[1]
                    if i_condo == 'fa-building':
                        check_dict["CONDO_MARK_ICON"] = 1
                    else:
                        check_dict["CONDO_MARK_ICON"] = "NOT CORRECT"
                    #condo_mark_icon_color
                    ic_condo = icon_condo[2].split("-")[1]
                    if ic_condo == "white":
                        check_dict["CONDO_MARK_ICON_COLOR"] = 1
                    else:
                        check_dict["CONDO_MARK_ICON_COLOR"] = "NOT CORRECT"
                #condo_mark_name
                else:
                    name_condo = m_condo.find('span')
                    name_condo = name_condo.text.strip()
                    if name_condo:
                        check_dict["CONDO_MARK_NAME"] = 1
                    else:
                        check_dict["CONDO_MARK_NAME"] = "NOT CORRECT"
            else:
                check_dict["CONDO_MARK_ICON_BG"] = "NOT FOUND"
                check_dict["CONDO_MARK_ICON"] = "NOT FOUND"
                check_dict["CONDO_MARK_ICON_COLOR"] = "NOT FOUND"
                check_dict["CONDO_MARK_NAME"] = "NOT FOUND"
        
        #home button -- home_link, home_button, home_listing_text     
        home = soup_inn.find('div' ,{'class':"mobile-container"})
        for h , home_button in enumerate(home.find_all('li')) :
            if home_button:
                if h == 0:
                    #home link
                    home_link = home_button.find('a')
                    home_link = home_link.get('href')
                    if home_link == "http://159.223.51.33/realist/condo/":
                        check_dict["HOME LINK"] = 1
                    else:
                        check_dict["HOME LINK"] = "NOT CORRECT"
                    #home button
                    home_text = home_button.find('a')
                    home_text = home_text.text.strip()
                    if home_text == "Home":
                        check_dict["HOME BUTTON"] = 1
                    else:
                        check_dict["HOME BUTTON"] = "NOT CORRECT"
                else:
                    #home listing text
                    home_list_text = home_button.text.strip()
                    if home_list_text == name:
                        check_dict["HOME LISTING TEXT"] = 1
                    else:
                        check_dict["HOME LISTING TEXT"] = "NOT CORRECT"
            else:
                check_dict["HOME LINK"] = "NOT FOUND"
                check_dict["HOME BUTTON"] = "NOT FOUND"
                check_dict["HOME LISTING TEXT"] = "NOT FOUND"
        test_list.append(check_dict)
        browser.close()

#Spotlight
spotlight = soup.find('div', {'id': 'top-spotlight'})
while x in range(0,3):
    for i , list in enumerate(spotlight.find_all('div' ,{'class':"py-1"})) :
        y = randint(0,30)
        #if i == y:
        if x==3:
            break
        if list:
            section = list.find('a')
            if section:
                name = section.text.strip()
                link = section.get('href')
                urls = ("http://159.223.51.33",link)
                urls = "".join(urls)
                check_dict = {"LISTING": name, "COVER": ""}
                condo_count = list.find('p')
                count = condo_count.text.strip()
                count = count.replace("(","")
                count = count.replace(")","")
            
                browser = webdriver.Chrome()
                browser.get(urls)
                browser.maximize_window()
                time.sleep(2)
                browser.refresh()
                time.sleep(5)
                browser.execute_script("window.scrollTo(0, 900)")
                time.sleep(3)
                soup_in = bs(browser.page_source, 'html.parser')
        x += 1
        test_function("Spotlight")
        test_function_3()

#Price
#x = 0
#i = 0
#price = soup.find('div', {'id': 'top-price'})
#while x in range(0,3):
#    for i , list in enumerate(price.find_all('div' ,{'class':"py-1"})) :
#        if i in range(0,6):
#            y = randint(0,27)
#            if i == y:
#                test_function("Segment")
#                if x==3:
#                    break
#                x += 1
test_df = pd.DataFrame(test_list)
test_df.to_csv('test_2023.csv')         
print("done")
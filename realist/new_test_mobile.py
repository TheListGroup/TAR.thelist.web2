#top_bar
    #LISTING
        #icon
            #color
    #HOME
        #home link
        #home pic
    #SEARCH
        #search icon
            #search color
        #search click
            #in_searh_click_bgcolor 
            #input_click
                #input_search_click
                    #search_result_condo
                    #search_result_train
                #input_search_bgcolor
                #input_search_text
            #search_button
                #search_button_bgcolor
                #search_button_text
                #search_button_text_color
            #back_button
                #back_icon
                    #back_icon_color
                #back_click
    #top_bar_bgcolor
    #LISTING_CLICK
        #in listing bgcolor
        #top in list click
            #condo data
                #condo data icon
                #condo data link
                #condo data text
            #realist_blig
                #realist blog icon
                #realist blog link
                #realist blog text
            #listing_info
                #listing text
                    #listing text color
                #listing icon
                    #listing icon color 
            #listing click
            #social
                #social link
                #social icon
#HEADER
    #top head
    #header text
        #header text color
    #cover text
        #begin_quote
            #begin_quote_color
        #cover_text
            #cover_text_color
        #end_quote
            #end_quote_color
#HELP_SEARCH
    #help_search_text
        #help_search_text_color    
    #help_search_input
        #help_search_input_text
        #help_search_input_text_color
        #help_search_input_bgcolor
        #help_search_input_click 
            #in_help_search_bgcolor
            #input_help_search_click
                #help_search_result_condo
                #help_search_result_train
            #input_help_search_bgcolor
            #input_help_search_text
            #help_search_button
                #help_search_button_bgcolor
                #help_search_button_text
                    #help_search_button_text_color
            #help_search_back_button
                #help_search_back_icon
                    #help_search_back_icon_color
                #help_search_back_click
    #or_text
        #or_text_color
    #help_search_map_button
        #help_search_map_button_color
        #help_search_map_icon
        #help_search_map_button_click
            #help_search_map_top_bar
                #help_search_map_LISTING
                    #help_search_map_icon
                        #help_search_map_color
                #help_search_map_HOME
                    #help_search_map_home link
                    #help_search_map_home pic
                #help_search_map_SEARCH
                    #help_search_map_search icon
                        #help_search_map_search color
                    #help_search_map_search click
                        #help_search_map_in_searh_click_bgcolor 
                        #help_search_map_input_click
                            #help_search_map_input_search_click
                                #help_search_map_search_result_condo
                                #help_search_map_search_result_train
                            #help_search_map_input_search_bgcolor
                            #help_search_map_input_search_text
                        #help_search_map_search_button
                            #help_search_map_search_button_bgcolor
                            #help_search_map_search_button_text
                            #help_search_map_search_button_text_color
                        #help_search_map_back_button
                            #help_search_map_back_icon
                                #help_search_map_back_icon_color
                            #help_search_map_back_click
                #help_search_map_top_bar_bgcolor
                #help_search_map_LISTING_CLICK
                    #help_search_map_in listing bgcolor
                    #help_search_map_top in list click
                        #help_search_map_condo data
                            #help_search_map_condo data icon
                            #help_search_map_condo data link
                            #help_search_map_condo data text
                        #help_search_map_realist_blig
                            #help_search_map_realist blog icon
                            #help_search_map_realist blog link
                            #help_search_map_realist blog text
                        #help_search_map_listing_info
                            #help_search_map_listing text
                                #help_search_map_listing text color
                            #help_search_map_listing icon
                                #help_search_map_listing icon color 
                        #help_search_map_listing click
                        #help_search_map_social
                            #help_search_map_social link
                            #help_search_map_social icon

from selenium import webdriver
from bs4 import BeautifulSoup as bs
import pandas as pd
import time
import re
from selenium.webdriver import ActionChains
from selenium.webdriver.common.by import By
from random import randint
from collections import Counter

url ='http://159.223.51.33/realist/condo/'
test_list = []
# test commit 3, another file
browser = webdriver.Chrome()
browser.set_window_size(390, 844)
browser.get("http://google.com")
browser.get(url)
soup = bs(browser.page_source, 'html.parser')

def input_search_not_found(s):
    check_dict["INPUT_"+s] = "NOT FOUND"
    check_dict[s+"_RESULT_CONDO"] = "NOT FOUND"
    check_dict[s+"_RESULT_TRAIN"] = "NOT FOUND"
    check_dict["INPUT_"+s+"_BGCOLOR"] = "NOT FOUND"
    check_dict["INPUT_"+s+"_TEXT"] = "NOT FOUND"
def search_button_not_found(se):
    check_dict[se+"_BUTTON"] = "NOT FOUND"
    check_dict[se+"_BUTTON_BGCOLOR"] = "NOT FOUND"
    check_dict[se+"_BUTTON_TEXT"] = "NOT FOUND"
    check_dict[se+"_BUTTON_TEXT_COLOR"] = "NOT FOUND"
def search_back_button(sea):
    check_dict[sea+"_BACK_ICON"] = "NOT FOUND"
    check_dict[sea+"_BACK_ICON_COLOR"] = "NOT FOUND"
    check_dict[sea+"_BACK_CLICK"] = "NOT FOUND"
def click_list():
    list_menu = browser.find_element(By.XPATH ,("//button[@data-target='#topbar-mobile']"))
    list_menu.click()
    time.sleep(1)
def search_button_click(sear):
    check_dict[sear+"_CLICK"] = "NOT FOUND"
    check_dict["IN_"+sear+"_BGCOLOR"] = "NOT FOUND"
    input_search_not_found(sear)
    search_button_not_found(sear)
    search_back_button(sear)
def search_click_in(sch):
    #in_search_click_bgcolor 
    in_search_click = soup.find('div', {'class': 'topbar-mobile-container bg-white pb-3'})
    if in_search_click: 
        check_dict["IN_"+sch+"_BGCOLOR"] = 1                    
    else:                 
        check_dict["IN_"+sch+"_BGCOLOR"] = "NOT CORRECT"
    #input_click -- input_search_click, input_search_bgcolor, input_search_text
    input_search = browser.find_element(By.XPATH ,("//input[@class='topbar-mobile-input-text border-0 w-100']"));
    if input_search:
        on_screen = input_search.is_displayed();
        if on_screen:
            #input_search_click
            try:
                input_search.click()
                check_dict["INPUT_"+sch] = 1
                input_search.clear()
                #search_result_condo
                input_search.send_keys("ทองหล่อ")
                time.sleep(3)
                search_result_condo = browser.find_element(By.XPATH ,("//div[@class='container search-result py-1 px-3 mx-2']"));
                on_screen = search_result_condo.is_displayed();
                if on_screen:
                    check_dict[sch+"_RESULT_CONDO"] = 1
                else:
                    check_dict[sch+"_RESULT_CONDO"] = "NOT FOUND"
                search_result_train = browser.find_element(By.XPATH ,("//div[@class='container search-result py-2 pr-3 pl-0 mx-2']"));
                on_screen = search_result_train.is_displayed();
                if on_screen:
                    check_dict[sch+"_RESULT_TRAIN"] = 1
                else:
                    check_dict[sch+"_RESULT_TRAIN"] = "NOT FOUND"
            except:
                check_dict["INPUT_"+sch] = "NOT CORRECT"
                check_dict[sch+"_RESULT_CONDO"] = "NOT FOUND"
                check_dict[sch+"_RESULT_TRAIN"] = "NOT FOUND"
            #input_search_bgcolor
            element = browser.find_element(By.XPATH ,("//input[@class='topbar-mobile-input-text border-0 w-100']"));
            background_color = element.value_of_css_property("background-color")
            rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
            hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
            if hex_color == "#e8e8e8":
                check_dict["INPUT_"+sch+"_BGCOLOR"] = 1
            else:
                check_dict["INPUT_"+sch+"_BGCOLOR"] = "NOT CORRECT"
            #input_search_text
            input_search_text = in_search_click.find('input')
            input_search_text = input_search_text.get('placeholder')
            if input_search_text == "พิมพ์ ชื่อคอนโด / ชื่อผู้พัฒนา / ทำเล / สถานีรถไฟฟ้า":
                check_dict["INPUT_"+sch+"_TEXT"] = 1
            else:
                check_dict["INPUT_"+sch+"_TEXT"] = "NOT CORRECT"
        else:
            input_search_not_found("SEARCH")
    else:
        input_search_not_found("SEARCH")
    #search_button -- search_button_bgcolor, search_button_text
    search_button = browser.find_element(By.XPATH ,("//button[@id='topbar-mobile-text-search-button']"));
    if search_button:
        on_screen = search_button.is_displayed();
        if on_screen:
            check_dict[sch+"_BUTTON"] = 1
            #search_button_bgcolor
            element = browser.find_element(By.XPATH ,("//button[@id='topbar-mobile-text-search-button']"));
            background_color = element.value_of_css_property("background-color")
            rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
            hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
            if hex_color == "#26b7be":
                check_dict[sch+"_BUTTON_BGCOLOR"] = 1
            else:
                check_dict[sch+"_BUTTON_BGCOLOR"] = "NOT CORRECT"
            #search_button_text
            search_button = soup.find('button', {'id': 'topbar-mobile-text-search-button'})
            search_button_text = search_button.text.strip()
            if search_button_text == "ค้นหา":
                check_dict[sch+"_BUTTON_TEXT"] = 1
            else:
                check_dict[sch+"_BUTTON_TEXT"] = "NOT CORRECT"
            #search_button_text_color
            search_button_text_color = search_button.get('class')
            search_button_text_color = str(search_button_text_color)
            if "white" in search_button_text_color:
                check_dict[sch+"_BUTTON_TEXT_COLOR"] = 1
            else:
                check_dict[sch+"_BUTTON_TEXT_COLOR"] = "NOT CORRECT"
        else:
            search_button_not_found("SEARCH")
    else:
        search_button_not_found("SEARCH")
    #back_button -- back_icon, back_click
    back_click = browser.find_element(By.XPATH ,("//button[@class='mobile-topbar-collapse bg-transparent border-0 text-center']"));
    if back_click:
        on_screen = back_click.is_displayed();
        if on_screen:
            #back_icon
            back = soup.find('button', {'class': 'mobile-topbar-collapse bg-transparent border-0 text-center'})
            back_icon = back.find('i')
            back_icon = back_icon.get('class')
            back_icon = str(back_icon)
            if "chevron-left" in back_icon:
                check_dict[sch+"_BACK_ICON"] = 1
            else:
                check_dict[sch+"_BACK_ICON"] = "NOT CORRECT"
            #back_icon_color
            back_icon_color = back.find('h3')
            back_icon_color = back_icon_color.get('class')
            back_icon_color = str(back_icon_color)
            if "black" in back_icon_color:
                check_dict[sch+"_BACK_ICON_COLOR"] = 1
            else:
                check_dict[sch+"_BACK_ICON_COLOR"] = "NOT CORRECT"
            #back_click
            try:
                back_click.click()
                check_dict[sch+"_BACK_CLICK"] = 1
            except:
                check_dict[sch+"_BACK_CLICK"] = "CANT CLICK"
        else:
            search_back_button("SEARCH")
    else:
        search_back_button("SEARCH")

def top_bar(page):
    def input_search_not_found():
        check_dict[page+"_INPUT_SEARCH"] = "NOT FOUND"
        check_dict[page+"_SEARCH_RESULT_CONDO"] = "NOT FOUND"
        check_dict[page+"_SEARCH_RESULT_TRAIN"] = "NOT FOUND"
        check_dict[page+"_INPUT_SEARCH_BGCOLOR"] = "NOT FOUND"
        check_dict[page+"_INPUT_SEARCH_TEXT"] = "NOT FOUND"
    def search_button_not_found():
        check_dict[page+"_SEARCH_BUTTON"] = "NOT FOUND"
        check_dict[page+"_SEARCH_BUTTON_BGCOLOR"] = "NOT FOUND"
        check_dict[page+"_SEARCH_BUTTON_TEXT"] = "NOT FOUND"
        check_dict[page+"_SEARCH_BUTTON_TEXT_COLOR"] = "NOT FOUND"
    def search_back_button():
        check_dict[page+"_SEARCH_BACK_ICON"] = "NOT FOUND"
        check_dict[page+"_SEARCH_BACK_ICON_COLOR"] = "NOT FOUND"
        check_dict[page+"_SEARCH_BACK_CLICK"] = "NOT FOUND"
    def click_list():
        list_menu = browser.find_element(By.XPATH ,("//button[@data-target='#topbar-mobile']"))
        list_menu.click()
        time.sleep(1)
    def search_button_click():
        check_dict[page+"_SEARCH_CLICK"] = "NOT FOUND"
        check_dict[page+"_IN_SEARCH_BGCOLOR"] = "NOT FOUND"
        input_search_not_found()
        search_button_not_found()
        search_back_button()
    def socials(type):
        if type in social_link:
            check_dict[page+'_'+type+'_LINK'] = 1
        else:
            check_dict[page+'_'+type+'_LINK'] = "NOT CORRECT"
        if type in social_icon:
            check_dict[page+'_'+type+'_ICON'] = 1
        else:
            check_dict[page+'_'+type+'_ICON'] = "NOT CORRECT"
    def not_found_menu():
        x = 0
        text = ["คอนโดที่แนะนำ","Spotlight","ราคา","รถไฟฟ้า","ทำเล","ผู้พัฒนาโครงการ","แบรนด์"]
        check_dict[page+"_LIST_BGCOLOR"] = "NOT FOUND"
        while x in range (0,7):
            check_dict[page+'_LISTING_TEXT_'+text[i]] = "NOT FOUND"
            check_dict[page+'_LISTING_TEXT_COLOR_'+text[i]] = "NOT FOUND"
            check_dict[page+'_LISTING_ICON_'+text[i]] = "NOT FOUND"
            check_dict[page+'_LISTING_ICON_COLOR_'+text[i]] = "NOT FOUND"
            x+=1
    def list_click_not_found():
        x = 0
        text = ["คอนโดที่แนะนำ","Spotlight","ราคา","รถไฟฟ้า","ทำเล","ผู้พัฒนาโครงการ","แบรนด์"]
        while x in range (0,7):
            check_dict[page+'_'+text[x]+'_CLICK'] = "NOT FOUND"
            x += 1
    def not_found():
        check_dict[page+"_BGCOLOR_LIST_BUTTON"] = "NOT CORRECT"
        check_dict[page+"_CONDO_DATA_ICON"] = "NOT FOUND"
        check_dict[page+"_CONDO_DATA_LINK"] = "NOT FOUND"
        check_dict[page+"_CONDO_DATA_TEXT"] = "NOT FOUND"
        check_dict[page+"_REALIST_BLOG_ICON"] = "NOT FOUND"
        check_dict[page+"_REALIST_BLOG_LINK"] = "NOT CORRECT"
        check_dict[page+"_REALIST_BLOG_TEXT"] = "NOT CORRECT"
    def social_not_found():
        check_dict[page+'_FACEBOOK_LINK'] = "NOT FOUND"
        check_dict[page+'_FACEBOOK_ICON'] = "NOT FOUND"
        check_dict[page+'_LINE_LINK'] = "NOT FOUND"
        check_dict[page+'_LINE_ICON'] = "NOT FOUND"
        check_dict[page+'_YOUTUBE_LINK'] = "NOT FOUND"
        check_dict[page+'_YOUTUBE_ICON'] = "NOT FOUND"
        check_dict[page+'_INSTAGRAM_LINK'] = "NOT FOUND"
        check_dict[page+'_INSTAGRAM_ICON'] = "NOT FOUND"
    def not_found_all():
        check_dict[page+"_CLICK_LIST"] = "CANT CLICK"
        not_found()
        not_found_menu()
        list_click_not_found()
        social_not_found()
        check_dict[page+"_EXIT_COLOR"] = "NOT FOUND"
        check_dict[page+"_EXIT_ICON"] = "NOT FOUND"
        check_dict[page+"_EXIT_CLICK"] = "NOT FOUND"
    def top_bar_not_found():
        check_dict[page+"_OPEN_LISTING_ICON"] = "NOT FOUND"
        check_dict[page+"_LISTING_ICON_COLOR"] = "NOT FOUND"
        check_dict[page+"_HOME_LINK"] = "NOT FOUND"
        check_dict[page+"_HOME_PIC"] = "NOT FOUND"
        check_dict[page+"_SEARCH_ICON"] = "NOT FOUND"
        check_dict[page+"_SEARCH_COLOR"] = "NOT FOUND"
        search_button_click()
        not_found_all()
        check_dict[page+"_TOPMENU_BGCOLOR"] = "NOT FOUND"
    
    #HOME PAGE
    #listing, home, search
    top_menu = soup.find('div', {'class': 'd-block d-lg-none mobile-topbar-block p-0 m-0'})
    if top_menu:
        #listing -- icon, color
        #icon
        open_list = top_menu.find('div', {'class': 'col-2'})
        if open_list:
            o_list = open_list.find('i')
            o_list = o_list.get('class')
            o_menu = o_list[1]
            if o_menu == 'fa-bars':
                check_dict[page+"_OPEN_LISTING_ICON"] = 1
            else:
                check_dict[page+"_OPEN_LISTING_ICON"] = "NOT CORRECT"
            #color
            o_menu_color = str(o_list)
            if 'white' in o_menu_color:
                check_dict[page+"_LISTING_ICON_COLOR"] = 1
            else:
                check_dict[page+"_LISTING_ICON_COLOR"] = "NOT CORRECT"
        else:
            check_dict[page+"_OPEN_LISTING_ICON"] = "NOT FOUND"
            check_dict[page+"_LISTING_ICON_COLOR"] = "NOT FOUND"
        #home -- home link, home pic
        home = top_menu.find('div', {'class': 'col-8 text-center'})
        if home:
            #home link
            home_link = home.find('a')
            home_link = home_link.get('href')
            if home_link == "/realist/condo/":
                check_dict[page+"_HOME_LINK"] = 1
            else:
                check_dict[page+"_HOME_LINK"] = "NOT CORRECT"
            #home pic
            home_pic = home.find('img')
            home_pic = home_pic.get('src')
            if home_pic == "/realist/assets/images/logo-white-blue.png":
                check_dict[page+"_HOME_PIC"] = 1
            else:
                check_dict[page+"_HOME_PIC"] = "NOT CORRECT"
        else:
            check_dict[page+"_HOME_LINK"] = "NOT FOUND"
            check_dict[page+"_HOME_PIC"] = "NOT FOUND"
        #search -- icon, color
        search = top_menu.find('div', {'class': 'col-2 text-right'})
        if search:
            #search_icon
            search = search.find('i')
            search = search.get('class')
            search_icon = search[1]
            if search_icon == "fa-magnifying-glass":
                check_dict[page+"_SEARCH_ICON"] = 1
            else:
                check_dict[page+"_SEARCH_ICON"] = "NOT CORRECT"
            #search_color
            search_color = str(search)
            if "white" in search_color:
                check_dict[page+"_SEARCH_COLOR"] = 1
            else:
                check_dict[page+"_SEARCH_COLOR"] = "NOT CORRECT"
        else:
            check_dict[page+"_SEARCH_ICON"] = "NOT FOUND"
            check_dict[page+"_SEARCH_COLOR"] = "NOT FOUND"
        #click_search -- input_click, search_button, back_button
        search_click = browser.find_element(By.XPATH ,("//div[@class='col-2 text-right']"));
        if search_click:
            on_screen = search_click.is_displayed();
            if on_screen:
                try:
                    search_click.click()
                    time.sleep(1)
                    check_dict[page+"_SEARCH_CLICK"] = 1
                except:
                    check_dict[page+"_SEARCH_CLICK"] = "CANT CLICK"
            else:
                check_dict[page+"_SEARCH_CLICK"] = "NOT FOUND"
                check_dict[page+"_IN_SEARCH_BGCOLOR"] = "NOT FOUND"
            #in_search_click_bgcolor 
            in_search_click = soup.find('div', {'class': 'topbar-mobile-container bg-white pb-3'})
            if in_search_click: 
                check_dict[page+"_IN_SEARCH_BGCOLOR"] = 1                    
            else:                 
                check_dict[page+"_IN_SEARCH_BGCOLOR"] = "NOT CORRECT"
            #input_click -- input_search_click, input_search_bgcolor, input_search_text
            input_search = browser.find_element(By.XPATH ,("//input[@class='topbar-mobile-input-text border-0 w-100']"));
            if input_search:
                on_screen = input_search.is_displayed();
                if on_screen:
                    #input_search_click
                    try:
                        input_search.click()
                        check_dict[page+"_INPUT_SEARCH"] = 1
                        input_search.clear()
                        #search_result_condo
                        input_search.send_keys("ทองหล่อ")
                        time.sleep(3)
                        search_result_condo = browser.find_element(By.XPATH ,("//div[@class='container search-result py-1 px-3 mx-2']"));
                        on_screen = search_result_condo.is_displayed();
                        if on_screen:
                            check_dict[page+"_SEARCH_RESULT_CONDO"] = 1
                        else:
                            check_dict[page+"_SEARCH_RESULT_CONDO"] = "NOT FOUND"
                        search_result_train = browser.find_element(By.XPATH ,("//div[@class='container search-result py-2 pr-3 pl-0 mx-2']"));
                        on_screen = search_result_train.is_displayed();
                        if on_screen:
                            check_dict[page+"_SEARCH_RESULT_TRAIN"] = 1
                        else:
                            check_dict[page+"_SEARCH_RESULT_TRAIN"] = "NOT FOUND"
                    except:
                        check_dict[page+"_INPUT_SEARCH"] = "NOT CORRECT"
                        check_dict[page+"_SEARCH_RESULT_CONDO"] = "NOT FOUND"
                        check_dict[page+"_SEARCH_RESULT_TRAIN"] = "NOT FOUND"
                    #input_search_bgcolor
                    element = browser.find_element(By.XPATH ,("//input[@class='topbar-mobile-input-text border-0 w-100']"));
                    background_color = element.value_of_css_property("background-color")
                    rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
                    hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
                    if hex_color == "#e8e8e8":
                        check_dict[page+"_INPUT_SEARCH_BGCOLOR"] = 1
                    else:
                        check_dict[page+"_INPUT_SEARCH_BGCOLOR"] = "NOT CORRECT"
                    #input_search_text
                    input_search_text = in_search_click.find('input')
                    input_search_text = input_search_text.get('placeholder')
                    if input_search_text == "พิมพ์ ชื่อคอนโด / ชื่อผู้พัฒนา / ทำเล / สถานีรถไฟฟ้า":
                        check_dict[page+"_INPUT_SEARCH_TEXT"] = 1
                    else:
                        check_dict[page+"_INPUT_SEARCH_TEXT"] = "NOT CORRECT"
                else:
                    input_search_not_found()
            else:
                input_search_not_found()
            #search_button -- search_button_bgcolor, search_button_text
            search_button = browser.find_element(By.XPATH ,("//button[@id='topbar-mobile-text-search-button']"));
            if search_button:
                on_screen = search_button.is_displayed();
                if on_screen:
                    check_dict[page+"_SEARCH_BUTTON"] = 1
                    #search_button_bgcolor
                    element = browser.find_element(By.XPATH ,("//button[@id='topbar-mobile-text-search-button']"));
                    background_color = element.value_of_css_property("background-color")
                    rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
                    hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
                    if hex_color == "#26b7be":
                        check_dict[page+"_SEARCH_BUTTON_BGCOLOR"] = 1
                    else:
                        check_dict[page+"_SEARCH_BUTTON_BGCOLOR"] = "NOT CORRECT"
                    #search_button_text
                    search_button = soup.find('button', {'id': 'topbar-mobile-text-search-button'})
                    search_button_text = search_button.text.strip()
                    if search_button_text == "ค้นหา":
                        check_dict[page+"_SEARCH_BUTTON_TEXT"] = 1
                    else:
                        check_dict[page+"_SEARCH_BUTTON_TEXT"] = "NOT CORRECT"
                    #search_button_text_color
                    search_button_text_color = search_button.get('class')
                    search_button_text_color = str(search_button_text_color)
                    if "white" in search_button_text_color:
                        check_dict[page+"_SEARCH_BUTTON_TEXT_COLOR"] = 1
                    else:
                        check_dict[page+"_SEARCH_BUTTON_TEXT_COLOR"] = "NOT CORRECT"
                else:
                    search_button_not_found()
            else:
                search_button_not_found()
            #back_button -- back_icon, back_click
            back_click = browser.find_element(By.XPATH ,("//button[@class='mobile-topbar-collapse bg-transparent border-0 text-center']"));
            if back_click:
                on_screen = back_click.is_displayed();
                if on_screen:
                    #back_icon
                    back = soup.find('button', {'class': 'mobile-topbar-collapse bg-transparent border-0 text-center'})
                    back_icon = back.find('i')
                    back_icon = back_icon.get('class')
                    back_icon = str(back_icon)
                    if "chevron-left" in back_icon:
                        check_dict[page+"_SEARCH_BACK_ICON"] = 1
                    else:
                        check_dict[page+"_SEARCH_BACK_ICON"] = "NOT CORRECT"
                    #back_icon_color
                    back_icon_color = back.find('h3')
                    back_icon_color = back_icon_color.get('class')
                    back_icon_color = str(back_icon_color)
                    if "black" in back_icon_color:
                        check_dict[page+"_SEARCH_BACK_ICON_COLOR"] = 1
                    else:
                        check_dict[page+"_SEARCH_BACK_ICON_COLOR"] = "NOT CORRECT"
                    #back_click
                    try:
                        back_click.click()
                        check_dict[page+"_SEARCH_BACK_CLICK"] = 1
                    except:
                        check_dict[page+"_SEARCH_BACK_CLICK"] = "CANT CLICK"
                else:
                    search_back_button()
            else:
                search_back_button()
        else:
            search_button_click()
        #top_bar_bgcolor
        element = browser.find_element(By.XPATH ,("//div[@class='d-block d-lg-none mobile-topbar-block p-0 m-0']"));
        background_color = element.value_of_css_property("background-color")
        if background_color == "rgba(46, 46, 46, 0.9)":
            check_dict[page+"_TOPMENU_BGCOLOR"] = 1
        else:
            check_dict[page+"_TOPMENU_BGCOLOR"] = "NOT CORRECT"
        #list_menu_click
        list_menu = browser.find_element(By.XPATH ,("//button[@data-target='#topbar-mobile']"))
        on_screen = list_menu.is_displayed();
        if on_screen:
            try:
                click_list()
                check_dict[page+"_CLICK_LIST"] = 1
            except:
                check_dict[page+"_CLICK_LIST"] = "CANT CLICK"
            #list_menu_bgcolor
            element = browser.find_element(By.XPATH ,("//div[@id='topbar-mobile']"));
            background_color = element.value_of_css_property("background-color")
            if background_color == "rgba(0, 0, 0, 1)":
                check_dict[page+"_BGCOLOR_LIST_BUTTON"] = 1
            else:
                check_dict[page+"_BGCOLOR_LIST_BUTTON"] = "NOT CORRECT"
            open_list = browser.find_element(By.XPATH ,("//div[@class='p-0 m-0 collapse show']"))
            on_screen = open_list.is_displayed();
            if on_screen:
                list_show = soup.find('div', {'id': 'topbar-mobile'})
                if list_show:
                    data_and_blog = list_show.find('div', {'class': 'container pb-5'})
                    for i , condo_data in enumerate(data_and_blog.find_all('div', {'class': 'row text-realist-white top-menu-mobile-header'})):
                        if condo_data:
                            if i == 0:
                                #condo_data_icon
                                condo_data_icon = condo_data.find('i')
                                condo_data_icon = condo_data_icon.get('class')
                                if "fa-building" in condo_data_icon:
                                    check_dict[page+"_CONDO_DATA_ICON"] = 1
                                else:
                                    check_dict[page+"_CONDO_DATA_ICON"] = "NOT CORRECT"
                                condo_data_link_and_text = condo_data.find('a')
                                #condo_data_link
                                condo_data_link = condo_data_link_and_text.get('href')
                                if "/realist/condo/" in condo_data_link:
                                    check_dict[page+"_CONDO_DATA_LINK"] = 1
                                else:
                                    check_dict[page+"_CONDO_DATA_LINK"] = "NOT CORRECT"
                                #condo_data_name
                                condo_data_text = condo_data_link_and_text.text.strip()
                                if condo_data_text == "Condo Data":
                                    check_dict[page+"_CONDO_DATA_TEXT"] = 1
                                else:
                                    check_dict[page+"_CONDO_DATA_TEXT"] = "NOT CORRECT"
                            elif i == 1:
                                #realist_blog_icon
                                realist_blog_icon = condo_data.find('i')
                                realist_blog_icon = realist_blog_icon.get('class')
                                if "fa-book" in realist_blog_icon:
                                    check_dict[page+"_REALIST_BLOG_ICON"] = 1
                                else:
                                    check_dict[page+"_REALIST_BLOG_ICON"] = "NOT CORRECT"
                                realist_blog_link_and_text = condo_data.find('a')
                                #realist_blog_link
                                realist_blog_link = realist_blog_link_and_text.get('href')
                                if "/realist/blog" in realist_blog_link:
                                    check_dict[page+"_REALIST_BLOG_LINK"] = 1
                                else:
                                    check_dict[page+"_REALIST_BLOG_LINK"] = "NOT CORRECT"
                                #condo_data_name
                                realist_blog_text = realist_blog_link_and_text.text.strip()
                                if realist_blog_text == "Realist Blog":
                                    check_dict[page+"_REALIST_BLOG_TEXT"] = 1
                                else:
                                    check_dict[page+"_REALIST_BLOG_TEXT"] = "NOT CORRECT"
                    menu = list_show.find('div', {'id': 'mobile-top-menu'})
                    if menu:
                        #in list bgcolor
                        bgcolor = menu.find('div', {'class': 'card-header p-0 bg-realist-black'})
                        bgcolor = bgcolor.get('class')
                        bgcolor = str(bgcolor)
                        if "black" in bgcolor:
                            check_dict[page+"_LIST_BGCOLOR"] = 1
                        else:
                            check_dict[page+"_LIST_BGCOLOR"] = "NOT CORRECT"
                        #listing_info -- listing text, listing text color, listing icon, listing icon color 
                        text = ["คอนโดที่แนะนำ","Spotlight","ราคา","รถไฟฟ้า","ทำเล","ผู้พัฒนาโครงการ","แบรนด์"]
                        for i , listing in enumerate(menu.find_all('div', {'class': 'card bg-transparent'})):
                            if listing:
                                #listing text
                                listing_info = listing.find('p')
                                listing_text = listing_info.text.strip()
                                if text[i] == listing_text:
                                    check_dict[page+'_LISTING_TEXT_'+text[i]] = 1
                                else:
                                    check_dict[page+'_LISTING_TEXT_'+text[i]] = "NOT CORRECT"
                                #listing text color
                                listing_text_color = listing_info.get('class')
                                listing_text_color = str(listing_text_color)
                                if "cyan" in listing_text_color:
                                    check_dict[page+'_LISTING_TEXT_COLOR_'+text[i]] = 1
                                else:
                                    check_dict[page+'_LISTING_TEXT_COLOR_'+text[i]] = "NOT CORRECT"
                                #listing icon
                                listing_arrow = listing.find('i')
                                listing_icon = listing_arrow.get('class')
                                listing_icon = str(listing_icon)
                                if "angle-down" in listing_icon:
                                    check_dict[page+'_LISTING_ICON_'+text[i]] = 1
                                else:
                                    check_dict[page+'_LISTING_ICON_'+text[i]] = "NOT CORRECT"
                                #listing icon color
                                if "grey2" in listing_icon:
                                    check_dict[page+'_LISTING_ICON_COLOR_'+text[i]] = 1
                                else:
                                    check_dict[page+'_LISTING_ICON_COLOR_'+text[i]] = "NOT CORRECT"
                            else:
                                check_dict[page+'_LISTING_TEXT_'+text[i]] = "NOT FOUND"
                                check_dict[page+'_LISTING_TEXT_COLOR_'+text[i]] = "NOT FOUND"
                                check_dict[page+'_LISTING_ICON_'+text[i]] = "NOT FOUND"
                                check_dict[page+'_LISTING_ICON_COLOR_'+text[i]] = "NOT FOUND"
                    else:
                        not_found_menu()
                    #listing click
                    click_listing = browser.find_elements(By.XPATH ,("//div[@class='card bg-transparent']"))
                    element_counts = Counter(click_listing)
                    x = 1
                    text = ["คอนโดที่แนะนำ","Spotlight","ราคา","รถไฟฟ้า","ทำเล","ผู้พัฒนาโครงการ","แบรนด์"]
                    for element, count in element_counts.items():
                        on_screen = element.is_displayed();
                        if on_screen:
                            if x <= 7:
                                try:
                                    element.click()
                                    time.sleep(1)
                                    check_dict[page+'_'+text[x-1]+'_CLICK'] = 1
                                    x += 1
                                except:
                                    check_dict[page+'_'+text[x-1]+'_CLICK'] = "CANT CLICK"
                                    x += 1
                        else:
                            list_click_not_found()
                    #social -- social link, social icon
                    social = list_show.find('div', {'class': 'row justify-content-center p-3 m-0'})
                    thelist_social = ["facebook","line","youtube","instagram"]
                    if social:
                        for i , contact in enumerate(social.find_all('div', {'class': 'col-auto px-2'})):
                            if contact:
                                #social link
                                social_link = contact.find('a')
                                social_link = social_link.get('href')
                                #social icon
                                social_icon = contact.find('img')
                                social_icon = social_icon.get('src')
                                socials(thelist_social[i])
                    else:
                        social_not_found()
                    exit_button_all = list_show.find('div', {'class': 'col-4 text-right'})
                    if exit_button_all:
                        exit_button = exit_button_all.find('h3')
                        exit_color = exit_button.get('class')
                        if "white" in str(exit_color):
                            check_dict[page+"_EXIT_COLOR"] = 1
                        else:
                            check_dict[page+"_EXIT_COLOR"] = "NOT CORRECT"
                        exit_icon = exit_button_all.find('i')
                        exit_icon = exit_icon.get('class')
                        if "xmark" in str(exit_icon):
                            check_dict[page+"_EXIT_ICON"] = 1
                        else:
                            check_dict[page+"_EXIT_ICON"] = "NOT CORRECT"
                    else:
                        check_dict[page+"_EXIT_COLOR"] = "NOT FOUND"
                        check_dict[page+"_EXIT_ICON"] = "NOT FOUND"
                    exit_click = browser.find_element(By.XPATH ,("//button[@class='mobile-topbar-collapse bg-transparent border-0 py-0 pr-0 pl-5']"))
                    on_screen = exit_click.is_displayed();
                    if on_screen:
                        try:
                            exit_click.click()
                            check_dict[page+"_EXIT_CLICK"] = 1
                        except:
                            check_dict[page+"_EXIT_CLICK"] = "CANT CLICK"
                    else:
                        check_dict[page+"_EXIT_CLICK"] = "NOT FOUND"
                else:
                    not_found_all()
            else:
                not_found_all()
        else:
            not_found_all()
    else:
        top_bar_not_found()
check_dict = {"PAGE" : "HOME PAGE"}
top_bar("HOME")

#header -- top head, cover text
header = soup.find('div', {'class': 'row m-0'})
if header:
    #top head
    top_head = header.find('img')
    if top_head:
        top_head = top_head.get('src')
        if top_head == "../assets/images/real-data-logo.png":
            check_dict["TOP_HEAD"] = 1
        else:
            check_dict["TOP_HEAD"] = "NOT CORRECT"
    else:
        check_dict["TOP_HEAD"] = "NOT FOUND"
    #header text
    header_t = header.find('h2')
    if header_t:
        header_text = header_t.text.strip()
        if header_text == "Bangkok Metropolitan Condo":
            check_dict["HEADER_TEXT"] = 1
        else:
            check_dict["HEADER_TEXT"] = "NOT CORRECT"
        #header text color
        header_text_color = header_t.get('class')
        header_text_color = str(header_text_color)
        if "grey3" in header_text_color:
            check_dict["HEADER_TEXT_COLOR"] = 1
        else:
            check_dict["HEADER_TEXT_COLOR"] = "NOT CORRECT"
    else:
        check_dict["HEADER_TEXT"] = "NOT FOUND"
        check_dict["HEADER_TEXT_COLOR"] = "NOT FOUND"
    #cover text -- begin_quote, begin_quote_color, cover_text, cover_text_color, end_quote, end_quote_color
    #begin_quote
    begin_quote = header.find('div', {'id': 'top-subhead-text-point'})
    if begin_quote:
        start_quote = begin_quote.find('span')
        quote1 = start_quote.text.strip()
        if quote1 == "❝":
            check_dict["BEGIN_QUOTE"] = 1
        else:
            check_dict["BEGIN_QUOTE"] = "NOT CORRECT"
        #begin_quote_color
        begin_quote_color = start_quote.get('class')
        begin_quote_color = str(begin_quote_color)
        if "white" in begin_quote_color:
            check_dict["START_QUOTE_COLOR"] = 1
        else:
            check_dict["START_QUOTE_COLOR"] = "NOT CORRECT"
    else:
        check_dict["BEGIN_QUOTE"] = "NOT FOUND"
        check_dict["START_QUOTE_COLOR"] = "NOT FOUND"
    #cover text
    cover_text = header.find('div', {'class': 'd-block d-lg-none'})
    if cover_text:
        text_cover = cover_text.find('h3')
        c_text = text_cover.text.strip()
        if c_text == "REAL DATA รวบรวมคอนโดฯ ในกรุงเทพ นำเสนอข้อมูลอย่างเป็นระบบครบถ้วน\n              แผนที่ที่ง่ายต่อการค้นหา รวมถึงมีราคาตลาด ยอดขายที่น่าเชื่อถือ\n              และบทความวิเคราะห์เชิงลึกทั้งในเรื่องความน่าอยู่และน่าลงทุน":
            check_dict["COVER_TEXT"] = 1
        else:
            check_dict["COVER_TEXT"] = "NOT CORRECT"
        #cover_text_color
        cover_text_color = text_cover.get('class')
        cover_text_color = str(cover_text_color)
        if "grey3" in cover_text_color:
            check_dict["COVER_TEXT_COLOR"] = 1
        else:
            check_dict["COVER_TEXT_COLOR"] = "NOT CORRECT"
    else:
        check_dict["COVER_TEXT"] = "NOT FOUND"
        check_dict["COVER_TEXT_COLOR"] = "NOT FOUND"
    #end quote -- end_quote_color
    for a, stop_quote in enumerate(header.find_all('div', {'class': 'd-flex justify-content-center align-items-center'})):
        if stop_quote:
            if a == 1:
                end_quote = stop_quote.find('span')
                quote2 = end_quote.text.strip()
                if quote2 == "❞":
                    check_dict["END_QUOTE"] = 1
                else:
                    check_dict["END_QUOTE"] = "NOT CORRECT"
                #end_quote_color
                end_quote_color = start_quote.get('class')
                end_quote_color = str(end_quote_color)
                if "white" in end_quote_color:
                    check_dict["END_QUOTE_COLOR"] = 1
                else:
                    check_dict["END_QUOTE_COLOR"] = "NOT CORRECT"
        else:
            check_dict["END_QUOTE"] = "NOT FOUND"
            check_dict["END_QUOTE_COLOR"] = "NOT FOUND"
else:
    check_dict["TOP_HEAD"] = "NOT FOUND"
    check_dict["HEADER_TEXT"] = "NOT FOUND"
    check_dict["HEADER_TEXT_COLOR"] = "NOT FOUND"
    check_dict["BEGIN_QUOTE"] = "NOT FOUND"
    check_dict["START_QUOTE_COLOR"] = "NOT FOUND"
    check_dict["COVER_TEXT"] = "NOT FOUND"
    check_dict["COVER_TEXT_COLOR"] = "NOT FOUND"
    check_dict["END_QUOTE"] = "NOT FOUND"
    check_dict["END_QUOTE_COLOR"] = "NOT FOUND"

browser.execute_script("window.scrollTo(0, 2000)")
#help_search -- help_search_header_text
help_search_all = soup.find('div', {'id': 'filter-searchd'})
if help_search_all:
    #help_search_header_text -- help_search_header_text_color
    search_header = help_search_all.find('h2')
    if search_header:
        search_header_text = search_header.text.strip()
        if search_header_text == "ให้เราช่วยคุณหาคอนโดที่ใช่":
            check_dict["HELP_SEARCH_HEADER_TEXT"] = 1
        else:
            check_dict["HELP_SEARCH_HEADER_TEXT"] = "NOT CORRECT"
        #help_search_header_text_color
        search_header_text_color = search_header.get('class')
        search_header_text_color = str(search_header_text_color)
        if "white" in search_header_text_color:
            check_dict["HELP_SEARCH_HEADER_TEXT_COLOR"] = 1
        else:
            check_dict["HELP_SEARCH_HEADER_TEXT_COLOR"] = "NOT CORRECT"
    else:
        check_dict["HELP_SEARCH_HEADER_TEXT"] = "NOT FOUND"
        check_dict["HELP_SEARCH_HEADER_TEXT_COLOR"] = "NOT FOUND"
    #help_search_input -- help_search_input_text, help_search_input_bgcolor
    search_input = help_search_all.find('div', {'id': 'search-form-element'})
    input = search_input.find('input')
    if input:
        input = input.get('placeholder')
        if input == "พิมพ์ ชื่อคอนโด / ชื่อผู้พัฒนา / ทำเล / สถานีรถไฟฟ้า":
            check_dict["HELP_SEARCH_INPUT_TEXT"] = 1
        else:
            check_dict["HELP_SEARCH_INPUT_TEXT"] = "NOT CORRECT"
        #help_search_input_text_color
        element = browser.find_element(By.XPATH ,("//div[@id='search-form-element']"));
        background_color = element.value_of_css_property("background-color")
        rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
        hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
        if hex_color == "#000000":
            check_dict["HELP_SEARCH_INPUT_TEXT_COLOR"] = 1
        else:
            check_dict["HELP_SEARCH_INPUT_TEXT_COLOR"] = "NOT CORRECT"
        #help_search_input_bgcolor
        element = browser.find_element(By.XPATH ,("//input[@placeholder='พิมพ์ ชื่อคอนโด / ชื่อผู้พัฒนา / ทำเล / สถานีรถไฟฟ้า']"));
        background_color = element.value_of_css_property("background-color")
        rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
        hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
        if hex_color == "#e8e8e8":
            check_dict["HELP_SEARCH_INPUT_BGCOLOR"] = 1
        else:
            check_dict["HELP_SEARCH_INPUT_BGCOLOR"] = "NOT CORRECT"
        #help_search_input_click    
        help_search_input_click = browser.find_element(By.XPATH ,("//input[@class='filter-text-input border-0 m-0 text-center']"));
        on_screen = help_search_input_click.is_displayed();
        if on_screen:
            try:
                help_search_input_click.click()
                check_dict["HELP_SEARCH_CLICK"] = 1
            except:
                check_dict["HELP_SEARCH_CLICK"] = "CANT CLICK"
            #clear text box
            input_search = browser.find_element(By.XPATH ,("//input[@class='topbar-mobile-input-text border-0 w-100']"));
            if input_search:
                on_screen = input_search.is_displayed();
                if on_screen:
                    search_click_in("HELP_SEARCH")
        else:
            search_button_click("HELP_SEARCH")
    else:
        check_dict["HELP_SEARCH_INPUT_TEXT"] = "NOT FOUND"
        check_dict["HELP_SEARCH_INPUT_TEXT_COLOR"] = "NOT FOUND"
        check_dict["HELP_SEARCH_INPUT_BGCOLOR"] = "NOT FOUND"
        search_button_click("HELP_SEARCH")
    #or_text -- or_text_color
    or_text = help_search_all.find('p')
    if or_text:
        o_text = or_text.text.strip()
        if o_text == "หรือ":
            check_dict["OR_TEXT"] = 1
        else:
            check_dict["OR_TEXT"] = "NOT CORRECT"
        #or_text_color
        or_text_color = or_text.get('class')
        or_text_color = str(or_text_color)
        if "white" in or_text_color:
            check_dict["OR_TEXT_COLOR"] = 1
        else:
            check_dict["OR_TEXT_COLOR"] = "NOT CORRECT"
    else:
        check_dict["OR_TEXT"] = "NOT FOUND"
        check_dict["OR_TEXT_COLOR"] = "NOT FOUND"
    #help_search_map_button -- help_search_map_button_color, help_search_map_icon
    search_map_button = help_search_all.find('button', {'class': 'search-map-button'})
    if search_map_button:
        s_map_button = search_map_button.text.strip()
        if s_map_button == "ค้นหาด้วยแผนที่":
            check_dict["HELP_SEARCH_MAP_BUTTON"] = 1
        else:
            check_dict["HELP_SEARCH_MAP_BUTTON"] = "NOT CORRECT"
        #help_search_map_button_color
        element = browser.find_element(By.XPATH ,("//button[@class='search-map-button']"));
        background_color = element.value_of_css_property("background-color")
        rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
        hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
        if hex_color == "#26b7be":
            check_dict["HELP_SEARCH_MAP_BUTTON_COLOR"] = 1
        else:
            check_dict["HELP_SEARCH_MAP_BUTTON_COLOR"] = "NOT CORRECT"
        #help_search_map_icon
        search_map_icon = search_map_button.find('i')
        s_map_icon = search_map_icon.get('class')
        s_map_icon = str(s_map_icon)
        if "fa-angles-right" in s_map_icon:
            check_dict["HELP_SEARCH_MAP_ICON"] = 1
        else:
            check_dict["HELP_SEARCH_MAP_ICON"] = "NOT CORRECT"
        #help_search_map_button_click
        on_screen = element.is_displayed();
        if on_screen:
            try:
                element.click()
                check_dict["HELP_SEARCH_MAP_CLICK"] = 1
                #help_search_map_top_bar
                top_bar("HELP_SEARCH_MAP")
            except:
                check_dict["HELP_SEARCH_MAP_CLICK"] = "CANT CLICK"
    else:
        check_dict["HELP_SEARCH_MAP_BUTTON"] = "NOT FOUND"
        check_dict["HELP_SEARCH_MAP_BUTTON_COLOR"] = "NOT FOUND"
        check_dict["HELP_SEARCH_MAP_ICON"] = "NOT FOUND"
        check_dict["HELP_SEARCH_MAP_CLICK"] = "NOT FOUND"
        check_dict["HELP_SEARCH_MAP_TOP_BAR"] = "NOT FOUND"
else:
    check_dict["HELP_SEARCH_HEADER_TEXT"] = "NOT FOUND"
    check_dict["HELP_SEARCH_HEADER_TEXT_COLOR"] = "NOT FOUND"
    check_dict["HELP_SEARCH_INPUT_TEXT"] = "NOT FOUND"
    check_dict["HELP_SEARCH_INPUT_TEXT_COLOR"] = "NOT FOUND"
    check_dict["HELP_SEARCH_INPUT_BGCOLOR"] = "NOT FOUND"
    search_button_click("HELP_SEARCH")
    check_dict["OR_TEXT"] = "NOT FOUND"
    check_dict["OR_TEXT_COLOR"] = "NOT FOUND"
    check_dict["HELP_SEARCH_MAP_BUTTON"] = "NOT FOUND"
    check_dict["HELP_SEARCH_MAP_BUTTON_COLOR"] = "NOT FOUND"
    check_dict["HELP_SEARCH_MAP_ICON"] = "NOT FOUND"
    check_dict["HELP_SEARCH_MAP_CLICK"] = "NOT FOUND"
    check_dict["HELP_SEARCH_MAP_TOP_BAR"] = "NOT FOUND"

test_list.append(check_dict)
test_df = pd.DataFrame(test_list)
test_df.to_csv('test_mobile_2023.csv')
browser.close()
print("done")
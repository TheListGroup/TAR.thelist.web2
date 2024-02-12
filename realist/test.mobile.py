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
    #top_bar_bgcolor
#HEADER
    #top head
    #header text
    #cover text
        #begin_quote
            #begin_quote_color
        #cover_text
            #cover_text_color
        #end_quote
            #end_quote_color
#help_search
    #search_header_text
        #search_header_text_color
    #search_input
        #search_input_bgcolor
    #help_search_icon
        #help_search_icon_color
    #or_text
        #or_text_color
    #search_map_button
        #search_map_button_color
        #search_map_icon
#category_section
    #category_bg
    ###function_pic_category###
        #category_pic 1-18
    ###function_category_check###
        #category_name 1-18
        #category_count 1-18
        #category_name_color 1-18
        #category_count_color 1-18
    #category_amount
    #button_showmore
        #showmore_button_text
        #showmore_button_text_color
#condo_ads
    #condo_ads_title 
        #condo_ads_title_text
        #condo_ads_title_text_color
        #condo_ads_title_bgcolor
    #previous_button
        #previous_button_icon
    #next_button
        #next_button_icon
    #ads_img
    #ads_name
        #ads_title_color
    #ads_place
        #ads_place_color
    #ads_dev
        #ads_dev_color
    #ads_text
        #ads_text_color
    #go_blog
        #blog_link
        #blog_text
        #blog_text_color
        #blog_bgcolor
#section_related
    #related_text
        #related_text_color
    #related_header_text (1,2,3)
        #related_header_text_color
    #nearest_condo_list, newest_condo_list, recommand_condo_list
        #condo_link 
        #condo_pic 
        #info_title 
            #info_title_color 
        #info_data_color 
        #info_unit_text 
            #info_unit_text 
        #count_related
        #related_text_1 (nearest, newest, recommand)
        #related_text_2 (nearest, newest, recommand)
        #related_text_3 (nearest, newest, recommand)
        #relate_carousel (60 condo)
#section_article
    #article_text
        #article_text_color
    #article_header_text (1,2)
        #article_header_text_color (1,2)
    #article_list (2)
        #article_pic (40)
        #read_more_text (40)
            #read_more_arrow (40)
        #article_info (40)
            #article_link (40)
            #article_intro (40)
            #article_tag_icon (40)
            #article_section (40)
            #read_article
                #read_article_link (40)
                #read_article_icon (40)
            #condo_data
                #condo_data_icon_1
                #condo_data_icon_2
                #condo_data_text
                #condo_data_link (1-20 not 17)
                #17
                    #condo_data_link
                    #condo_data_icon
                    #condo_data_title
        #count_article
        #date
            #date_color
            #date_icon

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

browser = webdriver.Chrome()
browser.set_window_size(390, 844)
browser.get("http://google.com")
browser.get(url)
soup = bs(browser.page_source, 'html.parser')

def top_bar():
    #HOME PAGE
    #listing, home, search
    top_menu = soup.find('div', {'class': 'd-block d-lg-none mobile-topbar-block p-0 m-0'})
    #listing -- icon, color
    #icon
    open_list = top_menu.find('div', {'class': 'col-2'})
    if open_list:
        o_list = open_list.find('i')
        o_list = o_list.get('class')
        o_menu = o_list[1]
        if o_menu == 'fa-bars':
            check_dict["OPEN LISTING ICON"] = 1
        else:
            check_dict["OPEN LISTING ICON"] = "NOT CORRECT"
        #color
        o_menu_color = o_list[2].split("-")[2]
        if o_menu_color == 'white':
            check_dict["LISTING ICON COLOR"] = 1
        else:
            check_dict["LISTING ICON COLOR"] = "NOT CORRECT"
    else:
        check_dict["OPEN LISTING ICON"] = "NOT FOUND"
        check_dict["LISTING ICON COLOR"] = "NOT FOUND"
    #home -- home link, home pic
    home = top_menu.find('div', {'class': 'col-8 text-center'})
    if home:
        #home link
        home_link = home.find('a')
        home_link = home_link.get('href')
        if home_link == "/realist/condo/":
            check_dict["HOME LINK"] = 1
        else:
            check_dict["HOME LINK"] = "NOT CORRECT"
        #home pic
        home_pic = home.find('img')
        home_pic = home_pic.get('src')
        if home_pic == "/realist/assets/images/logo-white-blue.png":
            check_dict["HOME PIC"] = 1
        else:
            check_dict["HOME PIC"] = "NOT CORRECT"
    else:
        check_dict["HOME LINK"] = "NOT FOUND"
        check_dict["HOME PIC"] = "NOT FOUND"
    #search -- icon, color
    search = top_menu.find('div', {'class': 'col-2 text-right'})
    if search:
        #search_icon
        search = search.find('i')
        search = search.get('class')
        search_icon = search[1]
        if search_icon == "fa-magnifying-glass":
            check_dict["SEARCH ICON"] = 1
        else:
            check_dict["SEARCH ICON"] = "NOT CORRECT"
        #search_color
        search_color = search[2].split("-")[2]
        if search_color == "white":
            check_dict["SEARCH COLOR"] = 1
        else:
            check_dict["SEARCH COLOR"] = "NOT CORRECT"
    else:
        check_dict["SEARCH ICON"] = "NOT FOUND"
        check_dict["SEARCH COLOR"] = "NOT FOUND"
    #top_bar_bgcolor
    element = browser.find_element(By.XPATH ,("//div[@class='d-block d-lg-none mobile-topbar-block p-0 m-0']"));
    background_color = element.value_of_css_property("background-color")
    if background_color == "rgba(46, 46, 46, 0.9)":
        check_dict["TOPMENU BGCOLOR"] = 1
    else:
        check_dict["TOPMENU BGCOLOR"] = "NOT CORRECT"

check_dict = {"PAGE" : "HOME PAGE"}
top_bar()
#header -- top head, cover text
header = soup.find('div', {'class': 'row m-0'})
#top head
top_head = header.find('img')
if top_head:
    top_head = top_head.get('src')
    if top_head == "../assets/images/real-data-logo.png":
        check_dict["TOP HEAD"] = 1
    else:
        check_dict["TOP HEAD"] = "NOT CORRECT"
else:
    check_dict["TOP HEAD"] = "NOT FOUND"
#header text
header_text = header.find('h2')
if header_text:
    header_text = header_text.text.strip()
    if header_text == "Bangkok Metropolitan Condo":
        check_dict["HEADER TEXT"] = 1
    else:
        check_dict["HEADER TEXT"] = "NOT CORRECT"
else:
    check_dict["HEADER TEXT"] = "NOT FOUND"
#cover text -- begin_quote, begin_quote_color, cover_text, cover_text_color, end_quote, end_quote_color
#begin_quote
begin_quote = header.find('div', {'id': 'top-subhead-text-point'})
if begin_quote:
    start_quote = begin_quote.find('span')
    quote1 = start_quote.text.strip()
    if quote1 == "❝":
        check_dict["BEGIN QUOTE"] = 1
    else:
        check_dict["BEGIN QUOTE"] = "NOT CORRECT"
    #begin_quote_color
    begin_quote_color = start_quote.get('class')
    begin_quote_color = begin_quote_color[0].split("-")[2]
    if begin_quote_color == "white":
        check_dict["START QUOTE COLOR"] = 1
    else:
        check_dict["START QUOTE COLOR"] = "NOT CORRECT"
else:
    check_dict["BEGIN QUOTE"] = "NOT FOUND"
    check_dict["START QUOTE COLOR"] = "NOT FOUND"
#cover text
cover_text = header.find('div', {'class': 'd-none d-lg-block'})
if cover_text:
    text_cover = cover_text.find('h3')
    c_text = text_cover.text.strip()
    if c_text == "REAL DATA รวบรวมคอนโดฯ ในกรุงเทพ นำเสนอข้อมูลอย่างเป็นระบบครบถ้วน\n              แผนที่ที่ง่ายต่อการค้นหา รวมถึงมีราคาตลาด ยอดขายที่น่าเชื่อถือ\n              และบทความวิเคราะห์เชิงลึกทั้งในเรื่องความน่าอยู่และน่าลงทุน":
        check_dict["COVER TEXT"] = 1
    else:
        check_dict["COVER TEXT"] = "NOT CORRECT"
    #cover_text_color
    cover_text_color = text_cover.get('class')
    cover_text_color = cover_text_color[1].split("-")[2]
    if cover_text_color == "grey3":
        check_dict["COVER TEXT COLOR"] = 1
    else:
        check_dict["COVER TEXT COLOR"] = "NOT CORRECT"
else:
    check_dict["COVER TEXT"] = "NOT FOUND"
    check_dict["COVER TEXT COLOR"] = "NOT FOUND"
#end quote -- end_quote_color
for a, stop_quote in enumerate(header.find_all('div', {'class': 'd-flex justify-content-center align-items-center'})):
    if a == 1:
        end_quote = stop_quote.find('span')
        quote2 = end_quote.text.strip()
        if quote2 == "❞":
            check_dict["END QUOTE"] = 1
        else:
            check_dict["END QUOTE"] = "NOT CORRECT"
        #end_quote_color
        end_quote_color = start_quote.get('class')
        end_quote_color = end_quote_color[0].split("-")[2]
        if begin_quote_color == "white":
            check_dict["END QUOTE COLOR"] = 1
        else:
            check_dict["END QUOTE COLOR"] = "NOT CORRECT"
#help_search -- search_header_text
help_search_all = soup.find('div', {'id': 'filter-searchd'})
#search_header_text -- search_header_text_color
search_header = help_search_all.find('h2')
if search_header:
    search_header_text = search_header.text.strip()
    if search_header_text == "ให้เราช่วยคุณหาคอนโดที่ใช่":
        check_dict["SEARCH HEADER TEXT"] = 1
    else:
        check_dict["SEARCH HEADER TEXT"] = "NOT CORRECT"
    #search_header_text_color
    search_header_text_color = search_header.get('class')
    search_header_text_color = search_header_text_color[1].split("-")[2]
    if search_header_text_color == "white":
        check_dict["SEARCH_HEADER_TEXT_COLOR"] = 1
    else:
        check_dict["SEARCH_HEADER_TEXT_COLOR"] = "NOT CORRECT"
else:
    check_dict["SEARCH HEADER TEXT"] = "NOT FOUND"
    check_dict["SEARCH_HEADER_TEXT_COLOR"] = "NOT FOUND"
#search_input -- search_input_bgcolor, help_search_icon
search_input = help_search_all.find('div', {'id': 'search-form-element'})
input = search_input.find('input')
if input:
    input = input.get('placeholder')
    if input == "พิมพ์ ชื่อคอนโด / ชื่อผู้พัฒนา / ทำเล / สถานีรถไฟฟ้า":
        check_dict["SEARCH INPUT"] = 1
    else:
        check_dict["SEARCH INPUT"] = "NOT CORRECT"
    #search_input_bgcolor
    element = browser.find_element(By.XPATH ,("//input[@placeholder='พิมพ์ ชื่อคอนโด / ชื่อผู้พัฒนา / ทำเล / สถานีรถไฟฟ้า']"));
    background_color = element.value_of_css_property("background-color")
    rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
    hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
    if hex_color == "#e8e8e8":
        check_dict["SEARCH_INPUT_BGCOLOR"] = 1
    else:
        check_dict["SEARCH_INPUT_BGCOLOR"] = "NOT CORRECT"
else:
    check_dict["SEARCH INPUT"] = "NOT FOUND"
    check_dict["SEARCH_INPUT_BGCOLOR"] = "NOT FOUND"
#help_search_icon -- help_search_icon_color
help_search_icon = search_input.find('i')
if help_search_icon:
    icon_help_search = help_search_icon.get('class')
    i_help_search = icon_help_search[1]
    if i_help_search == "fa-magnifying-glass":
        check_dict["ICON_HELP_SEARCH"] = 1
    else:
        check_dict["ICON_HELP_SEARCH"] = "NOT CORRECT"
    #help_search_icon_color
    help_search_icon_color = icon_help_search[2].split("-")[2]
    if help_search_icon_color == "white":
        check_dict["ICON_HELP_SEARCH_COLOR"] = 1
    else:
        check_dict["ICON_HELP_SEARCH_COLOR"] = "NOT CORRECT"
else:
    check_dict["ICON_HELP_SEARCH"] = "NOT FOUND"
    check_dict["ICON_HELP_COLOR"] = "NOT FOUND"
#or_text -- or_text_color
or_text = help_search_all.find('p')
if or_text:
    o_text = or_text.text.strip()
    if o_text == "หรือ":
        check_dict["OR TEXT"] = 1
    else:
        check_dict["OR TEXT"] = "NOT CORRECT"
    #or_text_color
    or_text_color = or_text.get('class')
    or_text_color = str(or_text_color)
    or_text_color = or_text_color.replace("']","").split("-")[2]
    if or_text_color == "white":
        check_dict["OR TEXT COLOR"] = 1
    else:
        check_dict["OR TEXT COLOR"] = "NOT CORRECT"
else:
    check_dict["OR TEXT"] = "NOT FOUND"
    check_dict["OR TEXT COLOR"] = "NOT FOUND"
#search_map_button -- search_map_button_color, search_map_icon
search_map_button = help_search_all.find('button', {'class': 'search-map-button'})
if search_map_button:
    s_map_button = search_map_button.text.strip()
    if s_map_button == "ค้นหาด้วยแผนที่":
        check_dict["SEARCH MAP BUTTON"] = 1
    else:
        check_dict["SEARCH MAP BUTTON"] = "NOT CORRECT"
    #search_map_button_color
    element = browser.find_element(By.XPATH ,("//button[@class='search-map-button']"));
    background_color = element.value_of_css_property("background-color")
    rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
    hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
    if hex_color == "#26b7be":
        check_dict["SEARCH MAP BUTTON_COLOR"] = 1
    else:
        check_dict["SEARCH MAP BUTTON_COLOR"] = "NOT CORRECT"
    #search_map_icon
    search_map_icon = search_map_button.find('i')
    s_map_icon = search_map_icon.get('class')
    s_map_icon = s_map_icon[1]
    if s_map_icon == "fa-angles-right":
        check_dict["SEARCH MAP ICON"] = 1
    else:
        check_dict["SEARCH MAP ICON"] = "NOT CORRECT"
else:
    check_dict["SEARCH MAP BUTTON"] = "NOT FOUND"
    check_dict["SEARCH MAP BUTTON_COLOR"] = "NOT FOUND"
    check_dict["SEARCH MAP ICON"] = "NOT FOUND"
#category_section -- category_bg, category_cover_text
category_section = soup.find('section', {'class': 'category-section'})
category_bg = category_section.get('style')
if category_bg:
    category_bg = category_bg.split(":")[2].replace(";","").strip()
    if category_bg == "#ffffff":
        check_dict["CATEGORY BG"] = 1
    else:
        check_dict["CATEGORY BG"] = "NOT CORRECT"
else:
    check_dict["CATEGORY BG"] = "NOT FOUND"
#category_cover_text
category_cover_text = category_section.find('h2')
if category_cover_text:
    category_c_text = category_cover_text.text.strip()
    if category_c_text == "กำลังค้นหาสิ่งเหล่านี้อยู่รึเปล่า ?":
        check_dict["CATEGORY COVER TEXT"] = 1
    else:
        check_dict["CATEGORY COVER TEXT"] = "NOT CORRECT"
else:
    check_dict["CATEGORY COVER TEXT"] = "NOT FOUND"
#category -- category_pic 1-18, category_name 1-18, category_count 1-18, , category_name_color 1-18, category_count_color 1-18, category_amount
category_list = []
def pic_category(c_pic):
    if c_pic in category_image:
        check_dict["CATEGORY_PIC_"+str(b+1)] = 1
    else:
        check_dict["CATEGORY_PIC_"+str(b+1)] = "NOT CORRECT"

def category_check(c_name):
    if c_name in category_name:
        check_dict["CATEGORY_NAME_"+str(b+1)] = 1
    else:
        check_dict["CATEGORY_NAME_"+str(b+1)] = "NOT CORRECT"
    if count == str(s_count_list[b]).split(":")[1].replace("'}","").replace("'","").strip():
        check_dict["CATEGORY_COUNT_"+str(b+1)] = 1
    else:
        check_dict["CATEGORY_COUNT_"+str(b+1)] = "NOT CORRECT"
    if category_name_color == "white":
        check_dict["CATEGORY_NAME_COLOR_"+str(b+1)] = 1
    else:
        check_dict["CATEGORY_NAME_COLOR_"+str(b+1)] = "NOT CORRECT"
    if count_color == "white":
        check_dict["CATEGORY_COUNT_COLOR_"+str(b+1)] = 1
    else:
        check_dict["CATEGORY_COUNT_COLOR_"+str(b+1)] = "NOT CORRECT"

###for check count category###
s_count_list = []
spotlight = soup.find('div', {'id': 'top-mobile-spotlight-content'})
for c, spotlight_list in enumerate(spotlight.find_all('div', {'class': 'col-6'})):
    section = spotlight_list.find('p')
    spotlight_count = section.text.strip()
    spotlight_count = spotlight_count.replace("(","").replace(")","")
    s_count_dict = {"COUNT" : spotlight_count}
    s_count_list.append(s_count_dict)

category = category_section.find('div', {'class': 'category-mobile'})
if category:
    for b, category_mobile in enumerate(category.find_all('figure')):
        category_list.append(category_mobile)
        #category_pic
        category_image = category_mobile.find('img')
        category_image = category_image.get('data-src')
        category_pic = category_image.split("/")[5].split("-")[1]
        #category_name
        category_name = category_mobile.find('h3')
        category_n = category_name.text.strip()
        category_name_color = category_name.get('class')
        category_name_color = category_name_color[2].split("-")[2]
        #category_count
        amount = category_mobile.find('div', {'class': 'popular-count text-realist-white m-0 pt-1'})
        count = amount.text.strip()
        count = count.replace("โครงการ","").strip()
        count_color = amount.get('class')
        count_color = count_color[1].split("-")[2]
        #category_pic 1-18
        #category_name 1-18
        #category_count 1-18
        #category_name_color 1-18
        #category_count_color 1-18
        pic_category(category_pic)
        category_check(category_n)
        #category_amount
    if len(category_list) == b+1:
        check_dict["AMOUNT CATEGORY"] = 1
    else:
        check_dict["AMOUNT CATEGORY"] = "NOT CORRECT"
else:
    check_dict["CATEGORY_PIC_"] = "NOT FOUND"
    check_dict["CATEGORY_NAME_"] = "NOT FOUND"
    check_dict["CATEGORY_COUNT_"] = "NOT FOUND"
    check_dict["CATEGORY_NAME_COLOR_"] = "NOT FOUND"
    check_dict["CATEGORY_COUNT_COLOR_"] = "NOT FOUND"
    check_dict["AMOUNT CATEGORY"] = "NOT FOUND"
#button_showmore -- showmore_button_text,  showmore_button_text_color
showmore_button = soup.find('button', {'class': 'button-category-showmore border-0 text-center text-realist-white'})
if showmore_button:
    #showmore_button_text
    showmore_button_text = showmore_button.text.strip()
    if showmore_button_text == "แสดงเพิ่มเติม":
        check_dict["SHOWMORE_BUTTON_TEXT"] = 1
    else:
        check_dict["SHOWMORE_BUTTON_TEXT"] = "NOT CORRECT"
    #showmore_button_text_color
    showmore_button_text_color = showmore_button.get('class')
    showmore_button_text_color = showmore_button_text_color[3].split("-")[2]
    if showmore_button_text_color == "white":
        check_dict["SHOWMORE_BUTTON_TEXT_COLOR"] = 1
    else:
        check_dict["SHOWMORE_BUTTON_TEXT_COLOR"] = "NOT CORRECT"
else:
    check_dict["SHOWMORE_BUTTON_TEXT"] = "NOT FOUND"
    check_dict["SHOWMORE_BUTTON_TEXT_COLOR"] = "NOT FOUND"
#condo_ads
condo_ads = soup.find('section', {'class': 'ads-section fullheight'})
#condo_ads_title -- condo_ads_title_text, condo_ads_title_text_color, condo_ads_title_bgcolor
condo_ads_title = condo_ads.find('p')
if condo_ads_title:
    #condo_ads_title_text
    condo_ads_title_text = condo_ads_title.text.strip()
    if condo_ads_title_text == "คอนโดที่น่าสนใจ":
        check_dict["CONDO ADS TITLE TEXT"] = 1
    else:
        check_dict["CONDO ADS TITLE TEXT"] = "NOT CORRECT"
    #condo_ads_title_text_color
    condo_ads_title_text_color = condo_ads_title.get('class')
    condo_ads_title_text_color = condo_ads_title_text_color[0].split("-")[2]
    if condo_ads_title_text_color == "white":
        check_dict["CONDO ADS TITLE TEXT COLOR"] = 1
    else:
        check_dict["CONDO ADS TITLE TEXT COLOR"] = "NOT CORRECT"
    #condo_ads_title_bgcolor
    element = browser.find_element(By.XPATH ,("//div[@class='condo-ads-feature']"));
    background_color = element.value_of_css_property("background-color")
    rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
    hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
    if hex_color == "#26b7be":
        check_dict["CONDO_ADS_TITLE_BGCOLOR"] = 1
    else:
        check_dict["CONDO_ADS_TITLE_BGCOLOR"] = "NOT CORRECT"
else:
    check_dict["CONDO ADS TITLE TEXT"] = "NOT FOUND"
    check_dict["CONDO ADS TITLE TEXT COLOR"] = "NOT FOUND"
    check_dict["CONDO_ADS_TITLE_BGCOLOR"] = "NOT FOUND"
#previous_button -- previous_button_icon
previous_button = condo_ads.find('button', {'aria-label': 'Previous'})
#previous_button_icon
p_button = previous_button.find('path')
if p_button:
    p_button = p_button.get('class')
    p_button = str(p_button).replace("['","").replace("']","").strip()
    if p_button == "arrow":
        check_dict["PREVIOUS BUTTON ICON"] = 1
    else:
        check_dict["PREVIOUS BUTTON ICON"] = "NOT CORRECT"
else:
    check_dict["PREVIOUS BUTTON ICON"] = "NOT FOUND"
#next_button
next_button = condo_ads.find('button', {'aria-label': 'Next'})
if next_button:
    #next_button_icon
    n_button = next_button.find('path')
    n_button = n_button.get('class')
    n_button = str(n_button).replace("['","").replace("']","").strip()
    if n_button == "arrow":
        check_dict["NEXT BUTTON ICON"] = 1
    else:
        check_dict["NEXT BUTTON ICON"] = "NOT CORRECT"
else:
    check_dict["NEXT BUTTON ICON"] = "NOT FOUND"
    
#ads_pic, ads_name
for d , ads_info in enumerate(condo_ads.find_all('div', {'class': 'carousel-cell'})):
    ads_pic = ads_info.find('img')
    ads_img = ads_pic.get('data-src')
    ads_img = ads_img.split("/")[5].replace(".jpg","").replace("-"," ")
    if d == 3:
        break
    for e , ads_content in enumerate(condo_ads.find_all('div', {'class': 'container-fluid pt-4'})):
        ads_title = ads_content.find('h2')
        ads_condo_name = ads_title.text.strip()
        ads_title_color = ads_title.get('class')
        ads_title_color = ads_title_color[1].split("-")[2]
        if d == e:
            if ads_condo_name in ads_img:
                check_dict["ADS_IMG_"+str(d+1)] = 1
            else:
                check_dict["ADS_IMG_"+str(d+1)] = "NOT CORRECT"
            #ads_title_color
            if ads_title_color == "white":
                check_dict["ADS_TITLE_COLOR_"+str(d+1)] = 1
            else:
                check_dict["ADS_TITLE_COLOR_"+str(d+1)] = "NOT CORRECT"
    #ads_place
    for f , ads_place in enumerate(condo_ads.find_all('div', {'class': 'container-fluid py-1'})):
        ads_place_name = ads_place.find('h3')
        ads_p = ads_place_name.text.strip()
        ads_place_color = ads_place_name.get('class')
        ads_place_color = ads_place_color[1].split("-")[2]
        if d == f:
            if ads_p:
                check_dict["ADS_PLACE_"+str(d+1)] = 1
            else:
                check_dict["ADS_PLACE_"+str(d+1)] = "NOT CORRECT"
            #ads_place_color
            if ads_place_color == "white":
                check_dict["ADS_PLACE_COLOR_"+str(d+1)] = 1
            else:
                check_dict["ADS_PLACE_COLOR_"+str(d+1)] = "NOT CORRECT"
    #ads_dev
    for g , ads_dev in enumerate(condo_ads.find_all('div', {'class': 'container-fluid mb-3'})):
        ads_developer = ads_dev.find('p')
        ads_dev_name = ads_developer.text.strip()
        ads_dev_color = ads_developer.get('class')
        ads_dev_color = ads_dev_color[2].split("-")[2]
        if d == g:
            if ads_dev_name:
                check_dict["ADS_DEV_"+str(d+1)] = 1
            else:
                check_dict["ADS_DEV_"+str(d+1)] = "NOT CORRECT"
            #ads_dev_color
            if ads_dev_color == "grey3":
                check_dict["ADS_DEV_COLOR_"+str(d+1)] = 1
            else:
                check_dict["ADS_DEV_COLOR_"+str(d+1)] = "NOT CORRECT"
    #ads_text
    for h , ads_article in enumerate(condo_ads.find_all('div', {'class': 'container-fluid show-three-line'})):
        ads_3line = ads_article.find('p')
        ads_text = ads_article.text.strip()
        ads_text_color = ads_3line.get('class')
        ads_text_color = ads_text_color[1].split("-")[2]
        if d == h:
            if ads_text:
                check_dict["ADS_TEXT_"+str(d+1)] = 1
            else:
                check_dict["ADS_TEXT_"+str(d+1)] = "NOT CORRECT"
            #ads_text_color
            if ads_text_color == "grey3":
                check_dict["ADS_TEXT_COLOR_"+str(d+1)] = 1
            else:
                check_dict["ADS_TEXT_COLOR_"+str(d+1)] = "NOT CORRECT"
    #go_blog -- blog_link, blog_text, blog_text_color, blog_bgcolor
    for i , blog in enumerate(condo_ads.find_all('div', {'class': 'container-fluid mt-4 text-center'})):
        go_blog = condo_ads.find('a')
        to_blog = go_blog.get('href')
        blog_text = go_blog.text.strip()
        blog_text_color = go_blog.get('class')[1].split("-")[2]
        element = browser.find_element(By.XPATH ,("//a[@class='ads-moreinfo-button text-realist-white']"));
        background_color = element.value_of_css_property("background-color")
        rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
        hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
        #blog_link
        if d == i:
            if "https://thelist.group/realist/blog/" in to_blog:
                check_dict["BLOG_LINK"+str(d+1)] = 1
            else:
                check_dict["BLOG_LINK"+str(d+1)] = "NOT CORRECT"
            #blog_text
            if blog_text == "อ่านเพิ่มเติม":
                check_dict["BLOG_TEXT"+str(d+1)] = 1
            else:
                check_dict["BLOG_TEXT"+str(d+1)] = "NOT CORRECT"
            #blog_text_color
            if blog_text_color == "white":
                check_dict["BLOG_TEXT_COLOR_"+str(d+1)] = 1
            else:
                check_dict["BLOG_TEXT_COLOR_"+str(d+1)] = "NOT CORRECT"
            #blog_bgcolor
            if hex_color == "#26b7be":
                check_dict["BLOG_BGCOLOR_"+str(d+1)] = 1
            else:
                check_dict["BLOG_BGCOLOR_"+str(d+1)] = "NOT CORRECT"
#section_related
section_related = soup.find('section', {'class': 'section-relatedd'})
#related_text
section_related_text = section_related.find('h2')
section_related_t = section_related_text.text.strip()
if section_related_t == "RELATED LINK":
    check_dict["SECTION_RELATED_TEXT"] = 1
else:
    check_dict["SECTION_RELATED_TEXT"] = "NOT CORRECT"
#related_text_color
section_related_text_color = section_related_text.get('class')[1].split("-")[2]
if section_related_text_color == "cyan":
    check_dict["SECTION_RELATED_TEXT_COLOR"] = 1
else:
    check_dict["SECTION_RELATED_TEXT_COLOR"] = "NOT CORRECT"
#related_header_text
def relate(related_text):
    if related_header_t == related_text:
            check_dict["RELATED_HEADER_TEXT_"+str(s+1)] = 1
    else:
        check_dict["RELATED_HEADER_TEXT_"+str(s+1)] = "NOT CORRECT"

for s , related_header in enumerate(section_related.find_all('div', {'class': 'mobile-container px-0 related-subheader'})):
    related_header_text = related_header.find('h3')
    related_header_t = related_header_text.text.strip()
    if s == 0:
        relate("ข้อมูลคอนโดใกล้ฉัน")
    elif s == 1:
        relate("ข้อมูลคอนโดล่าสุด")
    elif s == 2:
        relate("ข้อมูลคอนโดแนะนำ")
#related_header_text_color
element = browser.find_element(By.XPATH ,("//div[@class='mobile-container px-0 related-subheader']"));
background_color = element.value_of_css_property("background-color")
rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
if hex_color == "#000000":
    check_dict["RELATED_HEADER_TEXT_COLOR"] = 1
else:
    check_dict["RELATED_HEADER_TEXT_COLOR"] = "NOT CORRECT"
    
def f_related (section_name):
    for j , first_nearest_condo in enumerate(first_condo_nearest.find_all('div', {'class': 'row'})):
        if j == 0:
            first_nearest_condo_pic = first_nearest_condo.find('img')
            first_nearest_condo_pic = first_nearest_condo_pic.get('data-src')
        elif j == 1:
            f_nearest_condo = first_nearest_condo.find('a')
            first_nearest_condo_name = f_nearest_condo.text.strip().replace(" ","-")
            first_nearest_condo_link = f_nearest_condo.get('href').split("/")[6].upper()
            #nearest_condo_link
            if first_nearest_condo_name.upper() in first_nearest_condo_link:
                check_dict[section_name+"_LINK_1"] = 1
            else:
                check_dict[section_name+"_LINK_1"] = "NOT CORRECT"
            #nearest_condo_pic
            if first_nearest_condo_link.split("-")[-1] in first_nearest_condo_pic:
                check_dict[section_name+"_PIC_1"] = 1
            else:
                check_dict[section_name+"_PIC_1"] = "NOT CORRECT"
        elif j == 3:
            for k , info in enumerate(first_nearest_condo.find_all('span')):
                if k == 0:
                    info_title = info.text.replace("&nbsp;","").strip()
                    info_title_color = info.get('class')
                    info_title_color = str(info_title_color).split("-")[2].replace("']","")
                    #info_title
                    if info_title == "เฉลี่ย" or "เริ่มต้น":
                        check_dict[section_name+"_INFO_TITLE_1"] = 1
                    else:
                        check_dict[section_name+"_INFO_TITLE_1"] = "NOT CORRECT"
                    #info_title_color
                    if info_title_color == "grey1":
                        check_dict[section_name+"_INFO_TITLE_COLOR_1"] = 1
                    else:
                        check_dict[section_name+"_INFO_TITLE_COLOR_1"] = "NOT CORRECT"
                elif k == 1:
                    info_data = info.get('class')
                    info_data = str(info_data).split("-")[2].replace("']","")
                    #info_data_color
                    if info_data == "cyan":
                        check_dict[section_name+"_INFO_DATA_COLOR_1"] = 1
                    else:
                        check_dict[section_name+"_INFO_DATA_COLOR_1"] = "NOT CORRECT"
                elif k == 2:
                    info_unit = info.text.replace("&nbsp;","").strip()
                    info_unit_color = info.get('class')
                    info_unit_color = str(info_unit_color).split("-")[2].replace("']","")
                    #info_unit_text
                    if info_unit == "บ./ตร.ม.":
                        check_dict[section_name+"_INFO_UNIT_1"] = 1
                    else:
                        check_dict[section_name+"_INFO_UNIT_1"] = "NOT CORRECT"
                    #info_unit_color
                    if info_unit_color == "grey1":
                        check_dict[section_name+"_INFO_UNIT_COLOR_1"] = 1
                    else:
                        check_dict[section_name+"_INFO_UNIT_COLOR_1"] = "NOT CORRECT"
                        
def other_related (s_name):
    for j , nearest_condo in enumerate(nearest_condo_list.find_all('div', {'class': 'row'})):
        if j == 0:
            nearest_condo_pic = nearest_condo.find('img')
            nearest_condo_pic = nearest_condo_pic.get('data-src')
        elif j == 1:
            o_nearest_condo = nearest_condo.find('a')
            nearest_condo_name = o_nearest_condo.text.strip().replace(" ","-")
            nearest_condo_link = o_nearest_condo.get('href').split("/")[6].upper()
            #nearest_condo_link
            if nearest_condo_name.upper() in nearest_condo_link:
                check_dict[s_name+"_LINK_"+str(m+2)] = 1
            else:
                check_dict[s_name+"_LINK_"+str(m+2)] = "NOT CORRECT"
            #nearest_condo_pic
            if nearest_condo_link.split("-")[-1] in nearest_condo_pic:
                check_dict[s_name+"_PIC_"+str(m+2)] = 1
            elif "Default" in nearest_condo_pic:
                check_dict[s_name+"_PIC_"+str(m+2)] = 1
            else:
                check_dict[s_name+"_PIC_"+str(m+2)] = "NOT CORRECT"
        elif j == 3:
            for k , abount in enumerate(nearest_condo.find_all('span')):
                if k == 0:
                    abount_title = abount.text.replace("&nbsp;","").strip()
                    abount_title_color = abount.get('class')
                    abount_title_color = str(abount_title_color).split("-")[2].replace("']","")
                    #info_title
                    if abount_title == "เฉลี่ย" or "เริ่มต้น":
                        check_dict[s_name+"_INFO_TITLE_"+str(m+2)] = 1
                    else:
                        check_dict[s_name+"_INFO_TITLE_"+str(m+2)] = "NOT CORRECT"
                    #info_title_color
                    if abount_title_color == "grey1":
                        check_dict[s_name+"_INFO_TITLE_COLOR_"+str(m+2)] = 1
                    else:
                        check_dict[s_name+"_INFO_TITLE_COLOR_"+str(m+2)] = "NOT CORRECT"
                if k == 1:
                    abount_data = abount.get('class')
                    abount_data = str(abount_data).split("-")[2].replace("']","")
                    #info_data_color
                    if abount_data == "cyan":
                        check_dict[s_name+"_INFO_DATA_COLOR_"+str(m+2)] = 1
                    else:
                        check_dict[s_name+"_INFO_DATA_COLOR_"+str(m+2)] = "NOT CORRECT"
                elif k == 2:
                    abount_unit = abount.text.replace("&nbsp;","").strip()
                    abount_unit_color = abount.get('class')
                    abount_unit_color = str(abount_unit_color).split("-")[2].replace("']","")
                    #info_unit_text
                    if abount_unit == "บ./ตร.ม.":
                        check_dict[s_name+"_INFO_UNIT_"+str(m+2)] = 1
                    else:
                        check_dict[s_name+"_INFO_UNIT_"+str(m+2)] = "NOT CORRECT"
                    #info_unit_color
                    if abount_unit_color == "grey1":
                        check_dict[s_name+"_INFO_UNIT_COLOR_"+str(m+2)] = 1
                    else:
                        check_dict[s_name+"_INFO_UNIT_COLOR_"+str(m+2)] = "NOT CORRECT"
    
#nearest_condo_list
list_nearest = []
dot_list = []
for n , nearest_list in enumerate(soup.find_all('div', {'class': 'related-condo-slide'})):
    first_condo_nearest = nearest_list.find('div', {'class': 'carousel-cell shadow is-selected'}) #count_related
    list_nearest.append(first_condo_nearest) #count_related
    for p , relate_carousel in enumerate(nearest_list.find_all('ol', {'class': 'flickity-page-dots'})):
        for q , relate_carousel_dot in enumerate(relate_carousel.find_all('li')):
            dot = relate_carousel_dot.get('aria-label')
            dot_list.append(relate_carousel_dot)
    if n == 0:
        f_related("NEAREST")
    elif n == 1:
        f_related("NEWEST")
    elif n == 2:
        f_related("RECOMMAND")
    for m , nearest_condo_list in enumerate(nearest_list.find_all('div', {'class': 'carousel-cell shadow'})): #count_related
        list_nearest.append(nearest_condo_list) #count_related
        if n == 0:
            other_related("NEAREST")
        elif n == 1:
            other_related("NEWEST")
        elif n == 2:
            other_related("RECOMMAND")
if len(list_nearest) == 60: #count_related
    check_dict["COUNT_RELATED"] = 1 #count_related
else: #count_related
    check_dict["COUNT_RELATED"] = "NOT CORRECT" #count_related

#related_stat
def relate_stat(stat_text):
    for l , info_stat in enumerate(related_stat.find_all('div', {'class': 'col-4 d-flex align-items-center justify-content-center related-stat-text show-single-line'})):
        if l == 0:
            related_stat_text_1 = info_stat.text.strip()
            if "เริ่ม" in related_stat_text_1:
                    check_dict[stat_text+str(o+1)+"_RELATED_STAT_TEXT_1"] = 1
            else:
                check_dict[stat_text+str(o+1)+"_RELATED_STAT_TEXT_1"] = "NOT CORRECT"
        elif l == 1:
            related_stat_text_2 = info_stat.text.strip()
            if "RESALE" in related_stat_text_2 or "ขายแล้ว" in related_stat_text_2:
                check_dict[stat_text+str(o+1)+"_RELATED_STAT_TEXT_2"] = 1
            else:
                check_dict[stat_text+str(o+1)+"_RELATED_STAT_TEXT_2"] = "NOT CORRECT"
        elif l == 2:
            related_stat_text_3 = info_stat.text.strip()
            if "เสร็จ" in related_stat_text_3 or "เปิดตัว" in related_stat_text_3:
                check_dict[stat_text+str(o+1)+"_RELATED_STAT_TEXT_3"] = 1
            else:
                check_dict[stat_text+str(o+1)+"_RELATED_STAT_TEXT_3"] = "NOT CORRECT"

#related_stat_text_color
element = browser.find_element(By.XPATH ,("//div[@class='col-4 d-flex align-items-center justify-content-center related-stat-text show-single-line']"));
background_color = element.value_of_css_property("background-color")
rgba_values = [int(val) for val in background_color.strip("rgba(").strip(")").split(", ")]
hex_color = "#" + "".join([hex(val)[2:].zfill(2) for val in rgba_values[:3]])
if hex_color == "#000000":
    check_dict["RELATED_STAT_TEXT_COLOR"] = 1
else:
    check_dict["RELATED_STAT_TEXT_COLOR"] = "NOT CORRECT"

for o , related_stat in enumerate(section_related.find_all('div', {'class': 'container related-stat py-0 px-2'})):
    #related_text_1
    if o in range (0,20):
        relate_stat("NEAREST_")
    #related_text_2
    elif o in range (20,40):
        relate_stat("NEWEST_")
    #related_text_3
    elif o in range (40,60):
        relate_stat("RECOMMAND_")
        
if len(dot_list) == 60: #count_related_dot
        check_dict["COUNT_RELATED_DOT"] = 1 #count_related_dot
else: #count_related_dot
    check_dict["COUNT_RELATED_DOT"] = "NOT CORRECT" #count_related_dot
    
#article_section
section_article = soup.find('section', {'class': 'article-section'})
#article_text
section_article_text = section_article.find('h2')
section_article_t = section_article_text.text.strip()
if section_article_t == "ARTICLE":
    check_dict["SECTION_ARTICLE_TEXT"] = 1
else:
    check_dict["SECTION_ARTICLE_TEXT"] = "NOT CORRECT"
#article_text_color
section_article_text_color = section_article_text.get('class')[0].split("-")[2]
if section_article_text_color == "white":
    check_dict["SECTION_ARTICLE_TEXT_COLOR"] = 1
else:
    check_dict["SECTION_ARTICLE_TEXT_COLOR"] = "NOT CORRECT"
#article_header_text
def article(article_text):
    if article_header_t == article_text:
            check_dict["ARTICLE_HEADER_TEXT_"+str(r+1)] = 1
    else:
        check_dict["ARTICLE_HEADER_TEXT_"+str(r+1)] = "NOT CORRECT"
    #article_header_text_color
    if article_header_text_color == "white":
        check_dict["ARTICLE_HEADER_TEXT_"+str(r+1)+"_COLOR"] = 1
    else:
        check_dict["ARTICLE_HEADER_TEXT_"+str(r+1)+"_COLOR"] = "NOT CORRECT"
#article_header_text, #article_header_text_color
for r , article_header in enumerate(section_article.find_all('div', {'class': 'col-12 px-0 d-block related-subheader'})):
    article_header_text = article_header.find('h3')
    article_header_t = article_header_text.text.strip()
    article_header_text_color = article_header_text.get('class')[2].split("-")[2]
    if r == 0:
        article("บทความคอนโดล่าสุด")
    elif r == 1:
        article("บทความบ้าน/ทาวน์โฮมล่าสุด")
        
#article_list
def article_readmore(type):
    if ".jpg" in article_image:
        check_dict["ARTICLE_IMAGE_"+type] = 1
    else:
        check_dict["ARTICLE_IMAGE_"+type] = "NOT CORRECT"
    if read_more_t == "อ่านเพิ่มเติม":
        check_dict["READ_MORE_TEXT_"+type] = 1
    else:
        check_dict["READ_MORE_TEXT_"+type] = "NOT CORRECT"
    if read_more_a == "fa-chevron-right":
        check_dict["ARROW_"+type] = 1
    else:
        check_dict["ARROW_"+type] = "NOT CORRECT"
        
def read_in(type):
    if "realist/blog" in article_link:
        check_dict["ARTICLE_LINK_"+type] = 1
    else:
        check_dict["ARTICLE_LINK_"+type] = "NOT CORRECT"
    if article_intro:
        check_dict["ARTICLE_INTRO_"+type] = 1
    else:
        check_dict["ARTICLE_INTRO_"+type] = "NOT CORRECT"
    if article_tag_icon == "fa-tag":
        check_dict["ARTICLE_TAG_"+type] = 1
    else:
        check_dict["ARTICLE_TAG_"+type] = "NOT CORRECT"
    if len(article_section_list) == 0:
        check_dict["ARTICLE_SECTION_"+type] = "NOT FOUND"
    else:
        check_dict["ARTICLE_SECTION_"+type] = len(article_section_list)
    if "realist/blog" in read_article_link:
        check_dict["READ_ARTICLE_LINK_"+type] = 1
    else:
        check_dict["READ_ARTICLE_LINK_"+type] = "NOT CORRECT"
    if read_icon == "fa-file-alt":
        check_dict["READ_ARTICLE_ICON_"+type] = 1
    else:
        check_dict["READ_ARTICLE_ICON_"+type] = "NOT CORRECT"
    if read_article_text == "อ่านบทความนี้":
        check_dict["READ_ARTICLE_TEXT_"+type] = 1
    else:
        check_dict["READ_ARTICLE_TEXT_"+type] = "NOT CORRECT"
        
def many_link(type):
    if condo_data_icon == "fa-chart-simple":
        check_dict["ICON_+"+type] = 1
    else:
        check_dict["ICON_+"+type] = "NOT CORRECT"
    if condo_data_title == "ดูข้อมูล REAL DATA":
        check_dict["TITLE_"+type] = 1
    else:
        check_dict["TITLE_"+type] = "NOT CORRECT"

#article_list
list_article = []
for t , articles in enumerate(soup.find_all('div', {'class': 'carousel-block'})):
    article_list = articles.find('div', {'class': 'front-carousel-section d-flex flex-column'})
    list_article.append(article_list) #count_article
    #article_link_check
    link_check = article_list.find('div', {'class': 'col p-0 cell-image d-flex align-items-center justify-content-center bg-dark'})
    #read_more_text
    read_more = article_list.find('div', {'class': 'row m-0 d-block mobile-carousel-readmore'})
    read_more_text = read_more.find('p')
    read_more_t = read_more_text.text.strip()
    #read_more_arrow
    read_more_arrow = read_more.find('i')
    read_more_a = read_more_arrow.get('class')[1]
    #article_pic
    article_image = link_check.find('img')
    article_image = article_image.get('data-src')
    if t in range(0,20):
        article_readmore("CONDO_"+str(t+1))
    elif t in range(20,40):
        article_readmore("HOUSE_"+str(t-19))
    #article_info
    article_info_all = articles.find('div', {'class': 'container d-flex flex-column info-carousel-section carousel-hide'})
    #article_link
    article_link = article_info_all.find('a')
    article_link = article_link.get('href')
    #article_intro
    article_intro = article_info_all.find('p').text.strip()
    #article_tag_icon
    article_tag_icon = article_info_all.find('i')
    article_tag_icon = article_tag_icon.get('class')[1]
    #article_section
    article_section_list = []
    article_section = article_info_all.find('div', {'class': 'col-10 tag-mobile-text pl-0'})
    for v , article_sec in enumerate(article_section.find_all('a')):
        article_section_list.append(article_sec)
    #read_article
    read = article_info_all.find('div', {'class': 'container px-0 py-2 mt-auto'})
    click_read = read.find('div', {'class': 'row'})
    #if have 2 button
    for w , read_article in enumerate(click_read.find_all('div', {'class': 'col-6'})):
        if w == 0:
            #read_article_link
            read_article_link = read_article.find('a')
            read_article_link = read_article_link.get('href')
            #read_article_icon
            read_article_icon = read_article.find('i')
            read_icon = read_article_icon.get('class')[1]
            #read_article_text
            read_article_text = read_article.find('p')
            read_article_text = read_article_text.text.strip()
        elif w == 1:
            #condo_data_link
            condo_data_link = read_article.find('div')
            condo_data_link = condo_data_link.get('onclick')
            #see_data
            see_data = read_article.find('p')
            see_data_text = see_data.text.strip()
            for u , see_data_icon in enumerate(see_data.find_all('i')):
                if u == 0:
                    icon_1 = see_data_icon.get('class')[1]
                    if t in range(0,20):
                        if icon_1 == "fa-chart-simple":
                            check_dict["ICON_1_CONDO_DATA_"+str(t+1)] = 1
                        else:
                            check_dict["ICON_1_CONDO_DATA_"+str(t+1)] = "NOT CORRECT"
                    elif t in range(20,40):
                        if icon_1 == "fa-chart-simple":
                            check_dict["ICON_1_HOUSE_DATA_"+str(t-19)] = 1
                        else:
                            check_dict["ICON_1_HOUSE_DATA_"+str(t-19)] = "NOT CORRECT"
                elif u == 1:
                    icon_2 = see_data_icon.get('class')[1]
                    if t in range(0,20):
                        if icon_2 == "fa-external-link-alt":
                            check_dict["CONDO_DATA_ICON_2_"+str(t+1)] = 1
                        else:
                            check_dict["ICON_2_CONDO_DATA_"+str(t+1)] = "NOT CORRECT"
                    elif t in range(20,40):
                        if icon_2 == "fa-external-link-alt":
                            check_dict["ICON_2_CONDO_DATA_"+str(t-19)] = 1
                        else:
                            check_dict["ICON_2_CONDO_DATA_"+str(t-19)] = "NOT CORRECT"
            if see_data_text:
                if t in range(0,20):
                    if see_data_text == "ดูข้อมูลนี้":
                        check_dict["TEXT_CONDO_DATA_"+str(t+1)] = 1
                    else:
                        check_dict["TEXT_CONDO_DATA_"+str(t+1)] = "NOT CORRECT"
                elif t in range(20,40):
                    if see_data_text == "ดูข้อมูลนี้":
                        check_dict["TEXT_HOUSE_DATA_"+str(t-19)] = 1
                    else:
                        check_dict["TEXT_HOUSE_DATA_"+str(t-19)] = "NOT CORRECT"
            if condo_data_link:
                if "realist/condo/proj" in condo_data_link:
                    check_dict["LINK_CONDO_DATA_"+str(t+1)] = 1
                else:
                    check_dict["LINK_CONDO_DATA_"+str(t+1)]  = "NOT CORRECT"
            else:
                condo_data_list = articles.find('div', {'class': 'container d-flex flex-column condo-carousel-section carousel-hide'})
                #condo_data_icon
                condo_data_icon = condo_data_list.find('i')
                condo_data_icon = condo_data_icon.get('class')[1]
                #condo_data_title
                condo_data_title = condo_data_list.find('p').text.strip()
                #condo_data_link
                for x , condo_data_link_list in enumerate(condo_data_list.find_all('div', {'class': 'condo-button-link d-flex justify-content-center align-items-center'})):
                    condo_data_link = condo_data_link_list.get('onclick')
                    condo_data_link_text = condo_data_link_list.find('p').text.strip()
                    if t in range(0,20):
                        if "realist/condo/proj" in condo_data_link and condo_data_link_text.replace("\n"," ").split(" ")[0].capitalize() in condo_data_link:
                            check_dict["CONDO_DATA_LINK_"+str(t+1)+"_"+str(x+1)] = 1
                        else:
                            check_dict["CONDO_DATA_LINK_"+str(t+1)+"_"+str(x+1)]  = "NOT CORRECT"
                    elif t in range(20,40):
                        if "realist/condo/proj" in condo_data_link and condo_data_link_text.replace("\n"," ").split(" ")[0].capitalize() in condo_data_link:
                            check_dict["CONDO_DATA_LINK_"+str(t-19)+"_"+str(x+1)] = 1
                        else:
                            check_dict["CONDO_DATA_LINK_"+str(t-19)+"_"+str(x+1)]  = "NOT CORRECT"
                if t in range(0,20):
                    many_link("CONDO_DATA_"+str(t+1))
                elif t in range(20,40):
                    many_link("CONDO_DATA_"+str(t-19))
    #if have 1 button
    read_article = click_read.find('div', {'class': 'col-12'})
    if read_article:
        #read_article_link
        read_article_link = read_article.find('a')
        read_article_link = read_article_link.get('href')
        #read_article_icon
        read_article_icon = read_article.find('i')
        read_icon = read_article_icon.get('class')[1]
        #read_article_text
        read_article_text = read_article.find('p')
        read_article_text = read_article_text.text.strip()
    if t in range(0,20):
        read_in("CONDO_"+str(t+1))
    elif t in range(20,40):
        read_in("HOUSE_"+str(t-19))
#date
for y , article_date in enumerate(section_article.find_all('div', {'class': 'row m-0 text-white'})):
    #date_color
    date_color = article_date.get('class')[2].split("-")[1]
    #date_icon
    date_icon = article_date.find("i")
    date_icon = date_icon.get('class')[1]
    if y in range(0,20):
        if date_color == "white":
            check_dict["CONDO_DATE_COLOR_"+str(y+1)] = 1
        else:
            check_dict["CONDO_DATE_COLOR_"+str(y+1)] = "NOT CORRECT"
        if date_icon == "fa-calendar":
            check_dict["CONDO_DATE_ICON_"+str(y+1)] = 1
        else:
            check_dict["CONDO_DATE_ICON_"+str(y+1)] = "NOT CORRECT"
    elif t in range(20,40):
        if date_color == "white":
            check_dict["HOUSE_DATE_COLOR_"+str(y-19)] = 1
        else:
            check_dict["HOUSE_DATE_COLOR_"+str(y-19)] = "NOT CORRECT"
        if date_icon == "fa-calendar":
            check_dict["HOUSE_DATE_ICON_"+str(y-19)] = 1
        else:
            check_dict["HOUSE_DATE_ICON_"+str(y-19)] = "NOT CORRECT"
#read_more click
#browser.execute_script("window.scrollTo(0, 6600)")
#article_more = browser.find_element(By.XPATH ,("//div[@class='row m-0 d-block mobile-carousel-readmore']"))
#try:
#    article_more.click()
#    check_dict["article_click"] = 1
#except:
#    check_dict["article_click"] = "CANT CLICK"
if len(list_article) == 40: #count_article
    check_dict["COUNT_ARTICLE"] = 1 #count_article
else: #count_article
    check_dict["COUNT_ARTICLE"] = "NOT CORRECT" #count_article

test_list.append(check_dict)
test_df = pd.DataFrame(test_list)
test_df.to_csv('test_mobile_2023.csv')
browser.close()
print("done")
from selenium import webdriver
from bs4 import BeautifulSoup as bs
import time
from selenium.webdriver.common.by import By
from collections import Counter

url ='http://159.223.51.33/realist/condo/'
test_list = []

browser = webdriver.Chrome()
browser.set_window_size(390, 844)
browser.get("http://google.com")
browser.get(url)
soup = bs(browser.page_source, 'html.parser')
#browser.execute_script("window.scrollTo(0, 6500)")

def click_list():
    list_menu.click()
    time.sleep(1)
    
def not_found_menu():
    print('list bgcolor not found')
    x = 0
    text = ["คอนโดที่แนะนำ", "Spotlight", "ราคา", "รถไฟฟ้า", "ทำเล", "ผู้พัฒนาโครงการ", "แบรนด์"]
    while x in range (0,7):
        print('listing_text '+text[x]+' not found')
        print('listing_text color '+text[x]+' not found')
        print('listing_icon '+text[x]+' not found')
        print('listing_icon color '+text[x]+' not found')
        x+=1

def list_click_not_found():
    print('คอนโดที่แนะนำ click not found')
    print('Spotlight click not found')
    print('ราคา click not found')
    print('รถไฟฟ้า click not found')
    print('ทำเล click not found')
    print('ผู้พัฒนาโครงการ click not found')
    print('แบรนด์ click not found')

def not_found():
    print('condo data icon not found')
    print('condo data link not found')
    print('condo data text not found')
    print('realist blog icon not found')
    print('realist blog link not found')
    print('realist blog text not found')
    
def social_not_found():
    print('facebook link not found')
    print('facebook icon not found')
    print('line link not found')
    print('line icon not found')
    print('youtube link not found')
    print('youtube icon not found')
    print('instagram link not found')
    print('instagram icon not found')
    
def not_found_all():
    print('click not found')
    not_found()
    not_found_menu()
    list_click_not_found()
    social_not_found()
    print('exit color not found')
    print('exit icon not found')
    print('exit click not found')
    
def socials(type):
    if type in social_link:
        print(type+' link ok')
    else:
        print(type+' link no')
    if type in social_icon:
        print(type+' icon ok')
    else:
        print(type+' icon no')
# test commmit 3
#list_menu_click
list_menu = browser.find_element(By.XPATH ,("//button[@data-target='#topbar-mobile']"))
on_screen = list_menu.is_displayed();
if on_screen:
    try:
        click_list()
        print('click ok')
    except:
        print('click no')
    #list_menu_bgcolor
    element = browser.find_element(By.XPATH ,("//div[@id='topbar-mobile']"));
    background_color = element.value_of_css_property("background-color")
    if background_color == "rgba(0, 0, 0, 1)":
        print('bg color ok')
    else:
        print('bg color no')
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
                            print('condo data icon ok')
                        else:
                            print('condo data icon no')
                        condo_data_link_and_text = condo_data.find('a')
                        #condo_data_link
                        condo_data_link = condo_data_link_and_text.get('href')
                        if "/realist/condo/" in condo_data_link:
                            print('condo data link ok')
                        else:
                            print('condo data link no')
                        #condo_data_name
                        condo_data_text = condo_data_link_and_text.text.strip()
                        if condo_data_text == "Condo Data":
                            print('condo data text ok')
                        else:
                            print('condo data text no')
                    elif i == 1:
                        #realist_blog_icon
                        realist_blog_icon = condo_data.find('i')
                        realist_blog_icon = realist_blog_icon.get('class')
                        if "fa-book" in realist_blog_icon:
                            print('realist blog icon ok')
                        else:
                            print('realist blog icon no')
                        realist_blog_link_and_text = condo_data.find('a')
                        #realist_blog_link
                        realist_blog_link = realist_blog_link_and_text.get('href')
                        if "/realist/blog" in realist_blog_link:
                            print('realist blog link ok')
                        else:
                            print('realist blog link no')
                        #condo_data_name
                        realist_blog_text = realist_blog_link_and_text.text.strip()
                        if realist_blog_text == "Realist Blog":
                            print('realist blog text ok')
                        else:
                            print('realist blog text no')
            menu = list_show.find('div', {'id': 'mobile-top-menu'})
            if menu:
                bgcolor = menu.find('div', {'class': 'card-header p-0 bg-realist-black'})
                bgcolor = bgcolor.get('class')
                bgcolor = str(bgcolor)
                if "black" in bgcolor:
                    print('list bgcolor ok')
                else:
                    print('list bgcolor no')
                text = ["คอนโดที่แนะนำ", "Spotlight", "ราคา", "รถไฟฟ้า", "ทำเล", "ผู้พัฒนาโครงการ", "แบรนด์"]
                for i , listing in enumerate(menu.find_all('div', {'class': 'card bg-transparent'})):
                    if listing:
                        listing_info = listing.find('p')
                        listing_text = listing_info.text.strip()
                        if text[i] == listing_text:
                            print('listing text '+text[i]+' ok')
                        else:
                            print('listing text '+text[i]+' no')
                        listing_text_color = listing_info.get('class')
                        listing_text_color = str(listing_text_color)
                        if "cyan" in listing_text_color:
                            print('listing text color '+text[i]+' ok')
                        else:
                            print('listing text color '+text[i]+' no')
                        listing_arrow = listing.find('i')
                        listing_icon = listing_arrow.get('class')
                        listing_icon = str(listing_icon)
                        if "angle-down" in listing_icon:
                            print('listing icon '+text[i]+' ok')
                        else:
                            print('listing icon '+text[i]+' no')
                        if "grey2" in listing_icon:
                            print('listing icon color '+text[i]+' ok')
                        else:
                            print('listing icon color '+text[i]+' no')
                    else:
                        print('listing text '+text[i]+' not found')
                        print('listing text color '+text[i]+' not found')
                        print('listing icon '+text[i]+' not found')
                        print('listing icon color '+text[i]+' not found')
            else:
                not_found_menu()        
            click_listing = browser.find_elements(By.XPATH ,("//div[@class='card bg-transparent']"))
            element_counts = Counter(click_listing)
            x = 1
            text = ["คอนโดที่แนะนำ", "Spotlight", "ราคา", "รถไฟฟ้า", "ทำเล", "ผู้พัฒนาโครงการ", "แบรนด์"]
            for element, count in element_counts.items():
                on_screen = element.is_displayed();
                if on_screen:
                    if x <= 7:
                        try:
                            element.click()
                            time.sleep(1)
                            print(text[x-1]+' click ok')
                            x += 1
                        except:
                            print(text[x-1]+' click no')
                            x += 1
                else:
                    print(text[x-1]+' click not found')
            social = list_show.find('div', {'class': 'row justify-content-center p-3 m-0'})
            thelist_social = ["facebook", "line", "youtube", "instagram"]
            if social:
                for i , contact in enumerate(social.find_all('div', {'class': 'col-auto px-2'})):
                    if contact:
                        social_link = contact.find('a')
                        social_link = social_link.get('href')
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
                    print('exit color ok')
                else:
                    print('exit color no')
                exit_icon = exit_button_all.find('i')
                exit_icon = exit_icon.get('class')
                if "xmark" in str(exit_icon):
                    print('exit icon ok')
                else:
                    print('exit icon no')
            else:
                print('exit color not found')
                print('exit icon not found')
            exit_click = browser.find_element(By.XPATH ,("//button[@class='mobile-topbar-collapse bg-transparent border-0 py-0 pr-0 pl-5']"))
            on_screen = exit_click.is_displayed();
            if on_screen:
                try:
                    exit_click.click()
                    print('exit click ok')
                except:
                    print('exit click no')
            else:
                print('exit click not found')
        else:
            not_found_all()
    else:
        not_found_all()
else:
    not_found_all()
browser.close()
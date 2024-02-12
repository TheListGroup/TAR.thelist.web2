from selenium import webdriver
from bs4 import BeautifulSoup as bs
import pandas as pd
import time
import json
from selenium.webdriver.common.by import By
from selenium.webdriver.common.actions.mouse_button import MouseButton
from selenium.webdriver.common.actions.action_builder import ActionBuilder
from selenium.webdriver import ActionChains
import re
from random import randint
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.keys import Keys

urls = pd.read_csv("realist_link.csv")
data_info_list = []

prv_condo = pd.read_csv("realist_data_open.csv")
for ind in prv_condo.index:
    data_info_dict = prv_condo.iloc[ind].to_dict()
    data_info_list.append(data_info_dict)
ind = len(data_info_list)-1
no = len(urls.index)
while ind in urls.index:
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--window-size=1920x1080")
    browser = webdriver.Chrome(options=chrome_options)
    url = urls.iloc[ind][3]
    browser.get(url)
    #condo code
    code = url.split("-")
    code = code[-1]
    code = code.replace("/","")
    print(f"{ind} : {code} : {url}")
    
    soup = bs(browser.page_source, 'html.parser')
    ##condo name thai
    condo_name = soup.find('title')
    condo_name_thai = condo_name.text.strip()
    condo_name_thai = re.findall(r'\(.*?\)', condo_name_thai)
    condo_name_thai = str(condo_name_thai)
    condo_name_thai = condo_name_thai[3:-3]
    #condo name eng
    condo_name_eng = condo_name.text.strip()
    condo_name_eng = re.sub(r"\([^()]*\)", "", condo_name_eng)
    condo_name_eng = condo_name_eng.replace("REALIST","")
    condo_name_eng = condo_name_eng.replace("|","")
    condo_name_eng = condo_name_eng.strip()
    ##link
    urls_in = soup.find('link',{'rel':"canonical"})
    urls_in = urls_in.get('href')
    if condo_name:
        data_info_dict = {'Condo_Code': code, 'Condo_Name': condo_name_thai, 'Condo_ENName': condo_name_eng, 'url': urls_in}
    #developer
    developer = soup.find('h2')
    developer = developer.text.strip()
    data_info_dict['Developer'] = developer
    #data top page 4 section
    data_4 = soup.find('div' ,{'class':"col-12 px-0 d-none d-sm-none d-md-none d-lg-block"})
    for d , data_4_in in enumerate(data_4.find_all('div' ,{'class':"col-3 mt-5 text-center p-0"})) :
        if data_4_in:
            section = data_4_in.find('div' ,{'class':"text-realist-cyan"})
            section = section.text.strip()
            value = data_4_in.find('h3' ,{'class':"text-realist-white"})
            value = value.text.strip()
            if d == 0:
                section_1 = re.sub(r"\([^()]*\)", "", section)
                section_1 = section_1+"(บ./ตร.ม.)"
                section_1 = section_1.strip()
                value_1 = value.replace("บ./ตร.ม.","")
                value_1 = value_1.strip()
                value_1 = value_1.replace("N/A","")
                section_y1 = data_4_in.find('div' ,{'class':"text-realist-cyan"})
                section_y1 = section_y1.text.strip()
                section_y1 = re.findall(r'\(.*?\)', section_y1)
                section_y1 = str(section_y1)
                section_y1 = section_y1[3:-3]
            if d == 1:
                section_2 = re.sub(r"\([^()]*\)", "", section)
                section_2 = section_2+"(ลบ.)"
                section_2 = section_2.strip()
                value_2 = value.replace("ลบ.","")
                value_2 = value_2.strip()
                value_2 = value_2.replace("N/A","")
                section_y2 = data_4_in.find('div' ,{'class':"text-realist-cyan"})
                section_y2 = section_y2.text.strip()
                section_y2 = re.findall(r'\(.*?\)', section_y2)
                section_y2 = str(section_y2)
                section_y2 = section_y2[3:-3]
            if d == 2:
                section_3 = re.sub(r"\([^()]*\)", "", section)
                section_3 = section_3.strip()
                value_3 = value
                value_3 = value_3.replace("N/A","")
                section_y3 = data_4_in.find('div' ,{'class':"text-realist-cyan"})
                section_y3 = section_y3.text.strip()
                section_y3 = re.findall(r'\(.*?\)', section_y3)
                section_y3 = str(section_y3)
                section_y3 = section_y3[3:-3]
            if d == 3:
                section_4 = section
                value_4 = value
                value_4 = value_4.replace("N/A","")
    data_info_dict['Section_1'] = section_1
    data_info_dict['Value_Price_Per_sqm'] = value_1
    data_info_dict['Date_Price_Per_sqm'] = section_y1
    data_info_dict['Section_2'] = section_2
    data_info_dict['Value_Price_Per_Unit'] = value_2
    data_info_dict['Date_Price_Per_Unit'] = section_y2
    data_info_dict[section_3] = value_3
    data_info_dict['Project_Status_Year'] = section_y3
    data_info_dict['Section_4'] = section_4
    data_info_dict['YEAR'] = value_4
    #spotlight
    spotlight = soup.find('div' ,{'class':"flickity-slider"})
    spotlight_all = ''
    for s , spotlight_in in enumerate(spotlight.find_all('div' ,{'class':"col text-center condo-spotlight-text text-realist-white"})) :
        if len(spotlight_in.text.strip())>0:
            spotlight_all = spotlight_all + ',' + spotlight_in.text.strip()
    spotlight_all = spotlight_all[1:]
    data_info_dict['Spotlight'] = spotlight_all
    #fact sheet
    #ทำแบบนี้เพราะอยากใส่หน่วยไว้ข้างบนด้วย
    array_location = ['สถานี','ถนน','เขต','ย่าน','จังหวัด']
    array_price = ['ราคาเฉลี่ย/ตร.ม. (บ./ตร.ม.)','ราคา Resell เฉลี่ย/ตร.ม. (บ./ตร.ม.)','ราคาเริ่มต้น/ตร.ม. (บ./ตร.ม.)','ราคาเรื่มต้น/ยูนิต (ลบ.)','ค่าส่วนกลาง (บ./ตร.ม./เดือน)']
    array_building =['FinishYear','Land (ไร่)','Building','Unit','Project_Status']
    array_room = ['Room_Studio (ตร.ม.)','1_Bedroom (ตร.ม.)','2_Bedroom (ตร.ม.)','3_Bedroom (ตร.ม.)','4_Bedroom (ตร.ม.)']
    array_year = ['Year_Price_1','Year_Price_2','Year_Price_3','Year_Price_4']
    n = 0
    x = 0
    fact_sheet = soup.find('div' ,{'id':"factsheet-desktop"})
    for f , fact_sheet_in in enumerate(fact_sheet.find_all('div' ,{'class':"col p-0 condo-factsheet-block"})) :
        if fact_sheet_in:
            if f == 0:
                for location , fact_sheet_inn in enumerate(fact_sheet_in.find_all('span' ,{'class':"condo-factsheet-value-block-text show-single-line"})) :
                    if fact_sheet_inn:  
                        fact_sheet_data = fact_sheet_inn.text.strip()
                        data_info_dict[array_location[location]] = fact_sheet_data
            if f == 1:
                for price , fact_sheet_inn in enumerate(fact_sheet_in.find_all('div' ,{'class':"row m-0"})) :
                    if fact_sheet_inn:
                        fact_sheet_data = fact_sheet_inn.find('span' ,{'class':"condo-factsheet-value-block-text show-single-line"})
                        fact_sheet_year = fact_sheet_inn.find('span' ,{'class':"condo-factsheet-key-block-text"})
                        if price%2==1:   # 1,3,5,7
                            fact_sheet_year = fact_sheet_year.text.strip()
                            fact_sheet_year = re.findall(r'\(.*?\)', fact_sheet_year)
                            if fact_sheet_year:
                                fact_sheet_year = str(fact_sheet_year)
                                fact_sheet_year = fact_sheet_year[3:-3]
                                data_info_dict[array_year[price-(1+n)]] = fact_sheet_year
                            n+=1  
                        if price%2==0:   # 2,4,6,8,10
                            if price>0:
                                fact_sheet_data = fact_sheet_data.text.strip()
                                fact_sheet_data = fact_sheet_data.replace("บ./ตร.ม.","")
                                fact_sheet_data = fact_sheet_data.replace("ลบ.","")
                                fact_sheet_data = fact_sheet_data.replace("/เดือน","")
                                fact_sheet_data = fact_sheet_data.replace("N/A","")
                                fact_sheet_data = fact_sheet_data.strip()
                                data_info_dict[array_price[price-(1+x)]] = fact_sheet_data
                            x+=1           
            if f == 2:
                n = 0
                for building , fact_sheet_inn in enumerate(fact_sheet_in.find_all('div' ,{'class':"row m-0"})) :
                    if fact_sheet_inn:
                        fact_sheet_section = fact_sheet_inn.find('span' ,{'class':"condo-factsheet-key-block-text"}) 
                        fact_sheet_data = fact_sheet_inn.find('span' ,{'class':"condo-factsheet-value-block-text show-single-line"})
                        if building == 1:
                            fact_sheet_section = fact_sheet_section.text.strip()
                            data_info_dict['FinishYear_Section'] = fact_sheet_section
                        if building%2==0:    #2,4,6,8,10
                            if building>0:
                                fact_sheet_data = fact_sheet_data.text.strip()
                                fact_sheet_data = fact_sheet_data.replace("ไร่","")
                                fact_sheet_data = fact_sheet_data.replace("ยูนิต","")
                                fact_sheet_data = fact_sheet_data.replace("N/A","")
                                fact_sheet_data = fact_sheet_data.strip()
                                data_info_dict[array_building[building-(1+n)]] = fact_sheet_data
                            n+=1
            if f == 3:
                for room , fact_sheet_inn in enumerate(fact_sheet_in.find_all('span' ,{'class':"condo-factsheet-value-block-text show-single-line"})) :
                    if fact_sheet_inn:  
                        fact_sheet_data = fact_sheet_inn.text.strip()
                        fact_sheet_data = fact_sheet_data.replace("ตร.ม.","")
                        fact_sheet_data = fact_sheet_data.replace("N/A","")
                        fact_sheet_data = fact_sheet_data.strip()
                        data_info_dict[array_room[room]] = fact_sheet_data
    #check upload from gallery
    pic = soup.find('img', {'class': 'carousel-cell-image img-fluid flickity-lazyloaded'})
    if pic:
        data_info_dict['check_pic'] = 1
    else:
        data_info_dict['check_pic'] = ''
    browser.close()
    if ind == no:
        break
    ind += 1
    data_info_list.append(data_info_dict)
    data_info_df = pd.DataFrame(data_info_list)
    data_info_df.to_csv('realist_data_open.csv')
print("done")
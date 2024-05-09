import pandas as pd
from selenium import webdriver
from bs4 import BeautifulSoup as bs
import time
import re

link_file = r"C:\PYTHON\TAR.thelist.web2\dd\dd_link.csv"
csv_file = r'C:\PYTHON\TAR.thelist.web2\dd\dd_data.csv'

data_list = []

dd_link = pd.read_csv(link_file)
try:
    prv_link = pd.read_csv(csv_file)
    for ind in prv_link.index:
        data_info_dict = prv_link.iloc[ind].to_dict()
        data_list.append(data_info_dict)
    ind = len(data_list)
    no = len(dd_link.index)
except:
    ind = 0
    no = len(dd_link.index)
print(f"Start at Link {ind+1}")

while ind in dd_link.index:
    proj_name_eng,proj_name_th,province,price_min,price_max,price_min_unit,price_max_unit = '','','','','','',''
    url = dd_link.iloc[ind].iloc[1]
    code = url.split("/")[-1].split("-")[0]
    data_dict = {'LINK': url, 'DD_Code': code}
    browser = webdriver.Chrome()  
    browser.maximize_window()
    browser.get(url)
    time.sleep(5)
    
    soup = bs(browser.page_source, 'html.parser')
    
    proj_name = soup.find('h1', {'class': 'h2 text-transform-none'})
    proj_name = proj_name.text.strip()
    try:
        proj_name_format = re.split(r'[:\-]', proj_name)
        proj_name_eng = proj_name_format[0].strip()
        proj_name_th = proj_name_format[1].strip()
    except:
        pattern = r'\(.*?\)'
        proj_name_format = re.sub(pattern, '', proj_name).strip()
        proj_name_eng = re.sub(proj_name_format, '',proj_name)
        proj_name_eng = re.sub(r'[()]+', '', proj_name_eng).strip()
        proj_name_th = proj_name_format
    data_dict["Name_Eng"] = proj_name_eng
    data_dict["Name_TH"] = proj_name_th
    
    price_range = soup.find('div', {'itemprop': 'offers'})
    for i, price in enumerate(price_range.find_all('span', {'class': 'element-label price'})):
        if i == 0:
            price_min_unit = price.text.strip()
            price_min_unit = int(re.sub(",",'',price_min_unit))
        elif i == 1:
            price_max_unit = price.text.strip()
            price_max_unit = int(re.sub(",",'',price_max_unit))
    data_dict["Price_Per_Unit_Min"] = price_min_unit
    data_dict["Price_Per_Unit_Max"] = price_max_unit
    
    address = soup.find('span', {'itemprop': 'streetAddress'})
    address = address.text.strip()
    province = address.split(",")[-1].strip()
    data_dict["Province"] = province
    
    detail = soup.find('div', {'class': 'listing-details-primary'})
    for i, section in enumerate(detail.find_all('tbody')):
        if i == 4:
            for j, inside in enumerate(section.find_all('td')):
                if j == 1:
                    price = inside.text.strip()
                    if price != "N/A":
                        price = price.split("-")
                        price = [item.strip() for item in price]
                        price = list(set(price))
                        price = [re.sub("฿","",x) for x in price]
                        price = [re.sub(",","",x) for x in price]
                        price = [int(x) if x.isdigit() else float(x) for x in price]
                        price = sorted(price)
                        if len(price) == 1:
                            price_min = format(price[0], ',')
                        elif len(price) == 2:
                            price_min = format(price[0], ',')
                            price_max = format(price[1], ',')
                        data_dict["Price_Min"] = price_min
                        data_dict["Price_Max"] = price_max
            break
    
    graph_section = soup.find('div', {'class': 'tab-content tab-content-1'})
    graph_section_in = graph_section.find('div', {'class': 'price_widget_tab_body'})
    before_graph = graph_section_in.find('svg')
    graph = before_graph.find('g', {'class': 'highcharts-series-group'})
    for i, graph_check in enumerate(graph.find_all('g')):
        if i == 1:
            dot = graph_check.find("path")
            break
    if dot:
        data_dict["Graph"] = 1
    else:
        data_dict["Graph"] = 0
    data_list.append(data_dict)
    
    data_df = pd.DataFrame(data_list)
    data_df.to_csv(csv_file, encoding='utf-8')
    print(f"LINK -- {ind+1}")
    browser.close()
    ind += 1
    if ind == no:
        break
print("OK")
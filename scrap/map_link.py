from bs4 import BeautifulSoup
import re
import pandas as pd
#import requests

file_name = "D:\PYTHON\TAR.thelist.web-2\scrap\webpage_home_data.txt"
link_file = "D:\PYTHON\TAR.thelist.web-2\scrap\homenayoo_link_for_data.csv"
csv_file = 'D:\PYTHON\TAR.thelist.web-2\scrap\google_map.csv'

data_list = []

urls = pd.read_csv(link_file)
try:
    prv_link = pd.read_csv(csv_file)
    for ind in prv_link.index:
        data_info_dict = prv_link.iloc[ind].to_dict()
        data_list.append(data_info_dict)
    ind = len(data_list)
    no = len(urls.index)
except:
    ind = 0
    no = len(urls.index)

with open(file_name, "r", encoding="utf-8") as file:
    all_page_sources = file.read()

stop = False
sections = all_page_sources.split("### ")
link = ind
print(f'Start at Link {link+1}')
while ind in urls.index:
    if stop:
        break
    section = sections[1:][ind]
    url, page_source = section.split(" ###\n", 1)
    map_link,lat,long,lat_map,long_map = '','','','',''
    data_dict = {'Link' : url}
    soup = BeautifulSoup(page_source, 'html.parser')
    content = soup.find('div', {'class': 'thaitheme_read'}) 
    links = content.find_all('a')
    for each_link in links:
        map_link = each_link.get('href')
        if map_link:
            if "goo" in map_link and "maps" in map_link:
                coor = each_link.text.strip()
                pattern = r'\d+\.\d{4,}\b'
                matches = re.findall(pattern, coor)
                if matches:
                    lat = matches[0]
                    long = matches[1]
                #response = requests.get(map_link)
                #result_url = response.url
                #if response.status_code == 429:
                #    print("Too Many Requests Wait and Try again")
                #    stop = True
                #    break
                #format_url = re.findall(pattern, result_url)
                #if format_url[0][0:2] == "40":
                #    lat_map = re.sub("40","",format_url[0])
                #else:
                #    lat_map = format_url[0]
                #long_map = format_url[1]
                #print(f"{link+1} -- {url} -- {map_link} -- {lat},{long}")
                data_dict['Link_Map'] = map_link
                data_dict['Latitude'] = lat
                data_dict['Longitude'] = long
                data_dict['Latitude_Map'] = lat_map
                data_dict['Longitude_Map'] = long_map
                break
    if not stop:
        data_list.append(data_dict)
        data_df = pd.DataFrame(data_list)
        data_df.to_csv(csv_file, encoding='utf-8')
        print(f"LINK {link+1} -- {url}")
        ind += 1
        link += 1
        if ind == no:
            break
print("OK")
from bs4 import BeautifulSoup
import requests
import json

file_name = "D:\PYTHON\TAR.thelist.web-2\scrap\webpage_home_data.txt"
file_json = 'D:\PYTHON\TAR.thelist.web-2\scrap\ggmap.json'
file_json2 = 'D:\PYTHON\TAR.thelist.web-2\scrap\ggmap_location.json'

json_list_1 = []
json_list_2 = []

with open(file_name, "r", encoding="utf-8") as file:
    all_page_sources = file.read()

sections = all_page_sources.split("### ")

url_path = 'https://maps.googleapis.com/maps/api/geocode/json?address='
key = '&key=AIzaSyAwL10BBi0BkxT1NbjNsG_A90QUM0WpgK4'

i = 0
for section in sections[1:]:
    url, page_source = section.split(" ###\n", 1)
    soup = BeautifulSoup(page_source, 'html.parser')
    table = soup.find('table')
    if table:
        for j , data in enumerate(table.find_all('tr')):
            for k , data_in in enumerate(data.find_all('td')):
                if k == 0:
                    get_data_head = data_in.text.strip()
                    if "ที่ตั้ง" in get_data_head:
                            get_data_head = "ที่ตั้ง"
                elif k == 1:
                    get_data = data_in.text.strip()

                    if get_data_head == 'ชื่อโครงการ':
                        name = get_data
                        full_url = requests.get(url_path + name + key)
                        if full_url.status_code == 200:
                            json_data = full_url.json()
                            json_list_1.append(json_data['results'])
                        else:
                            print("Error: Unable to retrieve data from the API.")

                    if get_data_head == 'ที่ตั้ง':
                        location = get_data

        full_url = requests.get(url_path + name + ' ' + location + key)
        if full_url.status_code == 200:
            json_data = full_url.json()
            json_list_2.append(json_data['results'])
        else:
            print("Error: Unable to retrieve data from the API.")

    #if i == 300:
    #    break
    i += 1
    print(f'json -- {i}')
with open(file_json, 'w', encoding='utf-8') as file:
    json.dump(json_list_1, file, ensure_ascii=False, indent=4)
with open(file_json2, 'w', encoding='utf-8') as file2:
    json.dump(json_list_2, file2, ensure_ascii=False, indent=4)
print('Done')
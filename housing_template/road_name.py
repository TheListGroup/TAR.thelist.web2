import requests
from bs4 import BeautifulSoup as bs
import pandas as pd

url = "https://th.wikipedia.org/wiki/รายชื่อถนนในกรุงเทพมหานคร"
file_name = "D:\PYTHON\TAR.thelist.web-2\housing_template\get_road_name.csv"

web = requests.get(url)

data_list = []
if web.status_code == 200:
    soup = bs(web.text, 'html.parser')
    content = soup.find('div', {'class': 'mw-body-content'})
    tables = content.find_all('table', {'class': 'wikitable'})
    for i, table in enumerate(tables):
        table = table.find('tbody')
        for j, roads in enumerate(table.find_all('tr')):
            if j > 1:
                for k, names in enumerate(roads.find_all('td')):
                    if k == 1:
                        nameth = names.text.strip()
                        data_dict = {'NameTH' : nameth}
                    if k == 2:
                        nameen = names.text.strip()
                        data_dict['NameEN'] = nameen
                        break
                data_list.append(data_dict)
    data_df = pd.DataFrame(data_list)
    data_df.to_csv(file_name, encoding='utf-8')
    print('OK')
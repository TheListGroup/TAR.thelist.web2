import requests
import re
from bs4 import BeautifulSoup
import pandas as pd

file_name = "D:\PYTHON\TAR.thelist.web-2\scrap\webpage_home_data.txt"
link_file = "D:\PYTHON\TAR.thelist.web-2\scrap\homenayoo_link_for_data.csv"
csv_file = 'D:\PYTHON\TAR.thelist.web-2\scrap\coor_number.csv'

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

sections = all_page_sources.split("### ")
link = ind
print(f'Start at Link {link+1}')
while ind in urls.index:
    section = sections[1:][ind]
    url, page_source = section.split(" ###\n", 1)
    data_dict = {'Link' : url}
    soup = BeautifulSoup(page_source, 'html.parser')
    text_content = soup.get_text()

    pattern = r'\b\d+\.\d{4,}\b'
    numbers = re.findall(pattern, text_content)
    if len(numbers) == 2:
        data_dict["Real_Lat"] = numbers[0]
        data_dict["Real_Long"] = numbers[1]
        data_dict["NOTE"] = ''
    elif len(numbers) > 0:
        data_dict["Real_Lat"] = ''
        data_dict["Real_Long"] = ''
        data_dict["NOTE"] = numbers

    data_list.append(data_dict)
    data_df = pd.DataFrame(data_list)
    data_df.to_csv(csv_file, encoding='utf-8')
    #print(f"{link+1} -- {url} --- {numbers}")
    ind += 1
    link += 1
    if link % 500 == 0:
        print(f"Link -- {link}")
    if ind == no:
        break
print("ALL DONE")
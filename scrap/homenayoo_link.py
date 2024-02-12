import requests
import time
from bs4 import BeautifulSoup as bs
import re
import pandas as pd

home_list = []
def open_browser(path1,path2):
    url = (f"https://www.homenayoo.com/category/{path1}/รีวิว-{path2}/")
    response = requests.get(url)
    soup = bs(response.text, 'html.parser')
    #หาหน้ารวม
    page = soup.find('span', {'class': 'count_page'})
    page = page.text.strip()
    page = re.findall("\d+ หน้า", page)
    page = re.findall("\d+", str(page))
    page = int(page[0])

    def get_link():
        for i , post in enumerate(soup.find_all('article', {'class': 'tt_list tt_1x'})):
            post_list = post.find("a")
            post_list = post_list.get("href")
            title = post.find('div', {'class': 'title'})
            date = title.find('div', {'class': 'tt_date'})
            date = date.text.split(":")[1].split("|")[0].strip()
            if path1 == "townhome":
                post_dict = {"Link":post_list, "TownHome":"TRUE", "Single/Double Detached House":"", "Date": date}
            elif path1 == "home":
                post_dict = {"Link":post_list, "TownHome":"", "Single/Double Detached House":"TRUE", "Date": date}
            home_list.append(post_dict)

    x = 1
    while x <= page :
        if x == 1:
            get_link()
        else:
            url = (f"https://www.homenayoo.com/category/{path1}/รีวิว-{path2}/page/{x}/")
            response = requests.get(url)
            if x % 100 == 0:
                time.sleep(60)
            else:
                time.sleep(3)
            soup = bs(response.text, 'html.parser')
            get_link()
        print(f"{path1} -- {path2} -- PAGE {x}")
        x += 1
        if x > page: 
            break

open_browser("townhome","ทาวน์โฮม")
open_browser("home","บ้านเดี่ยว")
link_df = pd.DataFrame(home_list)
link_df.to_csv('D:\PYTHON\TAR.thelist.web-2\scrap\homenayoo_link_all.csv')

group_link = pd.read_csv("D:\PYTHON\TAR.thelist.web-2\scrap\homenayoo_link_all.csv")
group_link['COUNT'] = group_link.groupby('Link')['Link'].transform('count')
group_link = group_link.groupby('Link').first().reset_index()
group_link = group_link.drop(columns=['Unnamed: 0'])
group_link['COUNT'] = group_link['COUNT'].astype(int)
group_link['MIX'] = group_link['COUNT'] > 1
group_link = group_link.sort_values(by='Date', ascending=False)
group_link.to_csv('D:\PYTHON\TAR.thelist.web-2\scrap\homenayoo_link_for_data.csv')
print("Get Link Success")
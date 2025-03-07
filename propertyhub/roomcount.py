from selenium import webdriver
import time
from bs4 import BeautifulSoup as bs
import pandas as pd
import json

data_list = []
input_file = pd.read_csv(r"C:\PYTHON\TAR.thelist.web2\propertyhub\condo_link3.csv", encoding='utf-8')
file_name = r"C:\PYTHON\TAR.thelist.web2\propertyhub\year_not_match.csv"

browser = webdriver.Chrome()  
browser.maximize_window()

for i in range(input_file.index.size):
    code = input_file.iloc[i, 0]
    link = input_file.iloc[i, 4]
    browser.execute_script(f"window.open('{link}', '_blank');")
    browser.switch_to.window(browser.window_handles[-1])
    time.sleep(2)
    try:
        soup_in = bs(browser.page_source, 'html.parser')
        json_data = soup_in.find('script', {'id': '__NEXT_DATA__'})
        json_text = json_data.text.strip()
        data = json.loads(json_text)
        room_count = data["props"]["pageProps"]["listings"]["pagination"]["totalCount"]
        condo_date = data["props"]["pageProps"]["project"]["projectInfo"]["completedYear"]
        data_dict = {'Condo_ID': code, 'Condo_URL': link, 'Room_Count': room_count, 'Build_Finished': condo_date}
        data_list.append(data_dict)
    except:
        print(link)
    browser.close()
    time.sleep(2)
    browser.switch_to.window(browser.window_handles[0])
    print(f'Link {i+1} of {input_file.index.size}')

browser.close()

link_df = pd.DataFrame(data_list)
link_df.to_csv(file_name, encoding='utf-8')
print("DONE")
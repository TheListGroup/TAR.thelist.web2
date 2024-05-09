import requests
import pandas as pd

def save(all_page_sources):
    all_page_sources_2 = '\n'.join(page_list)
    if count > 0:
        all_page_sources += '\n' + all_page_sources_2
    else:
        all_page_sources += all_page_sources_2
    with open(file_path, "w", encoding="utf-8") as file:
        file.write(all_page_sources)

home_link = pd.read_csv(r"C:\PYTHON\TAR.thelist.web2\scrap\format_link.csv")
file_path = r"C:\PYTHON\TAR.thelist.web2\scrap\webpage_home_data.txt"
search_string = '### '

all_page_sources = ""
page_list = []

try:
    with open(file_path, 'r', encoding='utf-8') as file:
        file_contents = file.read()
        count = file_contents.count(search_string)
    print(f"Start at index {count}")

    all_page_sources += file_contents
except:
    print("First Time")
    count = 0

i = count
while i in range(len(home_link.index)):
    url = home_link.iloc[i].iloc[0]
    response = requests.get(url)
    if response.status_code == 200:
        try:
            page_source = response.text
            format_html = "### " + url + " ###\n" + page_source
            page_list.append(format_html)
            print(f'Link {i+1}')
            i += 1
            #if i == 6000:
            #    break
        except:
            save(all_page_sources)
            print(f"Error at Link {i+1}")
            break

save(all_page_sources)
print(f"All page sources saved to {file_path}")
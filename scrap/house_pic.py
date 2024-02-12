from bs4 import BeautifulSoup
import re
import pandas as pd

file_name = "D:\PYTHON\TAR.thelist.web-2\scrap\webpage.txt"

with open(file_name, "r", encoding="utf-8") as file:
    all_page_sources = file.read()

data_list = []
sections = all_page_sources.split("### ")

link = 0
for section in sections[1:]:
    count_image = 0
    select_house_type = True
    all_pic = 0
    url, page_source = section.split(" ###\n", 1)
    data_dict = {'Link': url}
    soup = BeautifulSoup(page_source, 'html.parser')
    page = soup.find('div', {'class': 'thaitheme_read'})
    all_content = page.find_all("p")
    for i, images in enumerate(all_content):
        for j, pic in enumerate(images.find_all('a')):
            if pic:
                image = pic.get('href')
                try:
                    image_check = re.search("wp-content/uploads",image)
                    if image_check:
                        count_image += 1
                        if count_image > 30:
                            select_house_type = False
                            all_pic = 1
                except:
                    pass
    
    data_dict['Count_Images'] = count_image
    data_dict['Use_all_pic'] = all_pic
    data_list.append(data_dict)
    if select_house_type:
        print(f'Link -- {link+1} have {count_image} Images')
    else:
        print(f'Link -- {link+1} have {count_image} Images AND select only house_type Images')
    link += 1
    if link == 200:
        break

data_df = pd.DataFrame(data_list)
data_df.to_csv('D:\PYTHON\TAR.thelist.web-2\scrap\house_pic_count.csv', encoding='utf-8')
print('DONE')
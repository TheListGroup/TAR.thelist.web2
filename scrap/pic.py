from bs4 import BeautifulSoup
import pandas as pd
import re
import requests
import os
from PIL import Image
from io import BytesIO

file_name = "D:\PYTHON\TAR.thelist.web-2\scrap\webpage_home_data.txt"
save_folder = "D:\PYTHON\TAR.thelist.web-2\scrap\house_image2"
csv_file = 'D:\PYTHON\TAR.thelist.web-2\scrap\get_pic.csv'
link_file = "D:\PYTHON\TAR.thelist.web-2\scrap\homenayoo_link_for_data.csv"

data_list = []

urls = pd.read_csv(link_file)
try:
    prv_link = pd.read_csv(csv_file)
    for ind in prv_link.index:
        data_info_dict = prv_link.iloc[ind].to_dict()
        data_list.append(data_info_dict)
    ind = len(data_list)
except:
    ind = 0
no = len(urls.index)

print("Reading Text File....")
with open(file_name, "r", encoding="utf-8") as file:
    all_page_sources = file.read()

def choose_pic(pic_name,stat):
    select_house_type = False
    count_image = 0
    all_pic = 1
    page = soup.find('div', {'class': 'thaitheme_read'})
    all_content = page.find_all("p")
    for i, images in enumerate(all_content):
        for j, pic in enumerate(images.find_all('img')):
            if pic:
                image = pic.get('src')
                if image:
                    image_check = re.search("wp-content/uploads",image)
                    if image_check:
                        if stat == 'count':
                            count_image += 1
                            if count_image > 30:
                                select_house_type = True
                                all_pic = 0
                        else:
                            pic_name += 1
                            save_image(pic_name,image)
                            big_pic_link.append(image)
    return select_house_type,count_image,all_pic

def save_image(pic_name,pic):
    folder_path = f'\{link+1:04d}'
    full_path = save_folder + folder_path
    if not os.path.exists(full_path):
        os.makedirs(full_path)
    
    try:
        response = requests.get(pic)
            
        if response.status_code == 200:
            image_data = response.content
            image = Image.open(BytesIO(image_data))
            file_name = f"{link+1:04d}-{pic_name:02d}.webp"
            save_path = os.path.join(full_path, file_name)
            image.save(save_path, "WebP")
            big_pic.append(file_name)
    except:
        pass

def scrap(ct,bt,pic_name,ft,st,tt):
    for i, nextSibling in enumerate(p):
        text = nextSibling.text.strip()
        if text:
            if ct:
                if i < 3:
                    if i == 0:
                        ft = ''.join(text.split())
                    elif i == 1:
                        st = ''.join(text.split())
                    elif i == 2:
                        tt = ''.join(text.split())
                else:
                    text_to_check = ''.join(text.split())
                    if text_to_check in ft or text_to_check in st or text_to_check in tt:
                        bt = []
                        ct = False
            stop = nextSibling.find('strong')
            if stop:
                stop = nextSibling.find('li')
                if not stop and i > 1 :
                    break
            house_type = nextSibling.find('li')
            if house_type:
                bt.append(text)
        else:
            if select_house_type:
                for j, pic in enumerate(nextSibling.find_all('a')):
                    if pic:
                        pic = pic.get('href')
                        pic_name += 1
                        save_image(pic_name,pic)
                        big_pic_link.append(pic)
    
    get_text = '\n### '.join(bt)
    get_pic_link = '\n### '.join(big_pic_link)
    get_pic = '\n### '.join(big_pic)
    return get_text,get_pic_link,get_pic


sections = all_page_sources.split("### ")
link = ind
print(f'Start at Link {link+1}')
while ind in urls.index:
    section = sections[1:][ind]
    url, page_source = section.split(" ###\n", 1)
    data_dict = {'Link' : url}
    soup = BeautifulSoup(page_source, 'html.parser')

    l = 0
    check_text = True
    big_text,big_pic,big_pic_link = [],[],[]
    first_text,second_text,third_text = '','',''
    p_tag = soup.find('p', text=['HOUSE TYPE', 'แบบบ้าน',':: HOUSE TYPE ::'])
    p_tag2 = soup.find('p', text=lambda text: text and ('HOUSE TYPE' in text or 'แบบบ้าน' in text))
    select_house_type,count_image,all_pic = choose_pic(l,"count")
    if p_tag:
        p = p_tag.find_next_siblings(["p", "ul", "div"])
        get_text,get_pic_link,get_pic = scrap(check_text,big_text,l,first_text,second_text,third_text)
    elif p_tag2:
        p = p_tag2.find_next_siblings(["p", "ul", "div"])
        get_text,get_pic_link,get_pic = scrap(check_text,big_text,l,first_text,second_text,third_text)
    else:
        get_text,get_pic_link,get_pic = '','',''
    if not select_house_type:
        choose_pic(l,"save")
    get_text = '\n### '.join(big_text)
    get_pic_link = '\n### '.join(big_pic_link)
    get_pic = '\n### '.join(big_pic)
    use_image = len(big_pic)
    house_type_list = ['Text','Count_Images','Use_Images','All_Pic','IMAGE_LINK','IMAGE']
    house_type_result_list = [get_text,count_image,use_image,all_pic,get_pic_link,get_pic]
    for i, head in enumerate(house_type_list):
        data_dict[head] = house_type_result_list[i]
    data_list.append(data_dict)
    
    data_df = pd.DataFrame(data_list)
    data_df.to_csv(csv_file, encoding='utf-8')
    print(f"LINK {link+1} -- {url}")
    link += 1
    ind += 1
    if ind == no:
        break
print('ok')
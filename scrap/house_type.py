from bs4 import BeautifulSoup
import pandas as pd
import os
import requests
from PIL import Image
from io import BytesIO
import re

file_name = "D:\PYTHON\TAR.thelist.web-2\scrap\webpage.txt"
save_folder = "D:\PYTHON\TAR.thelist.web-2\scrap\house_image"
data_list = []

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

def choose_pic(pic_name,stat):
    select_house_type = False
    count_image = 0
    all_pic = 1
    page = soup.find('div', {'class': 'thaitheme_read'})
    all_content = page.find_all("p")
    for i, images in enumerate(all_content):
        for j, pic in enumerate(images.find_all('a')):
            if pic:
                image = pic.get('href')
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

with open(file_name, "r", encoding="utf-8") as file:
    all_page_sources = file.read()

sections = all_page_sources.split("### ")

link = 0
for section in sections[1:]:
    l = 0
    check_text = True
    big_text,big_pic,big_pic_link = [],[],[]
    first_text,second_text,third_text = '','',''
    url, page_source = section.split(" ###\n", 1)
    data_dict = {'Link': url}
    
    soup = BeautifulSoup(page_source, 'html.parser')
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

    data_dict['TEXT'] = get_text
    data_dict['Count_Images'] = count_image
    data_dict['Use_Images'] = use_image
    data_dict['All_Pic'] = all_pic
    data_dict['IMAGE_LINK'] = get_pic_link
    data_dict['IMAGE'] = get_pic
    data_list.append(data_dict)

    print(f"LINK {link+1} -- {url}")
    link += 1
    if link == 200:
        break

data_df = pd.DataFrame(data_list)
data_df.to_csv('D:\PYTHON\TAR.thelist.web-2\scrap\house_type.csv', encoding='utf-8')
print("OK")
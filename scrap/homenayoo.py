from bs4 import BeautifulSoup
import pandas as pd
import re
import requests ####
import os
from PIL import Image
from io import BytesIO

file_name = r"C:\PYTHON\TAR.thelist.web2\scrap\webpage_home_data.txt"
save_folder = r"C:\PYTHON\TAR.thelist.web2\scrap\house_image"
csv_file = r'C:\PYTHON\TAR.thelist.web2\scrap\home.csv'
link_file = r"C:\PYTHON\TAR.thelist.web2\scrap\format_link.csv"

url_path = 'https://maps.googleapis.com/maps/api/geocode/json?address=' ####
key = '&key=AIzaSyAwL10BBi0BkxT1NbjNsG_A90QUM0WpgK4' ####

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

def map_work(): ####
    def va():
        locality,sublocality_level_1,administrative_area_level_2,sublocality_level_2 = '','','',''
        postal_code,latitude,longitude = '','',''
        return locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude

    def locate_type(name_eng):
        locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = va()
        def district():
            locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = va()
            latitude = components['geometry']['location']['lat']
            longitude = components['geometry']['location']['lng']
            for gov in components['address_components']:
                if 'locality' in gov['types']:
                    locality = gov['long_name']
                elif 'sublocality_level_1' in gov['types']:
                    sublocality_level_1 = gov['long_name']
                elif 'administrative_area_level_2' in gov['types']:
                    administrative_area_level_2 = gov['long_name']
                elif 'sublocality_level_2' in gov['types']:
                    sublocality_level_2 = gov['long_name']
                elif 'postal_code' in gov['types']:
                    postal_code = gov['long_name']
            return locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude

        def point_cal():
            choose = False
            if point >= max(point_list):
                choose = True
            return choose

        count_object = len(json_data)
        point_list = [0]
        for j, components in enumerate(json_data):
            point = 0
            geometry = components["geometry"]
            location_type = geometry.get("location_type")
            try:
                code = components['plus_code']['global_code']
                point += 5
            except:
                code = ''
            long_name = components["address_components"][0]["long_name"]
            long_name = re.sub(" ","",long_name)
            long_name = long_name.lower()
            name_eng = re.sub(" ","",name_eng)
            name_eng = name_eng.lower()
            if long_name == name_eng:
                point += 10

            if "bounds" in geometry:
                location_type = "FOUND BOUNDS"
                use = ''

            if location_type == "ROOFTOP":
                point += 40
                choose = point_cal()
                if choose:
                    locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = district()
                    point_list.append(point)
                    use = j + 1
                    break
            elif location_type == "RANGE_INTERPOLATED":
                point += 35
                choose = point_cal()
                if choose:
                    locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = district()
                    point_list.append(point)
                    use = j + 1
            elif location_type == "GEOMETRIC_CENTER":
                point += 30
                choose = point_cal()
                if choose:
                    locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = district()
                    point_list.append(point)
                    use = j + 1
            elif location_type == "APPROXIMATE":
                point += 25
                choose = point_cal()
                if choose:
                    locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = district()
                    point_list.append(point)
                    use = j + 1
        return use, count_object, location_type, locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude, code


    full_url = requests.get(url_path + proj_name + key)
    if full_url.status_code == 200:
        json_data = full_url.json()
        json_data = json_data['results']
    
    if json_data:
        use, count_object, location_type, locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude, code = locate_type(name_eng)
    else:
        full_url = requests.get(url_path + proj_name + ' ' + location + key)
        if full_url.status_code == 200:
            json_data = full_url.json()
            json_data = json_data['results']
            
        if json_data:
            use, count_object, location_type, locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude, code = locate_type(name_eng)
        else:
            use = ''
            count_object = 0
            location_type = 'NOT FOUND'
            code = ''
            locality, sublocality_level_1, administrative_area_level_2, sublocality_level_2, postal_code, latitude, longitude = va()
    coordinate_list = ['Set_Count','Use_Set','Type','Locality','Sublocality_level_1','administrative_area_level_2'
                    ,'Sublocality_level_2','Postal_Code','Latitude','Longitude','Global_Code']
    result_list = [count_object,use,location_type,locality,sublocality_level_1,administrative_area_level_2
                ,sublocality_level_2,postal_code,latitude,longitude,code]
    for i, head in enumerate(coordinate_list):
        data_dict[head] = result_list[i]

def Land(count_number):
    rai,ngan,wa = '','',''
    if count_number == 3:
        rai = numbers_list[0]
        ngan = numbers_list[1]
        wa = numbers_list[2]
    elif count_number < 3:
        text = re.findall(r'\d*\.?\d+\s*\S+', get_data)
        for word in enumerate(text):
            land_text = re.findall(r'\S+', word[1])
            if 'ไร่' in land_text:
                rai = land_text[0]
            elif 'งาน' in land_text:
                ngan = land_text[0]
            elif 'วา' or 'ว.' in land_text:
                wa = land_text[0]
    data_dict[get_data_head] = get_data
    data_dict['LandRai'] = rai
    data_dict['LandNgan'] = ngan
    data_dict['LandWa'] = wa

def manage_list(variable):
    text = variable
    if get_data_head != 'จำนวนห้อง':
        text = re.sub(',', '', get_data)
    count_list = re.findall(r'\d+\.\d+|\d+', text)
    count_list = list(set(count_list))
    count_list = [int(x) if x.isdigit() else float(x) for x in count_list]
    count_list = sorted(count_list)
    return count_list

def minmax(head1,head2,head3):
    if get_data_head != 'จำนวนห้อง':
        count_list = manage_list(get_data)
    else:
        count_list = manage_list(item)
    total_min,total_max,total_check = '','',0
    if len(count_list) == 2:
        total_min = str(count_list[0])
        total_max = str(count_list[1])
    elif len(count_list) == 1:
        total_min = str(count_list[0])
    elif len(count_list) > 2:
        total_min = str(min(count_list))
        total_max = str(max(count_list))
        total_check = 1
    if get_data_head != 'จำนวนห้อง':
        data_dict[get_data_head] = get_data
    data_dict[head1] = total_min
    data_dict[head2] = total_max
    data_dict[head3] = total_check

def extract_numbers(text):
    results = []
    th_month = ['ม.ค.','ก.พ.','มี.ค.','เม.ย.','พ.ค.','มิ.ย.','ก.ค.','ส.ค.','ก.ย.','ต.ค.','พ.ย.','ธ.ค.']
    digit_month = ['1','2','3','4','5','6','7','8','9','10','11','12']

    price_min,price_max,price_check,price_date,for_date = '','',0,'',True

    pattern = r'\(([^)]+)\)'
    date = re.findall(pattern, text)
    if date:
        number_pattern = r'\d+'
        for j, cal in enumerate(date):
            year = re.findall(number_pattern, cal)
            try:
                month = re.sub(year[0],'',cal).strip()
                for_date = True
                break
            except:
                for_date = False
                pass
        if for_date:
            for i, mm in enumerate(th_month):
                if month == mm:
                    month = digit_month[i]
                    break
            year = str(int(year[0]) + 1957)
            price_date = year + '-' + month + '-1'

    if "," in text:
        text = re.sub(',', '', text)
        price_check = 1

    pattern = r'(\d+\.\d+|\d+)\s*-\s*(\d+\.\d+|\d+)\s*(?:ล้าน|ลบ\.|บาท)'
    matches = re.finditer(pattern, text)
    for match in matches:
        num1 = float(match.group(1)) if '.' in match.group(1) else int(match.group(1))
        num2 = float(match.group(2)) if '.' in match.group(2) else int(match.group(2))
        results.append(num1)
        results.append(num2)

    pattern = r'(\d+\.\d+|\d+)\s*(?:ล้าน|ลบ\.|บาท)'
    matches = re.finditer(pattern, text)
    for match in matches:
        number = float(match.group(1)) if '.' in match.group(1) else int(match.group(1))
        results.append(number)

    results = sorted(list(set(results)))

    if len(results) == 1:
        if results[0] < 100000:
            price_min = str(results[0]*1000000)
        else:
            price_min = str(results[0])
    elif len(results) >= 2:
        if min(results) < 100000 and max(results) < 100000:
            price_min = str(min(results)*1000000)
            price_max = str(max(results)*1000000)
        else:
            price_min = str(min(results))
            price_max = str(max(results))
    data_dict[get_data_head] = get_data
    data_dict["Date_Price"] = price_date
    data_dict["House_Price_Min"] = price_min
    data_dict["House_Price_Max"] = price_max
    data_dict["House_Price_Check"] = price_check

def format_name(head1,head2):
    pattern = r'\(.*?\)'
    f_name = re.sub(pattern, '', get_data)
    f_name = re.sub(r'\)', '', f_name).strip()
    if '/' in f_name:
        name = f_name.split('/')[0].strip()
        name_eng = f_name.split('/')[1].strip()
    else:
        pattern = re.compile(r'(.*?)([A-Za-z])', re.UNICODE)
        match = pattern.search(f_name)
        if match:
            name = match.group(1).strip()
            name_eng = re.sub(name,'',f_name).strip()
        elif f_name != '':
            name = f_name
            name_eng = ''
        else:
            name = ''
            name_eng = ''
    if j == 1:
        data_dict[get_data_head] = get_data
    data_dict[head1] = name
    data_dict[head2] = name_eng
    return name_eng

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

def save_image(pic_name,pic):
    folder_path = f'\\{link+1:04d}'
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

def merge_similar_texts(text_list):
    merged_texts = {}
    for text in text_list:
        prefix = re.findall(r'ห้อง[^\s]+', text)
        
        if prefix[0] in merged_texts:
            merged_texts[prefix[0]].append(text)
        else:
            merged_texts[prefix[0]] = [text]

    result = [' '.join(texts) for texts in merged_texts.values()]
    return result

sections = all_page_sources.split("### ")
link = ind
print(f'Start at Link {link+1}')
while ind in urls.index:
    section = sections[1:][ind]
    url, page_source = section.split(" ###\n", 1)
    data_dict = {'Link' : url}
    soup = BeautifulSoup(page_source, 'html.parser')
    table = soup.find('table')
    if table:
        for j , data in enumerate(table.find_all('tr')):
            home_type = []
            for k , data_in in enumerate(data.find_all('td')):
                if k == 0:
                    get_data_head = data_in.text.strip()
                    if get_data_head == "รงการ":
                        get_data_head = "ชื่อโครงการ"
                    if get_data_head == "ขนส่งสาธารณะ" or "คมนาคม" in get_data_head:
                        get_data_head = "เส้นทางคมนาคม"
                    elif "กองทุน" in get_data_head:
                        get_data_head = "ค่าส่วนกลาง"
                    elif "ที่ตั้ง" in get_data_head or "ทีตั้ง" in get_data_head:
                        get_data_head = "ที่ตั้ง"
                    elif get_data_head == "ขนาดแปลงที่ดิน":
                        get_data_head = "พื้นที่โครงการ"
                    elif "สถานที่สำคัญ" in get_data_head:
                        get_data_head = "สถานที่สำคัญใกล้เคียง"
                    elif "จำนวนบ้าน" in get_data_head:
                        get_data_head = "จำนวนบ้าน"
                    elif get_data_head == "จุดเด่นของโครงการ" or get_data_head == "รถโดยสารที่ผ่าน" or get_data_head == "เนื้อที่บ้านจำนวนห้อง":
                        break
                elif k == 1:
                    get_data = data_in.text.strip()
                    if "รอข้อมูล" in get_data or get_data == "n/a" or get_data == "N/A":
                        get_data = ''

                    if get_data_head == 'ชื่อโครงการ':
                        data_dict[get_data_head] = get_data
                        name_eng = format_name('House_Name','House_ENName')
                        proj_name = get_data ###

                    elif get_data_head == 'ที่ตั้ง': ####
                        location = get_data ####

                    elif get_data_head == 'เจ้าของโครงการ':
                        format_name('Developer_Name','Developer_ENName')

                    elif get_data_head == 'ลักษณะโครงการ':
                        type_list = data_in.find('li')
                        if type_list:
                            for x, home_type_list in enumerate(data_in.find_all('li')):
                                if home_type_list:
                                    get_data = home_type_list.text.strip()
                                    home_type.append(get_data)
                            get_data = ','.join(home_type)

                    elif get_data_head == 'พื้นที่โครงการ':
                        numbers_list = re.findall(r'\d+\.\d+|\d+', get_data)
                        numbers_list = numbers_list[:3]
                        Land(len(numbers_list))

                    elif get_data_head == 'จำนวนบ้าน':
                        minmax('House_TotalUnit_Min','House_TotalUnit_Max','House_TotalUnit_Check')

                    elif get_data_head == 'เนื้อที่บ้าน':
                        minmax('House_Area_Min','House_Area_Max','House_Area_Check')

                    elif get_data_head == 'พื้นที่ใช้สอย':
                        minmax('House_Usable_Area_Min','House_Usable_Area_Max','House_Usable_Area_Check')

                    elif get_data_head == 'ที่จอดรถทั้งหมด':
                        minmax('House_Parking_Min','House_Parking_Max','House_Parking_Check')

                    elif get_data_head == 'ราคา':
                        extract_numbers(get_data)

                    elif get_data_head == 'ค่าส่วนกลาง':
                        text = re.sub(',', '', get_data)
                        common_fee = re.findall(r'\d+', text)
                        common_fee_check = 0
                        if len(common_fee) == 1:
                            common_fee = common_fee[0]
                            if int(common_fee) < 10:
                                common_fee = ''
                        elif len(common_fee) >= 2:
                            common_fee = common_fee[0]
                            if int(common_fee) < 10:
                                common_fee = ''
                            common_fee_check = 1
                        else:
                            common_fee = ''
                            common_fee_check = 0
                        data_dict[get_data_head] = get_data
                        data_dict['House_Common_Fee'] = common_fee
                        data_dict['House_Common_Fee_Check'] = common_fee_check

                    elif get_data_head == 'จำนวนห้อง':
                        data_dict[get_data_head] = get_data
                        room_list = ['Bedroom_Min','Bedroom_Max','Bathroom_Min','Bathroom_Max','Maidroom_Min','Maidroom_Max'
                                    ,'Kitchen_Min','Kitchen_Max','Multi_purpose_room_Min','Multi_purpose_room_Max','']
                        for i, room in enumerate(room_list):
                            data_dict[room] = ''
                        all_room = re.findall(r'(\d+-?\d*\s+ห้อง[^\s]+)', get_data)
                        all_room = merge_similar_texts(all_room)
                        for i, item in enumerate(all_room):
                            if "ห้องนอน" in item:
                                minmax('Bedroom_Min','Bedroom_Max','')
                            elif "ห้องน้ำ" in item:
                                minmax('Bathroom_Min','Bathroom_Max','')
                            elif "ห้องแม่บ้าน" in item:
                                minmax('Maidroom_Min','Maidroom_Max','')
                            elif "ห้องครัว" in item:
                                minmax('Kitchen_Min','Kitchen_Max','')
                            elif "ห้องอเนกประสงค์" in item:
                                minmax('Multi_purpose_room_Min','Multi_purpose_room_Max','')

                    data_dict[get_data_head] = get_data
        try:
            del data_dict['']
        except:
            pass
    post_date = soup.find('div', {'class': 'tt_author'})
    if post_date:
        date = post_date.text.strip()
        date = date.split("|")[1].strip()
        date = re.sub(r"วันที่ : ", '', date)
        data_dict["House_HNY_date"] = date

    category = soup.find('div', {'class': 'tt_post_in'})
    cate_list = ['HNY_Cat_Town_Home','HNY_Cat_Single_House','HNY_Cat_Home_Office']
    for i, cates in enumerate(cate_list):
        data_dict[cates] = 0
    if category:
        for i, cate in enumerate(category.find_all('a')):
            cate_text = cate.text.strip()
            if "ทาวน์โฮม" in cate_text:
                data_dict["HNY_Cat_Town_Home"] = 1
            if "บ้านเดี่ยว" in cate_text:
                data_dict["HNY_Cat_Single_House"] = 1
            if "โฮมออฟฟิศ" in cate_text:
                data_dict["HNY_Cat_Home_Office"] = 1

    all_tag = soup.find('div', {'class': 'tags-page'})
    tag_lists = ['HNY_Tag_Single_House','HNY_Tag_Twin_House','HNY_Tag_Town_Home','HNY_Tag_Home_Office','HNY_Tag_Commercial']
    for i, tags in enumerate(tag_lists):
        data_dict[tags] = 0
    if all_tag:
        for l, tag_list in enumerate(all_tag.find_all('a')):
            tag_text = tag_list.text.strip()
            if "บ้านเดี่ยว" in tag_text:
                data_dict["HNY_Tag_Single_House"] = 1
            if "บ้านแฝด" in tag_text:
                data_dict["HNY_Tag_Twin_House"] = 1
            if "ทาวน์โฮม" in tag_text:
                data_dict["HNY_Tag_Town_Home"] = 1
            if "โฮมออฟฟิศ" in tag_text:
                data_dict["HNY_Tag_Home_Office"] = 1
            if "อาคารพาณิชย์" in tag_text:
                data_dict["HNY_Tag_Commercial"] = 1

    if table:
        map_work()

    l = 0
    check_text = True
    big_text,big_pic,big_pic_link = [],[],[]
    first_text,second_text,third_text = '','',''
    p_tag = soup.find('p', string=['HOUSE TYPE', 'แบบบ้าน',':: HOUSE TYPE ::'])
    p_tag2 = soup.find('p', string=lambda text: text and ('HOUSE TYPE' in text or 'แบบบ้าน' in text))
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
print("OK")
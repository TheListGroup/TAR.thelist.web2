import mysql.connector
import pandas as pd
import re
import os
import requests
import io
from datetime import datetime
from PIL import Image as a
from io import BytesIO
from wand.image import Image as b

SHEET_URL = 'https://docs.google.com/spreadsheets/d/1DL3EIH9h2begYCOSpAfiuCZHrNUQvRjSjjxuKQ8rS7A/export?format=csv'
save_folder = r"C:\PYTHON\TAR.thelist.web2\classifield\Serve\classified_image"

host = '157.230.242.204'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

user_id = 4

def check_null(variable):
    if pd.isna(variable) or variable == 'N/A' or variable == '':
        variable = None
    else:
        variable = str(variable).strip()
    return variable

def sale_rent(va):
    if check_null(va) != None:
        va = 1
    else:
        va = 0
    return va

def price(va1,va2):
    if va1 == 1:
        va1 = re.sub(",","",va2).strip()
    else:
        va1 = None
    return va1

def check_image_url_validity(url):
    try:
        response = requests.head(url)
        content_length = response.headers.get('content-length')
        
        if content_length:
            if int(content_length) < 1024 * 1024: 
                try:
                    image_response = requests.get(url)
                    img = a.open(BytesIO(image_response.content))
                    img.verify()
                    return True
                except (IOError, SyntaxError):
                    pass
        return False
    except requests.RequestException:
        return False

def create_folder_and_remove_image_and_save_image():
    response = requests.get(folder_url)
    if response.status_code == 200:
        html_content = response.text

        file_links = []
        start_index = 0
        while True:
            start_index = html_content.find("https://drive.google.com/", start_index)
            if start_index == -1:
                break
            end_index = html_content.find('"', start_index)
            file_link = html_content[start_index:end_index]
            file_links.append(file_link)
            start_index = end_index
            file_links = list(set(file_links))

        pic_list = []
        for file_link in file_links:
            if "ddrive_web" in file_link:
                pic_list.append(file_link)
    
    folder_path = f'//{classified_id:06d}'
    full_path = save_folder + folder_path
    if not os.path.exists(full_path):
        os.makedirs(full_path)
        
    for existing_file in os.listdir(full_path):
        file_path = os.path.join(full_path, existing_file)
        if os.path.isfile(file_path):
            os.remove(file_path)
    
    if update_stat:
        query = """DELETE FROM classified_image
                    WHERE Classified_ID = %s"""
        val = (classified_id,)
        cursor.execute(query,val)
        connection.commit()
    
    l = 0
    for image_url in pic_list:
        file_id_match = re.search(r'/d/([a-zA-Z0-9_-]+)/', image_url)
        if file_id_match:
            file_id = file_id_match.group(1)
            direct_download_url = f"https://drive.google.com/uc?id={file_id}"
            
            if check_image_url_validity(direct_download_url):
                response = requests.get(direct_download_url)
                with b(file=BytesIO(response.content)) as img:
                    img.transform(resize=f"1900x1900>")
                    filename = f"{classified_id:06d}-{l+1:02d}.webp"
                    img.format = 'webp'
                    save_path = os.path.join(full_path, filename)
                    img.save(filename=save_path)
            
                query = """INSERT INTO classified_image (Classified_Image_URL,Displayed_Order_in_Classified,Classified_ID,Classified_Image_Status
                            , Created_By, Created_Date, Last_Updated_By, Last_Updated_Date)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""
                val = (filename, l+1, classified_id, '1', 32, create_date, 32, last_updated_date)
                cursor.execute(query,val)
                connection.commit()
                l += 1

def insert_log(location):
    if log:
        query = """INSERT INTO realist_log (Type, SQL_State, Message, Location)
                VALUES (%s, %s, %s, %s)"""
        val = (0, '00000', f'Update {upd} Rows and Insert {insert} Rows', f'{location}')
        cursor.execute(query,val)
        connection.commit()
    else:
        query = """INSERT INTO realist_log (Type, Message, Location)
                VALUES (%s, %s, %s)"""
        val = (1, str(e), f'{location}')
        cursor.execute(query,val)
        connection.commit()

match_list = []
data_list = []
sql = False
upd = 0
insert = 0
stop_processing = False
log = False
try:
    connection = mysql.connector.connect(
        host = host,
        user = user,
        password = password,
        database = 'realist2'
    )

    if connection.is_connected():
        print('Connected to MySQL server')
        cursor = connection.cursor()

        bridge_classified = """select Classified_ID, Ref_ID, Created_Date from classified where User_ID = 4"""
        cursor.execute(bridge_classified)
        bridge_check = cursor.fetchall()
        sql = True

except Exception as e:
    print(f'Error: {e}')

if sql:
    response = requests.get(SHEET_URL)
    if response.status_code == 200:
        data = response.content.decode('utf-8')
        df = pd.read_csv(io.StringIO(data))
        
        for row in df.values:
            data_list.append(row)

        for data in data_list:
            if stop_processing:
                break
            found = False
            prop_id = data[2]
            title_th = check_null(data[3])
            title_en = check_null(data[4])
            condo_code = data[0][:6]
            des_th = check_null(data[5])
            des_en = check_null(data[6])
            size = check_null(data[9])
            sale = sale_rent(data[13])
            rent = sale_rent(data[12])
            price_sale = price(sale,data[13])
            price_rent = price(rent,data[12])
            bedroom = check_null(data[10])
            bathroom = check_null(data[11])
            classified_status = data[15][0]
            last_updated_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            create_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            folder_url = data[14]
            
            if data[10] == 'Studio':
                room_type = 'Studio'
                bedroom = 1
            else:
                room_type = None
            
            for bridge_id in bridge_check:
                if prop_id == bridge_id[1]:
                    classified_id = bridge_id[0]
                    create_date = bridge_id[2]
                    found = True
                    query = """UPDATE classified 
                                SET Title_TH = %s, Title_ENG = %s, Condo_Code = %s, Sale = %s, Rent = %s, Price_Sale = %s, Price_Rent = %s
                                , Room_Type = %s, Bedroom = %s, Bathroom = %s, Size = %s, Descriptions_Eng = %s, Descriptions_TH = %s, Classified_Status = %s
                                , Last_Updated_Date = %s where Ref_ID = %s"""
                    val = (title_th, title_en, condo_code, sale, rent, price_sale, price_rent, room_type, bedroom, bathroom, size, des_en, des_th, classified_status, last_updated_date, prop_id)
                    try:
                        cursor.execute(query,val)
                        connection.commit()
                        upd += 1
                        update_stat = True
                        create_folder_and_remove_image_and_save_image()
                        if upd % 50 == 0:
                            print(f'Update {upd} Rows')
                        log = True
                        break
                    except Exception as e:
                        stop_processing = True
                        print(f'Error: {e} at SERVE_insert_prop_Update')
                        log = True
                        insert_log("SERVE_insert_prop_Update")
                        break
            
            if not found:
                query = "INSERT INTO classified (Ref_ID, Title_TH, Title_ENG, Condo_Code, Sale, Rent\
                        , Price_Sale, Price_Rent, Bedroom, Bathroom, Size\
                        , Descriptions_ENG, Descriptions_TH, User_ID, Classified_Status, Created_By, Created_Date\
                        , Last_Updated_By, Last_Updated_Date)\
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
                val = (prop_id, title_th, title_en, condo_code, sale, rent, price_sale, price_rent
                        , bedroom, bathroom, size, des_en, des_th, user_id
                        , classified_status, 32, create_date, 32, last_updated_date)
                try:
                    cursor.execute(query,val)
                    connection.commit()
                    insert += 1
                    update_stat = False
                    query = "SELECT Classified_ID, Ref_ID FROM classified WHERE Ref_ID = %s"
                    val = (prop_id,)
                    cursor.execute(query,val)
                    classified_id = cursor.fetchone()
                    classified_id = classified_id[0]
                    create_folder_and_remove_image_and_save_image()
                    if insert % 50 == 0:
                        print(f'Insert {insert} Rows')
                    log = True
                except Exception as e:
                    stop_processing = True
                    print(f'Error: {prop_id} {e}')
                    log = False
                    insert_log("SERVE_insert_prop_Insert")
                    break
        
        if log:
            insert_log("SERVE_insert_prop")

cursor.close()
connection.close()
print('Connection closed')
import mysql.connector
import json
import re
from datetime import datetime
import os
import requests
from PIL import Image
from io import BytesIO

save_folder = r"C:\PYTHON\TAR.thelist.web2\classifield\classified_image"
#save_folder = r"/var/www/html/realist/condo/uploads/classified"
json_path = r'C:\PYTHON\TAR.thelist.web2\classifield\Plus\Plus_PROPERTY.json'
#json_path = r'/home/gitdev/ta_python/classifield/Plus/Plus_PROPERTY.json'
#json_path = r'/home/gitprod/ta_python/classifield/Plus/Plus_PROPERTY.json'

host = '157.230.242.204'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

#host = '127.0.0.1'
#user = 'real-research'
#password = 'shA0Y69X06jkiAgaX&ng'

user_id = 3

def create_folder_and_remove_image_and_save_image():
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
            
    for l, image_url in enumerate(image_urls):
        response = requests.get(image_url)
        
        if response.status_code == 200:
            image_data = response.content
            image = Image.open(BytesIO(image_data))
            file_name = f"{classified_id:06d}-{l+1:02d}.webp"
            save_path = os.path.join(full_path, file_name)
            image.save(save_path, "WebP")
            
            query = """INSERT INTO classified_image (Classified_Image_URL,Displayed_Order_in_Classified,Classified_ID,Classified_Image_Status
                        , Created_By, Created_Date, Last_Updated_By, Last_Updated_Date)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""
            val = (file_name, l+1, classified_id, '1', 32, created_Date, 32, last_Updated_Date)
            cursor.execute(query,val)
            connection.commit()

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

sql = False
insert = 0
upd = 0
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
        sql = True
        
        match = "SELECT Project_ID, Condo_Code FROM classified_match WHERE Agent = 'Plus'"
        cursor.execute(match)
        result_match = cursor.fetchall()
        
        check_update = "SELECT Classified_ID, Ref_ID, Project_ID, Last_Updated_Date FROM classified where Classified_Status = '1' and User_ID = 3"
        cursor.execute(check_update)
        update = cursor.fetchall()

except Exception as e:
    print(f'Error: {e}')

property_list = []
if sql:
    with open(json_path, 'r', encoding='utf-8') as json_file_property:
        property_data = json.load(json_file_property)
    for property_bc in property_data:
        property_list.append(property_bc)
    
i = 0
while i in range(len(property_list)):
    match = False
    project_id = property_list[i]['Project_ID']
    for j in result_match:
        match_id = j[0]
        if project_id == match_id:
            match = True
            i += 1
            break
    if not match:
        property_list.pop(i)

stop_processing = False
log = False
for i, prop in enumerate(property_list):
    if stop_processing:
        break
    prop_proj_id = prop['Project_ID']
    
    for j, proj_match in enumerate(result_match):
        if stop_processing:
            break
        project_id = proj_match[0]
        condo_code = proj_match[1]
        if prop_proj_id == project_id:
            break
    
    if prop_proj_id == project_id:
        if prop["Last_Updated_Date"] != None:
            last_Updated_Date = prop["Last_Updated_Date"]
            date_last_Updated_Date = last_Updated_Date[0:10]
            last_Updated_Date = re.sub('T',' ',last_Updated_Date)
            if '.' in last_Updated_Date:
                last_Updated_Date = datetime.strptime(last_Updated_Date, '%Y-%m-%d %H:%M:%S.%f')
            else:
                last_Updated_Date = datetime.strptime(last_Updated_Date, '%Y-%m-%d %H:%M:%S')
            last_Updated_Date = last_Updated_Date.strftime('%Y-%m-%d %H:%M:%S')
        else:
            last_Updated_Date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        idid = str(prop["Ref_ID"])
        
        if prop["Title_TH"] == None or prop["Title_TH"] == "":
            title_TH = None
        else:    
            title_TH = prop["Title_TH"]
        
        if prop["Title_ENG"] == None or prop["Title_ENG"] == "":
            title_ENG = None
        else:
            title_ENG = prop["Title_ENG"]
        
        if prop["Description_TH"] == None or prop["Description_TH"] == "":
            description_TH = None
        else:
            description_TH = prop["Description_TH"]
        
        if prop["Description_ENG"] == None or prop["Description_ENG"] == "":
            description_ENG = None
        else:
            description_ENG = prop["Description_ENG"]
        
        sale = prop["Sale"]
        rent = prop["Rent"]
        
        if prop["Price_Sale"] == None or prop["Price_Sale"] == 0.0:
            price_Sale = None
        else:
            price_Sale = prop["Price_Sale"]
        
        if prop["Price_Rent"] == None or prop["Price_Rent"] == 0.0:
            price_Rent = None
        else:
            price_Rent = prop["Price_Rent"]
        
        if prop["Bedroom"] == 0:
            bedroom = 1
        else:
            bedroom = prop["Bedroom"]
        
        if prop["Bathroom"] == 0:
            bathroom = 1
        else:
            bathroom = prop["Bathroom"]
        
        if prop["Size"] == None or prop["Size"] == 0.00:
            size = None
        else:
            size = prop["Size"]
        
        if prop["Furnish"] == None:
            furnish = None
        elif prop["Furnish"] == "semi":
            furnish = "Fully Fitted"
        elif prop["Furnish"] == "fully":
            furnish = "Fully Furnished"
        
        image_urls = prop["Images"]
        if prop["Created_Date"] != None:
            created_Date = prop["Created_Date"]
            created_Date = re.sub('T',' ',created_Date)
        else:
            created_Date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        penthouse = prop["is_penthouse"]
        
        if prop["is_studio"] == True:
            studio = 'Studio'
        else:
            studio = None
        
        if prop["is_duplex"] == True:
            duplex = 'Duplex'
        else:
            duplex = None
        
        found = False
        for k in update:
            update_date = k[3]
            update_date = update_date.strftime('%Y-%m-%d')
            update_proj_id = k[2]
            update_id = k[1]
            classified_id = k[0]
            
            if update_proj_id == prop_proj_id and update_id == idid:
                found = True
                if update_date != date_last_Updated_Date:
                    query = """UPDATE classified 
                                SET Ref_ID = %s, Project_ID = %s, Title_TH = %s, Title_ENG = %s, Condo_Code = %s, Sale = %s
                                    , Rent = %s, Price_Sale = %s, Price_Rent = %s, Room_Type = %s, Unit_Floor_Type = %s, PentHouse = %s, Bedroom = %s, Bathroom = %s, Size = %s
                                    , Furnish = %s, Descriptions_Eng = %s, Descriptions_TH = %s, Last_Updated_Date = %s
                                WHERE Ref_ID = %s and Project_ID = %s"""
                    val = (idid, project_id, title_TH, title_ENG, condo_code, sale, rent, price_Sale, price_Rent, studio, duplex, penthouse
                        , bedroom, bathroom, size, furnish, description_ENG, description_TH, last_Updated_Date, idid, project_id)
                    try:
                        cursor.execute(query,val)
                        connection.commit()
                        upd += 1
                        update_stat = True
                        create_folder_and_remove_image_and_save_image()
                        if upd % 100 == 0:
                            print(f'Update {upd} Rows')
                        log = True
                        break
                    except Exception as e:
                        stop_processing = True
                        print(f'Error: {idid} {e}')
                        log = False
                        insert_log("BC_insert_prop_Update")
                        break
                else:
                    break
        
        if not found:
            query = "INSERT INTO classified (Ref_ID, Project_ID, Title_TH, Title_ENG, Condo_Code, Sale, Rent\
                    , Price_Sale, Price_Rent, Room_Type, Unit_Floor_Type, PentHouse, Bedroom, Bathroom, Size, Furnish\
                    , Descriptions_ENG, Descriptions_TH, User_ID, Classified_Status, Created_By, Created_Date\
                    , Last_Updated_By, Last_Updated_Date)\
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            val = (idid, project_id, title_TH, title_ENG, condo_code, sale, rent, price_Sale, price_Rent, studio, duplex, penthouse, bedroom, bathroom, size, furnish
                    , description_ENG, description_TH, user_id, '1', 32, created_Date, 32, last_Updated_Date)
            try:
                cursor.execute(query,val)
                connection.commit()
                insert += 1
                update_stat = False
                query = "SELECT Classified_ID, Ref_ID FROM classified WHERE Ref_ID = %s AND Project_ID = %s"
                val = (idid, project_id)
                cursor.execute(query,val)
                classified_id = cursor.fetchone()
                classified_id = classified_id[0]
                create_folder_and_remove_image_and_save_image()
                if insert % 100 == 0:
                    print(f'Insert {insert} Rows')
                log = True
            except Exception as e:
                stop_processing = True
                print(f'Error: {idid} {e}')
                log = False
                insert_log("Plus_insert_prop_Insert")
                break

if log:
    insert_log("Plus_insert_prop")

if len(property_list) > 0:
    try:
        query = """SELECT Classified_ID, Ref_ID FROM classified WHERE Classified_Status = '1' AND User_ID = 3"""
        cursor.execute(query)
        classified = cursor.fetchall()
    except Exception as e:
        stop_processing = True
        print(f'Error: {e}')

    if not stop_processing:
        for i, info in enumerate(classified):
            if stop_processing:
                break
            match = False
            classified_id = info[0]
            classified_ref_id = info[1]
            for j in property_list:
                if stop_processing:
                    break
                ref_id = str(j['Ref_ID'])
                if ref_id == classified_ref_id:
                    match = True
                    break
            if not match:
                try:
                    query = """UPDATE classified SET Classified_Status = '2' WHERE Classified_ID = %s"""
                    val = (classified_id,)
                    cursor.execute(query,val)
                    connection.commit()
                except Exception as e:
                    stop_processing = True
                    print(f'Error: {e}')
                    break

cursor.close()
connection.close()
print(f'Insert {insert} Rows')
print(f'Update {upd} Rows')
print('Connection closed')
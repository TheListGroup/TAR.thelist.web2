import mysql.connector
import json
import re
from datetime import datetime
import os
import requests
from PIL import Image
from io import BytesIO

#save_folder = "D:\PYTHON\TAR.thelist.web-1\classifield\classified_image"
#json_path = 'D:\PYTHON\TAR.thelist.web-1\classifield\AG\AG_PROPERTY.json'
json_path = '/home/gitdev/ta_python/classifield/AG/AG_PROPERTY.json'
save_folder = "/var/www/html/realist/condo/uploads/classified"
#json_path = '/home/gitprod/ta_python/classifield/AG/AG_PROPERTY.json'
user_id = 2

#host = '127.0.0.1'
#user = 'real-research'
#password = 'shA0Y69X06jkiAgaX&ng'

host = '157.230.242.204'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

def create_folder_and_remove_image_and_save_image():
    only_1_pic = False
    #folder_path = f'\{classified_id:06d}'
    folder_path = f'/{classified_id:06d}'
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
    for image_url in image_urls:
        try:
            try:
                response = requests.get(image_url)
            except:
                response = requests.get(image_urls)
                only_1_pic = True
            
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
                l += 1
                if only_1_pic:
                    break
        except:
            pass

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

def format_time(var):
    datetime = var.split(" ")
    date = datetime[0].split("/")
    date = [f'{int(part):02d}' for part in date]
    time = datetime[1].split(":")
    time = [f'{int(part):02d}' for part in time]
    var = '/'.join(date) + " " + ':'.join(time) + " " + datetime[2]
    if var[-2:] == "AM" and var[11:13] == "12":
        return var[:11] + "00" + var[13:-3] 
    elif var[-2:] == "AM":
        return var[:11] + var[11:-3] 
    elif var[-2:] == "PM" and var[11:13] == "12":
        return var[:11] + var[11:-3] 
    else:
        return var[:11] + str(int(var[11:13]) + 12) + var[13:19]

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
        
        match = "SELECT Project_ID, Condo_Code FROM classified_match WHERE Agent = 'AG'"
        cursor.execute(match)
        result_match = cursor.fetchall()
        
        check_update = "SELECT Classified_ID, Ref_ID, Project_ID, Last_Updated_Date FROM classified where Classified_Status = '1' AND User_ID = 2"
        cursor.execute(check_update)
        update = cursor.fetchall()

except Exception as e:
    print(f'Error: {e}')

property_list = []
if sql:
    with open(json_path, 'r', encoding='utf-8') as json_file_property:
        property_data = json.load(json_file_property)
    for property_ag in property_data:
        property_list.append(property_ag)
    
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
        last_Updated_Date = prop["Last_Updated_Date"]
        last_Updated_Date = format_time(last_Updated_Date) 
        last_Updated_Date = datetime.strptime(last_Updated_Date, '%m/%d/%Y %H:%M:%S')
        last_Updated_Date = last_Updated_Date.strftime('%Y-%m-%d %H:%M:%S')
        date_last_Updated_Date = last_Updated_Date[0:10]
        
        idid = prop["Ref_ID"]
        
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
            description_TH = re.sub(f' - {idid}', '', description_TH)
        
        if prop["Description_ENG"] == None or prop["Description_ENG"] == "":
            description_ENG = None
        else:
            description_ENG = prop["Description_ENG"]
            description_ENG = re.sub(f' - {idid}', '', description_ENG)
        
        if prop["Price_Sale"] == None or prop["Price_Sale"] == "0":
            price_Sale = None
            sale = False
        else:
            price_Sale = prop["Price_Sale"]
            sale = True
        
        if prop["Price_Rent"] == None or prop["Price_Rent"] == "0":
            price_Rent = None
            rent = False
        else:
            price_Rent = prop["Price_Rent"]
            rent = True
        
        if prop["Sale_with_Tenant"] == 'True':
            if sale == True:
                sale_with_Tenant = True
            else:
                sale_with_Tenant = False
        else:
            sale_with_Tenant = False
        
        if prop["Min_Rental_Contract"] == None:
            min_Rental_Contract = None
        else:
            min_Rental_Contract = prop["Min_Rental_Contract"]
        
        if prop["Deposit"] == None:
            deposit = None
        else:
            deposit = prop["Deposit"]
        
        if prop["Advance_Payment"] == None:
            advance_Payment = None
        else:
            advance_Payment = prop["Advance_Payment"]
        
        unit_floor_type = None
        if prop["bedtype"] == None:
            unit_floor_type = None
        elif 'Loft' in prop["bedtype"]:
            unit_floor_type = "Loft"
        elif 'Duplex' in prop["bedtype"]:
            unit_floor_type = "Duplex"
        
        if prop["bedrooms"] == None or prop["bedrooms"] == "0":
            bedroom = 1
        else:
            bedroom = prop["bedrooms"]
        
        if prop["bathrooms"] == "0" or prop["bathrooms"] == "0":
            bathroom = 1
        else:
            bathroom = prop["bathrooms"]
        
        if prop["Size"] == None or prop["Size"] == "0":
            size = None
        else:
            size = prop["Size"]
        
        if prop["Furnish"] == None or prop["Furnish"] == "Un furnished":
            furnish = None
        elif prop["Furnish"] == "Partly Furnished":
            furnish = "Fully Fitted"
        elif prop["Furnish"] == "Fully Furnished":
            furnish = "Fully Furnished"
        
        if prop["Fix_Parking"] == "N/A":
            fix_Parking = None
        elif prop["Fix_Parking"] == "True":   
            fix_Parking = True
        else:   
            fix_Parking = False
        
        try:
            image_urls = prop["images"]["imageurl"]
        except:
            image_urls = prop["images"]
        created_Date = prop["Created_Date"]
        created_Date = format_time(created_Date) 
        created_Date = datetime.strptime(created_Date, '%m/%d/%Y %H:%M:%S')
        created_Date = created_Date.strftime('%Y-%m-%d %H:%M:%S')
        if created_Date[:4] == '1900':
            created_Date = last_Updated_Date
        
        insert_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        update_insert_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
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
                                    , Sale_with_Tenant = %s, Rent = %s, Price_Sale = %s, Price_Rent = %s, Min_Rental_Contract = %s
                                    , Rent_Deposit = %s, Advance_Payment = %s, Unit_Floor_Type = %s, Bedroom = %s, Bathroom = %s
                                    , Size = %s, Furnish = %s , Parking = %s, Descriptions_Eng = %s, Descriptions_TH = %s
                                    , Last_Updated_Date = %s, Last_Update_Insert_Date = %s
                                WHERE Ref_ID = %s and Project_ID = %s"""
                    val = (idid, project_id, title_TH, title_ENG, condo_code, sale, sale_with_Tenant, rent, price_Sale, price_Rent
                        , min_Rental_Contract, deposit, advance_Payment, unit_floor_type, bedroom, bathroom, size, furnish
                        , fix_Parking, description_ENG, description_TH, last_Updated_Date, update_insert_date, idid, project_id)
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
                        insert_log("AG_insert_prop_Update")
                        break
                else:
                    break
        
        if not found:
            query = "INSERT INTO classified (Ref_ID, Project_ID, Title_TH, Title_ENG, Condo_Code, Sale, Sale_with_Tenant\
                    , Rent, Price_Sale, Price_Rent, Min_Rental_Contract, Rent_Deposit, Advance_Payment, Unit_Floor_Type\
                    , Bedroom, Bathroom, Size, Furnish, Parking, Descriptions_ENG, Descriptions_TH, User_ID\
                    , Classified_Status, Created_By, Created_Date, Last_Updated_By, Last_Updated_Date, Insert_Date)\
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            val = (idid, project_id, title_TH, title_ENG, condo_code, sale, sale_with_Tenant, rent, price_Sale, price_Rent, min_Rental_Contract
                    , deposit, advance_Payment, unit_floor_type, bedroom, bathroom, size, furnish, fix_Parking, description_ENG, description_TH, user_id
                    , '1', 32, created_Date, 32, last_Updated_Date, insert_date)
            try:
                cursor.execute(query,val)
                connection.commit()
                insert += 1
                update_stat = False
                query = "SELECT Classified_ID, Ref_ID FROM classified WHERE Ref_ID = %s AND Project_ID = %s AND Classified_Status = %s Limit 1"
                val = (idid, project_id, '1')
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
                insert_log("AG_insert_prop_Insert")
                break

if log:
    insert_log("AG_insert_prop")

if len(property_list) > 0:
    try:
        query = """SELECT Classified_ID, Ref_ID FROM classified WHERE Classified_Status = '1' AND User_ID = 2"""
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
                ref_id = j['Ref_ID']
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
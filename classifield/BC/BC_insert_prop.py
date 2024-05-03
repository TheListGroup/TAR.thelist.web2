import mysql.connector
import json
import re
from datetime import datetime
import os
import requests
from PIL import Image
from io import BytesIO

#save_folder = "D:\PYTHON\TAR.thelist.web-1\classifield\classified_image"
#json_path = 'D:\PYTHON\TAR.thelist.web-1\classifield\BC\BC_PROPERTY.json'
#json_path = '/home/gitdev/ta_python/classifield/BC/BC_PROPERTY.json'
save_folder = "/var/www/html/realist/condo/uploads/classified"
json_path = '/home/gitprod/ta_python/classifield/BC/BC_PROPERTY.json'
user_id = 1

host = '127.0.0.1'
user = 'real-research'
password = 'shA0Y69X06jkiAgaX&ng'

#host = '157.230.242.204'
#user = 'real-research2'
#password = 'DQkuX/vgBL(@zRRa'

def create_folder_and_remove_image_and_save_image():
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
            response = requests.get(image_url)
            image_data = response.content
            image = Image.open(BytesIO(image_data))
            file_name = f"{classified_id:06d}-{l+1:02d}.webp"
            save_path = os.path.join(full_path, file_name)
            image.save(save_path, "WebP")
            
            query = """INSERT INTO classified_image (Classified_Image_URL,Displayed_Order_in_Classified,Classified_ID,Classified_Image_Status
                        , Created_By, Created_Date, Last_Updated_By, Last_Updated_Date)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""
            val = (file_name, l+1, classified_id, '1', 32, created_Date, 32, last_Updated_Date)
            #print(f"{idid} -- {classified_id} -- {l+1} -- {created_Date} -- {last_Updated_Date}")
            cursor.execute(query,val)
            connection.commit()
            l += 1
            #print("Done Image")
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
        
        match = "SELECT Project_ID, Condo_Code FROM classified_match WHERE Agent = 'BC'"
        cursor.execute(match)
        result_match = cursor.fetchall()
        
        check_update = "SELECT Classified_ID, Ref_ID, Project_ID, Last_Updated_Date FROM classified where Classified_Status = '1' and User_ID = 1"
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
    project_id = property_list[i]['project_ID']
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
    prop_proj_id = prop['project_ID']
    
    for j, proj_match in enumerate(result_match):
        if stop_processing:
            break
        project_id = proj_match[0]
        condo_code = proj_match[1]
        if prop_proj_id == project_id:
            break
    
    if prop_proj_id == project_id:
        last_Updated_Date = prop["last_Updated_Date"]
        date_last_Updated_Date = last_Updated_Date[0:10]
        last_Updated_Date = re.sub('T',' ',last_Updated_Date)
        if '.' in last_Updated_Date:
            last_Updated_Date = datetime.strptime(last_Updated_Date, '%Y-%m-%d %H:%M:%S.%f')
        else:
            last_Updated_Date = datetime.strptime(last_Updated_Date, '%Y-%m-%d %H:%M:%S')
        last_Updated_Date = last_Updated_Date.strftime('%Y-%m-%d %H:%M:%S')
        idid = str(prop["id"])
        
        if prop["title_TH"] == None or prop["title_TH"] == "":
            title_TH = None
        else:    
            title_TH = prop["title_TH"]
        
        if prop["title_ENG"] == None or prop["title_ENG"] == "":
            title_ENG = None
        else:
            title_ENG = prop["title_ENG"]
        
        if prop["description_TH"] == None or prop["description_TH"] == "":
            description_TH = None
        else:
            description_TH = prop["description_TH"]
            description_TH = re.sub(r' Bangkok CitiSmart ', '', description_TH)
        
        if prop["description_ENG"] == None or prop["description_ENG"] == "":
            description_ENG = None
        else:
            description_ENG = prop["description_ENG"]
        
        if prop["price_Sale"] == None or prop["price_Sale"] == 0.00:
            price_Sale = None
            sale = False
        else:
            price_Sale = prop["price_Sale"]
            sale = True
        
        if prop["price_Rent"] == None or prop["price_Rent"] == 0.00:
            price_Rent = None
            rent = False
        else:
            price_Rent = prop["price_Rent"]
            rent = True
        
        sale_with_Tenant = prop["sale_with_Tenant"]
        if sale_with_Tenant == True:
            if sale == True:
                sale_with_Tenant = True
            else:
                sale_with_Tenant = False        
        
        if prop["min_Rental_Contract"] == None:
            min_Rental_Contract = None
        else:
            min_Rental_Contract = prop["min_Rental_Contract"]
        
        if prop["deposit"] == None:
            deposit = None
        else:
            deposit = prop["deposit"]
        
        if prop["advance_Payment"] == None:
            advance_Payment = None
        else:
            advance_Payment = prop["advance_Payment"]
        
        if prop["bedroom"] == 0:
            bedroom = 1
        else:
            bedroom = prop["bedroom"]
        
        if prop["bathroom"] == 0:
            bathroom = 1
        else:
            bathroom = prop["bathroom"]
        
        if prop["size"] == None or prop["size"] == 0.00:
            size = None
        else:
            size = prop["size"]
        
        if prop["furnish"] == None or prop["furnish"] == " No Furnished":
            furnish = None
        elif prop["furnish"] == " Partly Furnished":
            furnish = "Fully Fitted"
        else:
            furnish = prop["furnish"]
            furnish = furnish.strip()
        
        fix_Parking = prop["fix_Parking"]
        image_urls = prop["images"]
        created_Date = prop["created_Date"]
        created_Date = re.sub('T',' ',created_Date)
        if '.' in created_Date:
            created_Date = datetime.strptime(created_Date, '%Y-%m-%d %H:%M:%S.%f')
        else:
            created_Date = datetime.strptime(created_Date, '%Y-%m-%d %H:%M:%S')
        created_Date = created_Date.strftime('%Y-%m-%d %H:%M:%S')
        
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
                                    , Rent_Deposit = %s, Advance_Payment = %s, Bedroom = %s, Bathroom = %s, Size = %s, Furnish = %s
                                    , Parking = %s, Descriptions_Eng = %s, Descriptions_TH = %s, Last_Updated_Date = %s, Last_Update_Insert_Date = %s
                                WHERE Ref_ID = %s and Project_ID = %s"""
                    val = (idid, project_id, title_TH, title_ENG, condo_code, sale, sale_with_Tenant, rent, price_Sale, price_Rent
                        , min_Rental_Contract, deposit, advance_Payment, bedroom, bathroom, size, furnish, fix_Parking, description_ENG
                        , description_TH, last_Updated_Date, update_insert_date, idid, project_id)
                    try:
                        #print(idid)
                        cursor.execute(query,val)
                        connection.commit()
                        #print("Update Done")
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
            query = "INSERT INTO classified (Ref_ID, Project_ID, Title_TH, Title_ENG, Condo_Code, Sale, Sale_with_Tenant, Rent\
                    , Price_Sale, Price_Rent, Min_Rental_Contract, Rent_Deposit, Advance_Payment, Bedroom, Bathroom, Size, Furnish, Parking\
                    , Descriptions_ENG, Descriptions_TH, User_ID, Classified_Status, Created_By, Created_Date\
                    , Last_Updated_By, Last_Updated_Date, Insert_Date)\
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            val = (idid, project_id, title_TH, title_ENG, condo_code, sale, sale_with_Tenant, rent, price_Sale, price_Rent, min_Rental_Contract
                    , deposit, advance_Payment, bedroom, bathroom, size, furnish, fix_Parking, description_ENG, description_TH, user_id
                    , '1', 32, created_Date, 32, last_Updated_Date, insert_date)
            try:
                #print(idid)
                cursor.execute(query,val)
                connection.commit()
                #print("Insert Done")
                insert += 1
                update_stat = False
                #print(idid)
                query = "SELECT Classified_ID, Ref_ID FROM classified WHERE Ref_ID = %s AND Project_ID = %s AND Classified_Status = %s Limit 1"
                val = (idid, project_id, '1')
                cursor.execute(query,val)
                classified_id = cursor.fetchone()
                classified_id = classified_id[0]
                #print("Gen classified_id Done")
                create_folder_and_remove_image_and_save_image()
                if insert % 100 == 0:
                    print(f'Insert {insert} Rows')
                log = True
            except Exception as e:
                stop_processing = True
                print(f'Error: {idid} {e}')
                log = False
                insert_log("BC_insert_prop_Insert")
                break

if log:
    insert_log("BC_insert_prop")

if len(property_list) > 0:
    try:
        query = """SELECT Classified_ID, Ref_ID FROM classified WHERE Classified_Status = '1' AND User_ID = 1"""
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
                ref_id = str(j['id'])
                if ref_id == classified_ref_id:
                    match = True
                    break
            if not match:
                try:
                    query = """UPDATE classified SET Classified_Status = '3' WHERE Classified_ID = %s"""
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
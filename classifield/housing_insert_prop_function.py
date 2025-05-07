#destination
#log_in_database
#database
#open_proj_json
#project_have_room
#check_proj
#prepare_variable
#prepare_variable_from_db
#insert_log
#create_folder_and_remove_image_and_save_image
#create_query
#update_work
#insert_work
#check_status
from datetime import datetime
import requests
import os
from io import BytesIO
import mysql.connector
import json
from PIL import Image

def destination(agent):
    #save_folder = rf"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield\classified_image"
    #json_path = rf'C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield\{agent}\{agent}_housing_PROPERTY.json'
    #json_path2 = rf'C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield\{agent}\{agent}_housing_PROJECT.json'
    save_folder = rf"/var/www/html/realist/housing/uploads/classified"
    #json_path = rf'/home/gitdev/ta_python/classifield/{agent}/{agent}_housing_PROPERTY.json'
    #json_path2 = rf'/home/gitdev/ta_python/classifield/{agent}/{agent}_housing_PROJECT.json'
    json_path = rf'/home/gitprod/ta_python/classifield/{agent}/{agent}_housing_PROPERTY.json'
    json_path2 = rf'/home/gitprod/ta_python/classifield/{agent}/{agent}_housing_PROJECT.json'
    return save_folder, json_path, json_path2

def log_in_database():
    #host = '159.223.76.99'
    #user = 'real-research2'
    #password = 'DQkuX/vgBL(@zRRa'
    
    host = '127.0.0.1'
    user = 'real-research'
    password = 'shA0Y69X06jkiAgaX&ng'

    return host, user, password

def database(host,user,password,sql,agent,user_id):
    connection,cursor = '',''
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
            
            match = f"SELECT Project_ID, Condo_Code FROM classified_match WHERE Agent = '{agent}'"
            cursor.execute(match)
            result_match = {row[0]: row for row in cursor.fetchall()}
            
            check_update =f"""SELECT Classified_ID, Ref_ID, Project_ID, Classified_Type, Housing_Type, Housing_Latitude, Housing_Longitude
                            , Price_Sale, Sale_Reservation, Sale_Contact, Sale_Transfer_Fee, Sale_with_Tenant, Price_Rent, Min_Rental_Contract
                            , Rent_Deposit, Advance_Payment, Housing_TotalRai, Housing_Usable_Area, Floor, Bedroom, Bathroom, Parking_Amount
                            , Direction, Furnish, Move_In
                            FROM housing_classified WHERE Classified_Status = '1' AND User_ID = {user_id}"""
            cursor.execute(check_update)
            update = {(row[1], row[2]): row for row in cursor.fetchall()}

    except Exception as e:
        print(f'Error: {e}')
    
    return connection,cursor,sql,result_match,update

def open_proj_json(agent,json_path,property_list,cursor,connection,work):
    try:
        with open(json_path, 'r', encoding='utf-8') as json_file_property:
            property_data = json.load(json_file_property)
        for property_agent in property_data:
            property_list.append(property_agent)
        work = True
    except:
        query = """INSERT INTO realist_log (Type, Message, Location)
                VALUES (%s, %s, %s)"""
        val = (1, f'Agent {agent} cannot call api', 'classified_all_logs')
        cursor.execute(query,val)
        connection.commit()
    return property_list, work

def project_have_room(property_list,result_match,agent):
    i = 0
    while i in range(len(property_list)):
        project_id = property_list[i]['Project_ID']
        proj_prop = result_match.get(project_id)
        if proj_prop:
            i += 1
        else:
            property_list.pop(i)
    return property_list

def check_proj(result_match,prop_proj_id):
    project_id, housing_code = '', ''
    for j, proj_match in enumerate(list(result_match.values())):
        project_id = proj_match[0]
        housing_code = proj_match[1]
        if prop_proj_id == project_id:
            break
    return project_id, housing_code

def prepare_variable(prop,agent):
    idid_ref = "Ref_ID"
    housing_type_ref = "Housing_Type"
    lat_ref = "Housing_Latitude"
    long_ref = "Housing_Longitude"
    title_TH_ref = "Title_TH"
    title_ENG_ref = "Title_ENG"
    description_TH_ref = "Description_TH"
    description_ENG_ref = "Description_ENG"
    sale_with_Tenant_ref = "Sale_with_Tenant"
    sale_reservation_ref = "Sale_Reservation"
    sale_transfer_fee_ref = "Sale_Transfer_Fee"
    sale_contact_ref = "Sale_Contact"
    price_Sale_ref = "Price_Sale"
    price_Rent_ref = "Price_Rent"
    min_Rental_Contract_ref = "Min_Rental_Contract"
    deposit_ref = "Deposit"
    advance_Payment_ref = "Advance_Payment"
    totalrai_ref = "Housing_TotalRai"
    usable_area_ref = "Housing_Usable_Area"
    floor_ref = "Floor"
    bedroom_ref = "Bedroom"
    bathroom_ref = "Bathroom"
    parking_amount_ref = "Parking_Amount"
    direction_ref = "Direction"
    furnish_ref = "Furnish"
    move_in_ref = "Move_In"
    image_ref = "Images"
    last_Updated_Date_ref = "Last_Updated_Date"
    created_Date_ref = "Created_Date"

    idid = str(prop[idid_ref])
    
    if prop[housing_type_ref] == None or prop[housing_type_ref] == "":
        housing_type = None
    elif prop[housing_type_ref] == "single-detached-house":
        housing_type = "บ้านเดี่ยว"
    elif prop[housing_type_ref] == "semi-detached-house":
        housing_type = "บ้านแฝด"
    elif prop[housing_type_ref] == "townhome":
        housing_type = "ทาวน์โฮม"
    elif prop[housing_type_ref] == "shophouse":
        housing_type = "อาคารพาณิชย์"
    
    if prop[lat_ref] == None or prop[lat_ref] == "":
        lat = None
    else:
        lat = float(prop[lat_ref])
    
    if prop[long_ref] == None or prop[long_ref] == "":
        long = None
    else:
        long = float(prop[long_ref])
    
    if prop[title_TH_ref] == None or prop[title_TH_ref] == "":
        title_TH = None
    else:    
        title_TH = prop[title_TH_ref]
    
    if prop[title_ENG_ref] == None or prop[title_ENG_ref] == "":
        title_ENG = None
    else:
        title_ENG = prop[title_ENG_ref]
    
    if prop[description_TH_ref] == None or prop[description_TH_ref] == "":
        description_TH = None
    else:
        description_TH = prop[description_TH_ref]
    
    if prop[description_ENG_ref] == None or prop[description_ENG_ref] == "":
        description_ENG = None
    else:
        description_ENG = prop[description_ENG_ref]
    
    if prop[price_Sale_ref] == None or prop[price_Sale_ref] == "0" or round(float(prop[price_Sale_ref])) == 0:
        price_Sale = None
    else:
        price_Sale = int(round(float(prop[price_Sale_ref])))
        classified_type = "ขาย"
    
    if price_Sale != None:
        if prop[sale_reservation_ref] == None or prop[sale_reservation_ref] == ".00" or prop[sale_reservation_ref] == "":
            sale_reservation = None
        else:
            sale_reservation = int(round(float(prop[sale_reservation_ref])))
        
        if prop[sale_transfer_fee_ref] == None or prop[sale_transfer_fee_ref] == ".00" or prop[sale_transfer_fee_ref] == "":
            sale_transfer_fee = None
        else:
            sale_transfer_fee = (round(float(prop[sale_transfer_fee_ref])) * 100) / price_Sale
        
        if prop[sale_contact_ref] == None or prop[sale_contact_ref] == ".00" or prop[sale_contact_ref] == "" or prop[sale_contact_ref] == "0":
            sale_contact = None
        else:
            sale_contact = round(float(prop[sale_contact_ref]),2)
        
        if prop[sale_with_Tenant_ref] == 'True' or prop[sale_with_Tenant_ref] == True or prop[sale_with_Tenant_ref] == "1":
            sale_with_Tenant = True
        else:
            sale_with_Tenant = False
    else:
        sale_reservation, sale_contact, sale_transfer_fee, sale_with_Tenant = None, None, None, False
    
    if prop[price_Rent_ref] == None or round(float(prop[price_Rent_ref])) == 0:
        price_Rent = None
    else:
        price_Rent = int(round(float(prop[price_Rent_ref])))
        classified_type = "เช่า"
    
    if price_Rent != None and price_Sale != None:
        classified_type = "เช่าและขาย"
    
    if price_Rent != None:
        if prop[min_Rental_Contract_ref] == None or round(float(prop[min_Rental_Contract_ref])) == 0:
            min_Rental_Contract = None
        else:
            min_Rental_Contract = str(prop[min_Rental_Contract_ref])
        
        if prop[deposit_ref] == None:
            deposit = None
        else:
            deposit = str(prop[deposit_ref])
        
        if prop[advance_Payment_ref] == None:
            advance_Payment = None
        else:
            advance_Payment = str(prop[advance_Payment_ref])
    else:
        min_Rental_Contract, deposit, advance_Payment = None, None, None
    
    if prop[totalrai_ref] == None or round(float(prop[totalrai_ref])) == 0:
        totalrai = None
    else:
        totalrai = round(float(prop[totalrai_ref]),5)
    
    if prop[usable_area_ref] == None or round(float(prop[usable_area_ref])) == 0:
        usable_area = None
    else:
        usable_area = round(float(prop[usable_area_ref]),5)
    
    if "Storey" in prop[floor_ref]:
        floor = '2'
    elif prop[floor_ref] == None or prop[floor_ref] == "-":
        floor = None
    elif round(float(prop[floor_ref])) == 0:
        floor = None
    else:
        floor = int(prop[floor_ref].strip())
        if floor >= 6:
            floor = '6+'
        else:
            floor = str(floor)
    
    if prop[bedroom_ref] == None or round(float(prop[bedroom_ref])) == 0:
        bedroom = None
    else:
        bedroom = int(prop[bedroom_ref])
        if bedroom >= 5:
            bedroom = '5+'
        else:
            bedroom = str(bedroom)
    
    if prop[bathroom_ref] == None or round(float(prop[bathroom_ref])) == 0:
        bathroom = None
    else:
        bathroom = int(prop[bathroom_ref])
        if bathroom >= 5:
            bathroom = '5+'
        else:
            bathroom = str(bathroom)
    
    if prop[parking_amount_ref] == None:
        parking_amount = None
    else:
        parking_amount = int(prop[parking_amount_ref])
        if parking_amount >= 5:
            parking_amount = '5+'
        else:
            parking_amount = str(parking_amount)
    
    if prop[direction_ref] == None:
        direction = None
    else:
        if "East" in prop[direction_ref]:
            direction = "หันหน้าทิศตะวันออก"
        elif "West" in prop[direction_ref]:
            direction = "หันหน้าทิศตะวันตก"
        elif "North" in prop[direction_ref]:
            direction = "หันหน้าทิศเหนือ"
        elif "South" in prop[direction_ref]:
            direction = "หันหน้าทิศใต้"
    
    if prop[furnish_ref] == "Un furnished" or prop[furnish_ref] == " No Furnished" or prop[furnish_ref] == "Unfurnished":
        furnish = "Non Furnished"
    elif prop[furnish_ref] == "Partly Furnished" or prop[furnish_ref] == " Partly Furnished" or prop[furnish_ref] == "semi" or prop[furnish_ref] == "Partially":
        furnish = "Fully Fitted"
    elif prop[furnish_ref] == "Fully Furnished" or prop[furnish_ref] == " Fully Furnished" or prop[furnish_ref] == "fully" or prop[furnish_ref] == "Fully":
        furnish = "Fully Furnished"
    else:
        furnish = None
    
    if prop[move_in_ref] == None:
        move_in = None
    else:
        move_in = "พร้อมให้เข้าอยู่"
    
    if prop[image_ref] == None or prop[image_ref] == "[]":
        image_urls = None
    else:
        image_urls = prop[image_ref]

    if prop[created_Date_ref] == None or prop[created_Date_ref] == "":
        created_Date = None
    else:
        created_Date = prop[created_Date_ref]
        created_Date = datetime.strptime(created_Date, '%Y-%m-%d %H:%M:%S.%f')
        created_Date = created_Date.strftime('%Y-%m-%d %H:%M:%S')
    
    if prop[last_Updated_Date_ref] == None or prop[last_Updated_Date_ref] == "":
        last_Updated_Date = None
    else:
        last_Updated_Date = prop[last_Updated_Date_ref]
        last_Updated_Date = datetime.strptime(last_Updated_Date, '%Y-%m-%d %H:%M:%S.%f')
        last_Updated_Date = last_Updated_Date.strftime('%Y-%m-%d %H:%M:%S')
    
    insert_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    update_insert_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    data_api_list = [classified_type, housing_type, lat, long, price_Sale, sale_reservation, sale_contact, sale_transfer_fee, sale_with_Tenant
                    , price_Rent, min_Rental_Contract, deposit, advance_Payment, totalrai, usable_area, floor, bedroom, bathroom, parking_amount
                    , direction, furnish, move_in]
    return idid, classified_type, housing_type, lat, long, price_Sale, sale_reservation, sale_contact, sale_transfer_fee, sale_with_Tenant, price_Rent\
            , min_Rental_Contract, deposit, advance_Payment, totalrai, usable_area, floor, bedroom, bathroom, parking_amount, direction, furnish, move_in\
            , title_TH, title_ENG, description_TH, description_ENG, last_Updated_Date, created_Date, insert_date, update_insert_date, image_urls\
            , data_api_list

def prepare_variable_from_db(data):
    classified_id,update_id,update_proj_id = data[0], data[1],data[2]
    classified_type_check,housing_type_check,lat_check,long_check = data[3],data[4],data[5],data[6]
    price_sale_check,sale_reservation_check,sale_contact_check = data[7],data[8],data[9]
    sale_transfer_fee_check,sale_with_tenant_check,price_rent_check = data[10],data[11],data[12]
    min_rental_contract_check,deposit_check,advance_payment_check,totalrai_check,usable_area_check = data[13],data[14],data[15],data[16],data[17]
    floor_check,bedroom_check,bathroom_check,parking_amount_check,direction_check = data[18],data[19],data[20],data[21],data[22]
    furnish_check,move_in_check = data[23],data[24]
    variable_check_list = [classified_id,update_id,update_proj_id,classified_type_check,housing_type_check,lat_check,long_check
                            ,price_sale_check,sale_reservation_check,sale_contact_check,sale_transfer_fee_check,sale_with_tenant_check
                            ,price_rent_check,min_rental_contract_check,deposit_check,advance_payment_check,totalrai_check,usable_area_check
                            ,floor_check,bedroom_check,bathroom_check,parking_amount_check,direction_check,furnish_check,move_in_check]
    return classified_id, update_id, update_proj_id, classified_type_check, housing_type_check, lat_check, long_check, price_sale_check\
            , sale_reservation_check, sale_contact_check, sale_transfer_fee_check, sale_with_tenant_check, price_rent_check\
            , min_rental_contract_check, deposit_check, advance_payment_check, totalrai_check, usable_area_check, floor_check, bedroom_check\
            , bathroom_check, parking_amount_check, direction_check, furnish_check, move_in_check, variable_check_list

def insert_log(location,log,upd,insert,cursor,connection,e):
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

def create_folder_and_remove_image_and_save_image(cursor,connection,classified_id,save_folder,update_stat,image_urls,created_Date,last_Updated_Date):
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
        query = """DELETE FROM housing_classified_image
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
                
                query = """INSERT INTO housing_classified_image (Classified_Image_URL,Displayed_Order_in_Classified,Classified_ID,Classified_Image_Status
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

def create_query(state):
    if state == 'log_update':
        query = """INSERT INTO housing_classified_log (Type, Classified_ID, Ref_ID, Project_ID, Classified_Type, Housing_Type, Housing_Code
                , Housing_Latitude, Housing_Longitude, Price_Sale, Sale_Reservation, Sale_Contact, Sale_Transfer_Fee, Sale_with_Tenant, Price_Rent
                , Min_Rental_Contract, Rent_Deposit, Advance_Payment, Housing_TotalRai, Housing_Usable_Area, Floor, Bedroom, Bathroom
                , Parking_Amount, Direction, Furnish, Move_In, Title_TH, Title_ENG, Descriptions_TH, Descriptions_ENG, User_ID, Classified_Status
                , Created_By, Created_Date, Last_Updated_By, Last_Updated_Date)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                , %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
    elif state == 'data_update':
        query = """UPDATE housing_classified
                SET Classified_Type = %s, Housing_Type = %s, Housing_Code = %s, Housing_Latitude = %s, Housing_Longitude = %s
                    , Price_Sale = %s, Sale_Reservation = %s, Sale_Contact = %s, Sale_Transfer_Fee = %s, Sale_with_Tenant = %s, Price_Rent = %s
                    , Min_Rental_Contract = %s, Rent_Deposit = %s, Advance_Payment = %s, Housing_TotalRai = %s, Housing_Usable_Area = %s, Floor = %s
                    , Bedroom = %s, Bathroom = %s, Parking_Amount = %s, Direction = %s, Furnish = %s, Move_In = %s, Title_TH = %s, Title_ENG = %s
                    , Descriptions_TH = %s, Descriptions_ENG = %s, Last_Updated_Date = %s, Last_Update_Insert_Date = %s
                WHERE Ref_ID = %s and Project_ID = %s and Classified_Status = '1'"""
    elif state == 'log_insert':
        query = """INSERT INTO housing_classified_log (Type, Classified_ID, Ref_ID, Project_ID, Classified_Type, Housing_Type, Housing_Code
                , Housing_Latitude, Housing_Longitude, Price_Sale, Sale_Reservation, Sale_Contact, Sale_Transfer_Fee, Sale_with_Tenant, Price_Rent
                , Min_Rental_Contract, Rent_Deposit, Advance_Payment, Housing_TotalRai, Housing_Usable_Area, Floor, Bedroom, Bathroom
                , Parking_Amount, Direction, Furnish, Move_In, Title_TH, Title_ENG, Descriptions_TH, Descriptions_ENG, User_ID, Classified_Status
                , Created_By, Created_Date, Last_Updated_By, Last_Updated_Date)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                , %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
    elif state == 'data_insert':
        query = """INSERT INTO housing_classified (Ref_ID, Project_ID, Classified_Type, Housing_Type, Housing_Code
                , Housing_Latitude, Housing_Longitude, Price_Sale, Sale_Reservation, Sale_Contact, Sale_Transfer_Fee, Sale_with_Tenant, Price_Rent
                , Min_Rental_Contract, Rent_Deposit, Advance_Payment, Housing_TotalRai, Housing_Usable_Area, Floor, Bedroom, Bathroom
                , Parking_Amount, Direction, Furnish, Move_In, Title_TH, Title_ENG, Descriptions_TH, Descriptions_ENG, User_ID, Classified_Status
                , Created_By, Created_Date, Last_Updated_By, Last_Updated_Date, Insert_Date)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                , %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
    return query

def update_work(agent,cursor,connection,query,val,classified_log,log_val,idid,upd,classified_id,save_folder,image_urls,created_Date,last_Updated_Date,insert,stop_processing):
    try:
        cursor.execute(query,val)
        connection.commit()
        cursor.execute(classified_log,log_val)
        connection.commit()
        upd += 1
        update_stat = True
        create_folder_and_remove_image_and_save_image(cursor,connection,classified_id,save_folder,update_stat,image_urls,created_Date,last_Updated_Date)
        if upd % 100 == 0:
            print(f'Update {upd} Rows')
        log = True
    except Exception as e:
        stop_processing = True
        print(f'Error: {idid} {e}')
        log = False
        insert_log(f"{agent}_insert_prop_Update",log,upd,insert,cursor,connection,e)
    return stop_processing, log, upd

def insert_work(agent,cursor,connection,query,val,idid,project_id,insert,save_folder,image_urls,created_Date,last_Updated_Date,upd,stop_processing):
    try:
        cursor.execute(query,val)
        connection.commit()
        insert += 1
        update_stat = False
        query = "SELECT Classified_ID, Ref_ID FROM housing_classified WHERE Ref_ID = %s AND Project_ID = %s AND Classified_Status = %s Limit 1"
        val = (idid, project_id, '1')
        cursor.execute(query,val)
        classified_id = cursor.fetchone()
        classified_id = classified_id[0]
        create_folder_and_remove_image_and_save_image(cursor,connection,classified_id,save_folder,update_stat,image_urls,created_Date,last_Updated_Date)
        if insert % 100 == 0:
            print(f'Insert {insert} Rows')
        log = True
    except Exception as e:
        stop_processing = True
        print(f'Error: {idid} {e}')
        log = False
        insert_log(f"{agent}_insert_prop_Insert",log,upd,insert,cursor,connection,e)
    return stop_processing, log, insert, classified_id

def check_status(cursor,connection,user_id,property_list,stop_processing,agent):
    try:
        query = f"""SELECT Classified_ID, Ref_ID FROM housing_classified WHERE Classified_Status = '1' AND User_ID = {user_id}"""
        cursor.execute(query)
        classified =  cursor.fetchall()
    except Exception as e:
        stop_processing = True
        print(f'Error: {e}')

    for i, info in enumerate(classified):
        if stop_processing:
            break
        ref_ref  = 'Ref_ID'
        status_update = '3'
        classified_id = info[0]
        classified_ref_id = info[1]
        found_ref = next((item for item in property_list if str(item[ref_ref]) == classified_ref_id), None)
        if found_ref == None:
            try:
                query = "UPDATE housing_classified SET Classified_Status = %s WHERE Classified_ID = %s"
                val = (status_update, classified_id)
                cursor.execute(query,val)
                connection.commit()
                classified_log = """INSERT INTO housing_classified_all_logs (Type, Classified_ID, Classified_Status, Created_By, Last_Updated_By, User_ID)
                                VALUES (%s, %s, %s, %s, %s, %s)"""
                log_val = ('status', classified_id, status_update, 32, 32, user_id)
                cursor.execute(classified_log,log_val)
                connection.commit()
            except Exception as e:
                stop_processing = True
                print(f'Error: {e}')
                break
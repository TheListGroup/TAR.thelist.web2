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
import re
import requests
import os
from io import BytesIO
import mysql.connector
import json
from PIL import Image

def destination(agent):
    #save_folder = rf"C:\PYTHON\TAR.thelist.web2\classifield\classified_image"
    #json_path = rf'C:\PYTHON\TAR.thelist.web2\classifield\{agent}\{agent}_PROPERTY.json'
    #json_path2 = rf'C:\PYTHON\TAR.thelist.web2\classifield\{agent}\{agent}_PROJECT.json'
    save_folder = rf"/var/www/html/realist/condo/uploads/classified"
    #json_path = rf'/home/gitdev/ta_python/classifield/{agent}/{agent}_PROPERTY.json'
    #json_path2 = rf'/home/gitdev/ta_python/classifield/{agent}/{agent}_PROJECT.json'
    json_path = rf'/home/gitprod/ta_python/classifield/{agent}/{agent}_PROPERTY.json'
    json_path2 = rf'/home/gitprod/ta_python/classifield/{agent}/{agent}_PROJECT.json'
    return save_folder, json_path, json_path2

def log_in_database():
    #host = '157.230.242.204'
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
            
            check_update =f"""SELECT Classified_ID, Ref_ID, Project_ID, Title_TH, Title_ENG, Sale, Sale_with_Tenant, Rent, Price_Sale
                            , Sale_Transfer_Fee, Sale_Deposit, Sale_Mortgage_Costs, Price_Rent, Min_Rental_Contract, Rent_Deposit
                            , Advance_Payment, Room_Type, Unit_Floor_Type, PentHouse, Bedroom, Bathroom, Floor, Direction, Move_In, Size
                            , Furnish, Parking
                            FROM classified WHERE Classified_Status = '1' AND User_ID = {user_id}"""
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
        if agent != 'BC':
            project_id = property_list[i]['Project_ID']
        else:
            project_id = property_list[i]['project_ID']
        proj_prop = result_match.get(project_id)
        if proj_prop:
            i += 1
        else:
            property_list.pop(i)
    return property_list

def check_proj(result_match,prop_proj_id):
    project_id, condo_code = '', ''
    for j, proj_match in enumerate(list(result_match.values())):
        project_id = proj_match[0]
        condo_code = proj_match[1]
        if prop_proj_id == project_id:
            break
    return project_id, condo_code

def prepare_variable(prop,agent):
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
    
    def date_bc_plus(created_Date):
        if created_Date != None:
            created_Date = re.sub('T',' ',created_Date)
            if '.' in created_Date:
                created_Date = datetime.strptime(created_Date, '%Y-%m-%d %H:%M:%S.%f')
            else:
                created_Date = datetime.strptime(created_Date, '%Y-%m-%d %H:%M:%S')
            created_Date = created_Date.strftime('%Y-%m-%d %H:%M:%S')
        else:
            created_Date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        return created_Date
    
    if agent != 'BC':
        idid_ref = "Ref_ID"
        title_TH_ref = "Title_TH"
        title_ENG_ref = "Title_ENG"
        price_Sale_ref = "Price_Sale"
        sale_with_Tenant_ref = "Sale_with_Tenant"
        price_Rent_ref = "Price_Rent"
        min_Rental_Contract_ref = "Min_Rental_Contract"
        deposit_ref = "Deposit"
        advance_Payment_ref = "Advance_Payment"
        size_ref = "Size"
        furnish_ref = "Furnish"
        description_TH_ref = "Description_TH"
        description_ENG_ref = "Description_ENG"
        last_Updated_Date_ref = "Last_Updated_Date"
        created_Date_ref = "Created_Date"
    else:
        idid_ref = "id"
        title_TH_ref = "title_TH"
        title_ENG_ref = "title_ENG"
        price_Sale_ref = "price_Sale"
        sale_with_Tenant_ref = "sale_with_Tenant"
        price_Rent_ref = "price_Rent"
        min_Rental_Contract_ref = "min_Rental_Contract"
        deposit_ref = "deposit"
        advance_Payment_ref = "advance_Payment"
        size_ref = "size"
        furnish_ref = "furnish"
        description_TH_ref = "description_TH"
        description_ENG_ref = "description_ENG"
        last_Updated_Date_ref = "last_Updated_Date"
        created_Date_ref = "created_Date"

    idid = str(prop[idid_ref])
    floor, direction, move_in = None,None,None
    sale_transfer_fee,sale_deposit,sale_mongage_cost = None,None,None
    
    if prop[title_TH_ref] == None or prop[title_TH_ref] == "":
        title_TH = None
    else:    
        title_TH = prop[title_TH_ref]
    
    if prop[title_ENG_ref] == None or prop[title_ENG_ref] == "":
        title_ENG = None
    else:
        title_ENG = prop[title_ENG_ref]
    
    if prop[price_Sale_ref] == None or prop[price_Sale_ref] == "0" or prop[price_Sale_ref] == 0.00 or prop[price_Sale_ref] == 0.0:
        price_Sale = None
        sale = False
    else:
        price_Sale = int(round(float(prop[price_Sale_ref])))
        sale = True
    
    if prop[price_Rent_ref] == None or prop[price_Rent_ref] == "0" or prop[price_Rent_ref] == 0.00 or prop[price_Rent_ref] == 0.0:
        price_Rent = None
        rent = False
    else:
        price_Rent = int(round(float(prop[price_Rent_ref])))
        rent = True
    
    if prop[size_ref] == None or prop[size_ref] == "0" or prop[size_ref] == 0.00:
        size = None
    else:
        size = str(float(prop[size_ref]))
    
    if prop[furnish_ref] == "Un furnished" or prop[furnish_ref] == " No Furnished":
        furnish = "Non Furnished"
    elif prop[furnish_ref] == "Partly Furnished" or prop[furnish_ref] == " Partly Furnished" or prop[furnish_ref] == "semi":
        furnish = "Fully Fitted"
    elif prop[furnish_ref] == "Fully Furnished" or prop[furnish_ref] == " Fully Furnished" or prop[furnish_ref] == "fully":
        furnish = "Fully Furnished"
    else:
        furnish = None
    
    if prop[description_TH_ref] == None or prop[description_TH_ref] == "":
        description_TH = None
    else:
        description_TH = prop[description_TH_ref]
    
    if prop[description_ENG_ref] == None or prop[description_ENG_ref] == "":
        description_ENG = None
    else:
        description_ENG = prop[description_ENG_ref]
    
    insert_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    update_insert_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    if agent != 'Plus':
        room_type, penthouse = None,0
        
        if prop[sale_with_Tenant_ref] == 'True' or prop[sale_with_Tenant_ref] == True:
            if sale == True:
                sale_with_Tenant = True
            else:
                sale_with_Tenant = False
        else:
            sale_with_Tenant = False
        
        if prop[min_Rental_Contract_ref] == None:
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
        
        if agent != 'BC':
            description_TH = re.sub(f' - {idid}', '', description_TH)
            description_ENG = re.sub(f' - {idid}', '', description_ENG)
            
            if prop["bedtype"] == None:
                unit_floor_type = None
            elif 'Loft' in prop["bedtype"]:
                unit_floor_type = "Loft"
            elif 'Simplex' in prop["bedtype"]:
                unit_floor_type = "Simplex"
            elif 'Duplex' in prop["bedtype"]:
                unit_floor_type = "Duplex"
            elif 'Triplex' in prop["bedtype"]:
                unit_floor_type = "Triplex"
            else:
                unit_floor_type = None
            
            if prop["bedrooms"] == None or prop["bedrooms"] == "0":
                bedroom = '1'
            else:
                bedroom = str(round(float(prop["bedrooms"])))
            
            if prop["bathrooms"] == None or prop["bathrooms"] == "0":
                bathroom = 1
            else:
                bathroom = int(round(float(prop["bathrooms"])))
            
            if prop["Fix_Parking"] == "N/A":
                fix_Parking = None
            elif prop["Fix_Parking"] == "True":   
                fix_Parking = True
            else:   
                fix_Parking = False
            
            last_Updated_Date = prop[last_Updated_Date_ref]
            last_Updated_Date = format_time(last_Updated_Date) 
            last_Updated_Date = datetime.strptime(last_Updated_Date, '%m/%d/%Y %H:%M:%S')
            last_Updated_Date = last_Updated_Date.strftime('%Y-%m-%d %H:%M:%S')
            
            created_Date = prop[created_Date_ref]
            created_Date = format_time(created_Date) 
            created_Date = datetime.strptime(created_Date, '%m/%d/%Y %H:%M:%S')
            created_Date = created_Date.strftime('%Y-%m-%d %H:%M:%S')
            if created_Date[:4] == '1900':
                created_Date = last_Updated_Date
            
            try:
                image_urls = prop["images"]["imageurl"]
            except:
                image_urls = prop["images"]
        else:
            unit_floor_type = None
            fix_Parking = prop["fix_Parking"]
            image_urls = prop["images"]
            
            if prop["bedroom"] == 0:
                bedroom = '1'
            else:
                bedroom = str(round(float(prop["bedroom"])))
            
            if prop["bathroom"] == 0:
                bathroom = 1
            else:
                bathroom = int(round(float(prop["bathroom"])))
            
            last_Updated_Date = prop[last_Updated_Date_ref]
            last_Updated_Date = re.sub('T',' ',last_Updated_Date)
            if '.' in last_Updated_Date:
                last_Updated_Date = datetime.strptime(last_Updated_Date, '%Y-%m-%d %H:%M:%S.%f')
            else:
                last_Updated_Date = datetime.strptime(last_Updated_Date, '%Y-%m-%d %H:%M:%S')
            last_Updated_Date = last_Updated_Date.strftime('%Y-%m-%d %H:%M:%S')
            
            created_Date = prop[created_Date_ref]
            created_Date = date_bc_plus(created_Date)
    else:
        sale_with_Tenant = False
        min_Rental_Contract,deposit,advance_Payment,fix_Parking = None,None,None,None
        penthouse = prop["is_penthouse"]
        if description_TH != None:
            description_TH = re.sub(r' Bangkok CitiSmart ', '', description_TH)
        image_urls = prop["Images"]
        
        if prop["is_studio"] == True:
            room_type = 'Studio'
        else:
            room_type = None
        
        if prop["is_duplex"] == True:
            unit_floor_type = 'Duplex'
        else:
            unit_floor_type = None
        
        if prop["Bedroom"] == 0:
            bedroom = '1'
        else:
            bedroom = str(round(float(prop["Bedroom"])))
        
        if prop["Bathroom"] == 0:
            bathroom = 1
        else:
            bathroom = int(round(float(prop["Bathroom"])))
        
        if prop[last_Updated_Date_ref] != None:
            last_Updated_Date = prop[last_Updated_Date_ref]
            last_Updated_Date = re.sub('T',' ',last_Updated_Date)
            if '.' in last_Updated_Date:
                last_Updated_Date = datetime.strptime(last_Updated_Date, '%Y-%m-%d %H:%M:%S.%f')
            else:
                last_Updated_Date = datetime.strptime(last_Updated_Date, '%Y-%m-%d %H:%M:%S')
            last_Updated_Date = last_Updated_Date.strftime('%Y-%m-%d %H:%M:%S')
        else:
            last_Updated_Date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        created_Date = prop[created_Date_ref]
        created_Date = date_bc_plus(created_Date)
    
    data_api_list = [sale,sale_with_Tenant, rent, price_Sale, sale_transfer_fee, sale_deposit, sale_mongage_cost, price_Rent, min_Rental_Contract
                    , deposit, advance_Payment, room_type, unit_floor_type, penthouse, bedroom, bathroom, floor, direction, move_in, size, furnish
                    , fix_Parking]
    return idid, title_TH, title_ENG, sale, sale_with_Tenant, rent, price_Sale, sale_transfer_fee, sale_deposit, sale_mongage_cost, price_Rent\
            , min_Rental_Contract, deposit, advance_Payment, room_type, unit_floor_type, penthouse, bedroom, bathroom, floor, direction, move_in\
            , size, furnish, fix_Parking, description_TH, description_ENG, last_Updated_Date, created_Date, insert_date, update_insert_date\
            , image_urls, data_api_list

def prepare_variable_from_db(data):
    classified_id,update_id = data[0], data[1]
    update_proj_id,th_title,en_title = data[2],data[3],data[4]
    sale_check,sale_with_tenant_check,rent_check = data[5],data[6],data[7]
    price_sale_check,sale_transfer_fee_check,sale_deposit_check,sale_mongage_cost_check,price_rent_check = data[8],data[9],data[10],data[11],data[12]
    min_rental_contract_check,rent_deposit,advance_payment_check,room_type_check,unit_floor_type_check = data[13],data[14],data[15],data[16],data[17]
    penthouse_check,bedroom_check,bathroom_check,floor_check,direction_check = data[18],data[19],data[20],data[21],data[22]
    movein_check,size_check,furnish_check,parking = data[23],str(data[24]),data[25],data[26]
    variable_check_list = [classified_id,update_id,update_proj_id,sale_check,sale_with_tenant_check,rent_check,price_sale_check
                            ,sale_transfer_fee_check,sale_deposit_check,sale_mongage_cost_check,price_rent_check
                            ,min_rental_contract_check,rent_deposit,advance_payment_check,room_type_check,unit_floor_type_check
                            ,penthouse_check,bedroom_check,bathroom_check,floor_check,direction_check,movein_check,size_check
                            ,furnish_check,parking]
    return classified_id, update_id, update_proj_id, th_title, en_title, sale_check, sale_with_tenant_check, rent_check, price_sale_check\
            , sale_transfer_fee_check, sale_deposit_check, sale_mongage_cost_check, price_rent_check, min_rental_contract_check, rent_deposit\
            , advance_payment_check, room_type_check, unit_floor_type_check, penthouse_check, bedroom_check, bathroom_check, floor_check\
            , direction_check, movein_check, size_check, furnish_check, parking, variable_check_list

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

def create_query(state):
    if state == 'log_update':
        query = """INSERT INTO classified_all_logs (Type, Classified_ID, Ref_ID, Project_ID, Title_TH, Title_ENG, Condo_Code, Sale
                , Sale_with_Tenant, Rent, Price_Sale, Sale_Transfer_Fee, Sale_Deposit, Sale_Mortgage_Costs, Price_Rent, Min_Rental_Contract
                , Rent_Deposit, Advance_Payment, Room_Type, Unit_Floor_Type, PentHouse, Bedroom, Bathroom, Floor, Direction, Move_In
                , Size, Furnish, Parking, Descriptions_Eng, Descriptions_TH, User_ID, Classified_Status, Created_By, Created_Date
                , Last_Updated_By, Last_Updated_Date)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                , %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
    elif state == 'data_update':
        query = """UPDATE classified
                SET Title_TH = %s, Title_ENG = %s, Condo_Code = %s, Sale = %s
                    , Sale_with_Tenant = %s, Rent = %s, Price_Sale = %s, Sale_Transfer_Fee = %s, Sale_Deposit = %s, Sale_Mortgage_Costs = %s
                    , Price_Rent = %s, Min_Rental_Contract = %s, Rent_Deposit = %s, Advance_Payment = %s, Room_Type = %s, Unit_Floor_Type = %s
                    , PentHouse = %s, Bedroom = %s, Bathroom = %s, Floor = %s, Direction = %s, Move_In = %s, Size = %s, Furnish = %s , Parking = %s
                    , Descriptions_Eng = %s, Descriptions_TH = %s, Last_Updated_Date = %s, Last_Update_Insert_Date = %s
                WHERE Ref_ID = %s and Project_ID = %s and Classified_Status = '1'"""
    elif state == 'log_insert':
        query = """INSERT INTO classified_all_logs (Type, Classified_ID, Ref_ID, Project_ID, Title_TH, Title_ENG, Condo_Code, Sale
                , Sale_with_Tenant, Rent, Price_Sale, Sale_Transfer_Fee, Sale_Deposit, Sale_Mortgage_Costs, Price_Rent, Min_Rental_Contract
                , Rent_Deposit, Advance_Payment, Room_Type, Unit_Floor_Type, PentHouse, Bedroom, Bathroom, Floor, Direction, Move_In
                , Size, Furnish, Parking, Descriptions_Eng, Descriptions_TH, User_ID, Classified_Status, Created_By, Created_Date
                , Last_Updated_By, Last_Updated_Date)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                , %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
    elif state == 'data_insert':
        query = "INSERT INTO classified (Ref_ID, Project_ID, Title_TH, Title_ENG, Condo_Code, Sale, Sale_with_Tenant, Rent, Price_Sale, Sale_Transfer_Fee\
                , Sale_Deposit, Sale_Mortgage_Costs, Price_Rent, Min_Rental_Contract, Rent_Deposit, Advance_Payment, Room_Type , Unit_Floor_Type, PentHouse\
                , Bedroom, Bathroom, Floor, Direction, Move_In, Size, Furnish, Parking, Descriptions_ENG, Descriptions_TH, User_ID, Classified_Status\
                , Created_By, Created_Date, Last_Updated_By, Last_Updated_Date, Insert_Date)\
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\
                , %s, %s, %s)"
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
        query = "SELECT Classified_ID, Ref_ID FROM classified WHERE Ref_ID = %s AND Project_ID = %s AND Classified_Status = %s Limit 1"
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
        query = f"""SELECT Classified_ID, Ref_ID FROM classified WHERE Classified_Status = '1' AND User_ID = {user_id}"""
        cursor.execute(query)
        classified =  cursor.fetchall()
    except Exception as e:
        stop_processing = True
        print(f'Error: {e}')

    for i, info in enumerate(classified):
        if stop_processing:
            break
        if agent != 'BC':
            ref_ref  = 'Ref_ID'
        else:
            ref_ref  = 'id'
        if agent == 'BC':
            status_update = '3'
        else:
            status_update = '2'
        classified_id = info[0]
        classified_ref_id = info[1]
        found_ref = next((item for item in property_list if str(item[ref_ref]) == classified_ref_id), None)
        if found_ref == None:
            try:
                query = f"""UPDATE classified SET Classified_Status = {status_update} WHERE Classified_ID = %s"""
                val = (classified_id,)
                cursor.execute(query,val)
                connection.commit()
                classified_log = """INSERT INTO classified_all_logs (Type, Classified_ID, Classified_Status, Created_By, Last_Updated_By)
                                VALUES (%s, %s, %s, %s, %s)"""
                log_val = ('status', classified_id, status_update, 32, 32)
                cursor.execute(classified_log,log_val)
                connection.commit()
            except Exception as e:
                stop_processing = True
                print(f'Error: {e}')
                break
from datetime import datetime as tt, timedelta
import gspread
from oauth2client.service_account import ServiceAccountCredentials
from googleapiclient.discovery import build
import pandas as pd
import re
import requests
import os
from io import BytesIO
from wand.image import Image as b
from PIL import Image as a
import mysql.connector
import io

def destination(agent,file):
    #save_folder = rf"C:\PYTHON\TAR.thelist.web2\classifield\{agent}\classified_image"
    #json_file = rf"C:\PYTHON\TAR.thelist.web2\classifield\{agent}\{file}"
    save_folder = "/var/www/html/realist/condo/uploads/classified"
    #json_file = rf"/home/gitdev/ta_python/classifield/{agent}/{file}"
    json_file = rf"/home/gitprod/ta_python/classifield/{agent}/{file}"
    return save_folder, json_file

def log_in_database():
    #host = '157.230.242.204'
    #user = 'real-research2'
    #password = 'DQkuX/vgBL(@zRRa'
    
    host = '127.0.0.1'
    user = 'real-research'
    password = 'shA0Y69X06jkiAgaX&ng'

    return host, user, password

def check_update(json_file,ggsheet_url):
    work = False
    yesterday = (tt.now() - timedelta(days=1)).strftime('%Y-%m-%d')
    scope = ['https://spreadsheets.google.com/feeds', 'https://www.googleapis.com/auth/drive']
    creds = ServiceAccountCredentials.from_json_keyfile_name(json_file, scope)
    client = gspread.authorize(creds)
    sheet = client.open_by_url(ggsheet_url)
    file_id = sheet.id
    sheet = sheet.sheet1
    drive_service = build('drive', 'v3', credentials=creds)
    file_metadata = drive_service.files().get(fileId=file_id, fields='modifiedTime').execute()
    last_modified_time = file_metadata['modifiedTime']
    last_modified_date = last_modified_time.split('T')[0]
    #print(last_modified_date)
    if last_modified_date == yesterday:
        work = True
    return work, sheet

def check_null(variable):
    if pd.isna(variable) or variable == 'N/A' or variable == '' or variable == '-':
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

def create_folder_and_remove_image_and_save_image(folder_url,classified_id,save_folder,update_stat,cursor,connection,log,upd,insert,create_date,last_updated_date):
    response = requests.get(folder_url)
    if response.status_code == 200:
        html_content = response.text
        #current_time = datetime.datetime.now()
        #print(f"request image at {current_time}")
        
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
        #current_time = datetime.datetime.now()
        #print(f"get all link at {current_time}")
        
        pic_list = []
        for file_link in file_links:
            if "ddrive_web" in file_link:
                pic_list.append(file_link)
        #current_time = datetime.datetime.now()
        #print(f"get img link at {current_time}")
    
    #folder_path = f'//{classified_id:06d}'
    folder_path = f'/{classified_id:06d}'
    full_path = save_folder + folder_path
    if not os.path.exists(full_path):
        os.makedirs(full_path)
        
    for existing_file in os.listdir(full_path):
        file_path = os.path.join(full_path, existing_file)
        if os.path.isfile(file_path):
            os.remove(file_path)
    #current_time = datetime.datetime.now()
    #print(f"create or delete file at {current_time}")
    
    if update_stat:
        query = """DELETE FROM classified_image
                    WHERE Classified_ID = %s"""
        val = (classified_id,)
        cursor.execute(query,val)
        connection.commit()
        #current_time = datetime.datetime.now()
        #print(f"delete from img table at {current_time}")
    
    l = 0
    for image_url in pic_list:
        file_id_match = re.search(r'/d/([a-zA-Z0-9_-]+)/', image_url)
        if file_id_match:
            file_id = file_id_match.group(1)
            direct_download_url = f"https://drive.google.com/uc?id={file_id}"
            
            #if check_image_url_validity(direct_download_url):
            response = requests.get(direct_download_url)
            #current_time = datetime.datetime.now()
            #print(f"image {l+1} request to resize at {current_time}")
            try:
                with b(file=BytesIO(response.content)) as img:
                    img.transform(resize=f"1900x1900>")
                    #current_time = datetime.datetime.now()
                    #print(f"image {l+1} resize at {current_time}")
                    filename = f"{classified_id:06d}-{l+1:02d}.webp"
                    img.format = 'webp'
                    save_path = os.path.join(full_path, filename)
                    img.save(filename=save_path)
                    #current_time = datetime.datetime.now()
                    #print(f"image {l+1} save at {current_time}")
                
                try:
                    query = """INSERT INTO classified_image (Classified_Image_URL,Displayed_Order_in_Classified,Classified_ID,Classified_Image_Status
                                , Created_By, Created_Date, Last_Updated_By, Last_Updated_Date)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""
                    val = (filename, l+1, classified_id, '1', 32, create_date, 32, last_updated_date)
                    cursor.execute(query,val)
                    connection.commit()
                    stop_processing = False
                    #current_time = datetime.datetime.now()
                    #print(f"image {l+1} insert to img table at {current_time}")
                    l += 1
                except Exception as e:
                    stop_processing = True
                    print(f'Error: {e} at SERVE_insert_prop_Image')
                    insert_log("SERVE_insert_prop_Image",log,upd,insert,cursor,connection,e)
                    break
            except:
                pass
    return stop_processing

def check_image_url_validity(url):
    try:
        response = requests.head(url)
        #current_time = datetime.datetime.now()
        #print(f"request to check at {current_time}")
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

def database(host,user,password,sql):
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

    except Exception as e:
        print(f'Error: {e}')
    return connection,cursor,sql

def read_sheet(SHEET_URL,data_list):
    response = requests.get(SHEET_URL)
    if response.status_code == 200:
        data = response.content.decode('utf-8')
        df = pd.read_csv(io.StringIO(data))
        #current_time = datetime.datetime.now()
        #print(f"Read ggsheet at {current_time}")
        
        for row in df.values:
            data_list.append(row)
    return data_list

def check(stop_processing, query ,prop_id, user_id, cursor, log, upd, insert, connection, agent):
    column_check = None
    val = (prop_id, user_id)
    try:
        cursor.execute(query,val)
        column_check = cursor.fetchone()
    except Exception as e:
        stop_processing = True
        print(f'Error: {e} at {agent}_check_column')
        log = False
        insert_log(f"{agent}_check_column",log,upd,insert,cursor,connection,e)
    return stop_processing, column_check, log

def compare_column(column_list1, column_check):
    for i, column in enumerate(column_list1):
        if type(column_check[i]) == int or type(column_check[i]) == float:
            if '.0' in str(column_check[i]) or '.00' in str(column_check[i]) or '.0' in str(column) or '.00' in str(column):
                db_column = round(column_check[i])
                column = round(float(column))
            else:
                db_column = column_check[i]
        else:
            db_column = column_check[i]
        if str(column) != str(db_column):
            #print(f"{column} -- {db_column}")
            found = True
            break
        else:
            found = False
    return found

def update_work(stop_processing, cursor, connection, query, val, folder_url, classified_id, save_folder, log, upd, insert, create_date, last_updated_date, sheet, row_sheet, agent):
    try:
        cursor.execute(query,val)
        connection.commit()
        #current_time = datetime.datetime.now()
        #print(f"Update at {current_time}")
        upd += 1
        update_stat = True
        stop_processing = create_folder_and_remove_image_and_save_image(folder_url,classified_id,save_folder,update_stat,cursor,connection,log,upd,insert,create_date,last_updated_date)
        #sheet.update_cell(row_sheet,17,f"https://thelist.group/realist/condo/unit/{classified_id}") #only prod
        if upd % 10 == 0:
            print(f'Update {upd} Rows')
        if not stop_processing:
            log = True
    except Exception as e:
        stop_processing = True
        print(f'Error: {e} at {agent}_insert_prop_Update')
        log = False
        insert_log(f"{agent}_insert_prop_Update",log,upd,insert,cursor,connection,e)
    return log, upd, stop_processing, row_sheet

def insert_work(stop_processing, cursor, connection, query, val, prop_id, user_id, folder_url, save_folder, log, upd, insert, create_date, last_updated_date, sheet, row_sheet, agent):
    try:
        cursor.execute(query,val)
        connection.commit()
        insert += 1
        update_stat = False
        query = "SELECT Classified_ID, Ref_ID FROM classified WHERE Ref_ID = %s AND Classified_Status = %s and User_ID = %s Limit 1"
        val = (prop_id, '1', user_id)
        cursor.execute(query,val)
        classified_id = cursor.fetchone()
        if classified_id:
            classified_id = classified_id[0]
            stop_processing = create_folder_and_remove_image_and_save_image(folder_url,classified_id,save_folder,update_stat,cursor,connection,log,upd,insert,create_date,last_updated_date)
            #sheet.update_cell(row_sheet,17,f"https://thelist.group/realist/condo/unit/{classified_id}") #only prod
        if insert % 10 == 0:
            print(f'Insert {insert} Rows')
        if not stop_processing:
            log = True
    except Exception as e:
        stop_processing = True
        print(f'Error: {prop_id} {e}')
        log = False
        insert_log(f"{agent}_insert_prop_Insert",log,upd,insert,cursor,connection,e)
    return log, insert, stop_processing, row_sheet
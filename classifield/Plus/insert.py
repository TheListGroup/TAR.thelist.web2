import pandas as pd
from datetime import datetime
import os
from io import BytesIO
from PIL import Image
import requests
import mysql.connector
import ast

#file = pd.read_csv(r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield\Plus\plus_data.csv", encoding='utf-8')
#save_folder = rf"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield\condo_classified_image"
#save_folder_housing = rf"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield\housing_classified_image"
#file = pd.read_csv(r'/home/gitdev/ta_python/classifield/Plus/plus_data.csv', encoding='utf-8')
#save_folder = rf"/var/www/html/realist/condo/uploads/classified"
#save_folder_housing = rf"/var/www/html/realist/housing/uploads/classified"
file = pd.read_csv(r'/home/gitprod/ta_python/classifield/Plus/plus_data.csv', encoding='utf-8')
save_folder = rf"/var/www/html/realist/condo/uploads/classified"
save_folder_housing = rf"/var/www/html/realist/housing/uploads/classified"

host = '127.0.0.1'
user = 'real-research'
password = 'shA0Y69X06jkiAgaX&ng'

#host = '159.223.76.99'
#user = 'real-research2'
#password = 'DQkuX/vgBL(@zRRa'

agent = 'Plus'
sql = False
user_id = 3
stop_processing = False
insert = 0
log = False

def insert_log():
    if log:
        query = """INSERT INTO realist_log (Type, SQL_State, Message, Location)
                VALUES (%s, %s, %s, %s)"""
        val = (0, '00000', f'Insert {insert} Rows', f"{agent}_insert_prop")
        cursor.execute(query,val)
        connection.commit()
    else:
        query = """INSERT INTO realist_log (Type, Message, Location)
                VALUES (%s, %s, %s)"""
        val = (1, str(e), f'{location}')
        cursor.execute(query,val)
        connection.commit()

def create_folder_and_remove_image_and_save_image(image_urls):
    only_1_pic = False
    #folder_path = f'\{classified_id:06d}'
    folder_path = f'/{classified_id:06d}'
    if housing:
        folder = save_folder_housing
    else:
        folder = save_folder
    full_path = folder + folder_path
    if not os.path.exists(full_path):
        os.makedirs(full_path)
        
    for existing_file in os.listdir(full_path):
        file_path = os.path.join(full_path, existing_file)
        if os.path.isfile(file_path):
            os.remove(file_path)
    
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
                
                query = f"""INSERT INTO {image_table} (Classified_Image_URL,Displayed_Order_in_Classified,Classified_ID,Classified_Image_Status
                            , Created_By, Created_Date, Last_Updated_By, Last_Updated_Date)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""
                val = (file_name, l+1, classified_id, '1', 32, use_date, 32, use_date)
                cursor.execute(query,val)
                connection.commit()
                l += 1
                if only_1_pic:
                    break
        except:
            pass

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

if sql:
    for i in range(file.index.size):
        if stop_processing:
            break
        use_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        housing = False
        date_table = 'classified'
        image_table = 'classified_image'
        code = file.iloc[i, 0]
        proj_id = file.iloc[i, 1]
        title = file.iloc[i, 2]
        condo_code = file.iloc[i, 3]
        sale = file.iloc[i, 4]
        rent = file.iloc[i, 5]
        price = file.iloc[i, 6]
        bedroom = file.iloc[i, 7]
        bathroom = file.iloc[i, 8]
        size = file.iloc[i, 9]
        description = file.iloc[i, 10]
        image_list = ast.literal_eval(file.iloc[i, 11])
        if "CD" in code:
            query = "INSERT INTO classified (Ref_ID, Project_ID, Title_TH, Condo_Code, Sale, Rent, Price_Sale, Bedroom, Bathroom, Size\
                    , Descriptions_TH, User_ID, Classified_Status, Created_By, Created_Date, Last_Updated_By, Last_Updated_Date\
                    , Insert_Date, Last_Update_Insert_Date)\
                    values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            val = (str(code), str(proj_id), str(title), str(condo_code), int(sale), int(rent), int(price), str(bedroom), int(bathroom), str(size), str(description)
                , user_id, '1', 32, use_date, 32, use_date, use_date, use_date)
            log_query = "INSERT INTO classified_all_logs (Type, Classified_ID, Ref_ID, Project_ID, Title_TH, Condo_Code, Sale\
                    , Price_Sale, Bedroom, Bathroom, Size, Descriptions_TH, User_ID, Classified_Status, Created_By, Created_Date\
                    , Last_Updated_By, Last_Updated_Date)\
                    values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
        else:
            housing = True
            date_table = 'housing_classified'
            image_table = 'housing_classified_image'
            if "SH" in code:
                housing_type = "บ้านเดี่ยว"
            elif "TH" in code:
                housing_type = "ทาวน์โฮม"
            else:
                pass
            if bedroom >= 5:
                bedroom = "5+"
            if bathroom >= 5:
                bathroom = "5+"
            query = "INSERT INTO housing_classified (Ref_ID, Project_ID, Classified_Type, Housing_Type, Housing_Code, Price_Sale\
                    , Sale_with_Tenant, Housing_Usable_Area, Bedroom, Bathroom, Title_TH, Descriptions_TH, User_ID, Classified_Status\
                    , Created_By, Created_Date, Last_Updated_By, Last_Updated_Date, Last_Update_Insert_Date)\
                    values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
            val = (str(code), str(proj_id), 'ขาย', str(housing_type), str(condo_code), int(price), 0, str(size), str(bedroom), str(bathroom)
                , str(title), str(description), user_id, '1', 32, use_date, 32, use_date, use_date)
        try:
            cursor.execute(query,val)
            connection.commit()
            insert += 1
            query = f"SELECT Classified_ID, Ref_ID FROM {date_table} WHERE Ref_ID = %s AND Project_ID = %s AND Classified_Status = %s Limit 1"
            val = (code, proj_id, '1')
            cursor.execute(query,val)
            classified_id = cursor.fetchone()
            classified_id = classified_id[0]
            create_folder_and_remove_image_and_save_image(image_list)
            if not housing:
                log_val = ('insert', str(classified_id), str(code), str(proj_id), str(title), str(condo_code), 1, int(price), str(bedroom), int(bathroom)
                        , str(size), str(description), user_id, '1', 32, use_date, 32 ,use_date)
                cursor.execute(log_query,log_val)
                connection.commit()
            log = True
        except Exception as e:
            stop_processing = True
            print(f'Error: {code} {e}')
            log = False
            insert_log()
        print(f'{i+1} -- {code}')

if log:
    insert_log()

cursor.close()
connection.close()
print('Connection closed')
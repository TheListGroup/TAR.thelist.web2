import pandas as pd
import re
import mysql.connector
from datetime import datetime

def check_null(variable):
    if pd.isna(variable) or variable == 'NULL':
        variable = None
    else:
        variable = str(variable).strip()
    return variable

def format_date(variable):
    if variable != None:
        split_variable = variable.split(" ")
        if len(split_variable) == 1:
            split_variable = variable.split("/")
            variable = split_variable[2] + "-" + split_variable[0] + "-" + split_variable[1]
        else:
            date = variable[:-6].split("/")
            date = date[2] + "-" + date[0] + "-" + date[1]
            time = variable[-6:] + ":00"
            variable = date + time
    return variable

def format_comma(variable):
    if variable != None:
        variable = re.sub(',','',variable)
    return variable

csv_path = r"C:\PYTHON\TAR.thelist.web2\housing_template\home.csv"

host = '157.230.242.204'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

work = False
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
        work = True
    
except Exception as e:
    print(f'Error: {e}')

if work:
    log = False
    count = 0
    csv = pd.read_csv(csv_path, encoding='utf-8')
    for i in range(csv.index.size): 
        code = check_null(csv.iloc[i].iloc[1])
        
        name_th = check_null(csv.iloc[i].iloc[2])
        name_th_lo = check_null(csv.iloc[i].iloc[3])
        if name_th != None and name_th_lo != None:
            name = name_th + "\n" + name_th_lo
        else:
            name = name_th
        
        name_en = check_null(csv.iloc[i].iloc[4])
        name_en_lo = check_null(csv.iloc[i].iloc[5])
        if name_en != None and name_en_lo != None:
            enname = name_en + "\n" + name_en_lo
        else:
            enname = name_en
        
        brand_code = check_null(csv.iloc[i].iloc[6])
        developer_code = check_null(csv.iloc[i].iloc[7])
        latitude = check_null(csv.iloc[i].iloc[8])
        longitude = check_null(csv.iloc[i].iloc[9])
        coordinate_mark = check_null(csv.iloc[i].iloc[10])
        scope_area = check_null(csv.iloc[i].iloc[11])
        road_name = check_null(csv.iloc[i].iloc[12])
        postal_code = check_null(csv.iloc[i].iloc[13])
        subdistrict = check_null(csv.iloc[i].iloc[14])
        district = check_null(csv.iloc[i].iloc[15])
        province = check_null(csv.iloc[i].iloc[16])
        address_mark = check_null(csv.iloc[i].iloc[17])
        update_date = datetime.today().strftime('%Y-%m-%d %H-%M-%S')

        update = """update housing set Housing_Name = %s, Housing_ENName = %s, Brand_Code = %s, Developer_Code= %s, Housing_Latitude = %s, Housing_Longitude = %s
                , Coordinate_Mark = %s, Housing_ScopeArea = %s, Road_Name = %s, Postal_Code = %s, SubDistrict_ID = %s, District_ID = %s, Province_ID = %s, Address_Mark = %s
                , Last_Updated_Date = %s where Housing_Code = %s"""
        val = (name, enname, brand_code, developer_code, latitude, longitude, coordinate_mark, scope_area, road_name, postal_code, subdistrict, district, province
            , address_mark, update_date, code)
        try:
            cursor.execute(update,val)
            connection.commit()
            count += 1
            if count % 800 == 0:
                print(f"Updated {count}")
            log = True
        except Exception as e:
            print(f'Error: {e} at Update_Housing_Project')

    if log:
        query = """INSERT INTO realist_log (Type, SQL_State, Message, Location)
                VALUES (%s, %s, %s, %s)"""
        val = (0, '00000', f'Update_Housing_Project {count} Rows', 'Update Housing_Project')
        try:
            cursor.execute(query,val)
            connection.commit()
        except Exception as e:
            print(f'Error: {e} at Update_log')

    cursor.close()
    connection.close()
print('Done -- Connection closed')
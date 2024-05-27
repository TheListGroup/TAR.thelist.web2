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
    insert_list = []
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
        
        #brand_code = check_null(csv.iloc[i].iloc[4])
        developer_code = check_null(csv.iloc[i].iloc[6])
        latitude = check_null(csv.iloc[i].iloc[7])
        longitude = check_null(csv.iloc[i].iloc[8])
        coordinate_mark = check_null(csv.iloc[i].iloc[9])
        #scope_area = check_null(csv.iloc[i].iloc[9])
        #road_name = check_null(csv.iloc[i].iloc[10])
        postal_code = check_null(csv.iloc[i].iloc[10])
        subdistrict = check_null(csv.iloc[i].iloc[11])
        district = check_null(csv.iloc[i].iloc[12])
        province = check_null(csv.iloc[i].iloc[13])
        address_mark = check_null(csv.iloc[i].iloc[14])
        #realsubdistrict = check_null(csv.iloc[i].iloc[16])
        #realdistrict = check_null(csv.iloc[i].iloc[17])
        rai = format_comma(check_null(csv.iloc[i].iloc[19]))
        ngan = format_comma(check_null(csv.iloc[i].iloc[20]))
        wa = format_comma(check_null(csv.iloc[i].iloc[21]))
        totalrai = format_comma(check_null(csv.iloc[i].iloc[22]))
        floor_min = check_null(csv.iloc[i].iloc[16])
        floor_max = check_null(csv.iloc[i].iloc[17])
        total_unit = check_null(csv.iloc[i].iloc[24])
        area_min = format_comma(check_null(csv.iloc[i].iloc[28]))
        area_max = format_comma(check_null(csv.iloc[i].iloc[29]))
        use_area_min = format_comma(check_null(csv.iloc[i].iloc[32]))
        use_area_max = format_comma(check_null(csv.iloc[i].iloc[33]))
        bedroom_min = check_null(csv.iloc[i].iloc[36])
        bedroom_max = check_null(csv.iloc[i].iloc[37])
        bathroom_min = check_null(csv.iloc[i].iloc[38])
        bathroom_max = check_null(csv.iloc[i].iloc[39])
        price_min = format_comma(check_null(csv.iloc[i].iloc[54]))
        price_max = format_comma(check_null(csv.iloc[i].iloc[55]))
        price_date = format_date(check_null(csv.iloc[i].iloc[53]))
        build_start = format_date(check_null(csv.iloc[i].iloc[45]))
        build_finish = format_date(check_null(csv.iloc[i].iloc[49]))
        #sold_status = check_null(csv.iloc[i].iloc[38])
        #sold_date = format_date(check_null(csv.iloc[i].iloc[39]))
        parking_min = check_null(csv.iloc[i].iloc[41])
        parking_max = check_null(csv.iloc[i].iloc[42])
        common_fee_min = check_null(csv.iloc[i].iloc[58])
        common_fee_max = check_null(csv.iloc[i].iloc[59])
        sd = check_null(csv.iloc[i].iloc[65])
        dd = check_null(csv.iloc[i].iloc[66])
        th = check_null(csv.iloc[i].iloc[67])
        ho = check_null(csv.iloc[i].iloc[68])
        sh = check_null(csv.iloc[i].iloc[69])
        #spotlight1 = check_null(csv.iloc[i].iloc[49])
        #spotlight2 = check_null(csv.iloc[i].iloc[50])
        #price_point = check_null(csv.iloc[i].iloc[51])
        #unit_point = check_null(csv.iloc[i].iloc[52])
        #age_point = check_null(csv.iloc[i].iloc[53])
        #list_point = check_null(csv.iloc[i].iloc[54])
        #station_point = check_null(csv.iloc[i].iloc[55])
        #expressway_point = check_null(csv.iloc[i].iloc[56])
        #realist_score = check_null(csv.iloc[i].iloc[57])
        #url_tag = check_null(csv.iloc[i].iloc[58])
        #cover = check_null(csv.iloc[i].iloc[59])
        #redirect = check_null(csv.iloc[i].iloc[60])
        #pageview = check_null(csv.iloc[i].iloc[61])
        status = '1'
        create_by = 32
        create_date = datetime.today().strftime('%Y-%m-%d %H-%M-%S')
        update_by = 32
        update_date = datetime.today().strftime('%Y-%m-%d %H-%M-%S')
        insert_list.append((code, name, enname, developer_code, latitude, longitude, coordinate_mark
                            , postal_code, subdistrict, district, province, address_mark, rai, ngan
                            , wa, totalrai, floor_min, floor_max, total_unit, area_min, area_max, use_area_min, use_area_max, bedroom_min
                            , bedroom_max, bathroom_min, bathroom_max, price_min, price_max, price_date, build_start, build_finish
                            , parking_min, parking_max, common_fee_min, common_fee_max, sd, dd, th, ho, sh, status, create_by, create_date, update_by, update_date))
        count += 1
        if count % 800 == 0:
            print(f"Prepare {count}")

    insert = "insert into housing (Housing_Code, Housing_Name, Housing_ENName, Developer_Code, Housing_Latitude, Housing_Longitude\
            , Coordinate_Mark, Postal_Code, SubDistrict_ID, District_ID, Province_ID, Address_Mark\
            , Housing_LandRai, Housing_LandNgan, Housing_LandWa, Housing_TotalRai\
            , Housing_Floor_Min, Housing_Floor_Max , Housing_TotalUnit, Housing_Area_Min, Housing_Area_Max, Housing_Usable_Area_Min\
            , Housing_Usable_Area_Max, Bedroom_Min, Bedroom_Max, Bathroom_Min, Bathroom_Max, Housing_Price_Min, Housing_Price_Max\
            , Housing_Price_Date, Housing_Built_Start, Housing_Built_Finished\
            , Housing_Parking_Min, Housing_Parking_Max, Housing_Common_Fee_Min, Housing_Common_Fee_Max, IS_SD, IS_DD, IS_TH, IS_HO, IS_SH\
            , Housing_Status, Created_By, Created_Date, Last_Updated_By, Last_Updated_Date)\
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,\
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,\
                %s, %s)"
    val = insert_list
    try:
        cursor.executemany(insert,val)
        connection.commit()
        log = True
    except Exception as e:
        print(f'Error: {e} at Insert_Housing_Project')

    if log:
        query = """INSERT INTO realist_log (Type, SQL_State, Message, Location)
                VALUES (%s, %s, %s, %s)"""
        val = (0, '00000', f'Insert_Housing_Project {count} Rows', 'Insert Housing_Project')
        try:
            cursor.execute(query,val)
            connection.commit()
        except Exception as e:
            print(f'Error: {e} at Insert_log')

    cursor.close()
    connection.close()
print('Done -- Connection closed')
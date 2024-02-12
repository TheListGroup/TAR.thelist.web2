import pandas as pd
import re
import mysql.connector

def check_null(variable):
    if pd.isna(variable) or variable == '':
        variable = None
    else:
        variable = str(variable).strip()
    return variable

def format_date(variable):
    if variable != None:
        variable = variable.split("/")
        variable = variable[2] + "-" + variable[1] + "-" + variable[0]
    return variable

def format_comma(variable):
    if variable != None:
        variable = re.sub(',','',variable)
    return variable

csv_path = "D:\PYTHON\TAR.thelist.web-2\housing_template\home.csv"

host = '157.230.242.204'
user = 'real-research2'
password = 'Y2qhLqIV9Vwqg]U@'

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
        idid = csv.iloc[i][0]
        code = "HP" + str(f'{idid:04d}') #
        name = check_null(csv.iloc[i][3])
        enname = check_null(csv.iloc[i][4])
        developer_code = check_null(csv.iloc[i][8])
        latitude = check_null(csv.iloc[i][86])
        longitude = check_null(csv.iloc[i][87])
        coordinate_mark = check_null(csv.iloc[i][88])
        postal_code = check_null(csv.iloc[i][85])
        district = check_null(csv.iloc[i][81])
        subdistrict = check_null(csv.iloc[i][82])
        province = check_null(csv.iloc[i][83])
        address_mark = check_null(csv.iloc[i][84])
        rai = format_comma(check_null(csv.iloc[i][13]))
        ngan = format_comma(check_null(csv.iloc[i][14]))
        wa = format_comma(check_null(csv.iloc[i][15]))
        totalrai = format_comma(check_null(csv.iloc[i][16]))
        floor_min = check_null(csv.iloc[i][10])
        floor_max = check_null(csv.iloc[i][11])
        total_unit = check_null(csv.iloc[i][18])
        area_min = format_comma(check_null(csv.iloc[i][21]))
        area_max = format_comma(check_null(csv.iloc[i][22]))
        use_area_min = format_comma(check_null(csv.iloc[i][25]))
        use_area_max = format_comma(check_null(csv.iloc[i][26]))
        bedroom_min = check_null(csv.iloc[i][29])
        bedroom_max = check_null(csv.iloc[i][30])
        bathroom_min = check_null(csv.iloc[i][31])
        bathroom_max = check_null(csv.iloc[i][32])
        price_min = format_comma(check_null(csv.iloc[i][56]))
        price_max = format_comma(check_null(csv.iloc[i][57]))
        price_date = format_date(check_null(csv.iloc[i][55]))
        build_start = format_date(check_null(csv.iloc[i][47]))
        build_finish = format_date(check_null(csv.iloc[i][51]))
        parking_min = check_null(csv.iloc[i][40])
        parking_max = check_null(csv.iloc[i][41])
        common_fee_min = check_null(csv.iloc[i][60])
        common_fee_max = check_null(csv.iloc[i][61])
        sd = check_null(csv.iloc[i][72])
        dd = check_null(csv.iloc[i][73])
        th = check_null(csv.iloc[i][74])
        ho = check_null(csv.iloc[i][75])
        sh = check_null(csv.iloc[i][76])
        if enname != None: 
            url_tag = re.sub(' ','-',enname.lower()) + '-' + code
        else:
            url_tag = None
        insert_list.append((code, name, enname, developer_code, latitude, longitude, coordinate_mark, postal_code, subdistrict
                            , district, province, address_mark, rai, ngan, wa, totalrai, floor_min, floor_max, total_unit
                            , area_min, area_max, use_area_min, use_area_max, bedroom_min, bedroom_max, bathroom_min
                            , bathroom_max, price_min, price_max, price_date, build_start, build_finish, parking_min, parking_max
                            , common_fee_min, common_fee_max, sd, dd, th, ho, sh, url_tag, '1', 32, 32))
        count += 1
        if count % 800 == 0:
            print(f"Prepare {count}")

    insert = "insert into housing (Housing_Code, Housing_Name, Housing_ENName, Developer_Code, Housing_Latitude, Housing_Longitude\
            , Coordinate_Mark, Postal_Code, SubDistrict_ID, District_ID, Province_ID, Address_Mark, Housing_LandRai, Housing_LandNgan\
            , Housing_LandWa, Housing_TotalRai, Housing_Floor_Min, Housing_Floor_Max , Housing_TotalUnit, Housing_Area_Min\
            , Housing_Area_Max, Housing_Usable_Area_Min, Housing_Usable_Area_Max, Bedroom_Min, Bedroom_Max, Bathroom_Min, Bathroom_Max\
            , Housing_Price_Min, Housing_Price_Max, Housing_Price_Date, Housing_Built_Start, Housing_Built_Finished\
            , Housing_Parking_Min, Housing_Parking_Max, Housing_Common_Fee_Min, Housing_Common_Fee_Max, IS_SD, IS_DD, IS_TH, IS_HO\
            , IS_SH, Housing_URL_Tag, Housing_Status, Created_By, Last_Updated_By)\
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,\
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
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
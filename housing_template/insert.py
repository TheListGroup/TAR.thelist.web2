import pandas as pd
import re
import mysql.connector

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
        code = check_null(csv.iloc[i][1])
        name = check_null(csv.iloc[i][2])
        enname = check_null(csv.iloc[i][3])
        brand_code = check_null(csv.iloc[i][4])
        developer_code = check_null(csv.iloc[i][5])
        latitude = check_null(csv.iloc[i][6])
        longitude = check_null(csv.iloc[i][7])
        coordinate_mark = check_null(csv.iloc[i][8])
        scope_area = check_null(csv.iloc[i][9])
        road_name = check_null(csv.iloc[i][10])
        postal_code = check_null(csv.iloc[i][11])
        subdistrict = check_null(csv.iloc[i][12])
        district = check_null(csv.iloc[i][13])
        province = check_null(csv.iloc[i][14])
        address_mark = check_null(csv.iloc[i][15])
        realsubdistrict = check_null(csv.iloc[i][16])
        realdistrict = check_null(csv.iloc[i][17])
        rai = format_comma(check_null(csv.iloc[i][18]))
        ngan = format_comma(check_null(csv.iloc[i][19]))
        wa = format_comma(check_null(csv.iloc[i][20]))
        totalrai = format_comma(check_null(csv.iloc[i][21]))
        floor_min = check_null(csv.iloc[i][22])
        floor_max = check_null(csv.iloc[i][23])
        total_unit = check_null(csv.iloc[i][24])
        area_min = format_comma(check_null(csv.iloc[i][25]))
        area_max = format_comma(check_null(csv.iloc[i][26]))
        use_area_min = format_comma(check_null(csv.iloc[i][27]))
        use_area_max = format_comma(check_null(csv.iloc[i][28]))
        bedroom_min = check_null(csv.iloc[i][29])
        bedroom_max = check_null(csv.iloc[i][30])
        bathroom_min = check_null(csv.iloc[i][31])
        bathroom_max = check_null(csv.iloc[i][32])
        price_min = format_comma(check_null(csv.iloc[i][33]))
        price_max = format_comma(check_null(csv.iloc[i][34]))
        price_date = format_date(check_null(csv.iloc[i][35]))
        build_start = format_date(check_null(csv.iloc[i][36]))
        build_finish = format_date(check_null(csv.iloc[i][37]))
        sold_status = check_null(csv.iloc[i][38])
        sold_date = format_date(check_null(csv.iloc[i][39]))
        parking_min = check_null(csv.iloc[i][40])
        parking_max = check_null(csv.iloc[i][41])
        common_fee_min = check_null(csv.iloc[i][42])
        common_fee_max = check_null(csv.iloc[i][43])
        sd = check_null(csv.iloc[i][44])
        dd = check_null(csv.iloc[i][45])
        th = check_null(csv.iloc[i][46])
        ho = check_null(csv.iloc[i][47])
        sh = check_null(csv.iloc[i][48])
        spotlight1 = check_null(csv.iloc[i][49])
        spotlight2 = check_null(csv.iloc[i][50])
        price_point = check_null(csv.iloc[i][51])
        unit_point = check_null(csv.iloc[i][52])
        age_point = check_null(csv.iloc[i][53])
        list_point = check_null(csv.iloc[i][54])
        station_point = check_null(csv.iloc[i][55])
        expressway_point = check_null(csv.iloc[i][56])
        realist_score = check_null(csv.iloc[i][57])
        url_tag = check_null(csv.iloc[i][58])
        cover = check_null(csv.iloc[i][59])
        redirect = check_null(csv.iloc[i][60])
        pageview = check_null(csv.iloc[i][61])
        status = check_null(csv.iloc[i][62])
        create_by = check_null(csv.iloc[i][63])
        create_date = format_date(check_null(csv.iloc[i][64]))
        update_by = check_null(csv.iloc[i][65])
        update_date = format_date(check_null(csv.iloc[i][66]))
        insert_list.append((code, name, enname, brand_code, developer_code, latitude, longitude, coordinate_mark, scope_area
                            , road_name, postal_code, subdistrict, district, province, address_mark, realsubdistrict, realdistrict, rai, ngan
                            , wa, totalrai, floor_min, floor_max, total_unit, area_min, area_max, use_area_min, use_area_max, bedroom_min
                            , bedroom_max, bathroom_min, bathroom_max, price_min, price_max, price_date, build_start, build_finish, sold_status
                            , sold_date, parking_min, parking_max, common_fee_min, common_fee_max, sd, dd, th, ho, sh, spotlight1, spotlight2
                            , price_point, unit_point, age_point, list_point, station_point, expressway_point, realist_score, url_tag, cover
                            , redirect, pageview, status, create_by, create_date, update_by, update_date))
        count += 1
        if count % 800 == 0:
            print(f"Prepare {count}")

    insert = "insert into housing (Housing_Code, Housing_Name, Housing_ENName, Brand_Code, Developer_Code, Housing_Latitude, Housing_Longitude\
            , Coordinate_Mark, Housing_ScopeArea, Road_Name, Postal_Code, SubDistrict_ID, District_ID, Province_ID, Address_Mark\
            , RealSubDistrict_Code, RealDistrict_Code, Housing_LandRai, Housing_LandNgan, Housing_LandWa, Housing_TotalRai\
            , Housing_Floor_Min, Housing_Floor_Max , Housing_TotalUnit, Housing_Area_Min, Housing_Area_Max, Housing_Usable_Area_Min\
            , Housing_Usable_Area_Max, Bedroom_Min, Bedroom_Max, Bathroom_Min, Bathroom_Max, Housing_Price_Min, Housing_Price_Max\
            , Housing_Price_Date, Housing_Built_Start, Housing_Built_Finished, Housing_Sold_Status_Raw_Number, Housing_Sold_Status_Date\
            , Housing_Parking_Min, Housing_Parking_Max, Housing_Common_Fee_Min, Housing_Common_Fee_Max, IS_SD, IS_DD, IS_TH, IS_HO, IS_SH\
            , Housing_Spotlight_1, Housing_Spotlight_2, Price_Min_Point, No_of_Unit_Point, Age_Point, ListCompany_Point\
            , DistanceFromStation_Point, DistanceFromExpressway_Point, Realist_Score, Housing_URL_Tag, Housing_Cover, Housing_Redirect\
            , Housing_Pageviews, Housing_Status, Created_By, Created_Date, Last_Updated_By, Last_Updated_Date)\
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,\
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,\
                %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
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
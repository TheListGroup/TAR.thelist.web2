import Levenshtein as lev
import pandas as pd
from math import radians, sin, cos, sqrt, atan2
import csv
import mysql.connector
import re

def haversine(lat1, lon1, lat2, lon2):
    R = 6371.0

    lat1_rad = radians(lat1)
    lon1_rad = radians(lon1)
    lat2_rad = radians(lat2)
    lon2_rad = radians(lon2)

    dlat = lat2_rad - lat1_rad
    dlon = lon2_rad - lon1_rad

    a = sin(dlat / 2)**2 + cos(lat1_rad) * cos(lat2_rad) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    distance = R * c
    return distance

scrap_data = pd.read_csv(r"C:\PYTHON\TAR.thelist.web2\scrap webhome\list_condo.csv", encoding='utf-8')
file_name = r"C:\PYTHON\TAR.thelist.web2\scrap webhome\match1.csv"

#host = '127.0.0.1'
#user = 'real-research'
#password = 'shA0Y69X06jkiAgaX&ng'

host = '159.223.76.99'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

agent = 'Web Home'
sql = False
match_list = []
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

        all_data = "SELECT Condo_Code, \
                            REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(condo_name),' ',''),'-',''),\"'\",''),'@',''),'minium',''),'condo',''),'\\\\.',''),'\\\\)',''),'\\\\(',''),'/','') as use_name, \
                            Condo_Latitude,\
                            Condo_Longitude\
                    FROM (SELECT cpc.Condo_Code, \
                                IF(Condo_ENName1 IS NOT NULL, CONCAT(SUBSTRING_INDEX(Condo_ENName1,'\n',1),' ',SUBSTRING_INDEX(Condo_ENName1,'\n',-1)), Condo_ENName2) AS condo_name, \
                                cpc.Condo_Latitude,\
                                cpc.Condo_Longitude\
                            FROM real_condo AS cpc \
                            LEFT JOIN (SELECT Condo_Code AS Condo_Code1, Condo_ENName AS Condo_ENName1 FROM real_condo WHERE Condo_ENName LIKE '%\n%') real_condo1 ON cpc.Condo_Code = real_condo1.Condo_Code1 \
                            LEFT JOIN (SELECT Condo_Code AS Condo_Code2, Condo_ENName AS Condo_ENName2 FROM real_condo WHERE Condo_ENName NOT LIKE '%\n%' AND Condo_ENName NOT LIKE '%\r%') real_condo2 ON cpc.Condo_Code = real_condo2.Condo_Code2 \
                            WHERE cpc.Condo_Status = 1 \
                            and cpc.Condo_Latitude is not null\
                            and cpc.Condo_Longitude is not null\
                            ORDER BY cpc.Condo_Code) aaa"
        cursor.execute(all_data)
        real = cursor.fetchall()
        
        sql = True

except Exception as e:
    print(f'Error: {e}')

if sql:
    use_project_list = []
    for i in range(scrap_data.index.size):
        code = scrap_data.iloc[i, 0]
        update_date = scrap_data.iloc[i, 1]
        th_name = scrap_data.iloc[i, 2]
        name = scrap_data.iloc[i, 3]
        link = scrap_data.iloc[i, 4]
        lat = scrap_data.iloc[i, 5]
        long = scrap_data.iloc[i, 6]
        use_project_list.append((str(code),th_name,name,str(lat),str(long),update_date,link))

    query = """INSERT INTO classified_project_staging (Project_ID, Name_TH, Name_ENG, Latitude, Longitude, Last_Updated_Date, Created_Date) 
            VALUES (%s, %s, %s, %s, %s, %s, %s)"""
    val = use_project_list
    try:
        cursor.executemany(query,val)
        connection.commit()
    except Exception as e:
        print(f'Error: {e} at classified_project_staging')

    query = """select Ref_ID
                    , Project_ID
                    , Name_TH
                    , Name_ENG
                    , Latitude
                    , Longitude
                    , Created_Date
                    , Last_Updated_Date 
                from (select cp.Ref_ID
                            , cp.Project_ID
                            , cp.Name_TH
                            , cp.Name_ENG
                            , cp.Latitude
                            , cp.Longitude
                            , cp.Created_Date
                            , cp.Last_Updated_Date
                            , m.Project_ID as proj_match
                            , n.Project_ID as proj_not_match
                        from classified_project_staging cp
                        left join (select Project_ID from classified_match where Agent = "Web Home") m on cp.Project_ID = m.Project_ID
                        left join (select Project_ID from classified_not_match where Agent = "Web Home") n on cp.Project_ID = n.Project_ID) c
                where proj_match is null
                and proj_not_match is null"""
    try:
        more_work = False
        cursor.execute(query)
        new_project = cursor.fetchall()
        if len(new_project) > 0:
            more_work = True
        else:
            more_work = False
    except Exception as e:
        print(f'Error: {e} at check_new_project')
    
    if more_work:
        data_list = []
        new_project_insert = []
        insert = 0
        for i in new_project:
            found = False
            near_list = []
            distance_list = []
            code = i[1]
            update_date = i[7]
            th_name = i[2]
            name = i[3].lower().replace(" ","").replace("-","").replace("'","").replace("(","").replace(")","").replace("@","").replace("minium","").replace("condo","").replace("/","").strip()
            link = i[6]
            lat = i[4]
            long = i[5]
            number_new = re.findall(r'\d+', name)
            if len(number_new) > 0:
                number_in_name_new = number_new[-1]
            else:
                number_in_name_new = 0
            
            best_ratio = 0
            for y in real:
                name_realist = y[1]
                ratio = lev.ratio(name, name_realist)
                if ratio == 1 :
                    best_ratio = ratio
                    best_condo_code = y[0]
                    new_project_insert.append((agent,code,best_condo_code))
                    insert += 1
                    found = True
                    break
                else:
                    best_ratio = ratio
                    best_word = name_realist
                    best_condo_code = y[0]
                    best_latitude = y[2]
                    best_longitude = y[3]
                    distance_list.append((best_condo_code, best_word, best_latitude, best_longitude, best_ratio))
            
            if not found:
                found2 = False
                for x in distance_list:
                    realist_lat = x[2]
                    realist_long = x[3]
                    distance = haversine(lat, long, realist_lat, realist_long)
                    if distance < 1.5:
                        near_list.append((x[0],x[1],x[2],x[3],x[4],distance))
                sorted_data = sorted(near_list, key=lambda x: x[4], reverse=True)
                near_list = sorted_data[:5]
                
                if len(sorted_data) > 0:
                    for x, data_in in enumerate(near_list):
                        score = data_in[4]
                        realist_name = data_in[1]
                        number_old = re.findall(r'\d+', realist_name)
                        if len(number_old) > 0:
                            number_in_name_old = number_old[-1]
                        else:
                            number_in_name_old = 0
                        if (score > 0.94 and number_in_name_old == number_in_name_new)\
                            or (number_in_name_new == '1' and number_in_name_old == 0 and score > 0.9)\
                            or (number_in_name_new == 0 and number_in_name_old == '1' and score > 0.9)\
                            or (score > 0.9 and len(number_new) == 1 and len(number_old) == 1 and number_in_name_old == number_in_name_new)\
                            or (score > 0.92 and len(number_new) == 0 and len(number_old) == 0):
                            new_project_insert.append((agent,code,data_in[0]))
                            insert += 1
                            found2 = True
                            break
                if not found2:
                    use_list = (code, update_date, th_name, link, lat, long, name)
                    for data in near_list:
                        use_list = use_list + (data[1],data[0],data[4],data[2],data[3],data[5])
                    data_list.append(use_list)

        header = ['Condo_ID', 'Condo_Update', 'TH_Name', 'Link', 'Latitude', 'Longitude', 'Eng_Name', 'realist_Eng_Name', 'Condo_Code', 'Name_Point'
                , 'realist_Latitude', 'realist_Longitude', 'Distance', 'realist_Eng_Name2', 'Condo_Code2', 'Name_Point2', 'realist_Latitude2'
                , 'realist_Longitude2', 'Distance2', 'realist_Eng_Name3', 'Condo_Code3', 'Name_Point3', 'realist_Latitude3', 'realist_Longitude3'
                , 'Distance3', 'realist_Eng_Name4', 'Condo_Code4', 'Name_Point4', 'realist_Latitude4', 'realist_Longitude4', 'Distance4'
                , 'realist_Eng_Name5', 'Condo_Code5', 'Name_Point5', 'realist_Latitude5', 'realist_Longitude5', 'Distance5', 'msg', 'old_condo']
        with open(file_name, mode="w", newline="", encoding='utf-8') as file:
                writer = csv.writer(file)
                writer.writerow(header)
                writer.writerows(data_list)
        
        if len(new_project_insert) > 0:
            query = """INSERT INTO classified_match (Agent, Project_ID, Condo_Code) 
                    VALUES (%s, %s, %s)"""
            val = new_project_insert
            try:
                cursor.executemany(query,val)
                connection.commit()
            except Exception as e:
                print(f'Error: {e} at Insert_new_project')
            
            query = """INSERT INTO realist_log (Type, SQL_State, Message, Location)
                    VALUES (%s, %s, %s, %s)"""
            val = (0, '00000', f'Insert {insert} Rows', 'WebHome_Insert_Match_Project')
            try:
                cursor.execute(query,val)
                connection.commit()
            except Exception as e:
                print(f'Error: {e} at WebHome_Insert_log')
    
    query = """DELETE FROM classified_project_staging"""
    try:
        cursor.execute(query)
        connection.commit()
    except Exception as e:
        print(f'Error: {e} at Delete_classified_project_staging')
    
    cursor.close()
    connection.close()
    print('Connection closed')
print("Done")
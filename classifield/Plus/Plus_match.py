import mysql.connector
import json
import Levenshtein as lev
import csv
import math

#project_path = r'C:\PYTHON\TAR.thelist.web2\classifield\Plus\Plus_PROJECT.json'
#csv_path = r'C:\PYTHON\TAR.thelist.web2\classifield\Plus\Plus_Match.csv'

project_path = r'/home/gitdev/ta_python/classifield/Plus/Plus_PROJECT.json'
csv_path = r"/home/gitdev/ta_python/classifield/Plus/Plus_Match.csv"

#project_path = r'/home/gitprod/ta_python/classifield/Plus/Plus_PROJECT.json'
#csv_path = r"/home/gitprod/ta_python/classifield/Plus/Plus_Match.csv"

host = '157.230.242.204'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

#host = '127.0.0.1'
#user = 'real-research'
#password = 'shA0Y69X06jkiAgaX&ng'

agent = 'Plus'
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
                            condo_name, \
                            REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(REGEXP_REPLACE(LOWER(condo_name),' ',''),'-',''),\"'\",''),'@',''),'minium',''),'condo',''),'\\\\.',''),'\\\\)',''),'\\\\(','') as use_name, \
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
        result = cursor.fetchall()

        sql = True

except Exception as e:
    print(f'Error: {e}')

#เอาแค่ project ที่มีห้อง
project_list = []
if sql:
    with open(project_path, 'r', encoding='utf-8') as json_file:
        project_data = json.load(json_file)
        for project in project_data:
            project = tuple(project.values())
            project_list.append(project)

#ตัด id:0 ออก เผื่อมี
i = 0
while i in range(len(project_list)):
    check_proj_id = project_list[i][1]
    if check_proj_id == None:
        project_list.pop(i)
    i += 1

#เอาเข้าตารางทด
query = """INSERT INTO classified_project_staging (Project_ID, Name_TH, Name_ENG, Latitude, Longitude, Created_Date, Last_Updated_Date) 
        VALUES (%s, %s, %s, %s, %s, %s, %s)"""
val = project_list
try:
    cursor.executemany(query,val)
    connection.commit()
except Exception as e:
    print(f'Error: {e} at classified_project_staging')

#คัดแค่ project ที่ไม่เคยมี
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
                    left join (select Project_ID from classified_match) m on cp.Project_ID = m.Project_ID
                    left join (select Project_ID from classified_not_match) n on cp.Project_ID = n.Project_ID) c
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
    insert = 0
    new_project_insert = []
    for i in new_project:
        name = i[3].lower().replace(" ","").replace("-","").replace("'","").replace("(","").replace(")","").replace("@","").replace("minium","").replace("condo","").strip()
        project_id = i[1]
        nameTH = i[2]
        nameEN = i[3]
        latitude = i[4]
        longitude = i[5]
        created_date = i[6]
        last_updated_date = i[7]

        best_ratio = 0
        best_distance_1 = 100
        best_distance_2 = 100
        best_distance_3 = 100
        best_distance_4 = 100
        best_distance_5 = 100
        best_word_1 = ""
        best_word_2 = ""
        best_word_3 = ""
        best_word_4 = ""
        best_word_5 = ""
        best_condo_code_1 = ""
        best_condo_code_2 = ""
        best_condo_code_3 = ""
        best_condo_code_4 = ""
        best_condo_code_5 = ""
        best_condo_name_1 = ""
        best_condo_name_2 = ""
        best_condo_name_3 = ""
        best_condo_name_4 = ""
        best_condo_name_5 = ""

        for j in result:
            #match ชื่อครั้งแรก
            best_condo = []
            ratio = lev.ratio(name, j[2])
            try:
                distance = math.sqrt(((latitude - j[3])**2)+((longitude - j[4])**2))
            except:
                distance = 100
            if (ratio == 1):
                best_condo_code = j[0]
                new_project_insert.append((agent,project_id,best_condo_code))
                insert += 1
                break
            elif (ratio > best_ratio):
                best_ratio = ratio
                best_word = j[2]
                best_condo_code = j[0]
                condo_name = j[1]
                best_latitude = j[3]
                best_longitude = j[4]
            try:
                #match พิกัด
                if (distance < best_distance_1):
                    best_distance_5 = best_distance_4
                    best_condo_name_5 = best_condo_name_4
                    best_word_5 = best_word_4
                    best_condo_code_5 = best_condo_code_4
                    best_distance_4 = best_distance_3
                    best_condo_name_4 = best_condo_name_3
                    best_word_4 = best_word_3
                    best_condo_code_4 = best_condo_code_3
                    best_distance_3 = best_distance_2
                    best_condo_name_3 = best_condo_name_2
                    best_word_3 = best_word_2
                    best_condo_code_3 = best_condo_code_2
                    best_distance_2 = best_distance_1
                    best_condo_name_2 = best_condo_name_1
                    best_word_2 = best_word_1
                    best_condo_code_2 = best_condo_code_1
                    best_distance_1 = distance
                    best_condo_name_1 = j[1]
                    best_word_1 = j[2]
                    best_condo_code_1 = j[0]
                elif (distance < best_distance_2):
                    best_distance_5 = best_distance_4
                    best_condo_name_5 = best_condo_name_4
                    best_word_5 = best_word_4
                    best_condo_code_5 = best_condo_code_4
                    best_distance_4 = best_distance_3
                    best_condo_name_4 = best_condo_name_3
                    best_word_4 = best_word_3
                    best_condo_code_4 = best_condo_code_3
                    best_distance_3 = best_distance_2
                    best_condo_name_3 = best_condo_name_2
                    best_word_3 = best_word_2
                    best_condo_code_3 = best_condo_code_2
                    best_distance_2 = distance
                    best_condo_name_2 = j[1]
                    best_word_2 = j[2]
                    best_condo_code_2 = j[0]
                elif (distance < best_distance_3):
                    best_distance_5 = best_distance_4
                    best_condo_name_5 = best_condo_name_4
                    best_word_5 = best_word_4
                    best_condo_code_5 = best_condo_code_4
                    best_distance_4 = best_distance_3
                    best_condo_name_4 = best_condo_name_3
                    best_word_4 = best_word_3
                    best_condo_code_4 = best_condo_code_3
                    best_distance_3 = distance
                    best_condo_name_3 = j[1]
                    best_word_3 = j[2]
                    best_condo_code_3 = j[0]
                elif (distance < best_distance_4):
                    best_distance_5 = best_distance_4
                    best_condo_name_5 = best_condo_name_4
                    best_word_5 = best_word_4
                    best_condo_code_5 = best_condo_code_4
                    best_distance_4 = distance
                    best_condo_name_4 = j[1]
                    best_word_4 = j[2]
                    best_condo_code_4 = j[0]
                elif (distance < best_distance_5):
                    best_distance_5 = distance
                    best_condo_name_5 = j[1]
                    best_word_5 = j[2]
                    best_condo_code_5 = j[0]
            except:
                pass

        best_condo.extend([(best_condo_code_1,best_condo_name_1,best_word_1),(best_condo_code_2,best_condo_name_2,best_word_2)
                            ,(best_condo_code_3,best_condo_name_3,best_word_3),(best_condo_code_4,best_condo_name_4,best_word_4)
                            ,(best_condo_code_5,best_condo_name_5,best_word_5)])

        ratio_best = 0
        ratio_best_1 = 0
        ratio_best_2 = 0
        ratio_best_3 = 0
        ratio_best_4 = 0
        ratio_best_5 = 0
        #match ชื่อจาก 5 โครงการที่ใกล้ที่สุด เรียงจากคะแนนมากไปน้อย
        for k in best_condo:
            ratio_best = lev.ratio(name, k[2])
            if (ratio_best > ratio_best_1):
                ratio_best_5 = ratio_best_4
                best_condo_name_5 = best_condo_name_4
                best_condo_code_5 = best_condo_code_4
                ratio_best_4 = ratio_best_3
                best_condo_name_4 = best_condo_name_3
                best_condo_code_4 = best_condo_code_3
                ratio_best_3 = ratio_best_2
                best_condo_name_3 = best_condo_name_2
                best_condo_code_3 = best_condo_code_2
                ratio_best_2 = ratio_best_1
                best_condo_name_2 = best_condo_name_1
                best_condo_code_2 = best_condo_code_1
                ratio_best_1 = ratio_best
                best_condo_name_1 = k[1]
                best_condo_code_1 = k[0]
            elif (ratio_best > ratio_best_2):
                ratio_best_5 = ratio_best_4
                best_condo_name_5 = best_condo_name_4
                best_condo_code_5 = best_condo_code_4
                ratio_best_4 = ratio_best_3
                best_condo_name_4 = best_condo_name_3
                best_condo_code_4 = best_condo_code_3
                ratio_best_3 = ratio_best_2
                best_condo_name_3 = best_condo_name_2
                best_condo_code_3 = best_condo_code_2
                ratio_best_2 = ratio_best
                best_condo_name_2 = k[1]
                best_condo_code_2 = k[0]
            elif (ratio_best > ratio_best_3):
                ratio_best_5 = ratio_best_4
                best_condo_name_5 = best_condo_name_4
                best_condo_code_5 = best_condo_code_4
                ratio_best_4 = ratio_best_3
                best_condo_name_4 = best_condo_name_3
                best_condo_code_4 = best_condo_code_3
                ratio_best_3 = ratio_best
                best_condo_name_3 = k[1]
                best_condo_code_3 = k[0]
            elif (ratio_best > ratio_best_4):
                ratio_best_5 = ratio_best_4
                best_condo_name_5 = best_condo_name_4
                best_condo_code_5 = best_condo_code_4
                ratio_best_4 = ratio_best
                best_condo_name_4 = k[1]
                best_condo_code_4 = k[0]
            elif (ratio_best > ratio_best_5):
                ratio_best_5 = ratio_best
                best_condo_name_5 = k[1]
                best_condo_code_5 = k[0]

        if ratio < 1:
            match_data = [project_id, nameTH, nameEN, latitude, longitude, created_date, last_updated_date, name, best_word
                        , best_condo_code, condo_name, best_latitude, best_longitude, best_ratio, best_condo_code_1, best_condo_name_1
                        , best_condo_code_2, best_condo_name_2, best_condo_code_3, best_condo_name_3, best_condo_code_4, best_condo_name_4
                        , best_condo_code_5, best_condo_name_5]
            match_list.append(match_data)

    #save to csv
    header = ['BC_Project_ID', 'nameTH', 'nameEN', 'latitude', 'longitude', 'created_date', 'last_updated_date', 'name_use'
            , 'real_name_use', 'Condo_Code', 'Condo_Name', 'Condo_Latitude', 'Condo_Longitude', 'best_ratio', 'Condo_Code_1'
            , 'Condo_Full_Name_1', 'Condo_Code_2', 'Condo_Full_Name_2', 'Condo_Code_3', 'Condo_Full_Name_3', 'Condo_Code_4'
            , 'Condo_Full_Name_4', 'Condo_Code_5', 'Condo_Full_Name_5', 'msg', 'Old_Condo']
    with open(csv_path, mode="w", newline="", encoding='utf-8') as file:
        writer = csv.writer(file)
        writer.writerow(header)
        writer.writerows(match_list)

    #เอาคะแนน1 เข้า table match
    if len(new_project_insert) > 0:
        query = """INSERT INTO classified_match (Agent, Project_ID, Condo_Code) 
                VALUES (%s, %s, %s)"""
        val = new_project_insert
        try:
            cursor.executemany(query,val)
            connection.commit()
        except Exception as e:
            print(f'Error: {e} at Insert_new_project')

    #save log
        query = """INSERT INTO realist_log (Type, SQL_State, Message, Location)
                VALUES (%s, %s, %s, %s)"""
        val = (0, '00000', f'Insert {insert} Rows', 'Plus_Insert_Match_Project')
        try:
            cursor.execute(query,val)
            connection.commit()
        except Exception as e:
            print(f'Error: {e} at Plus_Insert_log')

#truncated table classified_project_staging
query = """DELETE FROM classified_project_staging"""
try:
    cursor.execute(query)
    connection.commit()
except Exception as e:
    print(f'Error: {e} at Delete_classified_project_staging')

cursor.close()
connection.close()
print('Connection closed')
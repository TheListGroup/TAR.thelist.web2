import mysql.connector
import pandas as pd
from datetime import datetime

classified_file = pd.read_csv(r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\propertyhub\classified_all_rent.csv", encoding='utf-8')
condo_link = pd.read_csv(r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\propertyhub\all_link.csv", encoding='utf-8')

#host = '127.0.0.1'
#user real-research
#password = 'shA0Y69X06jkiAgaX&ng'

host = '159.223.76.99'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

agent = 'PropertyHub'
sql = False
log = False
user_id = 2
check_project_list = []
project_list = []
classified_list = []
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
    query_match = f"SELECT Project_ID, Condo_Code FROM `classified_match` where Agent = '{agent}'"
    cursor.execute(query_match)
    result_match = {row[0]: row for row in cursor.fetchall()}
    
    query_proj = f"SELECT Project_ID FROM `condo_price_other_web` where User_ID = {user_id} group by Project_ID"
    cursor.execute(query_proj)
    for data in cursor.fetchall():
        check_project_list.append(data[0])
    
    condo_dict = {row['Condo_ID']: tuple(row) for _, row in condo_link.iterrows()}
    
    for i in range(classified_file.index.size):
        use_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        proj_id = classified_file.iat[i,0]
        classified = result_match.get(str(proj_id))
        if classified and pd.notna(classified_file.iat[i,1]):
            proj = condo_dict.get(proj_id)
            condo_code = classified[1]
            condo_date = datetime.strptime(proj[1].split(' ')[0], '%m/%d/%y')
            condo_update = condo_date.strftime('%Y-%m-%d')
            ref_id = str(int(classified_file.iat[i,1]))
            sale = classified_file.iat[i,2]
            rent = classified_file.iat[i,3]
            if pd.notna(classified_file.iat[i,4]):
                sale_price = int(classified_file.iat[i,4])
            else:
                sale_price = None
            
            if pd.notna(classified_file.iat[i,5]):
                sale_rent = int(classified_file.iat[i,5])
            else:
                sale_rent = None
            
            if pd.notna(classified_file.iat[i,6]):
                bedroom = int(classified_file.iat[i,6])
            else:
                bedroom = None
            
            if pd.notna(classified_file.iat[i,7]):
                bathroom = int(classified_file.iat[i,7])
            else:
                bathroom = None
            
            if pd.notna(classified_file.iat[i,8]):
                size = float(classified_file.iat[i,8])
            else:
                size = None
            classified_format_date = datetime.strptime(classified_file.iat[i,9].split(' ')[0], '%m/%d/%y')
            classified_date = classified_format_date.strftime('%Y-%m-%d')
            if sale_price != None:
                classified_list.append((str(proj_id), ref_id, int(sale), int(rent), sale_price, sale_rent, bedroom, bathroom, size
                                        , classified_date, '1', user_id, 32, use_date, 32 ,use_date))
            if sale_rent != None:
                classified_list.append((str(proj_id), ref_id, int(sale), int(rent), sale_price, sale_rent, bedroom, bathroom, size
                                        , classified_date, '1', user_id, 32, use_date, 32 ,use_date))
            if str(proj_id) not in check_project_list:
                check_project_list.append(str(proj_id))
                project_list.append((str(proj_id), condo_code, condo_update, '1', user_id, 32, use_date, 32, use_date, 1))
        
        if i % 10000 == 0:
            print(f'Row {i} Done')
    
    if len(project_list) > 0:
        log = False
        query = """insert into condo_price_other_web (Project_ID, Condo_Code, Lastest_Update, Project_Status, User_ID
                , Created_By, Created_Date, Last_Updated_By, Last_Updated_Date, Run_Count)
                values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
        val = project_list
        try:
            cursor.executemany(query,val)
            connection.commit()
            log = True
        except Exception as e:
            print(f'Error: {e} at {agent}_Insert_condo_price_other_web')
    
    if len(classified_list) > 0:
        log = False
        query = """insert into classified_other_web (Project_ID, Ref_ID, Sale, Rent, Price_Sale, Price_Rent, Bedroom, Bathroom, Size, Classified_Date
                , Classified_Status, User_ID, Created_By, Created_Date, Last_Updated_By, Last_Updated_Date)
                values (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
        val = classified_list
        try:
            cursor.executemany(query,val)
            connection.commit()
            log = True
        except Exception as e:
            print(f'Error: {e} at {agent}_Insert_classified_other_web')
    
    if log:
        query = """INSERT INTO realist_log (Type, SQL_State, Message, Location)
                VALUES (%s, %s, %s, %s)"""
        val = (0, '00000', f'Insert_condo {len(project_list)} Rows and Insert_classified {len(classified_list)} Rows', f'{agent}_classified_other_web')
        try:
            cursor.execute(query,val)
            connection.commit()
        except Exception as e:
            print(f'Error: {e} at Insert_log')
    
cursor.close()
connection.close()
print('Done -- Connection closed')
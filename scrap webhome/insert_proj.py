import pandas as pd
import mysql.connector

csv_path = r"C:\PYTHON\TAR.thelist.web2\scrap webhome\match1.csv"

#host = '127.0.0.1'
#user real-research
#password = 'shA0Y69X06jkiAgaX&ng'

host = '159.223.76.99'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

real = pd.read_csv(csv_path, encoding='utf-8')
agent = 'Web Home'
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
    
except Exception as e:
    print(f'Error: {e}')

match_list = []
not_match_list = []
m = 0
n = 0
for i in range(real.index.size):
    proj_id = real.iat[i,0]
    condo_code = real.iat[i,8]
    msg = real.iat[i,37]
    old = real.iat[i,38]

    if pd.notna(real.iat[i,8]):
        match_list.append((agent,str(proj_id),condo_code))
        m += 1
    elif pd.notna(real.iat[i,37]):
        not_match_list.append((agent,str(proj_id),msg,0))
        n += 1
    elif pd.notna(real.iat[i,38]):
        msg = None
        not_match_list.append((agent,str(proj_id),msg,1))
        n += 1

if len(match_list) > 0:
    log = False
    insert = "INSERT INTO classified_match (Agent, Project_ID, Condo_Code)\
            VALUES (%s, %s, %s)"
    val = match_list
    try:
        cursor.executemany(insert,val)
        connection.commit()
        log = True
    except Exception as e:
        print(f'Error: {e} at Insert_Match')

if len(not_match_list) > 0:
    log = False
    insert = "INSERT INTO classified_not_match (Agent, Project_ID, msg, Old_Condo)\
            VALUES (%s, %s, %s, %s)"
    val = not_match_list
    try:
        cursor.executemany(insert,val)
        connection.commit()
        log = True
    except Exception as e:
        print(f'Error: {e} at Insert_Not_Match')

if log:
    query = """INSERT INTO realist_log (Type, SQL_State, Message, Location)
            VALUES (%s, %s, %s, %s)"""
    val = (0, '00000', f'Insert_Match {m} Rows and Insert_Not_Match {n} Rows', 'WebHome_Insert_Project_After_Manual')
    try:
        cursor.execute(query,val)
        connection.commit()
    except Exception as e:
        print(f'Error: {e} at Insert_log')

cursor.close()
connection.close()
print('Done -- Connection closed')
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import mysql.connector
import time
from datetime import datetime

#json_file = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\realist\update_data\access.json"
json_file = r"/home/gitprod/ta_python/update_data/access.json"

scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name(json_file, scope)
client = gspread.authorize(creds)
spreadsheet = client.open_by_url('https://docs.google.com/spreadsheets/d/1nELi_Xn0NhqoLWa1XVDlzUxGVT7yb_HBvBd0Qclfv1E')
print('Connect to GoogleSheet')

#host = '159.223.76.99'
#user = 'real-research2'
#password = 'DQkuX/vgBL(@zRRa'

host = '127.0.0.1'
user = 'real-research'
password = 'shA0Y69X06jkiAgaX&ng'

sql = False
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

def work_process(sheet_name,table,column_update,x,work,cursor,connection):
    sheet = spreadsheet.worksheet(sheet_name)
    data = sheet.get_all_values()
    headers = data[0]  # แถวชื่อคอลัมน์
    rows = data[1:]
    update = 0
    insert = 0
    enum_column = ['Condo_Build_Date','Resale','Special','Price_Status']
    for row_index, row in enumerate(rows, start=2):  # start=2 เพราะ Google Sheet เริ่มที่แถว 1, headers อยู่แถว 1
        if row[-1] != 'Y' and row[0]:
            code = row[0]
            code_column = headers[0]
            set_clauses = []
            for idx in range(4, len(headers) - 1):  # ข้ามคอลัมน์ 0–3 และสุดท้าย (Done)
                value = row[idx]
                col_name = headers[idx]
                raw_value = value.strip().replace(',', '')
                if col_name in enum_column and sheet_name == 'insert Condo Price':
                    set_clauses.append(f"'{value.strip()}'")
                else:
                    if raw_value != '' and work == 'update':
                        try:
                            float_val = float(raw_value)
                            set_clauses.append(f"{col_name} = {float_val}")
                        except ValueError:
                            set_clauses.append(f"{col_name} = '{value.strip()}'")
                    elif work == 'insert':
                        try:
                            float_val = float(raw_value)
                            set_clauses.append(f"{float_val}")
                        except ValueError:
                            if value.strip() != '':
                                set_clauses.append(f"'{value.strip()}'")
                            else:
                                set_clauses.append("NULL")
            
            if set_clauses:
                code_sql  = f"'{code}'"
                if work == 'update':
                    update_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
                    set_clauses.append(f"{column_update} = '{update_time}'")
                    set_part = ", ".join(set_clauses)
                    query = f"UPDATE {table} SET {set_part} WHERE {code_column} = {code_sql};"
                    update += 1
                else:
                    set_part = ", ".join([code_sql] + set_clauses)
                    query = f"INSERT INTO {table} ({', '.join([headers[0]]+headers[4:-1])}) VALUES ({set_part});"
                    insert += 1
                cursor.execute(query)
                connection.commit()
                
                # เขียน 'Y' กลับไปที่คอลัมน์ Done
                done_col = len(headers)  # คอลัมน์สุดท้าย (index + 1 เพราะ gspread ใช้ 1-based index)
                sheet.update_cell(row_index, done_col, 'Y')
                #sheet.update_cell(row_index, done_col, query)
                x += 1
                if x % 50 == 0 and x > 0:
                    time.sleep(120)
    if update > 0:
        query = """INSERT INTO realist_log (Type, SQL_State, Message, Location)
                VALUES (%s, %s, %s, %s)"""
        val = (0, '00000', f'Update {update} Rows', f'{sheet_name}_update')
        cursor.execute(query,val)
        connection.commit()
    if insert > 0:
        query = """INSERT INTO realist_log (Type, SQL_State, Message, Location)
                VALUES (%s, %s, %s, %s)"""
        val = (0, '00000', f'Insert {insert} Rows', f'{sheet_name}_insert')
        cursor.execute(query,val)
        connection.commit()
    return x

if sql:
    x = 0
    sheet_name = ['update Housing','update Condo','insert Condo Price','update Condo Date', 'insert Condo 561']
    table_name = ['housing','real_condo','real_condo_price_new','real_condo_price', 'real_condo_561']
    column_updatetime = ['Last_Updated_Date','Condo_LastUpdate','Last_Updated_Date','Date_LastUpdate','Data_Update_Date']

    for i, sheet in enumerate(sheet_name):
        if i != 2 and i != 4:
            work = 'update'
        else:
            work = 'insert'
        x = work_process(sheet,table_name[i],column_updatetime[i],x,work,cursor,connection)
        print(f'{sheet} Done')
print('DONE')
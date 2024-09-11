import gspread
from oauth2client.service_account import ServiceAccountCredentials
import mysql.connector
import time
from datetime import datetime
from googleapiclient.discovery import build

#json_file = r"C:\PYTHON\TAR.thelist.web2\contact_form\access.json"
json_file = r"/home/gitprod/ta_python/contact_form/access.json"

scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name(json_file, scope)
client = gspread.authorize(creds)
spreadsheet = client.open_by_url('https://docs.google.com/spreadsheets/d/1mhVZCWvkWZRxvHhdh76NwaRgvoIPhLV09JfH0WB55NI')
service = build('sheets', 'v4', credentials=creds)
print('Connect to GoogleSheet')

#host = '157.230.242.204'
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

def check_null(variable,i):
    if variable == None:
        variable = ''
    else:
        if i in [1,9,10,12,16]: ##
            variable = int(variable)
        else:
            variable = str(variable).strip()
    return variable

def insert_ggsheet(query):
    column_values = sheet.col_values(24) ##
    column_values = column_values[1:]
    column_values.sort(reverse=True)
    lastest_date = column_values[0]
    
    val = (lastest_date,)
    cursor.execute(query,val)
    new_data = cursor.fetchall()
    
    for j, row in enumerate(new_data):
        rows_to_append = []
        for i, data in enumerate(row):
            if i in [0,23]: ##
                data = data.strftime('%Y-%m-%d %H:%M:%S')
            rows_to_append.append(check_null(data,i))
        if j % 50 == 0 and j > 0:
            time.sleep(120)
        sheet.append_rows([rows_to_append])

def format_date(col):
    date_format = '%Y-%m-%d %H:%M:%S'
    date_object = datetime.strptime(sheet.cell(i+2,col).value, date_format)
    sheet.update_cell(i+2,col,date_object.strftime(date_format))

def color_column():
    color1 = {
            "red": 0.988,
            "green": 0.898,
            "blue": 0.804
        }
    column_index1 = 0 ##
    color2 = {
            "red": 0.851,
            "green": 0.918,
            "blue": 0.827
        }
    column_index2 = 13 ##
    column_list = [column_index1,column_index2]
    color_list = [color1,color2]
    for i, column_color in enumerate(column_list):
        if i == 0:
            end_column = 13 ##
        else:
            end_column = 11 ##
        requests = [
                {
                    "repeatCell": {
                        "range": {
                            "sheetId": 1275005235,
                            "startColumnIndex": column_color,
                            "endColumnIndex": column_color + end_column
                        },
                        "cell": {
                            "userEnteredFormat": {
                                "backgroundColor": color_list[i]
                            }
                        },
                        "fields": "userEnteredFormat.backgroundColor"
                    }
                }
            ]
        body = {
                'requests': requests
            }
        response = service.spreadsheets().batchUpdate(
                spreadsheetId=spreadsheet.id,
                body=body
            ).execute()

def border(z):
    x,y = 0,0
    data_all = sheet.get_all_records()
    while x in range(len(data_all)):
        contact_id_first = data_all[x]["Contact_ID"]
        while y in range(len(data_all)):
            contact_id = data_all[y]["Contact_ID"]
            if contact_id_first != contact_id:
                requests = [
                    {
                        "updateBorders": {
                            "range": {
                                "sheetId": 1275005235, 
                                "startRowIndex": 0,
                                "endRowIndex": x+1, 
                                "startColumnIndex": 0,  
                                "endColumnIndex": 30
                            },
                            "bottom": {
                                "style": "SOLID",  
                                "width": 1,        
                                "color": {
                                    "red": 0,      
                                    "green": 0,
                                    "blue": 0
                                }
                            }
                        }
                    }
                ]
                body = {
                    'requests': requests
                }

                response = service.spreadsheets().batchUpdate(
                    spreadsheetId=spreadsheet.id,
                    body=body
                ).execute()
                if z % 50 == 0 and z > 0:
                    time.sleep(100)
                z += 1
                break
            x += 1
            y += 1

if sql:
    sheet = spreadsheet.worksheet("condo_template_all_email")
    old_records = sheet.get_all_records()
    query = """SELECT rcf.Contact_Date 
                , el.Contact_ID
                , rcf.Contact_Ref_ID as 'คอนโดที่ลงทะเบียน'
                , rc2.Condo_ENName
                , rcf.Contact_Name as 'คนลงทะเบียน'
                , rcf.Contact_Tel
                , rcf.Contact_Email
                , rcf.Contact_Room_Status
                , rcf.Contact_Position
                , cpc.Condo_Price_Per_Square
                , cpc.Condo_Price_Per_Unit
                , if(cpc.Condo_Sold_Status_Show_Value<>'RESALE',round(cpc.Condo_Sold_Status_Show_Value * 100),cpc.Condo_Sold_Status_Show_Value) AS Project_Status
                , if(cpc.Condo_Built_Text <> 'ปีที่เปิดตัว',cpc.Condo_Built_Date,null) as Condo_Built_Finished
                , el.Condo_Code as 'คอนโดที่ส่งให้'
                , rc.Condo_ENName
                , el.Contact_Type
                , el.Dev_Agent_Contact_ID
                , el.Dev_or_Agent
                , el.Company_Name
                , el.Contact_Name
                , el.Email
                , el.Contact_Sent
                , el.Error_Reason
                , el.Contact_Sent_Date
            FROM real_contact_email_log el
            inner join real_condo rc on el.Condo_Code = rc.Condo_Code
            inner join real_contact_form rcf on el.Contact_ID = rcf.Contact_ID
            inner join real_condo rc2 on rcf.Contact_Ref_ID = rc2.Condo_Code
            inner join all_condo_price_calculate cpc on rcf.Contact_Ref_ID = cpc.Condo_Code or rc2.Condo_Redirect = cpc.Condo_Code
            where el.Contact_Sent_Date > %s
            ORDER BY `el`.`Contact_Sent_Date` ASC"""
    insert_ggsheet(query)
    print("Insert Done")
    
    color_column()
    print("Column Color Done")
    time.sleep(100)
    z = 0
    records = sheet.get_all_records()
    for i in range(len(records)):
        if i+1 > len(old_records):
            for col in [1,24]: ##
                format_date(col)
            if z % 25 == 0 and z > 0:
                time.sleep(100)
            z += 1
    print("Format Date Done")
    time.sleep(100)
    
    border(z)
    print("Borders Done")

cursor.close()
connection.close()
print('Done -- Connection closed')
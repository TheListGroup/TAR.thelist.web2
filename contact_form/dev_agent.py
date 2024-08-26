import gspread
from oauth2client.service_account import ServiceAccountCredentials
import mysql.connector
import re

#json_file = r"C:\PYTHON\TAR.thelist.web2\contact_form\access.json"
json_file = r"/home/gitprod/ta_python/contact_form/access.json"

scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name(json_file, scope)
client = gspread.authorize(creds)
spreadsheet = client.open_by_url('https://docs.google.com/spreadsheets/d/1C2GfogSkNSEFPfdUg5YyNteVfzdMeXqz-5sXPV3yTc4')
print('Connect to GoogleSheet')

#-------------------------------------------------------------------------------------------------------------------------------------

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

if sql:
    data_list = []
    sheet = spreadsheet.get_worksheet(1)
    data = sheet.get_all_values()
    for row in data[1:]:
        developer_code = row[1].strip()
        company_name = row[2].strip()
        contact_name = row[3].strip()
        email = re.sub("\n",";",row[6]).strip()
        condo_list = re.sub("\n","",re.sub(r'\d+\s*\.',";",row[7])).strip()
        #print(f"{company_name} -- {contact_name} -- {email} -- {condo_list}")
        data_list.append((developer_code,company_name,contact_name,email,condo_list))
    
    query_check = """select * from real_contact_dev_agent where Company_Name = %s and Contact_Name = %s and Dev_or_Agent = 'D' and Email = %s"""
    
    query_update = """update real_contact_dev_agent set Company_Name = %s, Contact_Name = %s Email = %s"""
    
    for data in data_list:
        company_name,contact_name,email = data[1], data[2], data[3]
        val = (company_name,contact_name,email)
        cursor.execute(query_check,val)
        dev_check = cursor.fetchall()
        
        if len(dev_check) > 0:
            for dev in dev_check:
                company_name_dev,contact_name_dev,email_dev = dev[1], dev[2], dev[4]
                if company_name != company_name_dev or contact_name != contact_name_dev or email != email_dev:
                    cursor.execute(query_update,val)
                    connection.commit()
        else:
            print("INSERT")

cursor.close()
connection.close()
print('Done -- Connection closed')
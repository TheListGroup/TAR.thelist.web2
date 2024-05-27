import gspread
from oauth2client.service_account import ServiceAccountCredentials
import mysql.connector

## ggsheet connect
#json_file = r"C:\PYTHON\TAR.thelist.web2\realist\contract_form\access.json"
json_file = r"/home/gitprod/ta_python/contact_form/access.json"

scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name(json_file, scope)
client = gspread.authorize(creds)
spreadsheet = client.open_by_url('https://docs.google.com/spreadsheets/d/1RTninS_ZUCl4MLDkI8wYZYEBKzJeZ_ocr2JY_q_6txk/edit#gid=0')
print('Connect to GoogleSheet')
#----------------------------------------------------------------------------------------------------------------------------------------------------

## database connect
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
#------------------------------------------------------------------------------------------------------------------------------------------------------
# function
def check_null(variable,i):
    if variable == None:
        variable = ''
    else:
        if i == 9 or i == 10 or i == 12:
            variable = int(variable)
        else:
            variable = str(variable).strip()
    return variable

def insert_ggsheet(query):
    column_values = sheet.col_values(14)
    column_values = column_values[1:]
    column_values.sort(reverse=True)
    lastest_date = column_values[0]
    
    val = (lastest_date,)
    cursor.execute(query,val)
    new_data = cursor.fetchall()
    
    for row in new_data:
        rows_to_append = []
        for i, data in enumerate(row):
            if i == 13:
                data = data.strftime('%Y-%m-%d %H:%M:%S')
            rows_to_append.append(check_null(data,i))
        #print("Data to append:", rows_to_append)
        sheet.append_rows([rows_to_append])
#--------------------------------------------------------------------------------------------------------------------------------------------------
if sql:
    #sheet 1
    sheet = spreadsheet.sheet1
    query = """SELECT rcf.Contact_Ref_ID as Condo_Code
                    , rc.Condo_ENName
                    , cd.Developer_ENName
                    , rcf.Contact_Name
                    , rcf.Contact_Tel
                    , rcf.Contact_Email
                    , rcf.Contact_Room_Status
                    , rcf.Contact_Position
                    , rcf.Contact_Decision_Time
                    , cpc.Condo_Price_Per_Square
                    , cpc.Condo_Price_Per_Unit
                    , if(cpc.Condo_Sold_Status_Show_Value<>'RESALE',round(cpc.Condo_Sold_Status_Show_Value * 100),cpc.Condo_Sold_Status_Show_Value) AS Project_Status
                    , if(cpc.Condo_Built_Text <> 'ปีที่เปิดตัว',cpc.Condo_Built_Date,null) as Condo_Built_Finished
                    , rcf.Contact_Date
                    , rcf.Contact_Link
                FROM real_contact_form rcf
                left join real_condo rc on rcf.Contact_Ref_ID = rc.Condo_Code
                left join condo_developer cd on rc.Developer_Code = cd.Developer_Code
                left join all_condo_price_calculate cpc on rcf.Contact_Ref_ID = cpc.Condo_Code or rc.Condo_Redirect = cpc.Condo_Code
                where rcf.Contact_Ref_ID like 'CD%'
                and rcf.Contact_Date > %s
                ORDER BY rcf.Contact_Date  ASC"""
    insert_ggsheet(query)
    #---------------------------------------------------------------------------------------------------------------------------------------------
    #sheet 2
    sheet = spreadsheet.get_worksheet(1)
    query = """SELECT cu.First_Name
                , rcf.Contact_Ref_ID
                , c.Condo_Code
                , rc.Condo_ENName
                , cd.Developer_ENName
                , rcf.Contact_Name
                , rcf.Contact_Tel
                , rcf.Contact_Email
                , rcf.Contract_Classified_Text
                , cpc.Condo_Price_Per_Square
                , cpc.Condo_Price_Per_Unit
                , if(cpc.Condo_Sold_Status_Show_Value<>'RESALE',round(cpc.Condo_Sold_Status_Show_Value * 100),cpc.Condo_Sold_Status_Show_Value) AS Project_Status
                , if(cpc.Condo_Built_Text <> 'ปีที่เปิดตัว',cpc.Condo_Built_Date,null) as Condo_Built_Finished
                , rcf.Contact_Date
                , rcf.Contact_Link
            FROM real_contact_form rcf
            left join classified c on rcf.Contact_Ref_ID = c.Classified_ID
            left join classified_user cu on c.User_ID = cu.User_ID
            left join real_condo rc on c.Condo_Code = rc.Condo_Code
            left join condo_developer cd on rc.Developer_Code = cd.Developer_Code
            left join all_condo_price_calculate cpc on c.Condo_Code = cpc.Condo_Code or rc.Condo_Redirect = cpc.Condo_Code
            where rcf.Contact_Ref_ID not like 'CD%'
            and c.Classified_Status <> '2'
            and rcf.Contact_Date > %s
            ORDER BY rcf.Contact_Date  ASC"""
    insert_ggsheet(query)
    #-------------------------------------------------------------------------------------------------------------------------------------------------------

cursor.close()
connection.close()
print('Done -- Connection closed')
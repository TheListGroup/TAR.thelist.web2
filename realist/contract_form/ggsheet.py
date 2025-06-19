import gspread
from oauth2client.service_account import ServiceAccountCredentials
import mysql.connector
from datetime import datetime

## ggsheet connect
#json_file = rf"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\realist\contract_form\access.json"
json_file = r"/home/gitprod/ta_python/contact_form/access.json"

scope = ["https://spreadsheets.google.com/feeds", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name(json_file, scope)
client = gspread.authorize(creds)
spreadsheet = client.open_by_url('https://docs.google.com/spreadsheets/d/1mhVZCWvkWZRxvHhdh76NwaRgvoIPhLV09JfH0WB55NI')
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
def check_null(variable,i,table):
    if variable == None:
        variable = ''
    else:
        if table == 'condo':
            if i == 10 or i == 11 or i == 13:
                variable = int(variable)
            else:
                variable = str(variable).strip()
        else:
            if i == 10 or i == 11:
                variable = int(variable)
            else:
                variable = str(variable).strip()
    return variable

def insert_ggsheet(query,table):
    column_values = sheet.col_values(15)
    column_values = column_values[1:]
    if column_values:
        column_values.sort(reverse=True)
        lastest_date = column_values[0]
    else:
        lastest_date = f"{datetime.now().year}-01-01 00:00:00"
    
    val = (lastest_date,)
    cursor.execute(query,val)
    new_data = cursor.fetchall()
    
    for row in new_data:
        rows_to_append = []
        for i, data in enumerate(row):
            if i == 14:
                data = data.strftime('%Y-%m-%d %H:%M:%S')
            rows_to_append.append(check_null(data,i,table))
        #print("Data to append:", rows_to_append)
        sheet.append_rows([rows_to_append])
#--------------------------------------------------------------------------------------------------------------------------------------------------
if sql:
    #sheet 1
    sheet = spreadsheet.worksheet('condo_template')
    query = """SELECT rcf.Contact_ID
                    , rcf.Contact_Ref_ID as Condo_Code
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
                where rcf.Contact_Type = 'contact'
                and rcf.Contact_Date > %s
                ORDER BY rcf.Contact_Date  ASC"""
    insert_ggsheet(query,'condo')
    #---------------------------------------------------------------------------------------------------------------------------------------------
    #sheet 2
    sheet = spreadsheet.worksheet('classified')
    query = """SELECT rcf.Contact_ID
                , cu.First_Name
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
            where rcf.Contact_Type = 'classified'
            and rcf.Contact_Date > %s
            ORDER BY rcf.Contact_Date  ASC"""
    insert_ggsheet(query,'condo')
    #-------------------------------------------------------------------------------------------------------------------------------------------------------
    #sheet 3
    sheet = spreadsheet.worksheet('housing_template')
    query = """SELECT rcf.Contact_ID
                    , rcf.Contact_Ref_ID as Housing_Code
                    , h.Housing_ENName
                    , cd.Developer_ENName
                    , rcf.Contact_Name
                    , rcf.Contact_Tel
                    , rcf.Contact_Email
                    , rcf.Contact_Room_Status
                    , rcf.Contact_Position
                    , rcf.Contact_Decision_Time
                    , h.Housing_Price_Min
                    , h.Housing_Price_Max
                    , h.Housing_Built_Start
                    , h.Housing_Built_Finished
                    , rcf.Contact_Date
                    , rcf.Contact_Link
                FROM real_contact_form rcf
                left join housing h on rcf.Contact_Ref_ID = h.Housing_Code
                left join condo_developer cd on h.Developer_Code = cd.Developer_Code
                where rcf.Contact_Type = 'housingcontact'
                and rcf.Contact_Date > %s
                ORDER BY rcf.Contact_Date  ASC"""
    insert_ggsheet(query,'housing')
    #-------------------------------------------------------------------------------------------------------------------------------------------------------
    #sheet 4
    sheet = spreadsheet.worksheet('housing_classified')
    query = """SELECT rcf.Contact_ID
                , cu.First_Name
                , rcf.Contact_Ref_ID
                , h.Housing_Code
                , h.Housing_ENName
                , cd.Developer_ENName
                , rcf.Contact_Name
                , rcf.Contact_Tel
                , rcf.Contact_Email
                , rcf.Contract_Classified_Text
                , h.Housing_Price_Min
                , h.Housing_Price_Max
                , h.Housing_Built_Start
                , h.Housing_Built_Finished
                , rcf.Contact_Date
                , rcf.Contact_Link
            FROM real_contact_form rcf
            left join housing_classified hc on rcf.Contact_Ref_ID = hc.Classified_ID
            left join classified_user cu on hc.User_ID = cu.User_ID
            left join housing h on hc.Housing_Code = h.Housing_Code
            left join condo_developer cd on h.Developer_Code = cd.Developer_Code
            where rcf.Contact_Type = 'housingclassified'
            and rcf.Contact_Date > %s
            ORDER BY rcf.Contact_Date  ASC"""
    insert_ggsheet(query,'housing')

cursor.close()
connection.close()
print('Done -- Connection closed')
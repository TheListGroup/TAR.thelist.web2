import datetime
from datetime import datetime as tt
import importlib
import sys

SHEET_URL = 'https://docs.google.com/spreadsheets/d/1_ig3t4I-hX8UwJPzAHDLOKqplpU2ekhk3cFrT6BtzdI/export?format=csv'

#head_path = r"C:\PYTHON\TAR.thelist.web2\classifield"
head_path = r"/home/gitdev/ta_python/classifield"
#head_path = r"/home/gitprod/ta_python/classifield"
function_file = 'ggsheet_function'
function_list = ['check_update', 'check_null', 'sale_rent', 'price','insert_log','create_folder_and_remove_image_and_save_image','check_image_url_validity'
                ,'database', 'read_sheet', 'check', 'log_in_database', 'compare_column', 'update_work', 'destination', 'insert_work']
use_list = [None] * len(function_list)
sys.path.append(head_path)
module_name = function_file
module = importlib.import_module(module_name)
for i, function in enumerate(function_list):
    function_name = function_list[i]
    use_list[i] = getattr(module, function_name)
check_update, check_null, sale_rent, price, insert_log, create_folder_and_remove_image_and_save_image, check_image_url_validity, database \
, read_sheet, check, log_in_database, compare_column, update_work, destination, insert_work = use_list

save_folder, json_file = destination('Bridge','bridge.json')
work,sheet = check_update(json_file,'https://docs.google.com/spreadsheets/d/1_ig3t4I-hX8UwJPzAHDLOKqplpU2ekhk3cFrT6BtzdI/edit#gid=0')
host, user, password = log_in_database()

#work = True
user_id = 5

match_list = []
data_list = []
sql = False
upd = 0
insert = 0
stop_processing = False
log = False
row_sheet = 2
if work:
    connection,cursor,sql = database(host,user,password,sql)

if sql:
    data_list = read_sheet(SHEET_URL,data_list)

    if len(data_list) > 0:
        #count = 1
        for data in data_list:
            if stop_processing:
                break
            found = False
            new = True
            if data[5] == 'Condo':
                prop_id = data[1]
                query = """SELECT Ref_ID,Condo_Code,Sale,Sale_with_Tenant,Rent,Price_Sale,Price_Rent,Room_Type,Bedroom,Bathroom,Size 
                        ,Classified_Status,Classified_ID FROM classified WHERE Ref_ID = %s and User_ID = %s Limit 1"""
                stop_processing, column_check = check(stop_processing, query ,prop_id, user_id, cursor, log, upd, insert, connection, 'Bridge')
                if stop_processing:
                    break
                
                title_en = check_null(data[2])
                condo_code = data[0][:6]
                
                content = check_null(data[3])
                near = check_null(data[4])
                if content != None and near != None:
                    des_en = content + '.\n' + near
                elif content != None and near == None:
                    des_en = content
                elif content == None and near != None:
                    des_en = near
                else:
                    des_en = None
                
                size = check_null(data[9])
                sale = sale_rent(data[10])
                rent = sale_rent(data[11])
                price_sale = price(sale,data[10])
                price_rent = price(rent,data[11])
                bedroom = check_null(data[8])
                bathroom = check_null(data[7])
                classified_status = data[14][0]
                last_updated_date = tt.now().strftime('%Y-%m-%d %H:%M:%S')
                create_date = tt.now().strftime('%Y-%m-%d %H:%M:%S')
                folder_url = data[13]
                
                if data[8] == 'Studio':
                    room_type = 'Studio'
                    bedroom = 1
                else:
                    room_type = None
                
                if data[6] == 'TRUE' and sale == 1:
                    sale_with_tenant = 1
                else:
                    sale_with_tenant = 0
                
                insert_date = tt.now().strftime('%Y-%m-%d %H:%M:%S')
                update_insert_date = tt.now().strftime('%Y-%m-%d %H:%M:%S')
                
                #print(f"room {count}")  #####
                #count += 1 #####
                
                #current_time = datetime.datetime.now()
                #print(f"Prepare Data at {current_time}")
                
                if column_check:
                    new = False
                    column_list1 = [prop_id, condo_code, sale, sale_with_tenant, rent, price_sale, price_rent, room_type, bedroom, bathroom, size, classified_status]
                    found = compare_column(column_list1, column_check)
                
                if found:
                    classified_id = column_check[-1]
                    query = """UPDATE classified 
                                SET Title_ENG = %s, Condo_Code = %s, Sale = %s, Sale_with_Tenant = %s, Rent = %s, Price_Sale = %s, Price_Rent = %s
                                , Room_Type = %s, Bedroom = %s, Bathroom = %s, Size = %s, Descriptions_Eng = %s, Classified_Status = %s
                                , Last_Updated_Date = %s, Last_Update_Insert_Date = %s where Ref_ID = %s and User_ID = %s"""
                    val = (title_en, condo_code, sale, sale_with_tenant, rent, price_sale, price_rent, room_type, bedroom, bathroom, size, des_en, classified_status
                        , last_updated_date, update_insert_date, prop_id, user_id)
                    log, upd, stop_processing, row_sheet = update_work(stop_processing, cursor, connection, query, val, folder_url, classified_id, save_folder, log, upd, insert, create_date, last_updated_date, sheet, row_sheet, 'Bridge')
                    if stop_processing:
                        break
                
                elif new:
                    query = "INSERT INTO classified (Ref_ID, Title_ENG, Condo_Code, Sale, Sale_with_Tenant, Rent\
                            , Price_Sale, Price_Rent, Bedroom, Bathroom, Size\
                            , Descriptions_ENG, User_ID, Classified_Status, Created_By, Created_Date\
                            , Last_Updated_By, Last_Updated_Date, Insert_Date)\
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
                    val = (prop_id, title_en, condo_code, sale, sale_with_tenant, rent, price_sale, price_rent
                            , bedroom, bathroom, size, des_en, user_id
                            , classified_status, 32, create_date, 32, last_updated_date, insert_date)
                    log, insert, stop_processing, row_sheet = insert_work(stop_processing, cursor, connection, query, val, prop_id, user_id, folder_url, save_folder, log, upd, insert, create_date, last_updated_date, sheet, row_sheet, 'Bridge')
                    if stop_processing:
                        break
            row_sheet += 1
        
        if log:
            insert_log("Bridge_insert_prop",log,upd,insert,cursor,connection,'')

    cursor.close()
    connection.close()
print(f'Insert {insert} Rows')
print(f'Update {upd} Rows')
print('Connection closed')
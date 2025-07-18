import os
import importlib
import sys

#head_path = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\classifield"
#head_path = r"/home/gitdev/ta_python/classifield"
head_path = r"/home/gitprod/ta_python/classifield"
function_file = 'housing_insert_prop_function'
function_list = ['destination', 'log_in_database', 'database', 'open_proj_json', 'project_have_room', 'check_proj', 'prepare_variable'
                , 'prepare_variable_from_db', 'insert_log', 'create_folder_and_remove_image_and_save_image', 'create_query', 'update_work'
                , 'insert_work', 'check_status']
use_list = [None] * len(function_list)
sys.path.append(head_path)
module_name = function_file
module = importlib.import_module(module_name)
for i, function in enumerate(function_list):
    function_name = function_list[i]
    use_list[i] = getattr(module, function_name)
destination, log_in_database, database, open_proj_json, project_have_room, check_proj, prepare_variable, prepare_variable_from_db\
, insert_log, create_folder_and_remove_image_and_save_image, create_query, update_work, insert_work, check_status = use_list

def log_values(state):
    log_val = (state, classified_id, idid, project_id, classified_type, housing_type, housing_code, lat, long, price_Sale, sale_reservation, sale_contact
                , sale_transfer_fee, sale_with_Tenant, price_Rent, min_Rental_Contract, deposit, advance_Payment, totalrai, usable_area, floor, bedroom
                , bathroom, parking_amount, direction, furnish, move_in, title_TH, title_ENG, description_TH, description_ENG, user_id, '1', 32, created_Date
                , 32, last_Updated_Date)
    return log_val

user_id = 1
agent = 'BC'
save_folder, json_path, json_path2 = destination(agent)
host, user, password = log_in_database()
sql = False
insert = 0
upd = 0
connection,cursor,sql,result_match,update = database(host,user,password,sql,agent,user_id)

property_list = []
work = False
if sql:
    property_list, work = open_proj_json(agent,json_path,property_list,cursor,connection,work)

if work:
    property_list = project_have_room(property_list,result_match,agent)

    stop_processing = False
    log = False
    for i, prop in enumerate(property_list):
        if stop_processing:
            break
        prop_proj_id = prop['project_ID']
        project_id, housing_code = check_proj(result_match,prop_proj_id)
        
        if prop_proj_id == project_id:
            idid, classified_type, housing_type, lat, long, price_Sale, sale_reservation, sale_contact, sale_transfer_fee, sale_with_Tenant, price_Rent\
            , min_Rental_Contract, deposit, advance_Payment, totalrai, usable_area, floor, bedroom, bathroom, parking_amount, direction, furnish, move_in\
            , title_TH, title_ENG, description_TH, description_ENG, last_Updated_Date, created_Date, insert_date, update_insert_date, image_urls\
            , data_api_list = prepare_variable(prop,agent)
            
            found = False
            data = update.get((idid, prop_proj_id))
            if data:
                found = True
                row_update = False
                classified_id, update_id, update_proj_id, classified_type_check, housing_type_check, lat_check, long_check, price_sale_check\
                , sale_reservation_check, sale_contact_check, sale_transfer_fee_check, sale_with_tenant_check, price_rent_check\
                , min_rental_contract_check, deposit_check, advance_payment_check, totalrai_check, usable_area_check, floor_check, bedroom_check\
                , bathroom_check, parking_amount_check, direction_check, furnish_check, move_in_check, variable_check_list = prepare_variable_from_db(data)
                for variable_count, var in enumerate(data_api_list):
                    if variable_check_list[variable_count+3] != var:
                        row_update = True
                        break
                if row_update:
                    classified_log = create_query('log_update')
                    log_val = log_values('update')
                    query = create_query('data_update')
                    val = (classified_type, housing_type, housing_code, lat, long, price_Sale, sale_reservation, sale_contact
                            , sale_transfer_fee, sale_with_Tenant, price_Rent, min_Rental_Contract, deposit, advance_Payment, totalrai
                            , usable_area, floor, bedroom, bathroom, parking_amount, direction, furnish, move_in, title_TH, title_ENG, description_TH
                            , description_ENG, last_Updated_Date, update_insert_date, idid, project_id)
                    
                    stop_processing, log, upd = update_work(agent,cursor,connection,query,val,classified_log,log_val,idid,upd,classified_id
                                                ,save_folder,image_urls,created_Date,last_Updated_Date,insert,stop_processing)
            
            if not found:
                classified_log = create_query('log_insert')
                query = create_query('data_insert')
                val = (idid, project_id, classified_type, housing_type, housing_code, lat, long, price_Sale, sale_reservation, sale_contact
                        , sale_transfer_fee, sale_with_Tenant, price_Rent, min_Rental_Contract, deposit, advance_Payment, totalrai
                        , usable_area, floor, bedroom, bathroom, parking_amount, direction, furnish, move_in, title_TH, title_ENG, description_TH
                        , description_ENG, user_id, '1', 32, created_Date, 32, last_Updated_Date, insert_date)
                
                stop_processing, log, insert, classified_id = insert_work(agent,cursor,connection,query,val,idid,project_id,insert,save_folder
                                                                ,image_urls,created_Date,last_Updated_Date,upd,stop_processing)
                try:
                    log_val = log_values('insert')
                    cursor.execute(classified_log,log_val)
                    connection.commit()
                except Exception as e:
                    stop_processing = True
                    print(f'Error: {idid} {e}')
                    log = False
                    insert_log(f"{agent}_insert_prop_housing_Insert",log,upd,insert,cursor,connection,e)

    if log:
        e = ''
        insert_log(f"{agent}_insert_prop_housing_Insert",log,upd,insert,cursor,connection,e)

    if len(property_list) > 0:
        check_status(cursor,connection,user_id,property_list,stop_processing,agent)
    
    print(f'Insert Housing {insert} Rows')
    print(f'Update Housing {upd} Rows')
    os.remove(json_path)
    os.remove(json_path2)

if sql:
    cursor.close()
    connection.close()
print('Connection closed')
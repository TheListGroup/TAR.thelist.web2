import importlib
import sys

#head_path = r"C:\PYTHON\TAR.thelist.web2\classifield"
#head_path = r"/home/gitdev/ta_python/classifield"
head_path = r"/home/gitprod/ta_python/classifield"
function_file = 'match_function'
function_list = ['database', 'log_in_database', 'destination_match', 'match_query', 'open_proj_json', 'open_prop_json', 'project_have_room', 'table_proj_statge'
                , 'point_match', 'insert_to_tables', 'truncate_proj_stage']
use_list = [None] * len(function_list)
sys.path.append(head_path)
module_name = function_file
module = importlib.import_module(module_name)
for i, function in enumerate(function_list):
    function_name = function_list[i]
    use_list[i] = getattr(module, function_name)
database, log_in_database, destination_match, match_query, open_proj_json, open_prop_json, project_have_room, table_proj_statge, point_match\
, insert_to_tables, truncate_proj_stage = use_list

agent = 'BC'
project_path, property_path, csv_path = destination_match(agent)
host, user, password = log_in_database()

sql = False
match_list = []
connection,cursor,sql = database(host,user,password,sql)

#เอาแค่ project ที่มีห้อง
project_list = []
list_prop = []
work = False
if sql:
    result = match_query(cursor)
    try:
        project_list = open_proj_json(agent,project_path,project_list)
        prop_list = open_prop_json(property_path,list_prop)
        work = True
    except:
        pass

    if work:
        project_list = project_have_room(project_list,prop_list)

if work:
    #เอาเข้าตารางทด #คัดแค่ project ที่ไม่เคยมี
    more_work, new_project = table_proj_statge(project_list,cursor,connection,agent)

    if more_work:
        new_project_insert, insert = point_match(agent,new_project,result,match_list,csv_path)

        #เอาคะแนน1 เข้า table match
        if len(new_project_insert) > 0:
            insert_to_tables(new_project_insert,cursor,connection,insert,agent)

    #truncated table classified_project_staging
    truncate_proj_stage(cursor,connection)

cursor.close()
connection.close()
print('Connection closed')
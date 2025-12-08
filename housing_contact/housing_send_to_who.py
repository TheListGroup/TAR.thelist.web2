import mysql.connector

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
        cursor = connection.cursor(dictionary=True)
        sql = True
    
except Exception as e:
    print(f'Error: {e}')

if sql:
    query = """SELECT Dev_Agent_Contact_ID, Developer_Code
            FROM housing_contact_dev_agent
            WHERE Developer_Code is not null
            """
    cursor.execute(query)
    result = cursor.fetchall()
    
    contain_list = []
    exact_list = []
    for row in result:
        if row['Developer_Code'].endswith('00'):
            contain_list.append(row)
        else:
            exact_list.append(row)
    
    query_find_housing_dev_contain = """select Housing_Code from housing where Developer_Code like %s and Housing_Status = '1'"""
    query_find_housing_dev_exact = """select Housing_Code from housing where Developer_Code = %s and Housing_Status = '1'"""
    
    query_insert_sen_to_who = """insert into housing_contact_send_to_who (Housing_Code, Dev_Agent_Contact_ID, Created_By, Last_Updated_By) values (%s, %s, %s, %s)"""
    
    log_query = """insert into realist_log (Type, SQL_State, Message, Location) values (%s, %s, %s, %s)"""
    error_log_query = """insert into realist_log (Type, Message, Location) values (%s, %s, %s)"""
    
    send_to_who_list = []
    data_list = [contain_list, exact_list]
    query_housing_list = [query_find_housing_dev_contain, query_find_housing_dev_exact]
    for data in data_list:
        for row in data:
            if data_list.index(data) == 0:
                developer_code = f"%{row['Developer_Code'][:-3]}%"
            else:
                developer_code = row['Developer_Code']
            cursor.execute(query_housing_list[data_list.index(data)], (developer_code,))
            result_housing = cursor.fetchall()
            
            for row_housing in result_housing:
                send_to_who_list.append((row_housing['Housing_Code'], row['Dev_Agent_Contact_ID'], 32, 32))
    
    list_dev_1 = [{"Dev_Agent_Contact_ID": 1, "Housing_Code": "HP1497"}, {"Dev_Agent_Contact_ID": 1, "Housing_Code": "HP0072"}]
    
    list_dev_2 = [{"Dev_Agent_Contact_ID": 2, "Housing_Code": "HP1691"}]
    
    list_dev_3 = [{"Dev_Agent_Contact_ID": 3, "Housing_Code": "HP2718"}, {"Dev_Agent_Contact_ID": 3, "Housing_Code": "HP2354"}]
    
    list_dev_4 = [{"Dev_Agent_Contact_ID": 4, "Housing_Code": "HP6521"}, {"Dev_Agent_Contact_ID": 4, "Housing_Code": "HP0385"}]
    
    list_dev_5 = [{"Dev_Agent_Contact_ID": 5, "Housing_Code": "HP6514"}, {"Dev_Agent_Contact_ID": 5, "Housing_Code": "HP6515"}]
    
    list_dev_6 = [{"Dev_Agent_Contact_ID": 6, "Housing_Code": "HP1108"}, {"Dev_Agent_Contact_ID": 6, "Housing_Code": "HP6240"}]
    
    list_dev_7 = [{"Dev_Agent_Contact_ID": 7, "Housing_Code": "HP1013"}, {"Dev_Agent_Contact_ID": 7, "Housing_Code": "HP0234"}, {"Dev_Agent_Contact_ID": 7, "Housing_Code": "HP0431"}]
    
    list_dev_8 = [{"Dev_Agent_Contact_ID": 8, "Housing_Code": "HP6520"}]
    
    list_dev_9 = [{"Dev_Agent_Contact_ID": 9, "Housing_Code": "HP0001"}]
    
    list_dev_10 = [{"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP1132"}, {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP1630"}, {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP1419"}
                , {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP1298"}, {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP1204"}, {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP6513"}
                , {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP0729"}, {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP0630"}, {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP0166"}
                , {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP0440"}, {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP0117"}, {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP0238"}
                , {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP0087"}, {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP0151"}, {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP0236"}
                , {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP6517"}, {"Dev_Agent_Contact_ID": 10, "Housing_Code": "HP6518"}]
    
    dev_fix_list = [list_dev_1, list_dev_2, list_dev_3, list_dev_4, list_dev_5, list_dev_6, list_dev_7, list_dev_8, list_dev_9, list_dev_10]
    for dev_fix in dev_fix_list:
        for row in dev_fix:
            send_to_who_list.append((row['Housing_Code'], row['Dev_Agent_Contact_ID'], 32, 32))
            
    #------------------------------------ AGENT SECTION ---------------------------------------
    """
    ag_bc_query = "
                    SELECT a.Condo_Code
                        , b.Dev_Agent_Contact_ID
                    FROM all_condo_price_calculate a
                    cross join real_contact_dev_agent b
                    where b.Dev_Agent_Contact_ID in (74,76) "

    plus_query = "
                    SELECT a.Condo_Code
                        , 72 as Dev_Agent_Contact_ID
                    FROM all_condo_price_calculate a
                    where (a.Condo_Price_Per_Square >= 160000 or a.Condo_Price_Per_Unit >= 3000000) "

    serve_query = "
                    SELECT a.Condo_Code
                        , 73 as Dev_Agent_Contact_ID
                    FROM all_condo_price_calculate a
                    left join (select Condo_Code, Station_Code
                                from condo_around_station
                                where Station_Code in ('N9','N8','N7','N6','N5','N4','N3','N2','N1','CEN-1','E1','E2','E3','E4','E5','E6','E7')) light_green
                    on a.Condo_Code = light_green.Condo_Code
                    left join (select Condo_Code, Station_Code
                                from condo_around_station
                                where Station_Code in ('W1','CEN-2','S1','S2','S3','S4','S5','S6','S7','S8')) dark_green
                    on a.Condo_Code = dark_green.Condo_Code
                    left join (select Condo_Code, Station_Code
                                from condo_around_station
                                where Station_Code in ('BL16','BL17','BL18','BL19','BL20','BL21','BL22','BL23','BL24','BL25','BL26')) blue
                    on a.Condo_Code = blue.Condo_Code
                    where (a.Condo_Price_Per_Square >= 100000 or a.Condo_Price_Per_Unit >= 3000000)
                    and (light_green.Station_Code is not null or dark_green.Station_Code is not null or blue.Station_Code is not null)
                    group by a.Condo_Code "

    agent_query_list = [ag_bc_query, plus_query, serve_query]
    for agent_query in agent_query_list:
        cursor.execute(agent_query)
        result = cursor.fetchall()
        for row in result:
            send_to_who_list.append((row['Condo_Code'], row['Dev_Agent_Contact_ID'], 32, 32))"""
    
    try:
        cursor.execute("truncate table housing_contact_send_to_who")
        cursor.executemany(query_insert_sen_to_who, send_to_who_list)
        cursor.execute(log_query, ('0', '0000', f'Insert {len(send_to_who_list)} rows', 'housing_contact_send_to_who'))
        connection.commit()
    except Exception as e:
        connection.rollback()
        cursor.execute(error_log_query, ('1', str(e), 'housing_contact_send_to_who'))
        connection.commit()
    finally:
        cursor.close()
        connection.close()
print("Done")
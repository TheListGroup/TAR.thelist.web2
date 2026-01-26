import os
import mysql.connector

save_folder = rf"/var/www/html/realist/condo/uploads/classified"

#host = '159.223.76.99'
#user = 'real-research2'
#password = 'DQkuX/vgBL(@zRRa'

host = '127.0.0.1'
user = 'real-research'
password = 'shA0Y69X06jkiAgaX&ng'

def insert_log(log,cursor,connection,e,x,delete_list):
    if log:
        log_query = """
                    INSERT INTO realist_log (Type, SQL_State, Message, Location)
                    VALUES (%s, %s, %s, %s)
                    """
        log_val = (0, '00000', f'Clear image {x} image from {len(delete_list)} folders', 'Classified Clear Image')
    else:
        log_query = """
                    INSERT INTO realist_log (Type, Message, Location)
                    VALUES (%s, %s, %s)
                    """
        log_val = (1, str(e), 'Classified Clear Image')
    cursor.execute(log_query, log_val)
    connection.commit()

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
    try:
        delete_list = []
        query = """
                SELECT a.Classified_ID, count(b.Classified_Image_ID) as abc
                FROM classified a
                left join classified_image b on a.Classified_ID = b.Classified_ID
                where a.Classified_Status = '2'
                group by a.Classified_ID  
                """
        cursor.execute(query)
        result = cursor.fetchall()
        
        x = 0
        for classified_unit in result:
            classified_id = classified_unit['Classified_ID']
            delete_list.append((classified_id,))
            full_path = os.path.join(save_folder, f'{classified_id:06d}')
            
            if os.path.exists(full_path):
                for existing_file in os.listdir(full_path):
                    file_path = os.path.join(full_path, existing_file)
                    if os.path.isfile(file_path):
                        try:
                            os.remove(file_path)
                            x += 1
                        except:
                            new_path = f"{full_path}_delete"
                            os.rename(full_path, new_path)
        
        if delete_list:
            query = """DELETE FROM classified_image WHERE Classified_ID = %s"""
            cursor.executemany(query, delete_list)
        
        log = True
        insert_log(log,cursor,connection,'',x,delete_list)
    except Exception as e:
        connection.rollback()
        log = False
        insert_log(log,cursor,connection,e,'','')
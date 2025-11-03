import mysql.connector
import re
import random
import string
import bcrypt
import csv

#host = '159.223.76.99'
#user = 'real-research2'
#password = 'DQkuX/vgBL(@zRRa'

host = '127.0.0.1'
user = 'real-research'
password = 'shA0Y69X06jkiAgaX&ng'

user_file = r"/home/gitprod/ta_python/gen_office_user/user.csv"

def generate_password(length=10):
    lowercase = string.ascii_lowercase
    uppercase = string.ascii_uppercase
    digits = string.digits
    
    guaranteed_chars = [
        random.choice(lowercase),
        random.choice(uppercase),
        random.choice(digits)
    ]
    
    all_chars = lowercase + uppercase + digits
    remaining_length = length - len(guaranteed_chars)
    
    remaining_chars = random.choices(all_chars, k=remaining_length)
    
    final_password_list = guaranteed_chars + remaining_chars
    random.shuffle(final_password_list)
    
    return "".join(final_password_list)

sql = False
try:
    connection = mysql.connector.connect(
        host = host,
        user = user,
        password = password,
        database = 'realist_office'
    )
    if connection.is_connected():
        print('Connected to MySQL server')
        cursor = connection.cursor(dictionary=True)
        sql = True
    
except Exception as e:
    print(f'Error: {e}')

if sql:
    try:
        data_list = []
        connection.start_transaction()
        query = """
                SELECT a.Project_ID, a.Name_EN, group_concat(b.Building_ID SEPARATOR ',') as Building_ID
                FROM office_project a
                left join (select Project_ID, Building_ID
                        FROM office_building
                        where Building_Status = '1') b
                on a.Project_ID = b.Project_ID
                WHERE a.Project_Status = '1'
                group by a.Project_ID, a.Name_EN
                """
        cursor.execute(query)
        result = cursor.fetchall()
        if result:
            user_query = """
                        INSERT INTO office_admin_and_leasing_user
                        (Role_ID, Company_Name, Phone_Number, User_FullName, Email, User_User_Name, User_Password, User_Status)
                        VALUES (2, 'Generate', 'Generate', 'Generate', 'Generate', %s, %s, '1')
                        """
            for row in result:
                username = re.sub(' ', '', row["Name_EN"]).lower().strip()
                password = generate_password(10)
                data_list.append((row['Project_ID'], row['Name_EN'], username, password))
                password_bytes = password.encode('utf-8')
                cost = 10
                salt = bcrypt.gensalt(rounds=cost)
                hashed_password_bytes = bcrypt.hashpw(password_bytes, salt)
                hashed_password_string = hashed_password_bytes.decode('utf-8')
                
                cursor.execute(user_query, (username, hashed_password_string))
                user_id = cursor.lastrowid
                #print(f"User from project {row['Project_ID']} created")
                
                relationship_list = []
                if row['Building_ID']:
                    building_id_list = row['Building_ID'].split(',')
                else:
                    building_id_list = []
                
                for building_id_str in building_id_list:
                    building_id = int(building_id_str.strip())
                    relationship_list.append((building_id, user_id, '1', 1, 1))
                
                if relationship_list:
                    relationship_query = """INSERT INTO office_building_relationship
                                        (Building_ID, User_ID, Relationship_Status, Created_By, Last_Updated_By)
                                        VALUES (%s, %s, %s, %s, %s)"""
                    cursor.executemany(relationship_query, relationship_list)
                    #print(f"Project {row['Project_ID']} have {len(relationship_list)} relationships")
            connection.commit()
            with open(user_file, 'w', newline='') as file:
                writer = csv.writer(file)
                writer.writerow(['Project_ID', 'Name_EN', 'Username', 'Password'])
                writer.writerows(data_list)
            
            print("DONE")
                
    except Exception as e:
        print(f'Error: {e}')
    
    finally:
        cursor.close()
        connection.close()
import os
import mysql.connector
import re

host = '157.230.242.204'
user = 'real-research2'
password = 'DQkuX/vgBL(@zRRa'

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
    
except Exception as e:
    print(f'Error: {e}')

insert_list = []
starting_directory = r"C:\PYTHON\TAR.thelist.web2\scrap\pic\house_image"

a = 0
for root, dirs, files in os.walk(starting_directory):
    x = 0
    for file in files:
        housing_code = file[:6]
        if file[-9:-5] == '-300':
            insert_list.append((housing_code, x+1, re.sub(file[-9:-5],'',file), file))
            x += 1
            a += 1
            if a % 10000 == 0:
                print(f"Prepare {a} Image")

data = len(insert_list)

try:
    query = """INSERT INTO housing_gallery (Housing_Code, Housing_Gallery_Order, Housing_Gallery_PicName , Housing_Gallery_PicName_300)
            VALUES (%s, %s, %s, %s)"""
    val = insert_list
    cursor.executemany(query,val)
    connection.commit()
    
except Exception as e:
    print(f'Error: {e}')

cursor.close()
connection.close()
print(f'DONE {data} rows insert')
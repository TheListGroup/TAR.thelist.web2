import pandas as pd
from urllib.parse import unquote, quote
import mysql.connector

host = '127.0.0.1'
user = 'real-research'
password = 'shA0Y69X06jkiAgaX&ng'

#host = '159.223.76.99'
#user = 'real-research2'
#password = 'DQkuX/vgBL(@zRRa'

#csv_file = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\P Ton\blog view.csv"
csv_file = r"/home/gitprod/ta_python/analytic/blog view.csv"

def normalize_to_db_format(path):
    slug = path.split('realist/blog/')[-1].strip('/')
    return quote(unquote(slug)).lower()

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
        cursor.execute("""select ID, post_name from wp_posts where post_type = 'post' and post_status = 'publish'""")
        posts = cursor.fetchall()
        db_map = {row['post_name'].lower(): row['ID'] for row in posts}
        
        df = pd.read_csv(csv_file)
        mask = df['Page path and screen class'].str.contains('realist/blog/', na=False)
        df_blog = df[mask].copy()
        
        df_blog['db_slug'] = df_blog['Page path and screen class'].apply(normalize_to_db_format)
        df_blog = df_blog.dropna(subset=['db_slug'])
        
        grouped_df = df_blog.groupby('db_slug')['Views'].sum().reset_index()
        grouped_df['post_id'] = grouped_df['db_slug'].map(db_map)
        final_list = grouped_df.dropna(subset=['post_id'])
        
        sql_check = f"SELECT DISTINCT post_id FROM wp_postmeta where meta_key = '_gapp_post_views'"
        cursor.execute(sql_check)
            
        existing_ids = {row['post_id'] for row in cursor.fetchall()}
            
        update_batch = []
        insert_batch = []
        for index, row in final_list.iterrows():
            p_id = row['post_id']
            views = row['Views']
            if p_id in existing_ids:
                update_batch.append((views, p_id)) 
            else:
                insert_batch.append((p_id, '_gapp_post_views', views))
        
        if update_batch:
            sql_update = f"UPDATE wp_postmeta SET meta_value = %s WHERE post_id = %s and meta_key = '_gapp_post_views'"
            cursor.executemany(sql_update, update_batch)
        if insert_batch:
            sql_insert = f"INSERT INTO wp_postmeta (post_id, meta_key, meta_value) VALUES (%s, %s, %s)"
            cursor.executemany(sql_insert, insert_batch)
        connection.commit()
        
        print(f'complete insert {len(insert_batch)} rows and update {len(update_batch)} rows')
    except Exception as e:
        connection.rollback()
        print(f'error {e}')
    finally:
        cursor.close()
        connection.close()

print('DONE')
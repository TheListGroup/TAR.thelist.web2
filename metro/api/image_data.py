import pandas as pd
from pathlib import Path
from PIL import Image
from db import get_db
#import mysql.connector

#host = '159.223.76.99'
#user = 'real-research2'
#password = 'DQkuX/vgBL(@zRRa'

#try:
#    conn = mysql.connector.connect(
#        host = host,
#        user = user,
#        password = password,
#        database = 'metro'
#    )
#    if conn.is_connected():
#        print('Connected to MySQL server')
#        cur = conn.cursor(dictionary=True)
#except Exception as e:
#    print(f'Error: {e}')

#root_dir = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\metro\api"
#save_file = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\metro\api\image_report.xlsx"
conn = get_db()
cur = conn.cursor(dictionary=True)
root_dir = r"/var/www/html/uploads"
prefix = "https://thelist.group/metropolis/uploads"
save_file = r"/var/www/html/fastapi/image_report.xlsx"

def get_image_info(file_path):
    """ฟังก์ชันดึงขนาดและ Resolution ของรูป"""
    try:
        with Image.open(file_path) as img:
            width, height = img.size
            size_kb = round(file_path.stat().st_size / 1024, 2)
            return width, height, size_kb
    except:
        return None, None, None

def scan_folders(base_path, category_name):
    data_cover = []
    data_gallery = []
    
    # เข้าไปใน proj, prof, หรือ prod
    base = Path(base_path) / category_name
    if not base.exists():
        return [], []

    # Loop ผ่านโฟลเดอร์ ID
    for id_folder in base.iterdir():
        allow = False
        if id_folder.is_dir():
            main_id = id_folder.name
            if category_name == 'project':
                data_info = proj_master.get(str(int(main_id)), {'name_en': '-', 'name_th': '-'})
            elif category_name == 'professional':
                data_info = prof_master.get(str(int(main_id)), {'name_en': '-', 'name_th': '-'})
            else:
                data_info = prod_master.get(str(int(main_id)), {'name_en': '-', 'name_th': '-'})
            
            # เช็คโฟลเดอร์ย่อย (cover, gallery)
            for sub in ['cover', 'gallery']:
                sub_path = id_folder / sub
                if not sub_path.exists():
                    continue
                
                if category_name in ['project', 'product'] and sub == 'cover':
                    allow = True
                
                # ค้นหารูปภาพ (รวมถึงในโฟลเดอร์ซ้อนของ proj/gallery ด้วย)
                # rglob('*') จะช่วยหาไฟล์ลึกกี่ชั้นก็ได้
                for file in sub_path.rglob('*'):
                    if sub == 'gallery' and "-H-1440" in str(file.absolute()):
                        allow = True
                    elif category_name == 'professional' and sub == 'cover' and "-H-420" not in str(file.absolute()):
                        allow = True
                    
                    if allow:
                        if file.is_file() and file.suffix.lower() in ['.jpg', '.jpeg', '.png', '.webp']:
                            sub_id = "-"
                            expertise_name = "-"
                            if file.parent != sub_path:
                                sub_id = file.parent.name
                                expertise_name = expertise_master.get(str(int(sub_id)), {'Responsibility': '-'})
                            width, height, size = get_image_info(file)
                            url = str(file.absolute()).replace(str(Path(root_dir).absolute()), prefix)
                            url = url.replace('\\', '/')
                            info = {
                                'ID': int(main_id),
                                'Name EN': data_info['name_en'],
                                'Name TH': data_info['name_th'],
                                'Size (KB)': size,
                                'Width': width,
                                'Height': height,
                                'URL': url
                            }
                            
                            if category_name == 'project' and sub == 'gallery':
                                info['Expertise'] = expertise_name["Responsibility"] if expertise_name != "-" else "-"
                            
                            if sub == 'cover':
                                data_cover.append(info)
                            else:
                                data_gallery.append(info)
                            
    return data_cover, data_gallery

proj_query = f"""select a.ID, a.Name_EN, a.Name_TH from projects a"""
cur.execute(proj_query)
rows = cur.fetchall()
proj_master = {str(row["ID"]): {'name_en': row["Name_EN"], 'name_th': row["Name_TH"]} for row in rows}

prof_query = f"""select a.ID, a.Name_EN, a.Name_TH from professionals a"""
cur.execute(prof_query)
rows = cur.fetchall()
prof_master = {str(row["ID"]): {'name_en': row["Name_EN"], 'name_th': row["Name_TH"]} for row in rows}

prod_query = f"""select a.ID, a.Name_EN, a.Name_TH from product_entities a"""
cur.execute(prod_query)
rows = cur.fetchall()
prod_master = {str(row["ID"]): {'name_en': row["Name_EN"], 'name_th': row["Name_TH"]} for row in rows}

expertise_query = f"""SELECT  a.ID, concat(c.Responsibility, ' by ', d.Name_EN) as Responsibility
                    FROM proj_prof_relationship a
                    join prof_expertise_relationship b on a.Prof_Expertise_Relationship_ID = b.ID
                    join prof_expertise c on b.Expertise_ID = c.ID
                    join professionals d on b.Prof_ID = d.ID"""
cur.execute(expertise_query)
rows = cur.fetchall()
expertise_master = {str(row["ID"]): {'Responsibility': row["Responsibility"]} for row in rows}

# --- เริ่มทำงาน ---
categories = ['project', 'professional', 'product']
all_lists = {}

for cat in categories:
    cover_list, gallery_list = scan_folders(root_dir, cat)
    all_lists[f"{cat}_cover"] = cover_list
    all_lists[f"{cat}_gallery"] = gallery_list

# บันทึกลง Excel 6 Tabs
column_order = ['ID', 'Name EN', 'Name TH', 'Expertise', 'Width', 'Height', 'Size (KB)', 'URL']
with pd.ExcelWriter(save_file, engine='xlsxwriter') as writer:
    for sheet_name, data in all_lists.items():
        df = pd.DataFrame(data)
        if not df.empty:
            # กรองเอาเฉพาะคอลัมน์ที่มีอยู่ในข้อมูลจริงๆ (กัน Error ถ้าบาง Sheet ไม่มีบาง Column)
            existing_columns = [col for col in column_order if col in df.columns]
            # สั่ง Reindex ตามลำดับที่เราเลือก
            df = df.reindex(columns=existing_columns)
            df = df.fillna('-')
            df.to_excel(writer, sheet_name=sheet_name, index=False)
    print("สร้างไฟล์ image_report.xlsx เรียบร้อยแล้ว!")

#cur.close()
#conn.close()
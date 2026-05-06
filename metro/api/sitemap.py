import xml.etree.ElementTree as ET
from xml.dom import minidom
from datetime import datetime
from db import get_db
#import mysql.connector

conn = get_db()
cur = conn.cursor(dictionary=True)
#save_file = r"C:\Users\RealResearcher1\Documents\GitHub\TAR.thelist.web2\metro\api\sitemap.xml"
#save_file = r"/var/www/html/metropolis/sitemap/sitemap.xml"
save_file = r"/var/www/html/sitemap.xml"

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

data_list = []
BASE_URL = "https://thelist.group/metropolis"
NAMESPACE = "http://www.sitemaps.org/schemas/sitemap/0.9"
cur.execute(f"""select "{BASE_URL}" as path, CURRENT_DATE as lastmod, 'daily' as changefreq, 1.0 as priority
                union select "{BASE_URL}/proj" as path, CURRENT_DATE as lastmod, 'daily' as changefreq, 1.0 as priority
                union select "{BASE_URL}/prof" as path, CURRENT_DATE as lastmod, 'daily' as changefreq, 1.0 as priority
                union select "{BASE_URL}/prod" as path, CURRENT_DATE as lastmod, 'daily' as changefreq, 1.0 as priority
                union select concat("{BASE_URL}/proj/", Proj_URL_Tag) as path, date(Last_Updated_Date) as lastmod
                        , 'weekly' as changefreq, 0.8 as priority from projects where Proj_Status = '1'
                union select concat("{BASE_URL}/prod/", Entity_URL_Tag) as path, date(Last_Updated_Date) as lastmod
                        , 'weekly' as changefreq, 0.6 as priority from product_entities where Entity_Status = '1'
                union select concat("{BASE_URL}/prof/", Prof_URL_Tag) as path, date(Last_Updated_Date) as lastmod
                        , 'weekly' as changefreq, 0.4 as priority from professionals where Prof_Status = '1';
            """)
rows = cur.fetchall()
for row in rows:
    row["lastmod"] = row["lastmod"].strftime("%Y-%m-%d")
    row["priority"] = str(row["priority"])
    data_list.append(row)

# เริ่มสร้าง XML
# ลงทะเบียน Namespace เพื่อไม่ให้เกิด Prefix (เช่น ns0:) ในไฟล์
ET.register_namespace('', NAMESPACE)

# สร้าง Root element (urlset) พร้อมกำหนด Namespace
root = ET.Element("urlset", xmlns=NAMESPACE)

for row in data_list:
    # สร้าง <url>
    url_tag = ET.SubElement(root, "url")
    
    # สร้าง <loc> (Base URL + Path จาก query)
    loc = ET.SubElement(url_tag, "loc")
    loc.text = f"{row['path']}"
    
    # สร้าง <lastmod>
    lastmod = ET.SubElement(url_tag, "lastmod")
    lastmod.text = row['lastmod']
    
    # สร้าง <changefreq>
    changefreq = ET.SubElement(url_tag, "changefreq")
    changefreq.text = row['changefreq']
    
    # สร้าง <priority>
    priority = ET.SubElement(url_tag, "priority")
    priority.text = row['priority']

# 4. แปลงเป็น XML String และจัดรูปแบบให้สวยงาม (Pretty Print)
xml_string = ET.tostring(root, encoding='utf-8')
reparsed = minidom.parseString(xml_string)
pretty_xml = minidom.parseString(ET.tostring(root, 'utf-8')).toprettyxml(indent="  ", encoding="utf-8")

# 5. บันทึกไฟล์
with open(save_file, "wb") as f:
    f.write(pretty_xml)

cur.close()
conn.close()
print("สร้าง sitemap.xml เรียบร้อยแล้ว!")
from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from function_utility import iso8601_z, normalize_unit_row, normalize_row, format_seconds_to_time_str
from typing import Optional, Tuple, Dict, Any, List
import re
import os
from wand.image import Image as WandImage
from io import BytesIO
from PIL import Image, ImageOps
import shutil

#UPLOAD_DIR = "/var/www/html/metro/uploads"
UPLOAD_DIR = "/var/www/html/uploads"

def check_location(cur, location, location_type):
    cur.execute(f"""select ID from place_location where Location_Type = %s and Name_EN = %s and Location_Status = '1'""", (location_type, location))
    result = cur.fetchone()
    if result:
        return result['ID']
    if location != None:
        cur.execute("INSERT INTO place_location (Location_Type, Name_EN, Location_Status) VALUES (%s, %s, %s)", (location_type, location, '1'))
        return cur.lastrowid
    return None

def check_country(cur, country):
    cur.execute(f"""select ID from country where Name_EN = %s and Country_Status = '1'""", (country,))
    result = cur.fetchone()
    if result:
        return result['ID']
    cur.execute("INSERT INTO country (Name_EN, Country_Status) VALUES (%s, %s)", (country, '1'))
    return cur.lastrowid

def _select_full_prof_item(prof_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                a.ID, a.Name_EN, a.Name_TH, a.Latitude, a.Longitude, a.Prof_Address, yarn.Name_EN as Prof_Yarn, sub_district.Name_EN as Prof_Sub_District
                , district.Name_EN as Prof_District, province.Name_EN as Prof_Province, state.Name_EN as Prof_State, c.Name_EN as Prof_Country
                , a.FB_Link, a.IG_Link, a.Line_Link, a.YT_Link, a.Website, YEAR(a.Found_Date) as Year_Found_Date, a.Found_Date, a.Is_Freelance, a.Logo_URL, a.Brief_Description, a.Content
                , a.Prof_URL_Tag, a.Prof_Status, owner.Owner, owner.Owner_Text, ext.Expertise, ext.Expertise_Text, exp.Experience, exp.Experience_Text
            FROM professionals a
            left join place_location yarn on a.Prof_Yarn = yarn.ID and yarn.Location_Status = '1'
            left join place_location sub_district on a.Prof_Sub_District = sub_district.ID and sub_district.Location_Status = '1'
            left join place_location district on a.Prof_District = district.ID and district.Location_Status = '1'
            left join place_location province on a.Prof_Province = province.ID and province.Location_Status = '1'
            left join place_location state on a.Prof_State = state.ID and state.Location_Status = '1'
            left join country c on a.Prof_Country = c.ID and c.Country_Status = '1'
            left join (SELECT a.Prof_ID, JSON_ARRAYAGG(JSON_OBJECT( 'Owner_ID', a.ID
                                                                    , 'First_Name_EN', a.First_Name_EN
                                                                    , 'Last_Name_EN', a.Last_Name_EN
                                                                    , 'First_Name_TH', a.First_Name_TH
                                                                    , 'Last_Name_TH', a.Last_Name_TH
                                                                    , 'Order', a.Owner_Order)) as Owner
                                , GROUP_CONCAT(concat_ws(' ', a.First_Name_EN, a.Last_Name_EN) ORDER BY a.First_Name_EN, a.Last_Name_EN SEPARATOR ', ') as Owner_Text
                        FROM prof_owners a
                        where a.Owner_Status = '1'
                        group by a.Prof_ID) as owner
            on a.ID = owner.Prof_ID
            left join (SELECT a.Prof_ID, JSON_ARRAYAGG(JSON_OBJECT( 'Relationship_ID', a.ID
                                                                    , 'Expertise_ID', a.Expertise_ID
                                                                    , 'Responsibility', b.Responsibility
                                                                    , 'Expertise_Order', a.Relationship_Order)) as Expertise
                            , GROUP_CONCAT(b.Responsibility ORDER BY a.Relationship_Order ASC SEPARATOR ', ') as Expertise_Text
                        FROM prof_expertise_relationship a
                        join prof_expertise b on a.Expertise_ID = b.ID and b.Expertise_Status = '1'
                        where a.Relationship_Status = '1'
                        group by a.Prof_ID) as ext
            on a.ID = ext.Prof_ID
            left join (SELECT a.Prof_ID, JSON_ARRAYAGG(JSON_OBJECT( 'Relationship_ID', a.ID
                                                                    , 'Proj_Category_ID', a.Proj_Category_ID
                                                                    , 'Category_Name', b.Category_Name)) as Experience
                            , GROUP_CONCAT(b.Category_Name ORDER BY c.Categories_Order, b.Categories_Order ASC SEPARATOR ' | ') as Experience_Text
                        FROM prof_experience_relationship a
                        left join proj_categories b on a.Proj_Category_ID = b.ID and b.Categories_Status = '1'
                        left join proj_categories c on b.Parent_ID = c.ID and c.Categories_Status = '1'
                        where a.Proj_Category_Status = '1'
                        group by a.Prof_ID) as exp
            on a.ID = exp.Prof_ID
            WHERE a.ID=%s""",
        (prof_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return normalize_unit_row(row)

def _select_all_location(location_type):
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                Name_EN, Name_TH
            FROM place_location
            WHERE Location_Type=%s
            and Location_status = '1'""",
        (location_type,)
    )
    row = cur2.fetchall()
    cur2.close()
    conn2.close()
    return normalize_unit_row(row)

def _select_country():
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                Name_EN, Name_TH
            FROM country
            WHERE Country_Status = '1'"""
    )
    row = cur2.fetchall()
    cur2.close()
    conn2.close()
    return normalize_unit_row(row)

def _select_expertise():
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                Responsibility
            FROM prof_expertise
            WHERE Expertise_Status = '1'"""
    )
    row = cur2.fetchall()
    cur2.close()
    conn2.close()
    return normalize_unit_row(row)

def _select_category(state: str):
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    if state == "prof":
        query = "join"
    else:
        query = "join"
    
    cur2.execute(
        f"""SELECT
                a.Category_Name
            FROM proj_categories a
            {query} proj_categories b on a.Parent_ID = b.ID and b.Categories_Status = '1'
            WHERE a.Categories_Status = '1'
            order by b.Categories_Order, a.Categories_Order"""
    )
    row = cur2.fetchall()
    cur2.close()
    conn2.close()
    return normalize_unit_row(row)

def _select_full_proj_item(proj_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                a.ID, a.Name_EN, a.Name_TH, a.Latitude, a.Longitude, a.Proj_Address, yarn.Name_EN as Proj_Yarn, sub_district.Name_EN as Proj_Sub_District
                , district.Name_EN as Proj_District, province.Name_EN as Proj_Province, state.Name_EN as Proj_State, c.Name_EN as Proj_Country
                , a.Start_Date, a.Finish_Date, a.Renovated_Date, a.Land_Rai, a.Land_Ngan, a.Land_Wa, a.Usable_Area, a.Commercial_Area, a.Land_Total
                , a.Brief_Description, a.Proj_URL_Tag, a.Proj_Status, exp.Categories
            FROM projects a
            left join place_location yarn on a.Proj_Yarn = yarn.ID and yarn.Location_Status = '1'
            left join place_location sub_district on a.Proj_Sub_District = sub_district.ID and sub_district.Location_Status = '1'
            left join place_location district on a.Proj_District = district.ID and district.Location_Status = '1'
            left join place_location province on a.Proj_Province = province.ID and province.Location_Status = '1'
            left join place_location state on a.Proj_State = state.ID and state.Location_Status = '1'
            left join country c on a.Proj_Country = c.ID and c.Country_Status = '1'
            left join (SELECT a.Proj_ID, JSON_ARRAYAGG(JSON_OBJECT( 'Relationship_ID', a.ID
                                                                    , 'Category_ID', a.Category_ID
                                                                    , 'Category_Name', b.Category_Name
                                                                    , 'Relationship_Order', a.Relationship_Order)) as Categories
                        FROM proj_category_relationship a
                        left join proj_categories b on a.Category_ID = b.ID and b.Categories_Status = '1'
                        where a.Relationship_Status = '1'
                        group by a.Proj_ID) as exp
            on a.ID = exp.Proj_ID
            WHERE a.ID=%s""",
        (proj_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return normalize_unit_row(row)

def _select_prof_expertise() -> Dict[str, Any]:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                a.ID,
                concat(b.Name_EN, ' - ', c.Responsibility) as expertise
            FROM prof_expertise_relationship a
            join professionals b on a.Prof_ID = b.ID and b.Prof_Status <> '2'
            join prof_expertise c on a.Expertise_ID = c.ID and c.Expertise_Status = '1'
            where a.Relationship_Status = '1'"""
    )
    row = cur2.fetchall()
    cur2.close()
    conn2.close()
    return row

def _select_proj_prof_relationship(Prof_ID) -> Dict[str, Any]:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                aa.ID,
                concat(d.Name_EN, ' - ', b.Name_EN, ' - ', c.Responsibility) as expertise
            FROM proj_prof_relationship aa
            join prof_expertise_relationship a on aa.Prof_Expertise_Relationship_ID = a.ID and a.Relationship_Status = '1'
            join professionals b on a.Prof_ID = b.ID and b.Prof_Status <> '2'
            join prof_expertise c on a.Expertise_ID = c.ID and c.Expertise_Status = '1'
            join projects d on aa.Proj_ID = d.ID and d.Proj_Status <> '2'
            where a.Prof_ID = %s
            and aa.Relationship_Status = '1'""",
        (Prof_ID,)
    )
    row = cur2.fetchall()
    cur2.close()
    conn2.close()
    return row

def prepare_relationship_data(Text_Type):
    if Text_Type == 'exp':
        table_relationship = 'prof_experience_relationship'
        tag_id_column = 'Proj_Category_ID'
        order_column = 'Categories_Order'
        table_cate = 'proj_categories'
        name_column = 'Category_Name'
        status_column = 'Categories_Status'
        status_relationship_column = 'Proj_Category_Status'
    else:
        table_relationship = 'prof_expertise_relationship'
        tag_id_column = 'Expertise_ID'
        order_column = 'Expertise_Order'
        table_cate = 'prof_expertise'
        name_column = 'Responsibility'
        status_column = 'Expertise_Status'
        status_relationship_column = 'Relationship_Status'
    return table_relationship, tag_id_column, order_column, table_cate, name_column, status_column, status_relationship_column

def insert_tag_relationship(cur, prof_id: int, tag_id: int, table_relationship: str, order) -> dict:
    if table_relationship == 'prof_experience_relationship':
        cur.execute(f"""INSERT INTO {table_relationship} (Prof_ID, Proj_Category_ID, Proj_Category_Status) VALUES (%s, %s, %s)""", (prof_id, tag_id, '1'))
    else:
        cur.execute(f"""INSERT INTO {table_relationship} (Prof_ID, Expertise_ID, Relationship_Order, Relationship_Status) VALUES (%s, %s, %s, %s)""", (prof_id, tag_id, order, '1'))

def insert_relationship(cur, Prof_ID: int, Text: str, Text_Type: str):
    if not Text:
        return
    table_relationship, tag_id_column, order_column, table_cate, name_column, status_column, status_relationship_column = prepare_relationship_data(Text_Type)
    
    cur.execute(f"""SELECT max({order_column}) as max_order FROM {table_cate} where {status_column} = '1'""")
    row = cur.fetchone()
    max_order = row['max_order'] if row and row['max_order'] else 0
    
    all_tag = [t.strip() for t in Text.split(";") if t.strip()]
    x = 1
    for i, tag in enumerate(all_tag):
        cur.execute(f"SELECT ID FROM {table_cate} WHERE {name_column} = %s and {status_column} = '1'", (tag,))
        row = cur.fetchone()
        if row is not None:
            tag_id = row['ID']
        else:
            cur.execute(f"INSERT INTO {table_cate} ({name_column}, {order_column}, {status_column}) VALUES (%s, %s, %s)", (tag, int(max_order) + x, '1'))
            tag_id = cur.lastrowid
            x += 1
        cur.execute(f"SELECT 1 FROM {table_relationship} WHERE Prof_ID = %s AND {tag_id_column} = %s and {status_relationship_column} = '1'", (Prof_ID, tag_id))
        if not cur.fetchone():
            insert_tag_relationship(cur, Prof_ID, tag_id, table_relationship, i+1)

def update_relationship(cur, Prof_ID: int, Text: str, Text_Type: str, state: str, state2: str):
    table_relationship, tag_id_column, order_column, table_cate, name_column, status_column, status_relationship_column = prepare_relationship_data(Text_Type)

    cur.execute(f"""SELECT max({order_column}) as max_order FROM {table_cate} where {status_column} = '1'""")
    row = cur.fetchone()
    max_order = row['max_order'] if row and row['max_order'] else 0
    
    all_tags = [t.strip() for t in Text.split(";") if t.strip()] if Text else []
    x = 1
    new_tag_ids = []
    for tag in all_tags:
        cur.execute(f"SELECT ID FROM {table_cate} WHERE {name_column} = %s and {status_column} = '1'", (tag,))
        row_cate = cur.fetchone()
        if row_cate:
            tag_id = row_cate['ID']
        else:
            cur.execute(f"INSERT INTO {table_cate} ({name_column}, {order_column}, {status_column}) VALUES (%s, %s, %s)", (tag, int(max_order) + x, '1'))
            tag_id = cur.lastrowid
            x += 1
        new_tag_ids.append(tag_id)

    # 3. ดึง ID ปัจจุบันที่มีอยู่ในความสัมพันธ์ (Relationship Table)
    cur.execute(f"SELECT {tag_id_column} FROM {table_relationship} WHERE Prof_ID = %s", (Prof_ID,))
    existing_rows = cur.fetchall()
    existing_ids = [r[tag_id_column] for r in existing_rows]

    # 4. ลบ (Delete): ตัวที่มีใน DB แต่ไม่อยู่ใน List ใหม่
    ids_to_delete = list(set(existing_ids) - set(new_tag_ids))
    if ids_to_delete:
        format_strings = ','.join(['%s'] * len(ids_to_delete))
        if table_relationship != 'prof_experience_relationship':
            cur.execute(f"SELECT ID FROM {table_relationship} WHERE Prof_ID = %s AND {tag_id_column} IN ({format_strings})", (Prof_ID, *ids_to_delete))
            rel_rows = cur.fetchall()
            rel_ids = [r['ID'] for r in rel_rows]
            if rel_ids:
                delete_expertise_process(cur, rel_ids, state, state2)
        
        if state != 'delete':
            relationship_query = f"UPDATE {table_relationship} SET {status_relationship_column} = '2'"
        else:
            relationship_query = f"delete from {table_relationship}"
        
        cur.execute(f"{relationship_query} WHERE Prof_ID = %s AND {tag_id_column} IN ({format_strings}) and {status_relationship_column} = '1'", 
                    (Prof_ID, *ids_to_delete))

    # 5. จัดการเพิ่มหรืออัปเดตข้อมูล (Insert / Reactive / Re-order)
    ids_to_add = set(new_tag_ids) - set(existing_ids)
    for i, t_id in enumerate(new_tag_ids):
        current_order = i + 1
        if t_id in ids_to_add:
            # กรณีที่ 1: เป็น ID ใหม่ซิ่งที่ยังไม่เคยมีความสัมพันธ์กับ Prof นี้เลย
            insert_tag_relationship(cur, Prof_ID, t_id, table_relationship, current_order)
        else:
            # กรณีที่ 2: เป็น ID ที่เคยมีอยู่แล้ว (อาจจะเป็น status '1' หรือ '2' ก็ได้)
            # ต้องมั่นใจว่าเรา UPDATE ให้ status กลับมาเป็น '1' และเปลี่ยน Order ให้ตรงกับ Text ล่าสุด
            sql_update = f"""
                UPDATE {table_relationship} 
                SET {status_relationship_column} = '1'
            """
            # เพิ่มการ Update Order เฉพาะตารางที่มีคอลัมน์ลำดับ
            params = [Prof_ID, t_id]
            if table_relationship != 'prof_experience_relationship':
                sql_update += ", Relationship_Order = %s "
                params.insert(0, current_order) # แทรก current_order ไว้หน้าสุดของ params
            sql_update += f" WHERE Prof_ID = %s AND {tag_id_column} = %s"
            cur.execute(sql_update, tuple(params))

def delete_expertise_process(cur, Prof_Relationship_IDs: list, state: str, state2: str):
    if not Prof_Relationship_IDs:
        return
    
    if state != 'delete':
        employ_query = "UPDATE prof_employees SET Member_Status = '2'"
        gallery_query = "UPDATE proj_gallery SET Image_Status = '2'"
        relationship_query = "UPDATE proj_prof_relationship SET Relationship_Status = '2'"
    else:
        employ_query = "delete from prof_employees"
        gallery_query = "delete from proj_gallery"
        relationship_query = "delete from proj_prof_relationship"
    
    format_rel = ','.join(['%s'] * len(Prof_Relationship_IDs))
    if state2 == "prof":
        # 1. หา ID ของ proj_prof_relationship ทั้งหมดที่เกี่ยวข้อง
        cur.execute(f"SELECT ID FROM proj_prof_relationship WHERE Prof_Expertise_Relationship_ID IN ({format_rel}) AND Relationship_Status = '1'", tuple(Prof_Relationship_IDs)) #xx
        rows = cur.fetchall()
        proj_rel_ids = [row['ID'] for row in rows]
    else:
        proj_rel_ids = Prof_Relationship_IDs
    
    if proj_rel_ids:
        format_proj = ','.join(['%s'] * len(proj_rel_ids))
        
        # 2. Update ตารางลูก (Employees และ Gallery) ทีเดียวเลย
        cur.execute(f"{employ_query} WHERE Proj_Profs_Relationship_ID IN ({format_proj}) AND Member_Status = '1'", tuple(proj_rel_ids))
        
        cur.execute(f"{gallery_query} WHERE Proj_Profs_Relationship_ID IN ({format_proj}) AND Image_Status = '1'", tuple(proj_rel_ids))
    # 3. Update สถานะของ Relationship หลัก
    if state == 'delete_prof':
        cur.execute(f"{relationship_query} WHERE Prof_Expertise_Relationship_ID IN ({format_rel}) AND Relationship_Status = '1'", tuple(Prof_Relationship_IDs))
    else:
        if proj_rel_ids:
            for data in proj_rel_ids:
                cur.execute(f"SELECT Proj_ID FROM proj_prof_relationship WHERE ID = %s AND Relationship_Status = '1'", (data,))
                proj_id = cur.fetchone()
                path_folder = os.path.join(UPLOAD_DIR, "project", f"{proj_id['Proj_ID']:04d}", "gallery", f"{data:04d}")
                if os.path.exists(path_folder):
                    shutil.rmtree(path_folder)
            cur.execute(f"{relationship_query} WHERE ID IN ({format_proj}) AND Relationship_Status = '1'", tuple(proj_rel_ids)) #xx

def url_work(cur, new_id, Name_EN, state):
    pattern = r'[!@#$%^&*()_+{}\[\]:;<>,.?~\\|/`\'"-]'
    project_url_tag = re.sub(r'\s+', '-', re.sub(pattern, '', Name_EN)).lower() + '-' + str(new_id).rjust(4, '0')
    
    if state == 'proj':
        table = 'projects'
        column = 'Proj_URL_Tag'
    elif state == 'prof':
        table = 'professionals'
        column = 'Prof_URL_Tag'
    else:
        table = 'product_entities'
        column = 'Entity_URL_Tag'
    
    update_sql = f"""UPDATE {table}
                    SET {column}=%s
                    WHERE ID=%s"""
    cur.execute(update_sql, (project_url_tag, new_id))

def update_owners(cur, Prof_ID: int, Owner_Text: str, state: str):
    cur.execute("SELECT First_Name_EN, Last_Name_EN, First_Name_TH, Last_Name_TH, Owner_Order FROM prof_owners WHERE Prof_ID = %s and Owner_Status = '1'", (Prof_ID,))
    existing_rows = cur.fetchall()
    existing_owners = {(
        (r['First_Name_EN'] or "").strip(),
        (r['Last_Name_EN'] or "").strip(),
        (r['First_Name_TH'] or "").strip(),
        (r['Last_Name_TH'] or "").strip(),
        str(r['Owner_Order']).strip() if r['Owner_Order'] is not None else ""
    ) for r in existing_rows}

    new_owners = set()
    if Owner_Text:
        owner_list = Owner_Text.split(';')
        for person in owner_list:
            data = [d.strip() if d.strip().lower() != 'none' else "" for d in person.split(',')]
            if len(data) == 5:
                new_owners.add(tuple(data))
    if existing_owners == new_owners:
        return

    to_delete = existing_owners - new_owners
    if state != 'delete':
        owner_query = "update prof_owners set Owner_Status = '2'"
    else:
        owner_query = "delete from prof_owners"
    for person in to_delete:
        cur.execute(f"""
                        {owner_query}
                        WHERE Prof_ID = %s 
                        AND IFNULL(First_Name_EN, '') = %s 
                        AND IFNULL(Last_Name_EN, '') = %s 
                        AND IFNULL(First_Name_TH, '') = %s 
                        AND IFNULL(Last_Name_TH, '') = %s
                        AND IFNULL(Owner_Order, '') = %s
                    """, (Prof_ID, person[0], person[1], person[2] or '', person[3] or '', person[4] or ''))

    to_add = new_owners - existing_owners
    for person in to_add:
        person_to_insert = [None if str(p).strip() == "" else p for p in person]
        cur.execute("""
            INSERT INTO prof_owners (Prof_ID, First_Name_EN, Last_Name_EN, First_Name_TH, Last_Name_TH, Owner_Order, Owner_Status) 
            VALUES (%s, %s, %s, %s, %s, %s, '1')
        """, (Prof_ID, *person_to_insert))

def _delete_cover(cur, ref_id, cover_ratio: str, state: str):
    if state == 'prof':
        table = 'prof_cover'
        id_column = 'Prof_ID'
    elif state == 'proj':
        table = 'proj_cover'
        id_column = 'Proj_ID'
    else:
        table = 'product_cover'
        id_column = 'Entity_ID'
    
    cur.execute(f"SELECT ID,{id_column},Image_URL, Ratio_Type FROM {table} WHERE {id_column}=%s and Ratio_Type = %s and Image_Status = '1'", (ref_id, cover_ratio))
    rows = cur.fetchall()
    if not rows:
        return
    
    for each_cover in rows:
        cur.execute(f"DELETE FROM {table} WHERE ID=%s", (each_cover[0],))
        affected = cur.rowcount

        if affected > 0:
            dest_path = os.path.join('/var/www/html', each_cover[2].lstrip('/'))
            os.remove(dest_path)

def _delete_image(cur, cover_id: int, action: str, relationship_id, state: str):
    if state == 'prof':
        table = 'prof_gallery'
        id_column = 'Prof_ID'
    elif state == 'proj':
        table = 'proj_gallery'
        id_column = 'Proj_Profs_Relationship_ID'
    else:
        table = 'product_gallery'
        id_column = 'Entity_ID'
    
    image_size_list = [(1440,810),(800,450),(400,225)]
    cur.execute(f"SELECT {id_column}, Image_Order FROM {table} WHERE ID=%s", (cover_id,))
    row = cur.fetchone()
    if not row:
        return
    (ref_id, display_order) = row
    
    if action == "Delete_Image":
        cur.execute(f"DELETE FROM {table} WHERE ID=%s", (cover_id,))
        affected = cur.rowcount

        if affected > 0:
            cur.execute(f"SELECT ID FROM {table} WHERE {id_column}=%s AND Image_Order>%s", (ref_id, display_order))
            rows = cur.fetchall()
            for row in rows:
                cur.execute(f"UPDATE {table} SET Image_Order=Image_Order-1 WHERE ID=%s", (row[0],))
            
            if state == "prof":
                path_folder = os.path.join(UPLOAD_DIR, "professional", str(f"{ref_id:04d}"), "gallery")
            elif state == "proj":
                cur.execute(f"SELECT Proj_ID FROM proj_prof_relationship WHERE ID=%s", (relationship_id,))
                proj_id = cur.fetchone()
                path_folder = os.path.join(UPLOAD_DIR, "project", str(f"{proj_id[0]:04d}"), "gallery", str(f"{relationship_id:04d}"))
            else:
                path_folder = os.path.join(UPLOAD_DIR, "product", str(f"{ref_id:04d}"), "gallery")
            
            for image_size in image_size_list:
                filename = f"{cover_id:06d}-H-{image_size[0]}.webp"
                dest_path = os.path.join(path_folder, filename)
                os.remove(dest_path)
    else:
        cur.execute(f"UPDATE {table} SET Image_Status='2' WHERE ID=%s", (cover_id,))

def _insert_cover_record(cur, ref_id: int, image_name: str, image_url: str, ratio_type: str, image_status: str, state: str) -> dict:
    if state == 'prof':
        table = 'prof_cover'
        id_column = 'Prof_ID'
    elif state == 'proj':
        table = 'proj_cover'
        id_column = 'Proj_ID'
    else:
        table = 'product_cover'
        id_column = 'Entity_ID'
    
    sql = f"""INSERT INTO {table}
                ({id_column}, Cover_Name, Image_Url, Ratio_Type, Image_Status)
            VALUES (%s, %s, %s, %s, %s)"""
    cur.execute(sql, (ref_id, image_name, image_url, ratio_type, image_status))
    new_id = cur.lastrowid

    # ดึงเรคคอร์ดที่เพิ่ง insert
    cur.execute(
            f"""SELECT
                    ID, {id_column}, Cover_Name, Image_Url, Ratio_Type, Image_Status
                FROM {table}
                WHERE ID=%s""",
        (new_id,))
    row = cur.fetchone()
    return row

def _save_image_file(f: bytes, image_id: int, ref_id: int, image_type: str, type_name: str, relationship_id, image_size: tuple, ratio: str) -> dict:
    width, height = image_size
    if image_type == "Cover":
        if type_name == "prof":
            path_folder = os.path.join(UPLOAD_DIR, "professional", str(f"{ref_id:04d}"), "cover")
        elif type_name == "proj":
            path_folder = os.path.join(UPLOAD_DIR, "project", str(f"{ref_id:04d}"), "cover")
        else:
            path_folder = os.path.join(UPLOAD_DIR, "product", str(f"{ref_id:04d}"), "cover")
    elif image_type == "Logo":
        if type_name == "prof":
            path_folder = os.path.join(UPLOAD_DIR, "professional", str(f"{ref_id:04d}"), "logo")
        else:
            path_folder = os.path.join(UPLOAD_DIR, "product", str(f"{ref_id:04d}"), "logo")
        ratio_code = "S"
        filename = f"{ref_id:06d}-{ratio_code}-{width}.webp"
    else:
        if type_name == "prof":
            path_folder = os.path.join(UPLOAD_DIR, "professional", str(f"{ref_id:04d}"), "gallery")
        elif type_name == "proj":
            path_folder = os.path.join(UPLOAD_DIR, "project", str(f"{ref_id:04d}"), "gallery", str(f"{relationship_id:04d}"))
        else:
            path_folder = os.path.join(UPLOAD_DIR, "product", str(f"{ref_id:04d}"), "gallery")
    
    if ratio == "16:9" or ratio == "3:2":
        ratio_code = "H"
    elif ratio == "9:16":
        ratio_code = "V"
    elif ratio == "1:1":
        ratio_code = "S"

    if image_type != "Logo":
        filename = f"{image_id:06d}-{ratio_code}-{width}.webp"
    
    os.makedirs(path_folder, exist_ok=True)  # create if not exists
    dest_path = os.path.join(path_folder, filename)
    
    if image_type == "Cover" or image_type == "Logo":
        image = Image.open(BytesIO(f)).convert("RGB")
        image = ImageOps.fit(image, image_size, Image.Resampling.LANCZOS)
        image.save(dest_path, "WEBP", quality=65)
    else:
        image = WandImage(file=BytesIO(f))
        original_width, original_height = image.width, image.height
        if original_width > width or original_height > height:
            image.transform(resize=f"{width}x{height}")
        image.format = 'webp'
        image.compression_quality = 65
        image.save(filename=dest_path)
    
    image_url = re.sub(r'^/var/www/html', '', dest_path)

    return {
        "filename": filename,
        "path": dest_path,
        "url": image_url
    }

def _update_cover_record(
    cur, cover_id, cover_url: str, state: str
) -> dict:
    if state == 'prof':
        table = 'prof_cover'
    elif state == 'proj':
        table = 'proj_cover'
    else:
        table = 'product_cover'
    
    sql = f"""
        UPDATE {table}
        SET Image_Url=%s
        WHERE ID=%s
    """
    cur.execute(sql, (cover_url, cover_id))

def _get_image_display_order(cur, ref_id: int, state: str) -> int:
    if state == 'prof':
        table = 'prof_gallery'
        id_column = 'Prof_ID'
    elif state == 'proj':
        table = 'proj_gallery'
        id_column = 'Proj_Profs_Relationship_ID'
    else:
        table = 'product_gallery'
        id_column = 'Entity_ID'
    
    cur.execute(f"""SELECT MAX(Image_Order) as max_order FROM {table} WHERE {id_column}=%s and Image_Status = '1'""", (ref_id,))
    row = cur.fetchone()
    if row['max_order'] is None:
        return 1
    else:
        return row['max_order'] + 1

def _insert_image_record(cur, ref_id: int, state: str, image_name, image_url, display_order: int, image_status, image_description) -> dict:
    # ตัดชื่อไฟล์ให้ไม่เกิน 100 ตัวอักษรตาม schema
    image_name = image_name[:100] if image_name else None
    if state == 'prof':
        table = 'prof_gallery'
        id_column = 'Prof_ID'
    elif state == 'proj':
        table = 'proj_gallery'
        id_column = 'Proj_Profs_Relationship_ID'
    else:
        table = 'product_gallery'
        id_column = 'Entity_ID'
    
    cur.execute(f"""INSERT INTO {table} ({id_column}, Image_Name, Image_URL, Image_Order, Image_Status, Image_Description)
                VALUES (%s, %s, %s, %s, %s, %s)""", (ref_id, image_name, image_url, display_order, image_status, image_description))
    new_id = cur.lastrowid

    # ดึงเรคคอร์ดที่เพิ่ง insert
    cur.execute(
        f"""SELECT
                ID, {id_column}, Image_Name, Image_URL, Image_Order, Image_Status, Image_Description
            FROM {table}
            WHERE ID=%s""",
        (new_id,)
    )
    row = cur.fetchone()
    return row

def _update_image_record(cur, image_id, image_url: str, state: str) -> dict:
    if state == 'prof':
        table = 'prof_gallery'
    elif state == 'proj':
        table = 'proj_gallery'
    else:
        table = 'product_gallery'
    
    sql = f"""
        UPDATE {table}
        SET Image_Url=%s
        WHERE ID=%s
    """
    cur.execute(sql, (image_url, image_id))

def _update_image_order(
    cur, image_id, display_order: int, table_name: str,
) -> dict:
    sql = f"""
        UPDATE {table_name}
        SET Image_Order=%s
        WHERE ID=%s
    """
    cur.execute(sql, (display_order, image_id))
    
    return {
        "image_id": image_id,
        "display_order": display_order,
    }

def recover_proj_prof_relationship(cur, ref_id: int, state: str):
    id_list = []
    if state == 'prof':
        column_id = 'Proj_ID'
        cur.execute(f"""select ID from prof_expertise_relationship where Prof_ID = %s""", (ref_id,))
        rows = cur.fetchall()
        prof_ext_list = list(set(row['ID'] for row in rows))
        for prof_ext_id in prof_ext_list:
            cur.execute(f"""select Proj_ID from proj_prof_relationship where Prof_Expertise_Relationship_ID = %s""", (prof_ext_id,))
            rows = cur.fetchall()
            proj_list = list(set(row['Proj_ID'] for row in rows))
            for proj_id in proj_list:
                proj = _select_full_proj_item(proj_id)
                proj_status = proj['Proj_Status']
                if proj_status == '1':
                    id_list.append(proj_id)
    else:
        column_id = 'Prof_Expertise_Relationship_ID'
        cur.execute(f"""select Prof_Expertise_Relationship_ID from proj_prof_relationship where Proj_ID = %s""", (ref_id,))
        rows = cur.fetchall()
        prof_ext_list = list(set(row['Prof_Expertise_Relationship_ID'] for row in rows))
        for prof_ext_id in prof_ext_list:
            cur.execute(f"""select Prof_ID from prof_expertise_relationship where ID = %s""", (prof_ext_id,))
            row = cur.fetchone()
            prof_id = row['Prof_ID']
            prof = _select_full_prof_item(prof_id)
            prof_status = prof['Prof_Status']
            if prof_status == '1':
                id_list.append(prof_ext_id)
    
    for each_id in id_list:
        cur.execute(f"""update proj_prof_relationship set Relationship_Status = '1' where {column_id} = %s""", (each_id,))
        
        cur.execute(f"""select ID from proj_prof_relationship where {column_id} = %s""", (each_id,))
        rows = cur.fetchall()
        for row in rows:
            cur.execute(f"""update proj_gallery set Image_Status = '1' where Proj_Profs_Relationship_ID = %s""", (row['ID'],))
            cur.execute(f"""update prof_employees set Member_Status = '1', Last_Updated_Date = CURRENT_TIMESTAMP where Proj_Profs_Relationship_ID = %s""", (row['ID'],))

def _select_proj_cate(proj_id: int, state: str) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    if state == 'header':
        #column_query = ", concat(b.Category_Name, ' | ', c.Category_Name) as Category_Header"
        column_query = ", group_concat(UPPER(b.Category_Name) order by a.Relationship_Order separator ' | ') as Category_Header"
        order_query = "and a.Relationship_Order <= 3"
        group_by_query = ""
    elif state == 'full':
        column_query = ", group_concat(UPPER(b.Category_Name) order by a.Relationship_Order separator ' | ') as Category_Group"
        order_query = ""
        group_by_query = "group by a.Proj_ID"
    
    cur2.execute(
        f"""SELECT
                a.Proj_ID
                {column_query}
            from proj_category_relationship a
            join proj_categories b on a.Category_ID = b.ID
            join proj_categories c on b.Parent_ID = c.ID
            where a.Relationship_Status = '1'
            and b.Categories_Status = '1'
            and c.Categories_Status = '1'
            {order_query}
            and a.Proj_ID = %s
            {group_by_query}""",
        (proj_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return row

def _select_proj_cover(proj_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cover_list = []
    cur2.execute(
        f"""SELECT
                a.Image_URL
                , a.Ratio_Type
            from proj_cover a
            where a.Image_Status = '1'
            and a.Proj_ID = %s
            and a.Ratio_Type in ('16:9', '9:16')""",
        (proj_id,)
    )
    rows = cur2.fetchall()
    for row in rows:
        row['Image_URL'] = row['Image_URL']
        cover_list.append(row)
    
    cur2.close()
    conn2.close()
    return cover_list

def proj_lastest_date(proj_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                a.ID
                , GREATEST(COALESCE(YEAR(Start_Date), 0), COALESCE(YEAR(Finish_Date), 0), COALESCE(YEAR(Renovated_Date), 0)) as Latest_Date
                , YEAR(Start_Date) as Start_Date
                , YEAR(Finish_Date) as Finish_Date
                , YEAR(Renovated_Date) as Renovated_Date
            from projects a
            where a.ID = %s""",
        (proj_id,)
    )
    row = cur2.fetchone()
    
    cur2.close()
    conn2.close()
    return row

def proj_responsibilities(proj_id: int, state: str) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    if state == 'hide':
        content_query = "and a.Content is not null"
    else:
        content_query = ""
    
    cur2.execute(
        f"""select
            c.Name_EN as Prof_Name
            , d.Responsibility
            , group_concat(concat_ws(' ',e.First_Name_EN, e.Last_Name_EN) ORDER BY isnull(e.Member_Order), e.Member_Order, e.First_Name_EN,e.Last_Name_EN separator ', ') as Member_Name
            , if(a.Content is not null 
                , concat(LPAD(b.Expertise_ID,2,'0'),'-',replace(c.Name_EN,' ','-'))
                , null) as Anchor
            , if(f.Url_Status = 1, c.Prof_URL_Tag, null) as Prof_Url
            from proj_prof_relationship a
            join prof_expertise_relationship b on a.Prof_Expertise_Relationship_ID = b.ID
            join professionals c on b.Prof_ID = c.ID
            join prof_expertise d on b.Expertise_ID = d.ID
            left join prof_employees e on a.ID = e.Proj_Profs_Relationship_ID and e.Member_Status = '1'
            left join prof_url f on c.ID = f.Prof_ID
            where a.Relationship_Status = '1'
            {content_query}
            and b.Relationship_Status = '1'
            and c.Prof_Status = '1'
            and d.Expertise_Status = '1'
            and a.Proj_ID = %s
            group by c.Name_EN, d.Responsibility, b.Expertise_ID, a.Content, c.Prof_URL_Tag, f.Prof_ID, c.Logo_URL
            order by d.Expertise_Order, ISNULL(a.Content), c.Name_EN""",
        (proj_id,)
    )
    rows = cur2.fetchall()
    grouped_data = {}
    for item in rows:
        res_type = item["Responsibility"]
        if res_type not in grouped_data:
            grouped_data[res_type] = []
        
        prof_entry = {
            "Prof_Name": item["Prof_Name"],
            "Member": f"({item['Member_Name']})" if item.get("Member_Name") else None,
            "Anchor": item.get("Anchor", False),
            "Prof_Url": item["Prof_Url"]
        }
        grouped_data[res_type].append(prof_entry)

    final_result = []
    for res, prof_list in grouped_data.items():
        final_result.append({
            "Res": res,
            "Prof": prof_list
        })
    
    cur2.close()
    conn2.close()
    return final_result

def proj_content(proj_id: int):
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    cur2.execute(
        f"""select
            UPPER(d.Content_Header) as Topic
            , c.Name_EN as Prof
            , concat(LPAD(b.Expertise_ID,2,'0'),'-',replace(c.Name_EN,' ','-')) as Anchor
            , a.Content
            , c.ID as Prof_ID
            , if(f.Url_Status = 1, c.Prof_URL_Tag, null) as Prof_Url
            from proj_prof_relationship a
            join prof_expertise_relationship b on a.Prof_Expertise_Relationship_ID = b.ID
            join professionals c on b.Prof_ID = c.ID
            join prof_expertise d on b.Expertise_ID = d.ID
            left join prof_url f on c.ID = f.Prof_ID
            where a.Relationship_Status = '1'
            and b.Relationship_Status = '1'
            and c.Prof_Status = '1'
            and d.Expertise_Status = '1'
            and a.Proj_ID = %s
            and a.Content is not null
            group by c.Name_EN, d.Responsibility, b.Expertise_ID, a.Content, c.ID
            order by d.Expertise_Order, c.Name_EN""",
        (proj_id,)
    )
    final_result = cur2.fetchall()
    prof_list = list(set(row["Prof_ID"] for row in final_result))
    
    cur2.close()
    conn2.close()
    
    if final_result:
        return final_result, prof_list
    else:
        return None, None 

def proj_gallery(proj_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    final_result = []
    cur2.execute(
        f"""select d.Content_Header,
                e.Image_URL as Url
                , ROW_NUMBER() OVER (ORDER BY d.Expertise_Order, ISNULL(a.Content), c.Name_EN, e.Image_Order) as Image_Order
                , e.Image_Name as Image_Name
                , e.Image_Description as Image_Description
            from proj_prof_relationship a
            join prof_expertise_relationship b on a.Prof_Expertise_Relationship_ID = b.ID and b.Relationship_Status = '1'
            join prof_expertise d on b.Expertise_ID = d.ID and d.Expertise_Status = '1'
            join proj_gallery e on a.ID = e.Proj_Profs_Relationship_ID and e.Image_Status = '1'
            join professionals c on b.Prof_ID = c.ID and c.Prof_Status = '1'
            where a.Relationship_Status = '1'
            and a.Proj_ID = %s
            order by d.Expertise_Order, ISNULL(a.Content), c.Name_EN, e.Image_Order""",
        (proj_id,)
    )
    rows = cur2.fetchall()
    grouped_data = {}
    image_size_list = [(1440,810),(800,450),(400,225)]
    for item in rows:
        header_type = item["Content_Header"]
        if header_type not in grouped_data:
            grouped_data[header_type] = []
        
        original_name = item["Url"]
        last_part = original_name.split("-")[-1]
        image_urls = []
        for width, height in image_size_list:
            new_last_part = re.sub(r'^\d+', str(width), last_part)
            image_urls.append(original_name.replace(last_part, new_last_part))
        gallery_entry = {
            "Url": image_urls,
            "Image_Order": item["Image_Order"],
            "Image_Name": item["Image_Name"],
            "Image_Description": item["Image_Description"]
        }
        grouped_data[header_type].append(gallery_entry)

    final_result = []
    for header, gallery_list in grouped_data.items():
        final_result.append({
            "Header": header,
            "Gallery": gallery_list
        })
    
    cur2.close()
    conn2.close()
    
    if final_result:
        return final_result
    else:
        return None

def get_gallery(ref_id: int, state: str) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    final_result = []
    if state == 'prof':
        query = f"""select a.Image_URL as Url
                    , a.Image_Name as Image_Name
                    , a.Image_Description as Image_Description
                    , a.Image_Order
                from prof_gallery a
                where a.Image_Status = '1'
                and a.Prof_ID = %s
                order by a.Image_Order"""
    else:
        query = f"""select a.Image_URL as Url
                    , a.Image_Name as Image_Name
                    , a.Image_Description as Image_Description
                    , a.Image_Order
                from product_gallery a
                where a.Image_Status = '1'
                and a.Entity_ID = %s
                order by a.Image_Order"""

    cur2.execute(query, (ref_id,))
    rows = cur2.fetchall()
    grouped_data = []
    image_size_list = [(1440,810),(800,450),(400,225)]
    for item in rows:
        original_name = item["Url"]
        last_part = original_name.split("-")[-1]
        image_urls = []
        for width, height in image_size_list:
            new_last_part = re.sub(r'^\d+', str(width), last_part)
            image_urls.append(original_name.replace(last_part, new_last_part))
        gallery_entry = {
            "Url": image_urls,
            "Image_Order": item["Image_Order"],
            "Image_Name": item["Image_Name"],
            "Image_Description": item["Image_Description"]
        }
        grouped_data.append(gallery_entry)

    final_result = []
    for gallery_list in grouped_data:
        final_result.append({
            "Gallery": gallery_list
        })
    
    cur2.close()
    conn2.close()
    
    if final_result:
        return final_result
    else:
        return None

def get_proj_category_id(cur, proj_id, state):
    more_query = ''
    if state != 'more':
        more_query = 'and a.Relationship_Order = 1'
    
    cur.execute(f"""select a.Proj_ID, a.Category_ID as Sub_Cate, b.Parent_ID as Head_Cate
                from proj_category_relationship a
                join proj_categories b on a.Category_ID = b.ID and b.Categories_Status = '1'
                where a.Relationship_Status = '1'
                and a.Proj_ID = %s
                {more_query}""", (proj_id,))
    rows = cur.fetchall()
    if not rows:
        return [] if state == 'more' else (None, None)

    if state == 'more':
        return [row["Sub_Cate"] for row in rows]
    else:
        return rows[0]["Sub_Cate"], rows[0]["Head_Cate"]

def get_similar_proj(prof_ids: list, proj_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    format_strings = ','.join(['%s'] * len(prof_ids))
    cur2.execute(
        f"""select
                c.ID as Prof_ID
                , c.Name_EN as Prof
                , c.Logo_URL as Image
                , prof_ext.Expertise as Res
                , prof_exp.Categories as Experience
                , if(f.Url_Status = 1, concat('metro/prof/', c.Prof_URL_Tag), null) as Prof_Url
            from proj_prof_relationship a
            join prof_expertise_relationship b on a.Prof_Expertise_Relationship_ID = b.ID
            join professionals c on b.Prof_ID = c.ID
            left join prof_url f on c.ID = f.Prof_ID
            left join (SELECT 
                            t.Prof_ID, 
                            group_concat(UPPER(t.Category_Name) order by row_num separator ' | ') AS Categories
                        FROM (  SELECT
                                    b.Prof_ID,
                                    d.Category_Name,
                                    c.Relationship_Order,
                                    ROW_NUMBER() OVER (PARTITION BY b.Prof_ID ORDER BY COUNT(DISTINCT ra.Proj_ID) DESC) as row_num 
                                FROM proj_prof_relationship ra
                                JOIN prof_expertise_relationship b ON ra.Prof_Expertise_Relationship_ID = b.ID AND b.Relationship_Status = '1'
                                JOIN proj_category_relationship c ON ra.Proj_ID = c.Proj_ID AND c.Relationship_Status = '1'
                                join proj_categories d on c.Category_ID = d.ID and d.Categories_Status = '1'
                                WHERE ra.Relationship_Status = '1'
                                GROUP BY b.Prof_ID, d.Category_Name, c.Relationship_Order
                        ) t
                        WHERE t.row_num <= 2
                        GROUP BY t.Prof_ID) prof_exp
            on c.ID = prof_exp.Prof_ID
            left join (SELECT 
                            t.Prof_ID, 
                            t.Expertise
                        FROM (
                            SELECT 
                                b.Prof_ID,
                                a.Proj_ID, 
                                c.Responsibility as Expertise,
                                ROW_NUMBER() OVER (PARTITION BY b.Prof_ID ORDER BY b.Relationship_Order) as row_num
                            from proj_prof_relationship a
                            join prof_expertise_relationship b on a.Prof_Expertise_Relationship_ID = b.ID
                            JOIN prof_expertise c ON b.Expertise_ID = c.ID
                            WHERE b.Relationship_Status = '1'
                            AND c.Expertise_Status = '1'
                            and a.Relationship_Status = '1'
                            and a.Content is not null
                        ) t
                        WHERE t.row_num = 1) prof_ext
            on c.ID = prof_ext.Prof_ID
            where a.Relationship_Status = '1'
            and b.Relationship_Status = '1'
            and c.Prof_Status = '1'
            and c.ID in ({format_strings})
            group by c.ID, c.Name_EN, c.Logo_URL, prof_ext.Expertise, prof_exp.Categories""",
        tuple(prof_ids)
    )
    rows = cur2.fetchall()
    
    prof_list = []
    for row in rows:
        prof_list.append(row)
    
    if prof_list:
        sub_cate, head_cate = get_proj_category_id(cur2, proj_id, 'similar')
        for prof in prof_list:
            cur2.execute(f"""SELECT 
                            aaa.Prof_ID,
                            aaa.Proj_ID,
                            aaa.Proj_Name as Name,
                            aaa.Display_Category as Category,
                            aaa.Proj_URL_Tag as URL,
                            aaa.Latest_Date as Year
                        FROM (
                            SELECT 
                                b.Prof_ID, 
                                a.Proj_ID, 
                                c.Name_EN as Proj_Name, 
                                c.Proj_URL_Tag,
                                cate.Display_Category,
                                d.Category_ID,
                                e.Parent_ID,
                                GREATEST(COALESCE(YEAR(c.Start_Date), 0), COALESCE(YEAR(c.Finish_Date), 0), COALESCE(YEAR(c.Renovated_Date), 0)) as Latest_Date,
                                -- ใช้ ROW_NUMBER เพื่อคัดเลือกหมวดหมู่ที่ "ใช่ที่สุด" เพียงอันเดียวต่อโปรเจกต์
                                ROW_NUMBER() OVER (
                                    PARTITION BY c.ID 
                                    ORDER BY 
                                        (CASE WHEN d.Category_ID = %s THEN 1 ELSE 2 END) ASC,
                                        d.Relationship_Order ASC
                                ) as row_num
                            FROM proj_prof_relationship a
                            JOIN prof_expertise_relationship b ON a.Prof_Expertise_Relationship_ID = b.ID
                            JOIN projects c ON a.Proj_ID = c.ID
                            JOIN proj_category_relationship d ON a.Proj_ID = d.Proj_ID AND d.Relationship_Status = '1'
                            JOIN proj_categories e ON d.Category_ID = e.ID AND e.Categories_Status = '1'
                            left join (select a.Proj_ID, group_concat(UPPER(b.Category_Name) order by a.Relationship_Order separator ' | ') as Display_Category
                                        from proj_category_relationship a
                                        join proj_categories b on a.Category_ID = b.ID AND b.Categories_Status = '1'
                                        where a.Relationship_Order <= 3
                                        group by a.Proj_ID) cate
                            on c.ID = cate.Proj_ID
                            WHERE a.Relationship_Status = '1'
                            AND b.Relationship_Status = '1'
                            AND c.Proj_Status = '1'
                            AND a.Proj_ID <> %s
                            AND b.Prof_ID = %s
                        ) aaa
                        -- เลือกแถวที่ 1 ที่ผ่านการเรียงลำดับความสำคัญในหมวดหมู่มาแล้ว
                        WHERE aaa.row_num = 1 
                        AND (aaa.Category_ID = %s OR aaa.Parent_ID = %s)
                        ORDER BY 
                            -- เรียงตามความสดใหม่และหมวดหมู่ที่ตรงกัน
                            (CASE WHEN aaa.Category_ID = %s THEN 1 ELSE 2 END) ASC, 
                            aaa.Latest_Date DESC
                        LIMIT 3""", 
                    (sub_cate, proj_id, prof['Prof_ID'], sub_cate, head_cate, sub_cate))
            rows = cur2.fetchall()
            for row in rows:
                cur2.execute(f"""SELECT Image_Url from proj_cover where Ratio_Type = '3:2' and Image_Status = '1' and Proj_ID = %s""", (row["Proj_ID"],))
                images = cur2.fetchall()
                row["Cover"] = images if images else None
            prof["Proj"] = rows if rows else None
    
    cur2.close()
    conn2.close()
    
    if prof_list:
        return prof_list
    else:
        return None

def proj_more(proj_id: int):
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    sub_cate = get_proj_category_id(cur2, proj_id, 'more')
    if sub_cate:
        placeholders = ', '.join(['%s'] * len(sub_cate))
        more = {}
        raw_query = f"""SELECT 
                            aaa.Proj_ID,
                            aaa.Proj_Name as Name,
                            aaa.Display_Category as Proj_Category,
                            aaa.Proj_URL_Tag as URL
                        FROM (
                            SELECT 
                                c.ID as Proj_ID, 
                                c.Name_EN as Proj_Name, 
                                c.Proj_URL_Tag,
                                cate.Display_Category,
                                GREATEST(COALESCE(YEAR(c.Start_Date), 0), COALESCE(YEAR(c.Finish_Date), 0), COALESCE(YEAR(c.Renovated_Date), 0)) as Latest_Date,
                                e.Categories_Order,
                                -- คำนวณความสำคัญ: ย่อยตรง (1-99) > ใหญ่ตรง (100+)
                                CASE 
                                    WHEN ref_sub.Relationship_Order IS NOT NULL THEN ref_sub.Relationship_Order
                                    WHEN ref_parent.Min_Order IS NOT NULL THEN 100 + ref_parent.Min_Order
                                    ELSE 999 
                                END as Final_Priority,
                                -- สำคัญ: เลือกแถวที่ "ดีที่สุด" ของโปรเจกต์นั้นมาโชว์ (ตัวที่ตรงเงื่อนไขที่สุด)
                                ROW_NUMBER() OVER (
                                    PARTITION BY c.ID 
                                    ORDER BY 
                                        (CASE 
                                            WHEN d.Category_ID IN ({placeholders}) THEN 1 
                                            WHEN e.Parent_ID IN (SELECT DISTINCT Parent_ID FROM proj_categories WHERE ID IN ({placeholders})) THEN 2 
                                            ELSE 3 
                                        END) ASC,
                                        d.Relationship_Order ASC
                                ) as row_num
                            FROM projects c
                            JOIN proj_category_relationship d ON c.ID = d.Proj_ID AND d.Relationship_Status = '1'
                            JOIN proj_categories e ON d.Category_ID = e.ID AND e.Categories_Status = '1'
                            -- Join เพื่อเช็คหมวดหมู่ย่อยที่ตรงกับโปรเจกต์ตั้งต้น (ใช้หา Priority 1-99)
                            LEFT JOIN proj_category_relationship ref_sub ON d.Category_ID = ref_sub.Category_ID AND ref_sub.Proj_ID = %s AND ref_sub.Relationship_Status = '1'
                            -- Join เพื่อเช็คหมวดหมู่ใหญ่ที่ตรงกัน (ใช้หา Priority 101-199)
                            LEFT JOIN (
                                SELECT p.Parent_ID, MIN(r.Relationship_Order) as Min_Order
                                FROM proj_category_relationship r
                                JOIN proj_categories p ON r.Category_ID = p.ID
                                WHERE r.Proj_ID = %s AND r.Relationship_Status = '1'
                                GROUP BY p.Parent_ID
                            ) ref_parent ON e.Parent_ID = ref_parent.Parent_ID
                            -- ดึงชื่อหมวดหมู่มาโชว์
                            LEFT JOIN (
                                SELECT a.Proj_ID, GROUP_CONCAT(UPPER(b.Category_Name) ORDER BY a.Relationship_Order SEPARATOR ' | ') as Display_Category
                                FROM proj_category_relationship a
                                JOIN proj_categories b ON a.Category_ID = b.ID AND b.Categories_Status = '1'
                                WHERE a.Relationship_Order <= 3
                                GROUP BY a.Proj_ID
                            ) cate ON c.ID = cate.Proj_ID
                            WHERE c.Proj_Status = '1'
                            AND c.ID <> %s
                        ) aaa
                        WHERE aaa.row_num = 1 
                        AND aaa.Final_Priority < 999 
                        ORDER BY 
                            aaa.Final_Priority ASC,
                            aaa.Categories_Order ASC,
                            aaa.Latest_Date DESC,
                            aaa.Proj_Name ASC
                        LIMIT 20"""
        query = raw_query.format(placeholders, placeholders)
        params = list(sub_cate) + list(sub_cate) + [proj_id, proj_id, proj_id]
        cur2.execute(query, params)
        rows = cur2.fetchall()
        categories = []
        for row in rows:
            cur2.execute(f"""SELECT Image_Url from proj_cover where Ratio_Type = '3:2' and Image_Status = '1' and Proj_ID = %s""", (row["Proj_ID"],))
            images = cur2.fetchall()
            row["Cover"] = images if images else None
            categories.append(row["Proj_Category"].split(' | ')[0])
        if categories:
            categories = list(set(categories))
            if len(categories) > 1:
                more["Title"] = "MORE PROJECTS"
            else:
                more["Title"] = f"MORE {categories[0].upper()} PROJECTS"
        else:
            more["Title"] = None
        more["Proj"] = rows
    else:
        more = None
    
    cur2.close()
    conn2.close()
    return more

def _select_prof_cover(prof_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cover_list = []
    cur2.execute(
        f"""SELECT
                a.Image_URL
                , a.Ratio_Type
            from prof_cover a
            where a.Image_Status = '1'
            and a.Prof_ID = %s""",
        (prof_id,)
    )
    rows = cur2.fetchall()
    for row in rows:
        row['Image_URL'] = row['Image_URL']
        cover_list.append(row)
    
    cur2.close()
    conn2.close()
    return cover_list

def get_prof_proj(prof_id):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    
    proj_list = []
    cur.execute("""select Proj_ID, Proj_Name, Proj_Category, Proj_Url
                    , ROW_NUMBER() OVER (ORDER BY Latest_Date desc) as Proj_Order
                from (select distinct(c.Name_EN) as Proj_Name, c.ID as Proj_ID, cate.Display_Category as Proj_Category
                        , c.Proj_URL_Tag as Proj_Url
                        , GREATEST(COALESCE(YEAR(c.Start_Date), 0), COALESCE(YEAR(c.Finish_Date), 0), COALESCE(YEAR(c.Renovated_Date), 0)) as Latest_Date
                    from proj_prof_relationship a
                    join prof_expertise_relationship b on a.Prof_Expertise_Relationship_ID = b.ID and b.Relationship_Status = '1'
                    join projects c on a.Proj_ID = c.ID and c.Proj_Status = '1'
                    left join proj_category_relationship d on c.ID = d.Proj_ID and d.Relationship_Status = '1' and d.Relationship_Order = 1
                    left join proj_categories e on d.Category_ID = e.ID and e.Categories_Status = '1'
                    left join (select a.Proj_ID, group_concat(UPPER(b.Category_Name) order by a.Relationship_Order separator ' | ') as Display_Category
                                    from proj_category_relationship a
                                    join proj_categories b on a.Category_ID = b.ID AND b.Categories_Status = '1'
                                    where a.Relationship_Order <= 3
                                    group by a.Proj_ID) cate
                        on c.ID = cate.Proj_ID
                    where a.Relationship_Status = '1'
                    and b.Prof_ID = %s) aaa""", (prof_id,))
    rows = cur.fetchall()
    for row in rows:
        cur.execute(f"""SELECT Image_Url from proj_cover where Ratio_Type = '3:2' and Image_Status = '1' and Proj_ID = %s""", (row["Proj_ID"],))
        images = cur.fetchall()
        row["Image"] = images if images else None
        proj_list.append(row)
    
    cur.close()
    conn.close()
    
    return proj_list

def prof_more(prof_id: int):
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    more = []
    cur2.execute("""select Prof_ID, Prof_Name, Expertise, Logo, Category, Prof_Url
                    from (
                        SELECT 
                            target.Prof_ID, 
                            p.Name_EN as Prof_Name,
                            target.Expertise_ID,
                            UPPER(prof_ext.Responsibility) as Expertise,
                            p.Logo_URL as Logo,
                            p.Prof_URL_Tag as Prof_Url,
                            cate.Category,
                            target.Relationship_Order as Target_Order, -- อันดับความเก่งของคู่แข่ง
                            IFNULL(stats.Count_Proj, 0) as Count_Proj,
                            ref.Relationship_Order as My_Order, -- อันดับความสำคัญตามบริษัท A (1=Landscape, 2=Interior...)
                            ROW_NUMBER() OVER (PARTITION BY target.Prof_ID ORDER BY ref.Relationship_Order, Count_Proj DESC, p.Name_EN) as row_num
                        FROM prof_expertise_relationship ref
                        -- 1. เชื่อมหาคนอื่นที่มี Expertise เดียวกับที่บริษัท A มี
                        JOIN prof_expertise_relationship target ON ref.Expertise_ID = target.Expertise_ID 
                        AND target.Relationship_Status = '1'
                        AND target.Prof_ID <> %s -- ตัดตัวเองออก
                        -- 2. Join เอาชื่อบริษัทคู่แข่ง
                        LEFT JOIN professionals p ON target.Prof_ID = p.ID and p.Prof_Status = '1'
                        join prof_url f on p.ID = f.Prof_ID and f.Url_Status = 1
                        -- 3. Join Subquery นับโปรเจกต์ (แบบที่คุณเขียน)
                        LEFT JOIN (
                            SELECT b.Prof_ID, b.Expertise_ID, COUNT(DISTINCT ra.Proj_ID) as Count_Proj
                            FROM proj_prof_relationship ra
                            JOIN prof_expertise_relationship b ON ra.Prof_Expertise_Relationship_ID = b.ID 
                            WHERE ra.Relationship_Status = '1' AND b.Relationship_Status = '1'
                            GROUP BY b.Prof_ID, b.Expertise_ID
                        ) stats ON target.Prof_ID = stats.Prof_ID AND target.Expertise_ID = stats.Expertise_ID
                        join prof_expertise prof_ext on target.Expertise_ID = prof_ext.ID and prof_ext.Expertise_Status = '1'
                        LEFT JOIN (
                            select Prof_ID
                                , CONCAT_WS(' | ', MAX(CASE WHEN row_num = 1 THEN UPPER(Category_Name) END), MAX(CASE WHEN row_num = 2 THEN UPPER(Category_Name) END)) AS Category
                            from (
                                SELECT
                                    b.Prof_ID,
                                    c.Category_ID,
                                    d.Category_Name,
                                    COUNT(DISTINCT ra.Proj_ID) as Count_Proj,
                                    ROW_NUMBER() OVER (PARTITION BY b.Prof_ID ORDER BY COUNT(DISTINCT ra.Proj_ID) DESC) as row_num 
                                FROM proj_prof_relationship ra
                                JOIN prof_expertise_relationship b ON ra.Prof_Expertise_Relationship_ID = b.ID AND b.Relationship_Status = '1'
                                JOIN proj_category_relationship c ON ra.Proj_ID = c.Proj_ID AND c.Relationship_Status = '1'
                                join proj_categories d on c.Category_ID = d.ID and d.Categories_Status = '1'
                                WHERE ra.Relationship_Status = '1'
                                GROUP BY b.Prof_ID, c.Category_ID) aaa
                            WHERE row_num <= 2
                            group by Prof_ID
                        ) cate ON target.Prof_ID = cate.Prof_ID
                        -- 4. เงื่อนไขบริษัท A
                        WHERE ref.Prof_ID = %s 
                        AND ref.Relationship_Status = '1'
                        AND target.Relationship_Order = 1
                        ORDER BY 
                            -- เรียงตามอันดับ Expertise ของบริษัท A ก่อน (Landscape ก่อน แล้วค่อย Interior...)
                            ref.Relationship_Order ASC, 
                            -- ในหมวดนั้นๆ เรียงตามคนที่ยกให้ด้านนี้เป็นเบอร์ 1 ของเขา
                            -- target.Relationship_Order ASC, 
                            -- เรียงตามจำนวนโปรเจกต์
                            Count_Proj DESC, 
                            -- เรียงตามชื่อ
                            p.Name_EN) aaa
                    where row_num = 1
                    order by My_Order, Count_Proj DESC, Prof_Name
                    limit 20""", (prof_id, prof_id))
    rows = cur2.fetchall()
    for row in rows:
        cur2.execute(f"""SELECT Image_Url from prof_cover where Ratio_Type = '16:9' and Image_URL like '%420%'
                        and Image_Status = '1' and Prof_ID = %s""", (row["Prof_ID"],))
        images = cur2.fetchall()
        row["Cover"] = images if images else None
        more.append(row)
    
    cur2.close()
    conn2.close()
    return more

def update_entity_parent(cur, current_id: int, new_parent_id: int | None, is_update):
    # --- STEP 0: ด่านตรวจการสลับกิ่ง (Swap/Circular Check) ---
    if is_update and new_parent_id:
        cur.execute("SELECT Family_IDS FROM product_entities WHERE ID = %s", (new_parent_id,))
        new_p_data = cur.fetchone()
        
        if new_p_data and str(current_id) in new_p_data['Family_IDS'].split(','):
            # พบว่า "พ่อใหม่" (4) เป็นลูกหลานของ "เรา" (1)
            # ต้องจัดการ "ปลดปล่อย" 4 ให้เป็น Root ก่อน (ตาม Step 4 ใน Excel)
            
            # ลบ 4 ออกจาก Buttom_Parent ของพ่อเดิมของเขา (ซึ่งก็คือเรา 1)
            cur.execute("SELECT Buttom_Parent FROM product_entities WHERE ID = %s", (current_id,))
            res = cur.fetchone()
            if res and res['Buttom_Parent']:
                kids = [k.strip() for k in res['Buttom_Parent'].split(',') if k.strip()]
                if str(new_parent_id) in kids:
                    kids.remove(str(new_parent_id))
                    updated_buttom = ",".join(kids) if kids else None
                    cur.execute("UPDATE product_entities SET Buttom_Parent = %s WHERE ID = %s", (updated_buttom, current_id))

            # ตั้งให้ 4 กลายเป็น Root ชั่วคราว (Parent=NULL, Family=4)
            cur.execute("UPDATE product_entities SET Parent_ID = NULL, Family_IDS = %s, Top_Parent = NULL WHERE ID = %s", 
                        (str(new_parent_id), new_parent_id))

    # --- STEP 1: ล้างมลทิน (ลบตัวเองออกจากพ่อเก่าทุกคน) ---
    if is_update:
        cur.execute("SELECT ID, Buttom_Parent FROM product_entities WHERE FIND_IN_SET(%s, Buttom_Parent) > 0", (current_id,))
        old_parents = cur.fetchall()
        for p in old_parents:
            if p['ID'] != new_parent_id:
                kids = [k.strip() for k in p['Buttom_Parent'].split(',') if k.strip()]
                if str(current_id) in kids:
                    kids = [k for k in kids if k != str(current_id)]
                    new_val = ",".join(kids) if kids else None
                    cur.execute("UPDATE product_entities SET Buttom_Parent = %s WHERE ID = %s", (new_val, p['ID']))

    # --- STEP 2: จัดการสายเลือดใหม่ (คำนวณ Family_IDS ของตัวเอง) ---
    new_family_ids = str(current_id)
    new_top_parent = None
    
    if new_parent_id:
        cur.execute("SELECT Family_IDS, Buttom_Parent FROM product_entities WHERE ID = %s", (new_parent_id,))
        parent = cur.fetchone()
        if parent:
            new_family_ids = f"{parent['Family_IDS']},{current_id}"
            new_top_parent = parent['Family_IDS']
            # เพิ่มตัวเองใน Buttom_Parent ของพ่อใหม่ (เช่น เพิ่ม 1 เข้าไปใน 4)
            kids = [k.strip() for k in parent['Buttom_Parent'].split(',') if k.strip()] if parent['Buttom_Parent'] else []
            if str(current_id) not in kids:
                kids.append(str(current_id))
                cur.execute("UPDATE product_entities SET Buttom_Parent = %s WHERE ID = %s", (",".join(kids), new_parent_id))

    # เก็บสายเลือดเก่าไว้เพื่อใช้ replace ให้ลูกหลาน
    cur.execute("SELECT Family_IDS FROM product_entities WHERE ID = %s", (current_id,))
    old_self_family = cur.fetchone()['Family_IDS']

    # --- STEP 3: อัปเดตตัวเอง ---
    cur.execute("UPDATE product_entities SET Family_IDS = %s, Top_Parent = %s, Parent_ID = %s WHERE ID = %s",
                (new_family_ids, new_top_parent, new_parent_id, current_id))

    # --- STEP 4: Cascade Update (พาลูกหลานย้ายตามมา) ---
    if is_update and old_self_family:
        cur.execute("SELECT ID, Family_IDS FROM product_entities WHERE FIND_IN_SET(%s, Family_IDS) > 0 AND ID != %s", (current_id, current_id))
        descendants = cur.fetchall()
        for desc in descendants:
            new_path = desc['Family_IDS'].replace(old_self_family, new_family_ids)
            new_desc_top = ",".join(new_path.split(',')[:-1])
            cur.execute("UPDATE product_entities SET Family_IDS = %s, Top_Parent = %s WHERE ID = %s", (new_path, new_desc_top, desc['ID']))

def _select_full_prod_item(prod_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                a.ID, a.Entity_Type, a.Parent_ID, a.Name_EN, a.Name_TH, a.Latitude, a.Longitude, a.Address, yarn.Name_EN as Yarn
                , sub_district.Name_EN as Sub_District, district.Name_EN as District, province.Name_EN as Province, state.Name_EN as State
                , c.Name_EN as Country, a.FB_Link, a.IG_Link, a.Line_Link, a.YT_Link, a.Website, a.Content, a.Brief_Description, a.Logo_URL
                , a.Family_IDS, a.Top_Parent, a.Buttom_Parent, a.Entity_URL_Tag, a.Entity_Status, cate.Category_Group, cate.Category_Text
            FROM product_entities a
            left join place_location yarn on a.Yarn = yarn.ID and yarn.Location_Status = '1'
            left join place_location sub_district on a.Sub_District = sub_district.ID and sub_district.Location_Status = '1'
            left join place_location district on a.District = district.ID and district.Location_Status = '1'
            left join place_location province on a.Province = province.ID and province.Location_Status = '1'
            left join place_location state on a.State = state.ID and state.Location_Status = '1'
            left join country c on a.Country = c.ID and c.Country_Status = '1'
            left join (SELECT a.Entity_ID, JSON_ARRAYAGG(JSON_OBJECT( 'Relationship_ID', a.ID
                                                                    , 'Category_ID', a.Category_ID
                                                                    , 'Parent_ID', b.Parent_ID
                                                                    , 'Code', b.Code
                                                                    , 'Category_ENName', b.Category_ENName
                                                                    , 'Category_UseName', b.Category_UseName
                                                                    , 'Category_THName', b.Category_THName
                                                                    , 'Category_Order', b.Categories_Order
                                                                    , 'Relationship_Order', a.Relationship_Order)) as Category_Group
                            , GROUP_CONCAT(b.Category_UseName ORDER BY a.Relationship_Order ASC SEPARATOR ' | ') as Category_Text
                        FROM product_entities_categories_relationship a
                        join product_entities_categories b on a.Category_ID = b.ID and b.Categories_Status = '1'
                        where a.Relationship_Status = '1'
                        group by a.Entity_ID) as cate
            on a.ID = cate.Entity_ID
            WHERE a.ID=%s""",
        (prod_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return normalize_unit_row(row)

def _select_prod_cover(prod_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cover_list = []
    cur2.execute(
        f"""SELECT
                a.Image_URL
                , a.Ratio_Type
            from product_cover a
            where a.Image_Status = '1'
            and a.Entity_ID = %s""",
        (prod_id,)
    )
    rows = cur2.fetchall()
    for row in rows:
        row['Image_URL'] = row['Image_URL']
        cover_list.append(row)
    
    cur2.close()
    conn2.close()
    return cover_list

def get_prod_resource(prod_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    file_list = []
    cur2.execute(
        f"""SELECT
                a.ID
                , a.File_Type
                , a.File_Size
                , a.File_Name
                , a.File_URL
            from product_catalogs a
            where a.Entity_ID = %s""",
        (prod_id,)
    )
    rows = cur2.fetchall()
    for row in rows:
        file_entry = {
            "ID": row["ID"],
            "Type": row["File_Type"],
            "Size": row["File_Size"],
            "Name": row["File_Name"],
            "URL": row["File_URL"]
        }
        file_list.append(file_entry)
    
    cur2.close()
    conn2.close()
    return file_list

def prod_url_gen(prod_type: str, url_tag: str):
    if not url_tag:
        return None
    
    if prod_type == 'suppliers':
        tag_url = 'supp'
    elif prod_type == 'products':
        tag_url = 'prod'
    else:
        tag_url = 'brand'
    result_url = tag_url + '/' + url_tag
    return result_url

def get_prod_parent(family_id: str):
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    parent_list = []
    prod_list = []
    cur2.execute(
        f"""SELECT a.ID
                , a.Entity_Type
                , if(a.Entity_Type <> 'products'
                    , UPPER(a.Name_EN)
                    , a.Name_EN) as Name_EN
                , a.Name_EN as Normal_Name
                , a.Brief_Description
                , a.Entity_URL_Tag
                , a.Family_IDS
            from product_entities a
            where a.Top_Parent = %s
            and a.Entity_Status = '1'""",
        (family_id,)
    )
    rows = cur2.fetchall()
    for row in rows:
        url_tag = prod_url_gen(row["Entity_Type"], row["Entity_URL_Tag"])
        parent_entry = {
            "Name": row["Name_EN"],
            "Url": url_tag
        }
        cover_data = _select_prod_cover(row["ID"])
        parent_entry["Cover"] = cover_data if cover_data else None
        
        if row["Entity_Type"] != 'products':
            parent_entry["Type"] = row["Entity_Type"]
            parent_entry["Brief_Description"] = row["Brief_Description"]
            sub_parent = get_prod_subparent(cur2, row["Family_IDS"], row["Normal_Name"], 'prod')
            parent_entry["Parent"] = sub_parent if sub_parent else None
            parent_list.append(parent_entry)
        else:
            prod_list.append(parent_entry)
    
    cur2.close()
    conn2.close()
    return parent_list, prod_list

def get_prod_subparent(cur, ref_id: str, name: str, state: str):
    parent_list = []
    if state == 'prod':
        cur.execute(
            f"""SELECT a.ID
                    , a.Entity_Type
                    , a.Name_EN
                    , a.Entity_URL_Tag
                from product_entities a
                where a.Top_Parent = %s
                and a.Entity_Status = '1'
                order by a.Entity_Type""",
            (ref_id,)
        )
    else:
        cur.execute(
            f"""SELECT a.ID
                    , a.Entity_Type
                    , c.Name_EN as Head_Name
                    , a.Name_EN
                    , a.Entity_URL_Tag
                from product_entities a
                join proj_prod_relationship b on a.ID = b.Prod_ID and b.Relationship_Status = '1'
                left join product_entities c on a.Parent_ID = c.ID and c.Entity_Status = '1' and c.Entity_Type <> 'suppliers'
                where b.Proj_ID = %s
                and a.Entity_Status = '1'
                order by a.Entity_Type""",
            (ref_id,)
        )
    
    rows = cur.fetchall()
    for row in rows:
        url_tag = prod_url_gen(row["Entity_Type"], row["Entity_URL_Tag"])
        parent_entry = {
            "Type": row["Entity_Type"],
            "Head_Name": name if state else row["Head_Name"],
            "Name": row["Name_EN"],
            "Url": url_tag
        }
        
        if row["Entity_Type"] != 'products':
            cur.execute(
            f"""SELECT count(ID) as count_prod FROM product_entities WHERE FIND_IN_SET(%s, Family_IDS) > 0 AND Entity_Type = 'products'""",
            (row["ID"],))
            count = cur.fetchone()
            parent_entry["Count_Prod"] = count["count_prod"] if count else None
        
        cover_data = _select_prod_cover(row["ID"])
        parent_entry["Cover"] = cover_data if cover_data else None
        
        parent_list.append(parent_entry)

    return parent_list

def get_breadcrumbs(family_ids_str: str, current_id: int):
    if not family_ids_str:
        return []
    
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)

    path_ids = family_ids_str.split(',')
    format_strings = ','.join(['%s'] * len(path_ids))
    query = f"""
        SELECT ID, Entity_Type, Name_EN, Entity_URL_Tag 
        FROM product_entities 
        WHERE ID IN ({format_strings})
        ORDER BY FIELD(ID, {format_strings})
    """
    cur2.execute(query, tuple(path_ids) + tuple(path_ids))
    rows = cur2.fetchall()

    breadcrumbs = []
    for i, row in enumerate(rows, start=1):
        is_current = (row["ID"] == int(current_id))
        breadcrumbs.append({
            "Name": row["Name_EN"],
            # ถ้าเป็นตัวปัจจุบัน (is_current) ให้ Url เป็น None เพื่อจะได้กดไม่ได้
            "Url": prod_url_gen(row["Entity_Type"], row["Entity_URL_Tag"]) if (row['Entity_URL_Tag'] and not is_current) else None,
            "order": i,
        })
    
    cur2.close()
    conn2.close()
    return breadcrumbs

def get_supplier(supp_id: int):
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    cur2.execute(f"""
                    SELECT a.ID, a.Name_EN as Name, a.Logo_URL as Logo, a.Entity_URL_Tag as Url
                        , c.Image_URL as Cover, count_help.count_prod as Count, cate.Category_Text as Category
                    from product_entities a
                    join prod_url b on a.ID = b.ID and b.Url_Status = 1
                    left join product_cover c on a.ID = c.Entity_ID and c.Image_Status = '1' and c.Ratio_Type = '1:1'
                    left join (SELECT 
                                    parent.ID as parent_id, 
                                    COUNT(child.ID) as count_prod
                                FROM product_entities parent
                                LEFT JOIN product_entities child ON FIND_IN_SET(parent.ID, child.Family_IDS) > 0
                                    AND child.Entity_Type = 'products' -- นับเฉพาะตัวที่เป็นสินค้า
                                    AND child.Entity_Status = '1'
                                WHERE parent.Entity_Status = '1'
                                GROUP BY parent.ID) count_help
                    on a.ID = count_help.parent_id
                    left join (SELECT a.Entity_ID
                                    , GROUP_CONCAT(upper(b.Category_UseName) ORDER BY a.Relationship_Order ASC SEPARATOR ' | ') as Category_Text
                                FROM product_entities_categories_relationship a
                                join product_entities_categories b on a.Category_ID = b.ID and b.Categories_Status = '1'
                                where a.Relationship_Status = '1'
                                and a.Relationship_Order <= 2
                                group by a.Entity_ID) as cate
                    on a.ID = cate.Entity_ID
                    where a.ID = %s
                    and a.Entity_Status = '1'
                """, (supp_id,))
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return row if row else None

def get_prod_proj(prod_id: int):
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)

    proj_list = []
    cur2.execute(f"""
                    SELECT a.Proj_ID, c.Name_EN as Name, cate.Display_Category as Category, c.Proj_URL_Tag as URL
                    FROM proj_prod_relationship a
                    JOIN projects c ON a.Proj_ID = c.ID and c.Proj_Status = '1'
                    left join (select a.Proj_ID, group_concat(UPPER(b.Category_Name) order by a.Relationship_Order separator ' | ') as Display_Category
                                from proj_category_relationship a
                                join proj_categories b on a.Category_ID = b.ID AND b.Categories_Status = '1'
                                where a.Relationship_Order <= 3
                                group by a.Proj_ID) cate
                    on c.ID = cate.Proj_ID
                    WHERE a.prod_id = %s
                    order by GREATEST(COALESCE(YEAR(c.Start_Date), 0), COALESCE(YEAR(c.Finish_Date), 0), COALESCE(YEAR(c.Renovated_Date), 0)) desc
                """, (prod_id,))
    rows = cur2.fetchall()

    for row in rows:
        cur2.execute(f"""SELECT Image_Url from proj_cover where Ratio_Type = '3:2' and Image_Status = '1' and Proj_ID = %s""", (row["Proj_ID"],))
        images = cur2.fetchall()
        row["Cover"] = images if images else None
        proj_list.append(row)
    
    cur2.close()
    conn2.close()
    return proj_list

def get_entity_context(family_ids_str: str):
    if not family_ids_str:
        return None, None
    
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)

    path_ids = family_ids_str.split(',')
    format_strings = ','.join(['%s'] * len(path_ids))
    
    query = f"""
        SELECT ID, Entity_Type, Name_EN, Entity_URL_Tag
        FROM product_entities 
        WHERE ID IN ({format_strings})
        ORDER BY FIELD(ID, {format_strings})
    """
    cur2.execute(query, tuple(path_ids) + tuple(path_ids))
    rows = cur2.fetchall()

    supplier_name = None
    brand_name = None
    supplier_url = None
    brand_url = None

    for row in rows:
        if row["Entity_Type"] == 'suppliers':
            supplier_name = row["Name_EN"]
            supplier_url = prod_url_gen(row["Entity_Type"], row["Entity_URL_Tag"])
        
        if row["Entity_Type"] == 'brands':
            brand_name = row["Name_EN"]
            brand_url = prod_url_gen(row["Entity_Type"], row["Entity_URL_Tag"])

    cur2.close()
    conn2.close()
    return supplier_name, brand_name, supplier_url, brand_url

def recover_proj_prod_relationship(cur, ref_id: int, state: str):
    id_list = []
    if state == 'prod':
        column_id = 'Proj_ID'
        cur.execute(f"""select {column_id} from proj_prod_relationship where Prod_ID = %s""", (ref_id,))
        rows = cur.fetchall()
        ref_list = list(set(row[column_id] for row in rows))
        for id_ref in ref_list:
            proj = _select_full_proj_item(id_ref)
            proj_status = proj['Proj_Status']
            if proj_status == '1':
                id_list.append(id_ref)
    else:
        column_id = 'Prod_ID'
        cur.execute(f"""select {column_id} from proj_prod_relationship where Proj_ID = %s""", (ref_id,))
        rows = cur.fetchall()
        ref_list = list(set(row[column_id] for row in rows))
        for id_ref in ref_list:
            prod = _select_full_prod_item(id_ref)
            prod_status = prod['Entity_Status']
            if prod_status == '1':
                id_list.append(id_ref)
    
    for each_id in id_list:
        cur.execute(f"""update proj_prod_relationship set Relationship_Status = '1' where {column_id} = %s""", (each_id,))

def _select_prod_category():
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    cur2.execute(
        f"""SELECT
                a.ID,
                a.Parent_ID,
                a.Code,
                a.Category_ENName,
                a.Category_UseName,
                a.Category_THName,
                a.Categories_Order
            FROM product_entities_categories a
            left join product_entities_categories b on a.Parent_ID = b.ID and b.Categories_Status = '1'
            left join product_entities_categories c on b.Parent_ID = c.ID and c.Categories_Status = '1'
            WHERE a.Categories_Status = '1'
            order by c.Categories_Order, b.Categories_Order, a.Categories_Order"""
    )
    
    row = cur2.fetchall()
    cur2.close()
    conn2.close()
    return normalize_unit_row(row)

def insert_file(cur, prod_id, file_path, file_name, file_size, file_type):
    cur.execute(f"""insert into product_catalogs (Entity_ID, File_URL, File_Name, File_Size, File_Type) 
                values (%s, %s, %s, %s, %s)""", (prod_id, file_path, file_name, file_size, file_type))
    return {"File_Name": file_name, "File_Type": file_type}

def _delete_resource(cur, res_id: int):
    cur.execute(f"select File_URL FROM product_catalogs WHERE ID=%s", (res_id,))
    row = cur.fetchone()
    url = row["File_URL"]
    
    cur.execute(f"DELETE FROM product_catalogs WHERE ID=%s", (res_id,))
    affected = cur.rowcount

    if affected > 0:
        path_file = os.path.join(UPLOAD_DIR, "product", url)
        if os.path.exists(path_file):
            os.remove(path_file)

def delete_entity_parent(cur, delete_id: int):
    # 1. ดึงข้อมูลตัวเองก่อนลบ (เพื่อหาพ่อและลูก)
    cur.execute("SELECT Parent_ID, Buttom_Parent FROM product_entities WHERE ID = %s", (delete_id,))
    target = cur.fetchone()
    if not target: return "Not Found"

    old_parent_id = target['Parent_ID']
    my_kids_raw = target['Buttom_Parent']
    my_kids = [k.strip() for k in my_kids_raw.split(',') if k.strip()] if my_kids_raw else []

    # 2. ปลดปล่อยลูกตรง (Direct Children) ให้กลายเป็น Root
    # เมื่อพ่อ (เรา) ตาย ลูกๆ จะไม่มี Parent และ Family_IDS จะเหลือแค่ตัวเขาเอง
    for kid_id in my_kids:
        # อัปเดตลูก: Parent=NULL, Top=NULL, Family=ตัวเอง
        cur.execute("""UPDATE product_entities SET Parent_ID = NULL, Top_Parent = NULL, Family_IDS = %s WHERE ID = %s""", (str(kid_id), kid_id))
        
        # --- [สำคัญ] ต้องจัดการ "ลูกหลานของลูก" (Grandchildren) ด้วย ---
        # สายเลือดเดิมของลูกคือ '...ต้นตระกูล,เรา,ลูก' 
        # ต้องตัด '...ต้นตระกูล,เรา,' ออก ให้เหลือแค่สายเลือดที่เริ่มจาก 'ลูก' เป็นต้นไป
        cur.execute("SELECT Family_IDS FROM product_entities WHERE ID = %s", (kid_id,))
        new_root_family = cur.fetchone()['Family_IDS']
        
        # หาหลานๆ ทุกคนที่มี 'ลูก' คนนี้อยู่ในสายเลือด
        cur.execute("SELECT ID, Family_IDS FROM product_entities WHERE FIND_IN_SET(%s, Family_IDS) > 0 AND ID != %s", (kid_id, kid_id))
        descendants = cur.fetchall()
        for desc in descendants:
            # ตัดสายเลือดส่วนเกินทิ้ง (เอาเฉพาะส่วนที่ต่อจาก ID ลูกลงไป)
            old_path = desc['Family_IDS']
            # หาตำแหน่งของ ID ลูกใน String แล้วตัดส่วนหน้าทิ้ง
            start_index = old_path.find(new_root_family)
            new_path = old_path[start_index:]
            new_top = ",".join(new_path.split(',')[:-1]) if ',' in new_path else None
            
            cur.execute("UPDATE product_entities SET Family_IDS = %s, Top_Parent = %s WHERE ID = %s", (new_path, new_top, desc['ID']))

    # 3. ลบตัวเองออกจาก Buttom_Parent ของพ่อเรา
    if old_parent_id:
        cur.execute("SELECT Buttom_Parent FROM product_entities WHERE ID = %s", (old_parent_id,))
        res = cur.fetchone()
        if res and res['Buttom_Parent']:
            p_kids = [k.strip() for k in res['Buttom_Parent'].split(',') if k.strip()]
            if str(delete_id) in p_kids:
                p_kids.remove(str(delete_id))
                updated_buttom = ",".join(p_kids) if p_kids else None
                cur.execute("UPDATE product_entities SET Buttom_Parent = %s WHERE ID = %s", (updated_buttom, old_parent_id))

    # 4. ลบตัวเองทิ้ง
    cur.execute("update product_entities set Entity_Status = '2' WHERE ID = %s", (delete_id,))

def assign_category_bulk(cur, entity_id, category_ids, include_descendants):
    target_ids = [entity_id]
    if include_descendants:
        cur.execute("SELECT ID FROM product_entities WHERE FIND_IN_SET(%s, Family_IDS) > 0 and Entity_Status = '1'", (entity_id,))
        rows = cur.fetchall()
        target_ids = list(set([entity_id] + [r['ID'] for r in rows]))

    placeholders = ', '.join(['%s'] * len(target_ids))
    sql = f"DELETE FROM product_entities_categories_relationship WHERE Entity_ID IN ({placeholders})"
    cur.execute(sql, target_ids)

    data_to_insert = []
    category_list = [c.strip() for c in category_ids.split(";") if c.strip()]
    for t_id in target_ids:
        for i, category_id in enumerate(category_list, start=1):
            data_to_insert.append((t_id, category_id, i))

    sql = """INSERT INTO product_entities_categories_relationship (Entity_ID, Category_ID, Relationship_Order, Relationship_Status) 
            VALUES (%s, %s, %s, '1') ON DUPLICATE KEY UPDATE Relationship_Order = VALUES(Relationship_Order), Relationship_Status = '1'"""
    cur.executemany(sql, data_to_insert)

def _select_full_cate_item(cate_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                a.ID, a.Parent_ID, a.Code, a.Category_ENName, a.Category_UseName, a.Category_THName, a.Categories_Order, a.Categories_Status
            FROM product_entities_categories a
            WHERE a.ID=%s""",
        (cate_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return row

def _update_category_order(cur, category_id, display_order: int) -> dict:
    sql = f"""
        UPDATE product_entities_categories
        SET Categories_Order=%s
        WHERE ID=%s
    """
    cur.execute(sql, (display_order, category_id))
    
    return {
        "category_id": category_id,
        "display_order": display_order,
    }

def _select_full_attr_def_item(def_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                a.ID, a.Key_Name, a.Display_Name, a.Remark, a.Data_Type, a.Options_List, a.Display_Order, a.Attr_Status
            FROM product_attribute_definitions a
            WHERE a.ID=%s""",
        (def_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return row

def _update_attr_order(cur, attr_id, display_order: int) -> dict:
    sql = f"""
        UPDATE product_attribute_definitions
        SET Display_Order=%s
        WHERE ID=%s
    """
    cur.execute(sql, (display_order, attr_id))
    
    return {
        "attr_id": attr_id,
        "display_order": display_order,
    }

def _select_full_attr_definition_item(cate_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                a.ID, a.Key_Name , a.Display_Name, a.Remark, a.Data_Type, a.Unit, a.Options_List, a.Display_Order, a.Attr_Status
            FROM product_attribute_definitions a
            WHERE a.ID=%s""",
        (cate_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return row

def get_prod_specification(ref_id: int, state: str):
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)

    if state == "prod":
        query = "and a.Entity_ID = %s"
    else:
        query = "and a.ID = %s"
    
    cur2.execute(f"""
                    SELECT a.ID, b.Key_Name, b.Display_Name, b.Unit, b.Data_Type, a.Attr_Value, a.Relationship_Status, a.Attr_Def_ID, a.Sub_Display_Order, a.Display_Order
                    FROM product_attribute_values a
                    join product_attribute_definitions b on a.Attr_Def_ID = b.ID and b.Attr_Status = '1'
                    where a.Relationship_Status <> '2'
                    {query}
                    order by a.Display_Order, a.Sub_Display_Order
                """, (ref_id,))
    rows = cur2.fetchall()
    
    cur2.close()
    conn2.close()
    return rows if rows else None

def get_prod_all_specification(ref_id: int):
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    cur2.execute("""
                    select b.Display_Name as Display
                        , b.Key_Name
                        , group_concat(a.Attr_Value order by a.Display_Order, a.Sub_Display_Order separator ';') as Value
                        , b.Unit
                        , b.Display_Order as 'Order'
                        , b.Data_Type
                    FROM product_attribute_values a
                    join product_attribute_definitions b on a.Attr_Def_ID = b.ID and b.Attr_Status = '1'
                    where a.Relationship_Status = '1'
                    and a.Entity_ID = %s
                    group by b.Display_Name, b.Key_Name
                """, (ref_id,))
    rows = cur2.fetchall()
    
    cur2.close()
    conn2.close()
    return rows if rows else None

def _update_prod_spec_order(cur, spec_id, display_order: int) -> dict:
    sql = f"""
        UPDATE product_attribute_values
        SET Sub_Display_Order=%s
        WHERE ID=%s
    """
    cur.execute(sql, (display_order, spec_id))
    
    return {
        "spec_id": spec_id,
        "sub_display_order": display_order,
    }

def _update_prod_spec_group_order(cur, entity_id, attr_id, display_order: int) -> dict:
    sql = f"""
        UPDATE product_attribute_values
        SET Display_Order=%s
        WHERE Entity_ID=%s and Attr_Def_ID=%s
    """
    cur.execute(sql, (display_order, entity_id, attr_id))
    
    return {
        "entity_id": entity_id,
        "attr_id": attr_id,
        "display_order": display_order,
    }
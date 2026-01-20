from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists, normalize_row
from function_query_helper import _select_full_office_unit_item, _select_full, _get_building_id, _get_project_id \
    , _get_unit_display_order, _select_all_unit_image_category, _get_building_relationship, _get_project_name, _get_building_name \
    , _update_image_order, gen_link
from typing import Optional, Tuple, Dict, Any, List
import os, uuid, shutil
from PIL import Image
import re
from wand.image import Image as WandImage
from io import BytesIO
from datetime import datetime, date
from collections import defaultdict
import itertools

router = APIRouter()
TABLE = "office_unit"

UPLOAD_DIR = "/var/www/html/real-lease/uploads"
PUBLIC_PREFIX = "/real-lease/uploads"
ALLOWED_EXT = {".jpg", ".jpeg", ".png", ".webp", ".gif"}

os.makedirs(UPLOAD_DIR, exist_ok=True)

def _save_one_file(f: bytes, unit_id: int, image_id: int, building_id: int, project_id: int, image_size: tuple, content_type: str) -> dict:
    width, height = image_size
    project_folder = os.path.join(UPLOAD_DIR, str(f"{project_id:04d}"))
    os.makedirs(project_folder, exist_ok=True)  # create if not exists
    building_folder = os.path.join(project_folder, str(f"{building_id:04d}"))
    os.makedirs(building_folder, exist_ok=True)  # create if not exists
    unit_folder = os.path.join(building_folder, str(f"{unit_id:05d}"))
    os.makedirs(unit_folder, exist_ok=True)  # create if not exists

    filename = f"{image_id:06d}-H-{width}.webp"
    dest_path = os.path.join(unit_folder, filename)
    
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
        "url": image_url,
        "content_type": content_type,
    }

def _insert_image_record(
    *, unit_id, unit_category_id: int, image_name: str, image_url: str,
    display_order: int, image_status: str, created_by: int
) -> dict:
    # ตัดชื่อไฟล์ให้ไม่เกิน 100 ตัวอักษรตาม schema
    image_name = image_name[:100] if image_name else None
    conn = get_db()
    cur = conn.cursor()
    try:
        sql = """
            INSERT INTO office_unit_image
                (Unit_ID, Unit_Category_ID, Image_Name, Image_Url, Display_Order, Image_Status,
                Created_By, Last_Updated_By)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (
            unit_id,
            unit_category_id,
            image_name,
            image_url,
            display_order,
            image_status,
            created_by,
            created_by,
        ))
        conn.commit()
        new_id = cur.lastrowid
    finally:
        cur.close()
        conn.close()

    # ดึงเรคคอร์ดที่เพิ่ง insert
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    try:
        cur2.execute(
            """SELECT
                    Unit_ID, Unit_Image_ID, Unit_Category_ID, Image_Name, Image_Url,
                    Display_Order, Image_Status, Created_By, Created_Date,
                    Last_Updated_By, Last_Updated_Date
                FROM office_unit_image
                WHERE Unit_Image_ID=%s""",
            (new_id,)
        )
        row = cur2.fetchone()
        return row
    finally:
        cur2.close()
        conn2.close()

def _update_image_record(
    *, image_id, image_url: str,
) -> dict:
    conn = get_db()
    cur = conn.cursor()
    try:
        sql = """
            UPDATE office_unit_image
            SET Image_Url=%s
            WHERE Unit_Image_ID=%s
        """
        cur.execute(sql, (image_url, image_id))
        conn.commit()
    finally:
        cur.close()
        conn.close()

def _delete_unit_image(image_id: int, action: str):
    conn = get_db()
    cur = conn.cursor()
    try:
        image_size_list = [(1440,810),(800,450),(400,225)]
        cur.execute("SELECT Unit_ID FROM office_unit_image WHERE Unit_Image_ID=%s", (image_id,))
        row = cur.fetchone()
        if not row:
            return
        (unit_id,) = row

        cur.execute("SELECT Building_ID FROM office_unit WHERE Unit_ID=%s", (unit_id,))
        (building_id,) = cur.fetchone()

        cur.execute("SELECT Project_ID FROM office_building WHERE Building_ID=%s", (building_id,))
        (project_id,) = cur.fetchone()
        
        cur.execute("SELECT Unit_Category_ID, Display_Order FROM office_unit_image WHERE Unit_Image_ID=%s", (image_id,))
        row = cur.fetchone()
        if not row:
            return
        (unit_category_id, display_order) = row
        
        if action == "Delete_Image":
            cur.execute("DELETE FROM office_unit_image WHERE Unit_Image_ID=%s", (image_id,))
            conn.commit()
            affected = cur.rowcount

            if affected > 0:
                cur.execute("SELECT Unit_Image_ID FROM office_unit_image WHERE Unit_Category_ID=%s AND Display_Order>%s AND Unit_ID=%s", (unit_category_id, display_order, unit_id))
                rows = cur.fetchall()
                for row in rows:
                    cur.execute("UPDATE office_unit_image SET Display_Order=Display_Order-1 WHERE Unit_Image_ID=%s", (row[0],))
                    conn.commit()
                
                project_folder = os.path.join(UPLOAD_DIR, f"{project_id:04d}")
                building_folder = os.path.join(project_folder, f"{building_id:04d}")
                unit_folder = os.path.join(building_folder, f"{unit_id:05d}")
                for image_size in image_size_list:
                    filename = f"{image_id:06d}-H-{image_size[0]}.webp"
                    dest_path = os.path.join(unit_folder, filename)
                    os.remove(dest_path)
        else:
            cur.execute("UPDATE office_unit_image SET Image_Status='2' WHERE Unit_Image_ID=%s", (image_id,))
            conn.commit()
            affected = cur.rowcount
    finally:
        cur.close()
        conn.close()

def _process_virtual_room_additive(cur, new_unit_data: dict, virtual_room_str: Optional[str], created_by: Optional[int], work_state: str):   
    virtual_room_mapping_query = """select Virtual_ID from office_unit_virtual_room_mapping where Unit_ID=%s"""
    cur.execute(virtual_room_mapping_query, (new_unit_data['Unit_ID'],))
    rows = cur.fetchall()
    
    if rows:
        for row in rows:
            cur.execute("delete from office_unit_virtual_room_mapping where Virtual_ID=%s", (row['Virtual_ID'],))
            cur.execute("delete from office_unit_virtual_room where Virtual_ID=%s", (row['Virtual_ID'],))
            cur.execute("delete from office_unit_adjacency where Unit_ID_A=%s or Unit_ID_B=%s", (new_unit_data['Unit_ID'], new_unit_data['Unit_ID']))
    
    if work_state != 'delete':
        new_pairs_added = _insert_new_adjacencies_and_return(cur, new_unit_data['Unit_ID'], virtual_room_str, created_by)
    
        if not new_pairs_added:
            return

        # 2. สร้าง Virtual Rooms ใหม่
        _find_and_create_new_virtual_rooms(
            cur=cur, 
            new_pairs_added=new_pairs_added, 
            new_unit_data=new_unit_data, # <--- ส่งข้อมูลห้องใหม่
            created_by=created_by)

def _insert_new_adjacencies_and_return(cur, new_unit_id: int, virtual_room_str: str, created_by: int) -> list:
    existing_pairs = set()
    cur.execute("SELECT Unit_ID_A, Unit_ID_B FROM office_unit_adjacency")
    for row in cur.fetchall():
        pair = tuple(sorted((int(row['Unit_ID_A']), int(row['Unit_ID_B']))))
        existing_pairs.add(pair)
        
    new_rows_to_insert = []
    new_pairs_for_logic = []
    try:
        virtual_id_list = [int(v.strip()) for v in virtual_room_str.split(';') if v.strip()]
    except ValueError:
        raise Exception("Invalid Virtual_Room IDs (non-integer).")

    for vid in virtual_id_list:
        pair = tuple(sorted((new_unit_id, vid)))
        
        if pair not in existing_pairs:
            new_rows_to_insert.append((pair[0], pair[1], created_by))
            new_pairs_for_logic.append(pair)
            existing_pairs.add(pair) 

    if new_rows_to_insert:
        sql = """
            INSERT INTO office_unit_adjacency (Unit_ID_A, Unit_ID_B, Created_By) 
            VALUES (%s, %s, %s)
        """
        cur.executemany(sql, new_rows_to_insert)
        
    return new_pairs_for_logic

def _find_and_create_new_virtual_rooms(cur, new_pairs_added: list, new_unit_data: dict, created_by: int):
    """
    (Worker 2 - Universal Topology Logic)
    รองรับทุกรูปทรง (เส้นตรง, ตัว T, สี่เหลี่ยม, ฯลฯ)
    """
    # --- 1. สร้าง Graph และ Cache (เหมือนเดิม) ---
    graph = defaultdict(list)
    cur.execute("SELECT Unit_ID_A, Unit_ID_B FROM office_unit_adjacency")
    rows = cur.fetchall()
    for row in rows:
        u, v = int(row['Unit_ID_A']), int(row['Unit_ID_B']) 
        graph[u].append(v); graph[v].append(u)

    existing_virtual_names = set()
    cur.execute("SELECT Virtual_Name FROM office_unit_virtual_room")
    for row in cur.fetchall():
        existing_virtual_names.add(row['Virtual_Name'])

    transient_unit_cache = {new_unit_data['Unit_ID']: new_unit_data }

    # --- 2. ค้นหา "กลุ่มก้อน" (Connected Components) ที่ได้รับผลกระทบ ---
    nodes_impacted = set(uid for pair in new_pairs_added for uid in pair) # {25,26}
    visited_nodes_in_search = set()
    
    for start_node in nodes_impacted:
        if start_node in visited_nodes_in_search or start_node not in graph:
            continue
            
        # 2.1 หา "เพื่อนทั้งหมดที่เชื่อมถึงกัน" (Component)
        # ไม่สนรูปทรง จะเป็นตัว T หรือดาว ก็เก็บมาให้หมด
        component = []
        stack = [start_node]
        visited_in_component = set()

        while stack:
            current_node = stack.pop()
            if current_node in visited_in_component or current_node in visited_nodes_in_search:
                continue
            visited_in_component.add(current_node)
            component.append(current_node)
            for neighbor in graph[current_node]:
                stack.append(neighbor)
        
        # Mark ว่ากลุ่มนี้ทำแล้ว
        visited_nodes_in_search.update(component)

        # --- 3. สร้าง Virtual Rooms จากกลุ่มนี้ (Logic ใหม่!) ---
        # เรามี component เช่น [25, 26, 27, 28] (อาจจะเป็นตัว T)
        # Loop ขนาด (size) ตั้งแต่ 2 ถึง จำนวนในกลุ่ม
        # (ระวัง: ถ้ากลุ่มใหญ่มาก เช่น 20 ห้อง combination จะเยอะมหาศาล 
        n_limit = len(component) 

        for r in range(2, n_limit + 1):
            # สร้าง Combination ทั้งหมดของขนาด r
            # เช่น r=3: (25,26,27), (25,26,28), (26,27,28), ...
            for subset in itertools.combinations(component, r):
                # *** 3.1 หัวใจสำคัญ: เช็คว่า Subset นี้เชื่อมต่อกันหรือไม่ ***
                if not _is_subgraph_connected(subset, graph):
                    continue # ถ้าไม่เชื่อมกัน (เช่น เอา 25 คู่ 28 แต่ตรงกลางโหว่) -> ข้าม
                # 3.2 ถ้าเชื่อมกัน -> สร้าง Virtual Room (เหมือนเดิม)
                v_room_data = _calculate_virtual_room_details_optimized(
                    unit_ids=list(subset),
                    transient_cache=transient_unit_cache)
                
                combined_name = v_room_data['Virtual_Name']
                
                if combined_name not in existing_virtual_names:
                    # INSERT Virtual Room
                    v_sql = """
                        INSERT INTO office_unit_virtual_room 
                        (Virtual_Name, Size, Rent_Price, Building_ID, Floor, Available_Date, Min_Divide_Size, Floor_Replacement, View_N, View_E, View_S, View_W, Ceiling_Dropped
                        , Furnish_Condition, Ceiling_Full_Structure, Ceiling_Replacement, Column_InUnit, AC_Split_Type, Pantry_InUnit, Bathroom_InUnit, Rent_Term
                        , Rent_Deposit, Rent_Advance) 
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    """
                    cur.execute(v_sql, (
                        v_room_data['Virtual_Name'], v_room_data['Size'],
                        v_room_data['Price'], v_room_data['Building_ID'], v_room_data['Floor'], v_room_data['Available_Date'], v_room_data['Min_Divide_Size'],
                        v_room_data['Floor_Replacement'], v_room_data['View_N'], v_room_data['View_E'], v_room_data['View_S'], v_room_data['View_W'], v_room_data['Ceiling_Dropped'],
                        v_room_data['Furnish_Condition'], v_room_data['Ceiling_Full_Structure'], v_room_data['Ceiling_Replacement'], v_room_data['Column_InUnit'],
                        v_room_data['AC_Split_Type'], v_room_data['Pantry_InUnit'], v_room_data['Bathroom_InUnit'], v_room_data['Rent_Term'], v_room_data['Rent_Deposit'],
                        v_room_data['Rent_Advance']
                    ))
                    new_vid = cur.lastrowid
                    
                    # INSERT Mapping
                    map_vals = [(new_vid, uid) for uid in subset]
                    cur.executemany("INSERT INTO office_unit_virtual_room_mapping (Virtual_ID, Unit_ID) VALUES (%s, %s)", map_vals)
                    
                    existing_virtual_names.add(combined_name)

def _calculate_virtual_room_details_optimized(unit_ids: list, transient_cache: dict) -> dict:
    all_details = []
    # --- 1. รวบรวมข้อมูลของทุก Unit ใน list ---
    for uid in unit_ids:
        if uid in transient_cache:
            # กรณี A: มีข้อมูลใน Cache แล้ว (เช่น เป็นห้องใหม่ที่เพิ่ง Insert หรือห้องที่เคยดึงมาแล้ว)
            all_details.append(transient_cache[uid])
        else:
            # กรณี B: ยังไม่มีข้อมูล -> ต้องไปดึงจาก DB
            # (เรียกใช้ Helper _select_full_office_unit_item ที่คุณมี)
            details = _select_full_office_unit_item(uid)
            
            if not details:
                # ป้องกันกรณีข้อมูลผิดพลาด (Database Inconsistency)
                raise Exception(f"Critical Error: Unit_ID {uid} not found in database during calculation.")
                
            # แปลงข้อมูลตัวเลขให้ชัวร์ว่าเป็น float (ป้องกัน Error ตอนคำนวณ)
            for key in ['Size', 'Rent_Price', 'Min_Divide_Size', 'Ceiling_Dropped', 'Ceiling_Full_Structure']:
                details[key] = float(details.get(key, 0) or 0)
            
            for key in ['Rent_Term', 'Rent_Deposit', 'Rent_Advance']:
                details[key] = int(details.get(key, 0) or 0)
            
            raw_date = details.get('Available')
            available_date_lastest = datetime.strptime(raw_date, "%Y-%m-%d").date()
            details['Available_Date'] = available_date_lastest
            
            details['Furnish_Condition'] = get_furnish_index(details.get('Furnish_Condition'))
            
            for key in ['Floor_Replacement', 'View_N', 'View_E', 'View_S', 'View_W', 'Ceiling_Replacement', 'Column_InUnit'
                        , 'AC_Split_Type', 'Pantry_InUnit', 'Bathroom_InUnit', 'Floor']:
                details[key] = details.get(key)
            
            # เก็บใส่ Cache ไว้ด้วย เผื่อรอบหน้าต้องใช้ ID นี้อีก
            transient_cache[uid] = details
            all_details.append(details)

    # --- 2. เรียงลำดับข้อมูล (สำคัญมากสำหรับชื่อ) ---
    # เรียงตาม Unit_ID เพื่อให้ชื่อออกมาเป็น "25+26" เสมอ ไม่ใช่ "26+25"
    sorted_details = sorted(all_details, key=lambda d: d['Unit_ID'])
    
    # --- 3. คำนวณค่าต่างๆ ---
    # 3.1 สร้างชื่อห้องรวม (String Join)
    combined_no = " - ".join([d['Unit_NO'] for d in sorted_details])
    combined_name = combined_no
    
    # 3.2 Building ID (สมมติว่าห้องติดกันต้องอยู่ตึกเดียวกัน ใช้ของห้องแรก)
    building_id = sorted_details[0]['Building_ID']
    
    # 3.3 รวมขนาด (Sum Size)
    combined_size = sum(d['Size'] for d in all_details)
    
    # 3.4 คำนวณราคาเฉลี่ยถ่วงน้ำหนัก (Weighted Average Price)
    # สูตร: (Price1*Size1 + Price2*Size2 + ...) / Total_Size
    # ถ้า Size เป็น 0 (เช่นห้องเปล่า) จะได้ราคาเฉลี่ย 0 เพื่อกัน Error หารด้วยศูนย์
    total_price_size = sum(d['Rent_Price'] * d['Size'] for d in all_details)
    weighted_price = 0.0
    if combined_size > 0:
        weighted_price = round(total_price_size / combined_size)
    
    valid_dates = [d['Available_Date'] for d in all_details if d['Available_Date']]
    available_date_latest = max(valid_dates)
    
    furnish = max((d['Furnish_Condition'] for d in all_details if d['Furnish_Condition'] is not None), default=0)
    
    keys_to_check = ['Min_Divide_Size', 'Ceiling_Dropped', 'Ceiling_Full_Structure', 'Rent_Term', 'Rent_Deposit', 'Rent_Advance']
    specs = {}
    for key in keys_to_check:
        max_value = max((d[key] for d in all_details), default=0)
        specs[key] = max_value or None
    
    replace_keys = ['Floor_Replacement', 'Ceiling_Replacement', 'Column_InUnit', 'AC_Split_Type', 'Pantry_InUnit', 'Bathroom_InUnit']
    replace_specs = {}
    for key in replace_keys:
        valid_values = [d[key] for d in all_details if d[key] is not None]
        replace_specs[key] = max(valid_values, default=None)
    
    view_n, view_e, view_s, view_w = None, None, None, None
    view_key_list = ['View_N', 'View_E', 'View_S', 'View_W']
    value_list = [view_n, view_e, view_s, view_w]
    for i, key in enumerate(view_key_list):
        view_values = [d[key] for d in all_details]
        if 1 in view_values:
            value_list[i] = 1
        elif 0 in view_values:
            value_list[i] = 0
        else:
            value_list[i] = None
    view_n, view_e, view_s, view_w = value_list
    
    floor = all_details[0]['Floor']
    
    # --- 4. ส่งค่ากลับ ---
    return {
        'Virtual_Name': combined_name,
        'Building_ID': building_id,
        'Size': combined_size,
        'Price': weighted_price,
        'Available_Date': available_date_latest,
        'Min_Divide_Size': specs['Min_Divide_Size'],
        'Floor_Replacement': replace_specs['Floor_Replacement'],
        'View_N': view_n,
        'View_E': view_e,
        'View_S': view_s,
        'View_W': view_w,
        'Ceiling_Dropped': specs['Ceiling_Dropped'],
        'Furnish_Condition': furnish,
        'Ceiling_Full_Structure': specs['Ceiling_Full_Structure'],
        'Ceiling_Replacement': replace_specs['Ceiling_Replacement'],
        'Column_InUnit': replace_specs['Column_InUnit'],
        'AC_Split_Type': replace_specs['AC_Split_Type'],
        'Pantry_InUnit': replace_specs['Pantry_InUnit'],
        'Bathroom_InUnit': replace_specs['Bathroom_InUnit'],
        'Rent_Term': specs['Rent_Term'],
        'Rent_Deposit': specs['Rent_Deposit'],
        'Rent_Advance': specs['Rent_Advance'],
        'Floor': floor
    }

def _is_subgraph_connected(nodes: tuple, full_graph: dict) -> bool:
    """
    Helper: เช็คว่ากลุ่มของ Node (nodes) เชื่อมต่อกันเองหรือไม่
    โดยใช้เส้นทางที่มีอยู่ใน full_graph
    """
    if not nodes: return False
    if len(nodes) == 1: return True
    
    # แปลง nodes เป็น set เพื่อให้ค้นหาเร็ว
    node_set = set(nodes)
    start_node = nodes[0]
    
    # ใช้ BFS/DFS เดินจากจุดแรก
    # แต่เดินไปหาได้ "เฉพาะเพื่อนที่อยู่ใน node_set" เท่านั้น
    visited = set()
    stack = [start_node]
    visited.add(start_node)
    count = 0
    
    while stack:
        curr = stack.pop()
        count += 1
        
        # ดูเพื่อนของ curr ในกราฟใหญ่
        for neighbor in full_graph[curr]:
            # เงื่อนไขสำคัญ: เพื่อนต้องอยู่ในกลุ่ม node_set ที่เราสนใจ
            if neighbor in node_set and neighbor not in visited:
                visited.add(neighbor)
                stack.append(neighbor)
    
    # ถ้าจำนวนที่เดินไปถึง เท่ากับ จำนวนทั้งหมดในกลุ่ม -> แสดงว่าเชื่อมถึงกันหมด
    return count == len(nodes)

def get_furnish_index(furnish: str) -> Optional[int]:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        if furnish == None:
            return 2
        cur.execute("""select Furnish_Condition + 0 as Furnish_Index from office_unit where Furnish_Condition = %s limit 1""", (furnish,))
        row = cur.fetchone()
        return row['Furnish_Index']
    finally:
        cur.close()
        conn.close()

# ----------------------------------------------------- INSERT --------------------------------------------------------------------------------------------
@router.post("/insert", status_code=201)
def insert_office_unit_and_return_full_record(
    response: Response,
    Building: int = Form(...),
    Unit_NO: str = Form(...),
    Rent_Price: str = Form(None),
    Size: str = Form(None),
    Unit_Status: str = Form("0"),  # <- ENUM('0','1','2','3')
    Available: str = Form(None),       # จะถูกแปลงเป็น 'YYYY-MM-DD HH:MM:SS'
    Furnish_Condition: str = Form('Standard'),
    Combine_Divide: str = Form(None),
    Min_Divide_Size: str = Form(None),
    Floor_Zone: str = Form(None),
    Floor: str = Form(None),
    Floor_Replacement: str = Form(None),
    View_N: str = Form(None),
    View_E: str = Form(None),
    View_S: str = Form(None),
    View_W: str = Form(None),
    Ceiling_Dropped: str = Form(None),
    Ceiling_Full_Structure: str = Form(None),
    Ceiling_Replacement: str = Form(None),
    Column_InUnit: str = Form(None),
    AC_Split_Type: str = Form(None),
    Pantry_InUnit: str = Form(None),
    Bathroom_InUnit: str = Form(None),
    Rent_Term: str = Form(None),
    Rent_Deposit: str = Form(None),
    Rent_Advance: str = Form(None),
    Unit_Description: str = Form(None),
    User_ID: int = Form(...),         # <- DB เป็น INT
    Created_By: int = Form(...),          # <- DB เป็น INT
    Last_Updated_By: int = Form(...),     # <- DB เป็น INT
    Virtual_Room: str = Form(None),
    _ = Depends(get_current_user),
):
    try:
        Rent_Price = None if not Rent_Price else int(Rent_Price)
        Size = None if not Size else float(Size)
        Available = None if not Available else datetime.strptime(Available, "%Y-%m-%d")
        Unit_Status = Unit_Status if Unit_Status else '0'
        Bathroom_InUnit = None if not Bathroom_InUnit else int(Bathroom_InUnit)
        Rent_Term = None if not Rent_Term else int(Rent_Term)
        Rent_Deposit = None if not Rent_Deposit else int(Rent_Deposit)
        Rent_Advance = None if not Rent_Advance else int(Rent_Advance)
        Furnish_Condition = Furnish_Condition if Furnish_Condition else 'Standard'
        Floor = Floor if Floor else None
        Floor_Replacement = None if not Floor_Replacement else int(Floor_Replacement)
        Combine_Divide = None if not Combine_Divide else int(Combine_Divide)
        Min_Divide_Size = None if not Min_Divide_Size else float(Min_Divide_Size)
        Floor_Zone = Floor_Zone if Floor_Zone else None
        View_N = None if not View_N else int(View_N)
        View_E = None if not View_E else int(View_E)
        View_S = None if not View_S else int(View_S)
        View_W = None if not View_W else int(View_W)
        Ceiling_Dropped = None if not Ceiling_Dropped else float(Ceiling_Dropped)
        Ceiling_Full_Structure = None if not Ceiling_Full_Structure else float(Ceiling_Full_Structure)
        Ceiling_Replacement = None if not Ceiling_Replacement else int(Ceiling_Replacement)
        Column_InUnit = None if not Column_InUnit else int(Column_InUnit)
        AC_Split_Type = None if not AC_Split_Type else int(AC_Split_Type)
        Pantry_InUnit = None if not Pantry_InUnit else int(Pantry_InUnit)
        Unit_Description = Unit_Description if Unit_Description else None
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")
    
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        sql = f"""
            INSERT INTO {TABLE}
            (Building_ID, Unit_NO, Rent_Price, Size, Unit_Status, Available, Furnish_Condition, Combine_Divide, Min_Divide_Size, Floor_Zone
            , Floor, Floor_Replacement, View_N, View_E, View_S, View_W, Ceiling_Dropped, Ceiling_Full_Structure, Ceiling_Replacement, Column_InUnit
            , AC_Split_Type, Pantry_InUnit, Bathroom_InUnit, Rent_Term, Rent_Deposit, Rent_Advance, Unit_Description, User_ID, Created_By, Last_Updated_By)
            VALUES (%s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (
            Building, Unit_NO, Rent_Price, Size, Unit_Status, Available, Furnish_Condition, Combine_Divide, Min_Divide_Size, Floor_Zone
            , Floor, Floor_Replacement, View_N, View_E, View_S, View_W, Ceiling_Dropped, Ceiling_Full_Structure, Ceiling_Replacement, Column_InUnit
            , AC_Split_Type, Pantry_InUnit, Bathroom_InUnit, Rent_Term, Rent_Deposit, Rent_Advance, Unit_Description, User_ID, Created_By, Last_Updated_By
        ))
        new_id = cur.lastrowid
        
        furnish_index = get_furnish_index(Furnish_Condition)
        if Virtual_Room:
            new_unit_data = {
            'Unit_ID': new_id,
            'Unit_NO': Unit_NO,
            'Building_ID': Building,
            'Size': Size if Size is not None else 0.0,
            'Rent_Price': Rent_Price if Rent_Price is not None else 0.0,
            'Available_Date': Available.date() if Available is not None else None,
            'Min_Divide_Size': Min_Divide_Size if Min_Divide_Size is not None else 0.0,
            'Floor_Replacement': Floor_Replacement,
            'View_N': View_N,
            'View_E': View_E,
            'View_S': View_S,
            'View_W': View_W,
            'Ceiling_Dropped': Ceiling_Dropped if Ceiling_Dropped is not None else 0.0,
            'Furnish_Condition': furnish_index,
            'Ceiling_Full_Structure': Ceiling_Full_Structure if Ceiling_Full_Structure is not None else 0.0,
            'Ceiling_Replacement': Ceiling_Replacement,
            'Column_InUnit': Column_InUnit,
            'AC_Split_Type': AC_Split_Type,
            'Pantry_InUnit': Pantry_InUnit,
            'Bathroom_InUnit': Bathroom_InUnit,
            'Rent_Term': Rent_Term if Rent_Term is not None else 0,
            'Rent_Deposit': Rent_Deposit if Rent_Deposit is not None else 0,
            'Rent_Advance': Rent_Advance if Rent_Advance is not None else 0,
            'Floor': Floor
            }
            _process_virtual_room_additive(cur=cur,new_unit_data=new_unit_data,virtual_room_str=Virtual_Room, created_by=Created_By, work_state='create')
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert failed: {e}")
    finally:
        cur.close()
        conn.close()

    row = _select_full_office_unit_item(new_id)
    if not row:
        return to_problem(500, "Server Error", "Created but cannot fetch newly created resource.")
    response.headers["Location"] = f"/office-unit/select-office-unit/{new_id}"
    return apply_etag_and_return(response, row)


# ----------------------------------------------------- UPDATE --------------------------------------------------------------------------------------------
@router.put("/update/{Unit_ID}", status_code=200)
@router.post("/update/{Unit_ID}", status_code=200)  # รองรับส่งจาก form
def update_office_unit_and_return_full_record(
    Unit_ID: int,
    response: Response,
    Building: int = Form(...),
    Unit_NO: str = Form(...),
    Rent_Price: str = Form(None),
    Size: str = Form(None),
    Unit_Status: str = Form("0"),  # <- ENUM('0','1','2','3')
    Available: str = Form(None),       # จะถูกแปลงเป็น 'YYYY-MM-DD HH:MM:SS'
    Furnish_Condition: str = Form('Standard'),
    Combine_Divide: str = Form(None),
    Min_Divide_Size: str = Form(None),
    Floor_Zone: str = Form(None),
    Floor: str = Form(None),
    Floor_Replacement: str = Form(None),
    View_N: str = Form(None),
    View_E: str = Form(None),
    View_S: str = Form(None),
    View_W: str = Form(None),
    Ceiling_Dropped: str = Form(None),
    Ceiling_Full_Structure: str = Form(None),
    Ceiling_Replacement: str = Form(None),
    Column_InUnit: str = Form(None),
    AC_Split_Type: str = Form(None),
    Pantry_InUnit: str = Form(None),
    Bathroom_InUnit: str = Form(None),
    Rent_Term: str = Form(None),
    Rent_Deposit: str = Form(None),
    Rent_Advance: str = Form(None),
    Unit_Description: str = Form(None),
    User_ID: int = Form(...),         # <- DB เป็น INT
    Last_Updated_By: int = Form(...),     # <- DB เป็น INT  
    Virtual_Room: str = Form(None),
    if_match: Optional[str] = Header(None, alias="If-Match"),
    _ = Depends(get_current_user),
):
    try:
        Rent_Price = None if not Rent_Price else int(Rent_Price)
        Size = None if not Size else float(Size)
        Available = None if not Available else datetime.strptime(Available, "%Y-%m-%d")
        Unit_Status = Unit_Status if Unit_Status else '0'
        Bathroom_InUnit = None if not Bathroom_InUnit else int(Bathroom_InUnit)
        Rent_Term = None if not Rent_Term else int(Rent_Term)
        Rent_Deposit = None if not Rent_Deposit else int(Rent_Deposit)
        Rent_Advance = None if not Rent_Advance else int(Rent_Advance)
        Furnish_Condition = Furnish_Condition if Furnish_Condition else 'Standard'
        Floor = Floor if Floor else None
        Floor_Replacement = None if not Floor_Replacement else int(Floor_Replacement)
        Combine_Divide = None if not Combine_Divide else int(Combine_Divide)
        Min_Divide_Size = None if not Min_Divide_Size else float(Min_Divide_Size)
        Floor_Zone = Floor_Zone if Floor_Zone else None
        View_N = None if not View_N else int(View_N)
        View_E = None if not View_E else int(View_E)
        View_S = None if not View_S else int(View_S)
        View_W = None if not View_W else int(View_W)
        Ceiling_Dropped = None if not Ceiling_Dropped else float(Ceiling_Dropped)
        Ceiling_Full_Structure = None if not Ceiling_Full_Structure else float(Ceiling_Full_Structure)
        Ceiling_Replacement = None if not Ceiling_Replacement else int(Ceiling_Replacement)
        Column_InUnit = None if not Column_InUnit else int(Column_InUnit)
        AC_Split_Type = None if not AC_Split_Type else int(AC_Split_Type)
        Pantry_InUnit = None if not Pantry_InUnit else int(Pantry_InUnit)
        Unit_Description = Unit_Description if Unit_Description else None
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")

    try:
        current = _select_full(Unit_ID)
        if not current:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                detail=f"Unit '{Unit_ID}' was not found")

        if if_match and if_match != etag_of(current):
            raise HTTPException(status_code=status.HTTP_412_PRECONDITION_FAILED,
                            detail="ETag mismatch. Please GET latest and retry with If-Match.")
    
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        last_available_date = 'null'
        if Unit_Status == "1":
            check_status_query = f"""SELECT Unit_Status FROM {TABLE} WHERE Unit_ID=%s"""
            cur.execute(check_status_query, (Unit_ID,))
            unit_status = cur.fetchone()
            if unit_status['Unit_Status'] == '0':
                last_available_date = 'CURRENT_TIMESTAMP'
                Available = None
        
        sql = f"""
            UPDATE {TABLE}
            SET Building_ID=%s,
                Unit_NO=%s,
                Rent_Price=%s,
                Size=%s,
                Furnish_Condition=%s,
                Combine_Divide=%s,
                Min_Divide_Size=%s,
                Floor_Zone=%s,
                Floor=%s,
                Floor_Replacement=%s,
                View_N=%s,
                View_E=%s,
                View_S=%s,
                View_W=%s,
                Ceiling_Dropped=%s,
                Ceiling_Full_Structure=%s,
                Ceiling_Replacement=%s,
                Column_InUnit=%s,
                AC_Split_Type=%s,
                Pantry_InUnit=%s,
                Bathroom_InUnit=%s,
                Rent_Term=%s,
                Rent_Deposit=%s,
                Rent_Advance=%s,
                Unit_Description=%s,
                Available=%s,
                User_ID=%s,
                Unit_Status=%s,
                Last_Updated_By=%s,
                Last_Updated_Date=CURRENT_TIMESTAMP,
                Last_Available_Date={last_available_date}
            WHERE Unit_ID=%s
        """
        cur.execute(sql, (
            Building, Unit_NO, Rent_Price, Size, Furnish_Condition, Combine_Divide, Min_Divide_Size, Floor_Zone, Floor, Floor_Replacement, View_N
            , View_E, View_S, View_W, Ceiling_Dropped, Ceiling_Full_Structure, Ceiling_Replacement, Column_InUnit, AC_Split_Type, Pantry_InUnit, Bathroom_InUnit, Rent_Term
            , Rent_Deposit, Rent_Advance, Unit_Description, Available, User_ID, Unit_Status, Last_Updated_By, Unit_ID))
        
        if Unit_Status == "1":
            sql = f"""UPDATE office_unit_image SET Image_Status='1' WHERE Unit_ID=%s"""
            cur.execute(sql, (Unit_ID,))
        
        furnish_index = get_furnish_index(Furnish_Condition)
        new_unit_data = {
            'Unit_ID': Unit_ID,
            'Unit_NO': Unit_NO,
            'Building_ID': Building,
            'Size': Size if Size is not None else 0.0,
            'Rent_Price': Rent_Price if Rent_Price is not None else 0.0,
            'Available_Date': Available.date() if Available is not None else None,
            'Min_Divide_Size': Min_Divide_Size if Min_Divide_Size is not None else 0.0,
            'Floor_Replacement': Floor_Replacement,
            'View_N': View_N,
            'View_E': View_E,
            'View_S': View_S,
            'View_W': View_W,
            'Ceiling_Dropped': Ceiling_Dropped if Ceiling_Dropped is not None else 0.0,
            'Furnish_Condition': furnish_index,
            'Ceiling_Full_Structure': Ceiling_Full_Structure if Ceiling_Full_Structure is not None else 0.0,
            'Ceiling_Replacement': Ceiling_Replacement,
            'Column_InUnit': Column_InUnit,
            'AC_Split_Type': AC_Split_Type,
            'Pantry_InUnit': Pantry_InUnit,
            'Bathroom_InUnit': Bathroom_InUnit,
            'Rent_Term': Rent_Term if Rent_Term is not None else 0,
            'Rent_Deposit': Rent_Deposit if Rent_Deposit is not None else 0,
            'Rent_Advance': Rent_Advance if Rent_Advance is not None else 0,
            'Floor': Floor,
            }
        if Virtual_Room and Unit_Status == "1":
            _process_virtual_room_additive(cur=cur,new_unit_data=new_unit_data,virtual_room_str=Virtual_Room, created_by=Last_Updated_By, work_state='update')
        if Unit_Status != "1" or not Virtual_Room:
            _process_virtual_room_additive(cur=cur,new_unit_data=new_unit_data,virtual_room_str=None, created_by=None, work_state='delete')
        
        conn.commit()
    except HTTPException as he:
    # สำคัญ: ส่ง 404/412 ออกไปตรง ๆ
        raise he
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Update failed: {e}")
    finally:
        cur.close()
        conn.close()

    row = _select_full(Unit_ID)
    return apply_etag_and_return(response, row)

# ----------------------------------------------------- DELETE --------------------------------------------------------------------------------------------
@router.delete("/delete/{Unit_ID}", status_code=204)
@router.post("/delete/{Unit_ID}", status_code=204)  # รองรับ form
def delete_office_unit(
    Unit_ID: int,
    _ = Depends(get_current_user),
):
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        cur.execute(f"UPDATE {TABLE} SET Unit_Status='2' WHERE Unit_ID=%s", (Unit_ID,))
        affected = cur.rowcount
        conn.commit()
        
        cur.execute(f"SELECT Unit_Image_ID FROM office_unit_image WHERE Unit_ID=%s", (Unit_ID,))
        rows = cur.fetchall()
        for row in rows:
            _delete_unit_image(row['Unit_Image_ID'], "Delete_Unit")
        
        new_unit_data = {'Unit_ID': Unit_ID}
        _process_virtual_room_additive(cur=cur,new_unit_data=new_unit_data,virtual_room_str=None, created_by=None, work_state='delete')
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Delete failed: {e}")
    finally:
        cur.close()
        conn.close()

    if affected == 0:
        # 404 แบบ problem+json
        return to_problem(404, "Not Found", f"Unit '{Unit_ID}' was not found.")
    # 204 No Content → ไม่ส่ง body

# ====================== SELECT ALL ======================
@router.get("/select/all/{User_ID}", status_code=200)
def select_all_office_units(
    User_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        building_result = _get_building_relationship(User_ID)
        building_result.sort(key=lambda x: x[1])
        
        base_sql = f"""
            SELECT
                *
            FROM {TABLE}
            WHERE User_ID=%s
            AND Unit_Status <> '2'
            ORDER BY Unit_ID DESC
        """

        cur.execute(base_sql, (User_ID,))
        rows = cur.fetchall()
        data = []
        for b in building_result:
            proj_id = b[1]
            project_nameth, project_nameen = _get_project_name(proj_id)
            project = next((p for p in data if p["Project_ID"] == proj_id), None)
            if not project:
                project = {
                    "Project_ID": proj_id,
                    "Project_Name_TH": project_nameth,
                    "Project_Name_EN": project_nameen,
                    "Buildings": []
                }
                data.append(project)
            
            building_id = b[0]
            building_name = _get_building_name(building_id)
            building = next((b for b in project["Buildings"] if b["Building_ID"] == building_id), None)
            if not building:
                building = {
                    "Building_ID": building_id,
                    "Building_Name": building_name,
                    "Units": []
                }
                project["Buildings"].append(building)
            
            for row in rows:
                if row["Building_ID"] == building_id:
                    unit = {k: row[k] for k in row.keys()}
                    building["Units"].append(unit)
    
        for project in data:
            for building in project["Buildings"]:
                building["Units"].sort(key=lambda u: u["Last_Updated_Date"], reverse=True)
        
        return {"data": data}
    finally:
        cur.close()
        conn.close()

# ====================== SELECT BY KEY ======================
@router.get("/select/{Unit_ID}", status_code=200)
def select_office_unit_by_id(
    response: Response,
    Unit_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_full(Unit_ID)
    require_row_exists(row, Unit_ID, 'Unit')

    et = etag_of(row)
    # ถ้า client ส่ง If-None-Match มาและตรง → 304
    if if_none_match and if_none_match == et:
        response.headers["ETag"] = et
        response.status_code = status.HTTP_304_NOT_MODIFIED
        return

    return apply_etag_and_return(response, row)

# ============ อัปโหลดกี่ไฟล์ก็ได้ + บันทึก DB ============
@router.post("/images/record", status_code=201)
async def upload_and_record(
    files: List[UploadFile] = File(...),
    Unit_Category_ID: int = Form(...),
    Unit_ID: int = Form(...),
    Image_caption: str = Form(...),
    Created_By: int = Form(...),
    Image_Status: str = Form("0"),
    _ = Depends(get_current_user),
):
    if not files:
        raise HTTPException(status_code=400, detail="No files")

    results = []
    image_size_list = [(1440,810),(800,450),(400,225)]
    order = _get_unit_display_order(Unit_ID, Unit_Category_ID)
    images_name = Image_caption.split(";")
    for i ,f in enumerate(files):
        name = f.filename or "unnamed"
        ext = os.path.splitext(name)[1].lower()
        content_type = f.content_type
        if ext not in ALLOWED_EXT:
            raise HTTPException(status_code=400, detail=f"File type not allowed: {ext}")
        
        file_bytes = f.file.read()
        record = _insert_image_record(
            unit_id=Unit_ID,
            unit_category_id=Unit_Category_ID,
            image_name=images_name[i],
            image_url="",
            display_order=order,
            image_status=Image_Status,
            created_by=Created_By,
        )
        image_id = record["Unit_Image_ID"]
        building_id = _get_building_id(Unit_ID)
        project_id = _get_project_id(building_id)

        for image_size in image_size_list:
            meta = _save_one_file(file_bytes, Unit_ID, image_id, building_id, project_id, image_size, content_type)
            if image_size[0] == 1440:
                _update_image_record(
                    image_id=image_id,
                    image_url=meta["url"],
                )
            
                record["Image_Url"] = meta["url"]
        
            results.append({"file": meta, "record": record})
        order += 1

    return {"count": len(results), "items": results}

# ----------------------------------------------------- UPDATE Image Order --------------------------------------------------------------------------------------------
@router.put("/image/update/image_order", status_code=200)
@router.post("/image/update/image_order", status_code=200)
def update_unit_image_order(
    Display_Order: str = Form(...),
    _ = Depends(get_current_user),
):
    order_list = Display_Order.split(",")
    results = []
    for i, order in enumerate(order_list):
        meta = _update_image_order(image_id=int(order), display_order=i+1, table_name="office_unit_image", id_column="Unit_Image_ID")
        results.append({"data": meta})

    return {"items": results}

# ----------------------------------------------------- UPDATE Image Name --------------------------------------------------------------------------------------------
@router.put("/image/update/image_caption", status_code=200)
@router.post("/image/update/image_caption", status_code=200)
def update_project_image_caption(
    Unit_Image_ID: int = Form(...),
    Image_Caption: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    update_query = "UPDATE office_unit_image SET Image_Name = %s WHERE Unit_Image_ID = %s"
    try:
        cur.execute(update_query, (Image_Caption, Unit_Image_ID))
        conn.commit()
        return {"data": {"Unit_Image_ID": Unit_Image_ID, "Image_Name": Image_Caption}}
    except Exception as e:
        return to_problem(409, "Conflict", f"Update Unit Image Caption failed: {e}")
    finally:
        cur.close()
        conn.close()

# ============ ลบ ============
@router.delete("/images/delete/{Image_ID}", status_code=204)
@router.post("/images/delete/{Image_ID}", status_code=204)
async def delete_image_record(
    Image_ID: int,
    _ = Depends(get_current_user),
):
    _delete_unit_image(Image_ID, "Delete_Image")

# ====================== SELECT BY KEY ======================
@router.get("/images/select/{Unit_ID}", status_code=200)
def select_all_office_unit_images(
    Unit_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    response: Response = Response(),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        categories = _select_all_unit_image_category(id_column="Unit_Category_ID", table_name="office_unit_image_category")
        unit = _select_full(Unit_ID)
        require_row_exists(unit, Unit_ID, 'Unit')
        
        et = etag_of(unit)
        # ถ้า client ส่ง If-None-Match มาและตรง → 304
        if if_none_match and if_none_match == et:
            response.headers["ETag"] = et
            response.status_code = status.HTTP_304_NOT_MODIFIED
            return
        
        base_sql = """SELECT
                        a.Unit_Image_ID,
                        a.Unit_Category_ID,
                        a.Unit_ID,
                        a.Image_Name,
                        a.Image_Url,
                        a.Display_Order,
                        a.Image_Status,
                        a.Created_By,
                        a.Created_Date,
                        a.Last_Updated_By,
                        a.Last_Updated_Date,
                        b.Category_Name,
                        b.Section
                    FROM office_unit_image a
                    JOIN office_unit_image_category b ON a.Unit_Category_ID = b.Unit_Category_ID
                    WHERE a.Unit_ID = %s AND a.Unit_Category_ID = %s AND a.Image_Status = '1'
                    ORDER BY b.Display_Order, a.Display_Order"""
        
        data = []
        for row in categories:
            cur.execute(base_sql, (Unit_ID, row["Unit_Category_ID"]))
            rows = cur.fetchall()
            rows = [normalize_row(r) for r in rows]
            data.append({"category_id": row["Unit_Category_ID"], "category": row["Category_Name"], "list": rows})

        return {"data": data}
    
    finally:
        cur.close()
        conn.close()

# ====================== SELECT ALL unit_adjacency ======================
@router.put("/select/unit_adjacency/all", status_code=200)
@router.post("/select/unit_adjacency/all", status_code=200)
def select_all_unit_adjacency(
    Floor: str = Form(...),
    Building: str = Form(...),
    State: str = Form(...),
    Unit_ID: str = Form(None),
    _ = Depends(get_current_user),
):
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        Floor = None if not Floor else int(Floor)
        Building = None if not Building else int(Building)
        Unit_ID = None if not Unit_ID else int(Unit_ID)
        
        checked_unit_ids = set()
        
        if State == 'update':
            virtual_room_query = """
                SELECT Virtual_ID 
                FROM office_unit_virtual_room_mapping
                WHERE Unit_ID = %s"""
            cur.execute(virtual_room_query, (Unit_ID,))
            virtual_room_row = cur.fetchall()

            if virtual_room_row:
                virtual_ids = [r['Virtual_ID'] for r in virtual_room_row]
                placeholders = ', '.join(['%s'] * len(virtual_ids))
                select_max_query = f"""
                                    SELECT Virtual_ID
                                    FROM office_unit_virtual_room_mapping
                                    WHERE Virtual_ID IN ({placeholders})
                                    GROUP BY Virtual_ID
                                    ORDER BY COUNT(*) DESC
                                    LIMIT 1"""
                cur.execute(select_max_query, tuple(virtual_ids))
                best_room = cur.fetchone()
                
                ids_query = "SELECT Unit_ID FROM office_unit_virtual_room_mapping WHERE Virtual_ID = %s"
                cur.execute(ids_query, (best_room['Virtual_ID'],))
                checked_unit_ids = {row['Unit_ID'] for row in cur.fetchall()}

        base_query = """
            SELECT Unit_ID, Unit_NO 
            FROM office_unit
            WHERE Building_ID = %s AND Floor = %s 
            AND Unit_Status = '1' AND Combine_Divide = 1"""
        params = [Building, Floor]

        if State == 'update':
            base_query += " AND Unit_ID != %s"
            params.append(Unit_ID)

        cur.execute(base_query, tuple(params))
        adjacency_rows = cur.fetchall()

        for unit in adjacency_rows:
            unit['Check'] = 1 if unit['Unit_ID'] in checked_unit_ids else 0

        return adjacency_rows

    finally:
        cur.close()
        conn.close()
        
# ====================== Agent Gen Link ======================
@router.get("/agent-gen-link/{Unit_ID}", status_code=200)
def agent_gen_unit_link(
    Unit_ID: int,
    User_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        unit_data = _select_full(Unit_ID)
        if not unit_data:
            return to_problem(404, "Not Found", "Unit not found")
        
        building_id = unit_data['Building_ID']
        project_id = _get_project_id(building_id)
        
        unit_link = gen_link(unit_data['Unit_ID'], project_id, 2, None, User_ID, None)
        
        return [{"Unit_ID": unit_data['Unit_ID'], "Unit_Link": unit_link}]
    
    except Exception as e:
        return to_problem(409, "Conflict", f"Generate Unit Link error: {e}")
    finally:
        cur.close()
        conn.close()
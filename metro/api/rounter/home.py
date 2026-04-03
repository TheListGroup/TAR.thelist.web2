from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from typing import Optional, Tuple, Dict, Any, List
import json

router = APIRouter()

def _select_active_category_hierarchies(cur):
    sql = """
        SELECT DISTINCT 
            c.ID, 
            c.Category_Name, 
            c.Parent_ID, 
            c.Categories_Order
        FROM home_image h
        -- ดึงชื่อจาก JSON กิ่ง l2 หรือ l3 มาเทียบ (ตัวอย่างนี้เทียบ l2 และ l3)
        JOIN proj_categories c ON (
            c.Category_Name = h.Category_Hierarchy->>'$.l2' OR 
            c.Category_Name = h.Category_Hierarchy->>'$.l3'
        )
        WHERE h.Card_Type = 'PROJECT' 
        AND h.Category_Hierarchy->>'$.l1' = 'PROJECT'
        AND c.Categories_Status = '1'
        ORDER BY c.Parent_ID , c.Categories_Order
    """
    cur.execute(sql)
    return cur.fetchall()

def _select_active_expertise_hierarchies(cur):
    sql = """
        SELECT DISTINCT 
            c.ID, 
            c.Responsibility, 
            c.Parent_ID, 
            c.Expertise_Order
        FROM home_image h
        -- ดึงชื่อจาก JSON กิ่ง l2 หรือ l3 มาเทียบ (ตัวอย่างนี้เทียบ l2 และ l3)
        JOIN prof_expertise c ON (
            c.Responsibility = h.Category_Hierarchy->>'$.l2' OR 
            c.Responsibility = h.Category_Hierarchy->>'$.l3'
        )
        WHERE h.Card_Type = 'PROFESSIONAL' 
        AND h.Category_Hierarchy->>'$.l1' = 'PROFESSIONAL'
        AND c.Expertise_Status = '1'
        ORDER BY c.Parent_ID , c.Expertise_Order
    """
    cur.execute(sql)
    return cur.fetchall()

def create_json(data, state):
    if state == 'PROJECT':
        cate_column = 'Category_Name'
    elif state == 'PROFESSIONAL':
        cate_column = 'Responsibility'
    
    # 1. แยกกลุ่ม Parent เหมือนเดิม (เพื่อเอาไว้หาลูก)
    by_parent = {}
    for r in data:
        p_id = r['Parent_ID'] if r['Parent_ID'] is not None else 0
        if p_id not in by_parent:
            by_parent[p_id] = []
        by_parent[p_id].append(r)

    # 2. สร้างโครงสร้าง Head_Cate สำหรับ PROJECT
    head_cate_list = []
    
    # -- อันดับแรกสุดของ PROJECT คือ ALL PROJECTS --
    #head_cate_list.append({"ID": 0, "Head_Name": f"ALL {state}S", "Order": 1, "Sub_Cate": None})
    head_cate_list.append({"ID": 0, "Head_Name": f"ALL", "Order": 1, "Sub_Cate": None})

    # 3. วนลูปเฉพาะพวก Parent_ID IS NULL (จากรูปคือ ID 1-15)
    # พวกนี้จะเป็น Head_Name
    roots = by_parent.get(0, [])
    for idx, root in enumerate(roots, 2): # เริ่ม Order ที่ 2
        root_id = root['ID']
        root_name = root[cate_column].upper()
        
        # 4. สร้าง Sub_Cate ของแต่ละ Head
        sub_cate_list = []
        # ต้องมี ALL ของตัวเองก่อน (เช่น ALL RESIDENTIAL PROJECTS)
        #sub_cate_list.append({"ID": 0, "Sub_Name": f"ALL {root_name} {state}S", "Order": 1})
        sub_cate_list.append({"ID": 0, "Sub_Name": f"ALL", "Order": 1})
        
        # ดึงลูกจริงๆ มาใส่ (เช่น ID 16, 17, 18 มาใส่ใต้ ID 1)
        children = by_parent.get(root_id, [])
        for c_idx, child in enumerate(children, 2):
            sub_cate_list.append({"ID": child['ID'], "Sub_Name": child[cate_column].upper(), "Order": c_idx})
            
        # ประกอบเข้า Head_Cate
        head_cate_list.append({
            "ID": root_id,
            "Head_Name": root_name,
            "Order": idx,
            "Sub_Cate": sub_cate_list
        })
    return head_cate_list

def get_home_images(cur, start_order, amount, category_path):
    filters = []
    params = []
    
    l1_type = category_path[0].upper() if category_path else None
    if l1_type and l1_type != "ALL":
        filters.append("UPPER(Card_Type) = %s")
        params.append(l1_type)
    
    #for i, val in enumerate(category_path, 1):
    #    if val and val.upper() != "ALL":
    #        filters.append(f"Category_Hierarchy->>'$.l{i}' = %s")
    #        params.append(val.upper())
    
    for val in category_path[1:]:
        if val and val.upper() != "ALL":
            filters.append("JSON_CONTAINS(UPPER(All_Category), JSON_QUOTE(UPPER(%s)))")
            params.append(val)
    
    filter_sql = " AND ".join(filters) if filters else "1=1"
    
    cur.execute("select count(*) as amount from home_image where " + filter_sql, params)
    total = cur.fetchone()['amount']
    
    sql = f"""
        SELECT 
            Card_Type, Category, Card_Name, Card_Sub_Name, 
            Brief_Description, Image_URL, Card_Logo, Image_Order, Card_Url, DATE(Last_Updated_Date) as Last_Updated_Date
        FROM home_image
        WHERE {filter_sql}
        ORDER BY Image_Order ASC
        LIMIT %s OFFSET %s
    """
    
    # Pagination: start_order มักเริ่มที่ 1, OFFSET เริ่มที่ 0
    offset = max(0, start_order - 1)
    params.extend([amount, offset])
    
    cur.execute(sql, params)
    data = cur.fetchall()
    
    return data, total

def _select_active_category(cur):
    sql = """
        SELECT DISTINCT 
            c.ID, 
            c.Category_Name, 
            c.Parent_ID, 
            c.Categories_Order
        FROM home_image h
        JOIN proj_categories c ON (
            c.Category_Name MEMBER OF (h.All_Category)
        )
        WHERE h.Card_Type = 'PROJECT' 
        AND c.Categories_Status = '1'
        AND h.All_Category IS NOT NULL
        ORDER BY c.Parent_ID ASC, c.Categories_Order ASC
    """
    cur.execute(sql)
    return cur.fetchall()

def _select_active_expertise(cur):
    sql = """
        SELECT DISTINCT 
            c.ID, 
            c.Responsibility, 
            c.Parent_ID, 
            c.Expertise_Order
        FROM home_image h
        JOIN prof_expertise c ON (
            c.Responsibility MEMBER OF (h.All_Category)
        )
        WHERE h.Card_Type = 'PROFESSIONAL' 
        AND c.Expertise_Status = '1'
        AND h.All_Category IS NOT NULL
        ORDER BY c.Parent_ID , c.Expertise_Order
    """
    cur.execute(sql)
    return cur.fetchall()

@router.get("/home-template-tag", status_code=200)
def home_template_tag(
    _ = Depends(get_current_user),
):
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    
    #proj_cate_data = _select_active_category_hierarchies(cur2)
    proj_cate_data = _select_active_category(cur2)
    if proj_cate_data:
        proj = create_json(proj_cate_data, 'PROJECT')
    else:
        proj = None
    
    #prof_cate_data = _select_active_expertise_hierarchies(cur2)
    prof_cate_data = _select_active_expertise(cur2)
    if prof_cate_data:
        prof = create_json(prof_cate_data, 'PROFESSIONAL')
    else:
        prof = None
    
    header_response = [
        {"Tag": "ALL", "Head_Cate": None},
        {"Tag": "PROJECT", "Head_Cate": proj},
        {"Tag": "PROFESSIONAL", "Head_Cate": prof},
        {"Tag": "PRODUCT", "Head_Cate": None}
    ]

    cur2.close()
    conn2.close()
    
    return {"Header": header_response}


@router.post("/home-template-image", status_code=201)
def home_template_image(
    Start_Order: int = Form(...),
    Amount: int = Form(...),
    Category: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    
    category_path = Category.split("/")
    rows, total = get_home_images(cur, Start_Order, Amount, category_path)
    
    output_images = []
    for row in rows:
        item = {
                "Type": row['Card_Type'],
                "Tag": row['Category'],
                "Name": row['Card_Name'],
                "Sub_Name": row['Card_Sub_Name'],
                "Description": row['Brief_Description'],
                "Image": row['Image_URL'],
                "Order": row['Image_Order'],
                "Logo": row['Card_Logo'],
                "Url": row['Card_Url']
            }
        output_images.append(item)
    
    cur.close()
    conn.close()
    
    return {"Total": total, "Last_Updated_Date": rows[0]["Last_Updated_Date"] if rows else None, "Images": output_images}
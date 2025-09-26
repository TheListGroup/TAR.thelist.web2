from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists, normalize_row
from function_query_helper import _select_full_office_unit_item, _select_full, _get_building_id, _get_project_id \
    , _get_unit_display_order, _select_all_unit_image_category, _get_building_relationship, _get_project_name, _get_building_name \
    , _update_image_order
from typing import Optional, Tuple, Dict, Any, List
import os, uuid, shutil
from PIL import Image
import re
from wand.image import Image as WandImage
from io import BytesIO

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
    *, image_id, image_name: str, image_url: str,
) -> dict:
    conn = get_db()
    cur = conn.cursor()
    try:
        sql = """
            UPDATE office_unit_image
            SET Image_Name=%s, Image_Url=%s
            WHERE Unit_Image_ID=%s
        """
        cur.execute(sql, (image_name, image_url, image_id))
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

# ----------------------------------------------------- INSERT --------------------------------------------------------------------------------------------
@router.post("/insert", status_code=201)
def insert_office_unit_and_return_full_record(
    response: Response,
    Building: int = Form(...),
    Unit_NO: str = Form(...),
    Rent_Price: int = Form(...),
    Size: float = Form(...),
    Unit_Status: str = Form("0"),  # <- ENUM('0','1','2','3')
    Available: str = Form(...),       # จะถูกแปลงเป็น 'YYYY-MM-DD HH:MM:SS'
    Furnish_Condition: str = Form('Standard'),
    Combine_Divide: str = Form(None),
    Min_Divide_Size: str = Form(None),
    Floor_Zone: str = Form(None),
    Floor: str = Form(None),
    View_N: str = Form(None),
    View_E: str = Form(None),
    View_S: str = Form(None),
    View_W: str = Form(None),
    Ceiling_Dropped: str = Form(None),
    Ceiling_Full_Structure: str = Form(None),
    Column_InUnit: str = Form(None),
    AC_Split_Type: str = Form(None),
    Pantry_InUnit: str = Form(None),
    Bathroom_InUnit: str = Form(None),
    Rent_Term: str = Form(None),
    Rent_Deposit: str = Form(None),
    Rent_Advance: str = Form(None),
    User_ID: int = Form(...),         # <- DB เป็น INT
    Created_By: int = Form(...),          # <- DB เป็น INT
    Last_Updated_By: int = Form(...),     # <- DB เป็น INT   
    _ = Depends(get_current_user),
):
    try:
        Unit_Status = Unit_Status if Unit_Status else '0'
        Bathroom_InUnit = None if not Bathroom_InUnit else int(Bathroom_InUnit)
        Rent_Term = None if not Rent_Term else int(Rent_Term)
        Rent_Deposit = None if not Rent_Deposit else int(Rent_Deposit)
        Rent_Advance = None if not Rent_Advance else int(Rent_Advance)
        Furnish_Condition = Furnish_Condition if Furnish_Condition else 'Standard'
        Floor = Floor if Floor else None
        Combine_Divide = None if not Combine_Divide else int(Combine_Divide)
        Min_Divide_Size = None if not Min_Divide_Size else float(Min_Divide_Size)
        Floor_Zone = Floor_Zone if Floor_Zone else None
        View_N = None if not View_N else int(View_N)
        View_E = None if not View_E else int(View_E)
        View_S = None if not View_S else int(View_S)
        View_W = None if not View_W else int(View_W)
        Ceiling_Dropped = None if not Ceiling_Dropped else float(Ceiling_Dropped)
        Ceiling_Full_Structure = None if not Ceiling_Full_Structure else float(Ceiling_Full_Structure)
        Column_InUnit = None if not Column_InUnit else int(Column_InUnit)
        AC_Split_Type = None if not AC_Split_Type else int(AC_Split_Type)
        Pantry_InUnit = None if not Pantry_InUnit else int(Pantry_InUnit)
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")
    
    try:
        conn = get_db()
        cur = conn.cursor()
        sql = f"""
            INSERT INTO {TABLE}
            (Building_ID, Unit_NO, Rent_Price, Size, Unit_Status, Available, Furnish_Condition, Combine_Divide, Min_Divide_Size, Floor_Zone
            , Floor, View_N, View_E, View_S, View_W, Ceiling_Dropped, Ceiling_Full_Structure, Column_InUnit, AC_Split_Type, Pantry_InUnit
            , Bathroom_InUnit, Rent_Term, Rent_Deposit, Rent_Advance, User_ID, Created_By, Last_Updated_By)
            VALUES (%s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s
            , %s, %s)
        """
        cur.execute(sql, (
            Building, Unit_NO, Rent_Price, Size, Unit_Status, Available, Furnish_Condition, Combine_Divide, Min_Divide_Size, Floor_Zone
            , Floor, View_N, View_E, View_S, View_W, Ceiling_Dropped, Ceiling_Full_Structure, Column_InUnit, AC_Split_Type, Pantry_InUnit
            , Bathroom_InUnit, Rent_Term, Rent_Deposit, Rent_Advance, User_ID, Created_By, Last_Updated_By
        ))
        conn.commit()
        new_id = cur.lastrowid
        cur.close()
        conn.close()
    except Exception as e:
        return to_problem(409, "Conflict", f"Insert failed: {e}")

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
    Rent_Price: int = Form(...),
    Size: float = Form(...),
    Unit_Status: str = Form("0"),  # <- ENUM('0','1','2','3')
    Available: str = Form(...),       # จะถูกแปลงเป็น 'YYYY-MM-DD HH:MM:SS'
    Furnish_Condition: str = Form('Standard'),
    Combine_Divide: str = Form(None),
    Min_Divide_Size: str = Form(None),
    Floor_Zone: str = Form(None),
    Floor: str = Form(None),
    View_N: str = Form(None),
    View_E: str = Form(None),
    View_S: str = Form(None),
    View_W: str = Form(None),
    Ceiling_Dropped: str = Form(None),
    Ceiling_Full_Structure: str = Form(None),
    Column_InUnit: str = Form(None),
    AC_Split_Type: str = Form(None),
    Pantry_InUnit: str = Form(None),
    Bathroom_InUnit: str = Form(None),
    Rent_Term: str = Form(None),
    Rent_Deposit: str = Form(None),
    Rent_Advance: str = Form(None),
    User_ID: int = Form(...),         # <- DB เป็น INT
    Last_Updated_By: int = Form(...),     # <- DB เป็น INT  
    if_match: Optional[str] = Header(None, alias="If-Match"),
    _ = Depends(get_current_user),
):
    try:
        Unit_Status = Unit_Status if Unit_Status else '0'
        Bathroom_InUnit = None if not Bathroom_InUnit else int(Bathroom_InUnit)
        Rent_Term = None if not Rent_Term else int(Rent_Term)
        Rent_Deposit = None if not Rent_Deposit else int(Rent_Deposit)
        Rent_Advance = None if not Rent_Advance else int(Rent_Advance)
        Furnish_Condition = Furnish_Condition if Furnish_Condition else 'Standard'
        Floor = Floor if Floor else None
        Combine_Divide = None if not Combine_Divide else int(Combine_Divide)
        Min_Divide_Size = None if not Min_Divide_Size else float(Min_Divide_Size)
        Floor_Zone = Floor_Zone if Floor_Zone else None
        View_N = None if not View_N else int(View_N)
        View_E = None if not View_E else int(View_E)
        View_S = None if not View_S else int(View_S)
        View_W = None if not View_W else int(View_W)
        Ceiling_Dropped = None if not Ceiling_Dropped else float(Ceiling_Dropped)
        Ceiling_Full_Structure = None if not Ceiling_Full_Structure else float(Ceiling_Full_Structure)
        Column_InUnit = None if not Column_InUnit else int(Column_InUnit)
        AC_Split_Type = None if not AC_Split_Type else int(AC_Split_Type)
        Pantry_InUnit = None if not Pantry_InUnit else int(Pantry_InUnit)
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
        cur = conn.cursor()
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
                View_N=%s,
                View_E=%s,
                View_S=%s,
                View_W=%s,
                Ceiling_Dropped=%s,
                Ceiling_Full_Structure=%s,
                Column_InUnit=%s,
                AC_Split_Type=%s,
                Pantry_InUnit=%s,
                Bathroom_InUnit=%s,
                Rent_Term=%s,
                Rent_Deposit=%s,
                Rent_Advance=%s,
                Available=%s,
                User_ID=%s,
                Unit_Status=%s,
                Last_Updated_By=%s,
                Last_Updated_Date=CURRENT_TIMESTAMP
            WHERE Unit_ID=%s
        """
        cur.execute(sql, (
            Building, Unit_NO, Rent_Price, Size, Furnish_Condition, Combine_Divide, Min_Divide_Size, Floor_Zone, Floor, View_N
            , View_E, View_S, View_W, Ceiling_Dropped, Ceiling_Full_Structure, Column_InUnit, AC_Split_Type, Pantry_InUnit, Bathroom_InUnit, Rent_Term
            , Rent_Deposit, Rent_Advance, Available, User_ID, Unit_Status, Last_Updated_By, Unit_ID
        ))
        conn.commit()
        
        if Unit_Status == "1":
            sql = f"""UPDATE office_unit_image SET Image_Status='1' WHERE Unit_ID=%s"""
            cur.execute(sql, (Unit_ID,))
            conn.commit()
        
        cur.close()
        conn.close()
    except HTTPException as he:
    # สำคัญ: ส่ง 404/412 ออกไปตรง ๆ
        raise he

    except Exception as e:
        return to_problem(409, "Conflict", f"Update failed: {e}")

    row = _select_full(Unit_ID)
    return apply_etag_and_return(response, row)

# ----------------------------------------------------- DELETE --------------------------------------------------------------------------------------------
@router.delete("/delete/{Unit_ID}", status_code=204)
@router.post("/delete/{Unit_ID}", status_code=204)  # รองรับ form
def delete_office_unit(
    Unit_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(f"UPDATE {TABLE} SET Unit_Status='2' WHERE Unit_ID=%s", (Unit_ID,))
    affected = cur.rowcount
    conn.commit()
    
    cur.execute(f"SELECT Unit_Image_ID FROM office_unit_image WHERE Unit_ID=%s", (Unit_ID,))
    rows = cur.fetchall()
    for row in rows:
        _delete_unit_image(row[0], "Delete_Unit")
    
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
    Created_By: int = Form(...),
    Image_Status: str = Form("0"),
    _ = Depends(get_current_user),
):
    if not files:
        raise HTTPException(status_code=400, detail="No files")

    results = []
    image_size_list = [(1440,810),(800,450),(400,225)]
    order = _get_unit_display_order(Unit_ID, Unit_Category_ID)
    for f in files:
        name = f.filename or "unnamed"
        ext = os.path.splitext(name)[1].lower()
        content_type = f.content_type
        if ext not in ALLOWED_EXT:
            raise HTTPException(status_code=400, detail=f"File type not allowed: {ext}")
        
        file_bytes = f.file.read()
        record = _insert_image_record(
            unit_id=Unit_ID,
            unit_category_id=Unit_Category_ID,
            image_name="",
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
                    image_name=meta["filename"],
                    image_url=meta["url"],
                )
            
                record["Image_Name"] = meta["filename"]
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
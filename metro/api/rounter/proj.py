from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists, normalize_row
from function_query_helper import check_location, check_country, _select_full_proj_item, _select_prof_expertise, url_work, _select_all_location, _select_country \
    , _select_category, _delete_cover, delete_expertise_process, recover_proj_prof_relationship, _insert_cover_record, _save_image_file, _update_cover_record \
    , _get_image_display_order, _insert_image_record, _update_image_record, _update_image_order, _delete_image
from typing import Optional, Tuple, Dict, Any, List
from datetime import datetime
import os

router = APIRouter()
TABLE = "projects"
ALLOWED_EXT = {".jpg", ".jpeg", ".png", ".webp", ".gif"}

def insert_relationship(cur, Proj_ID: int, Text: str):
    #ล้างให้หมดก่อนจะสร้าง
    cur.execute(f"DELETE FROM proj_category_relationship WHERE Proj_ID = %s", (Proj_ID,))
    cur.execute(f"""SELECT max(Categories_Order) as max_order FROM proj_categories where Categories_Status = '1'""")
    row = cur.fetchone()
    max_order = row['max_order'] if row and row['max_order'] else 0
    
    if Text is not None:
        all_tag = [t.strip() for t in Text.split(";") if t.strip()]
        x = 1
        for i, tag in enumerate(all_tag):
            cur.execute(f"SELECT ID FROM proj_categories WHERE Category_Name = %s and Categories_Status = '1'", (tag,))
            row = cur.fetchone()
            if row is not None:
                tag_id = row['ID']
            else:
                cur.execute(f"INSERT INTO proj_categories (Category_Name, Categories_Order, Categories_Status) VALUES (%s, %s, %s)", (tag, int(max_order) + x), '1')
                tag_id = cur.lastrowid
                x += 1
            cur.execute(f"""INSERT INTO proj_category_relationship (Proj_ID, Category_ID, Relationship_Order, Relationship_Status) VALUES (%s, %s, %s, %s)"""
                        , (Proj_ID, tag_id, i+1, '1'))

# ----------------------------------------------------- INSERT --------------------------------------------------------------------------------------------
@router.post("/insert", status_code=201)
def insert_projs(
    response: Response,
    Name_EN: str = Form(...),
    Name_TH: str = Form(None),
    Latitude: str = Form(None),
    Longitude: str = Form(None),
    Proj_Address: str = Form(None),
    Proj_Yarn: str = Form(None),
    Proj_Sub_District: str = Form(None),
    Proj_District: str = Form(None),
    Proj_Province: str = Form(None),
    Proj_State: str = Form(None),
    Proj_Country: str = Form(None),
    Start_Date: str = Form(None),
    Finish_Date: str = Form(None),
    Renovated_Date: str = Form(None),
    Land_Rai: str = Form(None),
    Land_Ngan: str = Form(None),
    Land_Wa: str = Form(None),
    Usable_Area: str = Form(None),
    Commercial_Area: str = Form(None),
    Brief_Description: str = Form(None),
    Proj_Status: str = Form('0'),
    Created_By: int = Form(...),
    Last_Updated_By: int = Form(...),
    Category_Text: str = Form(None),
    _ = Depends(get_current_user),
):
    try:
        Name_TH = None if not Name_TH else Name_TH
        Latitude = None if not Latitude else float(Latitude)
        Longitude = None if not Longitude else float(Longitude)
        Proj_Address = None if not Proj_Address else Proj_Address
        Proj_Yarn = None if not Proj_Yarn else Proj_Yarn
        Proj_Sub_District = None if not Proj_Sub_District else Proj_Sub_District
        Proj_District = None if not Proj_District else Proj_District
        Proj_Province = None if not Proj_Province else Proj_Province
        Proj_State = None if not Proj_State else Proj_State
        Proj_Country = None if not Proj_Country else Proj_Country
        Start_Date = None if not Start_Date else datetime.strptime(Start_Date, "%Y-%m-%d")
        Finish_Date = None if not Finish_Date else datetime.strptime(Finish_Date, "%Y-%m-%d")
        Renovated_Date = None if not Renovated_Date else datetime.strptime(Renovated_Date, "%Y-%m-%d")
        Land_Rai = None if not Land_Rai else float(Land_Rai)
        Land_Ngan = None if not Land_Ngan else float(Land_Ngan)
        Land_Wa = None if not Land_Wa else float(Land_Wa)
        Usable_Area = None if not Usable_Area else float(Usable_Area)
        Commercial_Area = None if not Commercial_Area else float(Commercial_Area)
        Brief_Description = None if not Brief_Description else Brief_Description
        Proj_Status = Proj_Status if Proj_Status else '0'
        
        land_total = None
        if Land_Rai != None or Land_Ngan != None or Land_Wa != None:
            if Land_Rai == None:
                Land_Rai = 0
            if Land_Ngan == None:
                Land_Ngan = 0
            if Land_Wa == None:
                Land_Wa = 0
            land_total = Land_Rai + (Land_Ngan / 4) + (Land_Wa / 400)
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")
    
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        location_id_list = [None, None, None, None, None]
        location_type_list = ['Yarn', 'Subdistrict', 'District', 'Province', 'State']
        location_list = [Proj_Yarn, Proj_Sub_District, Proj_District, Proj_Province, Proj_State]
        for i, location in enumerate(location_list):
            location_id = check_location(cur, location, location_type_list[i])
            location_id_list[i] = location_id
        if Proj_Country:
            country_id = check_country(cur, Proj_Country)
        else:
            country_id = None

        sql = f"""
            INSERT INTO {TABLE}
            (Name_EN, Name_TH, Latitude, Longitude, Proj_Address, Proj_Yarn, Proj_Sub_District, Proj_District, Proj_Province, Proj_State
            , Proj_Country, Start_Date, Finish_Date, Renovated_Date, Land_Rai, Land_Ngan, Land_Wa, Land_Total, Usable_Area, Commercial_Area
            , Brief_Description, Proj_Status, Created_By, Last_Updated_By)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (
            Name_EN, Name_TH, Latitude, Longitude, Proj_Address, location_id_list[0], location_id_list[1], location_id_list[2], location_id_list[3], location_id_list[4]
            , country_id, Start_Date, Finish_Date, Renovated_Date, Land_Rai, Land_Ngan, Land_Wa, land_total, Usable_Area, Commercial_Area
            , Brief_Description, Proj_Status, Created_By, Last_Updated_By
        ))
        new_id = cur.lastrowid
        
        insert_relationship(cur, new_id, Category_Text)
        
        url_work(cur, new_id, Name_EN, 'proj')
        
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Project failed: {e}")
    finally:
        cur.close()
        conn.close()
    
    data = []
    row_proj = _select_full_proj_item(new_id)
    data.append({"proj": row_proj})
    
    response.headers["Location"] = f"/proj/select-proj/{new_id}"
    return apply_etag_and_return(response, data)

@router.post("/insert-prof-relationship", status_code=201)
def insert_proj_prof_relationship(
    Proj_ID: int = Form(...),
    prof_expertise_id: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        data_list = []
        expertise = prof_expertise_id.split(';')
        for expertise_id in expertise:
            cur.execute("""select Proj_ID, Prof_Expertise_Relationship_ID from proj_prof_relationship 
                        where Proj_ID = %s and Prof_Expertise_Relationship_ID = %s and Relationship_Status = '1'"""
                        , (Proj_ID, int(expertise_id)))
            check = cur.fetchall()
            if not check:
                cur.execute("INSERT INTO proj_prof_relationship (Proj_ID, Prof_Expertise_Relationship_ID, Relationship_Status) VALUES (%s, %s, %s)"
                            , (Proj_ID, int(expertise_id), '1'))
                data_list.append(expertise_id)
        conn.commit()
        
        return {"insert id": data_list}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Project Prof Relationship failed: {e}")
    finally:
        cur.close()
        conn.close()

@router.post("/delete-prof-relationship", status_code=204)  # รองรับ form
def delete_prof_relationship(
    relationship_id: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    
    delete_expertise_process(cur, [relationship_id], 'delete', 'proj')
    
    conn.commit()
    cur.close()
    conn.close()

@router.get("/select-prof-expertise/all", status_code=200)
def select_prof_expertise(
    _ = Depends(get_current_user),
):
    row = _select_prof_expertise()

    return row

#-----------------------------------------------------------UPDATE--------------------------------------------------------------
@router.post("/update", status_code=200)
def update_projects(
    response: Response,
    Proj_ID: int = Form(...),
    Name_EN: str = Form(...),
    Name_TH: str = Form(None),
    Latitude: str = Form(None),
    Longitude: str = Form(None),
    Proj_Address: str = Form(None),
    Proj_Yarn: str = Form(None),
    Proj_Sub_District: str = Form(None),
    Proj_District: str = Form(None),
    Proj_Province: str = Form(None),
    Proj_State: str = Form(None),
    Proj_Country: str = Form(None),
    Start_Date: str = Form(None),
    Finish_Date: str = Form(None),
    Renovated_Date: str = Form(None),
    Land_Rai: str = Form(None),
    Land_Ngan: str = Form(None),
    Land_Wa: str = Form(None),
    Usable_Area: str = Form(None),
    Commercial_Area: str = Form(None),
    Brief_Description: str = Form(None),
    Proj_Status: str = Form('0'),
    Last_Updated_By: int = Form(...),
    Category_Text: str = Form(None),
    if_match: Optional[str] = Header(None, alias="If-Match"),
    _ = Depends(get_current_user),
):
    try:
        Name_TH = None if not Name_TH else Name_TH
        Latitude = None if not Latitude else float(Latitude)
        Longitude = None if not Longitude else float(Longitude)
        Proj_Address = None if not Proj_Address else Proj_Address
        Proj_Yarn = None if not Proj_Yarn else Proj_Yarn
        Proj_Sub_District = None if not Proj_Sub_District else Proj_Sub_District
        Proj_District = None if not Proj_District else Proj_District
        Proj_Province = None if not Proj_Province else Proj_Province
        Proj_State = None if not Proj_State else Proj_State
        Proj_Country = None if not Proj_Country else Proj_Country
        Start_Date = None if not Start_Date else datetime.strptime(Start_Date, "%Y-%m-%d")
        Finish_Date = None if not Finish_Date else datetime.strptime(Finish_Date, "%Y-%m-%d")
        Renovated_Date = None if not Renovated_Date else datetime.strptime(Renovated_Date, "%Y-%m-%d")
        Land_Rai = None if not Land_Rai else float(Land_Rai)
        Land_Ngan = None if not Land_Ngan else float(Land_Ngan)
        Land_Wa = None if not Land_Wa else float(Land_Wa)
        Usable_Area = None if not Usable_Area else float(Usable_Area)
        Commercial_Area = None if not Commercial_Area else float(Commercial_Area)
        Brief_Description = None if not Brief_Description else Brief_Description
        Proj_Status = Proj_Status if Proj_Status else '0'
        
        land_total = None
        if Land_Rai != None or Land_Ngan != None or Land_Wa != None:
            if Land_Rai == None:
                Land_Rai = 0
            if Land_Ngan == None:
                Land_Ngan = 0
            if Land_Wa == None:
                Land_Wa = 0
            land_total = Land_Rai + (Land_Ngan / 4) + (Land_Wa / 400)
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")

    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        current = _select_full_proj_item(Proj_ID)
        if not current:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                detail=f"Proj '{Proj_ID}' was not found")

        if if_match and if_match != etag_of(current):
            raise HTTPException(status_code=status.HTTP_412_PRECONDITION_FAILED,
                            detail="ETag mismatch. Please GET latest and retry with If-Match.")
        
        if Proj_Status == '1':
            cur.execute(f"UPDATE proj_cover SET Image_Status='1' WHERE Proj_ID = %s and Image_Status = '2'", (Proj_ID,))
            cur.execute(f"UPDATE proj_category_relationship SET Relationship_Status = '1' WHERE Proj_ID=%s and Relationship_Status = '2'", (Proj_ID,))
            recover_proj_prof_relationship(cur, Proj_ID, 'proj')
        
        location_id_list = [None, None, None, None, None]
        location_type_list = ['Yarn', 'Subdistrict', 'District', 'Province', 'State']
        location_list = [Proj_Yarn, Proj_Sub_District, Proj_District, Proj_Province, Proj_State]
        for i, location in enumerate(location_list):
            location_id = check_location(cur, location, location_type_list[i])
            location_id_list[i] = location_id
        
        if Proj_Country:
            country_id = check_country(cur, Proj_Country)
        else:
            country_id = None
        
        insert_relationship(cur, Proj_ID, Category_Text)
        
        sql = f"""
            UPDATE {TABLE}
            SET Name_EN=%s,
                Name_TH=%s,
                Latitude=%s,
                Longitude=%s,
                Proj_Address=%s,
                Proj_Yarn=%s,
                Proj_Sub_District=%s,
                Proj_District=%s,
                Proj_Province=%s,
                Proj_State=%s,
                Proj_Country=%s,
                Start_Date=%s,
                Finish_Date=%s,
                Renovated_Date=%s,
                Land_Rai=%s,
                Land_Ngan=%s,
                Land_Wa=%s,
                Land_Total=%s,
                Usable_Area=%s,
                Commercial_Area=%s,
                Brief_Description=%s,
                Proj_Status=%s,
                Last_Updated_By=%s,
                Last_Updated_Date=CURRENT_TIMESTAMP
            WHERE ID=%s
        """
        cur.execute(sql, (Name_EN, Name_TH, Latitude, Longitude, Proj_Address, location_id_list[0], location_id_list[1], location_id_list[2], location_id_list[3], location_id_list[4]
            , country_id, Start_Date, Finish_Date, Renovated_Date, Land_Rai, Land_Ngan, Land_Wa, land_total, Usable_Area, Commercial_Area
            , Brief_Description, Proj_Status, Last_Updated_By, Proj_ID))
        
        url_work(cur, Proj_ID, Name_EN, 'proj')
        
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Update Project failed: {e}")
    finally:
        cur.close()
        conn.close()
    
    row = _select_full_proj_item(Proj_ID)
    return apply_etag_and_return(response, row)

# ----------------------------------------------------- DELETE --------------------------------------------------------------------------------------------
@router.post("/delete", status_code=204)  # รองรับ form
def delete_project(
    Proj_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    cur.execute(f"UPDATE {TABLE} SET Proj_Status='2' WHERE ID=%s", (Proj_ID,))
    affected = cur.rowcount
    
    #cover management
    cur.execute(f"update proj_cover set Image_Status = '2' WHERE Proj_ID=%s", (Proj_ID,))
    
    #category relationship management
    cur.execute(f"UPDATE proj_category_relationship SET Relationship_Status='2' WHERE Proj_ID=%s", (Proj_ID,))
    
    # prof relationship management (gallery inside)
    cur.execute(f"SELECT ID FROM proj_prof_relationship WHERE Proj_ID = %s", (Proj_ID,))
    rel_rows = cur.fetchall()
    rel_ids = [r['ID'] for r in rel_rows]
    if rel_ids:
        delete_expertise_process(cur, rel_ids, 'delete_proj', 'proj')
    
    conn.commit()
    cur.close()
    conn.close()

    if affected == 0:
        return to_problem(404, "Not Found", f"Proj '{Proj_ID}' was not found.")

# ====================== SELECT ALL ======================
@router.get("/select/all", status_code=200)
def select_all_project(
    _ = Depends(get_current_user),
):
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        base_sql = f"""
            SELECT
            *
            FROM {TABLE} 
            WHERE Proj_Status <> '2'
            ORDER BY ID
        """

        cur.execute(base_sql)
        rows = cur.fetchall()
        rows = [normalize_row(r) for r in rows]
        
        return rows
    finally:
        cur.close()
        conn.close()

# ====================== SELECT BY KEY ======================
@router.get("/select/{Proj_ID}", status_code=200)
def select_project_by_id(
    response: Response,
    Proj_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_full_proj_item(Proj_ID)
    require_row_exists(row, Proj_ID, 'Project')

    et = etag_of(row)
    # ถ้า client ส่ง If-None-Match มาและตรง → 304
    if if_none_match and if_none_match == et:
        response.headers["ETag"] = et
        response.status_code = status.HTTP_304_NOT_MODIFIED
        return

    return apply_etag_and_return(response, row)

# ----------------------------------------------------- LOCATION ----------------------------------------------------------------------------------------
@router.get("/select-location/{location_type}", status_code=200)
def select_location(
    response: Response,
    location_type: str,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_all_location(location_type)

    et = etag_of(row)
    # ถ้า client ส่ง If-None-Match มาและตรง → 304
    if if_none_match and if_none_match == et:
        response.headers["ETag"] = et
        response.status_code = status.HTTP_304_NOT_MODIFIED
        return

    return apply_etag_and_return(response, row)

@router.get("/select-country", status_code=200)
def select_country(
    response: Response,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_country()

    et = etag_of(row)
    # ถ้า client ส่ง If-None-Match มาและตรง → 304
    if if_none_match and if_none_match == et:
        response.headers["ETag"] = et
        response.status_code = status.HTTP_304_NOT_MODIFIED
        return

    return apply_etag_and_return(response, row)

# ----------------------------------------------------- categories ----------------------------------------------------------------------------------------
@router.get("/select-categories", status_code=200)
def select_categories(
    response: Response,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_category("proj")

    et = etag_of(row)
    # ถ้า client ส่ง If-None-Match มาและตรง → 304
    if if_none_match and if_none_match == et:
        response.headers["ETag"] = et
        response.status_code = status.HTTP_304_NOT_MODIFIED
        return

    return apply_etag_and_return(response, row)

# ============ upload cover + บันทึก DB ============
@router.post("/cover/record", status_code=201)
async def upload_and_record_cover(
    file: UploadFile = File(...),
    Proj_ID: int = Form(...),
    Cover_Ratio: str = Form(...),
    Image_Status: str = Form("1"),
    _ = Depends(get_current_user),
):
    if not file:
        raise HTTPException(status_code=400, detail="No files")
    
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        results = []
        if Cover_Ratio == "16:9":
            cover_size_list = [
                {"size": (1920, 1080), "ratio": "16:9"}
            ]
        elif Cover_Ratio == "9:16":
            cover_size_list = [
                {"size": (450, 800),  "ratio": "9:16"}
            ]
        elif Cover_Ratio == "3:2":
            cover_size_list = [
                {"size": (450, 300),  "ratio": "3:2"}
            ]
        name = file.filename or "unnamed"
        ext = os.path.splitext(name)[1].lower()
        file_bytes = await file.read()
        if ext not in ALLOWED_EXT:
            raise HTTPException(status_code=400, detail=f"File type not allowed: {ext}")
        for cover_size in cover_size_list:
            size = cover_size["size"]
            ratio = cover_size["ratio"]
            record = _insert_cover_record(cur,
                    ref_id=Proj_ID,
                    image_name = None,
                    image_url="",
                    ratio_type = ratio,
                    image_status=Image_Status,
                    state="proj")
        
            cover_id = record["ID"]
            meta = _save_image_file(file_bytes, cover_id, Proj_ID, "Cover", "proj", None, size, ratio)
            _update_cover_record(cur, cover_id=cover_id, cover_url=meta["url"], state="proj")
            record["Cover_Url"] = meta["url"]
        
            results.append({"file": meta, "record": record})
        conn.commit()

        return {"cover": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Proj_Cover failed: {e}")
    finally:
        cur.close()
        conn.close()

# ============ ลบ cover + ลบ DB ============
@router.post("/cover/delete/", status_code=204)
async def delete_cover_record(
    Proj_ID: int = Form(...),
    Cover_Ratio: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    try:
        _delete_cover(cur, Proj_ID, Cover_Ratio, "proj")
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Delete Proj_Cover failed: {e}")
    finally:
        cur.close()
        conn.close()

# ====================== SELECT BY KEY ======================
@router.get("/cover/select/{Proj_ID}", status_code=200)
def select_all_proj_cover(
    Proj_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    response: Response = Response(),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        proj = _select_full_proj_item(Proj_ID)
        require_row_exists(proj, Proj_ID, 'Proj')
        
        et = etag_of(proj)
        # ถ้า client ส่ง If-None-Match มาและตรง → 304
        if if_none_match and if_none_match == et:
            response.headers["ETag"] = et
            response.status_code = status.HTTP_304_NOT_MODIFIED
            return
        
        ratio_list = ["16:9","9:16","3:2"]
        list_169 = []
        list_916 = []
        list_32 = []
        for ratio in ratio_list:
            base_sql = """SELECT
                            ID,
                            Proj_ID,
                            Image_URL,
                            Ratio_Type
                        FROM proj_cover
                        WHERE Proj_ID = %s 
                        AND Image_Status = '1'
                        and Ratio_Type = %s
                        order by ID
                        limit 1"""
            
            cur.execute(base_sql, (Proj_ID, ratio))
            row = cur.fetchone()
            
            if ratio == "16:9":
                list_169 = row
            elif ratio == "9:16":
                list_916 = row
            elif ratio == "3:2":
                list_32 = row
        
        data = []
        data.append({"cover": {"16:9": list_169, "9:16": list_916, "3:2": list_32}})

        return {"data": data}
    
    finally:
        cur.close()
        conn.close()

# ============ อัปโหลดกี่ไฟล์ก็ได้ + บันทึก DB ============
@router.post("/images/record", status_code=201)
async def upload_and_record(
    files: List[UploadFile] = File(...),
    Proj_ID: int = Form(...),
    Relationship_ID: int = Form(...),
    Image_Status: str = Form("1"),
    Image_caption: str = Form(None),
    Image_Description: str = Form(None),
    _ = Depends(get_current_user),
):
    if not files:
        raise HTTPException(status_code=400, detail="No files")
    
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        results = []
        image_size_list = [(1440,810),(800,450),(400,225)]
        order = _get_image_display_order(cur, Relationship_ID, 'proj')
        Image_caption = None if not Image_caption else Image_caption
        images_name = Image_caption.split(";") if Image_caption else None
        Image_Description = None if not Image_Description else Image_Description
        imgs_des = Image_Description.split(";") if Image_Description else None
        for i, f in enumerate(files):
            name = f.filename or "unnamed"
            ext = os.path.splitext(name)[1].lower()
            image_name = images_name[i] if images_name else None
            img_des = imgs_des[i] if imgs_des else None
            if ext not in ALLOWED_EXT:
                raise HTTPException(status_code=400, detail=f"File type not allowed: {ext}")
            
            file_bytes = f.file.read()
            record = _insert_image_record(
                        cur = cur,
                        ref_id = Relationship_ID,
                        state = 'proj',
                        image_name=image_name,
                        image_url="",
                        display_order=order,
                        image_status=Image_Status,
                        image_description=img_des
                    )
            image_id = record["ID"]
            for image_size in image_size_list:
                meta = _save_image_file(file_bytes, image_id, Proj_ID, "Gallery", "proj", Relationship_ID, image_size, '16:9')
                if image_size[0] == 1440:
                    _update_image_record(
                        cur = cur,
                        image_id = image_id,
                        image_url = meta["url"],
                        state = 'proj'
                    )
                    record["Image_Url"] = meta["url"]
                
                results.append({"file": meta, "record": record})
            order += 1
        conn.commit()

        return {"count": len(results), "items": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Proj_Gallery failed: {e}")
    finally:
        cur.close()
        conn.close()

# ----------------------------------------------------- UPDATE Image Order --------------------------------------------------------------------------------------------
@router.post("/image/update/image_order", status_code=200)
def update_proj_image_order(
    Display_Order: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        order_list = Display_Order.split(",")
        results = []
        for i, order in enumerate(order_list):
            meta = _update_image_order(cur = cur, image_id=int(order), display_order=i+1, table_name="proj_gallery")
            results.append({"data": meta})
        conn.commit()

        return {"items": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Update Proj_Gallery Order failed: {e}")
    finally:
        cur.close()
        conn.close()

# ----------------------------------------------------- UPDATE Image Name --------------------------------------------------------------------------------------------
@router.post("/image/update/image_caption", status_code=200)
def update_proj_image_caption(
    Image_ID: int = Form(...),
    Image_Caption: str = Form(None),
    Image_Description: str = Form(None),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    update_query = "UPDATE proj_gallery SET Image_Name = %s, Image_Description = %s WHERE ID = %s"
    try:
        Image_Caption = None if not Image_Caption else Image_Caption
        Image_Description = None if not Image_Description else Image_Description
        cur.execute(update_query, (Image_Caption, Image_Description, Image_ID))
        conn.commit()
        return {"data": {"Image_ID": Image_ID, "Image_Name": Image_Caption}}
    except Exception as e:
        return to_problem(409, "Conflict", f"Update Proj_Gallery Caption failed: {e}")
    finally:
        cur.close()
        conn.close()

# ============ ลบ cover + ลบ DB ============
@router.post("/images/delete/", status_code=204)
async def delete_image_record(
    Image_ID: int = Form(...),
    Relationship_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    try:
        _delete_image(cur, Image_ID, "Delete_Image", Relationship_ID, "proj")
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Delete Proj_Gallery failed: {e}")
    finally:
        cur.close()
        conn.close()

# ====================== SELECT BY KEY ======================
@router.get("/images/select/{Relationship_ID}", status_code=200)
def select_all_prof_images(
    Relationship_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        base_sql = """SELECT
                        a.ID
                        , a.Proj_Profs_Relationship_ID
                        , a.Image_Name
                        , a.Image_URL
                        , a.Image_Order
                        , a.Image_Status
                    FROM proj_gallery a
                    WHERE a.Proj_Profs_Relationship_ID = %s and a.Image_Status = '1'
                    ORDER BY a.Image_Order"""
        
        data = []
        cur.execute(base_sql, (Relationship_ID,))
        rows = cur.fetchall()
        rows = [normalize_row(r) for r in rows]
        data.append({"list": rows})

        return {"data": data}
    finally:
        cur.close()
        conn.close()

@router.get("/select-prof-expertise/{Proj_ID}", status_code=200)
def select_prof_expertise(
    Proj_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        base_sql = """SELECT
                        a.ID
                        , d.Name_EN as Professional
                        , e.Responsibility as Expertise
                        , e.Expertise_Order
                        , c.Relationship_Order as Prof_Expertise_Order
                    from proj_prof_relationship a
                    join projects b on a.Proj_ID = b.ID
                    join prof_expertise_relationship c on a.Prof_Expertise_Relationship_ID = c.ID
                    join professionals d on c.Prof_ID = d.ID
                    join prof_expertise e on c.Expertise_ID = e.ID
                    where a.Proj_ID = %s
                    and b.Proj_Status = '1'
                    and a.Relationship_Status = '1'
                    and c.Relationship_Status = '1'
                    and d.Prof_Status = '1'
                    and e.Expertise_Status = '1'"""
        
        cur.execute(base_sql, (Proj_ID,))
        rows = cur.fetchall()

        return rows
    finally:
        cur.close()
        conn.close()

@router.post("/save-content", status_code=201)
def save_content(
    Relationship_ID: int = Form(...),
    Content_Text: str = Form(None),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        Content_Text = None if not Content_Text else Content_Text
        
        cur.execute("update proj_prof_relationship set Content = %s where ID = %s", (Content_Text, Relationship_ID))
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Content failed: {e}")
    finally:
        cur.close()
        conn.close()

@router.get("/select-content/{Relationship_ID}", status_code=200)
def select_content(
    Relationship_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute("select Content from proj_prof_relationship where ID = %s", (Relationship_ID,))
        row = cur.fetchone()
        
        return row
    finally:
        cur.close()
        conn.close()
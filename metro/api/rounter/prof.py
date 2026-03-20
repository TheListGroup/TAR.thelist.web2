from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists, normalize_row
from function_query_helper import check_location, check_country, _select_full_prof_item, _select_proj_prof_relationship, insert_relationship, update_relationship, url_work \
                                , update_owners, _delete_cover, delete_expertise_process, _select_all_location, _select_country, _select_expertise, _select_category \
                                , _insert_cover_record, _save_image_file, _update_cover_record, _get_image_display_order, _insert_image_record, _update_image_record \
                                , _update_image_order, _delete_image, recover_proj_prof_relationship
from typing import Optional, Tuple, Dict, Any, List
import os
from datetime import datetime

router = APIRouter()
TABLE = "professionals"
ALLOWED_EXT = {".jpg", ".jpeg", ".png", ".webp", ".gif", ".jfif"}

@router.post("/test", status_code=201)
def test(
    user_id: int = Form(...),
    _ = Depends(get_current_user),
):
    return "OK"

# ----------------------------------------------------- INSERT --------------------------------------------------------------------------------------------
@router.post("/insert", status_code=201)
def insert_professionals(
    response: Response,
    Name_EN: str = Form(...),
    Name_TH: str = Form(None),
    Latitude: str = Form(None),
    Longitude: str = Form(None),
    Prof_Address: str = Form(None),
    Prof_Yarn: str = Form(None),
    Prof_Sub_District: str = Form(None),
    Prof_District: str = Form(None),
    Prof_Province: str = Form(None),
    Prof_State: str = Form(None),
    Prof_Country: str = Form(None),
    FB_Link: str = Form(None),
    IG_Link: str = Form(None),
    Line_Link: str = Form(None),
    YT_Link: str = Form(None),
    Website: str = Form(None),
    Found_Date: str = Form(None),
    Is_Freelance: str = Form(None),
    Brief_Description: str = Form(None),
    Content: str = Form(None),
    Experience_Text: str = Form(None),
    Expertise_Text: str = Form(None),
    Owner_Text: str = Form(None),
    Prof_Status: str = Form('0'),
    Created_By: int = Form(...),
    Last_Updated_By: int = Form(...),
    _ = Depends(get_current_user),
):
    try:
        Name_TH = None if not Name_TH else Name_TH
        Latitude = None if not Latitude else float(Latitude)
        Longitude = None if not Longitude else float(Longitude)
        Prof_Address = None if not Prof_Address else Prof_Address
        Prof_Yarn = None if not Prof_Yarn else Prof_Yarn
        Prof_Sub_District = None if not Prof_Sub_District else Prof_Sub_District
        Prof_District = None if not Prof_District else Prof_District
        Prof_Province = None if not Prof_Province else Prof_Province
        Prof_State = None if not Prof_State else Prof_State
        Prof_Country = None if not Prof_Country else Prof_Country
        FB_Link = None if not FB_Link else FB_Link
        IG_Link = None if not IG_Link else IG_Link
        Line_Link = None if not Line_Link else Line_Link
        YT_Link = None if not YT_Link else YT_Link
        Website = None if not Website else Website
        Found_Date = None if not Found_Date else datetime.strptime(Found_Date, "%Y-%m-%d")
        Is_Freelance = 0 if not Is_Freelance else 1
        Brief_Description = None if not Brief_Description else Brief_Description
        Content = None if not Content else Content
        Prof_Status = Prof_Status if Prof_Status else '0'
        Owner_Text = None if not Owner_Text else Owner_Text
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")
    
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        location_id_list = [None, None, None, None, None]
        location_type_list = ['Yarn', 'Subdistrict', 'District', 'Province', 'State']
        location_list = [Prof_Yarn, Prof_Sub_District, Prof_District, Prof_Province, Prof_State]
        for i, location in enumerate(location_list):
            location_id = check_location(cur, location, location_type_list[i])
            location_id_list[i] = location_id
        if Prof_Country:
            country_id = check_country(cur, Prof_Country)
        else:
            country_id = None

        sql = f"""
            INSERT INTO {TABLE}
            (Name_EN, Name_TH, Latitude, Longitude, Prof_Address, Prof_Yarn, Prof_Sub_District, Prof_District, Prof_Province, Prof_State
            , Prof_Country, FB_Link, IG_Link, Line_Link, YT_Link, Website, Found_Date, Is_Freelance, Brief_Description
            , Content, Prof_Status, Created_By, Last_Updated_By)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (
            Name_EN, Name_TH, Latitude, Longitude, Prof_Address, location_id_list[0], location_id_list[1], location_id_list[2], location_id_list[3], location_id_list[4]
            , country_id, FB_Link, IG_Link, Line_Link, YT_Link, Website, Found_Date, Is_Freelance, Brief_Description
            , Content, Prof_Status, Created_By, Last_Updated_By
        ))
        new_id = cur.lastrowid
        
        text_list = [(Experience_Text,"exp"), (Expertise_Text,"ext")]
        for text in text_list:
            insert_relationship(cur, new_id, text[0], text[1])
        
        if Owner_Text is not None:
            owner = Owner_Text.split(';')
            for person in owner:
                data = [d.strip() if d.strip().lower() != 'none' else None for d in person.split(',')]
                cur.execute("INSERT INTO prof_owners (Prof_ID, First_Name_EN, Last_Name_EN, First_Name_TH, Last_Name_TH, Owner_Status) VALUES (%s, %s, %s, %s, %s, %s)"
                            , (new_id, data[0], data[1], data[2], data[3], '1'))
        url_work(cur, new_id, Name_EN, 'prof')
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Professional failed: {e}")
    finally:
        cur.close()
        conn.close()
    
    data = []
    row_prof = _select_full_prof_item(new_id)
    data.append({"prof": row_prof})
    
    response.headers["Location"] = f"/prof/select-prof/{new_id}"
    return apply_etag_and_return(response, data)

@router.post("/insert-member", status_code=201)
def insert_member(
    Proj_Profs_Relationship_ID: int = Form(...),
    Member_Text: str = Form(...),
    User_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        data_list = []
        member = Member_Text.split(';')
        for person in member:
            data = person.split(',')
            cur.execute("""INSERT INTO prof_employees (Proj_Profs_Relationship_ID, First_Name_EN, Last_Name_EN, Position_EN
                        , First_Name_TH, Last_Name_TH, Position_TH, Created_By, Last_Updated_By, Member_Status) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
                        , (Proj_Profs_Relationship_ID, data[0], data[1], data[2], data[3], data[4], data[5], User_ID, User_ID, '1'))
            data_list.append({"First_Name_EN": data[0], "Last_Name_EN": data[1], "Position_EN": data[2], "First_Name_TH": data[3], "Last_Name_TH": data[4]
                            , "Position_TH": data[5]})
        conn.commit()
        
        return {"data": data_list}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Prof Member failed: {e}")
    finally:
        cur.close()
        conn.close()

@router.get("/select-proj-prof-relationship/{Prof_ID}", status_code=200)
def select_proj_prof_relationship(
    Prof_ID: int,
    _ = Depends(get_current_user),
):
    row = _select_proj_prof_relationship(Prof_ID)

    return row

#-----------------------------------------------------------UPDATE--------------------------------------------------------------
@router.post("/update", status_code=201)
def update_professionals(
    response: Response,
    Prof_ID: int = Form(...),
    Name_EN: str = Form(...),
    Name_TH: str = Form(None),
    Latitude: str = Form(None),
    Longitude: str = Form(None),
    Prof_Address: str = Form(None),
    Prof_Yarn: str = Form(None),
    Prof_Sub_District: str = Form(None),
    Prof_District: str = Form(None),
    Prof_Province: str = Form(None),
    Prof_State: str = Form(None),
    Prof_Country: str = Form(None),
    FB_Link: str = Form(None),
    IG_Link: str = Form(None),
    Line_Link: str = Form(None),
    YT_Link: str = Form(None),
    Website: str = Form(None),
    Found_Date: str = Form(None),
    Is_Freelance: str = Form(None),
    Brief_Description: str = Form(None),
    Content: str = Form(None),
    Experience_Text: str = Form(None),
    Expertise_Text: str = Form(None),
    Owner_Text: str = Form(None),
    Prof_Status: str = Form('0'),
    Last_Updated_By: int = Form(...),
    if_match: Optional[str] = Header(None, alias="If-Match"),
    _ = Depends(get_current_user),
):
    try:
        Name_TH = None if not Name_TH else Name_TH
        Latitude = None if not Latitude else float(Latitude)
        Longitude = None if not Longitude else float(Longitude)
        Prof_Address = None if not Prof_Address else Prof_Address
        Prof_Yarn = None if not Prof_Yarn else Prof_Yarn
        Prof_Sub_District = None if not Prof_Sub_District else Prof_Sub_District
        Prof_District = None if not Prof_District else Prof_District
        Prof_Province = None if not Prof_Province else Prof_Province
        Prof_State = None if not Prof_State else Prof_State
        Prof_Country = None if not Prof_Country else Prof_Country
        FB_Link = None if not FB_Link else FB_Link
        IG_Link = None if not IG_Link else IG_Link
        Line_Link = None if not Line_Link else Line_Link
        YT_Link = None if not YT_Link else YT_Link
        Website = None if not Website else Website
        Found_Date = None if not Found_Date else datetime.strptime(Found_Date, "%Y-%m-%d")
        Is_Freelance = 0 if not Is_Freelance else 1
        Brief_Description = None if not Brief_Description else Brief_Description
        Content = None if not Content else Content
        Prof_Status = Prof_Status if Prof_Status else '0'
        Owner_Text = None if not Owner_Text else Owner_Text
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")

    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        current = _select_full_prof_item(Prof_ID)
        if not current:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                detail=f"Prof '{Prof_ID}' was not found")

        if if_match and if_match != etag_of(current):
            raise HTTPException(status_code=status.HTTP_412_PRECONDITION_FAILED,
                            detail="ETag mismatch. Please GET latest and retry with If-Match.")
        
        if Prof_Status == '1':
            cur.execute(f"UPDATE prof_owners SET Owner_Status='1' WHERE Prof_ID=%s and Owner_Status = '2'", (Prof_ID,))
            cur.execute(f"UPDATE prof_cover SET Image_Status='1' WHERE Prof_ID=%s and Image_Status = '2'", (Prof_ID,))
            cur.execute(f"UPDATE prof_experience_relationship SET Proj_Category_Status='1' WHERE Prof_ID=%s and Proj_Category_Status = '2'", (Prof_ID,))
            cur.execute(f"UPDATE prof_expertise_relationship SET Relationship_Status='1' WHERE Prof_ID=%s and Relationship_Status = '2'", (Prof_ID,))
            cur.execute(f"UPDATE prof_gallery SET Image_Status ='1' WHERE Prof_ID = %s and Image_Status = '2'", (Prof_ID,))
            recover_proj_prof_relationship(cur, Prof_ID, 'prof')
        
        location_id_list = [None, None, None, None, None]
        location_type_list = ['Yarn', 'Subdistrict', 'District', 'Province', 'State']
        location_list = [Prof_Yarn, Prof_Sub_District, Prof_District, Prof_Province, Prof_State]
        for i, location in enumerate(location_list):
            location_id = check_location(cur, location, location_type_list[i])
            location_id_list[i] = location_id
        if Prof_Country:
            country_id = check_country(cur, Prof_Country)
        else:
            country_id = None
        
        text_list = [(Experience_Text,"exp"), (Expertise_Text,"ext")]
        for text in text_list:
            update_relationship(cur, Prof_ID, text[0], text[1], 'delete', 'prof')
        
        update_owners(cur, Prof_ID, Owner_Text, 'delete')
        
        sql = f"""
            UPDATE {TABLE}
            SET Name_EN=%s,
                Name_TH=%s,
                Latitude=%s,
                Longitude=%s,
                Prof_Address=%s,
                Prof_Yarn=%s,
                Prof_Sub_District=%s,
                Prof_District=%s,
                Prof_Province=%s,
                Prof_State=%s,
                Prof_Country=%s,
                FB_Link=%s,
                IG_Link=%s,
                Line_Link=%s,
                YT_Link=%s,
                Website=%s,
                Found_Date=%s,
                Is_Freelance=%s,
                Brief_Description=%s,
                Content=%s,
                Prof_Status=%s,
                Last_Updated_By=%s,
                Last_Updated_Date=CURRENT_TIMESTAMP
            WHERE ID=%s
        """
        cur.execute(sql, (Name_EN, Name_TH, Latitude, Longitude, Prof_Address, location_id_list[0], location_id_list[1], location_id_list[2], location_id_list[3], location_id_list[4]
            , country_id, FB_Link, IG_Link, Line_Link, YT_Link, Website, Found_Date, Is_Freelance, Brief_Description
            , Content, Prof_Status, Last_Updated_By, Prof_ID))
        
        url_work(cur, Prof_ID, Name_EN, 'prof')
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Update Professional failed: {e}")
    finally:
        cur.close()
        conn.close()
    
    row = _select_full_prof_item(Prof_ID)
    return apply_etag_and_return(response, row)

# ====================== SELECT ALL ======================
@router.get("/select/all", status_code=200)
def select_all_professional(
    _ = Depends(get_current_user),
):
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        base_sql = f"""
            SELECT
            *
            FROM {TABLE} 
            WHERE Prof_Status <> '2'
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
@router.get("/select/{Prof_ID}", status_code=200)
def select_professionals_by_id(
    response: Response,
    Prof_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_full_prof_item(Prof_ID)
    require_row_exists(row, Prof_ID, 'Professional')

    et = etag_of(row)
    # ถ้า client ส่ง If-None-Match มาและตรง → 304
    if if_none_match and if_none_match == et:
        response.headers["ETag"] = et
        response.status_code = status.HTTP_304_NOT_MODIFIED
        return

    return apply_etag_and_return(response, row)

# ----------------------------------------------------- DELETE --------------------------------------------------------------------------------------------
@router.post("/delete", status_code=204)  # รองรับ form
def delete_professionals(
    Prof_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    cur.execute(f"UPDATE {TABLE} SET Prof_Status='2' WHERE ID=%s", (Prof_ID,))
    affected = cur.rowcount
    
    #owner management
    cur.execute(f"UPDATE prof_owners SET Owner_Status='2' WHERE Prof_ID=%s", (Prof_ID,))
    
    #cover management
    cur.execute(f"update prof_cover set Image_Status = '2' WHERE Prof_ID=%s", (Prof_ID,))
    
    #gallery management
    cur.execute(f"UPDATE prof_gallery SET Image_Status = '2' WHERE Prof_ID = %s", (Prof_ID,))
    
    #experience management
    cur.execute(f"UPDATE prof_experience_relationship SET Proj_Category_Status='2' WHERE Prof_ID=%s", (Prof_ID,))
    
    #expertise management
    cur.execute(f"UPDATE prof_expertise_relationship SET Relationship_Status='2' WHERE Prof_ID=%s", (Prof_ID,))
    
    # proj relationship management
    cur.execute(f"SELECT ID FROM prof_expertise_relationship WHERE Prof_ID = %s", (Prof_ID,))
    rel_rows = cur.fetchall()
    rel_ids = [r['ID'] for r in rel_rows]
    if rel_ids:
        delete_expertise_process(cur, rel_ids, 'delete_prof', 'prof')
    
    conn.commit()
    cur.close()
    conn.close()

    if affected == 0:
        return to_problem(404, "Not Found", f"Prof '{Prof_ID}' was not found.")

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

# ----------------------------------------------------- expertise ----------------------------------------------------------------------------------------
@router.get("/select-expertise", status_code=200)
def select_expertise(
    response: Response,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_expertise()

    et = etag_of(row)
    # ถ้า client ส่ง If-None-Match มาและตรง → 304
    if if_none_match and if_none_match == et:
        response.headers["ETag"] = et
        response.status_code = status.HTTP_304_NOT_MODIFIED
        return

    return apply_etag_and_return(response, row)

# ----------------------------------------------------- experience ----------------------------------------------------------------------------------------
@router.get("/select-experience", status_code=200)
def select_experience(
    response: Response,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_category("prof")

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
    Prof_ID: int = Form(...),
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
                {"size": (1920, 1080), "ratio": "16:9"},
                {"size": (420, 236), "ratio": "16:9"}
            ]
        elif Cover_Ratio == "9:16":
            cover_size_list = [
                {"size": (450, 800),  "ratio": "9:16"}
            ]
        name = file.filename or "unnamed"
        ext = os.path.splitext(name)[1].lower()
        file_bytes = await file.read()
        if ext not in ALLOWED_EXT:
            raise HTTPException(status_code=400, detail=f"File type not allowed: {ext}")
        for cover_size in cover_size_list:
            size = cover_size["size"]
            ratio = str(cover_size["ratio"])
            record = _insert_cover_record(cur,
                    ref_id=Prof_ID,
                    image_name = None,
                    image_url="",
                    ratio_type = ratio,
                    image_status=Image_Status,
                    state="prof")
        
            cover_id = record["ID"]
            meta = _save_image_file(file_bytes, cover_id, Prof_ID, "Cover", "prof", None, size, ratio)
            _update_cover_record(cur, cover_id=cover_id, cover_url=meta["url"], state="prof")
            record["Cover_Url"] = meta["url"]
        
            results.append({"file": meta, "record": record})
        conn.commit()

        return {"cover": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Prof_Cover failed: {e}")
    finally:
        cur.close()
        conn.close()

# ============ ลบ cover + ลบ DB ============
@router.post("/cover/delete/", status_code=204)
async def delete_cover_record(
    Prof_ID: int = Form(...),
    Cover_Ratio: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    try:
        _delete_cover(cur, Prof_ID, Cover_Ratio, "prof")
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Delete Prof_Cover failed: {e}")
    finally:
        cur.close()
        conn.close()

# ====================== SELECT BY KEY ======================
@router.get("/cover/select/{Prof_ID}", status_code=200)
def select_all_prof_cover(
    Prof_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    response: Response = Response(),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        prof = _select_full_prof_item(Prof_ID)
        require_row_exists(prof, Prof_ID, 'Prof')
        
        et = etag_of(prof)
        # ถ้า client ส่ง If-None-Match มาและตรง → 304
        if if_none_match and if_none_match == et:
            response.headers["ETag"] = et
            response.status_code = status.HTTP_304_NOT_MODIFIED
            return
        
        ratio_list = ["16:9","9:16"]
        list_169 = []
        list_916 = []
        for ratio in ratio_list:
            base_sql = """SELECT
                            ID,
                            Prof_ID,
                            Image_URL,
                            Ratio_Type
                        FROM prof_cover
                        WHERE Prof_ID = %s 
                        AND Image_Status = '1'
                        and Ratio_Type = %s
                        order by ID
                        limit 1"""
            
            cur.execute(base_sql, (Prof_ID, ratio))
            row = cur.fetchone()
            
            if ratio == "16:9":
                list_169 = row
            elif ratio == "9:16":
                list_916 = row
        
        data = []
        data.append({"cover": {"16:9": list_169, "9:16": list_916}})

        return {"data": data}
    
    finally:
        cur.close()
        conn.close()

# ============ อัปโหลดกี่ไฟล์ก็ได้ + บันทึก DB ============
@router.post("/images/record", status_code=201)
async def upload_and_record(
    files: List[UploadFile] = File(...),
    Prof_ID: int = Form(...),
    Image_Status: str = Form("0"),
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
        order = _get_image_display_order(cur, Prof_ID, 'prof')
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
                        ref_id = Prof_ID,
                        state = 'prof',
                        image_name=image_name,
                        image_url="",
                        display_order=order,
                        image_status=Image_Status,
                        image_description=img_des
                    )
            image_id = record["ID"]
            for image_size in image_size_list:
                meta = _save_image_file(file_bytes, image_id, Prof_ID, "Gallery", "prof", None, image_size, '16:9')
                if image_size[0] == 1440:
                    _update_image_record(
                        cur = cur,
                        image_id = image_id,
                        image_url = meta["url"],
                        state = 'prof'
                    )
                    record["Image_Url"] = meta["url"]
                
                results.append({"file": meta, "record": record})
            order += 1
        conn.commit()

        return {"count": len(results), "items": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Prof_Gallery failed: {e}")
    finally:
        cur.close()
        conn.close()

# ----------------------------------------------------- UPDATE Image Order --------------------------------------------------------------------------------------------
@router.post("/image/update/image_order", status_code=200)
def update_prof_image_order(
    Display_Order: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        order_list = Display_Order.split(",")
        results = []
        for i, order in enumerate(order_list):
            meta = _update_image_order(cur = cur, image_id=int(order), display_order=i+1, table_name="prof_gallery")
            results.append({"data": meta})
        conn.commit()

        return {"items": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Update Prof_Gallery Order failed: {e}")
    finally:
        cur.close()
        conn.close()

# ----------------------------------------------------- UPDATE Image Name --------------------------------------------------------------------------------------------
@router.post("/image/update/image_caption", status_code=200)
def update_prof_image_caption(
    Image_ID: int = Form(...),
    Image_Caption: str = Form(None),
    Image_Description: str = Form(None),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    update_query = "UPDATE prof_gallery SET Image_Name = %s, Image_Description = %s WHERE ID = %s"
    try:
        Image_Caption = None if not Image_Caption else Image_Caption
        Image_Description = None if not Image_Description else Image_Description
        cur.execute(update_query, (Image_Caption, Image_Description, Image_ID))
        conn.commit()
        return {"data": {"Image_ID": Image_ID, "Image_Name": Image_Caption}}
    except Exception as e:
        return to_problem(409, "Conflict", f"Update Prof_Gallery Caption failed: {e}")
    finally:
        cur.close()
        conn.close()

# ============ ลบ cover + ลบ DB ============
@router.post("/images/delete/", status_code=204)
async def delete_image_record(
    Image_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    try:
        _delete_image(cur, Image_ID, "Delete_Image", None, "prof")
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Delete Prof_Gallery failed: {e}")
    finally:
        cur.close()
        conn.close()

# ====================== SELECT BY KEY ======================
@router.get("/images/select/{Prof_ID}", status_code=200)
def select_all_prof_images(
    Prof_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    response: Response = Response(),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        prof = _select_full_prof_item(Prof_ID)
        require_row_exists(prof, Prof_ID, 'Prof')
        
        et = etag_of(prof)
        # ถ้า client ส่ง If-None-Match มาและตรง → 304
        if if_none_match and if_none_match == et:
            response.headers["ETag"] = et
            response.status_code = status.HTTP_304_NOT_MODIFIED
            return
        
        base_sql = """SELECT
                        a.ID
                        , a.Prof_ID
                        , a.Image_Name
                        , a.Image_URL
                        , a.Image_Order
                        , a.Image_Status
                    FROM prof_gallery a
                    WHERE a.Prof_ID = %s and a.Image_Status = '1'
                    ORDER BY a.Image_Order"""
        
        data = []
        cur.execute(base_sql, (Prof_ID,))
        rows = cur.fetchall()
        rows = [normalize_row(r) for r in rows]
        data.append({"list": rows})

        return {"data": data}
    
    finally:
        cur.close()
        conn.close()

# ====================== SELECT Member All ======================
@router.get("/select-member/all/{Prof_ID}", status_code=200)
def select_all_member(
    Prof_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute("""SELECT a.ID, a.First_Name_EN, a.Last_Name_EN, a.Position_EN, e.Name_EN as Project_Name
                    FROM prof_employees a
                    join proj_prof_relationship b on a.Proj_Profs_Relationship_ID = b.ID and b.Relationship_Status = '1'
                    join prof_expertise_relationship c on b.Prof_Expertise_Relationship_ID = c.ID and c.Relationship_Status = '1'
                    join professionals d on c.Prof_ID = d.ID and d.Prof_Status = '1'
                    join projects e on b.Proj_ID = e.ID and e.Proj_Status = '1'
                    WHERE d.ID = %s
                    and a.Member_Status = '1'
                    ORDER BY a.ID""", (Prof_ID,))
        rows = cur.fetchall()
        rows = [normalize_row(r) for r in rows]
        return {"data": rows}
    
    finally:
        cur.close()
        conn.close()

# ====================== SELECT Member BY KEY ======================
@router.get("/select-member/{Mem_ID}", status_code=200)
def select_member(
    Mem_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute("""SELECT * FROM prof_employees a WHERE a.ID = %s""", (Mem_ID,))
        row = cur.fetchone()
        row = normalize_row(row)
        return {"data": row}
    
    finally:
        cur.close()
        conn.close()

# ----------------------------------------------------- UPDATE Member --------------------------------------------------------------------------------------------
@router.post("/update-member", status_code=200)
def update_prof_member(
    Proj_Profs_Relationship_ID: int = Form(...),
    Mem_ID: int = Form(...),
    First_Name_EN: str = Form(...),
    Last_Name_EN: str = Form(None),
    Position_EN: str = Form(None),
    First_Name_TH: str = Form(None),
    Last_Name_TH: str = Form(None),
    Position_TH: str = Form(None),
    Member_Status: str = Form('1'),
    User_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    update_query = """UPDATE prof_employees SET Proj_Profs_Relationship_ID = %s, First_Name_EN = %s, Last_Name_EN = %s, Position_EN = %s, First_Name_TH = %s
                    , Last_Name_TH = %s, Position_TH = %s, Member_Status = %s, Last_Updated_By = %s, Last_Updated_Date = CURRENT_TIMESTAMP WHERE ID = %s"""
    try:
        Last_Name_EN = None if not Last_Name_EN else Last_Name_EN 
        Position_EN = None if not Position_EN else Position_EN 
        First_Name_TH = None if not First_Name_TH else First_Name_TH 
        Last_Name_TH = None if not Last_Name_TH else Last_Name_TH 
        Position_TH = None if not Position_TH else Position_TH 
        cur.execute(update_query, (Proj_Profs_Relationship_ID, First_Name_EN, Last_Name_EN, Position_EN, First_Name_TH, Last_Name_TH, Position_TH, Member_Status, User_ID, Mem_ID))
        conn.commit()
        return {"data": {"Proj_Profs_Relationship_ID": Proj_Profs_Relationship_ID, "Member_ID": Mem_ID, "First_Name_EN": First_Name_EN, "Last_Name_EN": Last_Name_EN
                        , "Position_EN": Position_EN, "First_Name_TH": First_Name_TH, "Last_Name_TH": Last_Name_TH, "Position_TH": Position_TH, "Member_Status": Member_Status}}
    except Exception as e:
        return to_problem(409, "Conflict", f"Update Member failed: {e}")
    finally:
        cur.close()
        conn.close()

# ============ Delete Member ============
@router.post("/delete-member", status_code=204)
async def delete_image_record(
    Mem_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""DELETE FROM prof_employees WHERE ID = %s""", (Mem_ID,))
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Delete Member failed: {e}")
    finally:
        cur.close()
        conn.close()

# ============ upload logo + บันทึก DB ============
@router.post("/logo/record", status_code=201)
async def upload_and_record_logo(
    file: UploadFile = File(...),
    Prof_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    if not file:
        raise HTTPException(status_code=400, detail="No files")
    
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        results = []
        name = file.filename or "unnamed"
        ext = os.path.splitext(name)[1].lower()
        file_bytes = await file.read()
        if ext not in ALLOWED_EXT:
            raise HTTPException(status_code=400, detail=f"File type not allowed: {ext}")
        size = (180, 180)
        meta = _save_image_file(file_bytes, None, Prof_ID, "Logo", "prof", None, size, None)
        
        cur.execute(f"""UPDATE professionals SET Logo_URL = %s WHERE ID = %s""", (meta["url"], Prof_ID))
    
        results.append({"file": meta})
        conn.commit()

        return {"logo": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Prof_Logo failed: {e}")
    finally:
        cur.close()
        conn.close()

# ============ ลบ logo + ลบ DB ============
@router.post("/logo/delete/", status_code=204)
async def delete_logo_record(
    Prof_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute(f"""select Logo_URL from professionals WHERE ID = %s""", (Prof_ID,))
        logo = cur.fetchone()
        
        cur.execute(f"""UPDATE professionals SET Logo_URL = null WHERE ID = %s""", (Prof_ID,))
        
        dest_path = os.path.join('/var/www/html', logo["Logo_URL"].lstrip('/'))
        os.remove(dest_path)
        
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Delete Prof_Logo failed: {e}")
    finally:
        cur.close()
        conn.close()

# ====================== SELECT BY KEY ======================
@router.get("/logo/select/{Prof_ID}", status_code=200)
def select_all_prof_cover(
    Prof_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    response: Response = Response(),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        prof = _select_full_prof_item(Prof_ID)
        require_row_exists(prof, Prof_ID, 'Prof')
        
        et = etag_of(prof)
        # ถ้า client ส่ง If-None-Match มาและตรง → 304
        if if_none_match and if_none_match == et:
            response.headers["ETag"] = et
            response.status_code = status.HTTP_304_NOT_MODIFIED
            return

        return {"logo": prof["Logo_URL"]}
    
    finally:
        cur.close()
        conn.close()
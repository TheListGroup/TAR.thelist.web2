from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists, normalize_row
from function_query_helper import update_entity_parent, check_location, check_country, url_work, _select_full_prod_item, recover_proj_prod_relationship, _select_all_location \
    , _select_country, _select_prod_category, _insert_cover_record, _save_image_file, _update_cover_record, _delete_cover, _get_image_display_order, _insert_image_record \
    , _update_image_record, _update_image_order, _delete_image, insert_file, _delete_resource, delete_entity_parent, get_prod_resource, assign_category_bulk \
    , _select_full_cate_item, _update_category_order, _select_full_attr_def_item, _update_attr_order, _select_full_attr_definition_item
from typing import Optional, Tuple, Dict, Any, List
import os
from datetime import datetime
import re
import shutil
import json

router = APIRouter()
TABLE = "product_entities"
ALLOWED_EXT = {".jpg", ".jpeg", ".png", ".webp", ".gif", ".jfif"}
UPLOAD_DIR = "/var/www/html/metro/uploads/product"

# ----------------------------------------------------- INSERT --------------------------------------------------------------------------------------------
@router.post("/insert", status_code=201)
def insert_product_entities(
    response: Response,
    Entity_Type: str = Form(...),
    Parent_ID: str = Form(None),
    Name_EN: str = Form(...),
    Name_TH: str = Form(None),
    Latitude: str = Form(None),
    Longitude: str = Form(None),
    Address: str = Form(None),
    Yarn: str = Form(None),
    Sub_District: str = Form(None),
    District: str = Form(None),
    Province: str = Form(None),
    State: str = Form(None),
    Country: str = Form(None),
    FB_Link: str = Form(None),
    IG_Link: str = Form(None),
    Line_Link: str = Form(None),
    YT_Link: str = Form(None),
    Website: str = Form(None),
    Content: str = Form(None),
    Brief_Description: str = Form(None),
    Category_Text: str = Form(None),
    Include: bool = Form(True),
    Prod_Status: str = Form('1'),
    Created_By: int = Form(...),
    Last_Updated_By: int = Form(...),
    _ = Depends(get_current_user),
):
    try:
        Parent_ID = None if not Parent_ID else int(Parent_ID)
        Name_TH = None if not Name_TH else Name_TH
        Latitude = None if not Latitude else float(Latitude)
        Longitude = None if not Longitude else float(Longitude)
        Address = None if not Address else Address
        Yarn = None if not Yarn else Yarn
        Sub_District = None if not Sub_District else Sub_District
        District = None if not District else District
        Province = None if not Province else Province
        State = None if not State else State
        Country = None if not Country else Country
        FB_Link = None if not FB_Link else FB_Link
        IG_Link = None if not IG_Link else IG_Link
        Line_Link = None if not Line_Link else Line_Link
        YT_Link = None if not YT_Link else YT_Link
        Website = None if not Website else Website
        Content = None if not Content else Content
        Brief_Description = None if not Brief_Description else Brief_Description
        Prod_Status = Prod_Status if Prod_Status else '1'
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid column format for some field.")
    
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        location_id_list = [None, None, None, None, None]
        location_type_list = ['Yarn', 'Subdistrict', 'District', 'Province', 'State']
        location_list = [Yarn, Sub_District, District, Province, State]
        for i, location in enumerate(location_list):
            location_id = check_location(cur, location, location_type_list[i])
            location_id_list[i] = location_id
        if Country:
            country_id = check_country(cur, Country)
        else:
            country_id = None
        
        sql = f"""
            INSERT INTO {TABLE}
            (Entity_Type, Parent_ID, Name_EN, Name_TH, Latitude, Longitude, Address, Yarn, Sub_District, District
            , Province, State, Country, FB_Link, IG_Link, Line_Link, YT_Link, Website, Content, Brief_Description
            , Entity_Status, Created_By, Last_Updated_By)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (
            Entity_Type, Parent_ID, Name_EN, Name_TH, Latitude, Longitude, Address, location_id_list[0], location_id_list[1], location_id_list[2]
            , location_id_list[3], location_id_list[4], country_id, FB_Link, IG_Link, Line_Link, YT_Link, Website, Content
            , Brief_Description, Prod_Status, Created_By, Last_Updated_By
        ))
        new_id = cur.lastrowid
        url_work(cur, new_id, Name_EN, 'prod')
        update_entity_parent(cur=cur, current_id=new_id, new_parent_id=Parent_ID, is_update=False)
        if Category_Text:
            assign_category_bulk(cur, new_id, Category_Text, Include)
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Product failed: {e}")
    finally:
        cur.close()
        conn.close()
    
    data = []
    row_prod = _select_full_prod_item(new_id)
    data.append({"prod": row_prod})
    
    response.headers["Location"] = f"/prod/select-prod/{new_id}"
    return apply_etag_and_return(response, data)

#-----------------------------------------------------------UPDATE--------------------------------------------------------------
@router.post("/update", status_code=200)
def update_product_entities(
    response: Response,
    Prod_ID: int = Form(...),
    Entity_Type: str = Form(...),
    Parent_ID: str = Form(None),
    Name_EN: str = Form(...),
    Name_TH: str = Form(None),
    Latitude: str = Form(None),
    Longitude: str = Form(None),
    Address: str = Form(None),
    Yarn: str = Form(None),
    Sub_District: str = Form(None),
    District: str = Form(None),
    Province: str = Form(None),
    State: str = Form(None),
    Country: str = Form(None),
    FB_Link: str = Form(None),
    IG_Link: str = Form(None),
    Line_Link: str = Form(None),
    YT_Link: str = Form(None),
    Website: str = Form(None),
    Content: str = Form(None),
    Brief_Description: str = Form(None),
    Category_Text: str = Form(None),
    Include: bool = Form(True),
    Prod_Status: str = Form('1'),
    Last_Updated_By: int = Form(...),
    if_match: Optional[str] = Header(None, alias="If-Match"),
    _ = Depends(get_current_user),
):
    try:
        Parent_ID = None if not Parent_ID else int(Parent_ID)
        Name_TH = None if not Name_TH else Name_TH
        Latitude = None if not Latitude else float(Latitude)
        Longitude = None if not Longitude else float(Longitude)
        Address = None if not Address else Address
        Yarn = None if not Yarn else Yarn
        Sub_District = None if not Sub_District else Sub_District
        District = None if not District else District
        Province = None if not Province else Province
        State = None if not State else State
        Country = None if not Country else Country
        FB_Link = None if not FB_Link else FB_Link
        IG_Link = None if not IG_Link else IG_Link
        Line_Link = None if not Line_Link else Line_Link
        YT_Link = None if not YT_Link else YT_Link
        Website = None if not Website else Website
        Content = None if not Content else Content
        Brief_Description = None if not Brief_Description else Brief_Description
        Prod_Status = Prod_Status if Prod_Status else '1'
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")

    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        current = _select_full_prod_item(Prod_ID)
        if not current:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                detail=f"Prod '{Prod_ID}' was not found")

        if if_match and if_match != etag_of(current):
            raise HTTPException(status_code=status.HTTP_412_PRECONDITION_FAILED,
                            detail="ETag mismatch. Please GET latest and retry with If-Match.")
        
        if Prod_Status == '1':
            cur.execute(f"UPDATE product_cover SET Image_Status='1' WHERE Entity_ID =%s and Image_Status = '2'", (Prod_ID,))
            cur.execute(f"UPDATE product_catalogs SET File_Status ='1' WHERE Entity_ID = %s and File_Status = '2'", (Prod_ID,))
            cur.execute(f"UPDATE product_gallery SET Image_Status ='1' WHERE Entity_ID = %s and Image_Status = '2'", (Prod_ID,))
            cur.execute(f"UPDATE product_entities_categories_relationship SET Relationship_Status='1' WHERE Entity_ID=%s and Relationship_Status = '2'", (Prod_ID,))
            cur.execute(f"UPDATE product_attribute_values SET Relationship_Status='1' WHERE Entity_ID=%s and Relationship_Status = '2'", (Prod_ID,))
            recover_proj_prod_relationship(cur, Prod_ID, 'prod')
        
        location_id_list = [None, None, None, None, None]
        location_type_list = ['Yarn', 'Subdistrict', 'District', 'Province', 'State']
        location_list = [Yarn, Sub_District, District, Province, State]
        for i, location in enumerate(location_list):
            location_id = check_location(cur, location, location_type_list[i])
            location_id_list[i] = location_id
        if Country:
            country_id = check_country(cur, Country)
        else:
            country_id = None
        
        sql = f"""
            UPDATE {TABLE}
            SET Entity_Type=%s,
                Parent_ID=%s,
                Name_EN=%s,
                Name_TH=%s,
                Latitude=%s,
                Longitude=%s,
                Address=%s,
                Yarn=%s,
                Sub_District=%s,
                District=%s,
                Province=%s,
                State=%s,
                Country=%s,
                FB_Link=%s,
                IG_Link=%s,
                Line_Link=%s,
                YT_Link=%s,
                Website=%s,
                Content=%s,
                Brief_Description=%s,
                Entity_Status=%s,
                Last_Updated_By=%s,
                Last_Updated_Date=CURRENT_TIMESTAMP
            WHERE ID=%s
        """
        update_entity_parent(cur=cur, current_id=Prod_ID, new_parent_id=Parent_ID, is_update=True)
        cur.execute(sql, (Entity_Type, Parent_ID, Name_EN, Name_TH, Latitude, Longitude, Address, location_id_list[0], location_id_list[1], location_id_list[2]
            , location_id_list[3], location_id_list[4], country_id, FB_Link, IG_Link, Line_Link, YT_Link, Website, Content, Brief_Description
            , Prod_Status, Last_Updated_By, Prod_ID))
        
        url_work(cur, Prod_ID, Name_EN, 'prod')
        if Category_Text:
            assign_category_bulk(cur, new_id, Category_Text, Include)
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Update Product failed: {e}")
    finally:
        cur.close()
        conn.close()
    
    row = _select_full_prod_item(Prod_ID)
    return apply_etag_and_return(response, row)

# ----------------------------------------------------- DELETE --------------------------------------------------------------------------------------------
@router.post("/delete", status_code=204)  # รองรับ form
def delete_product_entities(
    Prod_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    cur.execute(f"UPDATE {TABLE} SET Entity_Status='2' WHERE ID=%s", (Prod_ID,))
    affected = cur.rowcount
    
    #cover management
    cur.execute(f"update product_cover set Image_Status = '2' WHERE Entity_ID=%s", (Prod_ID,))
    
    #gallery management
    cur.execute(f"UPDATE product_gallery SET Image_Status = '2' WHERE Entity_ID = %s", (Prod_ID,))
    
    #experience management
    cur.execute(f"UPDATE product_entities_categories_relationship SET Relationship_Status='2' WHERE Entity_ID=%s", (Prod_ID,))
    
    # proj relationship management
    cur.execute(f"UPDATE proj_prod_relationship SET Relationship_Status='2' WHERE Prod_ID=%s", (Prod_ID,))
    
    # resource management
    cur.execute(f"UPDATE product_catalogs SET File_Status='2' WHERE Entity_ID=%s", (Prod_ID,))
    
    # attr relationship management
    cur.execute(f"UPDATE product_attribute_values SET Relationship_Status='2' WHERE Entity_ID=%s", (Prod_ID,))
    
    #parent management
    delete_entity_parent(cur, Prod_ID)
    
    conn.commit()
    cur.close()
    conn.close()

    if affected == 0:
        return to_problem(404, "Not Found", f"Prod '{Prod_ID}' was not found.")

# ====================== SELECT ALL ======================
@router.get("/select/all", status_code=200)
def select_all_product(
    _ = Depends(get_current_user),
):
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        base_sql = f"""
            SELECT
            *
            FROM {TABLE} 
            WHERE Entity_Status <> '2'
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
@router.get("/select/{Prod_ID}", status_code=200)
def select_product_by_id(
    response: Response,
    Prod_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_full_prod_item(Prod_ID)
    require_row_exists(row, Prod_ID, 'Product')

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
    row = _select_prod_category()

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
    Prod_ID: int = Form(...),
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
        elif Cover_Ratio == "1:1":
            cover_size_list = [
                {"size": (480, 480),  "ratio": "1:1"}
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
                    ref_id=Prod_ID,
                    image_name = None,
                    image_url="",
                    ratio_type = ratio,
                    image_status=Image_Status,
                    state="prod")
        
            cover_id = record["ID"]
            meta = _save_image_file(file_bytes, cover_id, Prod_ID, "Cover", "prod", None, size, ratio)
            _update_cover_record(cur, cover_id=cover_id, cover_url=meta["url"], state="prod")
            record["Cover_Url"] = meta["url"]
        
            results.append({"file": meta, "record": record})
        conn.commit()

        return {"cover": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Prod_Cover failed: {e}")
    finally:
        cur.close()
        conn.close()

# ============ ลบ cover + ลบ DB ============
@router.post("/cover/delete/", status_code=204)
async def delete_cover_record(
    Prod_ID: int = Form(...),
    Cover_Ratio: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    try:
        _delete_cover(cur, Prod_ID, Cover_Ratio, "prod")
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Delete Prod_Cover failed: {e}")
    finally:
        cur.close()
        conn.close()

# ====================== SELECT BY KEY ======================
@router.get("/cover/select/{Prod_ID}", status_code=200)
def select_all_prod_cover(
    Prod_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    response: Response = Response(),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        prod = _select_full_prod_item(Prod_ID)
        require_row_exists(prod, Prod_ID, 'Prod')
        
        et = etag_of(prod)
        # ถ้า client ส่ง If-None-Match มาและตรง → 304
        if if_none_match and if_none_match == et:
            response.headers["ETag"] = et
            response.status_code = status.HTTP_304_NOT_MODIFIED
            return
        
        ratio_list = ["16:9","9:16","1:1"]
        list_169 = []
        list_916 = []
        list_11 = []
        for ratio in ratio_list:
            base_sql = """SELECT
                            ID,
                            Entity_ID,
                            Image_URL,
                            Ratio_Type
                        FROM product_cover
                        WHERE Entity_ID = %s 
                        AND Image_Status = '1'
                        and Ratio_Type = %s
                        order by ID
                        limit 1"""
            
            cur.execute(base_sql, (Prod_ID, ratio))
            row = cur.fetchone()
            
            if ratio == "16:9":
                list_169 = row
            elif ratio == "9:16":
                list_916 = row
            elif ratio == "1:1":
                list_11 = row
        
        data = []
        data.append({"cover": {"16:9": list_169, "9:16": list_916, "1:1": list_11}})

        return {"data": data}
    
    finally:
        cur.close()
        conn.close()

# ============ อัปโหลดกี่ไฟล์ก็ได้ + บันทึก DB ============
@router.post("/images/record", status_code=201)
async def upload_and_record(
    files: List[UploadFile] = File(...),
    Prod_ID: int = Form(...),
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
        order = _get_image_display_order(cur, Prod_ID, 'prod')
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
                        ref_id = Prod_ID,
                        state = 'prod',
                        image_name=image_name,
                        image_url="",
                        display_order=order,
                        image_status=Image_Status,
                        image_description=img_des
                    )
            image_id = record["ID"]
            for image_size in image_size_list:
                meta = _save_image_file(file_bytes, image_id, Prod_ID, "Gallery", "prod", None, image_size, '16:9')
                if image_size[0] == 1440:
                    _update_image_record(
                        cur = cur,
                        image_id = image_id,
                        image_url = meta["url"],
                        state = 'prod'
                    )
                    record["Image_Url"] = meta["url"]
                
                results.append({"file": meta, "record": record})
            order += 1
        conn.commit()

        return {"count": len(results), "items": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Prod_Gallery failed: {e}")
    finally:
        cur.close()
        conn.close()

# ----------------------------------------------------- UPDATE Image Order --------------------------------------------------------------------------------------------
@router.post("/image/update/image_order", status_code=200)
def update_prod_image_order(
    Display_Order: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        order_list = Display_Order.split(",")
        results = []
        for i, order in enumerate(order_list):
            meta = _update_image_order(cur = cur, image_id=int(order), display_order=i+1, table_name="product_gallery")
            results.append({"data": meta})
        conn.commit()

        return {"items": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Update Prod_Gallery Order failed: {e}")
    finally:
        cur.close()
        conn.close()

# ----------------------------------------------------- UPDATE Image Name --------------------------------------------------------------------------------------------
@router.post("/image/update/image_caption", status_code=200)
def update_prod_image_caption(
    Image_ID: int = Form(...),
    Image_Caption: str = Form(None),
    Image_Description: str = Form(None),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    update_query = "UPDATE product_gallery SET Image_Name = %s, Image_Description = %s WHERE ID = %s"
    try:
        Image_Caption = None if not Image_Caption else Image_Caption
        Image_Description = None if not Image_Description else Image_Description
        cur.execute(update_query, (Image_Caption, Image_Description, Image_ID))
        conn.commit()
        return {"data": {"Image_ID": Image_ID, "Image_Name": Image_Caption}}
    except Exception as e:
        return to_problem(409, "Conflict", f"Update Prod_Gallery Caption failed: {e}")
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
        _delete_image(cur, Image_ID, "Delete_Image", None, "prod")
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Delete Prod_Gallery failed: {e}")
    finally:
        cur.close()
        conn.close()

# ====================== SELECT BY KEY ======================
@router.get("/images/select/{Prod_ID}", status_code=200)
def select_all_prod_images(
    Prod_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    response: Response = Response(),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        prod = _select_full_prod_item(Prod_ID)
        require_row_exists(prod, Prod_ID, 'Prod')
        
        et = etag_of(prod)
        # ถ้า client ส่ง If-None-Match มาและตรง → 304
        if if_none_match and if_none_match == et:
            response.headers["ETag"] = et
            response.status_code = status.HTTP_304_NOT_MODIFIED
            return
        
        base_sql = """SELECT
                        a.ID
                        , a.Entity_ID
                        , a.Image_Name
                        , a.Image_URL
                        , a.Image_Order
                        , a.Image_Status
                    FROM product_gallery a
                    WHERE a.Entity_ID = %s and a.Image_Status = '1'
                    ORDER BY a.Image_Order"""
        
        data = []
        cur.execute(base_sql, (Prod_ID,))
        rows = cur.fetchall()
        rows = [normalize_row(r) for r in rows]
        data.append({"list": rows})

        return {"data": data}
    
    finally:
        cur.close()
        conn.close()

# ============ upload logo + บันทึก DB ============
@router.post("/logo/record", status_code=201)
async def upload_and_record_logo(
    file: UploadFile = File(...),
    Prod_ID: int = Form(...),
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
        meta = _save_image_file(file_bytes, None, Prod_ID, "Logo", "prod", None, size, None)
        
        cur.execute(f"""UPDATE product_entities SET Logo_URL = %s WHERE ID = %s""", (meta["url"], Prod_ID))
    
        results.append({"file": meta})
        conn.commit()

        return {"logo": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Prod_Logo failed: {e}")
    finally:
        cur.close()
        conn.close()

# ============ ลบ logo + ลบ DB ============
@router.post("/logo/delete/", status_code=204)
async def delete_logo_record(
    Prod_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute(f"""select Logo_URL from product_entities WHERE ID = %s""", (Prod_ID,))
        logo = cur.fetchone()
        
        cur.execute(f"""UPDATE product_entities SET Logo_URL = null WHERE ID = %s""", (Prod_ID,))
        
        dest_path = os.path.join('/var/www/html', logo["Logo_URL"].lstrip('/'))
        os.remove(dest_path)
        
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Delete Prod_Logo failed: {e}")
    finally:
        cur.close()
        conn.close()

# ====================== SELECT BY KEY ======================
@router.get("/logo/select/{Prod_ID}", status_code=200)
def select_all_prod_logo(
    Prod_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    response: Response = Response(),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        prod = _select_full_prod_item(Prod_ID)
        require_row_exists(prod, Prod_ID, 'Prod')
        
        et = etag_of(prod)
        # ถ้า client ส่ง If-None-Match มาและตรง → 304
        if if_none_match and if_none_match == et:
            response.headers["ETag"] = et
            response.status_code = status.HTTP_304_NOT_MODIFIED
            return

        return {"logo": prod["Logo_URL"]}
    
    finally:
        cur.close()
        conn.close()

@router.post("/upload-resource", status_code=201)
def upload_resource(
    document: UploadFile = File(...),
    Prod_ID: int = Form(...),
    File_Name: str = Form(...),
    _ = Depends(get_current_user),
):
    if not document:
        raise HTTPException(status_code=400, detail="No files")

    conn = get_db()
    cur = conn.cursor(dictionary=True)
    
    user_folder = os.path.join(UPLOAD_DIR, f"{Prod_ID:04d}", "resources")
    if not os.path.exists(user_folder):
        os.makedirs(user_folder, exist_ok=True)
    saved_files = []
    try:
        result_list = []
        name = re.sub(r'(?u)[^-\w.]', '_', os.path.basename(document.filename))
        file_path = os.path.join(user_folder, name)
        if os.path.exists(file_path):
            raise Exception(f"File '{name}' already exists. Please rename.")
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(document.file, buffer)
        saved_files.append(file_path)
        
        path_insert = re.sub(f"{UPLOAD_DIR}/", '', file_path)
        size_in_bytes = os.path.getsize(file_path)
        file_size = f"{round(size_in_bytes / (1024 * 1024), 1)} MB"
        file_type = re.sub(r'^\.', '', os.path.splitext(name)[1].upper())
        result = insert_file(cur, Prod_ID, path_insert, File_Name, file_size, file_type)
        document.file.close()
        result_list.append(result)
        conn.commit()
        return result_list
    except Exception as e:
        conn.rollback()
        for f_path in saved_files:
            try:
                if os.path.exists(f_path):
                    os.remove(f_path)
            except Exception as cleanup_error:
                to_problem(409, "Conflict", f"delete failed: {cleanup_error}")
        return to_problem(500, "Server Error", f"Process Error (Database or Query Error): {str(e)}")
    finally:
        cur.close()
        conn.close()

@router.post("/delete-resource", status_code=204)
async def delete_resource(
    Res_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        _delete_resource(cur, Res_ID)
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Delete Prod_Resource failed: {e}")
    finally:
        cur.close()
        conn.close()

@router.get("/select-resource/{Prod_ID}", status_code=200)
def select_resource(
    Prod_ID: int,
    _ = Depends(get_current_user),
):
    resource = get_prod_resource(Prod_ID)
    return resource if resource else None

@router.get("/select-prod-categories/{Prod_ID}", status_code=200)
def select_prod_categories(
    Prod_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        prod_data = _select_full_prod_item(Prod_ID)
        category_data = prod_data["Category_Group"]
        category = json.loads(category_data)
        return category
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", e)
    finally:
        cur.close()
        conn.close()

@router.post("/insert-category", status_code=201)
def insert_category(
    response: Response,
    Parent_ID: str = Form(None),
    Code: str = Form(...),
    Name_EN: str = Form(...),
    Name_TH: str = Form(None),
    Categories_Status: str = Form('1'),
    _ = Depends(get_current_user),
):
    try:
        Parent_ID = None if not Parent_ID else int(Parent_ID)
        Code = None if not Code else Code
        Name_TH = None if not Name_TH else Name_TH
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid column format for some field.")
    
    conn = get_db()
    cur = conn.cursor()
    try:
        if Parent_ID:
            cur.execute("select max(Categories_Order) as max_order from product_entities_categories where Parent_ID = %s", (Parent_ID, ))
        else:
            cur.execute("select max(Categories_Order) as max_order from product_entities_categories where Parent_ID is null")
        order = cur.fetchone()
        
        sql = f"""INSERT INTO product_entities_categories (Parent_ID, Code, Category_ENName, Category_THName, Categories_Order, Categories_Status)
                VALUES (%s, %s, %s, %s, %s, %s)"""
        cur.execute(sql, (Parent_ID, Code, Name_EN, Name_TH, order[0]+1 if order[0] else 1, Categories_Status))
        new_id = cur.lastrowid
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Category failed: {e}")
    finally:
        cur.close()
        conn.close()
    
    data = []
    row_cate = _select_full_cate_item(new_id)
    data.append({"cate": row_cate})
    return apply_etag_and_return(response, data)

@router.post("/update-category", status_code=200)
def update_category(
    response: Response,
    Cate_ID: int = Form(...),
    Parent_ID: str = Form(None),
    Code: str = Form(...),
    Name_EN: str = Form(...),
    Name_TH: str = Form(None),
    Categories_Status: str = Form('1'),
    if_match: Optional[str] = Header(None, alias="If-Match"),
    _ = Depends(get_current_user),
):
    try:
        Parent_ID = None if not Parent_ID else int(Parent_ID)
        Code = None if not Code else Code
        Name_TH = None if not Name_TH else Name_TH
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")

    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        current = _select_full_cate_item(Cate_ID)
        if not current:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                detail=f"Category '{Cate_ID}' was not found")

        if if_match and if_match != etag_of(current):
            raise HTTPException(status_code=status.HTTP_412_PRECONDITION_FAILED,
                            detail="ETag mismatch. Please GET latest and retry with If-Match.")
        
        sql = f"""
            UPDATE product_entities_categories
            SET Parent_ID=%s,
                Code=%s,
                Category_ENName=%s,
                Category_THName=%s,
                Categories_Status=%s
            WHERE ID=%s
        """
        cur.execute(sql, (Parent_ID, Code, Name_EN, Name_TH, Categories_Status, Cate_ID))
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Update Category failed: {e}")
    finally:
        cur.close()
        conn.close()
    
    row = _select_full_cate_item(Cate_ID)
    return apply_etag_and_return(response, row)

@router.post("/update-category-order", status_code=200)
def update_prod_category_order(
    Display_Order: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        order_list = Display_Order.split(",")
        results = []
        for i, order in enumerate(order_list):
            meta = _update_category_order(cur = cur, category_id=int(order), display_order=i+1)
            results.append({"data": meta})
        conn.commit()

        return {"items": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Update Prod_Category Order failed: {e}")
    finally:
        cur.close()
        conn.close()

@router.post("/delete-category", status_code=204)  # รองรับ form
def delete_category(
    Cate_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    cur.execute(f"UPDATE product_entities_categories SET Categories_Status='2' WHERE ID=%s", (Cate_ID,))
    affected = cur.rowcount
    
    # prod relationship management
    cur.execute(f"Delete from product_entities_categories_relationship WHERE Category_ID=%s", (Cate_ID,))
    
    #parent management
    cur.execute(f"UPDATE product_entities_categories SET Parent_ID=NULL WHERE Parent_ID=%s", (Cate_ID,))
    
    conn.commit()
    cur.close()
    conn.close()

    if affected == 0:
        return to_problem(404, "Not Found", f"Category '{Cate_ID}' was not found.")

@router.post("/insert-spec-definition", status_code=201)
def insert_spec_definition(
    response: Response,
    Display_Name: str = Form(...),
    Key_Name: str = Form(...),
    Remark: str = Form(None),
    Data_Type: str = Form(...),
    Unit: str = Form(None),
    Options_List: str = Form(None),
    Attr_Status: str = Form('1'),
    _ = Depends(get_current_user),
):
    try:
        Remark = None if not Remark else Remark
        Unit = None if not Unit else Unit
        Options_List = None if not Options_List else Options_List
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid column format for some field.")
    
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("select max(Display_Order) as max_order from product_attribute_definitions where Attr_Status = '1'")
        order = cur.fetchone()
        
        if Options_List:
            actual_list = [item.strip() for item in Options_List.split(';') if item.strip()]
            json_to_db = json.dumps(actual_list)
        else:
            json_to_db = None
        
        sql = f"""INSERT INTO product_attribute_definitions (Display_Name, Key_Name, Remark, Data_Type, Unit, Options_List, Display_Order, Attr_Status)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""
        cur.execute(sql, (Display_Name, Key_Name, Remark, Data_Type, Unit, json_to_db, order[0]+1 if order[0] else 1, Attr_Status))
        new_id = cur.lastrowid
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Attribute Definitions failed: {e}")
    finally:
        cur.close()
        conn.close()
    
    data = []
    row_cate = _select_full_attr_def_item(new_id)
    data.append({"definitions": row_cate})
    return apply_etag_and_return(response, data)

@router.post("/update-spec-definition", status_code=200)
def update_spec_definition(
    response: Response,
    Spec_ID: int = Form(...),
    Display_Name: str = Form(...),
    Key_Name: str = Form(...),
    Remark: str = Form(None),
    Data_Type: str = Form(...),
    Unit: str = Form(None),
    Options_List: str = Form(None),
    Attr_Status: str = Form('1'),
    if_match: Optional[str] = Header(None, alias="If-Match"),
    _ = Depends(get_current_user),
):
    try:
        Remark = None if not Remark else Remark
        Unit = None if not Unit else Unit
        Options_List = None if not Options_List else Options_List
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")

    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        current = _select_full_attr_def_item(Spec_ID)
        if not current:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                detail=f"Attribute Definitions '{Spec_ID}' was not found")

        if if_match and if_match != etag_of(current):
            raise HTTPException(status_code=status.HTTP_412_PRECONDITION_FAILED,
                            detail="ETag mismatch. Please GET latest and retry with If-Match.")
        
        sql = f"""
            UPDATE product_attribute_definitions
            SET Display_Name=%s,
                Key_Name=%s,
                Remark=%s,
                Data_Type=%s,
                Unit=%s,
                Options_List=%s,
                Attr_Status=%s
            WHERE ID=%s
        """
        cur.execute(sql, (Display_Name, Key_Name, Remark, Data_Type, Unit, Options_List, Attr_Status, Spec_ID))
        conn.commit()
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Update Attribute Definitions failed: {e}")
    finally:
        cur.close()
        conn.close()
    
    row = _select_full_attr_def_item(Spec_ID)
    return apply_etag_and_return(response, row)

@router.post("/update-attr-order", status_code=200)
def update_attribute_order(
    Display_Order: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        order_list = Display_Order.split(",")
        results = []
        for i, order in enumerate(order_list):
            meta = _update_attr_order(cur = cur, attr_id=int(order), display_order=i+1)
            results.append({"data": meta})
        conn.commit()

        return {"items": results}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Update Attribute Definitions Order failed: {e}")
    finally:
        cur.close()
        conn.close()

@router.post("/delete-attribute", status_code=204)  # รองรับ form
def delete_attribute(
    Attr_ID: int = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    cur.execute(f"UPDATE product_attribute_definitions SET Attr_Status='2' WHERE ID=%s", (Attr_ID,))
    affected = cur.rowcount
    
    # prod relationship management
    cur.execute(f"Delete from product_attribute_values WHERE Attr_Def_ID=%s", (Attr_ID,))
    
    conn.commit()
    cur.close()
    conn.close()

    if affected == 0:
        return to_problem(404, "Not Found", f"Attribute Definitions' {Attr_ID}' was not found.")

@router.get("/select-attr/all", status_code=200)
def select_all_attr(
    _ = Depends(get_current_user),
):
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        base_sql = f"""
            SELECT
            *
            FROM product_attribute_definitions 
            WHERE Attr_Status <> '2'
            ORDER BY Display_Order
        """

        cur.execute(base_sql)
        rows = cur.fetchall()
        rows = [normalize_row(r) for r in rows]
        
        return rows
    finally:
        cur.close()
        conn.close()

@router.get("/select-attr/{Attr_ID}", status_code=200)
def select_attr_by_id(
    response: Response,
    Attr_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_full_attr_definition_item(Attr_ID)
    require_row_exists(row, Attr_ID, 'Attribute Definitions')

    et = etag_of(row)
    # ถ้า client ส่ง If-None-Match มาและตรง → 304
    if if_none_match and if_none_match == et:
        response.headers["ETag"] = et
        response.status_code = status.HTTP_304_NOT_MODIFIED
        return

    return apply_etag_and_return(response, row)

@router.post("/insert-prod-attribute", status_code=201)
def insert_prod_attribute(
    Prod_ID: int = Form(...),
    Attr_ID: int = Form(...),
    Attr_Value: str = Form(...),
    Relationship_Status: str = Form('1'),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""select Entity_ID, Attr_Def_ID from product_attribute_values 
                    where Entity_ID = %s and Attr_Def_ID = %s and Relationship_Status = '1'"""
                    , (Prod_ID, Attr_ID))
        check = cur.fetchall()
        if not check:
            cur.execute("select max(Display_Order) as max_order from product_attribute_values where Entity_ID = %s and Relationship_Status = '1'", (Prod_ID,))
            order = cur.fetchone()
            
            cur.execute("INSERT INTO product_attribute_values (Entity_ID, Attr_Def_ID, Attr_Value, Display_Order, Relationship_Status) VALUES (%s, %s, %s, %s, %s)"
                        , (Prod_ID, Attr_ID, Attr_Value, order[0]+1 if order[0] else 1, Relationship_Status))
            new_id = cur.lastrowid
            conn.commit()
        
            return {"insert id": new_id}
        else:
            return {"Message": "Already Have This Relationship"}
    except Exception as e:
        conn.rollback()
        return to_problem(409, "Conflict", f"Insert Product Attribute Relationship failed: {e}")
    finally:
        cur.close()
        conn.close()
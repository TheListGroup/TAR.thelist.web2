from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from function_utility import iso8601_z, normalize_unit_row, normalize_row
from typing import Optional, Tuple, Dict, Any, List
import os, uuid, shutil
from PIL import Image
import re
from wand.image import Image as WandImage
from io import BytesIO

UPLOAD_DIR = "/var/www/html/real-lease/uploads"
PUBLIC_PREFIX = "/real-lease/uploads"
ALLOWED_EXT = {".jpg", ".jpeg", ".png", ".webp", ".gif"}

def _select_full(unit_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                *
            FROM office_unit
            WHERE Unit_ID=%s
            AND Unit_Status <> '2'""",
        (unit_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return normalize_unit_row(row)

def _count_all() -> int:
    conn = get_db()
    cur = conn.cursor()
    cur.execute(f"SELECT COUNT(*) FROM office_unit")
    (total,) = cur.fetchone()
    cur.close()
    conn.close()
    return int(total)

def _select_full_office_unit_item(new_id: int) -> dict | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                *
            FROM office_unit
            WHERE Unit_ID=%s""",
        (new_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    # แปลงวันที่
    if row:
        for k in ("Created_Date", "Last_Updated_Date", "Available"):
            row[k] = iso8601_z(row[k])
    return row

def _get_building_id(Unit_ID: int) -> int:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT a.Building_ID 
                    FROM office_unit a JOIN office_building b ON a.Building_ID = b.Building_ID 
                    WHERE a.Unit_ID=%s""", (Unit_ID,))
        row = cur.fetchone()
        return int(row[0])
    finally:
        cur.close()
        conn.close()

def _get_project_id(building_id: int) -> int:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT a.Project_ID 
                    FROM office_building a JOIN office_project b ON a.Project_ID = b.Project_ID 
                    WHERE a.Building_ID=%s""", (building_id,))
        row = cur.fetchone()
        return int(row[0])
    finally:
        cur.close()
        conn.close()

def _get_unit_display_order(unit_id: int, unit_category_id: int) -> int:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("SELECT MAX(Display_Order) FROM office_unit_image WHERE Unit_ID=%s and Image_Status = '1' and Unit_Category_ID = %s", (unit_id, unit_category_id))
        (display_order,) = cur.fetchone()
        if display_order is None:
            return 1
        else:
            return display_order + 1
    finally:
        cur.close()
        conn.close()

def _select_all_unit_image_category(id_column: str, table_name: str) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT {id_column}, Category_Name, Section FROM {table_name} WHERE Category_Status = '1'"""
    )
    row = cur2.fetchall()
    cur2.close()
    conn2.close()
    return row

def _count_all_unit_image(unit_id: int, unit_category_id: int) -> int:
    conn = get_db()
    cur = conn.cursor()
    cur.execute(f"SELECT COUNT(*) FROM office_unit_image WHERE Image_Status = '1' and Unit_ID = %s and Unit_Category_ID = %s", (unit_id, unit_category_id))
    (total,) = cur.fetchone()
    cur.close()
    conn.close()
    return int(total)

def _select_full_admin_and_leasing_user(new_id: int) -> dict | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                *
            FROM office_admin_and_leasing_user
            WHERE User_ID=%s""",
        (new_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return row

def _get_building_relationship(user_id: int) -> List[Tuple[int, int]]:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT a.Building_ID, a.Project_ID, b.ID
                    FROM office_building a 
                    join office_building_relationship b on a.Building_ID = b.Building_ID 
                    WHERE a.Building_Status <> '2'
                    and b.Relationship_Status <> '2'
                    and b.User_ID=%s""", (user_id,))
        return cur.fetchall()
    finally:
        cur.close()
        conn.close()

def _get_project_name(proj_id: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT a.Name_TH, a.Name_EN 
                    FROM office_project a
                    WHERE a.Project_ID=%s""", (proj_id,))
        return cur.fetchone()
    finally:
        cur.close()
        conn.close()

def _get_building_name(building_id: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT a.Building_Name 
                    FROM office_building a
                    WHERE a.Building_ID=%s""", (building_id,))
        return cur.fetchone()
    finally:
        cur.close()
        conn.close()

def _get_province(Project_ID: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT 
                        p.Province_Code
                    FROM office_project AS op
                    JOIN thailand_province AS p
                    ON ST_Contains(p.polygon, ST_GeomFromText(CONCAT('POINT(', op.Longitude, ' ', op.Latitude, ')')))
                    WHERE op.Latitude IS NOT NULL 
                    AND op.Longitude IS NOT NULL
                    AND op.Project_ID=%s""", (Project_ID,))
        row = cur.fetchone()
        return row[0]
    finally:
        cur.close()
        conn.close()

def _get_district(Project_ID: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT 
                        d.district_code
                    FROM office_project AS op
                    JOIN thailand_district AS d
                    ON ST_Contains(d.polygon, ST_GeomFromText(CONCAT('POINT(', op.Longitude, ' ', op.Latitude, ')')))
                    WHERE op.Latitude IS NOT NULL 
                    AND op.Longitude IS NOT NULL
                    AND op.Project_ID=%s""", (Project_ID,))
        row = cur.fetchone()
        return row[0]
    finally:
        cur.close()
        conn.close()

def _get_subdistrict(Project_ID: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT 
                        sd.subdistrict_code
                    FROM office_project AS op
                    JOIN thailand_subdistrict AS sd
                    ON ST_Contains(sd.polygon, ST_GeomFromText(CONCAT('POINT(', op.Longitude, ' ', op.Latitude, ')')))
                    WHERE op.Latitude IS NOT NULL 
                    AND op.Longitude IS NOT NULL
                    AND op.Project_ID=%s""", (Project_ID,))
        row = cur.fetchone()
        return row[0]
    finally:
        cur.close()
        conn.close()

def _get_realist_district(Project_ID: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT 
                        rm.District_Code
                    FROM office_project AS op
                    JOIN real_yarn_main AS rm
                    ON ST_Contains(rm.polygon, ST_GeomFromText(CONCAT('POINT(', op.Longitude, ' ', op.Latitude, ')')))
                    WHERE op.Latitude IS NOT NULL 
                    AND op.Longitude IS NOT NULL
                    AND op.Project_ID=%s""", (Project_ID,))
        row = cur.fetchone()
        return row[0]
    finally:
        cur.close()
        conn.close()

def _get_realist_subdistrict(Project_ID: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT 
                        rs.SubDistrict_Code
                    FROM office_project AS op
                    JOIN real_yarn_sub AS rs
                    ON ST_Contains(rs.polygon, ST_GeomFromText(CONCAT('POINT(', op.Longitude, ' ', op.Latitude, ')')))
                    WHERE op.Latitude IS NOT NULL 
                    AND op.Longitude IS NOT NULL
                    AND op.Project_ID=%s""", (Project_ID,))
        row = cur.fetchone()
        return row[0]
    finally:
        cur.close()
        conn.close()

def _select_full_office_project_item(new_id: int) -> dict | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                *
            FROM office_project
            WHERE Project_ID=%s""",
        (new_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    # แปลงวันที่
    if row:
        for k in ("Created_Date", "Last_Updated_Date"):
            row[k] = iso8601_z(row[k])
    return row

def _select_full_office_building_item(new_id: int) -> dict | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                *
            FROM office_building
            WHERE Building_ID=%s""",
        (new_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    # แปลงวันที่
    if row:
        for k in ("Created_Date", "Last_Updated_Date"):
            row[k] = iso8601_z(row[k])
    return row

def _insert_building_record(
    proj_id, building_name: str, office_condo: int, price_min: int, price_max: int|None, lat: float|None, lng: float|None,
    building_area: float|None, lettable_area: float|None, floor_plate1: int|None, floor_plate2: int|None, floor_plate3: int|None,
    size_min: float|None, size_max: float|None, landlord: str|None, management: str|None, sole_agent: int|None,
    built_completed: str|None, last_renovate: str|None, floor_above: float|None, floor_basement: float|None, floor_office_only: float|None,
    ceiling_avg: float|None,
    parking_ratio: str|None, parking_fee: int|None, total_lift: int|None, passenger_lift: int|None, service_lift: int|None, retail_parking_lift: int|None,
    ac: str|None, ac_time_start: str|None, ac_time_end: str|None, ac_ot_weekday_by_hour: float|None, ac_ot_weekday_by_area: float|None,
    ac_ot_weekend_by_hour: float|None, ac_ot_weekend_by_area: float|None, ac_ot_min_hour: float|None,
    bill_elec: float|None, bill_water: float|None, rent_term: int|None, rent_deposit: int|None, rent_advance: int|None, user_id: int, building_status: str,
    created_by: int, last_updated_by: int
) -> dict:
    try:
        conn = get_db()
        cur = conn.cursor()
        sql = """
            INSERT INTO office_building
                (Project_ID, Building_Name, Office_Condo, Rent_Price_Min, Rent_Price_Max, Building_latitude, Building_Longitude, Total_Building_Area, Lettable_Area
                , Typical_Floor_Plate_1, Typical_Floor_Plate_2, Typical_Floor_Plate_3, Unit_Size_Min, Unit_Size_Max, Landlord, Management
                , Sole_Agent, Built_Complete, Last_Renovate, Floor_Above, Floor_Basement, Floor_Office_Only
                , Ceiling_Avg
                , Parking_Ratio, Parking_Fee_Car
                , Total_Lift, Passenger_Lift, Service_Lift, Retail_Parking_Lift, AC_System, ACTime_Start, ACTime_End
                , AC_OT_Weekday_by_Hour, AC_OT_Weekday_by_Area, AC_OT_Weekend_by_Hour, AC_OT_Weekend_by_Area, AC_OT_Min_Hour
                , Bills_Electricity, Bills_Water
                , Rent_Term, Rent_Deposit, Rent_Advance, User_ID, Building_Status
                , Created_By, Last_Updated_By)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (proj_id, building_name, office_condo, price_min, price_max, lat, lng, building_area, lettable_area
                        , floor_plate1, floor_plate2, floor_plate3, size_min, size_max, landlord, management
                        , sole_agent, built_completed, last_renovate, floor_above, floor_basement, floor_office_only, ceiling_avg, parking_ratio, parking_fee, total_lift
                        , passenger_lift, service_lift, retail_parking_lift, ac, ac_time_start, ac_time_end, ac_ot_weekday_by_hour, ac_ot_weekday_by_area
                        , ac_ot_weekend_by_hour, ac_ot_weekend_by_area, ac_ot_min_hour, bill_elec, bill_water
                        , rent_term, rent_deposit, rent_advance, user_id, building_status, created_by, last_updated_by))
        conn.commit()
        new_id = cur.lastrowid
        return new_id
    finally:
        cur.close()
        conn.close()

def _insert_cover_record(
    type_text: str, ref_id: int, image_url: str,
    cover_size: int, cover_status: str, created_by: int
) -> dict:
    try:
        conn = get_db()
        cur = conn.cursor()
        sql = """INSERT INTO office_cover
                    (Project_or_Building, Ref_ID, Cover_Size, Cover_Url, Cover_Status, Created_By, Last_Updated_By)
                VALUES (%s, %s, %s, %s, %s, %s, %s)"""
        cur.execute(sql, (type_text, ref_id, cover_size, image_url, cover_status, created_by, created_by))
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
                        Cover_ID, Project_or_Building, Ref_ID, Cover_Size, Cover_Url, Cover_Status, Created_By, Created_Date,
                        Last_Updated_By, Last_Updated_Date
                    FROM office_cover
                    WHERE Cover_ID=%s""",
            (new_id,))
        row = cur2.fetchone()
        return row
    finally:
        cur2.close()
        conn2.close()

def _get_image_display_order(project_id: int, category_id: int, ref_type: str) -> int:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""
            SELECT MAX(Display_Order) FROM office_image WHERE Ref_ID=%s and Image_Status = '1' 
            and Category_ID = %s and Project_or_Building = %s""", (project_id, category_id, ref_type))
        (display_order,) = cur.fetchone()
        if display_order is None:
            return 1
        else:
            return display_order + 1
    finally:
        cur.close()
        conn.close()

def _update_image_order(
    *, image_id, display_order: int, table_name: str, id_column: str,
) -> dict:
    conn = get_db()
    cur = conn.cursor()
    try:
        sql = f"""
            UPDATE {table_name}
            SET Display_Order=%s
            WHERE {id_column}=%s
        """
        cur.execute(sql, (display_order, image_id))
        conn.commit()
    finally:
        cur.close()
        conn.close()
    
    return {
        "image_id": image_id,
        "display_order": display_order,
    }

def _select_full_project(project_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                *
            FROM office_project
            WHERE Project_ID=%s
            AND Project_Status <> '2'""",
        (project_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return normalize_row(row)

def _delete_cover(cover_id: int, action: str, type_name: str):
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("SELECT Ref_ID,Cover_Url FROM office_cover WHERE Cover_ID=%s", (cover_id,))
        row = cur.fetchone()
        if not row:
            return
        (ref_id, cover_url) = row
        
        if action == "Delete_Cover":
            cover_type = cover_url.split("/")[-1].split("-")[1]
            cur.execute("SELECT Cover_ID, Cover_Url FROM office_cover WHERE Cover_Url like %s and Ref_ID=%s and Project_or_Building=%s", (f"%{cover_type}%", ref_id, type_name))
            result = cur.fetchall()
            
            if result:
                for each_cover in result:
                    cur.execute("DELETE FROM office_cover WHERE Cover_ID=%s", (each_cover[0],))
                    conn.commit()
                    affected = cur.rowcount

                    if affected > 0:
                        dest_path = os.path.join('/var/www/html', each_cover[1].lstrip('/'))
                        os.remove(dest_path)
        else:
            cur.execute("UPDATE office_cover SET Cover_Status='2' WHERE Cover_ID=%s", (cover_id,))
            conn.commit()
            affected = cur.rowcount
    finally:
        cur.close()
        conn.close()

def _delete_image(image_id: int, action: str, type_name: str, project_id: int):
    conn = get_db()
    cur = conn.cursor()
    try:
        image_size_list = [(1440,810),(800,450),(400,225)]
        cur.execute("SELECT Ref_ID, Category_ID, Display_Order, Project_or_Building FROM office_image WHERE Image_ID=%s", (image_id,))
        row = cur.fetchone()
        if not row:
            return
        (ref_id, category_id, display_order, project_or_building) = row
        
        if action == "Delete_Image":
            cur.execute("DELETE FROM office_image WHERE Image_ID=%s", (image_id,))
            conn.commit()
            affected = cur.rowcount

            if affected > 0:
                cur.execute("SELECT Image_ID FROM office_image WHERE Ref_ID=%s AND Display_Order>%s AND Project_or_Building=%s AND Category_ID=%s"
                            , (ref_id, display_order, project_or_building, category_id))
                rows = cur.fetchall()
                for row in rows:
                    cur.execute("UPDATE office_image SET Display_Order=Display_Order-1 WHERE Image_ID=%s", (row[0],))
                    conn.commit()
                
                if type_name == "Project":
                    path_folder = os.path.join(UPLOAD_DIR, str(f"{ref_id:04d}"), "images")
                    for image_size in image_size_list:
                        filename = f"{image_id:06d}-H-{image_size[0]}.webp"
                        dest_path = os.path.join(path_folder, filename)
                        os.remove(dest_path)
                else:
                    path_folder = os.path.join(UPLOAD_DIR, str(f"{project_id:04d}"), str(f"{ref_id:04d}"), "images")
                    filename = f"{image_id:06d}.webp"
                    dest_path = os.path.join(path_folder, filename)
                    os.remove(dest_path)
        else:
            cur.execute("UPDATE office_image SET Image_Status='2' WHERE Image_ID=%s", (image_id,))
            conn.commit()
            affected = cur.rowcount
    finally:
        cur.close()
        conn.close()

def _save_image_file(f: bytes, image_id: int, ref_id: int, image_type: str, type_name: str, project_id: int, image_size: tuple, content_type: str) -> dict:
    width, height = image_size
    if image_type == "Cover":
        if type_name == "Project":
            path_folder = os.path.join(UPLOAD_DIR, str(f"{ref_id:04d}"), "cover")
        else:
            path_folder = os.path.join(UPLOAD_DIR, str(f"{project_id:04d}"), str(f"{ref_id:04d}"), "cover")
    else:
        if type_name == "Project":
            path_folder = os.path.join(UPLOAD_DIR, str(f"{ref_id:04d}"), "images")
        else:
            path_folder = os.path.join(UPLOAD_DIR, str(f"{project_id:04d}"), str(f"{ref_id:04d}"), "images")
    
    filename = f"{image_id:06d}-H-{width}.webp"
    os.makedirs(path_folder, exist_ok=True)  # create if not exists
    dest_path = os.path.join(path_folder, filename)
    
    if image_type == "Cover":
        image = Image.open(BytesIO(f)).convert("RGB")
        image = image.resize(image_size, Image.Resampling.LANCZOS)
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
        "url": image_url,
        "content_type": content_type,
    }

def _update_cover_record(
    *, cover_id, cover_url: str,
) -> dict:
    conn = get_db()
    cur = conn.cursor()
    try:
        sql = """
            UPDATE office_cover
            SET Cover_Url=%s
            WHERE Cover_ID=%s
        """
        cur.execute(sql, (cover_url, cover_id))
        conn.commit()
    finally:
        cur.close()
        conn.close()

def _select_full_office_building_relationship_item(id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                *
            FROM office_building_relationship
            WHERE ID=%s
            AND Relationship_Status = '1'""",
        (id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return normalize_row(row)
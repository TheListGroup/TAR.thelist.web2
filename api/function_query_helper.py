from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from function_utility import iso8601_z, normalize_unit_row, normalize_row, format_seconds_to_time_str
from typing import Optional, Tuple, Dict, Any, List
import os, uuid, shutil
from PIL import Image
import re
from wand.image import Image as WandImage
from io import BytesIO
import random
import string
from datetime import datetime

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
        if row:
            return row[0]
        return None
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
        if row:
            return row[0]
        return None
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
        if row:
            return row[0]
        return None
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
        if row:
            return row[0]
        return None
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
        if row:
            return row[0]
        return None
    finally:
        cur.close()
        conn.close()

def _select_full_office_project_item(new_id: int) -> dict | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
            a.Project_ID, a.Name_TH, a.Name_EN, a.Latitude, a.Longitude, a.Road_Name, a.Province_ID, a.District_ID
            , a.SubDistrict_ID, a.Realist_DistrictID, a.Realist_SubDistrictID, a.Land_Rai, a.Land_Ngan, a.Land_Wa, a.Land_Total, a.Office_Lettable_Area
            , a.Total_Usable_Area, a.Parking_Amount, a.Security_Type, a.F_Common_Bathroom, a.F_Common_Pantry, a.F_Common_Garbageroom, a.F_Retail_Conv_Store, a.F_Retail_Supermarket
            , a.F_Retail_Mall_Shop, a.F_Food_Market, a.F_Food_Foodcourt, a.F_Food_Cafe, a.F_Food_Restaurant, a.F_Services_ATM, a.F_Services_Bank, a.F_Services_Pharma_Clinic
            , a.F_Services_Hair_Salon, a.F_Services_Spa_Beauty, a.F_Others_Gym, a.F_Others_Valet, a.F_Others_EV, a.F_Others_Conf_Meetingroom, a.Environment_Friendly, a.Project_Description
            , a.Project_URL_Tag, a.Building_Copy, a.User_ID, a.Project_Status, a.Project_Redirect, a.Created_By, a.Created_Date, a.Last_Updated_By, a.Last_Updated_Date
            , b.Tags, floor_plan.Floor_Plan
            FROM office_project a
            left join (select a.Project_ID, group_concat(b.Tag_Name ORDER BY Relationship_Order SEPARATOR ';') as Tags
                        from office_project_tag_relationship a
                        join office_project_tag b on a.Tag_ID = b.Tag_ID
                        where a.Relationship_Status <> '2'
                        group by a.Project_ID) b 
            on a.Project_ID = b.Project_ID
            left join (SELECT a.Project_ID,  JSON_ARRAYAGG(JSON_OBJECT( 'Floor_Plan_ID', b.Image_ID
                                                                        , 'Floor_Name', b.Image_Name
                                                                        , 'FLoor_Plan_Order', b.Display_Order
                                                                        , 'Floor_Plan_URL', b.Image_URL)) as Floor_Plan
                        FROM office_project a
                        join office_image b on a.Project_ID = b.Ref_ID
                        where b.Image_Status = '1'
                        and b.Project_or_Building = 'Project'
                        and b.Category_ID = 14
                        group by a.Project_ID) floor_plan
            on a.Project_ID = floor_plan.Project_ID
            WHERE a.Project_Status <> '2'
            AND a.Project_ID = %s""",
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
        for k in ("ACTime_Start", "ACTime_End"):
            row[k] = format_seconds_to_time_str(row[k])
    return row

def _insert_building_record(
    proj_id, building_name: str, office_condo: int, price_min: int, price_max: int|None, lat: float|None, lng: float|None,
    building_area: float|None, lettable_area: float|None, floor_plate1: int|None, floor_plate2: int|None, floor_plate3: int|None,
    size_min: float|None, size_max: float|None, landlord: str|None, management: str|None, sole_agent: int|None,
    built_completed: str|None, last_renovate: str|None, floor_above: float|None, floor_basement: float|None, floor_office_only: float|None,
    ceiling_avg: float|None,
    parking_ratio: str|None, parking_fee: int|None, total_lift: int|None, passenger_lift: int|None, service_lift: int|None, retail_parking_lift: int|None,
    ac: str|None, ac_split_type: int|None, ac_time_start: str|None, ac_time_end: str|None, ac_ot_weekday_by_hour: str|None, ac_ot_weekday_by_area: str|None,
    ac_ot_weekend_by_hour: str|None, ac_ot_weekend_by_area: str|None, ac_ot_min_hour: float|None, ac_ot_min_baht: float|None,
    ac_ot_avg_weekday_by_hour: float|None, ac_ot_avg_weekend_by_hour: float|None, ac_ot_avg_weekday_by_area: float|None, ac_ot_avg_weekend_by_area: float|None,
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
                , Total_Lift, Passenger_Lift, Service_Lift, Retail_Parking_Lift, AC_System, AC_Split_Type, ACTime_Start, ACTime_End
                , AC_OT_Weekday_by_Hour, AC_OT_Weekday_by_Area, AC_OT_Weekend_by_Hour, AC_OT_Weekend_by_Area, AC_OT_Min_Hour, AC_OT_Min_Baht
                , AC_OT_Average_Weekday_by_Hour, AC_OT_Average_Weekend_by_Hour, AC_OT_Average_Weekday_by_Area, AC_OT_Average_Weekend_by_Area
                , Bills_Electricity, Bills_Water
                , Rent_Term, Rent_Deposit, Rent_Advance, User_ID, Building_Status
                , Created_By, Last_Updated_By)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (proj_id, building_name, office_condo, price_min, price_max, lat, lng, building_area, lettable_area, floor_plate1
                        , floor_plate2, floor_plate3, size_min, size_max, landlord, management, sole_agent, built_completed, last_renovate, floor_above
                        , floor_basement, floor_office_only, ceiling_avg, parking_ratio, parking_fee, total_lift, passenger_lift, service_lift, retail_parking_lift, ac
                        , ac_split_type, ac_time_start, ac_time_end, ac_ot_weekday_by_hour, ac_ot_weekday_by_area, ac_ot_weekend_by_hour
                        , ac_ot_weekend_by_area, ac_ot_min_hour, ac_ot_min_baht, ac_ot_avg_weekday_by_hour, ac_ot_avg_weekend_by_hour, ac_ot_avg_weekday_by_area
                        , ac_ot_avg_weekend_by_area
                        , bill_elec, bill_water
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
            path_folder = os.path.join(UPLOAD_DIR, str(f"{project_id:04d}"), str(f"{ref_id:04d}"), "floor_plan")
    
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

def _get_floor_plan_display_order(building_id: int) -> int:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""
            SELECT MAX(Display_Order) FROM office_floor_plan WHERE Building_ID=%s and Floor_Plan_Status = '1'""", (building_id,))
        (display_order,) = cur.fetchone()
        if display_order is None:
            return 1
        else:
            return display_order + 1
    finally:
        cur.close()
        conn.close()

def _get_project_card_data(proj_id: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT a.Project_Tag_Used, a.Project_Tag_All, a.near_by, a.Highlight
                    FROM source_office_project_carousel_recommend a
                    WHERE a.Project_ID=%s""", (proj_id,))
        row = cur.fetchone()
        if row:
            return row
        return None
    finally:
        cur.close()
        conn.close()

def _get_project_template_price_card_data(proj_id: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""select Project_ID
                            , if(min(Price)=max(Price)
                                , format(min(Price),0)
                                , concat(format(min(Price),0),' - ',format(max(Price),0))) as Rent_Price
                        from (select * from (select Project_ID, Rent_Price_Min as Price
                                            from office_building
                                            where Building_Status = '1'
                                            and Rent_Price_Min is not null) min_price
                                union all
                                select * from (select Project_ID, Rent_Price_Max as Price
                                                from office_building
                                                where Building_Status = '1'
                                                and Rent_Price_Max is not null) max_price) a
                        WHERE a.Project_ID=%s
                        group by Project_ID""", (proj_id,))
        row = cur.fetchone()
        if row:
            return row
        return None
    finally:
        cur.close()
        conn.close()

def _get_project_template_area_card_data(proj_id: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""select Project_ID
                            , if(min(Area)=max(Area)
                                , format(min(Area),0)
                                , concat(format(min(Area),0),' - ',format(max(Area),0))) as Area
                        from (select * from (select Project_ID, Unit_Size_Min as Area
                                            from office_building
                                            where Building_Status = '1'
                                            and Unit_Size_Min is not null) min_area
                                union all
                                select * from (select Project_ID, Unit_Size_Max as Area
                                                from office_building
                                                where Building_Status = '1'
                                                and Unit_Size_Max is not null) max_area) a
                        WHERE a.Project_ID=%s
                        group by Project_ID""", (proj_id,))
        row = cur.fetchone()
        if row:
            return row
        return None
    finally:
        cur.close()
        conn.close()

def _get_project_building(proj_id: int) -> Dict[str, Any] | None:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute("""SELECT a.Building_ID, a.Building_Name
                        , CONCAT(IF(a.Floor_above = FLOOR(a.Floor_above)
                                    , CAST(FLOOR(a.Floor_above) AS CHAR)
                                    , a.Floor_above), ';ชั้น') as Floor
                        , if(a.Unit_Size_Min is not null and a.Unit_Size_Max is not null
                            , if(a.Unit_Size_Min = a.Unit_Size_Max
                                , concat(format(a.Unit_Size_Min,0), ';ตร.ม.')
                                , concat(format(a.Unit_Size_Min,0),' - ',format(a.Unit_Size_Max,0), ';ตร.ม.'))
                            , concat(format(ifnull(a.Unit_Size_Max,a.Unit_Size_Min),0), ';ตร.ม.')) as Area
                        , if(a.Rent_Price_Min is not null and a.Rent_Price_Max is not null
                            , if(a.Rent_Price_Min = a.Rent_Price_Max
                                , concat(format(a.Rent_Price_Min,0), ';บ./ตร.ม./ด.')
                                , concat(format(a.Rent_Price_Min,0),' - ',format(a.Rent_Price_Max,0), ';บ./ตร.ม./ด.'))
                            , concat(format(ifnull(a.Rent_Price_Max,a.Rent_Price_Min),0), ';บ./ตร.ม./ด.')) as Rent_Price
                        , b.Cover_Url as Cover
                        , YEAR(a.Built_Complete) as Year_Built_Complete
                        , YEAR(a.Last_Renovate) as Year_Last_Renovate
                        , concat(format(a.Total_Building_Area,0), ';ตร.ม.') as Total_Building_Area
                        , concat(format(a.Lettable_Area,0), ';ตร.ม.') as Lettable_Area
                        , concat(format(a.Typical_Floor_Plate_1,0), ';ตร.ม.') as Typical_Floor_Plate_1
                        , concat(format(a.Typical_Floor_Plate_2,0), ';ตร.ม.') as Typical_Floor_Plate_2
                        , concat(format(a.Typical_Floor_Plate_3,0), ';ตร.ม.') as Typical_Floor_Plate_3
                        , IF(MOD(ROUND(a.Ceiling_Avg, 1), 1) = 0
                            , concat(FORMAT(ROUND(a.Ceiling_Avg, 1), 0), ';ม.')
                            , concat(FORMAT(ROUND(a.Ceiling_Avg, 1), 1), ';ม.')) as Ceiling
                        , ifnull(a.Total_Lift,0) as Total_Lift
                        , a.AC_System as AC_System
                    FROM office_building a
                    left join office_cover b on a.Building_ID = b.Ref_ID and b.Project_or_Building = 'Building' AND b.Cover_Size = 800 AND b.Cover_Status = '1'
                    WHERE a.Project_ID=%s
                    AND a.Building_Status = '1'""", (proj_id,))
        row = cur.fetchall()
        if len(row) >= 1:
            return row
        else:
            return None
    finally:
        cur.close()
        conn.close()

def _get_subdistrict_data(subdistrict_code : str) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT ts.subdistrict_code, ts.full_name_th, ts.full_name_en, ts.name_th, ts.name_en
                    FROM thailand_subdistrict ts
                    WHERE ts.subdistrict_code =%s""", (subdistrict_code,))
        row = cur.fetchone()
        if row:
            return row[1]
        return None
    finally:
        cur.close()
        conn.close()

def _get_district_data(district_code : str) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT td.district_code, td.full_name_th, td.full_name_en, td.name_th, td.name_en
                    FROM thailand_district td
                    WHERE td.district_code =%s""", (district_code,))
        row = cur.fetchone()
        if row:
            return row[1]
        return None
    finally:
        cur.close()
        conn.close()

def _get_province_data(province_code : str) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""SELECT tp.province_code, tp.name_th, tp.name_en
                    FROM thailand_province tp
                    WHERE tp.province_code =%s""", (province_code,))
        row = cur.fetchone()
        if row:
            return row[1]
        return None
    finally:
        cur.close()
        conn.close()

def get_project_cover(ref_id: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""select Ref_ID
                        , JSON_ARRAYAGG(JSON_OBJECT('Image_ID', Image_ID
                                                    , 'Image_Name', Image_Name
                                                    , 'Category_Order', Category_Order
                                                    , 'Display_Order', Display_Order
                                                    , 'Image_URL', Image_URL
                                                    , 'Image_Type', Image_Type)) as Image_Set
                    from source_office_image_all
                    WHERE Ref_ID=%s
                    and Image_Type = 'Cover_Project'
                    group by Ref_ID""", (ref_id,))
        row = cur.fetchone()
        if row:
            return row[1]
        return None
    finally:
        cur.close()
        conn.close()

def get_project_image(ref_id: int) -> str:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""select Ref_ID
                        , JSON_ARRAYAGG(JSON_OBJECT('Image_ID', Image_ID
                                                    , 'Image_Name', Image_Name
                                                    , 'Category_Order', Category_Order
                                                    , 'Display_Order', Display_Order
                                                    , 'Image_URL', Image_URL
                                                    , 'Image_Type', Image_Type)) as Image_Set
                    from source_office_image_all
                    WHERE Ref_ID=%s
                    and Image_Type in ('Project_Image', 'Cover_Project')
                    and Section <> 'Floor Plan'
                    and Category_ID <> 9
                    group by Ref_ID""", (ref_id,))
        row = cur.fetchone()
        if row:
            return row[1]
        return None
    finally:
        cur.close()
        conn.close()

def get_all_unit_carousel_images(unit_ids: list, project_ids: list, use_carousel_logic: bool = True, custom_resize: bool = None) -> dict:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    unit_placeholders = ', '.join(['%s'] * len(unit_ids))
    project_placeholders = ', '.join(['%s'] * len(project_ids))
    
    filter_mode = 1 if use_carousel_logic else 0
    if custom_resize is not None:
        resize_mode = 1 if custom_resize else 0
    else:
        resize_mode = filter_mode
    
    try:
        cur.execute("SET @filter_mode = %s", (filter_mode,))
        cur.execute("SET @resize_mode = %s", (resize_mode,))
        sql_query = f"""
        WITH ProcessedImages AS (
            SELECT
                CASE 
                    WHEN img.Image_Type = 'Unit_Image' THEN img.Ref_ID
                    ELSE map.Unit_ID
                END AS Owning_Unit_ID,

                CASE
                    WHEN @resize_mode = 0 THEN img.Image_URL                   
                    WHEN @resize_mode = 1 AND img.Image_Type = 'Cover_Project'
                    THEN REPLACE(
                            REGEXP_REPLACE(img.Image_URL, '-H-\\\\d+', '-H-400'),
                            SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-', 1),
                            LPAD(CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-', 1) AS UNSIGNED) + 2, LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-', 1)), '0')
                        )
                    
                    ELSE REGEXP_REPLACE(img.Image_URL, '-H-\\\\d+', '-H-400')
                END AS Modified_Image_URL,

                CASE
                    WHEN @resize_mode = 1 AND img.Image_Type = 'Cover_Project' 
                    THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-H', 1) AS UNSIGNED) + 2
                    ELSE img.Image_ID
                END AS Modified_Image_ID,

                img.Image_Name, img.Category_Order, img.Display_Order, img.Image_Type,
                img.Category_ID,

                SUM(CASE WHEN img.Image_Type = 'Unit_Image' THEN 1 ELSE 0 END) OVER (PARTITION BY 
                    CASE 
                        WHEN img.Image_Type = 'Unit_Image' THEN img.Ref_ID
                        ELSE map.Unit_ID
                    END
                ) AS unit_image_count
            FROM
                source_office_image_all AS img
            LEFT JOIN 
                (SELECT DISTINCT Unit_ID, Project_ID 
                FROM source_office_unit_carousel_recommend
                WHERE Unit_ID IN ({unit_placeholders})
                ) AS map
                ON img.Ref_ID = map.Project_ID AND img.Image_Type IN ('Project_Image', 'Cover_Project')
            WHERE
                (img.Image_Type = 'Unit_Image' AND img.Ref_ID IN ({unit_placeholders}))
                OR
                (img.Image_Type IN ('Project_Image', 'Cover_Project') AND img.Ref_ID IN ({project_placeholders}) AND img.Section <> 'Floor Plan')
        ),
        FilteredImages AS (
            SELECT *
            FROM ProcessedImages
            WHERE 
                -- CAROUSEL FILTER (@filter_mode = 1)
                (@filter_mode = 1 AND (
                    (unit_image_count > 0 AND (
                        Image_Type IN ('Unit_Image', 'Cover_Project') 
                        OR (Image_Type = 'Project_Image' AND Category_ID <> 9)))
                    OR
                    (unit_image_count = 0 AND Image_Type <> 'Unit_Image')))
                
                OR
                
                -- TEMPLATE FILTER (@filter_mode = 0)
                (@filter_mode = 0 AND (
                    (unit_image_count > 0 AND Image_Type IN ('Unit_Image', 'Cover_Project'))
                    OR
                    (unit_image_count = 0 AND (
                        Image_Type = 'Cover_Project' 
                        OR (Image_Type = 'Project_Image' AND Category_ID = 9)))))
        )
        SELECT 
            Owning_Unit_ID,
            JSON_ARRAYAGG(JSON_OBJECT(
                'Image_ID', Modified_Image_ID,
                'Image_Name', Image_Name,
                'Category_Order', Category_Order,
                'Display_Order', Display_Order,
                'Image_URL', Modified_Image_URL,
                'Image_Type',  CASE 
                                    WHEN Image_Type <> 'Unit_Image' AND Category_ID = 9 THEN 'Unit_Image' 
                                    ELSE Image_Type 
                                END
            )) AS Image_Set
        FROM FilteredImages
        WHERE Owning_Unit_ID IS NOT NULL
        GROUP BY Owning_Unit_ID
        """
        params = tuple(unit_ids) + tuple(unit_ids) + tuple(project_ids)
        cur.execute(sql_query, params)
        rows = cur.fetchall()
        if rows:
            return {row['Owning_Unit_ID']: row['Image_Set'] for row in rows}
        return None
    finally:
        cur.close()
        conn.close()

def get_project_station(proj_id: int) -> Optional[str]:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""WITH nearest_station AS (
                            SELECT 
                                Project_ID,
                                Route_Code,
                                Line_Code,
                                Station_Code,
                                Station_THName_Display,
                                MTran_ShortName,
                                Station_Latitude,
                                Station_Longitude,
                                Distance,
                                ROW_NUMBER() OVER (
                                    PARTITION BY Project_ID, MTran_ShortName, Station_THName_Display 
                                    ORDER BY Distance ASC
                                ) AS rn
                            FROM source_office_around_station
                            WHERE MTran_ShortName is not null)
                        , distinct_station AS (
                            SELECT Project_ID, Route_Code, Line_Code, Station_Code, Station_THName_Display, MTran_ShortName, Station_Latitude, Station_Longitude, Distance
                            FROM nearest_station
                            WHERE rn = 1
                            AND Project_ID = %s
                            ORDER BY Distance
                            Limit 2)
                        SELECT JSON_ARRAYAGG(JSON_OBJECT('Station_Code', Station_Code
                                                        , 'Station_THName_Display', Station_THName_Display
                                                        , 'Route_Code', Route_Code
                                                        , 'Line_Code', Line_Code
                                                        , 'MTran_ShortName', MTran_ShortName
                                                        , 'Place_Latitude', Station_Latitude
                                                        , 'Place_Longitude', Station_Longitude
                                                        , 'Project_ID', Project_ID
                                                        , 'Distance', Distance)) as Station
                        FROM (
                            SELECT *,
                                ROW_NUMBER() OVER (
                                    PARTITION BY Project_ID ORDER BY Distance ASC
                                ) AS rn2
                            FROM distinct_station) t""", (proj_id,))
        row = cur.fetchone()
        if row and row[0]:
            return row[0]
        return None
    finally:
        cur.close()
        conn.close()

def get_project_express_way(proj_id: int) -> Optional[str]:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""WITH nearest_express_way AS (
                        SELECT Place_ID,
                            Project_ID,
                            Place_Name,
                            Place_Type,
                            Place_Category,
                            Place_Attribute_1,
                            Place_Attribute_2,
                            Place_Latitude,
                            Place_Longitude,
                            Distance,
                            ROW_NUMBER() OVER (PARTITION BY Project_ID, Place_Name, Place_Attribute_2 ORDER BY Distance ASC) AS rn
                        FROM source_office_around_express_way)
                    , distinct_express_way AS (
                        SELECT Project_ID, Place_ID, replace(Place_Name, 'ทางพิเศษ', '') as Place_Name, Place_Type, Place_Category, Place_Attribute_1, Place_Attribute_2, Place_Latitude, Place_Longitude, Distance
                        FROM nearest_express_way
                        WHERE rn = 1
                        AND Project_ID = %s
                        ORDER BY Distance
                        Limit 2)
                    SELECT JSON_ARRAYAGG(JSON_OBJECT('Place_ID', Place_ID
                                                    , 'Place_Type', Place_Type
                                                    , 'Place_Category', Place_Category
                                                    , 'Place_Name', Place_Name
                                                    , 'Place_Attribute_1', Place_Attribute_1
                                                    , 'Place_Attribute_2', concat('(', Place_Attribute_2, ')')
                                                    , 'Place_Latitude', Place_Latitude
                                                    , 'Place_Longitude', Place_Longitude
                                                    , 'Project_ID', Project_ID
                                                    , 'Distance', Distance)) as Express_Way
                    FROM (SELECT *,
                            ROW_NUMBER() OVER (PARTITION BY Project_ID ORDER BY Distance ASC) AS rn2
                        FROM distinct_express_way) t""", (proj_id,))
        row = cur.fetchone()
        if row and row[0]:
            return row[0]
        return None
    finally:
        cur.close()
        conn.close()

def get_project_retail(proj_id: int) -> Optional[str]:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""WITH nearest_retail AS (
                        SELECT Place_ID,
                            Project_ID,
                            Place_Name,
                            Place_Latitude,
                            Place_Longitude,
                            Distance,
                            ROW_NUMBER() OVER (PARTITION BY Project_ID, Place_Name ORDER BY Distance ASC) AS rn
                        FROM source_office_around_retail)
                    , distinct_retail AS (
                        SELECT Project_ID, Place_ID, Place_Name, Place_Latitude, Place_Longitude, Distance
                        FROM nearest_retail
                        WHERE rn = 1
                        AND Project_ID = %s
                        ORDER BY Distance
                        Limit 2)
                    SELECT JSON_ARRAYAGG(JSON_OBJECT('Place_ID', Place_ID
                                                    , 'Place_Name', Place_Name
                                                    , 'Place_Latitude', Place_Latitude
                                                    , 'Place_Longitude', Place_Longitude
                                                    , 'Project_ID', Project_ID
                                                    , 'Distance', Distance)) as Retail_Set
                    FROM (SELECT *,
                            ROW_NUMBER() OVER (PARTITION BY Project_ID ORDER BY Distance ASC) AS rn2
                        FROM distinct_retail) t""", (proj_id,))
        row = cur.fetchone()
        if row and row[0]:
            return row[0]
        return None
    finally:
        cur.close()
        conn.close()

def get_project_hospital(proj_id: int) -> Optional[str]:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""WITH nearest_hospital AS (
                        SELECT Place_ID,
                            Project_ID,
                            Place_Name,
                            Place_Short_Name,
                            Place_Latitude,
                            Place_Longitude,
                            Distance,
                            ROW_NUMBER() OVER (PARTITION BY Project_ID, Place_Name ORDER BY Distance ASC) AS rn
                        FROM source_office_around_hospital)
                    , distinct_hospital AS (
                        SELECT Project_ID, Place_ID, Place_Name, Place_Short_Name, Place_Latitude, Place_Longitude, Distance
                        FROM nearest_hospital
                        WHERE rn = 1
                        AND Project_ID = %s
                        ORDER BY Distance
                        Limit 2)
                    SELECT JSON_ARRAYAGG(JSON_OBJECT('Place_ID', Place_ID
                                                    , 'Place_Name', trim(concat(Place_Short_Name, Place_Name))
                                                    , 'Place_Latitude', Place_Latitude
                                                    , 'Place_Longitude', Place_Longitude
                                                    , 'Project_ID', Project_ID
                                                    , 'Distance', Distance)) as Retail_Set
                    FROM (SELECT *,
                            ROW_NUMBER() OVER (PARTITION BY Project_ID ORDER BY Distance ASC) AS rn2
                        FROM distinct_hospital) t""", (proj_id,))
        row = cur.fetchone()
        if row and row[0]:
            return row[0]
        return None
    finally:
        cur.close()
        conn.close()

def get_project_education(proj_id: int) -> Optional[str]:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""WITH nearest_education AS (
                        SELECT Place_ID,
                            Project_ID,
                            Place_Name,
                            Place_Short_Name,
                            Place_Latitude,
                            Place_Longitude,
                            Distance,
                            ROW_NUMBER() OVER (PARTITION BY Project_ID, Place_Name ORDER BY Distance ASC) AS rn
                        FROM source_office_around_education)
                    , distinct_education AS (
                        SELECT Project_ID, Place_ID, Place_Name, Place_Short_Name, Place_Latitude, Place_Longitude, Distance
                        FROM nearest_education
                        WHERE rn = 1
                        AND Project_ID = %s
                        ORDER BY Distance
                        Limit 2)
                    SELECT JSON_ARRAYAGG(JSON_OBJECT('Place_ID', Place_ID
                                                    , 'Place_Name', trim(concat(Place_Short_Name, Place_Name))
                                                    , 'Place_Latitude', Place_Latitude
                                                    , 'Place_Longitude', Place_Longitude
                                                    , 'Project_ID', Project_ID
                                                    , 'Distance', Distance)) as Education_Set
                    FROM (SELECT *,
                            ROW_NUMBER() OVER (PARTITION BY Project_ID ORDER BY Distance ASC) AS rn2
                        FROM distinct_education) t""", (proj_id,))
        row = cur.fetchone()
        if row and row[0]:
            return row[0]
        return None
    finally:
        cur.close()
        conn.close()

def get_unit_highlight(unit_id: int) -> Optional[str]:
    conn2 = get_db()
    cur2 = conn2.cursor()
    try:
        cur2.execute(
            f"""SELECT
                    *
                FROM source_office_unit_highlight_relationship
                WHERE Unit_ID=%s""",
            (unit_id,)
        )
        row = cur2.fetchone()
        if row:
            return row[1]
        return None
    finally:
        cur2.close()
        conn2.close()

def get_unit_info_card(unit_id: int) -> Optional[str]:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    try:
        cur2.execute(
            f"""SELECT
                    /* a.Unit_ID
                    ,*/ 
                    concat(format(a.Size, 0), ';ตร.ม.') as Unit_Size
                    , if(d.building > 1, b.Building_Name, NULL) as Building_Name
                    , c.Name_EN as Project_Name
                    , e.Highlight as Highlight
                    , e.near_by as Nearby
                    , concat(format(round(a.Rent_Price*a.Size,-2),0), ';บ./ด.') as Rent_Price
                    , concat(format(a.Size,0),';ตร.ม. X ', format(a.Rent_Price,0), ';บ./ตร.ม./ด.') as Rent_Price_Sqm
                    , e.Project_Tag_Used as Project_Tag_Used
                FROM office_unit a
                join office_building b on a.Building_ID = b.Building_ID
                join office_project c on b.Project_ID = c.Project_ID
                left join (select a.Project_ID, count(b.Building_ID) as building
                            from office_project a
                            LEFT JOIN office_building b on a.Project_ID = b.Project_ID
                            where b.Building_Status = '1'
                            and a.Project_Status = '1'
                            group by a.Project_ID) d
                on c.Project_ID = d.Project_ID
                left join source_office_project_carousel_recommend e on c.Project_ID = e.Project_ID
                WHERE a.Unit_ID=%s""",
            (unit_id,)
        )
        row = cur2.fetchone()
        if row:
            return row
        return None
    finally:
        cur2.close()
        conn2.close()

def get_project_convenience_store(proj_id: int) -> Optional[str]:
    conn2 = get_db()
    cur2 = conn2.cursor()
    try:
        cur2.execute(
            f"""WITH nearest_convenience_store AS (
                    SELECT 
                        Project_ID,
                        Store_ID,
                        Store_Type,
                        Branch_Name,
                        Place_Latitude,
                        Place_Longitude,
                        Distance,
                        ROW_NUMBER() OVER (
                            PARTITION BY Project_ID, Store_Type 
                            ORDER BY Distance ASC
                        ) AS rn
                    FROM source_office_around_convenience_store)
                , distinct_convenience_store AS (
                    SELECT Project_ID, Store_ID, Store_Type, Branch_Name, Place_Latitude, Place_Longitude, Distance
                    FROM nearest_convenience_store
                    WHERE rn = 1)
                SELECT Project_ID, JSON_ARRAYAGG(JSON_OBJECT('Place_ID', Store_ID
                                                            , 'Store_Type', Store_Type
                                                            , 'Branch_Name', if(Store_Type = '7-11', concat('7-11 ', Branch_Name), Branch_Name)
                                                            , 'Place_Latitude', Place_Latitude
                                                            , 'Place_Longitude', Place_Longitude
                                                            , 'Distance', Distance)) as Convenience_Store
                FROM (
                    SELECT *,
                        ROW_NUMBER() OVER (
                            PARTITION BY Project_ID ORDER BY Distance ASC
                        ) AS rn2
                    FROM distinct_convenience_store
                    WHERE Project_ID=%s) t
                group by Project_ID""",
            (proj_id,)
        )
        row = cur2.fetchone()
        if row:
            return row[1]
        return None
    finally:
        cur2.close()
        conn2.close()

def get_project_bank(proj_id: int) -> Optional[str]:
    conn2 = get_db()
    cur2 = conn2.cursor()
    try:
        cur2.execute(
            f"""WITH nearest_bank AS (
                    SELECT 
                        Project_ID,
                        Bank_ID,
                        Bank_Name_TH,
                        Bank_Name_EN,
                        Branch_Name,
                        Place_Latitude,
                        Place_Longitude,
                        Distance,
                        ROW_NUMBER() OVER (
                            PARTITION BY Project_ID, Bank_Name_TH 
                            ORDER BY Distance ASC
                        ) AS rn
                    FROM source_office_around_bank)
                , distinct_bank AS (
                    SELECT Project_ID, Bank_ID, Bank_Name_TH, Bank_Name_EN, Branch_Name, Place_Latitude, Place_Longitude, Distance
                    FROM nearest_bank
                    WHERE rn = 1)
                SELECT Project_ID, JSON_ARRAYAGG(JSON_OBJECT('Place_ID', Bank_ID
                                                            , 'Bank_Name_TH', Bank_Name_TH
                                                            , 'Bank_Name_EN', Bank_Name_EN
                                                            , 'Branch_Name', Branch_Name
                                                            , 'Place_Latitude', Place_Latitude
                                                            , 'Place_Longitude', Place_Longitude
                                                            , 'Distance', Distance)) as Bank
                FROM (
                    SELECT *,
                        ROW_NUMBER() OVER (
                            PARTITION BY Project_ID ORDER BY Distance ASC
                        ) AS rn2
                    FROM distinct_bank
                    WHERE Project_ID=%s) t
                WHERE rn2 <= 2
                group by Project_ID""",
            (proj_id,)
        )
        row = cur2.fetchone()
        if row:
            return row[1]
        return None
    finally:
        cur2.close()
        conn2.close()

def get_search_project(Text: str) -> dict:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    text = f"'%{Text}%'"
    try:
        query = f"""
            SELECT 'project' AS location_type, 'โครงการ' AS type, Project_ID as 'code', Name_EN AS name_th, Name_EN AS name_en
            FROM office_project
            WHERE Project_Status = '1'
            AND (Name_TH LIKE {text} OR Name_EN LIKE {text})
            union all
            SELECT 'masstransit' AS location_type, 'สถานีรถไฟฟ้า' AS type, a.Station_Code as 'code', concat(d.MTran_ShortName, ' ', a.Station_THName_Display) AS name_th
                , concat(d.MTran_ShortName, ' ', a.Station_ENName_Display) AS name_en
            FROM mass_transit_station a
            join mass_transit_route b on a.Route_Code = b.Route_Code and b.Route_Timeline = 'Completion'
            join mass_transit_line c on b.Line_Code = c.Line_Code
            join mass_transit d on c.MTrand_ID = d.MTran_ID
            WHERE a.Station_Timeline = 'Completion'
            AND (a.Station_THName_Display LIKE {text} OR a.Station_ENName_Display LIKE {text})
            union all
            SELECT 'tag' AS location_type, 'ย่าน' AS type, Tag_ID as 'code', Tag_Name AS name_th, null AS name_en
            FROM office_project_tag
            WHERE Tag_Name LIKE {text}
            union all
            SELECT 'thailand' AS location_type, 'เขต/อำเภอ' AS type, district_code as 'code', full_name_th AS name_th, full_name_en AS name_en
            FROM thailand_district
            WHERE province_id in (10,11,12,13,73,74)
            AND (full_name_th LIKE {text} OR full_name_en LIKE {text})
            union all
            SELECT 'thailand' AS location_type, 'แขวง/ตำบล' AS type, a.subdistrict_code as 'code', if(b.province_id = 10, a.full_name_th, concat('ตำบล', a.full_name_th)) AS name_th
                , if(b.province_id = 10, a.full_name_en, concat('Tambon ', a.full_name_en)) AS name_en
            FROM thailand_subdistrict a
            join thailand_district b on a.district_id = b.district_code
            WHERE b.province_id in (10,11,12,13,73,74)
            AND (a.full_name_th LIKE {text} OR a.full_name_en LIKE {text})
            """
        
        cur.execute(query)
        row = cur.fetchall()
        if len(row) >= 1:
            return row
        else:
            return None
    finally:
        cur.close()
        conn.close()

def get_all_project_carousel_images(project_ids: list, use_carousel_logic: bool = True) -> dict:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    project_placeholders = ', '.join(['%s'] * len(project_ids))
    
    try:
        cur.execute("SET @use_carousel_logic = %s", (use_carousel_logic,))
        sql_query = f"""
        WITH ProcessedImages AS (
        SELECT
				img.Ref_ID AS Owning_Project_ID,

            CASE
                WHEN @use_carousel_logic = 0 THEN img.Image_URL
                WHEN @use_carousel_logic = 1 AND img.Image_Type = 'Cover_Project'
                THEN REPLACE(
                        REGEXP_REPLACE(img.Image_URL, '-H-\\\\d+', '-H-400'),
                        SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-', 1),
                        LPAD(CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-', 1) AS UNSIGNED) + 2, LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-', 1)), '0')
                    )
                ELSE REGEXP_REPLACE(img.Image_URL, '-H-\\\\d+', '-H-400')
            END AS Modified_Image_URL,

            CASE
                WHEN @use_carousel_logic = 1 AND img.Image_Type = 'Cover_Project' 
                THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-H', 1) AS UNSIGNED) + 2
                ELSE img.Image_ID
            END AS Modified_Image_ID,

            img.Image_Name, img.Category_Order, img.Display_Order, img.Image_Type,
            img.Category_ID
        FROM
            source_office_image_all AS img
        WHERE
            (img.Image_Type IN ('Project_Image', 'Cover_Project') AND img.Ref_ID IN ({project_placeholders}) AND img.Section <> 'Floor Plan')
		AND img.Category_ID <> 9)
        SELECT 
            Owning_Project_ID,
            JSON_ARRAYAGG(JSON_OBJECT(
                'Image_ID', Modified_Image_ID,
                'Image_Name', Image_Name,
                'Category_Order', Category_Order,
                'Display_Order', Display_Order,
                'Image_URL', Modified_Image_URL,
                'Image_Type',   Image_Type
            )) AS Image_Set
        FROM ProcessedImages
        WHERE Owning_Project_ID IS NOT NULL
        GROUP BY Owning_Project_ID
        """
        params = tuple(project_ids)
        cur.execute(sql_query, params)
        rows = cur.fetchall()
        if rows:
            return {row['Owning_Project_ID']: row['Image_Set'] for row in rows}
        return None
    finally:
        cur.close()
        conn.close()

def _get_project_carousel_data(proj_ids: list, total_proj: int, place_use: str) -> dict:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        if place_use == 'carousel_home':   
            cur.execute("""SELECT Project_ID, Project_Name, Project_Tag_Used, Project_Tag_All, near_by, Highlight, Rent_Price, Unit_Count, Project_URL_Tag, Project_Rank
                            FROM source_office_project_carousel_recommend where Project_Rank is not null
                            order by Project_Rank limit %s""", (total_proj,))
        else:
            proj_placeholders = ', '.join(['%s'] * len(proj_ids))
            query = f"""SELECT Project_ID, Project_Name, Project_Tag_Used, Project_Tag_All, near_by, Highlight, Rent_Price, Unit_Count, Project_URL_Tag
                            FROM source_office_project_carousel_recommend where Project_ID in ({proj_placeholders}) order by Last_Updated_Date desc"""
            params = tuple(proj_ids)
            cur.execute(query, params)
        
        rows = cur.fetchall()
        if rows:
            return rows
        return None
    finally:
        cur.close()
        conn.close()

def _get_project_tag_data(total_proj: int, condition: str) -> dict:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute(f"""SELECT Project_ID, Project_Name, near_by, Project_URL_Tag
                        FROM source_office_project_carousel_recommend
                        {condition}
                        order by Unit_Last_Updated_Date desc, Building_Date desc limit %s""", (total_proj,))
        rows = cur.fetchall()
        if rows:
            return rows
        return None
    finally:
        cur.close()
        conn.close()

def _get_project_youtube(Project_ID: int) -> str:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute("""WITH RankedVideos AS (
                        SELECT
                            ID,
                            Project_ID,
                            Youtube_URL,
                            Publish_Date,
                            ROW_NUMBER() OVER(PARTITION BY Project_ID ORDER BY Publish_Date DESC) AS rn
                        FROM office_project_youtube)
                    SELECT Project_ID
                        , Youtube_URL
                    FROM RankedVideos
                    WHERE rn = 1
                    and Project_ID = %s""", (Project_ID,))
        row = cur.fetchone()
        if row:
            return row['Youtube_URL']
        return None
    finally:
        cur.close()
        conn.close()

def _update_project_rank(
    *, project_id, project_rank: int,
) -> dict:
    conn = get_db()
    cur = conn.cursor()
    try:        
        sql = """
            UPDATE office_project
            SET Project_Rank=%s
            WHERE Project_ID=%s
        """
        cur.execute(sql, (project_rank, project_id))
        conn.commit()
    finally:
        cur.close()
        conn.close()
    
    return {
        "project_id": project_id,
        "project_rank": project_rank,
    }
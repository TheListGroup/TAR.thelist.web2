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

def _office_point_calculate(
    actime_start_default, actime_end_default, work_start, work_end, in_unit_condition, 
    btu_per_sqm, eer_btu_per_wh, elec_thb_per_kwh, avg_weekdays_per_month, work_sat,
    avg_saturdays_per_month, work_sun, avg_sundays_per_month, flooring_thb_per_sqm, ceiling_thb_per_sqm,
    elec_usage_kwh_per_sqm_month, elec_default_thb_per_sqm, water_usage_m3_per_sqm_month, water_default_thb_per_sqm, parking_needed,
    parking_fee_default, lease_months, split_capex_per_sqm, split_maint_pct_per_year, lease_years, 
    max_yarn_score, min_yarn_score, yarn_dist_min, yarn_dist_max, location_yarn_regex, 
    road_dist_min, min_road_score, max_road_score, road_dist_max, location_road_regex, 
    station_radius_dist_min, station_radius_dist_max, max_station_radius_score, min_station_radius_score, location_station_regex, 
    minimum_cost, cost_min_k, maximum_cost, cost_max_k, default_score, 
    minimum_size, maximum_size, size_tol_low_pct, size_tol_high_pct, dir_n_score, 
    dir_s_score, dir_e_score, dir_w_score, min_ceiling_clear, 
    bath_pref, pantry_pref, train_decay_k, express_decay_k, fac_bank_pref, 
    fac_cafe_pref, fac_restaurant_pref, fac_foodcourt_pref, fac_market_pref, fac_conv_store_pref, 
    fac_pharmacy_pref, fac_ev_pref, w_price, w_size, w_location,
    w_floor, w_direction, w_ceiling, w_columns, w_bathroom,
    w_pantry_inunit, w_pantry, w_security, w_passenger_lift, w_service_lift, 
    w_age, w_station, w_expressway, w_fac_bank, w_fac_cafe, 
    w_fac_restaurant, w_fac_foodcourt, w_fac_market, w_fac_conv_store, w_fac_pharma_clinic, 
    w_fac_ev
) -> dict:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:        
        cur.execute(f"""
                    WITH all_rentable_entities AS (
                        SELECT
                            vr.Virtual_ID AS Unit_ID, 
                            vr.Virtual_Name AS Unit_NO, 
                            '1' as Unit_Status,
                            vr.Building_ID,
                            vr.Size, 
                            vr.Rent_Price, 
                            vr.Floor,
                            vr.Bathroom_InUnit, vr.Pantry_InUnit,
                            vr.View_N, vr.View_E, vr.View_S, vr.View_W,
                            vr.Ceiling_Dropped, vr.Ceiling_Full_Structure,
                            vr.Column_InUnit,
                            vr.Rent_Deposit, vr.Rent_Advance,
                            vr.AC_Split_Type, 
                            vr.Floor_Replacement, 
                            vr.Ceiling_Replacement,
                            'merge' as Room_Source
                        FROM office_unit_virtual_room vr
                        UNION ALL
                        SELECT
                            u.Unit_ID, 
                            u.Unit_NO, 
                            u.Unit_Status, 
                            u.Building_ID,
                            u.Size, 
                            u.Rent_Price, 
                            u.Floor,
                            u.Bathroom_InUnit, u.Pantry_InUnit,
                            u.View_N, u.View_E, u.View_S, u.View_W,
                            u.Ceiling_Dropped, u.Ceiling_Full_Structure,
                            u.Column_InUnit,
                            u.Rent_Deposit, u.Rent_Advance,
                            u.AC_Split_Type, 
                            u.Floor_Replacement, 
                            u.Ceiling_Replacement,
                            'single' as Room_Source
                        FROM office_unit u
                        WHERE u.Unit_Status = '1'
                    ),
                    expenses_base AS (
                        SELECT
                            u.Unit_ID
                            , u.Room_Source
                            , u.Unit_NO
                            , u.Size
                            , u.Rent_Price
                            , b.Building_ID
                            , b.Building_Name
                            , b.Building_Latitude as Latitude
                            , b.Building_Longitude as Longitude
                            , if(u.AC_Split_Type = 1, 'Split Type', b.AC_System) as AC_System
                            , COALESCE(b.ACTime_Start, '{actime_start_default}') as ACTime_Start
                            , COALESCE(b.ACTime_End, '{actime_end_default}') as ACTime_End
                            , b.AC_OT_Min_Hour
                            , b.AC_OT_Min_Baht
                            , b.AC_OT_Weekday_by_Hour AS AC_OT_Average_Weekday_by_Hour
                            , b.AC_OT_Weekday_by_Area AS AC_OT_Average_Weekday_by_Area
                            , b.AC_OT_Weekend_by_Hour AS AC_OT_Average_Weekend_by_Hour
                            , b.AC_OT_Weekend_by_Area AS AC_OT_Average_Weekend_by_Area
                            , b.Bills_Electricity
                            , b.Bills_Water
                            , b.Parking_Ratio
                            , b.Parking_Fee_Car
                            , u.Floor_Replacement as Floor_Replacement
                            , u.Ceiling_Replacement as Ceiling_Replacement
                            , (GREATEST(TIME_TO_SEC(COALESCE(b.ACTime_Start, '{actime_start_default}')) - TIME_TO_SEC('{work_start}'), 0) 
                                + GREATEST(TIME_TO_SEC('{work_end}') - TIME_TO_SEC(COALESCE(b.ACTime_End, '{actime_end_default}')), 0)) AS Wkday_OT_Seconds
                            , if({work_sat} = 0 and {work_sun} = 0
                                , 0
                                , GREATEST(TIME_TO_SEC('{work_end}') - TIME_TO_SEC('{work_start}'), 0)) AS Wkend_Work_Seconds
                        FROM all_rentable_entities u
                        JOIN office_building b ON b.Building_ID = u.Building_ID
                        {in_unit_condition}),
                    calc AS (
                        SELECT
                            Unit_ID
                            , Room_Source
                            , Unit_NO
                            , Size
                            , Rent_Price
                            , Building_ID
                            , Building_Name
                            , Latitude
                            , Longitude
                            , AC_System
                            , ACTime_Start
                            , ACTime_End
                            , AC_OT_Min_Hour
                            , AC_OT_Min_Baht
                            , AC_OT_Average_Weekday_by_Hour
                            , AC_OT_Average_Weekday_by_Area
                            , AC_OT_Average_Weekend_by_Hour
                            , AC_OT_Average_Weekend_by_Area
                            , Wkday_OT_Seconds
                            , Wkend_Work_Seconds
                            , Bills_Electricity
                            , Bills_Water
                            , Parking_Ratio
                            , Parking_Fee_Car
                            , Floor_Replacement
                            , Ceiling_Replacement
                            , (Wkday_OT_Seconds / 3600.0) AS Wkday_Working_OT_Hours
                            , (Wkend_Work_Seconds / 3600.0) AS Wkend_Working_OT_Hours
                            , CASE WHEN Wkday_OT_Seconds > 0
                                THEN GREATEST(CEIL(Wkday_OT_Seconds / 3600.0), COALESCE(AC_OT_Min_Hour,1))
                                ELSE 0 END AS Wkday_Billable_Hours
                            , CASE WHEN Wkend_Work_Seconds > 0
                                THEN GREATEST(CEIL(Wkend_Work_Seconds / 3600.0), COALESCE(AC_OT_Min_Hour,1))
                                ELSE 0 END AS Wkend_Billable_Hours
                            , (Size * {btu_per_sqm}) AS Split_Required_BTU
                            , (Size * {btu_per_sqm}) / ({eer_btu_per_wh} * 1000.0) AS Split_kW
                            , ((Size * {btu_per_sqm}) / ({eer_btu_per_wh} * 1000.0)) * COALESCE(NULLIF(Bills_Electricity,0), {elec_thb_per_kwh}) AS Split_THB_per_Hour
                            , (TIME_TO_SEC('{work_end}') - TIME_TO_SEC('{work_start}')) / 3600.0 AS WorkWindowHours
                        FROM expenses_base),
                    perday AS (
                        SELECT
                            c.*
                            , CASE WHEN c.AC_System='Split Type' OR c.Wkday_Billable_Hours=0 THEN 0
                                ELSE GREATEST(
                                        COALESCE(c.AC_OT_Average_Weekday_by_Hour,0)*c.Wkday_Billable_Hours,
                                        COALESCE(c.AC_OT_Average_Weekday_by_Area,0)*c.Size*c.Wkday_Billable_Hours,
                                        COALESCE(c.AC_OT_Min_Baht,0))
                            END AS Weekday_OT_Cost_Per_Day
                            , CASE WHEN c.AC_System='Split Type' THEN 0
                                ELSE GREATEST(
                                        COALESCE(c.AC_OT_Average_Weekend_by_Hour,0)*c.Wkend_Billable_Hours,
                                        COALESCE(c.AC_OT_Average_Weekend_by_Area,0)*c.Size*c.Wkend_Billable_Hours,
                                        COALESCE(c.AC_OT_Min_Baht,0))
                            END AS Weekend_OT_Cost_Per_Day
                            , CASE WHEN c.AC_System='Split Type' THEN 0
                                ELSE COALESCE(c.AC_OT_Average_Weekday_by_Hour,0)*c.Wkday_Billable_Hours END AS Weekday_Hour_Method_Cost
                            , CASE WHEN c.AC_System='Split Type' THEN 0
                                ELSE COALESCE(c.AC_OT_Average_Weekend_by_Hour,0)*c.Wkend_Billable_Hours END AS Weekend_Hour_Method_Cost
                            , CASE WHEN c.AC_System='Split Type' THEN 0
                                ELSE COALESCE(c.AC_OT_Average_Weekday_by_Area,0)*c.Size*c.Wkday_Billable_Hours END AS Weekday_Area_Method_Cost
                            , CASE WHEN c.AC_System='Split Type' THEN 0
                                ELSE COALESCE(c.AC_OT_Average_Weekend_by_Area,0)*c.Size*c.Wkend_Billable_Hours END AS Weekend_Area_Method_Cost
                        FROM calc c),
                    monthly AS (
                        SELECT
                            p.*
                            , (p.Weekday_OT_Cost_Per_Day*{avg_weekdays_per_month} 
                                + p.Weekend_OT_Cost_Per_Day*({work_sat}*{avg_saturdays_per_month}+{work_sun}*{avg_sundays_per_month})) AS Central_OT_Cost_Baht_Month
                            , (p.Split_THB_per_Hour * (p.Wkday_Working_OT_Hours*{avg_weekdays_per_month} 
                                + p.WorkWindowHours*({work_sat}*{avg_saturdays_per_month}+{work_sun}*{avg_sundays_per_month}))) AS Split_Energy_Baht_Month
                        FROM perday p),
                    nonac AS (
                        SELECT
                            m.*
                            , if(m.Floor_Replacement = 1, {flooring_thb_per_sqm} * m.Size, 0) AS Flooring_Cost_OneTime_THB
                            , if(m.Ceiling_Replacement = 1, {ceiling_thb_per_sqm} * m.Size, 0) AS Ceiling_Cost_OneTime_THB
                            , CASE WHEN m.Bills_Electricity IS NOT NULL
                                THEN m.Bills_Electricity*{elec_usage_kwh_per_sqm_month}*m.Size
                                ELSE {elec_default_thb_per_sqm}*m.Size END AS Elec_Cost_Monthly_THB
                            , CASE WHEN m.Bills_Water IS NOT NULL
                                THEN m.Bills_Water*{water_usage_m3_per_sqm_month}*m.Size
                                ELSE {water_default_thb_per_sqm}*m.Size END AS Water_Cost_Monthly_THB
                            , CAST(REGEXP_SUBSTR(COALESCE(m.Parking_Ratio,''),'[0-9]+$') AS UNSIGNED) AS Sqm_Per_Free_Slot
                            , COALESCE(FLOOR(m.Size / NULLIF(CAST(REGEXP_SUBSTR(COALESCE(m.Parking_Ratio,''),'[0-9]+$') AS UNSIGNED),0)),0) AS Parking_Free_Slots
                            , GREATEST({parking_needed}-COALESCE(FLOOR(m.Size / NULLIF(CAST(REGEXP_SUBSTR(COALESCE(m.Parking_Ratio,''),'[0-9]+$') AS UNSIGNED),0)),0),0) AS Parking_Extra_Slots
                            , COALESCE(m.Parking_Fee_Car,{parking_fee_default}) AS Parking_Rate_THB_per_Month
                            , GREATEST({parking_needed}-COALESCE(FLOOR(m.Size / NULLIF(CAST(REGEXP_SUBSTR(COALESCE(m.Parking_Ratio,''),'[0-9]+$') AS UNSIGNED),0)),0),0)
                                * COALESCE(m.Parking_Fee_Car,{parking_fee_default}) AS Parking_Cost_Monthly_THB
                            , (COALESCE(m.Rent_Price,0)*m.Size) AS Rent_Monthly_THB
                            , (COALESCE(m.Rent_Price,0)*m.Size)*{lease_months} AS Rent_Total_Lease_THB
                            , (CASE WHEN m.Bills_Electricity IS NOT NULL
                                    THEN m.Bills_Electricity*{elec_usage_kwh_per_sqm_month}*m.Size
                                    ELSE {elec_default_thb_per_sqm}*m.Size END
                                + CASE WHEN m.Bills_Water IS NOT NULL
                                    THEN m.Bills_Water*{water_usage_m3_per_sqm_month}*m.Size
                                    ELSE {water_default_thb_per_sqm}*m.Size END
                                + (GREATEST({parking_needed}-
                                    COALESCE(FLOOR(m.Size / NULLIF(CAST(REGEXP_SUBSTR(COALESCE(m.Parking_Ratio,''),'[0-9]+$') AS UNSIGNED),0)),0),0)
                                    * COALESCE(m.Parking_Fee_Car,{parking_fee_default}))
                                + (COALESCE(m.Rent_Price,0)*m.Size)) AS Opex_Monthly_Subtotal_THB
                        FROM monthly m),
                    expenses AS (
                        SELECT
                            n.Unit_ID
                            , n.Room_Source
                            , n.Unit_NO
                            , n.Building_ID
                            , n.Building_Name
                            , n.Latitude
                            , n.Longitude
                            , n.Size
                            , n.Rent_Price
                            , n.Bills_Electricity
                            , n.Bills_Water
                            , n.ACTime_Start
                            , n.ACTime_End
                            , n.AC_OT_Average_Weekday_by_Hour
                            , n.AC_OT_Average_Weekday_by_Area
                            , n.AC_OT_Average_Weekend_by_Hour
                            , n.AC_OT_Average_Weekend_by_Area
                            , n.AC_OT_Min_Hour
                            , n.AC_OT_Min_Baht
                            , n.AC_System
                            , n.Wkday_Working_OT_Hours
                            , ROUND(n.Wkday_Billable_Hours,0) AS Wkday_Billable_Hours
                            , n.Wkend_Working_OT_Hours
                            , ROUND(n.Wkend_Billable_Hours,0) AS Wkend_Billable_Hours
                            , ROUND(n.Weekday_Hour_Method_Cost,0) AS `Weekday ใช้แบบ Hour`
                            , ROUND(n.Weekend_Hour_Method_Cost,0) AS `Weekend ใช้แบบ Hour`
                            , ROUND(n.Weekday_Area_Method_Cost,0) AS `Weekday ใช้แบบ Area`
                            , ROUND(n.Weekend_Area_Method_Cost,0) AS `Weekend ใช้แบบ Area`
                            , ROUND(n.Weekday_OT_Cost_Per_Day,0) AS Weekday_OT_Cost_Per_Day
                            , ROUND(n.Weekend_OT_Cost_Per_Day,0) AS Weekend_OT_Cost_Per_Day
                            , ROUND(n.Central_OT_Cost_Baht_Month,0) AS Central_OT_Cost_Baht_Month
                            , ROUND(n.Central_OT_Cost_Baht_Month*{lease_months},0) AS Total_3Y__Central_OT_Only
                            , ROUND(n.Split_THB_per_Hour,0) AS Split_THB_per_Hour
                            , ROUND(n.Split_Energy_Baht_Month,0) AS Split_Energy_Baht_Month
                            , ROUND(n.Split_Energy_Baht_Month*{lease_months},0) AS Split_Energy_Total
                            , ROUND(n.Size*{split_capex_per_sqm},0) AS Split_CAPEX_Total
                            , ROUND((n.Size*{split_capex_per_sqm})*{split_maint_pct_per_year}*{lease_years},0) AS Split_Maint_Total
                            , ROUND((n.Size*{split_capex_per_sqm})
                                + (n.Size*{split_capex_per_sqm})*{split_maint_pct_per_year}*{lease_years}
                                + (n.Split_Energy_Baht_Month*{lease_months}),0) AS Total_3Y__Split_Own_AC
                            , ROUND(n.Flooring_Cost_OneTime_THB,0) AS Flooring_Cost_OneTime_THB
                            , ROUND(n.Ceiling_Cost_OneTime_THB,0) AS Ceiling_Cost_OneTime_THB
                            , ROUND(n.Elec_Cost_Monthly_THB,0) AS Elec_Cost_Monthly_THB
                            , ROUND(n.Water_Cost_Monthly_THB,0) AS Water_Cost_Monthly_THB
                            , ROUND(n.Parking_Free_Slots,0) AS Parking_Free_Slots
                            , ROUND(n.Parking_Extra_Slots,0) AS Parking_Extra_Slots
                            , ROUND(n.Parking_Rate_THB_per_Month,0) AS Parking_Rate_THB_per_Month
                            , ROUND(n.Parking_Cost_Monthly_THB,0) AS Parking_Cost_Monthly_THB
                            , ROUND(n.Rent_Monthly_THB,0) AS Rent_Monthly_THB
                            , ROUND(n.Rent_Total_Lease_THB,0) AS Rent_Total_Lease_THB
                            , ROUND(n.Opex_Monthly_Subtotal_THB,0) AS Opex_Monthly_Subtotal_THB
                            , ROUND((n.Central_OT_Cost_Baht_Month + n.Opex_Monthly_Subtotal_THB)*{lease_months} + n.Flooring_Cost_OneTime_THB 
                                + n.Ceiling_Cost_OneTime_THB,0) AS Total_3Y__Central_With_NonAC
                            , ROUND(((n.Size*{split_capex_per_sqm})
                                + (n.Size*{split_capex_per_sqm})*{split_maint_pct_per_year}*{lease_years}
                                + (n.Split_Energy_Baht_Month*{lease_months}))
                                + (n.Opex_Monthly_Subtotal_THB*{lease_months})
                                + n.Flooring_Cost_OneTime_THB + n.Ceiling_Cost_OneTime_THB,0) AS Total_3Y__Split_Own_AC_Plus_NonAC
                            , ROUND(((n.Central_OT_Cost_Baht_Month + n.Opex_Monthly_Subtotal_THB)*{lease_months} + n.Flooring_Cost_OneTime_THB 
                                + n.Ceiling_Cost_OneTime_THB)/{lease_months},0) AS Monthly_Avg_All__Central_With_NonAC
                            , ROUND((((n.Size*{split_capex_per_sqm})
                                + (n.Size*{split_capex_per_sqm})*{split_maint_pct_per_year}*{lease_years}
                                + (n.Split_Energy_Baht_Month*{lease_months}))
                                + (n.Opex_Monthly_Subtotal_THB*{lease_months})
                                + n.Flooring_Cost_OneTime_THB + n.Ceiling_Cost_OneTime_THB)/{lease_months},0) AS Monthly_Avg_All__Split_Own_AC_Plus_NonAC
                        FROM nonac n
                        ORDER BY Total_3Y__Central_With_NonAC DESC, Total_3Y__Split_Own_AC_Plus_NonAC DESC, n.Building_Name, n.Unit_NO),
                    yarn AS (
                        with yarn_rank as (
                            select *, ROW_NUMBER() OVER (PARTITION BY Building_ID ORDER BY yarn_score DESC) as rn
                            from (
                                    SELECT 
                                        b.Building_ID, c.Place_Name_TH, b.Building_Latitude, b.Building_Longitude,
                                        CASE 
                                            WHEN ST_Contains(ST_SRID(c.Place_Polygon, 4326), ST_GeomFromText(CONCAT('POINT(', b.Building_Latitude, ' ', b.Building_Longitude, ')'), 4326)) 
                                            THEN 'INSIDE' 
                                            ELSE 'OUTSIDE' 
                                        END as location_status,
                                        round(ST_Distance(
                                                ST_GeomFromText(CONCAT('POINT(', b.Building_Latitude, ' ', b.Building_Longitude, ')'), 4326), 
                                                ST_ExteriorRing(ST_SRID(c.Place_Polygon, 4326))
                                            ),2) as distance_edge,
                                        CASE 
                                            WHEN ST_Contains(ST_SRID(c.Place_Polygon, 4326), ST_GeomFromText(CONCAT('POINT(', b.Building_Latitude, ' ', b.Building_Longitude, ')'), 4326)) 
                                            THEN {max_yarn_score}
                                            ELSE round(GREATEST({min_yarn_score}
                                                    , LEAST({max_yarn_score}
                                                        , {max_yarn_score} + ((round(ST_Distance(
                                                                                    ST_GeomFromText(CONCAT('POINT(', b.Building_Latitude, ' ', b.Building_Longitude, ')'), 4326), 
                                                                                    ST_ExteriorRing(ST_SRID(c.Place_Polygon, 4326))
                                                                                ),2) - {yarn_dist_min}) * ({min_yarn_score} - {max_yarn_score}) / ({yarn_dist_max} - {yarn_dist_min})))),2)
                                        END as yarn_score
                                    FROM office_building b
                                    cross join real_office_yarn c
                                    where b.Building_Status = '1'
                                    and b.Building_Latitude is not null
                                    and b.Building_Longitude is not null
                                    {location_yarn_regex}
                                    HAVING (location_status = 'OUTSIDE' and distance_edge <= {yarn_dist_max})
                                    OR (location_status = 'INSIDE')) aaa)
                        select * from yarn_rank where rn = 1),
                    road AS (
                        with road_rank as (
                            select *, ROW_NUMBER() OVER (PARTITION BY Building_ID ORDER BY road_score DESC) as rn
                            from (
                                SELECT 
                                    b.Building_ID, b.Building_Name, b.Building_Latitude, b.Building_Longitude, c.Road_Name_TH,
                                    round(ST_Distance(
                                        ST_GeomFromText(CONCAT('POINT(', b.Building_Latitude, ' ', b.Building_Longitude, ')'), 4326), 
                                        ST_SRID(c.Road_Line, 4326)
                                    ),2) as distance_meters,
                                    CASE 
                                        WHEN ST_Distance(
                                            ST_GeomFromText(CONCAT('POINT(', b.Building_Latitude, ' ', b.Building_Longitude, ')'), 4326), 
                                            ST_SRID(c.Road_Line, 4326)
                                        ) <= {road_dist_min} THEN 'ON ROAD'
                                        ELSE 'OFF ROAD'
                                    END as road_status,
                                    round(GREATEST({min_road_score}
                                        , LEAST({max_road_score}
                                            , {max_road_score} + ((round(ST_Distance(
                                                            ST_GeomFromText(CONCAT('POINT(', b.Building_Latitude, ' ', b.Building_Longitude, ')'), 4326), 
                                                            ST_SRID(c.Road_Line, 4326)
                                                        ),2) - {road_dist_min}) * ({min_road_score} - {max_road_score}) / ({road_dist_max} - {road_dist_min})))),2) as road_score
                                FROM office_building b
                                cross join real_office_road c
                                where b.Building_Status = '1'
                                and b.Building_Latitude is not null
                                and b.Building_Longitude is not null
                                {location_road_regex}
                                HAVING distance_meters <= {road_dist_max}) aaa)
                        select * from road_rank where rn = 1),
                    station_radius AS (
                        WITH radius_rank AS (
                            select *, ROW_NUMBER() OVER (PARTITION BY Building_ID ORDER BY station_radius_score DESC) as rn
                            from (
                                    SELECT 
                                        radius.*,
                                        CASE 
                                            WHEN distance_meters <= {station_radius_dist_min} THEN 1
                                            WHEN distance_meters > {station_radius_dist_max} THEN 0
                                            ELSE ROUND({max_station_radius_score} + ((distance_meters - {station_radius_dist_min}) 
                                                * ({min_station_radius_score} - {max_station_radius_score}) / ({station_radius_dist_max} - {station_radius_dist_min})), 2)
                                        END AS station_radius_score
                                    FROM (
                                        SELECT 
                                            b.Building_ID,
                                            b.Building_Name,
                                            b.Building_Latitude,
                                            b.Building_Longitude,
                                            mtsmr.Station_Code,
                                            mtsmr.Station_THName_Display,
                                            mtsmr.Station_Latitude,
                                            mtsmr.Station_Longitude,
                                            ST_Distance_Sphere(
                                                ST_GeomFromText(CONCAT('POINT(', b.Building_Longitude, ' ', b.Building_Latitude, ')')),
                                                ST_GeomFromText(CONCAT('POINT(', mtsmr.Station_Longitude , ' ', mtsmr.Station_Latitude, ')'))
                                            ) AS distance_meters
                                        FROM mass_transit_station_match_route mtsmr
                                        CROSS JOIN (
                                            SELECT * FROM office_building 
                                            WHERE Building_Status = '1' 
                                            AND Building_Latitude IS NOT NULL 
                                            AND Building_Longitude IS NOT NULL
                                        ) b
                                        WHERE mtsmr.Station_Timeline IN ('Completion', 'Planning')
                                        {location_station_regex}) AS radius
                                    HAVING distance_meters <= {station_radius_dist_max}) aaa)
                            select * from radius_rank where rn = 1),
                    station_dist AS (
                        SELECT
                            OAS.Project_ID,
                            MIN(OAS.Distance) AS Distance_from_nearest_station
                        FROM source_office_around_station OAS
                        GROUP BY OAS.Project_ID),
                    express_dist AS (
                        SELECT
                            OAE.Project_ID,
                            MIN(OAE.Distance) AS Distance_from_nearest_express_way
                        FROM source_office_around_express_way OAE
                        GROUP BY OAE.Project_ID),
                    base AS (
                        SELECT
                            u.*,
                            ob.Building_Name,
                            ob.Building_Latitude,
                            ob.Building_Longitude,
                            ob.Passenger_Lift AS Building_Passenger_Lift, 
                            ob.Service_Lift AS Building_Service_Lift,
                            ob.Built_Complete, 
                            ob.Last_Renovate,
                            op.Project_ID,
                            op.F_Common_Pantry, 
                            op.Security_Type, 
                            op.F_Services_Bank, 
                            op.F_Food_Cafe, 
                            op.F_Food_Restaurant,
                            op.F_Food_Foodcourt, 
                            op.F_Food_Market, 
                            op.F_Retail_Conv_Store, 
                            op.F_Services_Pharma_Clinic, 
                            op.F_Others_EV,
                            sd.Distance_from_nearest_station, 
                            ed.Distance_from_nearest_express_way,
                            NULLIF(REGEXP_SUBSTR(u.Floor, '[0-9]+'), '') AS floor_num_str,
                            yb.Place_Name_TH as Yarn_Name,
                            yb.location_status as In_or_Out,
                            round(yb.distance_edge,2) as Yarn_Distance_Meters,
                            ifnuLL(yb.yarn_score,0) as Yarn_Score,
                            rd.Road_Name_TH as Road_Name_TH,
                            round(rd.distance_meters,2) as Road_Distance_Meters,
                            ifnuLL(rd.road_score,0) as Road_Score,
                            sr.Station_THName_Display as Station_Name,
                            round(sr.distance_meters,2) as Station_Radius_Distance_Meters,
                            ifnuLL(sr.station_radius_score,0) as Station_Radius_Score
                        FROM all_rentable_entities u
                        JOIN office_building ob ON u.Building_ID = ob.Building_ID
                        LEFT JOIN office_project op ON ob.Project_ID = op.Project_ID
                        LEFT JOIN station_dist sd ON op.Project_ID = sd.Project_ID
                        LEFT JOIN express_dist ed ON op.Project_ID = ed.Project_ID
                        LEFT JOIN yarn yb ON ob.Building_ID = yb.Building_ID
                        LEFT JOIN road rd ON ob.Building_ID = rd.Building_ID
                        LEFT JOIN station_radius sr ON ob.Building_ID = sr.Building_ID
                        {in_unit_condition}),
                    floor_stats AS (
                        SELECT
                            b.*,
                            CAST(floor_num_str AS UNSIGNED) AS floor_num,
                            MIN(CAST(floor_num_str AS UNSIGNED)) OVER () AS floor_min_overall,
                            MAX(CAST(floor_num_str AS UNSIGNED)) OVER () AS floor_max_overall,
                            CAST(b.Security_Type AS UNSIGNED) AS security_idx,
                            MAX(CAST(b.Security_Type AS UNSIGNED)) OVER () AS security_max_overall,
                            CASE 
                                WHEN b.Built_Complete IS NULL AND b.Last_Renovate IS NULL THEN NULL 
                                WHEN b.Built_Complete IS NULL THEN TO_DAYS(b.Last_Renovate) 
                                WHEN b.Last_Renovate IS NULL THEN TO_DAYS(b.Built_Complete) 
                                WHEN b.Last_Renovate > b.Built_Complete THEN TO_DAYS(b.Last_Renovate) 
                                ELSE TO_DAYS(b.Built_Complete) 
                            END AS build_date_days,
                            MIN(CASE 
                                    WHEN b.Built_Complete IS NULL AND b.Last_Renovate IS NULL THEN NULL 
                                    WHEN b.Built_Complete IS NULL THEN TO_DAYS(b.Last_Renovate) 
                                    WHEN b.Last_Renovate IS NULL THEN TO_DAYS(b.Built_Complete) 
                                    WHEN b.Last_Renovate > b.Built_Complete THEN TO_DAYS(b.Last_Renovate) 
                                    ELSE TO_DAYS(b.Built_Complete) 
                                END) OVER () AS build_date_min_overall,
                            MAX(CASE 
                                    WHEN b.Built_Complete IS NULL AND b.Last_Renovate IS NULL THEN NULL 
                                    WHEN b.Built_Complete IS NULL THEN TO_DAYS(b.Last_Renovate) 
                                    WHEN b.Last_Renovate IS NULL THEN TO_DAYS(b.Built_Complete) 
                                    WHEN b.Last_Renovate > b.Built_Complete THEN TO_DAYS(b.Last_Renovate) 
                                    ELSE TO_DAYS(b.Built_Complete) 
                                END) OVER () AS build_date_max_overall,
                            MAX(b.Building_Passenger_Lift) OVER () AS passenger_lift_max_overall,
                            MAX(b.Building_Service_Lift)   OVER () AS service_lift_max_overall
                        FROM base b),
                    scored AS (
                        SELECT
                            f.*,
                            CASE 
                                WHEN LEAST(
                                    COALESCE(b.Monthly_Avg_All__Central_With_NonAC, b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC),
                                    COALESCE(b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC, b.Monthly_Avg_All__Central_With_NonAC)) IS NULL THEN 0.0 
                                WHEN LEAST(
                                    COALESCE(b.Monthly_Avg_All__Central_With_NonAC, b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC),
                                    COALESCE(b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC, b.Monthly_Avg_All__Central_With_NonAC)) < {minimum_cost} 
                                    THEN 0.5 * EXP( -{cost_min_k} * 
                                        ({minimum_cost} - LEAST(
                                                            COALESCE(b.Monthly_Avg_All__Central_With_NonAC, b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC),
                                                            COALESCE(b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC, b.Monthly_Avg_All__Central_With_NonAC))) )
                                WHEN LEAST(
                                    COALESCE(b.Monthly_Avg_All__Central_With_NonAC, b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC),
                                    COALESCE(b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC, b.Monthly_Avg_All__Central_With_NonAC)) > {maximum_cost} 
                                    THEN 0.5 * EXP( -{cost_max_k} * 
                                        (LEAST(
                                            COALESCE(b.Monthly_Avg_All__Central_With_NonAC, b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC),
                                            COALESCE(b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC, b.Monthly_Avg_All__Central_With_NonAC)) - {maximum_cost}) )
                                ELSE 1.0 - ( (LEAST(
                                            COALESCE(b.Monthly_Avg_All__Central_With_NonAC, b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC),
                                            COALESCE(b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC, b.Monthly_Avg_All__Central_With_NonAC)) - {minimum_cost}) * 
                                    0.5 / ({maximum_cost} - {minimum_cost}) )
                            END AS cost_score,
                            CASE 
                                WHEN f.Size IS NULL 
                                    THEN {default_score} 
                                WHEN f.Size BETWEEN {minimum_size} AND {maximum_size} 
                                    THEN 1.0 
                                WHEN f.Size < {minimum_size} 
                                    THEN 1.0 / (1.0 + (({minimum_size} - f.Size) / NULLIF({minimum_size} * {size_tol_low_pct}, 0))) 
                                ELSE 1.0 / (1.0 + ((f.Size - {maximum_size}) / NULLIF({maximum_size} * {size_tol_high_pct}, 0))) 
                            END AS size_score,
                            greatest(ifnull(f.Yarn_Score,0), ifnull(f.Road_Score,0), ifnull(f.Station_Radius_Score,0)) as location_score,
                            CASE 
                                WHEN f.floor_num IS NULL OR f.floor_min_overall IS NULL OR f.floor_max_overall IS NULL OR f.floor_min_overall = f.floor_max_overall 
                                    THEN {default_score} 
                                ELSE (f.floor_num - f.floor_min_overall) / NULLIF(f.floor_max_overall - f.floor_min_overall, 0) 
                            END AS floor_score,
                            CASE 
                                WHEN f.View_N IS NULL AND f.View_E IS NULL AND f.View_S IS NULL AND f.View_W IS NULL 
                                    THEN {default_score} 
                                ELSE LEAST(IF(f.View_N = 1, {dir_n_score}, 1.0), IF(f.View_S = 1, {dir_s_score}, 1.0), IF(f.View_E = 1, {dir_e_score}, 1.0), IF(f.View_W = 1, {dir_w_score}, 1.0)) 
                            END AS direction_score,
                            CASE 
                                WHEN COALESCE(f.Ceiling_Dropped, f.Ceiling_Full_Structure) IS NULL 
                                    THEN {default_score} 
                                WHEN COALESCE(f.Ceiling_Dropped, f.Ceiling_Full_Structure) >= {min_ceiling_clear} 
                                    THEN 1.0 ELSE 1.0 / (1.0 + ({min_ceiling_clear} - COALESCE(f.Ceiling_Dropped, f.Ceiling_Full_Structure))) 
                                END AS ceiling_score,
                            CASE 
                                WHEN f.Column_InUnit IS NULL 
                                    THEN {default_score} 
                                WHEN f.Column_InUnit = 0 
                                    THEN 1.0 
                                ELSE 0.25  
                            END AS columns_score,
                            CASE 
                                WHEN {bath_pref} = 1 
                                    THEN {default_score} 
                                WHEN {bath_pref} = 0 
                                    THEN 
                                        CASE 
                                            WHEN f.Bathroom_InUnit IS NULL 
                                                THEN {default_score} 
                                            WHEN f.Bathroom_InUnit = 1 
                                                THEN 0.0 
                                            ELSE 1.0 
                                        END 
                                WHEN {bath_pref} = 2 
                                    THEN 
                                        CASE 
                                            WHEN f.Bathroom_InUnit IS NULL 
                                                THEN {default_score} 
                                            WHEN f.Bathroom_InUnit = 1 
                                                THEN 1.0 
                                            ELSE 0.2 
                                        END 
                                ELSE {default_score} 
                            END AS bathroom_score,
                            CASE 
                                WHEN {pantry_pref} = 0 
                                    THEN {default_score} 
                                WHEN {pantry_pref} = 1 
                                    THEN 
                                        CASE 
                                            WHEN f.Pantry_InUnit IS NULL 
                                                THEN {default_score} 
                                            WHEN f.Pantry_InUnit = 1 
                                                THEN 1.0 
                                            ELSE 0.2 
                                        END 
                                WHEN {pantry_pref} = 2 
                                    THEN 
                                        CASE 
                                            WHEN f.Pantry_InUnit = 1 
                                                THEN 1.0 
                                            ELSE 0.0 
                                        END 
                                ELSE {default_score} 
                            END AS pantry_score,
                            /*CASE 
                                WHEN f.Rent_Deposit IS NULL 
                                    THEN p.rent_deposit_score_std 
                                WHEN f.Rent_Deposit <  p.rent_deposit_std 
                                    THEN p.rent_deposit_score_low 
                                WHEN f.Rent_Deposit =  p.rent_deposit_std 
                                    THEN p.rent_deposit_score_std 
                                WHEN f.Rent_Deposit >  p.rent_deposit_std 
                                    THEN p.rent_deposit_score_high 
                                ELSE {default_score} 
                            END AS deposit_score,
                            CASE 
                                WHEN f.Rent_Advance IS NULL 
                                    THEN p.rent_advance_score_std 
                                WHEN f.Rent_Advance <  p.rent_advance_std 
                                    THEN p.rent_advance_score_low 
                                WHEN f.Rent_Advance =  p.rent_advance_std 
                                    THEN p.rent_advance_score_std 
                                WHEN f.Rent_Advance >  p.rent_advance_std 
                                    THEN p.rent_advance_score_high 
                                ELSE {default_score} 
                            END AS advance_score,*/
                            CASE 
                                WHEN f.F_Common_Pantry IS NULL 
                                    THEN {default_score} 
                                WHEN f.F_Common_Pantry = 1 
                                    THEN 1.0 
                                ELSE {default_score} 
                            END AS common_pantry_score,
                            CASE   
                                WHEN f.security_idx IS NULL OR f.security_max_overall IS NULL OR f.security_max_overall = 0 
                                    THEN {default_score} 
                                ELSE f.security_idx / f.security_max_overall 
                            END AS security_score,
                            CASE 
                                WHEN f.Building_Passenger_Lift IS NULL OR f.passenger_lift_max_overall IS NULL OR f.passenger_lift_max_overall = 0 
                                    THEN {default_score} 
                                ELSE f.Building_Passenger_Lift / f.passenger_lift_max_overall 
                            END AS passenger_lift_score,
                            CASE 
                                WHEN f.Building_Service_Lift IS NULL OR f.service_lift_max_overall IS NULL OR f.service_lift_max_overall = 0 
                                    THEN {default_score} 
                                ELSE f.Building_Service_Lift / f.service_lift_max_overall 
                            END AS service_lift_score,
                            CASE 
                                WHEN f.build_date_days IS NULL OR f.build_date_min_overall IS NULL OR f.build_date_max_overall IS NULL OR f.build_date_max_overall = f.build_date_min_overall 
                                    THEN {default_score} 
                                ELSE (f.build_date_days - f.build_date_min_overall) / NULLIF(f.build_date_max_overall - f.build_date_min_overall, 0) 
                            END AS building_age_score,
                            CASE 
                                WHEN f.Distance_from_nearest_station IS NULL 
                                    THEN 0.0 
                                WHEN f.Distance_from_nearest_station <= 0.2 
                                    THEN 1.0 
                                ELSE EXP( - {train_decay_k} * (f.Distance_from_nearest_station - 0.2) ) 
                            END AS train_station_score,
                            CASE 
                                WHEN f.Distance_from_nearest_express_way IS NULL 
                                    THEN 0.0 
                                WHEN f.Distance_from_nearest_express_way <= 1.0 
                                    THEN 1.0 
                                ELSE EXP( - {express_decay_k} * (f.Distance_from_nearest_express_way - 1.0) ) 
                            END AS express_way_score,
                            CASE 
                                WHEN {fac_bank_pref}=0 
                                    THEN {default_score}
                                WHEN {fac_bank_pref}=1 
                                    THEN (
                                            CASE 
                                                WHEN f.F_Services_Bank IS NULL 
                                                    THEN {default_score}
                                                WHEN f.F_Services_Bank=1 
                                                    THEN 0.75 
                                                ELSE 0.25 
                                            END) 
                                ELSE (
                                        CASE 
                                            WHEN f.F_Services_Bank IS NULL 
                                                THEN {default_score}
                                            WHEN f.F_Services_Bank=1 
                                                THEN 1.0 
                                            ELSE 0.0 
                                        END) 
                            END AS bank_score,
                            CASE 
                                WHEN {fac_cafe_pref}=0 
                                    THEN {default_score}
                                WHEN {fac_cafe_pref}=1 
                                    THEN (
                                            CASE 
                                                WHEN f.F_Food_Cafe IS NULL 
                                                    THEN {default_score}
                                                WHEN f.F_Food_Cafe=1 
                                                    THEN 0.75 
                                                ELSE 0.25 
                                            END) 
                                ELSE (
                                        CASE 
                                            WHEN f.F_Food_Cafe IS NULL 
                                                THEN {default_score}
                                            WHEN f.F_Food_Cafe=1 
                                                THEN 1.0 
                                            ELSE 0.0 
                                        END) 
                            END AS cafe_score,
                            CASE 
                                WHEN {fac_restaurant_pref}=0 
                                    THEN {default_score}
                                WHEN {fac_restaurant_pref}=1 
                                    THEN (
                                            CASE 
                                                WHEN f.F_Food_Restaurant IS NULL 
                                                    THEN {default_score}
                                                WHEN f.F_Food_Restaurant=1 
                                                    THEN 0.75 
                                                ELSE 0.25 
                                            END) 
                                    ELSE (
                                            CASE 
                                                WHEN f.F_Food_Restaurant IS NULL 
                                                    THEN {default_score}
                                                WHEN f.F_Food_Restaurant=1 
                                                    THEN 1.0 
                                                ELSE 0.0 
                                            END) 
                            END AS restaurant_score,
                            CASE 
                                WHEN {fac_foodcourt_pref}=0 
                                    THEN {default_score}
                                WHEN {fac_foodcourt_pref}=1 
                                    THEN (
                                            CASE 
                                                WHEN f.F_Food_Foodcourt IS NULL 
                                                    THEN {default_score} 
                                                WHEN f.F_Food_Foodcourt=1 
                                                    THEN 0.75 
                                                ELSE 0.25 
                                            END) 
                                ELSE (
                                        CASE 
                                            WHEN f.F_Food_Foodcourt IS NULL 
                                                THEN {default_score}
                                            WHEN f.F_Food_Foodcourt=1 
                                                THEN 1.0 
                                            ELSE 0.0 
                                        END) 
                            END AS foodcourt_score,
                            CASE 
                                WHEN {fac_market_pref}=0 
                                    THEN {default_score}
                                WHEN {fac_market_pref}=1 
                                    THEN (
                                            CASE 
                                                WHEN f.F_Food_Market IS NULL 
                                                    THEN {default_score} 
                                                WHEN f.F_Food_Market=1 
                                                    THEN 0.75 
                                                ELSE 0.25  
                                            END) 
                                ELSE (
                                        CASE 
                                            WHEN f.F_Food_Market IS NULL 
                                                THEN {default_score}
                                            WHEN f.F_Food_Market=1  
                                                THEN 1.0 
                                            ELSE 0.0 
                                        END) 
                            END AS market_score,
                            CASE 
                                WHEN {fac_conv_store_pref}=0 
                                    THEN {default_score}
                                WHEN {fac_conv_store_pref}=1 
                                    THEN (
                                            CASE 
                                                WHEN f.F_Retail_Conv_Store IS NULL 
                                                    THEN {default_score}
                                                WHEN f.F_Retail_Conv_Store=1 
                                                    THEN 0.75 
                                                ELSE 0.25 
                                            END) 
                                ELSE (
                                        CASE 
                                            WHEN f.F_Retail_Conv_Store IS NULL 
                                                THEN {default_score}
                                            WHEN f.F_Retail_Conv_Store=1 
                                                THEN 1.0 
                                            ELSE 0.0   
                                        END) 
                            END AS conv_store_score,
                            CASE 
                                WHEN {fac_pharmacy_pref}=0 
                                    THEN {default_score} 
                                WHEN {fac_pharmacy_pref}=1 
                                    THEN (
                                            CASE 
                                                WHEN f.F_Services_Pharma_Clinic IS NULL 
                                                    THEN {default_score} 
                                                WHEN f.F_Services_Pharma_Clinic=1 
                                                    THEN 0.75 
                                                ELSE 0.25 
                                            END) 
                                ELSE (
                                        CASE 
                                            WHEN f.F_Services_Pharma_Clinic IS NULL 
                                                THEN {default_score}
                                            WHEN f.F_Services_Pharma_Clinic=1 
                                                THEN 1.0 
                                            ELSE 0.0 
                                        END) 
                            END AS pharma_clinic_score,
                            CASE 
                                WHEN {fac_ev_pref}=0 
                                    THEN {default_score}
                                WHEN {fac_ev_pref}=1 
                                    THEN (
                                            CASE 
                                                WHEN f.F_Others_EV IS NULL 
                                                    THEN {default_score}
                                                WHEN f.F_Others_EV=1 
                                                    THEN 0.75 
                                                ELSE 0.25 
                                            END) 
                                ELSE (
                                        CASE 
                                            WHEN f.F_Others_EV IS NULL 
                                                THEN {default_score}
                                            WHEN f.F_Others_EV=1 
                                                THEN 1.0 
                                            ELSE 0.0 
                                        END) 
                            END AS ev_score
                        FROM floor_stats f
                        left join expenses b on f.Unit_ID = b.Unit_ID),
                    summary AS (
                        SELECT
                            b.*, a.Project_ID,
                            LEAST(COALESCE(b.Monthly_Avg_All__Central_With_NonAC, b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC),
                                COALESCE(b.Monthly_Avg_All__Split_Own_AC_Plus_NonAC, b.Monthly_Avg_All__Central_With_NonAC)) as Selected_Cost,
                            ROUND(a.cost_score,3) AS Cost_Score,
                            ROUND({w_price} * a.cost_score, 3) AS Final_Cost_Score,

                            -- === Size raw + score ===
                            a.Size as Size_cal,
                            ROUND(a.size_score,3) AS Size_Score,
                            ROUND({w_size} * a.size_score, 3) AS Final_Size_Score,
                            
                            -- === Location raw + score ===
                            a.Yarn_Name,
                            a.In_or_Out,
                            a.Yarn_Distance_Meters,
                            a.Yarn_Score,
                            a.Road_Name_TH,
                            a.Road_Distance_Meters,
                            a.Road_Score,
                            a.Station_Name,
                            a.Station_Radius_Distance_Meters,
                            a.Station_Radius_Score,
                            ROUND(a.location_score,3) AS Location_Score,
                            ({w_location} * a.location_score) AS Location_Score_Weighted,
                            -- === Train station distance raw + score ===
                            a.Distance_from_nearest_station,
                            ROUND(a.train_station_score,3) AS Train_Station_Score,
                            ({w_station} * a.train_station_score) AS Train_Station_Score_Weighted,
                            -- === Express way distance raw + score ===
                            a.Distance_from_nearest_express_way,
                            ROUND(a.express_way_score,3) AS Express_Way_Score,
                            ({w_expressway} * a.express_way_score) AS Express_Way_Score_Weighted,
                            (({w_location} * a.location_score) 
                            + ({w_station} * a.train_station_score) 
                            + ({w_expressway} * a.express_way_score)) as Final_Location_Score,
                            
                            -- === Common pantry raw + score ===
                            a.F_Common_Pantry,
                            ROUND(a.common_pantry_score,3) AS Common_Pantry_Score,
                            ({w_pantry} * a.common_pantry_score) AS Common_Pantry_Score_Weighted,
                            -- === Security system raw + score ===
                            a.Security_Type,
                            ROUND(a.security_score,3) AS Security_Score,
                            ({w_security} * a.security_score) AS Security_Score_Weighted,
                            -- === Lifts raw + score ===
                            a.Building_Passenger_Lift,
                            ROUND(a.passenger_lift_score,3) AS Passenger_Lift_Score,
                            ({w_passenger_lift} * a.passenger_lift_score) AS Passenger_Lift_Score_Weighted,
                            a.Building_Service_Lift,
                            ROUND(a.service_lift_score,3) AS Service_Lift_Score,
                            ({w_service_lift} * a.service_lift_score) AS Service_Lift_Score_Weighted,
                            -- === Building year raw + score ===
                            a.Built_Complete,
                            a.Last_Renovate,
                            ROUND(a.building_age_score,3) AS Building_Age_Score,
                            ({w_age} * a.building_age_score) AS Building_Age_Score_Weighted,
                            (({w_pantry} * a.common_pantry_score)
                            + ({w_security} * a.security_score)
                            + ({w_passenger_lift} * a.passenger_lift_score)
                            + ({w_service_lift} * a.service_lift_score)
                            + ({w_age} * a.building_age_score)) as Final_Building_Score,

                            -- === Floor raw + score ===
                            Floor,
                            ROUND(a.floor_score,3) AS Floor_Score,
                            ({w_floor} * a.floor_score) AS Floor_Score_Weighted,
                            -- === Direction raw + score ===
                            a.View_N, a.View_E, a.View_S, a.View_W,
                            ROUND(a.direction_score,3) AS Direction_Score,
                            ({w_direction} * a.direction_score) AS Direction_Score_Weighted,
                            -- === Ceiling raw + score ===
                            a.Ceiling_Dropped, a.Ceiling_Full_Structure,
                            ROUND(a.ceiling_score,3) AS Ceiling_Score,
                            ({w_ceiling} * a.ceiling_score) AS Ceiling_Score_Weighted,
                            -- === Column raw + score ===
                            a.Column_InUnit,
                            ROUND(a.columns_score,3) AS Columns_Score,
                            ({w_columns} * a.columns_score) AS Columns_Score_Weighted,
                            -- === Bathroom raw + score ===
                            a.Bathroom_InUnit,
                            ROUND(a.bathroom_score,3) AS Bathroom_Score,
                            ({w_bathroom} * a.bathroom_score) AS Bathroom_Score_Weighted,
                            -- === Pantry raw + score ===
                            a.Pantry_InUnit,
                            ROUND(a.pantry_score,3) AS Pantry_Score,
                            ({w_pantry_inunit} * a.pantry_score) AS Pantry_Score_Weighted,
                            (({w_floor} * a.floor_score)
                            + ({w_direction} * a.direction_score)
                            + ({w_ceiling} * a.ceiling_score)
                            + ({w_columns} * a.columns_score)
                            + ({w_bathroom} * a.bathroom_score)
                            + ({w_pantry_inunit} * a.pantry_score)) as Final_Unit_Score,

                            -- === Deposit raw + score ===
                            /*Rent_Deposit,
                            ROUND(deposit_score,3) AS Rent_Deposit_Score,
                            (w_deposit * deposit_score) AS Rent_Deposit_Score_Weighted,
                            -- === Advance rent raw + score ===
                            Rent_Advance,
                            ROUND(advance_score,3) AS Rent_Advance_Score,
                            (w_advance * advance_score) AS Rent_Advance_Score_Weighted,*/

                            -- === Facilities raw + score ===
                            a.F_Services_Bank,
                            ROUND(a.bank_score,3) AS Bank_Score,
                            ({w_fac_bank} * a.bank_score) AS Bank_Score_Weighted,
                            a.F_Food_Cafe,
                            ROUND(a.cafe_score,3) AS Cafe_Score,
                            ({w_fac_cafe} * a.cafe_score) AS Cafe_Score_Weighted,
                            a.F_Food_Restaurant,
                            ROUND(a.restaurant_score,3) AS Restaurant_Score,
                            ({w_fac_restaurant} * a.restaurant_score) AS Restaurant_Score_Weighted,
                            a.F_Food_Foodcourt,
                            ROUND(a.foodcourt_score,3) AS Foodcourt_Score,
                            ({w_fac_foodcourt} * a.foodcourt_score) AS Foodcourt_Score_Weighted,
                            a.F_Food_Market,
                            ROUND(a.market_score,3) AS Market_Score,
                            ({w_fac_market} * a.market_score) AS Market_Score_Weighted,
                            a.F_Retail_Conv_Store,
                            ROUND(a.conv_store_score,3) AS Conv_Store_Score,
                            ({w_fac_conv_store} * a.conv_store_score) AS Conv_Store_Score_Weighted,
                            a.F_Services_Pharma_Clinic,
                            ROUND(a.pharma_clinic_score,3) AS Pharma_Clinic_Score,
                            ({w_fac_pharma_clinic} * a.pharma_clinic_score) AS Pharma_Clinic_Score_Weighted,
                            a.F_Others_EV,
                            ROUND(a.ev_score,3) AS EV_Score,
                            ({w_fac_ev} * a.ev_score) AS EV_Score_Weighted,
                            (({w_fac_bank} * a.bank_score)
                            + ({w_fac_cafe} * a.cafe_score)
                            + ({w_fac_restaurant} * a.restaurant_score)
                            + ({w_fac_foodcourt} * a.foodcourt_score)
                            + ({w_fac_market} * a.market_score)
                            + ({w_fac_conv_store} * a.conv_store_score)
                            + ({w_fac_pharma_clinic} * a.pharma_clinic_score)
                            + ({w_fac_ev} * a.ev_score)) as Final_Convenience_Score,

                            -- === TOTAL weighted score ===
                            ROUND(
                                ({w_price}                  * a.cost_score)
                                + ({w_size}                 * a.size_score)
                                + ({w_location}             * a.location_score)
                                + ({w_floor}                * a.floor_score)
                                + ({w_direction}            * a.direction_score)
                                + ({w_ceiling}              * a.ceiling_score)
                                + ({w_columns}              * a.columns_score)
                                + ({w_bathroom}             * a.bathroom_score)
                                + ({w_pantry_inunit}        * a.pantry_score)
                                /*+ (w_deposit              * deposit_score)
                                + (w_advance                * advance_score)*/
                                + ({w_pantry}               * a.common_pantry_score)
                                + ({w_security}             * a.security_score)
                                + ({w_passenger_lift}       * a.passenger_lift_score)
                                + ({w_service_lift}         * a.service_lift_score)
                                + ({w_age}                  * a.building_age_score)
                                + ({w_station}              * a.train_station_score)
                                + ({w_expressway}           * a.express_way_score)
                                + ({w_fac_bank}             * a.bank_score)
                                + ({w_fac_cafe}             * a.cafe_score)
                                + ({w_fac_restaurant}       * a.restaurant_score)
                                + ({w_fac_foodcourt}        * a.foodcourt_score)
                                + ({w_fac_market}           * a.market_score)
                                + ({w_fac_conv_store}       * a.conv_store_score)
                                + ({w_fac_pharma_clinic}    * a.pharma_clinic_score)
                                + ({w_fac_ev}               * a.ev_score)
                            ,3) AS Total_Score
                        FROM scored a
                        left join expenses b on a.Unit_ID = b.Unit_ID)
                    select * from summary ORDER BY Total_Score DESC""")
        rows = cur.fetchall()
        return rows
    finally:
        cur.close()
        conn.close()

#def _get_unit_result_data() -> dict:
#    conn = get_db()
#    cur = conn.cursor(dictionary=True)
#    try:
#        cur.execute(f"""create query for result merge room and single room""", (,))
#        rows = cur.fetchall()
#        if rows:
#            return rows
#        return None
#    finally:
#        cur.close()
#        conn.close()

def generate_unique_code(unit_id, length=12):
    prefix = str(unit_id)
    seconds_str = f"{datetime.now().second:02}"
    fixed_part = prefix + seconds_str
    missing_len = length - len(fixed_part)
    
    if missing_len <= 0:
        return prefix[:length] 

    chars = string.ascii_letters + string.digits
    suffix = ''.join(random.choices(chars, k=missing_len))
    
    return fixed_part + suffix

def _insert_unit_url(unique_code, unit_id, project_id, user_gen, search_output_id, user_id) -> dict:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        if user_gen == 1:
            ex_date = 'DATE_ADD(NOW(), INTERVAL 2 MONTH)'
            link_status = None
            search_output_id = search_output_id
            user_id = None
        elif user_gen == 2:
            ex_date = 'DATE_ADD(NOW(), INTERVAL 1 MONTH)'
            link_status = None
            search_output_id = None
            user_id = user_id
        else:
            ex_date = 'DATE_ADD(NOW(), INTERVAL 1 YEAR)'
            link_status = 'Active'
            search_output_id = None
            user_id = None
        
        cur.execute(f"""insert into office_unit_link (Unique_Code, Unit_ID, Project_ID, Expire_Date, Link_Status, Search_output_ID, User_ID) 
                    values (%s, %s, %s, {ex_date}, %s, %s, %s)""", (unique_code, unit_id, project_id, link_status, search_output_id, user_id))
        
        conn.commit()
        
        host_url = 'http://thelist.group/real-lease/proj/'
        project_data = _select_full_office_project_item(project_id)
        project_url = project_data['Project_URL_Tag']
        full_url = host_url + project_url + '/' + unique_code
    
        return full_url
    except Exception as e:
        conn.rollback()
        raise Exception("Insert Link error")
    finally:
        cur.close()
        conn.close()

def gen_link(unit_id, project_id, user_gen, search_output_id, user_id, room_source):
    if room_source == 'merge':
        generated_links = []
        for unit in unit_id:
            unique_code = generate_unique_code(unit)
            unit_link = _insert_unit_url(unique_code, unit, project_id, user_gen, search_output_id, user_id)
            generated_links.append({'Unit_ID': unit, 'Unit_Link': unit_link})
        return generated_links
    else:
        unique_code = generate_unique_code(unit_id)
        unit_link = _insert_unit_url(unique_code, unit_id, project_id, user_gen, search_output_id, user_id)
        return [{'Unit_ID': unit_id, 'Unit_Link': unit_link}]

def find_unit_virtual_room(virtual_id):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute("""SELECT group_concat(Unit_ID SEPARATOR ',') as Unit_ID FROM `office_unit_virtual_room_mapping` where Virtual_ID = %s""", (virtual_id,))
        row = cur.fetchone()
        if row:
            return row['Unit_ID'].split(',')
        return []
    finally:
        cur.close()
        conn.close()

def get_lastest_unit(unit_rank, project_id) -> dict:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        if project_id is not None:
            add_query = 'and Project_ID = %s'
            params = (unit_rank, project_id)
        else:
            add_query = ''
            params = (unit_rank,)
        
        sql_query = f"""
            WITH RankedUnits AS (
                SELECT
                    u.Unit_ID, u.Title, u.Project_Name, u.Project_Tag_Used, u.Project_Tag_All,
                    u.near_by, u.Rent_Price, u.Rent_Price_Sqm, u.Rent_Price_Status, u.Project_ID, u.Project_URL_Tag /*concat(u.Project_URL_Tag, '/', u.Unique_Code)*/ as Unit_URL,
                    u.Last_Updated_Date, ROW_NUMBER() OVER (PARTITION BY u.Project_ID ORDER BY u.Last_Updated_Date desc) as rn
                FROM
                    source_office_unit_carousel_recommend u
            )
            SELECT DISTINCT
                Unit_ID, Title, Project_Name, Project_Tag_Used, Project_Tag_All,
                near_by, Rent_Price, Rent_Price_Sqm, Rent_Price_Status, Project_ID, Unit_URL, Last_Updated_Date
            FROM
                RankedUnits
            WHERE
                rn <= %s
            {add_query}
            ORDER BY Last_Updated_Date DESC
        """
        cur.execute(sql_query, params)
        final_units = cur.fetchall()
        if final_units:
            return final_units
        return None
    finally:
        cur.close()
        conn.close()

def insert_document(user_id, doc_name, doc_type):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        cur.execute(f"""insert into tenant_document (Tenant_ID, Doc_Type, Doc_Name) 
                    values (%s, %s, %s)""", (user_id, doc_type, doc_name))
        conn.commit()
        return {"Document_Name": doc_name, "Document_Type": doc_type}
    except:
        conn.rollback()
        raise Exception("Insert Document error")
    finally:
        cur.close()
        conn.close()

def _select_full_tenant_user(user_id: int) -> Dict[str, Any] | None:
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    cur2.execute(
        f"""SELECT
                *
            FROM tenant_user
            WHERE Tenant_ID=%s""",
        (user_id,)
    )
    row = cur2.fetchone()
    cur2.close()
    conn2.close()
    return normalize_unit_row(row)
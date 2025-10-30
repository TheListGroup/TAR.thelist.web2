from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from function_utility import iso8601_z, normalize_unit_row, normalize_row, format_seconds_to_time_str
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
            , a.Building_Copy, a.User_ID, a.Project_Status, a.Project_Redirect, a.Created_By, a.Created_Date, a.Last_Updated_By, a.Last_Updated_Date
            , b.Tags, floor_plan.Floor_Plan
            FROM office_project a
            left join (select a.Project_ID, group_concat(b.Tag_Name ORDER BY Relationship_Order SEPARATOR ';') as Tags
                        from office_project_tag_relationship a
                        join office_project_tag b on a.Tag_ID = b.Tag_ID
                        where a.Relationship_Status <> '2'
                        group by a.Project_ID) b 
            on a.Project_ID = b.Project_ID
            left join (SELECT a.Project_ID,  JSON_ARRAYAGG(JSON_OBJECT( 'Building_ID', c.Building_ID
                                                                        , 'Building_Name', b.Building_Name
                                                                        , 'Floor_Plan_ID', c.Floor_Plan_ID
                                                                        , 'Floor_Name', c.Floor_Name
                                                                        , 'FLoor_Plan_Order', c.Display_Order
                                                                        , 'Floor_Plan_URL', c.Floor_Plan_Image)) as Floor_Plan
                        FROM office_project a
                        join office_building b on a.Project_ID = b.Project_ID
                        join office_floor_plan c on b.Building_ID = c.Building_ID
                        where c.Floor_Plan_Status = '1'
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
    ac: str|None, ac_time_start: str|None, ac_time_end: str|None, ac_ot_weekday_by_hour: float|None, ac_ot_weekday_by_area: float|None,
    ac_ot_weekend_by_hour: float|None, ac_ot_weekend_by_area: float|None, ac_ot_min_hour: float|None, ac_ot_min_baht: float|None,
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
                , AC_OT_Weekday_by_Hour, AC_OT_Weekday_by_Area, AC_OT_Weekend_by_Hour, AC_OT_Weekend_by_Area, AC_OT_Min_Hour, AC_OT_Min_Baht
                , Bills_Electricity, Bills_Water
                , Rent_Term, Rent_Deposit, Rent_Advance, User_ID, Building_Status
                , Created_By, Last_Updated_By)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
            , %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (proj_id, building_name, office_condo, price_min, price_max, lat, lng, building_area, lettable_area, floor_plate1
                        , floor_plate2, floor_plate3, size_min, size_max, landlord, management, sole_agent, built_completed, last_renovate, floor_above
                        , floor_basement, floor_office_only, ceiling_avg, parking_ratio, parking_fee, total_lift, passenger_lift, service_lift, retail_parking_lift, ac
                        , ac_time_start, ac_time_end, ac_ot_weekday_by_hour, ac_ot_weekday_by_area, ac_ot_weekend_by_hour
                        , ac_ot_weekend_by_area, ac_ot_min_hour, ac_ot_min_baht, bill_elec, bill_water
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
                                , concat(format(a.Rent_Price_Min,0), ';บ./ตร.ม.')
                                , concat(format(a.Rent_Price_Min,0),' - ',format(a.Rent_Price_Max,0), ';บ./ตร.ม.'))
                            , concat(format(ifnull(a.Rent_Price_Max,a.Rent_Price_Min),0), ';บ./ตร.ม.')) as Rent_Price
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
                        , Total_Lift as Total_Lift
                        , AC_System as AC_System
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

def get_image(unit_id: int, project_id: int, use_type: str) -> str:
    conn = get_db()
    cur = conn.cursor()
    if use_type == 'Project':
                image_url_expression = "REGEXP_REPLACE(Image_URL, '-H-\\\\d+', '-H-400')"
    else:
        image_url_expression = "Image_URL"
        
    try:
        cur.execute("""
                    SELECT EXISTS (
                        SELECT 1 
                        FROM source_office_image_all 
                        WHERE Ref_ID = %s AND Image_Type = 'Unit_Image'
                        )
                    """, (unit_id,))
                    
        unit_has_images = cur.fetchone()[0] == 1
        
        if unit_has_images:
            sql = f"""
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'Image_ID', Image_ID, 'Image_Name', Image_Name, 'Category_Order', Category_Order,
                        'Display_Order', Display_Order, 'Image_URL', {image_url_expression}, 
                        'Image_Type', Image_Type
                    )
                ) AS Image_Set
                FROM source_office_image_all
                WHERE Ref_ID = %s AND Image_Type = 'Unit_Image';
            """
            params = (unit_id,)
        else:
            sql = f"""
                SELECT JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'Image_ID', Image_ID, 'Image_Name', Image_Name, 'Category_Order', Category_Order,
                        'Display_Order', Display_Order, 
                        'Image_URL', {image_url_expression},
                        'Image_Type', 'Image_Type'
                    )
                ) AS Image_Set
                FROM source_office_image_all
                WHERE Ref_ID = %s 
                    AND Image_Type IN ('Project_Image', 'Cover_Project')
                    AND Section <> 'Floor Plan'
                    AND Category_ID = 9;
            """
            params = (project_id,)
        
        cur.execute(sql, params)
        row = cur.fetchone()
        if row and row[0]:
            return row[0]        
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

def get_all_unit_carousel_images(unit_ids: list, project_ids: list) -> dict:
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    unit_placeholders = ', '.join(['%s'] * len(unit_ids))
    project_placeholders = ', '.join(['%s'] * len(project_ids))
    
    try:
        sql_query = f"""
        WITH ProcessedImages AS (
        SELECT
            CASE 
                WHEN img.Image_Type = 'Unit_Image' THEN img.Ref_ID
                ELSE map.Unit_ID
            END AS Owning_Unit_ID,

            CASE
                WHEN img.Image_Type = 'Cover_Project'
                THEN REPLACE(
                        REGEXP_REPLACE(img.Image_URL, '-H-\\\\d+', '-H-400'),
                        SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-', 1),
                        LPAD(CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-', 1) AS UNSIGNED) + 2, LENGTH(SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-', 1)), '0')
                    )
                ELSE REGEXP_REPLACE(img.Image_URL, '-H-\\\\d+', '-H-400')
            END AS Modified_Image_URL,

            CASE
                WHEN img.Image_Type = 'Cover_Project' THEN CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(img.Image_URL, '/', -1), '-H', 1) AS UNSIGNED) + 2
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
            (SELECT DISTINCT Unit_ID, Project_ID FROM source_office_unit_carousel_recommend) AS map
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
                (Image_Type = 'Unit_Image' OR (Image_Type <> 'Unit_Image' AND Category_ID <> 9))
                OR (Image_Type <> 'Unit_Image' AND Category_ID = 9 AND unit_image_count = 0)
        )
        SELECT 
            Owning_Unit_ID,
            JSON_ARRAYAGG(JSON_OBJECT(
                'Image_ID', Modified_Image_ID,
                'Image_Name', Image_Name,
                'Category_Order', Category_Order,
                'Display_Order', Display_Order,
                'Image_URL', Modified_Image_URL,
                'Image_Type',   CASE 
                                    WHEN Image_Type <> 'Unit_Image' AND Category_ID = 9 THEN 'Unit_Image' 
                                    ELSE Image_Type 
                                END
            )) AS Image_Set
        FROM FilteredImages
        WHERE Owning_Unit_ID IS NOT NULL
        GROUP BY Owning_Unit_ID
        """
        params = tuple(unit_ids) + tuple(project_ids)
        cur.execute(sql_query, params)
        rows = cur.fetchall()
        return {row['Owning_Unit_ID']: row['Image_Set'] for row in rows}
    finally:
        cur.close()
        conn.close()

def get_project_station(proj_id: int) -> Optional[str]:
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute("""select JSON_ARRAYAGG(JSON_OBJECT('Station_Code', Station_Code
                                                    , 'Station_THName_Display', Station_THName_Display
                                                    , 'Route_Code', Route_Code
                                                    , 'Line_Code', Line_Code
                                                    , 'MTran_ShortName', MTran_ShortName
                                                    , 'Project_ID', Project_ID
                                                    , 'Distance', Distance)) as Station
                        from (SELECT mtsmr.Station_Code
                                    , mtsmr.Station_THName_Display
                                    , mtsmr.Route_Code
                                    , mtr.Line_Code
                                    , mtsmr.Station_Latitude
                                    , mtsmr.Station_Longitude
                                    , o.Project_ID
                                    , o.Latitude
                                    , o.Longitude
                                    , mt.MTran_ShortName
                                    , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(o.Latitude - mtsmr.Station_Latitude)) / 2), 2)
                                        + COS(RADIANS(mtsmr.Station_Latitude)) * COS(RADIANS(o.Latitude)) *
                                        POWER(SIN((RADIANS(o.Longitude - mtsmr.Station_Longitude)) / 2), 2 )))) AS Distance
                                FROM mass_transit_station_match_route mtsmr
                                left join mass_transit_route mtr on mtsmr.Route_Code = mtr.Route_Code
                                left join mass_transit_line mtl on mtr.Line_Code = mtl.Line_Code
                                left join mass_transit mt on mtl.MTrand_ID = mt.MTran_ID
                                cross join (select * from office_project where Project_Status = '1' and Latitude is not null AND Longitude is not null) o
                                where mtsmr.Route_Timeline = 'Completion') aaa
                        where Distance <= 0.8
                        and Project_ID = %s
                        order by Distance
                        limit 2""", (proj_id,))
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
        cur.execute("""select JSON_ARRAYAGG(JSON_OBJECT('Place_ID', Place_ID
                                                    , 'Place_Type', Place_Type
                                                    , 'Place_Category', Place_Category
                                                    , 'Place_Name', Place_Name
                                                    , 'Place_Latitude', Place_Latitude
                                                    , 'Place_Longitude', Place_Longitude
                                                    , 'Project_ID', Project_ID
                                                    , 'Distance', Distance)) as Express_Way_Set
                        from (SELECT ew.Place_ID 
                                    , ew.Place_Type
                                    , ew.Place_Category
                                    , ew.Place_Name
                                    , ew.Place_Latitude
                                    , ew.Place_Longitude
                                    , o.Project_ID
                                    , o.Latitude
                                    , o.Longitude
                                    , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(o.Latitude - ew.Place_Latitude)) / 2), 2)
                                        + COS(RADIANS(ew.Place_Latitude)) * COS(RADIANS(o.Latitude)) *
                                        POWER(SIN((RADIANS(o.Longitude - ew.Place_Longitude)) / 2), 2 )))) AS Distance
                                FROM real_place_express_way ew
                                cross join (select * from office_project where Project_Status = '1' and Latitude is not null AND Longitude is not null) o) aaa
                        where Distance <= 2.0
                        and Project_ID = %s
                        order by Distance
                        limit 2""", (proj_id,))
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
        cur.execute("""select JSON_ARRAYAGG(JSON_OBJECT('Place_ID', Place_ID
                                                    , 'Place_Name', Place_Name
                                                    , 'Place_Latitude', Place_Latitude
                                                    , 'Place_Longitude', Place_Longitude
                                                    , 'Project_ID', Project_ID
                                                    , 'Distance', Distance)) as Retail_Set
                        from (SELECT r.Place_ID
                                , r.Place_Name
                                , r.Place_Latitude
                                , r.Place_Longitude
                                , o.Project_ID
                                , o.Latitude
                                , o.Longitude
                                , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(o.Latitude - r.Place_Latitude)) / 2), 2)
                                    + COS(RADIANS(r.Place_Latitude)) * COS(RADIANS(o.Latitude)) *
                                    POWER(SIN((RADIANS(o.Longitude - r.Place_Longitude)) / 2), 2 )))) AS Distance
                            FROM real_place_retail r
                            cross join (select * from office_project where Project_Status = '1' and Latitude is not null AND Longitude is not null) o) aaa
                            where Distance <= 0.8
                            and Project_ID = %s
                            order by Distance
                            limit 2""", (proj_id,))
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
        cur.execute("""select JSON_ARRAYAGG(JSON_OBJECT('Place_ID', Place_ID
                                                    , 'Place_Name', CONCAT(Place_Category, Place_Name)
                                                    , 'Place_Latitude', Place_Latitude
                                                    , 'Place_Longitude', Place_Longitude
                                                    , 'Project_ID', Project_ID
                                                    , 'Distance', Distance)) as Hospital
                        from (SELECT h.Place_ID
                                , h.Place_Category
                                , h.Place_Name
                                , h.Place_Latitude
                                , h.Place_Longitude
                                , o.Project_ID
                                , o.Latitude
                                , o.Longitude
                                , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(o.Latitude - h.Place_Latitude)) / 2), 2)
                                    + COS(RADIANS(h.Place_Latitude)) * COS(RADIANS(o.Latitude)) *
                                    POWER(SIN((RADIANS(o.Longitude - h.Place_Longitude)) / 2), 2 )))) AS Distance
                            FROM real_place_hospital h
                            cross join (select * from office_project where Project_Status = '1' and Latitude is not null AND Longitude is not null) o) aaa
                            where Distance <= 0.8
                            and Project_ID = %s
                            order by Distance
                            limit 2""", (proj_id,))
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
        cur.execute("""select JSON_ARRAYAGG(JSON_OBJECT('Place_ID', Place_ID
                                                    , 'Place_Name', CONCAT(Place_Category, Place_Name)
                                                    , 'Place_Latitude', Place_Latitude
                                                    , 'Place_Longitude', Place_Longitude
                                                    , 'Project_ID', Project_ID
                                                    , 'Distance', Distance)) as Education
                        from (SELECT e.Place_ID
                                , e.Place_Category
                                , e.Place_Name
                                , e.Place_Latitude
                                , e.Place_Longitude
                                , o.Project_ID
                                , o.Latitude
                                , o.Longitude
                                , (6371 * 2 * ASIN(SQRT(POWER(SIN((RADIANS(o.Latitude - e.Place_Latitude)) / 2), 2)
                                    + COS(RADIANS(e.Place_Latitude)) * COS(RADIANS(o.Latitude)) *
                                    POWER(SIN((RADIANS(o.Longitude - e.Place_Longitude)) / 2), 2 )))) AS Distance
                            FROM real_place_education e
                            cross join (select * from office_project where Project_Status = '1' and Latitude is not null AND Longitude is not null) o) aaa
                            where Distance <= 0.8
                            and Project_ID = %s
                            order by Distance
                            limit 2""", (proj_id,))
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
                    ,*/ concat(format(a.Rent_Price, 0), ';บ./ตร.ม./ด.') as Rent_Price
                    , concat(format(a.Size, 0), ';ตร.ม.') as Unit_Size
                    , if(d.building > 1, b.Building_Name, NULL) as Building_Name
                    , c.Name_EN as Project_Name
                    , e.Highlight as Highlight
                    , e.near_by as Nearby
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
                                                            , 'Branch_Name', Branch_Name
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
    text_list = f"%{Text}%" * 6
    try:
        cur.execute("""
            SELECT 'project' AS location_type, 'โครงการ' AS type, Name_TH AS name_th, Name_EN AS name_en
            FROM office_project
            WHERE Project_Status = '1'
            AND (Name_TH LIKE %s OR Name_EN LIKE %s)
            union all
            SELECT 'masstransit' AS location_type, 'สถานีรถไฟฟ้า' AS type, concat(d.MTran_ShortName, ' ', a.Station_THName_Display) AS name_th
                , concat(d.MTran_ShortName, ' ', a.Station_ENName_Display) AS name_en
            FROM mass_transit_station a
            join mass_transit_route b on a.Route_Code = b.Route_Code and b.Route_Timeline = 'Completion'
            join mass_transit_line c on b.Line_Code = c.Line_Code
            join mass_transit d on c.MTrand_ID = d.MTran_ID
            WHERE a.Station_Timeline = 'Completion'
            AND (a.Station_THName_Display LIKE %s OR a.Station_ENName_Display LIKE %s)""", (f"%{Text}%", f"%{Text}%", f"%{Text}%", f"%{Text}%", f"%{Text}%", f"%{Text}%"))
        row = cur.fetchall()
        if len(row) >= 1:
            return row
        else:
            return None
    finally:
        cur.close()
        conn.close()
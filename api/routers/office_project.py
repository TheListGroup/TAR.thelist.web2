from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists
from function_query_helper import _select_full_office_project_item, _get_province, _get_district, _get_subdistrict, _get_realist_district \
    , _get_realist_subdistrict, _insert_building_record, _insert_cover_record, _get_image_display_order, _update_image_order, _select_all_unit_image_category \
    , _select_full_project, normalize_row, _delete_cover, _delete_image, _save_image_file, _update_cover_record
from typing import Optional, Tuple, Dict, Any, List
import os
import re

router = APIRouter()
TABLE = "office_project"

ALLOWED_EXT = {".jpg", ".jpeg", ".png", ".webp", ".gif"}

def _insert_image_record(
    project_id, ref_type: str, category_id: int, image_name: str, image_url: str,
    display_order: int, image_status: str, created_by: int
) -> dict:
    # ตัดชื่อไฟล์ให้ไม่เกิน 100 ตัวอักษรตาม schema
    image_name = image_name[:100] if image_name else None
    conn = get_db()
    cur = conn.cursor()
    try:
        sql = """
            INSERT INTO office_image
                (Category_ID, Project_or_Building, Ref_ID, Image_Name, Image_Url, Display_Order, Image_Status,
                Created_By, Last_Updated_By)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (
            category_id,
            ref_type,
            project_id,
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
                    Image_ID, Category_ID, Project_or_Building, Ref_ID, Image_Name, Image_Url,
                    Display_Order, Image_Status, Created_By, Created_Date, Last_Updated_By, Last_Updated_Date
                FROM office_image
                WHERE Image_ID=%s""",
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
            UPDATE office_image
            SET Image_Url=%s
            WHERE Image_ID=%s
        """
        cur.execute(sql, (image_url, image_id))
        conn.commit()
    finally:
        cur.close()
        conn.close()

def insert_project_tag_relationship(project_id: int, tag_id: int, created_by: int, order: int) -> dict:
    try:
        conn = get_db()
        cur = conn.cursor()
        sql = """INSERT INTO office_project_tag_relationship
                    (Tag_ID, Project_ID, Relationship_Order, Relationship_Status, Created_By, Last_Updated_By)
                VALUES (%s, %s, %s, %s, %s, %s)"""
        cur.execute(sql, (tag_id, project_id, order, '1', created_by, created_by))
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
                        ID, Tag_ID, Project_ID, Relationship_Order, Relationship_Status, Created_By, Created_Date,
                        Last_Updated_By, Last_Updated_Date
                    FROM office_project_tag_relationship
                    WHERE ID=%s""",
            (new_id,))
        row = cur2.fetchone()
        return row
    finally:
        cur2.close()
        conn2.close()

def insert_tag_relationship(Project_ID: int, Tag_Text: str, Created_By: int):
    conn = get_db()
    cur = conn.cursor()
    
    #ล้างให้หมดก่อนจะสร้าง
    delete_query = "DELETE FROM office_project_tag_relationship WHERE Project_ID = %s"
    cur.execute(delete_query, (Project_ID,))
    conn.commit()
    
    if Tag_Text is not None:
        data = []
        all_tag = Tag_Text.split(",")
        for i, tag in enumerate(all_tag):
            check_query = "SELECT Tag_ID FROM office_project_tag WHERE Tag_Name = %s"
            cur.execute(check_query, (tag,))
            row = cur.fetchone()
            if row is not None:
                tag_id = row[0]
                #ถ้ามีให้ insert เข้า relationship
                row = insert_project_tag_relationship(Project_ID, tag_id, Created_By, i+1)
            #ถ้าไม่มี ไปสร้างก่อน แล้วค่อยสร้าง relationship
            else:
                tag_query = "INSERT INTO office_project_tag (Tag_Name, Created_By, Last_Updated_By) VALUES (%s, %s, %s)"
                cur.execute(tag_query, (tag, Created_By, Created_By))
                conn.commit()
                tag_id = cur.lastrowid
                row = insert_project_tag_relationship(Project_ID, tag_id, Created_By, i+1)
            data.append({"relationship": row})
    
    cur.close()
    conn.close()

# ----------------------------------------------------- INSERT --------------------------------------------------------------------------------------------
@router.post("/insert", status_code=201)
def insert_office_project_and_return_full_record(
    response: Response,
    Name_TH: str = Form(None),
    Name_EN: str = Form(...),
    Latitude: str = Form(None),
    Longitude: str = Form(None),
    Road_Name: str = Form(None),
    Land_Rai: str = Form(None),
    Land_Ngan: str = Form(None),
    Land_Wa: str = Form(None),
    Office_Lettable_Area: str = Form(None),
    Total_Usable_Area: str = Form(None),
    Parking_Amount: str = Form(None),
    Security_Type: str = Form(None),
    F_Common_Bathroom: str = Form(None),
    F_Common_Pantry: str = Form(None),
    F_Common_Garbageroom: str = Form(None),
    F_Retail_Conv_Store: str = Form(None),
    F_Retail_Supermarket: str = Form(None),
    F_Retail_Mall_Shop: str = Form(None),
    F_Food_Market: str = Form(None),
    F_Food_Foodcourt: str = Form(None),
    F_Food_Cafe: str = Form(None),
    F_Food_Restaurant: str = Form(None),
    F_Services_ATM: str = Form(None),
    F_Services_Bank: str = Form(None),
    F_Services_Pharma_Clinic: str = Form(None),
    F_Services_Hair_Salon: str = Form(None),
    F_Services_Spa_Beauty: str = Form(None),
    F_Others_Gym: str = Form(None),
    F_Others_Valet: str = Form(None),
    F_Others_EV: str = Form(None),
    F_Others_Conf_Meetingroom: str = Form(None),
    Environment_Friendly: str = Form(None),
    Project_Description: str = Form(None),
    Building_Copy: str = Form(None),
    User_ID: int = Form(...),
    Project_Status: str = Form("0"),
    Created_By: int = Form(...),
    Last_Updated_By: int = Form(...),
    Tag_Text: str = Form(None),
    _ = Depends(get_current_user),
):
    try:
        Name_TH = Name_TH if Name_TH else None
        Name_EN = Name_EN if Name_EN else None
        Latitude = None if not Latitude else float(Latitude)
        Longitude = None if not Longitude else float(Longitude)
        Road_Name = Road_Name if Road_Name else None
        Land_Rai = None if not Land_Rai else float(Land_Rai)
        Land_Ngan = None if not Land_Ngan else float(Land_Ngan)
        Land_Wa = None if not Land_Wa else float(Land_Wa)
        Office_Lettable_Area = None if not Office_Lettable_Area else float(Office_Lettable_Area)
        Total_Usable_Area = None if not Total_Usable_Area else float(Total_Usable_Area)
        Parking_Amount = None if not Parking_Amount else int(Parking_Amount)
        Security_Type = Security_Type if Security_Type else None
        F_Common_Bathroom = None if not F_Common_Bathroom else int(F_Common_Bathroom)
        F_Common_Pantry = None if not F_Common_Pantry else int(F_Common_Pantry)
        F_Common_Garbageroom = None if not F_Common_Garbageroom else int(F_Common_Garbageroom)
        F_Retail_Conv_Store = None if not F_Retail_Conv_Store else int(F_Retail_Conv_Store)
        F_Retail_Supermarket = None if not F_Retail_Supermarket else int(F_Retail_Supermarket)
        F_Retail_Mall_Shop = None if not F_Retail_Mall_Shop else int(F_Retail_Mall_Shop)
        F_Food_Market = None if not F_Food_Market else int(F_Food_Market)
        F_Food_Foodcourt = None if not F_Food_Foodcourt else int(F_Food_Foodcourt)
        F_Food_Cafe = None if not F_Food_Cafe else int(F_Food_Cafe)
        F_Food_Restaurant = None if not F_Food_Restaurant else int(F_Food_Restaurant)
        F_Services_ATM = None if not F_Services_ATM else int(F_Services_ATM)
        F_Services_Bank = None if not F_Services_Bank else int(F_Services_Bank)
        F_Services_Pharma_Clinic = None if not F_Services_Pharma_Clinic else int(F_Services_Pharma_Clinic)
        F_Services_Hair_Salon = None if not F_Services_Hair_Salon else int(F_Services_Hair_Salon)
        F_Services_Spa_Beauty = None if not F_Services_Spa_Beauty else int(F_Services_Spa_Beauty)
        F_Others_Gym = None if not F_Others_Gym else int(F_Others_Gym)
        F_Others_Valet = None if not F_Others_Valet else int(F_Others_Valet)
        F_Others_EV = None if not F_Others_EV else int(F_Others_EV)
        F_Others_Conf_Meetingroom = None if not F_Others_Conf_Meetingroom else int(F_Others_Conf_Meetingroom)
        Environment_Friendly = Environment_Friendly if Environment_Friendly else None
        Project_Description = Project_Description if Project_Description else None
        Project_Status = Project_Status if Project_Status else '0'
        Building_Copy = True if Building_Copy == "1" else False
        
        if Land_Rai != None or Land_Ngan != None or Land_Wa != None:
            if Land_Rai == None:
                Land_Rai = 0
            if Land_Ngan == None:
                Land_Ngan = 0
            if Land_Wa == None:
                Land_Wa = 0
            land_total = Land_Rai + (Land_Ngan / 4) + (Land_Wa / 400)
        else:
            land_total = None

    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")
    
    try:
        conn = get_db()
        cur = conn.cursor()
        sql = f"""
            INSERT INTO {TABLE}
            (Name_TH, Name_EN, Latitude, Longitude, Road_Name, Land_Rai, Land_Ngan, Land_Wa, Land_Total, Office_Lettable_Area, Total_Usable_Area, Parking_Amount
            , Security_Type, F_Common_Bathroom, F_Common_Pantry, F_Common_Garbageroom, F_Retail_Conv_Store, F_Retail_Supermarket, F_Retail_Mall_Shop
            , F_Food_Market, F_Food_Foodcourt, F_Food_Cafe, F_Food_Restaurant, F_Services_ATM, F_Services_Bank, F_Services_Pharma_Clinic
            , F_Services_Hair_Salon, F_Services_Spa_Beauty, F_Others_Gym, F_Others_Valet, F_Others_EV, F_Others_Conf_Meetingroom
            , Environment_Friendly, Project_Description, Building_Copy, User_ID, Project_Status, Created_By, Last_Updated_By)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (
            Name_TH, Name_EN, Latitude, Longitude, Road_Name, Land_Rai, Land_Ngan, Land_Wa, land_total, Office_Lettable_Area, Total_Usable_Area, Parking_Amount
            , Security_Type, F_Common_Bathroom, F_Common_Pantry, F_Common_Garbageroom, F_Retail_Conv_Store, F_Retail_Supermarket, F_Retail_Mall_Shop
            , F_Food_Market, F_Food_Foodcourt, F_Food_Cafe, F_Food_Restaurant, F_Services_ATM, F_Services_Bank, F_Services_Pharma_Clinic
            , F_Services_Hair_Salon, F_Services_Spa_Beauty, F_Others_Gym, F_Others_Valet, F_Others_EV, F_Others_Conf_Meetingroom
            , Environment_Friendly, Project_Description, Building_Copy, User_ID, Project_Status, Created_By, Last_Updated_By
        ))
        conn.commit()
        new_id = cur.lastrowid
        
        if Latitude != None and Longitude != None:
            province = _get_province(new_id)
            district = _get_district(new_id)
            subdistrict = _get_subdistrict(new_id)
            realist_district = _get_realist_district(new_id)
            realist_subdistrict = _get_realist_subdistrict(new_id)
        
            update_sql = f"""UPDATE {TABLE}
                            SET Province_ID=%s, District_ID=%s, SubDistrict_ID=%s, Realist_DistrictID=%s, Realist_SubDistrictID=%s
                            WHERE Project_ID=%s"""
            cur.execute(update_sql, (province, district, subdistrict, realist_district, realist_subdistrict, new_id))
            conn.commit()
        
        pattern = r'[!@#$%^&*()_+{}\[\]:;<>,.?~\\|/`\'"-]'
        if Name_EN:
            project_url_tag = re.sub(r'\s+', '-', re.sub(pattern, '', Name_EN)) + '-' + str(new_id).rjust(4, '0')
            update_sql = f"""UPDATE {TABLE}
                            SET Project_URL_Tag=%s
                            WHERE Project_ID=%s"""
            cur.execute(update_sql, (project_url_tag, new_id))
            conn.commit()
        
        insert_tag_relationship(new_id, Tag_Text, Created_By)
        
        cur.close()
        conn.close()
    except Exception as e:
        return to_problem(409, "Conflict", f"Insert Project failed: {e}")
    
    data = []
    row_proj = _select_full_office_project_item(new_id)
    data.append({"project": row_proj})
    # ------------------------ Insert Building --------------------------------------------------------------------------------------------
    try:
        if Building_Copy:
            row_building = _insert_building_record(new_id, Name_EN, 0, 0, None, Latitude, Longitude, None, Office_Lettable_Area, None, 
                            None, None, None, None, None, None, None, None, None, None,
                            None, None, None, None, None, None, None, None, None, None,
                            None, None, None, None, None, None, None, None, None, None,
                            None, None, None, None, None, None, None, None, User_ID, Project_Status,
                            Created_By, Last_Updated_By)
            data.append({"building": row_building})
    except Exception as e:
        return to_problem(409, "Conflict", f"Insert Building from Project failed: {e}")
    
    response.headers["Location"] = f"/office-project/select-office-project/{new_id}"
    return apply_etag_and_return(response, data)


# ----------------------------------------------------- UPDATE --------------------------------------------------------------------------------------------
@router.put("/update/{Project_ID}", status_code=200)
@router.post("/update/{Project_ID}", status_code=200)  # รองรับส่งจาก form
def update_office_project_and_return_full_record(
    response: Response,
    Project_ID: int,
    Name_TH: str = Form(None),
    Name_EN: str = Form(None),
    Latitude: str = Form(None),
    Longitude: str = Form(None),
    Road_Name: str = Form(None),
    Land_Rai: str = Form(None),
    Land_Ngan: str = Form(None),
    Land_Wa: str = Form(None),
    Office_Lettable_Area: str = Form(None),
    Total_Usable_Area: str = Form(None),
    Parking_Amount: str = Form(None),
    Security_Type: str = Form(None),
    F_Common_Bathroom: str = Form(None),
    F_Common_Pantry: str = Form(None),
    F_Common_Garbageroom: str = Form(None),
    F_Retail_Conv_Store: str = Form(None),
    F_Retail_Supermarket: str = Form(None),
    F_Retail_Mall_Shop: str = Form(None),
    F_Food_Market: str = Form(None),
    F_Food_Foodcourt: str = Form(None),
    F_Food_Cafe: str = Form(None),
    F_Food_Restaurant: str = Form(None),
    F_Services_ATM: str = Form(None),
    F_Services_Bank: str = Form(None),
    F_Services_Pharma_Clinic: str = Form(None),
    F_Services_Hair_Salon: str = Form(None),
    F_Services_Spa_Beauty: str = Form(None),
    F_Others_Gym: str = Form(None),
    F_Others_Valet: str = Form(None),
    F_Others_EV: str = Form(None),
    F_Others_Conf_Meetingroom: str = Form(None),
    Environment_Friendly: str = Form(None),
    Project_Description: str = Form(None),
    Building_Copy: str = Form(None),
    User_ID: int = Form(...),
    Project_Status: str = Form("0"),
    Project_Redirect: str = Form(None),
    Last_Updated_By: int = Form(...),
    Tag_Text: str = Form(None),
    if_match: Optional[str] = Header(None, alias="If-Match"),
    _ = Depends(get_current_user),
):
    try:
        Name_TH = Name_TH if Name_TH else None
        Name_EN = Name_EN if Name_EN else None
        Latitude = None if not Latitude else float(Latitude)
        Longitude = None if not Longitude else float(Longitude)
        Road_Name = Road_Name if Road_Name else None
        Land_Rai = None if not Land_Rai else float(Land_Rai)
        Land_Ngan = None if not Land_Ngan else float(Land_Ngan)
        Land_Wa = None if not Land_Wa else float(Land_Wa)
        Office_Lettable_Area = None if not Office_Lettable_Area else float(Office_Lettable_Area)
        Total_Usable_Area = None if not Total_Usable_Area else float(Total_Usable_Area)
        Parking_Amount = None if not Parking_Amount else int(Parking_Amount)
        Security_Type = Security_Type if Security_Type else None
        F_Common_Bathroom = None if not F_Common_Bathroom else int(F_Common_Bathroom)
        F_Common_Pantry = None if not F_Common_Pantry else int(F_Common_Pantry)
        F_Common_Garbageroom = None if not F_Common_Garbageroom else int(F_Common_Garbageroom)
        F_Retail_Conv_Store = None if not F_Retail_Conv_Store else int(F_Retail_Conv_Store)
        F_Retail_Supermarket = None if not F_Retail_Supermarket else int(F_Retail_Supermarket)
        F_Retail_Mall_Shop = None if not F_Retail_Mall_Shop else int(F_Retail_Mall_Shop)
        F_Food_Market = None if not F_Food_Market else int(F_Food_Market)
        F_Food_Foodcourt = None if not F_Food_Foodcourt else int(F_Food_Foodcourt)
        F_Food_Cafe = None if not F_Food_Cafe else int(F_Food_Cafe)
        F_Food_Restaurant = None if not F_Food_Restaurant else int(F_Food_Restaurant)
        F_Services_ATM = None if not F_Services_ATM else int(F_Services_ATM)
        F_Services_Bank = None if not F_Services_Bank else int(F_Services_Bank)
        F_Services_Pharma_Clinic = None if not F_Services_Pharma_Clinic else int(F_Services_Pharma_Clinic)
        F_Services_Hair_Salon = None if not F_Services_Hair_Salon else int(F_Services_Hair_Salon)
        F_Services_Spa_Beauty = None if not F_Services_Spa_Beauty else int(F_Services_Spa_Beauty)
        F_Others_Gym = None if not F_Others_Gym else int(F_Others_Gym)
        F_Others_Valet = None if not F_Others_Valet else int(F_Others_Valet)
        F_Others_EV = None if not F_Others_EV else int(F_Others_EV)
        F_Others_Conf_Meetingroom = None if not F_Others_Conf_Meetingroom else int(F_Others_Conf_Meetingroom)
        Environment_Friendly = Environment_Friendly if Environment_Friendly else None
        Project_Description = Project_Description if Project_Description else None
        Project_Status = Project_Status if Project_Status else '0'
        Building_Copy = True if Building_Copy == "1" else False
        Project_Redirect = int(Project_Redirect) if Project_Redirect else None
        
        if Land_Rai != None or Land_Ngan != None or Land_Wa != None:
            if Land_Rai == None:
                Land_Rai = 0
            if Land_Ngan == None:
                Land_Ngan = 0
            if Land_Wa == None:
                Land_Wa = 0
            land_total = Land_Rai + (Land_Ngan / 4) + (Land_Wa / 400)
        else:
            land_total = None
        
        if Latitude != None and Longitude != None:
            province = _get_province(Project_ID)
            district = _get_district(Project_ID)
            subdistrict = _get_subdistrict(Project_ID)
            realist_district = _get_realist_district(Project_ID)
            realist_subdistrict = _get_realist_subdistrict(Project_ID)
        else:
            province = None
            district = None
            subdistrict = None
            realist_district = None
            realist_subdistrict = None

    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")

    try:
        current = _select_full_office_project_item(Project_ID)
        if not current:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                detail=f"Project '{Project_ID}' was not found")

        if if_match and if_match != etag_of(current):
            raise HTTPException(status_code=status.HTTP_412_PRECONDITION_FAILED,
                            detail="ETag mismatch. Please GET latest and retry with If-Match.")

        pattern = r'[!@#$%^&*()_+{}\[\]:;<>,.?~\\|/`\'"-]'
        project_url_tag = re.sub(r'\s+', '-', re.sub(pattern, '', Name_EN)) + '-' + str(Project_ID).rjust(4, '0')
        
        conn = get_db()
        cur = conn.cursor()
        sql = f"""
            UPDATE {TABLE}
            SET Name_TH=%s,
                Name_EN=%s,
                Latitude=%s,
                Longitude=%s,
                Road_Name=%s,
                Province_ID=%s,
                District_ID=%s,
                SubDistrict_ID=%s,
                Realist_DistrictID=%s,
                Realist_SubDistrictID=%s,
                Land_Rai=%s,
                Land_Ngan=%s,
                Land_Wa=%s,
                Land_Total=%s,
                Office_Lettable_Area=%s,
                Total_Usable_Area=%s,
                Parking_Amount=%s,
                Security_Type=%s,
                F_Common_Bathroom=%s,
                F_Common_Pantry=%s,
                F_Common_Garbageroom=%s,
                F_Retail_Conv_Store=%s,
                F_Retail_Supermarket=%s,
                F_Retail_Mall_Shop=%s,
                F_Food_Market=%s,
                F_Food_Foodcourt=%s,
                F_Food_Cafe=%s,
                F_Food_Restaurant=%s,
                F_Services_ATM=%s,
                F_Services_Bank=%s,
                F_Services_Pharma_Clinic=%s,
                F_Services_Hair_Salon=%s,
                F_Services_Spa_Beauty=%s,
                F_Others_Gym=%s,
                F_Others_Valet=%s,
                F_Others_EV=%s,
                F_Others_Conf_Meetingroom=%s,
                Environment_Friendly=%s,
                Project_Description=%s,
                Project_URL_Tag=%s,
                Building_Copy=%s,
                User_ID=%s,
                Project_Status=%s,
                Project_Redirect=%s,
                Last_Updated_By=%s,
                Last_Updated_Date=CURRENT_TIMESTAMP
            WHERE Project_ID=%s
        """
        cur.execute(sql, (Name_TH, Name_EN, Latitude, Longitude, Road_Name, province, district, subdistrict, realist_district, realist_subdistrict
                        , Land_Rai, Land_Ngan, Land_Wa, land_total, Office_Lettable_Area, Total_Usable_Area, Parking_Amount, Security_Type
                        , F_Common_Bathroom, F_Common_Pantry, F_Common_Garbageroom, F_Retail_Conv_Store, F_Retail_Supermarket, F_Retail_Mall_Shop, F_Food_Market
                        , F_Food_Foodcourt, F_Food_Cafe, F_Food_Restaurant, F_Services_ATM, F_Services_Bank, F_Services_Pharma_Clinic, F_Services_Hair_Salon
                        , F_Services_Spa_Beauty, F_Others_Gym, F_Others_Valet, F_Others_EV, F_Others_Conf_Meetingroom, Environment_Friendly, Project_Description
                        , project_url_tag, Building_Copy, User_ID, Project_Status, Project_Redirect, Last_Updated_By, Project_ID))
        conn.commit()
        
        if Project_Status == "1":
            sql = f"""UPDATE office_cover SET Cover_Status='1' WHERE Project_or_Building='Project' AND Ref_ID=%s"""
            cur.execute(sql, (Project_ID,))
            conn.commit()
            
            sql = f"""UPDATE office_image SET Image_Status='1' WHERE Project_or_Building='Project' AND Ref_ID=%s"""
            cur.execute(sql, (Project_ID,))
            conn.commit()
        
        insert_tag_relationship(Project_ID, Tag_Text, Last_Updated_By)
        
        cur.close()
        conn.close()
    except HTTPException as he:
        raise he

    except Exception as e:
        return to_problem(409, "Conflict", f"Update Project failed: {e}")

    row = _select_full_office_project_item(Project_ID)
    return apply_etag_and_return(response, row)


# ----------------------------------------------------- DELETE --------------------------------------------------------------------------------------------
@router.delete("/delete/{Project_ID}", status_code=204)
@router.post("/delete/{Project_ID}", status_code=204)  # รองรับ form
def delete_office_project(
    Project_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(f"UPDATE {TABLE} SET Project_Status='2' WHERE Project_ID=%s", (Project_ID,))
    affected = cur.rowcount
    conn.commit()
    
    #cover management
    cur.execute(f"SELECT Cover_ID FROM office_cover WHERE Project_or_Building='Project' AND Ref_ID=%s", (Project_ID,))
    rows = cur.fetchall()
    for row in rows:
        _delete_cover(row[0], "Delete_Project", "Project")
    
    #gallery management
    cur.execute(f"SELECT Image_ID FROM office_image WHERE Project_or_Building='Project' AND Ref_ID=%s", (Project_ID,))
    rows = cur.fetchall()
    for row in rows:
        _delete_image(row[0], "Delete_Project", "Project", Project_ID)
    
    cur.close()
    conn.close()

    if affected == 0:
        return to_problem(404, "Not Found", f"Project '{Project_ID}' was not found.")


# ====================== SELECT ALL ======================
@router.get("/select/all", status_code=200)
def select_all_office_projects(
    _ = Depends(get_current_user),
):
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        base_sql = f"""
            SELECT
            a.Project_ID, a.Name_TH, a.Name_EN, a.Latitude, a.Longitude, a.Road_Name, a.Province_ID, a.District_ID
            , a.SubDistrict_ID, a.Realist_DistrictID, a.Realist_SubDistrictID, a.Land_Rai, a.Land_Ngan, a.Land_Wa, a.Land_Total, a.Office_Lettable_Area
            , a.Total_Usable_Area, a.Parking_Amount, a.Security_Type, a.F_Common_Bathroom, a.F_Common_Pantry, a.F_Common_Garbageroom, a.F_Retail_Conv_Store, a.F_Retail_Supermarket
            , a.F_Retail_Mall_Shop, a.F_Food_Market, a.F_Food_Foodcourt, a.F_Food_Cafe, a.F_Food_Restaurant, a.F_Services_ATM, a.F_Services_Bank, a.F_Services_Pharma_Clinic
            , a.F_Services_Hair_Salon, a.F_Services_Spa_Beauty, a.F_Others_Gym, a.F_Others_Valet, a.F_Others_EV, a.F_Others_Conf_Meetingroom, a.Environment_Friendly, a.Project_Description
            , a.Building_Copy, a.User_ID, a.Project_Status, a.Project_Redirect, a.Created_By, a.Created_Date, a.Last_Updated_By, a.Last_Updated_Date
            , b.Tags
            FROM {TABLE} a
            left join (select a.Project_ID, group_concat(b.Tag_Name SEPARATOR ';') as Tags
                        from office_project_tag_relationship a
                        join office_project_tag b on a.Tag_ID = b.Tag_ID
                        where a.Relationship_Status <> '2'
                        group by a.Project_ID) b 
            on a.Project_ID = b.Project_ID
            WHERE a.Project_Status <> '2'
            ORDER BY a.Project_ID
        """

        cur.execute(base_sql)
        rows = cur.fetchall()
        
        return rows
    finally:
        cur.close()
        conn.close()


# ====================== SELECT BY KEY ======================
@router.get("/select/{Project_ID}", status_code=200)
def select_office_project_by_id(
    response: Response,
    Project_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_full_office_project_item(Project_ID)
    require_row_exists(row, Project_ID, 'Project')

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
    Project_ID: int = Form(...),
    Created_By: int = Form(...),
    Image_Status: str = Form("0"),
    _ = Depends(get_current_user),
):
    if not file:
        raise HTTPException(status_code=400, detail="No files")
    
    results = []
    cover_size_list = [(1440,810),(800,450),(400,225)]
    name = file.filename or "unnamed"
    ext = os.path.splitext(name)[1].lower()
    content_type = file.content_type
    file_bytes = file.file.read()
    if ext not in ALLOWED_EXT:
        raise HTTPException(status_code=400, detail=f"File type not allowed: {ext}")
    for cover_size in cover_size_list:
        record = _insert_cover_record(
                type_text="Project",
                ref_id=Project_ID,
                image_url="",
                cover_size = cover_size[0],
                cover_status=Image_Status,
                created_by=Created_By)
    
        cover_id = record["Cover_ID"]
        meta = _save_image_file(file_bytes, cover_id, Project_ID, "Cover", "Project", Project_ID, cover_size, content_type)
        _update_cover_record(
                cover_id=cover_id,
                cover_url=meta["url"],
            )
        record["Cover_Url"] = meta["url"]
    
        results.append({"file": meta, "record": record})

    return {"cover": results}

# ============ ลบ cover + ลบ DB ============
@router.delete("/cover/delete/{Cover_ID}", status_code=204)
@router.post("/cover/delete/{Cover_ID}", status_code=204)
async def delete_cover_record(
    Cover_ID: int,
    _ = Depends(get_current_user),
):
    _delete_cover(Cover_ID, "Delete_Cover", "Project")

# ====================== SELECT BY KEY ======================
@router.get("/cover/select/{Project_ID}", status_code=200)
def select_all_office_project_cover(
    Project_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    response: Response = Response(),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        project = _select_full_project(Project_ID)
        require_row_exists(project, Project_ID, 'Project')
        
        et = etag_of(project)
        # ถ้า client ส่ง If-None-Match มาและตรง → 304
        if if_none_match and if_none_match == et:
            response.headers["ETag"] = et
            response.status_code = status.HTTP_304_NOT_MODIFIED
            return
        
        base_sql = """SELECT
                        Cover_ID,
                        Cover_Size,
                        Cover_Url,
                        Created_By,
                        Created_Date,
                        Last_Updated_By,
                        Last_Updated_Date
                    FROM office_cover
                    WHERE Ref_ID = %s AND Cover_Status = '1' AND Project_or_Building = 'Project' AND Cover_Size = 1440
                    ORDER BY Cover_Size desc"""
        
        cur.execute(base_sql, (Project_ID,))
        rows = cur.fetchall()
        rows = [normalize_row(r) for r in rows]
        
        data = []
        for row in rows:
            data.append({"cover": row})

        return {"data": data}
    
    finally:
        cur.close()
        conn.close()


# ============ อัปโหลดกี่ไฟล์ก็ได้ + บันทึก DB ============
@router.post("/images/record", status_code=201)
async def upload_and_record(
    files: List[UploadFile] = File(...),
    Category_ID: int = Form(...),
    Project_ID: int = Form(...),
    Created_By: int = Form(...),
    Image_Status: str = Form("0"),
    Image_caption: str = Form(...),
    _ = Depends(get_current_user),
):
    if not files:
        raise HTTPException(status_code=400, detail="No files")
    
    results = []
    image_size_list = [(1440,810),(800,450),(400,225)]
    order = _get_image_display_order(Project_ID, Category_ID, "Project")
    images_name = Image_caption.split(";")
    for i,f in enumerate(files):
        name = f.filename or "unnamed"
        ext = os.path.splitext(name)[1].lower()
        content_type = f.content_type
        if ext not in ALLOWED_EXT:
            raise HTTPException(status_code=400, detail=f"File type not allowed: {ext}")
        
        file_bytes = f.file.read()
        record = _insert_image_record(
                    project_id=Project_ID,
                    ref_type="Project",
                    category_id=Category_ID,
                    image_name=images_name[i],
                    image_url="",
                    display_order=order,
                    image_status=Image_Status,
                    created_by=Created_By,
                )
        image_id = record["Image_ID"]
        for image_size in image_size_list:
            meta = _save_image_file(file_bytes, image_id, Project_ID, "Image", "Project", Project_ID, image_size, content_type)
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
def update_project_image_order(
    Display_Order: str = Form(...),
    _ = Depends(get_current_user),
):
    order_list = Display_Order.split(",")
    results = []
    for i, order in enumerate(order_list):
        meta = _update_image_order(image_id=int(order), display_order=i+1, table_name="office_image", id_column="Image_ID")
        results.append({"data": meta})

    return {"items": results}

# ----------------------------------------------------- UPDATE Image Name --------------------------------------------------------------------------------------------
@router.put("/image/update/image_caption", status_code=200)
@router.post("/image/update/image_caption", status_code=200)
def update_project_image_caption(
    Image_ID: int = Form(...),
    Image_Caption: str = Form(...),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    update_query = "UPDATE office_image SET Image_Name = %s WHERE Image_ID = %s"
    try:
        cur.execute(update_query, (Image_Caption, Image_ID))
        conn.commit()
        return {"data": {"Image_ID": Image_ID, "Image_Name": Image_Caption}}
    except Exception as e:
        return to_problem(409, "Conflict", f"Update Image Caption failed: {e}")
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
    _delete_image(Image_ID, "Delete_Image", "Project", 1)


# ====================== SELECT BY KEY ======================
@router.get("/images/select/{Project_ID}", status_code=200)
def select_all_office_unit_images(
    Project_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    response: Response = Response(),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        categories = _select_all_unit_image_category(id_column="Category_ID", table_name="office_image_category")
        project = _select_full_project(Project_ID)
        require_row_exists(project, Project_ID, 'Project')
        
        et = etag_of(project)
        # ถ้า client ส่ง If-None-Match มาและตรง → 304
        if if_none_match and if_none_match == et:
            response.headers["ETag"] = et
            response.status_code = status.HTTP_304_NOT_MODIFIED
            return
        
        base_sql = """SELECT
                        a.Image_ID,
                        a.Category_ID,
                        a.Project_or_Building,
                        a.Ref_ID,
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
                    FROM office_image a
                    JOIN office_image_category b ON a.Category_ID = b.Category_ID
                    WHERE a.Ref_ID = %s AND a.Category_ID = %s AND a.Image_Status = '1' AND a.Project_or_Building = 'Project'
                    ORDER BY b.Display_Order, a.Display_Order"""
        
        data = []
        for row in categories:
            cur.execute(base_sql, (Project_ID, row["Category_ID"]))
            rows = cur.fetchall()
            rows = [normalize_row(r) for r in rows]
            data.append({"category_id": row["Category_ID"], "category": row["Category_Name"], "list": rows})

        return {"data": data}
    
    finally:
        cur.close()
        conn.close()


# ====================== SELECT ALL TAG ======================
@router.get("/select-tag/all/{Tag_Text}", status_code=200)
def select_all_office_tags(
    Tag_Text: str,
    _ = Depends(get_current_user),
):
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        base_sql = "SELECT Tag_Name FROM office_project_tag WHERE Tag_Name LIKE %s"

        cur.execute(base_sql, (f"%{Tag_Text}%",))
        rows = cur.fetchall()
        
        return rows
    finally:
        cur.close()
        conn.close()
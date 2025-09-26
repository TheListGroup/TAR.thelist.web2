from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists
from function_query_helper import _insert_building_record, _insert_cover_record \
    , normalize_row, _select_full_office_building_item, _delete_cover, _save_image_file, _update_cover_record \
    , _select_full_office_building_relationship_item, _get_building_relationship, _get_project_name, _get_building_name
from typing import Optional, Tuple, Dict, Any, List
import os, uuid, shutil
from datetime import datetime

router = APIRouter()
TABLE = "office_building"

ALLOWED_EXT = {".jpg", ".jpeg", ".png", ".webp", ".gif"}

# ----------------------------------------------------- INSERT --------------------------------------------------------------------------------------------
@router.post("/insert", status_code=201)
def insert_office_building_and_return_full_record(
    response: Response,
    Building_Name: str = Form(...),
    Project_ID: int = Form(...),
    Office_Condo: str = Form(None),
    Rent_Price_Min: int = Form(...),
    Rent_Price_Max: str = Form(None),
    Building_Latitude: str = Form(None),
    Building_Longitude: str = Form(None),
    Total_Building_Area: str = Form(None),
    Lettable_Area: str = Form(None),
    Typical_Floor_Plate_1: str = Form(None),
    Typical_Floor_Plate_2: str = Form(None),
    Typical_Floor_Plate_3: str = Form(None),
    Unit_Size_Min: str = Form(...),
    Unit_Size_Max: str = Form(None),
    Landlord: str = Form(None),
    Management: str = Form(None),
    Sole_Agent: str = Form(None),
    Built_Complete: str = Form(None),
    Last_Renovate: str = Form(None),
    Floor_Above: str = Form(None),
    Floor_Basement: str = Form(None),
    Floor_Office_Only: str = Form(None),
    Ceiling_Avg: str = Form(None),
    Parking_Ratio: str = Form(None),
    Parking_Fee_Car: str = Form(None),
    Total_Lift: str = Form(None),
    Passenger_Lift: str = Form(None),
    Service_Lift: str = Form(None),
    Retail_Parking_Lift: str = Form(None),
    AC_System: str = Form(None),
    ACTime_Start: str = Form(None),
    ACTime_End: str = Form(None),
    AC_OT_Weekday_by_Hour: str = Form(None),
    AC_OT_Weekday_by_Area: str = Form(None),
    AC_OT_Weekend_by_Hour: str = Form(None),
    AC_OT_Weekend_by_Area: str = Form(None),
    AC_OT_Min_Hour: str = Form(None),
    Bills_Electricity: str = Form(None),
    Bills_Water: str = Form(None),
    Rent_Term: str = Form(None),
    Rent_Deposit: str = Form(None),
    Rent_Advance: str = Form(None),
    User_ID: int = Form(...),
    Building_Status: str = Form("0"),
    Created_By: int = Form(...),
    Last_Updated_By: int = Form(...),
    _ = Depends(get_current_user),
):
    try:
        Office_Condo = None if not Office_Condo else int(Office_Condo)
        Rent_Price_Max = None if not Rent_Price_Max else int(Rent_Price_Max)
        Building_Latitude = None if not Building_Latitude else float(Building_Latitude)
        Building_Longitude = None if not Building_Longitude else float(Building_Longitude)
        Total_Building_Area = None if not Total_Building_Area else float(Total_Building_Area)
        Lettable_Area = None if not Lettable_Area else float(Lettable_Area)
        Typical_Floor_Plate_1 = None if not Typical_Floor_Plate_1 else int(Typical_Floor_Plate_1)
        Typical_Floor_Plate_2 = None if not Typical_Floor_Plate_2 else int(Typical_Floor_Plate_2)
        Typical_Floor_Plate_3 = None if not Typical_Floor_Plate_3 else int(Typical_Floor_Plate_3)
        Unit_Size_Max = None if not Unit_Size_Max else float(Unit_Size_Max)
        Landlord = None if not Landlord else Landlord
        Management = None if not Management else Management
        Sole_Agent = None if not Sole_Agent else int(Sole_Agent)
        Built_Complete = None if not Built_Complete else datetime.strptime(Built_Complete, "%Y-%m-%d")
        Last_Renovate = None if not Last_Renovate else datetime.strptime(Last_Renovate, "%Y-%m-%d")
        Floor_Above = None if not Floor_Above else float(Floor_Above)
        Floor_Basement = None if not Floor_Basement else float(Floor_Basement)
        Floor_Office_Only = None if not Floor_Office_Only else float(Floor_Office_Only)
        Ceiling_Avg = None if not Ceiling_Avg else float(Ceiling_Avg)
        Parking_Ratio = None if not Parking_Ratio else f"1 : {Parking_Ratio}"
        Parking_Fee_Car = None if not Parking_Fee_Car else int(Parking_Fee_Car)
        Total_Lift = None if not Total_Lift else int(Total_Lift)
        Passenger_Lift = None if not Passenger_Lift else int(Passenger_Lift)
        Service_Lift = None if not Service_Lift else int(Service_Lift)
        Retail_Parking_Lift = None if not Retail_Parking_Lift else int(Retail_Parking_Lift)
        AC_System = None if not AC_System else AC_System
        ACTime_Start = None if not ACTime_Start else datetime.strptime(ACTime_Start, "%H:%M:%S").time()
        ACTime_End = None if not ACTime_End else datetime.strptime(ACTime_End, "%H:%M:%S").time()
        AC_OT_Weekday_by_Hour = None if not AC_OT_Weekday_by_Hour else float(AC_OT_Weekday_by_Hour)
        AC_OT_Weekday_by_Area = None if not AC_OT_Weekday_by_Area else float(AC_OT_Weekday_by_Area)
        AC_OT_Weekend_by_Hour = None if not AC_OT_Weekend_by_Hour else float(AC_OT_Weekend_by_Hour)
        AC_OT_Weekend_by_Area = None if not AC_OT_Weekend_by_Area else float(AC_OT_Weekend_by_Area)
        AC_OT_Min_Hour = None if not AC_OT_Min_Hour else float(AC_OT_Min_Hour)
        Bills_Electricity = None if not Bills_Electricity else float(Bills_Electricity)
        Bills_Water = None if not Bills_Water else float(Bills_Water)
        Rent_Term = None if not Rent_Term else int(Rent_Term)
        Rent_Deposit = None if not Rent_Deposit else int(Rent_Deposit)
        Rent_Advance = None if not Rent_Advance else int(Rent_Advance)
        Building_Status = Building_Status if Building_Status else '0'
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")
    
    try:
        new_id = _insert_building_record(Project_ID, Building_Name, Office_Condo, Rent_Price_Min, Rent_Price_Max, Building_Latitude, Building_Longitude, 
            Total_Building_Area, Lettable_Area, Typical_Floor_Plate_1, Typical_Floor_Plate_2, Typical_Floor_Plate_3, Unit_Size_Min, Unit_Size_Max,
            Landlord, Management, Sole_Agent, Built_Complete,
            Last_Renovate, Floor_Above, Floor_Basement, Floor_Office_Only, Ceiling_Avg,
            Parking_Ratio, Parking_Fee_Car, Total_Lift, Passenger_Lift, Service_Lift, Retail_Parking_Lift, AC_System, ACTime_Start, ACTime_End,
            AC_OT_Weekday_by_Hour, AC_OT_Weekday_by_Area, AC_OT_Weekend_by_Hour, AC_OT_Weekend_by_Area, AC_OT_Min_Hour,
            Bills_Electricity, Bills_Water, Rent_Term, Rent_Deposit, Rent_Advance, User_ID,
            Building_Status, Created_By, Last_Updated_By)
    except Exception as e:
        return to_problem(409, "Conflict", f"Insert failed: {e}")
    
    data = []
    row_building = _select_full_office_building_item(new_id)
    data.append({"building": row_building})
    
    response.headers["Location"] = f"/office-building/select-office-building/{new_id}"
    return apply_etag_and_return(response, data)


# ----------------------------------------------------- UPDATE --------------------------------------------------------------------------------------------
@router.put("/update/{Building_ID}", status_code=200)
@router.post("/update/{Building_ID}", status_code=200)  # รองรับส่งจาก form
def update_office_building_and_return_full_record(
    response: Response,
    Building_ID: int,
    Building_Name: str = Form(...),
    Project_ID: int = Form(...),
    Office_Condo: str = Form(None),
    Rent_Price_Min: int = Form(...),
    Rent_Price_Max: str = Form(None),
    Building_Latitude: str = Form(None),
    Building_Longitude: str = Form(None),
    Total_Building_Area: str = Form(None),
    Lettable_Area: str = Form(None),
    Typical_Floor_Plate_1: str = Form(None),
    Typical_Floor_Plate_2: str = Form(None),
    Typical_Floor_Plate_3: str = Form(None),
    Unit_Size_Min: str = Form(...),
    Unit_Size_Max: str = Form(None),
    Landlord: str = Form(None),
    Management: str = Form(None),
    Sole_Agent: str = Form(None),
    Built_Complete: str = Form(None),
    Last_Renovate: str = Form(None),
    Floor_Above: str = Form(None),
    Floor_Basement: str = Form(None),
    Floor_Office_Only: str = Form(None),
    Ceiling_Avg: str = Form(None),
    Parking_Ratio: str = Form(None),
    Parking_Fee_Car: str = Form(None),
    Total_Lift: str = Form(None),
    Passenger_Lift: str = Form(None),
    Service_Lift: str = Form(None),
    Retail_Parking_Lift: str = Form(None),
    AC_System: str = Form(None),
    ACTime_Start: str = Form(None),
    ACTime_End: str = Form(None),
    AC_OT_Weekday_by_Hour: str = Form(None),
    AC_OT_Weekday_by_Area: str = Form(None),
    AC_OT_Weekend_by_Hour: str = Form(None),
    AC_OT_Weekend_by_Area: str = Form(None),
    AC_OT_Min_Hour: str = Form(None),
    Bills_Electricity: str = Form(None),
    Bills_Water: str = Form(None),
    Rent_Term: str = Form(None),
    Rent_Deposit: str = Form(None),
    Rent_Advance: str = Form(None),
    User_ID: int = Form(...),
    Building_Status: str = Form("0"),
    Last_Updated_By: int = Form(...),
    if_match: Optional[str] = Header(None, alias="If-Match"),
    _ = Depends(get_current_user),
):
    try:
        Office_Condo = None if not Office_Condo else int(Office_Condo)
        Rent_Price_Max = None if not Rent_Price_Max else int(Rent_Price_Max)
        Building_Latitude = None if not Building_Latitude else float(Building_Latitude)
        Building_Longitude = None if not Building_Longitude else float(Building_Longitude)
        Total_Building_Area = None if not Total_Building_Area else float(Total_Building_Area)
        Lettable_Area = None if not Lettable_Area else float(Lettable_Area)
        Typical_Floor_Plate_1 = None if not Typical_Floor_Plate_1 else int(Typical_Floor_Plate_1)
        Typical_Floor_Plate_2 = None if not Typical_Floor_Plate_2 else int(Typical_Floor_Plate_2)
        Typical_Floor_Plate_3 = None if not Typical_Floor_Plate_3 else int(Typical_Floor_Plate_3)
        Unit_Size_Max = None if not Unit_Size_Max else float(Unit_Size_Max)
        Landlord = None if not Landlord else Landlord
        Management = None if not Management else Management
        Sole_Agent = None if not Sole_Agent else int(Sole_Agent)
        Built_Complete = None if not Built_Complete else datetime.strptime(Built_Complete, "%Y-%m-%d")
        Last_Renovate = None if not Last_Renovate else datetime.strptime(Last_Renovate, "%Y-%m-%d")
        Floor_Above = None if not Floor_Above else float(Floor_Above)
        Floor_Basement = None if not Floor_Basement else float(Floor_Basement)
        Floor_Office_Only = None if not Floor_Office_Only else float(Floor_Office_Only)
        Ceiling_Avg = None if not Ceiling_Avg else float(Ceiling_Avg)
        Parking_Ratio = None if not Parking_Ratio else (Parking_Ratio + " : 100")
        Parking_Fee_Car = None if not Parking_Fee_Car else int(Parking_Fee_Car)
        Total_Lift = None if not Total_Lift else int(Total_Lift)
        Passenger_Lift = None if not Passenger_Lift else int(Passenger_Lift)
        Service_Lift = None if not Service_Lift else int(Service_Lift)
        Retail_Parking_Lift = None if not Retail_Parking_Lift else int(Retail_Parking_Lift)
        AC_System = None if not AC_System else AC_System
        ACTime_Start = None if not ACTime_Start else datetime.strptime(ACTime_Start, "%H:%M:%S").time()
        ACTime_End = None if not ACTime_End else datetime.strptime(ACTime_End, "%H:%M:%S").time()
        AC_OT_Weekday_by_Hour = None if not AC_OT_Weekday_by_Hour else float(AC_OT_Weekday_by_Hour)
        AC_OT_Weekday_by_Area = None if not AC_OT_Weekday_by_Area else float(AC_OT_Weekday_by_Area)
        AC_OT_Weekend_by_Hour = None if not AC_OT_Weekend_by_Hour else float(AC_OT_Weekend_by_Hour)
        AC_OT_Weekend_by_Area = None if not AC_OT_Weekend_by_Area else float(AC_OT_Weekend_by_Area)
        AC_OT_Min_Hour = None if not AC_OT_Min_Hour else float(AC_OT_Min_Hour)
        Bills_Electricity = None if not Bills_Electricity else float(Bills_Electricity)
        Bills_Water = None if not Bills_Water else float(Bills_Water)
        Rent_Term = None if not Rent_Term else int(Rent_Term)
        Rent_Deposit = None if not Rent_Deposit else int(Rent_Deposit)
        Rent_Advance = None if not Rent_Advance else int(Rent_Advance)
        Building_Status = Building_Status if Building_Status else '0'
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")

    try:
        current = _select_full_office_building_item(Building_ID)
        if not current:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                                detail=f"Building '{Building_ID}' was not found")

        if if_match and if_match != etag_of(current):
            raise HTTPException(status_code=status.HTTP_412_PRECONDITION_FAILED,
                            detail="ETag mismatch. Please GET latest and retry with If-Match.")
    
        conn = get_db()
        cur = conn.cursor()
        sql = f"""
            UPDATE {TABLE}
            SET Building_Name=%s,
                Project_ID=%s,
                Office_Condo=%s,
                Rent_Price_Min=%s,
                Rent_Price_Max=%s,
                Building_Latitude=%s,
                Building_Longitude=%s,
                Total_Building_Area=%s,
                Lettable_Area=%s,
                Typical_Floor_Plate_1=%s,
                Typical_Floor_Plate_2=%s,
                Typical_Floor_Plate_3=%s,
                Unit_Size_Min=%s,
                Unit_Size_Max=%s,
                Landlord=%s,
                Management=%s,
                Sole_Agent=%s,
                Built_Complete=%s,
                Last_Renovate=%s,
                Floor_Above=%s,
                Floor_Basement=%s,
                Floor_Office_Only=%s,
                Ceiling_Avg=%s,
                Parking_Ratio=%s,
                Parking_Fee_Car=%s,
                Total_Lift=%s,
                Passenger_Lift=%s,
                Service_Lift=%s,
                Retail_Parking_Lift=%s,
                AC_System=%s,
                ACTime_Start=%s,
                ACTime_End=%s,
                AC_OT_Weekday_by_Hour=%s,
                AC_OT_Weekday_by_Area=%s,
                AC_OT_Weekend_by_Hour=%s,
                AC_OT_Weekend_by_Area=%s,
                AC_OT_Min_Hour=%s,
                Bills_Electricity=%s,
                Bills_Water=%s,
                Rent_Term=%s,
                Rent_Deposit=%s,
                Rent_Advance=%s,
                User_ID=%s,
                Building_Status=%s,
                Last_Updated_By=%s,
                Last_Updated_Date=CURRENT_TIMESTAMP
            WHERE Building_ID=%s
        """
        cur.execute(sql, (Building_Name, Project_ID, Office_Condo, Rent_Price_Min, Rent_Price_Max, Building_Latitude, Building_Longitude
                        , Total_Building_Area, Lettable_Area, Typical_Floor_Plate_1, Typical_Floor_Plate_2, Typical_Floor_Plate_3, Unit_Size_Min, Unit_Size_Max
                        , Landlord, Management, Sole_Agent, Built_Complete, Last_Renovate, Floor_Above, Floor_Basement, Floor_Office_Only, Ceiling_Avg
                        , Parking_Ratio, Parking_Fee_Car, Total_Lift, Passenger_Lift
                        , Service_Lift, Retail_Parking_Lift, AC_System, ACTime_Start, ACTime_End
                        , AC_OT_Weekday_by_Hour, AC_OT_Weekday_by_Area, AC_OT_Weekend_by_Hour, AC_OT_Weekend_by_Area, AC_OT_Min_Hour
                        , Bills_Electricity, Bills_Water
                        , Rent_Term, Rent_Deposit, Rent_Advance, User_ID
                        , Building_Status, Last_Updated_By, Building_ID))
        conn.commit()
        
        if Building_Status == "1":
            sql = f"""UPDATE office_cover SET Cover_Status='1' WHERE Project_or_Building='Building' AND Ref_ID=%s"""
            cur.execute(sql, (Building_ID,))
            conn.commit()
            
            sql = f"""UPDATE office_image SET Image_Status='1' WHERE Project_or_Building='Building' AND Ref_ID=%s"""
            cur.execute(sql, (Building_ID,))
            conn.commit()
        
        cur.close()
        conn.close()
    except HTTPException as he:
        raise he

    except Exception as e:
        return to_problem(409, "Conflict", f"Update Building failed: {e}")

    row = _select_full_office_building_item(Building_ID)
    return apply_etag_and_return(response, row)

# ----------------------------------------------------- DELETE --------------------------------------------------------------------------------------------
@router.delete("/delete/{Building_ID}", status_code=204)
@router.post("/delete/{Building_ID}", status_code=204)  # รองรับ form
def delete_office_building(
    Building_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(f"UPDATE {TABLE} SET Building_Status='2' WHERE Building_ID=%s", (Building_ID,))
    affected = cur.rowcount
    conn.commit()
    
    #cover management
    cur.execute(f"SELECT Cover_ID FROM office_cover WHERE Project_or_Building='Building' AND Ref_ID=%s", (Building_ID,))
    rows = cur.fetchall()
    for row in rows:
        _delete_cover(row[0], "Delete_Building", "Building")
    
    cur.close()
    conn.close()

    if affected == 0:
        return to_problem(404, "Not Found", f"Building '{Building_ID}' was not found.")


# ====================== SELECT ALL ======================
@router.get("/select/all/{Project_ID}", status_code=200)
def select_all_office_buildings(
    Project_ID: int,
    _ = Depends(get_current_user),
):
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        base_sql = f"""
            SELECT
                *
            FROM {TABLE}
            WHERE Building_Status <> '2' AND Project_ID=%s
            ORDER BY Building_ID
        """

        cur.execute(base_sql, (Project_ID,))
        rows = cur.fetchall()
        
        return rows
    finally:
        cur.close()
        conn.close()


# ====================== SELECT BY KEY ======================
@router.get("/select/{Building_ID}", status_code=200)
def select_office_building_by_id(
    response: Response,
    Building_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    _ = Depends(get_current_user),
):
    row = _select_full_office_building_item(Building_ID)
    require_row_exists(row, Building_ID, 'Building')

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
    Building_ID: int = Form(...),
    Created_By: int = Form(...),
    Image_Status: str = Form("0"),
    _ = Depends(get_current_user),
):
    if not file:
        raise HTTPException(status_code=400, detail="No files")
    
    results = []
    cover_size_list = [(800,600),(400,300)]
    name = file.filename or "unnamed"
    ext = os.path.splitext(name)[1].lower()
    content_type = file.content_type
    file_bytes = file.file.read()
    if ext not in ALLOWED_EXT:
        raise HTTPException(status_code=400, detail=f"File type not allowed: {ext}")
    
    row = _select_full_office_building_item(Building_ID)
    Project_ID = row["Project_ID"]
    
    for cover_size in cover_size_list:
        record = _insert_cover_record(
                type_text="Building",
                ref_id=Building_ID,
                image_url="",
                cover_size = cover_size[0],
                cover_status=Image_Status,
                created_by=Created_By)
    
        cover_id = record["Cover_ID"]
        meta = _save_image_file(file_bytes, cover_id, Building_ID, "Cover", "Building", Project_ID, cover_size, content_type)
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
    _delete_cover(Cover_ID, "Delete_Cover", "Building")

# ====================== SELECT BY KEY ======================
@router.get("/cover/select/{Building_ID}", status_code=200)
def select_all_office_building_cover(
    Building_ID: int,
    if_none_match: Optional[str] = Header(None, alias="If-None-Match"),
    response: Response = Response(),
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        building = _select_full_office_building_item(Building_ID)
        require_row_exists(building, Building_ID, 'Building')
        
        et = etag_of(building)
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
                    WHERE Ref_ID = %s AND Cover_Status = '1' AND Project_or_Building = 'Building'
                    AND Cover_Size = 800
                    ORDER BY Cover_Size desc"""
        
        cur.execute(base_sql, (Building_ID,))
        rows = cur.fetchall()
        rows = [normalize_row(r) for r in rows]
        
        data = []
        for row in rows:
            data.append({"cover": row})

        return {"data": data}
    
    finally:
        cur.close()
        conn.close()

# ----------------------------------------------------- INSERT RELATIONSHIP --------------------------------------------------------------------------------------------
@router.post("/insert/relationship", status_code=201)
def insert_office_building_relationship(
    response: Response,
    Building_ID: int = Form(...),
    User_ID: int = Form(...),
    Relationship_Status: int = Form(...),
    Created_By: int = Form(...),
    _ = Depends(get_current_user),
):  
    try:
        check_query = """SELECT * FROM office_building_relationship WHERE Building_ID=%s AND User_ID=%s AND Relationship_Status = '1'"""
        conn = get_db()
        cur = conn.cursor()
        cur.execute(check_query, (Building_ID, User_ID))
        rows = cur.fetchall()
        cur.close()
        conn.close()
        
        if rows:
            return to_problem(409, "Conflict", "Relationship already exists")
        
        query = """INSERT INTO office_building_relationship (Building_ID, User_ID, Relationship_Status, Created_By, Last_Updated_By) VALUES (%s, %s, %s, %s, %s)"""
        conn = get_db()
        cur = conn.cursor()
        cur.execute(query, (Building_ID, User_ID, Relationship_Status, Created_By, Created_By))
        conn.commit()
        new_id = cur.lastrowid
        cur.close()
        conn.close()
    except Exception as e:
        return to_problem(409, "Conflict", f"Insert failed: {e}")
    
    row = _select_full_office_building_relationship_item(new_id)
    if not row:
        return to_problem(500, "Server Error", "Created but cannot fetch newly created resource.")
    
    response.headers["Location"] = f"/office-building/select-office-building-relationship/{new_id}"
    return apply_etag_and_return(response, row)

# ----------------------------------------------------- DELETE RELATIONSHIP --------------------------------------------------------------------------------------------
@router.delete("/delete/relationship/{ID}", status_code=204)
@router.post("/delete/relationship/{ID}", status_code=204)  # รองรับ form
def delete_office_building_relationship(
    ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor()
    cur.execute(f"UPDATE office_building_relationship SET Relationship_Status='2' WHERE ID=%s", (ID,))
    affected = cur.rowcount
    conn.commit()
    cur.close()
    conn.close()

    if affected == 0:
        # 404 แบบ problem+json
        return to_problem(404, "Not Found", f"Relationship '{ID}' was not found.")
    # 204 No Content → ไม่ส่ง body

# ====================== SELECT BY KEY ======================
@router.get("/relationship/select/{User_ID}", status_code=200)
def select_all_office_building_relationship(
    User_ID: int,
    _ = Depends(get_current_user),
):
    conn = get_db()
    cur = conn.cursor(dictionary=True)
    try:
        building_result = _get_building_relationship(User_ID)
        building_result.sort(key=lambda x: x[2])
        
        data = []
        for b in building_result:
            proj_id = b[1]
            (project_nameth, project_nameen) = _get_project_name(proj_id)
            
            building_id = b[0]
            (building_name,) = _get_building_name(building_id)
            
            data.append({
                "ID": b[2],
                "User_ID": User_ID,
                "Building_ID": building_id,
                "Building_Name": building_name,
                "Project_ID": proj_id,
                "Project_Name_TH": project_nameth,
                "Project_Name_EN": project_nameen
            })
        
        return {"data": data}
    finally:
        cur.close()
        conn.close()
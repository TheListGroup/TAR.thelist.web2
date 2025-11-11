from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists
from function_query_helper import _select_full_office_project_item, _get_project_card_data, _get_project_template_price_card_data, _get_project_template_area_card_data \
    , _get_project_building, _get_subdistrict_data, _get_district_data, _get_province_data, get_project_station, get_project_express_way, get_project_retail \
    , get_project_hospital, get_project_education, _select_full_office_unit_item, _select_full_office_building_item, get_project_image, get_all_unit_carousel_images \
    , get_unit_highlight, get_unit_info_card, get_project_convenience_store, get_project_bank, get_project_cover, get_search_project, get_all_project_carousel_images
from typing import Optional, Tuple, Dict, Any, List
import os
import re
import json
import math

router = APIRouter()

def check_int(num):
    try:
        num = float(round(num,2))
        return str(int(num)) if num.is_integer() else str(num)
    except (ValueError, TypeError):
        return None

def safe_floor(value):
    if value is None:
        return None
    try:
        return float(re.sub(r'\s*ชั้น', '', str(value)).strip())
    except (ValueError, TypeError):
        return None

def format_range(values, formatter):
    values = [v for v in values if v is not None]
    if not values:
        return None

    min_val, max_val = min(values), max(values)
    if min_val == max_val:
        return formatter(min_val)
    return f"{formatter(min_val)}-{formatter(max_val)}"

def format_building_area(values):
    values = [v for v in values if v[1] is not None]
    if not values:
        return None

    formatted_lines = []
    for name, area in values:
        formatted_lines.append(f"{name} {area}")

    return "\n".join(formatted_lines)

def format_floor_plate_display(building_name, plate1, plate2, plate3):
    valid_plates = [p for p in [plate1, plate2, plate3] if p is not None]
    if not valid_plates:
        return None
        
    if len(set(valid_plates)) == 1:
        return f"{building_name} {valid_plates[0]}"
    else:
        plates_str = ", ".join(map(str, valid_plates))
        return f"{building_name} {plates_str}"

def format_data_display(list_data, dict_name, factsheet):
    if len(list_data) == 1 or len(set([item[1] for item in list_data])) == 1:
        data = list_data[0][1]
        if data:
            factsheet[dict_name] = data
        else:
            factsheet[dict_name] = None
    else:
        data_list = []
        for item in list_data:
            building = item[0]
            data = item[1]
            if data:
                data_list.append(building + " " + data)
        if data_list:
            factsheet[dict_name] = "\n".join(data_list)
        else:
            factsheet[dict_name] = None
    
    return factsheet

def get_projects_data_by_ids(cur, project_ids_tuple: tuple) -> list:
    if not project_ids_tuple:
        return []

    placeholders = ','.join(['%s'] * len(project_ids_tuple))
    
    card_query = f"""SELECT Project_ID, Project_Name, Project_Tag_Used, Project_Tag_All, near_by, Highlight, Rent_Price, Project_URL_Tag
                        , Latitude, Longitude
                    FROM source_office_project_carousel_recommend 
                    WHERE Project_ID IN ({placeholders})"""
    
    cur.execute(card_query, project_ids_tuple)
    projects_data = cur.fetchall()
    
    if projects_data:
        images_by_project_id = get_all_project_carousel_images(project_ids_tuple)
        for project in projects_data:
            project["Carousel_Image"] = images_by_project_id.get(project["Project_ID"])
        return projects_data
    else:
        return []

# ----------------------------------------------------- Recommand Unit Card --------------------------------------------------------------------------------------------
@router.get("/recommand-card/{tags}", status_code=200)
def recommand_card_data(
    tags: str,
    _ = Depends(get_current_user),
):
    try:
        MAX_TOTAL_UNITS = 100
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        tag_list = tags.split(";")
        if not tag_list:
            return to_problem(409, "No Tag", "Tag input is empty.")
        
        UNITS_PER_TAG = math.ceil(MAX_TOTAL_UNITS / len(tag_list))
        
        in_clause_placeholders = ', '.join(['%s'] * len(tag_list))

        sql_query = f"""
            WITH RankedUnits AS (
                SELECT
                    u.Unit_ID, u.Title, u.Project_Name, u.Project_Tag_Used, u.Project_Tag_All,
                    u.near_by, u.Rent_Price, u.Rent_Price_Sqm, u.Rent_Price_Status, u.Project_ID, u.Project_URL_Tag as Unit_URL,
                    ROW_NUMBER() OVER (PARTITION BY jt.Found_Tag ORDER BY u.Unit_ID) as rn
                FROM
                    source_office_unit_carousel_recommend u
                CROSS JOIN
                    JSON_TABLE(
                        COALESCE(u.Project_Tag_All, '[]'),
                        '$[*]' COLUMNS (Found_Tag VARCHAR(255) PATH '$')
                    ) AS jt
                WHERE
                    jt.Found_Tag IN ({in_clause_placeholders})
            )
            SELECT DISTINCT
                Unit_ID, Title, Project_Name, Project_Tag_Used, Project_Tag_All,
                near_by, Rent_Price, Rent_Price_Sqm, Rent_Price_Status, Project_ID, Unit_URL
            FROM
                RankedUnits
            WHERE
                rn <= %s
            LIMIT %s
        """
        params = tuple(tag_list) + (UNITS_PER_TAG, MAX_TOTAL_UNITS)
        cur.execute(sql_query, params)
        final_units = cur.fetchall()
        
        cur.close()
        conn.close()
        
        unit_ids = [unit['Unit_ID'] for unit in final_units]
        project_ids = [unit['Project_ID'] for unit in final_units]
        
        images_by_unit_id = get_all_unit_carousel_images(unit_ids, project_ids, True)
        
        for unit in final_units:
            unit['Carousel_Image'] = images_by_unit_id.get(unit['Unit_ID'])
            unit['Unit_URL'] = unit['Unit_URL'] + '/' + str(unit['Unit_ID']).rjust(4, '0')
            
        return final_units

    except Exception as e:
        return to_problem(500, "Server Error", f"Process Error (Database or Query Error): {str(e)}")


# ----------------------------------------------------- Recommand Project Card --------------------------------------------------------------------------------------------
@router.get("/recommand-project-card", status_code=200)
def recommand_project_card_data(
    _ = Depends(get_current_user),
):
    try:
        MAX_TOTAL_PROJECTS = 20
        conn = get_db()
        cur = conn.cursor(dictionary=True)

        cur.execute("""SELECT Project_ID, Project_Name, Project_Tag_Used, Project_Tag_All, near_by, Highlight, Rent_Price, Unit_Count, Project_URL_Tag
                        FROM source_office_project_carousel_recommend order by Unit_Count desc limit %s""", (MAX_TOTAL_PROJECTS,))
        rows = cur.fetchall()
        cur.close()
        conn.close()
        
        if rows:
            project_ids = [project['Project_ID'] for project in rows]
            images_by_project_id = get_all_project_carousel_images(project_ids)
            
            for project in rows:
                project['Carousel_Image'] = images_by_project_id.get(project['Project_ID'])
            return rows
        else:
            return []

    except Exception as e:
        return to_problem(500, "Server Error", f"Process Error (Database or Query Error): {str(e)}")


# ----------------------------------------------------- Project Template --------------------------------------------------------------------------------------------
@router.get("/project-template/{Project_ID}", status_code=200)
def project_template_data(
    Project_ID: int,
    _ = Depends(get_current_user),
):
    data = []
    try:
        proj_data = _select_full_office_project_item(Project_ID)
        if not proj_data:
            return to_problem(404, "Project Not Found", "Project Not Found.")
        
        proj_name = proj_data["Name_EN"]
        if not proj_name:
            return to_problem(404, "Project Name Not Found", "Project Name is None.")
        else:
            data.append({"Project_Name": proj_name})
        
        card_data = _get_project_card_data(Project_ID)
        fields = ["Project_Tag", "Near_By", "Project_Image_All", "Highlight"]
        card_values = card_data if card_data else [None] * 4
        project_image_all = get_project_image(Project_ID)

        data.extend([
            {fields[0]: card_values[0]},
            {fields[1]: card_values[2]},
            {fields[2]: project_image_all},
        ])
        
        overall = {}
        overall["Description"] = proj_data["Project_Description"]
        overall["Highlight"] = card_values[3]
        
        info = {}
        price_card_data = _get_project_template_price_card_data(Project_ID)
        price_values = price_card_data if price_card_data else [None] * 2
        rent_price = price_values[1]
        if rent_price:
            rent_price = rent_price + ';บาท / ตร.ม.'
        else:
            rent_price = 'หากสนใจกรุณาติดต่อ'
        info["Rent_Price"] = rent_price
        
        area_card_data = _get_project_template_area_card_data(Project_ID)
        area_values = area_card_data if area_card_data else [None] * 2
        area = area_values[1]
        if area:
            area = area + ';ตร.ม.'
        else:
            area = 'หากสนใจกรุณาติดต่อ'
        info["Area"] = area
        info["Near_By"] = card_values[2]
        data.append({"Info": info})
        
        building_data = _get_project_building(Project_ID) or None
        trimmed_building_data = [
            {k: v for i, (k, v) in enumerate(item.items()) if i < 6}
            for item in building_data
        ] if building_data else None
        if len(trimmed_building_data) <= 1:
            overall["Building"] = None
        else:
            overall["Building"] = trimmed_building_data
        data.append({"Overall": overall})
        
        factsheet = {}
        factsheet["Name_TH"] = proj_data["Name_TH"]
        factsheet["Name_EN"] = proj_data["Name_EN"]
        
        subdistrict = _get_subdistrict_data(proj_data["SubDistrict_ID"])
        if not subdistrict:
            subdistrict = ''
        district = _get_district_data(proj_data["District_ID"])
        if not district:
            district = ''
        province = _get_province_data(proj_data["Province_ID"])
        if not province:
            province = ''
        
        if subdistrict != '' or district != '' or province != '':
            factsheet["Address"] = " ".join(str(x) for x in [proj_data["Road_Name"], subdistrict, district, province] if x)
        else:
            factsheet["Address"] = None
        
        if building_data:
            floors = [safe_floor(item.get("Floor")) for item in building_data]
            factsheet["Floors"] = format_range(floors, check_int)
            
            finished_years_list = [item.get("Year_Built_Complete") for item in building_data]
            finished_years = [year for year in finished_years_list if year is not None]
            factsheet["Finished_Year"] = check_int(max(finished_years)) if finished_years else None
            
            last_renovated_years_list = [item.get("Year_Last_Renovate") for item in building_data]
            last_renovated_years = [year for year in last_renovated_years_list if year is not None]
            factsheet["Last_Renovated_Year"] = check_int(max(last_renovated_years)) if last_renovated_years else None
            
            building_area = [(item.get("Building_Name"), item.get("Total_Building_Area")) for item in building_data]
            if len(building_area) == 1:
                if building_area is not None:
                    factsheet["Building_Area"] = building_area[0][1]
                else:
                    factsheet["Building_Area"] = None
            else:
                factsheet["Building_Area"] = format_building_area(building_area)
            
            lettable_area = [(item.get("Building_Name"), item.get("Lettable_Area")) for item in building_data]
            if len(lettable_area) == 1:
                if lettable_area is not None:
                    factsheet["Lettable_Area"] = lettable_area[0][1]
                else:
                    factsheet["Lettable_Area"] = None
            else:
                factsheet["Lettable_Area"] = format_building_area(lettable_area)
            
            floor_plates_list = [(item.get("Building_Name"), item.get("Typical_Floor_Plate_1"), item.get("Typical_Floor_Plate_2"), item.get("Typical_Floor_Plate_3")) for item in building_data]
            floor_plates = []
            for name, p1, p2, p3 in floor_plates_list:
                display_string = format_floor_plate_display(name, p1, p2, p3)
                if display_string:
                    floor_plates.append(display_string)
            if floor_plates:
                final_floor_plates = "\n".join(floor_plates)
                factsheet["Floor_Plate"] = final_floor_plates
            else:
                factsheet["Floor_Plate"] = None
        
            ceiling_list = [(item.get("Building_Name"), item.get("Ceiling")) for item in building_data]
            factsheet = format_data_display(ceiling_list, "Ceiling", factsheet)
            
            if trimmed_building_data:
                area_list = [(item.get("Building_Name"), item.get("Area")) for item in trimmed_building_data]
                factsheet = format_data_display(area_list, "Usable_Area", factsheet)
            else:
                factsheet["Usable_Area"] = None
            
            total_lift = sum(item.get("Total_Lift") or 0 for item in building_data)
            if total_lift > 0:
                factsheet["Total_Lift"] = str(total_lift) + ';ตัว'
            else:
                factsheet["Total_Lift"] = None
            
            ac_system = [(item.get("Building_Name"), item.get("AC_System")) for item in building_data]
            factsheet = format_data_display(ac_system, "AC_System", factsheet)
        else:
            factsheet["Floors"] = None
            factsheet["Finished_Year"] = None
            factsheet["Last_Renovated_Year"] = None
            factsheet["Building_Area"] = None
            factsheet["Floor_Plate"] = None
            factsheet["Ceiling"] = None
            factsheet["Usable_Area"] = None
            factsheet["Total_Lift"] = None
        
        factsheet["Price"] = re.sub(';บาท / ตร.ม.', ';บ./ตร.ม.', rent_price)
        
        rai = check_int(proj_data["Land_Rai"]) if proj_data["Land_Rai"] else 0
        ngan = check_int(proj_data["Land_Ngan"]) if proj_data["Land_Ngan"] else 0
        wa = check_int(proj_data["Land_Wa"]) if proj_data["Land_Wa"] else 0
        if rai == 0 and ngan == 0 and wa == 0:
            factsheet["Land"] = None
        else:
            factsheet["Land"] = f"{rai}-{ngan}-{wa};ไร่"
        
        parking = proj_data["Parking_Amount"]
        if parking:
            factsheet["Parking"] = str('{:,}'.format(parking)) + ';คัน'
        else:
            factsheet["Parking"] = None
        
        amenities_columns = ["F_Services_ATM", "F_Services_Bank", "F_Food_Cafe", "F_Food_Restaurant", "F_Food_Foodcourt", "F_Food_Market", "F_Retail_Mall_Shop"
                            , "F_Retail_Conv_Store", "F_Retail_Supermarket", "F_Services_Pharma_Clinic", "F_Services_Hair_Salon", "F_Services_Spa_Beauty"
                            , "F_Others_Gym", "F_Others_EV", "F_Others_Valet", "F_Others_Conf_Meetingroom"]
        amenities_list = [{column: bool(proj_data.get(column)) for column in amenities_columns}]
        factsheet["Amenities"] = amenities_list
        data.append({"Factsheet": factsheet})
        
        floor_plan_data = proj_data["Floor_Plan"]
        if floor_plan_data:
            floor_plan = floor_plan_data
        else:
            floor_plan = None
        data.append({"Floor_Plan": floor_plan})
        
        data.append({"Gallery": {fields[2]: project_image_all}})
        
        unit_available = {}
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        cur.execute("""SELECT a.Project_ID, JSON_ARRAYAGG(JSON_OBJECT('Unit_ID', d.Unit_ID
                                                                    , 'Title', d.Title
                                                                    , 'Project_Name', d.Project_Name
                                                                    , 'Project_Tag_Used', d.Project_Tag_Used
                                                                    , 'Project_Tag_All', d.Project_Tag_All
                                                                    , 'near_by', d.near_by
                                                                    , 'Rent_Price', d.Rent_Price
                                                                    , 'Rent_Price_Sqm', d.Rent_Price_Sqm
                                                                    , 'Rent_Price_Status', d.Rent_Price_Status
                                                                    , 'Unit_URL', concat(d.Project_URL_Tag,'/',LPAD(d.Unit_ID, 4, '0')))) as Unit
                        FROM office_project a
                        join office_building b on a.Project_ID = b.Project_ID
                        join office_unit c on c.Building_ID = b.Building_ID
                        join source_office_unit_carousel_recommend d on c.Unit_ID = d.Unit_ID
                        where a.Project_ID = %s
                        and c.Unit_Status = '1'
                        group by a.Project_ID""", (Project_ID,))
        rows = cur.fetchall()
        cur.close()
        conn.close()
        
        if rows:
            project_data = rows[0]
            units = json.loads(project_data["Unit"])
            unit_id_set = [unit["Unit_ID"] for unit in units]
            unit_carousel_image = get_all_unit_carousel_images(unit_id_set, [Project_ID], True)
            for unit in units:
                unit["Carousel_Image"] = unit_carousel_image.get(unit['Unit_ID'])
                if 'near_by' in unit and unit['near_by'] is not None:
                    unit['near_by'] = json.dumps(unit['near_by'], ensure_ascii=False)
            unit_available["Unit"] = units
        else:
            unit_available["Unit"] = None
        data.append({"Unit_Available": unit_available})
        
        location = {}
        station = get_project_station(Project_ID)
        express_way = get_project_express_way(Project_ID)
        convenience_store = get_project_convenience_store(Project_ID)
        bank = get_project_bank(Project_ID)
        retail = get_project_retail(Project_ID)
        hospital = get_project_hospital(Project_ID)
        education = get_project_education(Project_ID)
        if station:
            location["Station"] = station
        else:
            location["Station"] = None
        if express_way:
            location["Express_Way"] = express_way
        else:
            location["Express_Way"] = None
        if convenience_store:
            location["Convenience_Store"] = convenience_store
        else:
            location["Convenience_Store"] = None
        if bank:
            location["Bank"] = bank
        else:
            location["Bank"] = None
        if retail:
            location["Retail"] = retail
        else:
            location["Retail"] = None
        if hospital:
            location["Hospital"] = hospital
        else:
            location["Hospital"] = None
        if education:
            location["Education"] = education
        else:
            location["Education"] = None
        if proj_data["Latitude"]:
            location["Latitude"] = proj_data["Latitude"]
        else:
            location["Latitude"] = None
        if proj_data["Longitude"]:
            location["Longitude"] = proj_data["Longitude"]
        else:
            location["Longitude"] = None
        data.append({"Location": location})
        
        return data
    except Exception as e:
        return to_problem(500, "Server Error", f"Process Error (Database or Query Error): {str(e)}")

# ----------------------------------------------------- Unit Template --------------------------------------------------------------------------------------------
@router.get("/unit-template/{Unit_ID}", status_code=200)
def unit_template_data(
    Unit_ID: int,
    _ = Depends(get_current_user),
):
    data = []
    try:
        unit_data = _select_full_office_unit_item(Unit_ID)
        if not unit_data:
            return to_problem(404, "Unit Not Found", "Unit Not Found.")
        
        building_data = _select_full_office_building_item(unit_data["Building_ID"])
        if not building_data:
            return to_problem(404, "Building Not Found", "Building Not Found.")
        
        project_data = _select_full_office_project_item(building_data["Project_ID"])
        if not project_data:
            return to_problem(404, "Project Not Found", "Project Not Found.")
        
        unit_name = unit_data["Unit_NO"]
        if not unit_name:
            return to_problem(404, "Unit Name Not Found", "Unit Name is None.")
        else:
            data.append({"Unit_Name": 'ห้อง ' + unit_name})
        
        project_name = project_data["Name_EN"]
        if not project_name:
            return to_problem(404, "Project Name Not Found", "Project Name is None.")
        else:
            data.append({"Project_Name": project_name})
            data.append({"Project_URL": project_data["Project_URL_Tag"]})
        
        building_name = building_data["Building_Name"]
        if not building_name:
            return to_problem(404, "Building Name Not Found", "Building Name is None.")
        else:
            data.append({"Building_Name": 'อาคาร ' + building_name})
        
        images_by_unit_id = get_all_unit_carousel_images([Unit_ID], [project_data["Project_ID"]], False)
        if images_by_unit_id:
            data.append({"Unit_Image": images_by_unit_id.get(Unit_ID)})
        else:
            data.append({"Unit_Image": None})
        
        overall = {}
        overall["Description"] = unit_data["Unit_Description"]
        overall["Highlight"] = get_unit_highlight(Unit_ID)
        
        data.append({"Overall": overall})
        
        building_in_proj = _get_project_building(project_data["Project_ID"])
        
        unit_info = get_unit_info_card(Unit_ID)
        
        floors = [safe_floor(item.get("Floor")) for item in building_in_proj]
        floor = format_range(floors, check_int)
        if floor:
            unit_info["Floors"] = floor + ';ชั้น'
        else:
            unit_info["Floors"] = None
        
        finished_years_list = [item.get("Year_Built_Complete") for item in building_in_proj]
        finished_years = [year for year in finished_years_list if year is not None]
        finished_year = check_int(max(finished_years)) if finished_years else None
        if finished_year:
            unit_info["Finished_Year"] = 'ปีที่สร้างเสร็จ;' + finished_year
        else:
            unit_info["Finished_Year"] = None
        data.append({"Info": unit_info})
        
        factsheet = {}
        factsheet["Unit_Name"] = "ห้อง " + unit_name
        factsheet["Building_Name"] = building_data["Building_Name"]
        factsheet["Project_Name"] = project_data["Name_EN"]
        factsheet["Floor"] = "ชั้น " + unit_data["Floor"]
        
        direction_text = []
        direction_keys = ["เหนือ", "ใต้", "ตะวันออก", "ตะวันตก"]
        direction_values = [unit_data["View_N"], unit_data["View_S"], unit_data["View_E"], unit_data["View_W"]]
        for i, direction in enumerate(direction_values):
            if direction == 1:
                direction_text.append(direction_keys[i])
        if direction_text:
            factsheet["Direction"] = ", ".join(direction_text)
        else:
            factsheet["Direction"] = None
        
        factsheet["Unit_Size"] = unit_info["Unit_Size"]
        
        rent_price = unit_data["Rent_Price"]
        if rent_price:
            factsheet["Rent_Price"] = str('{:,.0f}'.format((rent_price*unit_data["Size"]))) + ";บ. / ด."
            if unit_data["Size"]:
                rent_price_avg = rent_price
                factsheet["Rent_Price_Avg"] = str('{:,.0f}'.format(rent_price_avg)) + ";บ. / ตร.ม."
        else:
            factsheet["Rent_Price"] = None
            factsheet["Rent_Price_Avg"] = None
        
        key_list = ["Ceiling_Full_Structure", "Ceiling_Dropped"]
        text_list = [";เมตร", ";เมตร"]
        for i, data_key in enumerate(key_list):
            if unit_data[data_key]:
                factsheet[data_key] = check_int(unit_data[data_key]) + text_list[i]
            else:
                factsheet[data_key] = None
        
        factsheet["Furnish"] = unit_data["Furnish_Condition"]
        
        if unit_data["Column_InUnit"] == 1:
            factsheet["Column_InUnit"] = "มี"
        elif unit_data["Column_InUnit"] == 0:
            factsheet["Column_InUnit"] = "ไม่มี"
        else:
            factsheet["Column_InUnit"] = None
        
        if unit_data["Combine_Divide"] == 1:
            factsheet["Combine_Divide"] = "มี"
            if unit_data["Min_Divide_Size"]:
                factsheet["Min_Divide_Size"] = check_int(unit_data["Min_Divide_Size"]) + ';ตร.ม.'
            else:
                factsheet["Min_Divide_Size"] = None
        elif unit_data["Combine_Divide"] == 0:
            factsheet["Combine_Divide"] = "ไม่มี"
            factsheet["Min_Divide_Size"] = None
        else:
            factsheet["Combine_Divide"] = None
            factsheet["Min_Divide_Size"] = None
        
        factsheet["Project_Owner"] = building_data["Landlord"]
        factsheet["Management"] = building_data["Management"]
        
        factsheet["Security_Type"] = project_data["Security_Type"]
        
        lift_list = ["Passenger_Lift", "Service_Lift", "Retail_Parking_Lift"]
        for lift in lift_list:
            lift_count = building_data[lift]
            if lift_count:
                factsheet[lift] = check_int(lift_count) + ";ตัว"
            else:
                factsheet[lift] = None
        
        air_start = building_data["ACTime_Start"]
        air_end = building_data["ACTime_End"]
        if air_start and air_end:
            factsheet["ACTime"] = air_start[:-3] + " - " + ":".join([str(int(air_end.split(":")[0])), air_end.split(":")[1]]) + ";น."
        else:
            factsheet["ACTime"] = None
        
        air_data = []
        air_list = ["AC_OT_Weekday_by_Hour", "AC_OT_Weekend_by_Hour"]
        for i, air in enumerate(air_list):
            air_ot = building_data[air]
            if air_ot:
                if i == 0:
                    air_ot_weekday = "จันทร์ - ศุกร์ " + air_ot + ";บ./ชม."
                    air_data.append(air_ot_weekday)
                elif i == 1:
                    air_ot_weekend = "เสาร์ - อาทิตย์ " + air_ot + ";บ./ชม."
                    air_data.append(air_ot_weekend)
        if air_data:
            factsheet["Air_OT"] = "\n".join(air_data)
        else:
            factsheet["Air_OT"] = None
        
        key_list = ["AC_OT_Min_Hour", "Bills_Electricity", "Bills_Water"]
        text_list = [";ชม.", ";บ./หน่วย", ";บ./หน่วย"]
        for i, data_key in enumerate(key_list):
            if building_data[data_key]:
                factsheet[data_key] = check_int(building_data[data_key]) + text_list[i]
            else:
                factsheet[data_key] = None
        
        factsheet["Parking_Ratio"] = building_data["Parking_Ratio"]
        
        if building_data["Parking_Ratio"] and unit_data["Size"]:
            parking_ratio = building_data["Parking_Ratio"].split(":")[-1]
            unit_size = unit_data["Size"]
            factsheet["Parking"] =  math.floor(unit_size / int(parking_ratio))
        else:
            factsheet["Parking"] = None
        
        parking_fee = building_data["Parking_Fee_Car"]
        if parking_fee:
            factsheet["Parking_Fee_Car"] = str('{:,}'.format(parking_fee)) + ";บ./ด."
        else:
            factsheet["Parking_Fee_Car"] = None
        
        key_list = ["Rent_Term", "Rent_Deposit", "Rent_Advance"]
        for i, data_key in enumerate(key_list):
            if unit_data[data_key]:
                factsheet[data_key] = check_int(unit_data[data_key]) + ";เดือน"
            else:
                factsheet[data_key] = None
        
        unit_status = unit_data["Unit_Status"]
        if unit_status == '1':
            factsheet["Unit_Status"] = "พร้อมเข้าอยู่"
        elif unit_status == '2':
            factsheet["Unit_Status"] = "มีผู้เช่าแล้ว"
        else:
            factsheet["Unit_Status"] = None
        
        amenities_columns = ["F_Common_Bathroom", "F_Common_Pantry", "F_Common_Garbageroom"]
        amenities_list = [{column: bool(project_data.get(column)) for column in amenities_columns}]
        factsheet["Amenities"] = amenities_list
        data.append({"Factsheet": factsheet})
        
        images_by_unit_id = get_all_unit_carousel_images([Unit_ID], [project_data["Project_ID"]], False)
        if images_by_unit_id:
            data.append({"Gallery": images_by_unit_id.get(Unit_ID)})
        else:
            data.append({"Gallery": None})
        
        location = {}
        station = get_project_station(project_data["Project_ID"])
        express_way = get_project_express_way(project_data["Project_ID"])
        convenience_store = get_project_convenience_store(project_data["Project_ID"])
        bank = get_project_bank(project_data["Project_ID"])
        retail = get_project_retail(project_data["Project_ID"])
        hospital = get_project_hospital(project_data["Project_ID"])
        education = get_project_education(project_data["Project_ID"])
        if station:
            location["Station"] = station
        else:
            location["Station"] = None
        if express_way:
            location["Express_Way"] = express_way
        else:
            location["Express_Way"] = None
        if convenience_store:
            location["Convenience_Store"] = convenience_store
        else:
            location["Convenience_Store"] = None
        if bank:
            location["Bank"] = bank
        else:
            location["Bank"] = None
        if retail:
            location["Retail"] = retail
        else:
            location["Retail"] = None
        if hospital:
            location["Hospital"] = hospital
        else:
            location["Hospital"] = None
        if education:
            location["Education"] = education
        else:
            location["Education"] = None
        if project_data["Latitude"]:
            location["Latitude"] = project_data["Latitude"]
        else:
            location["Latitude"] = None
        if project_data["Longitude"]:
            location["Longitude"] = project_data["Longitude"]
        else:
            location["Longitude"] = None
        data.append({"Location": location})
        
        return data    
    except Exception as e:
        return to_problem(500, "Server Error", f"Process Error (Database or Query Error): {str(e)}")

# ----------------------------------------------------- Search Box --------------------------------------------------------------------------------------------
@router.get("/search/{Text}", status_code=200)
def search_box(
    Text: str,
    _ = Depends(get_current_user),
):
    if not Text:
        return to_problem(404, "Search Not Found", "Not Have Input.")
    data = []
    search = get_search_project(Text)
    if search:
        data.append(search)
    return data

# ----------------------------------------------------- Search MapResult --------------------------------------------------------------------------------------------
@router.post("/map_result", status_code=200)
def map_result(
    Project_ids: str = Form(None),
    Train_Stations: str = Form(None),
    Tags: str = Form(None),
    Locations: str = Form(None),
    _ = Depends(get_current_user),
):
    def location_manage(column, location_list):
        placeholders = ','.join(['%s'] * len(location_list))
        query = f"""SELECT DISTINCT Project_ID FROM office_project WHERE {column} IN ({placeholders}) AND Project_Status = '1'"""
        cur.execute(query, location_list)
        rows = cur.fetchall()
        if rows:
            ids_from_location = tuple([row["Project_ID"] for row in rows])
            return ids_from_location
        
    if not Project_ids and not Train_Stations and not Tags and not Locations:
        return to_problem(404, "Search Not Found", "Not Have Input.")
    
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        all_project_ids = set()
        
        if Project_ids:
            project_ids_list = Project_ids.split(";") if Project_ids else []
            project_ids_tuple = tuple(int(pid) for pid in project_ids_list if pid.isdigit())
            all_project_ids.update(project_ids_tuple)
        
        if Train_Stations:
            station_codes_tuple = tuple(Train_Stations.split(";")) if Train_Stations else []
            if station_codes_tuple:
                placeholders = ','.join(['%s'] * len(station_codes_tuple))
                station_query = f"""SELECT DISTINCT Project_ID FROM source_office_around_station WHERE Station_Code IN ({placeholders})"""
                cur.execute(station_query, station_codes_tuple)
                rows = cur.fetchall()
                if rows:
                    ids_from_stations = tuple([row["Project_ID"] for row in rows])
                    all_project_ids.update(ids_from_stations)
        
        if Tags:
            tag_list = [tag.strip("'") for tag in Tags.split(";")] if Tags else []
            if tag_list:
                regex_pattern = "|".join(tag_list)
                tag_query = """SELECT DISTINCT Project_ID FROM source_office_project_carousel_recommend WHERE Project_Tag_All REGEXP %s"""
                cur.execute(tag_query, (regex_pattern,))
                rows = cur.fetchall()
                if rows:
                    ids_from_tags = tuple([row["Project_ID"] for row in rows])
                    all_project_ids.update(ids_from_tags)
        
        if Locations:
            location_list = Locations.split(";") if Locations else []
            if location_list:
                district_codes = []
                sub_district_codes = []
                for location in location_list:
                    if len(location) == 4:
                        district_codes.append(location)
                    elif len(location) == 6:
                        sub_district_codes.append(location)
                if district_codes:
                    ids_from_districts = location_manage("District_ID", district_codes)
                    all_project_ids.update(ids_from_districts)
                if sub_district_codes:
                    ids_from_sub_districts = location_manage("SubDistrict_ID", sub_district_codes)
                    all_project_ids.update(ids_from_sub_districts)
        
        if not all_project_ids:
            return []
        
        final_id_tuple = tuple(all_project_ids)
        data_rows = get_projects_data_by_ids(cur, final_id_tuple)
        
        return data_rows
    except Exception as e:
        return to_problem(500, "Server Error", f"Process Error (Database or Query Error): {str(e)}")
    finally:
        cur.close()
        conn.close()
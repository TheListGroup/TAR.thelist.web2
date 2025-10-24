from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists
from function_query_helper import _select_full_office_project_item, _get_project_card_data, _get_project_template_price_card_data, _get_project_template_area_card_data \
    , _get_project_building, _get_subdistrict_data, _get_district_data, _get_province_data, get_image, get_project_station, get_project_express_way, get_project_retail \
    , get_project_hospital, get_project_education, _select_full_office_unit_item, _select_full_office_building_item, get_project_image, get_all_unit_carousel_images
from typing import Optional, Tuple, Dict, Any, List
import os
import re
import json
import math

router = APIRouter()

def check_int(num):
    try:
        num = float(num)
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
                    u.near_by, u.Rent_Price, u.Rent_Price_Sqm, u.Rent_Price_Status, u.Project_ID,
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
                near_by, Rent_Price, Rent_Price_Sqm, Rent_Price_Status, Project_ID
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
        
        images_by_unit_id = get_all_unit_carousel_images(unit_ids, project_ids)
        
        for unit in final_units:
            unit['Carousel_Image'] = images_by_unit_id.get(unit['Unit_ID'])
            
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

        cur.execute("""SELECT Project_ID, Project_Name, Project_Tag_Used, Project_Tag_All, near_by, Highlight, Rent_Price, Unit_Count
                        FROM source_office_project_carousel_recommend order by Unit_Count desc limit %s""", (MAX_TOTAL_PROJECTS,))
        rows = cur.fetchall()
        cur.close()
        conn.close()
        
        if rows:
            for row in rows:
                img_str = get_project_image(row["Project_ID"])
                if img_str:
                    img_data = json.loads(img_str)
                    for img in img_data:
                        if img:
                            url = img['Image_URL']
                            url = re.sub(r'-H-\d+', '-H-400', url)
                            if img['Image_Type'] == 'Cover_Project':
                                match = re.search(r'/(\d+)-H-\d+\.webp', url)
                                if match:
                                    image_num_str = match.group(1)
                                    original_length = len(image_num_str)
                                    new_image_num = int(image_num_str) + 2
                                    img['Image_ID'] = new_image_num
                                    new_image_num_str = str(new_image_num).zfill(original_length)
                                    url = url.replace(image_num_str, new_image_num_str, 1)
                            img['Image_URL'] = url
                    final_compact_string = json.dumps(img_data, ensure_ascii=False, separators=(',', ':'))
                    row['Project_Image'] = final_compact_string
                else:
                    row['Project_Image'] = None
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
            rent_price = rent_price + ' บาท / ตร.ม.'
        else:
            rent_price = 'หากสนใจกรุณาติดต่อ'
        info["Rent_Price"] = rent_price
        
        area_card_data = _get_project_template_area_card_data(Project_ID)
        area_values = area_card_data if area_card_data else [None] * 2
        area = area_values[1]
        if area:
            area = area + ' ตร.ม.'
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
                factsheet["Total_Lift"] = str(total_lift) + ' ตัว'
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
        
        factsheet["Price"] = re.sub(' บาท / ตร.ม.', ' บ./ตร.ม.', rent_price)
        
        rai = check_int(proj_data["Land_Rai"]) if proj_data["Land_Rai"] else 0
        ngan = check_int(proj_data["Land_Ngan"]) if proj_data["Land_Ngan"] else 0
        wa = check_int(proj_data["Land_Wa"]) if proj_data["Land_Wa"] else 0
        if rai == 0 and ngan == 0 and wa == 0:
            factsheet["Land"] = None
        else:
            factsheet["Land"] = f"{rai}-{ngan}-{wa} ไร่"
        
        parking = proj_data["Parking_Amount"]
        if parking:
            factsheet["Parking"] = str('{:,}'.format(parking)) + ' คัน'
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
                                                                    , 'Rent_Price_Status', d.Rent_Price_Status)) as Unit
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
            for unit in units:
                unit["Carousel_Image"] = get_image(unit["Unit_ID"])
            unit_available["Unit"] = units
        else:
            unit_available["Unit"] = None
        data.append({"Unit_Available": unit_available})
        
        location = {}
        station = get_project_station(Project_ID)
        express_way = get_project_express_way(Project_ID)
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
            data.append({"Unit_Name": unit_name})
        
        project_name = project_data["Name_EN"]
        if not project_name:
            return to_problem(404, "Project Name Not Found", "Project Name is None.")
        else:
            data.append({"Project_Name": project_name})
        
        unit_image = get_image(Unit_ID)
        data.append({"Unit_Image": unit_image})
        
        return data
    except Exception as e:
        return to_problem(500, "Server Error", f"Process Error (Database or Query Error): {str(e)}")
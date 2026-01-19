from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem
from function_query_helper import _office_point_calculate, gen_link, find_unit_virtual_room
from typing import Optional, Tuple, Dict, Any, List
import math
import json

router = APIRouter()

# ----------------------------------------------------- Check Quota Credit --------------------------------------------------------------------------------------------
@router.get("/quota-credit/{Tenant_ID}", status_code=200)
def check_quota_credit(
    Tenant_ID: int,
    _ = Depends(get_current_user),
):
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        cur.execute("""select Member_Status, Normal_Search_Remaining, Premium_Search_Remaining from tenant_user where Tenant_ID = %s""", (Tenant_ID,))
        rows = cur.fetchone()
        
        if rows['Member_Status'] == 'Normal':
            quota = rows['Normal_Search_Remaining']
            if quota == 0:
                return {'Member_Type': rows['Member_Status'], 'Status': False, 'Message': "ตอนนี้ credit การทำ questionnaire ของคุณหมดแล้ว กรุณาทำการยืนยันตัวตนเพื่อเป็น premium member โดยการยื่นเอกสารเพิ่มเติม หรือติดต่อเจ้าหน้าที่โดยตรง 094-653-3971, LINE: @REALLEASE , email: contact@real-lease.agency"}
            else:
                return {'Member_Type': rows['Member_Status'], 'Status': True}
        else:
            quota = rows['Premium_Search_Remaining']
            if quota == 0:
                return {'Member_Type': rows['Member_Status'], 'Status': False, 'Message': "ตอนนี้ credit การทำ questionnaire ของคุณหมดแล้ว กรุณาติดต่อเจ้าหน้าที่โดยตรง 094-653-3971, LINE: @REALLEASE , email: contact@real-lease.agency เพื่อขอ credit เพิ่มเติม"}
            else:
                return {'Member_Type': rows['Member_Status'], 'Status': True}
    except Exception as e:
        return to_problem(500, "Server Error", f"Process Error (Database or Query Error): {str(e)}")
    finally:
        cur.close()
        conn.close()

@router.get("/variable-questionnaire", status_code=200)
def variable_questionnaire(
    _ = Depends(get_current_user),
):
    return {"default_score": 0.5, "minimum_cost": 100000, "maximum_cost": 200000, "cost_min_for_k": 20, "cost_max_for_k": 15
            , "lease_term": 3, "lease_years_per_term": 3, "work_start": '10:00:00', "work_end": '18:00:00', 'work_sat': 0, "work_sun": 0
            , "parking_needed": 0, "cost_weight_group": 40, "percent_cost_group": 100, "avg_weekdays_per_month": 21.75
            , "avg_saturdays_per_month": 4.35, "avg_sundays_per_month": 4.35, "btu_per_sqm": 600, "eer_btu_per_wh": 12, "elec_thb_per_kwh": 6
            , "split_capex_per_sqm": 1500, "split_maint_pct_per_year": 0.05, "flooring_thb_per_sqm": 900, "ceiling_thb_per_sqm": 400
            , "elec_usage_kwh_per_sqm_month": 8, "elec_default_thb_per_sqm": 50, "water_usage_m3_per_sqm_month": 0.6, "water_default_thb_per_sqm": 10
            , "parking_fee_default": 2000, "actime_start_default": '07:30:00', "actime_end_default": '18:00:00', "minimum_size": 80, "maximum_size": 200
            , "size_weight_group": 30, "percent_size_group": 100, "size_tol_low_pct": 0.10, "size_tol_high_pct": 0.20, "station_need": 0, "expressway_need": 0
            , "location_weight_group": 15, "percent_location_group": 75, "percent_station_group": 15, "percent_expressway_group": 10, "train_decay_k": 2.31
            , "express_decay_k": 0.693, "yarn_dist_min": 0, "yarn_dist_max": 500, "min_yarn_score": 0.0 , "max_yarn_score": 1.0, "road_dist_min": 100
            , "road_dist_max": 400, "min_road_score": 0.0, "max_road_score": 1.0, "station_radius_dist_min": 500, "station_radius_dist_max": 1000
            , "min_station_radius_score": 0.0, "max_station_radius_score": 1.0, "min_station_radius_score": 0.0, "max_station_radius_score": 1.0
            , "building_weight_group": 5, "percent_building_age_group": 35, "percent_building_security_group": 30, "percent_building_pantry_group": 20
            , "percent_building_passenger_lift_group": 10, "percent_building_service_lift_group": 5, "pantry_pref": "ใช้ 1 (เฉยๆ = 0 สำคัญ = 1 สำคัญมาก = 2)"
            , "bath_pref": "ใช้ 2 (ไม่ต้องการ = 0 เฉยๆ = 1 สำคัญ = 2)", "unit_weight_group": 5, "percent_unit_direction_group": 30
            , "percent_unit_bathroom_group": 25, "percent_unit_pantry_group": 25, "percent_unit_floor_group": 10, "percent_unit_ceiling_group": 8
            , "percent_unit_column_group": 2, "dir_n_score": 1.0, "dir_s_score": 1.0, "dir_e_score": 0.5, "dir_w_score": 0.5, "min_ceiling_clear": 2.7
            , "fac_cafe_pref": 1, "fac_foodcourt_pref": 1, "fac_market_pref": 1, "fac_conv_store_pref": 1, "fac_ev_pref": 1, "fac_bank_pref": 1 
            , "fac_restaurant_pref": 1, "fac_phamacy_pref": 1, "convenient_weight_group": 5, "percent_cafe_group": 15, "percent_food_court_group": 15
            , "percent_market_group": 15, "percent_conv_store_group": 15, "percent_ev_charger_group": 15, "percent_bank_group": 10, "percent_restuarant_group": 10
            , "percent_phamacy_group": 5}

@router.post("/admin_office_point", status_code=200)
def admin_office_point(
    cost_weight_group: str = Form(None), #var
    percent_cost_group: str = Form(None), #var
    minimum_cost: str = Form(None),
    maximum_cost: str = Form(None),
    cost_min_for_k: str = Form(None), #var
    cost_max_for_k: str = Form(None), #var
    lease_term: str = Form(None),
    lease_years_per_term: str = Form(None),
    work_start: str = Form(None),
    work_end: str = Form(None),
    work_sat: str = Form(None),
    work_sun: str = Form(None),
    avg_weekdays_per_month: str = Form(None), #var
    avg_saturdays_per_month: str = Form(None), #var
    avg_sundays_per_month: str = Form(None), #var
    btu_per_sqm: str = Form(None), #var
    eer_btu_per_wh: str = Form(None), #var
    elec_thb_per_kwh: str = Form(None), #var
    split_capex_per_sqm: str = Form(None), #var
    split_maint_pct_per_year: str = Form(None), #var
    flooring_thb_per_sqm: str = Form(None), #var
    ceiling_thb_per_sqm: str = Form(None), #var
    elec_usage_kwh_per_sqm_month: str = Form(None), #var
    elec_default_thb_per_sqm: str = Form(None), #var
    water_usage_m3_per_sqm_month: str = Form(None), #var
    water_default_thb_per_sqm: str = Form(None), #var
    parking_needed: str = Form(None), #var
    parking_fee_default: str = Form(None), #var
    actime_start_default: str = Form(None), #var
    actime_end_default: str = Form(None), #var
    
    size_weight_group: str = Form(None), #var
    percent_size_group: str = Form(None), #var
    minimum_size: str = Form(None),
    maximum_size: str = Form(None),
    size_tol_low_pct: str = Form(None), #var
    size_tol_high_pct: str = Form(None), #var
    
    location_weight_group: str = Form(None), #var
    percent_location_group: str = Form(None), #var
    percent_station_group: str = Form(None), #var
    percent_expressway_group: str = Form(None), #var
    location_yarn: str = Form(None),
    location_road: str = Form(None),
    location_station: str = Form(None),
    station_need: str = Form(None),
    expressway_need: str = Form(None),
    train_decay_k: str = Form(None), #var
    express_decay_k: str = Form(None), #var
    yarn_dist_min: str = Form(None),
    yarn_dist_max: str = Form(None),
    max_yarn_score: str = Form(None),
    min_yarn_score: str = Form(None),
    road_dist_min: str = Form(None),
    road_dist_max: str = Form(None),
    max_road_score: str = Form(None),
    min_road_score: str = Form(None),
    station_radius_dist_min: str = Form(None),
    station_radius_dist_max: str = Form(None),
    max_station_radius_score: str = Form(None),
    min_station_radius_score: str = Form(None),
    
    building_weight_group: str = Form(None), #var
    percent_building_age_group: str = Form(None), #var
    percent_building_security_group: str = Form(None), #var
    percent_building_pantry_group: str = Form(None), #var
    percent_building_passenger_lift_group: str = Form(None), #var
    percent_building_service_lift_group: str = Form(None), #var
    
    unit_weight_group: str = Form(None), #var
    percent_unit_direction_group: str = Form(None), #var
    percent_unit_bathroom_group: str = Form(None), #var
    percent_unit_pantry_group: str = Form(None), #var
    percent_unit_floor_group: str = Form(None), #var
    percent_unit_ceiling_group: str = Form(None), #var
    percent_unit_column_group: str = Form(None), #var
    dir_n_score: str = Form(None), #var
    dir_s_score: str = Form(None), #var
    dir_e_score: str = Form(None), #var
    dir_w_score: str = Form(None), #var
    pantry_pref: str = Form(None),
    bath_pref: str = Form(None),
    min_ceiling_clear: str = Form(None), #var
    
    convenient_weight_group: str = Form(None), #var
    percent_cafe_group: str = Form(None), #var
    percent_food_court_group: str = Form(None), #var
    percent_market_group: str = Form(None), #var
    percent_conv_store_group: str = Form(None), #var
    percent_ev_charger_group: str = Form(None), #var
    percent_bank_group: str = Form(None), #var
    percent_restuarant_group: str = Form(None), #var
    percent_phamacy_group: str = Form(None), #var
    fac_cafe_pref: str = Form(None),
    fac_foodcourt_pref: str = Form(None),
    fac_market_pref: str = Form(None),
    fac_conv_store_pref: str = Form(None),
    fac_ev_pref: str = Form(None),
    fac_bank_pref: str = Form(None),
    fac_restaurant_pref: str = Form(None),
    fac_phamacy_pref: str = Form(None),
    _ = Depends(get_current_user),
):
    try:
        default_score = 0.5
        
        minimum_cost = 100000 if not minimum_cost else int(minimum_cost)
        maximum_cost = 200000 if not maximum_cost else int(maximum_cost)
        if minimum_cost > maximum_cost:
            minimum_cost, maximum_cost = maximum_cost, minimum_cost
        if minimum_cost == maximum_cost:
            maximum_cost = minimum_cost + 1
        cost_min_for_k = 20 if not cost_min_for_k else float(cost_min_for_k)
        cost_max_for_k = 15 if not cost_max_for_k else float(cost_max_for_k)
        
        cost_weight_group = 40 if not cost_weight_group else int(cost_weight_group) #var
        percent_cost_group = 100 if not percent_cost_group else int(percent_cost_group) #var
        lease_term = 3 if not lease_term else int(lease_term)
        lease_years_per_term = None if not lease_years_per_term else int(lease_years_per_term)
        if lease_years_per_term is None:
            lease_years_per_term = 3
        elif lease_years_per_term >= 12:
            lease_years_per_term = 12
        else: 
            lease_years_per_term = lease_years_per_term
        work_start = '10:00:00' if not work_start else work_start
        work_end = '18:00:00' if not work_end else work_end 
        work_sat = 0 if not work_sat else int(work_sat)
        work_sun = 0 if not work_sun else int(work_sun)
        avg_weekdays_per_month = 21.75 if not avg_weekdays_per_month else float(avg_weekdays_per_month) #var
        avg_saturdays_per_month = 4.35 if not avg_saturdays_per_month else float(avg_saturdays_per_month) #var
        avg_sundays_per_month = 4.35 if not avg_sundays_per_month else float(avg_sundays_per_month) #var
        btu_per_sqm = 600 if not btu_per_sqm else float(btu_per_sqm) #var
        eer_btu_per_wh = 12 if not eer_btu_per_wh else float(eer_btu_per_wh) #var
        elec_thb_per_kwh = 6 if not elec_thb_per_kwh else float(elec_thb_per_kwh) #var
        split_capex_per_sqm = 1500 if not split_capex_per_sqm else int(split_capex_per_sqm) #var
        split_maint_pct_per_year = 0.05 if not split_maint_pct_per_year else float(split_maint_pct_per_year) #var
        flooring_thb_per_sqm = 900 if not flooring_thb_per_sqm else float(flooring_thb_per_sqm) #var
        ceiling_thb_per_sqm = 400 if not ceiling_thb_per_sqm else float(ceiling_thb_per_sqm) #var
        elec_usage_kwh_per_sqm_month = 8 if not elec_usage_kwh_per_sqm_month else int(elec_usage_kwh_per_sqm_month) #var
        elec_default_thb_per_sqm = 50 if not elec_default_thb_per_sqm else int(elec_default_thb_per_sqm) #var
        water_usage_m3_per_sqm_month = 0.6 if not water_usage_m3_per_sqm_month else float(water_usage_m3_per_sqm_month) #var
        water_default_thb_per_sqm = 10 if not water_default_thb_per_sqm else int(water_default_thb_per_sqm) #var
        parking_needed = 0 if not parking_needed else int(parking_needed)
        parking_fee_default = 2000 if not parking_fee_default else int(parking_fee_default) #var
        actime_start_default = '07:30:00' if not actime_start_default else actime_start_default #var
        actime_end_default = '18:00:00' if not actime_end_default else actime_end_default #var
        
        size_weight_group = 30 if not size_weight_group else int(size_weight_group) #var
        percent_size_group = 100 if not percent_size_group else int(percent_size_group) #var
        minimum_size = 80 if not minimum_size else float(minimum_size)
        maximum_size = 200 if not maximum_size else float(maximum_size)
        size_tol_low_pct = 0.10 if not size_tol_low_pct else float(size_tol_low_pct) #var
        size_tol_high_pct = 0.20 if not size_tol_high_pct else float(size_tol_high_pct) #var
        
        location_weight_group = 15 if not location_weight_group else int(location_weight_group) #var
        percent_location_group = 75 if not percent_location_group else int(percent_location_group) #var
        percent_station_group = 15 if not percent_station_group else int(percent_station_group) #var
        percent_expressway_group = 10 if not percent_expressway_group else int(percent_expressway_group) #var
        station_need = 0 if not station_need else int(station_need)
        expressway_need = 0 if not expressway_need else int(expressway_need)
        train_decay_k = 2.31 if not train_decay_k else float(train_decay_k) #var
        express_decay_k = 0.693 if not express_decay_k else float(express_decay_k) #var
        
        building_weight_group = 5 if not building_weight_group else int(building_weight_group) #var
        percent_building_age_group = 35 if not percent_building_age_group else int(percent_building_age_group) #var
        percent_building_security_group = 30 if not percent_building_security_group else int(percent_building_security_group) #var
        percent_building_pantry_group = 20 if not percent_building_pantry_group else int(percent_building_pantry_group) #var
        percent_building_passenger_lift_group = 10 if not percent_building_passenger_lift_group else int(percent_building_passenger_lift_group) #var
        percent_building_service_lift_group = 5 if not percent_building_service_lift_group else int(percent_building_service_lift_group) #var
        
        unit_weight_group = 5 if not unit_weight_group else int(unit_weight_group) #var
        percent_unit_direction_group = 30 if not percent_unit_direction_group else int(percent_unit_direction_group) #var
        percent_unit_bathroom_group = 25 if not percent_unit_bathroom_group else int(percent_unit_bathroom_group) #var
        percent_unit_pantry_group = 25 if not percent_unit_pantry_group else int(percent_unit_pantry_group) #var
        percent_unit_floor_group = 10 if not percent_unit_floor_group else int(percent_unit_floor_group) #var
        percent_unit_ceiling_group = 8 if not percent_unit_ceiling_group else int(percent_unit_ceiling_group) #var
        percent_unit_column_group = 2 if not percent_unit_column_group else int(percent_unit_column_group) #var
        dir_n_score = 1.0 if not dir_n_score else float(dir_n_score) #var
        dir_s_score = 1.0 if not dir_s_score else float(dir_s_score) #var
        dir_e_score = 0.5 if not dir_e_score else float(dir_e_score) #var
        dir_w_score = 0.5 if not dir_w_score else float(dir_w_score) #var
        pantry_pref = 1 if not pantry_pref else int(pantry_pref)
        bath_pref = 2 if not bath_pref else int(bath_pref)
        min_ceiling_clear = 2.7 if not min_ceiling_clear else float(min_ceiling_clear) #var
        
        convenient_weight_group = 5 if not convenient_weight_group else int(convenient_weight_group) #var
        percent_cafe_group = 15 if not percent_cafe_group else int(percent_cafe_group) #var
        percent_food_court_group = 15 if not percent_food_court_group else int(percent_food_court_group) #var
        percent_market_group = 15 if not percent_market_group else int(percent_market_group) #var
        percent_conv_store_group = 15 if not percent_conv_store_group else int(percent_conv_store_group) #var
        percent_ev_charger_group = 15 if not percent_ev_charger_group else int(percent_ev_charger_group) #var
        percent_bank_group = 10 if not percent_bank_group else int(percent_bank_group) #var
        percent_restuarant_group = 10 if not percent_restuarant_group else int(percent_restuarant_group) #var
        percent_phamacy_group = 5 if not percent_phamacy_group else int(percent_phamacy_group) #var
        fac_cafe_pref = 1 if not fac_cafe_pref else int(fac_cafe_pref)
        fac_foodcourt_pref = 1 if not fac_foodcourt_pref else int(fac_foodcourt_pref)
        fac_market_pref = 1 if not fac_market_pref else int(fac_market_pref)
        fac_conv_store_pref = 1 if not fac_conv_store_pref else int(fac_conv_store_pref)
        fac_ev_pref = 1 if not fac_ev_pref else int(fac_ev_pref)
        fac_bank_pref = 1 if not fac_bank_pref else int(fac_bank_pref)
        fac_restaurant_pref = 1 if not fac_restaurant_pref else int(fac_restaurant_pref)
        fac_phamacy_pref = 1 if not fac_phamacy_pref else int(fac_phamacy_pref)

        yarn_dist_min = 0 if not yarn_dist_min else int(yarn_dist_min)
        yarn_dist_max = 500 if not yarn_dist_max else int(yarn_dist_max)
        max_yarn_score = 1.0 if not max_yarn_score else float(max_yarn_score)
        min_yarn_score = 0.0 if not min_yarn_score else float(min_yarn_score)
        
        road_dist_min = 100 if not road_dist_min else int(road_dist_min)
        road_dist_max = 400 if not road_dist_max else int(road_dist_max)
        max_road_score = 1.0 if not max_road_score else float(max_road_score)
        min_road_score = 0.0 if not min_road_score else float(min_road_score)
        
        station_radius_dist_min = 500 if not station_radius_dist_min else int(station_radius_dist_min)
        station_radius_dist_max = 1000 if not station_radius_dist_max else int(station_radius_dist_max)
        max_station_radius_score = 1.0 if not max_station_radius_score else float(max_station_radius_score)
        min_station_radius_score = 0.0 if not min_station_radius_score else float(min_station_radius_score)
        
        w_price = (cost_weight_group * percent_cost_group) / 100
        lease_years = lease_term * lease_years_per_term
        lease_months = lease_years * 12
        cost_min_distance = int(minimum_cost) * (cost_min_for_k/100) #test
        cost_max_distance = int(maximum_cost) * (cost_max_for_k/100) #test
        cost_min_k = -math.log(0.01 / 0.5) / cost_min_distance #test
        cost_max_k = -math.log(0.01 / 0.5) / cost_max_distance #test
        
        w_size = (size_weight_group * percent_size_group) / 100
        
        w_location = (location_weight_group * percent_location_group) / 100
        w_station = (location_weight_group * percent_station_group) / 100
        w_expressway = (location_weight_group * percent_expressway_group) / 100
        location_yarn_list = [yarn.strip("'") for yarn in location_yarn.split(";")] if location_yarn else []
        if location_yarn_list:
            pattern = "|".join(location_yarn_list)
            location_yarn_regex =  f"and c.Place_Name_TH REGEXP '{pattern}'"
        else:
            location_yarn_regex = f"and c.Place_Name_TH REGEXP 'xxx'"
        location_road_list = [road.strip("'") for road in location_road.split(";")] if location_road else []
        if location_road_list:
            pattern = "|".join(location_road_list)
            location_road_regex = f"and c.Road_Name_TH REGEXP '{pattern}'"
        else:
            location_road_regex = f"and c.Road_Name_TH REGEXP 'xxx'"
        location_station_list = [station.strip("'") for station in location_station.split(";")] if location_station else []
        if location_station_list:
            pattern = "|".join(location_station_list)
            location_station_regex = f"and mtsmr.Station_THName_Display REGEXP '{pattern}'"
        else:
            location_station_regex = f"and mtsmr.Station_THName_Display REGEXP 'xxx'"
        
        w_age = (building_weight_group * percent_building_age_group) / 100
        w_security = (building_weight_group * percent_building_security_group) / 100
        w_pantry = (building_weight_group * percent_building_pantry_group) / 100
        w_passenger_lift = (building_weight_group * percent_building_passenger_lift_group) / 100
        w_service_lift = (building_weight_group * percent_building_service_lift_group) / 100
        
        w_direction = (unit_weight_group * percent_unit_direction_group) / 100
        w_bathroom = (unit_weight_group * percent_unit_bathroom_group) / 100
        w_pantry_inunit = (unit_weight_group * percent_unit_pantry_group) / 100
        w_floor = (unit_weight_group * percent_unit_floor_group) / 100
        w_ceiling = (unit_weight_group * percent_unit_ceiling_group) / 100
        w_columns = (unit_weight_group * percent_unit_column_group) / 100
        
        w_fac_cafe = (convenient_weight_group * percent_cafe_group) / 100
        w_fac_foodcourt = (convenient_weight_group * percent_food_court_group) / 100
        w_fac_market = (convenient_weight_group * percent_market_group) / 100
        w_fac_conv_store = (convenient_weight_group * percent_conv_store_group) / 100
        w_fac_ev = (convenient_weight_group * percent_ev_charger_group) / 100
        w_fac_bank = (convenient_weight_group * percent_bank_group) / 100
        w_fac_restaurant = (convenient_weight_group * percent_restuarant_group) / 100
        w_fac_pharma_clinic = (convenient_weight_group * percent_phamacy_group) / 100
        
        bathroom_condition = 'u.Bathroom_InUnit <> 1' if bath_pref == 0 else None
        pantry_condition = 'u.Pantry_InUnit = 1' if pantry_pref == 2 else None
        if bathroom_condition is not None and pantry_condition is not None:
            in_unit_condition = 'where ' + bathroom_condition + ' and ' + pantry_condition
        elif bathroom_condition is not None:
            in_unit_condition = 'where ' + bathroom_condition
        elif pantry_condition is not None:
            in_unit_condition = 'where ' + pantry_condition
        else:
            in_unit_condition = ''
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")
    
    try:        
        rows = _office_point_calculate(actime_start_default, actime_end_default, work_start, work_end, in_unit_condition, 
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
            fac_phamacy_pref, fac_ev_pref, w_price, w_size, w_location,
            w_floor, w_direction, w_ceiling, w_columns, w_bathroom,
            w_pantry_inunit, w_pantry, w_security, w_passenger_lift, w_service_lift, 
            w_age, w_station, w_expressway, w_fac_bank, w_fac_cafe, 
            w_fac_restaurant, w_fac_foodcourt, w_fac_market, w_fac_conv_store, w_fac_pharma_clinic, 
            w_fac_ev)
        return rows
    except Exception as e:
        return to_problem(409, "Conflict", f"query error: {e}")

@router.post("/tenant_office_point", status_code=200)
def tenant_office_point(
    Tenant_ID: int = Form(...), #p1
    Member_Type: str = Form(...), #p1
    
    cost_weight_group: str = Form(None), #p11
    minimum_cost: str = Form(None), #p2
    maximum_cost: str = Form(None), #p2
    lease_term: str = Form(None), #p6
    work_start: str = Form(None), #p5
    work_end: str = Form(None), #p5
    work_sat: str = Form(None), #p5
    work_sun: str = Form(None), #p5
    parking_needed: str = Form(None), #p4
    
    size_weight_group: str = Form(None), #p11
    minimum_size: str = Form(None), #p3
    maximum_size: str = Form(None), #p3
    
    location_weight_group: str = Form(None), #p11
    location_yarn: str = Form(None), #p7
    location_road: str = Form(None), #p7
    location_station: str = Form(None), #p7
    station_need: str = Form(None), #p8
    expressway_need: str = Form(None), #p8
    
    building_weight_group: str = Form(None), #p11
    
    unit_weight_group: str = Form(None), #p11
    pantry_pref: str = Form(None), #p9
    bath_pref: str = Form(None), #p9
    
    convenient_weight_group: str = Form(None), #p11
    fac_cafe_pref: str = Form(None), #p10
    fac_foodcourt_pref: str = Form(None), #p10
    fac_market_pref: str = Form(None), #p10
    fac_conv_store_pref: str = Form(None), #p10
    fac_ev_pref: str = Form(None), #p10
    fac_bank_pref: str = Form(None), #p10
    fac_restaurant_pref: str = Form(None), #p10
    fac_pharmacy_pref: str = Form(None), #p10
    _ = Depends(get_current_user),
):
    try:
        default_score = 0.5
        
        minimum_cost = 100000 if not minimum_cost else int(minimum_cost)
        maximum_cost = 200000 if not maximum_cost else int(maximum_cost)
        if minimum_cost > maximum_cost:
            minimum_cost, maximum_cost = maximum_cost, minimum_cost
        elif minimum_cost == maximum_cost:
            maximum_cost = minimum_cost + 1
        
        cost_weight_group = 40 if not cost_weight_group else int(cost_weight_group)
        percent_cost_group = 100
        lease_term = 3 if not lease_term else int(lease_term)
        if lease_term >= 12:
            lease_term = 12
        work_start = '10:00:00' if not work_start else work_start
        work_end = '18:00:00' if not work_end else work_end 
        work_sat = 0 if not work_sat else int(work_sat)
        work_sun = 0 if not work_sun else int(work_sun)
        avg_weekdays_per_month = 21.75
        avg_saturdays_per_month = 4.35
        avg_sundays_per_month = 4.35
        btu_per_sqm = 600
        eer_btu_per_wh = 12
        elec_thb_per_kwh = 6
        split_capex_per_sqm = 1500
        split_maint_pct_per_year = 0.05
        flooring_thb_per_sqm = 900
        ceiling_thb_per_sqm = 400
        elec_usage_kwh_per_sqm_month = 8
        elec_default_thb_per_sqm = 50
        water_usage_m3_per_sqm_month = 0.6
        water_default_thb_per_sqm = 10
        parking_needed = 0 if not parking_needed else int(parking_needed)
        parking_fee_default = 2000
        actime_start_default = '07:30:00'
        actime_end_default = '18:00:00'
        
        size_weight_group = 30 if not size_weight_group else int(size_weight_group)
        percent_size_group = 100
        minimum_size = 80 if not minimum_size else float(minimum_size)
        maximum_size = 200 if not maximum_size else float(maximum_size)
        size_tol_low_pct = 0.1
        size_tol_high_pct = 0.2
        
        location_weight_group = 15 if not location_weight_group else int(location_weight_group)
        percent_location_group = 75
        percent_station_group = 15
        percent_expressway_group = 10
        station_need = 0 if not station_need else int(station_need)
        expressway_need = 0 if not expressway_need else int(expressway_need)
        train_decay_k = 2.31
        express_decay_k = 0.693
        
        building_weight_group = 5 if not building_weight_group else int(building_weight_group)
        percent_building_age_group = 35
        percent_building_security_group = 30
        percent_building_pantry_group = 20
        percent_building_passenger_lift_group = 10
        percent_building_service_lift_group = 5
        
        unit_weight_group = 5 if not unit_weight_group else int(unit_weight_group)
        percent_unit_direction_group = 30
        percent_unit_bathroom_group = 25
        percent_unit_pantry_group = 25
        percent_unit_floor_group = 10
        percent_unit_ceiling_group = 8
        percent_unit_column_group = 2
        dir_n_score = 1.0
        dir_s_score = 1.0
        dir_e_score = 0.5
        dir_w_score = 0.5
        pantry_pref = 1 if not pantry_pref else int(pantry_pref)
        bath_pref = 2 if not bath_pref else int(bath_pref)
        min_ceiling_clear = 2.7
        
        convenient_weight_group = 5 if not convenient_weight_group else int(convenient_weight_group)
        percent_cafe_group = 15
        percent_food_court_group = 15
        percent_market_group = 15
        percent_conv_store_group = 15
        percent_ev_charger_group = 15
        percent_bank_group = 10
        percent_restuarant_group = 10
        percent_phamacy_group = 5
        fac_cafe_pref = 1 if not fac_cafe_pref else int(fac_cafe_pref)
        fac_foodcourt_pref = 1 if not fac_foodcourt_pref else int(fac_foodcourt_pref)
        fac_market_pref = 1 if not fac_market_pref else int(fac_market_pref)
        fac_conv_store_pref = 1 if not fac_conv_store_pref else int(fac_conv_store_pref)
        fac_ev_pref = 1 if not fac_ev_pref else int(fac_ev_pref)
        fac_bank_pref = 1 if not fac_bank_pref else int(fac_bank_pref)
        fac_restaurant_pref = 1 if not fac_restaurant_pref else int(fac_restaurant_pref)
        fac_pharmacy_pref = 1 if not fac_pharmacy_pref else int(fac_pharmacy_pref)

        yarn_dist_min = 0
        yarn_dist_max = 500
        max_yarn_score = 1.0
        min_yarn_score = 0.0
        
        road_dist_min = 100
        road_dist_max = 400
        max_road_score = 1.0
        min_road_score = 0.0
        
        station_radius_dist_min = 500
        station_radius_dist_max = 1000
        max_station_radius_score = 1.0
        min_station_radius_score = 0.0
        
        w_price = (cost_weight_group * percent_cost_group) / 100
        lease_years = lease_term
        lease_months = lease_years * 12
        cost_min_k = 0.00019
        cost_max_k = 0.00023
        
        w_size = (size_weight_group * percent_size_group) / 100
        
        w_location = (location_weight_group * percent_location_group) / 100
        w_station = (location_weight_group * percent_station_group) / 100
        w_expressway = (location_weight_group * percent_expressway_group) / 100
        location_yarn_list = [yarn.strip("'") for yarn in location_yarn.split(";")] if location_yarn else []
        if location_yarn_list:
            pattern = "|".join(location_yarn_list)
            location_yarn_regex =  f"and c.Place_Name_TH REGEXP '{pattern}'"
        else:
            location_yarn_regex = ""
        location_road_list = [road.strip("'") for road in location_road.split(";")] if location_road else []
        if location_road_list:
            pattern = "|".join(location_road_list)
            location_road_regex = f"and c.Road_Name_TH REGEXP '{pattern}'"
        else:
            location_road_regex = ""
        location_station_list = [station.strip("'") for station in location_station.split(";")] if location_station else []
        if location_station_list:
            pattern = "|".join(location_station_list)
            location_station_regex = f"and mtsmr.Station_THName_Display REGEXP '{pattern}'"
        else:
            location_station_regex = ""
        
        w_age = (building_weight_group * percent_building_age_group) / 100
        w_security = (building_weight_group * percent_building_security_group) / 100
        w_pantry = (building_weight_group * percent_building_pantry_group) / 100
        w_passenger_lift = (building_weight_group * percent_building_passenger_lift_group) / 100
        w_service_lift = (building_weight_group * percent_building_service_lift_group) / 100
        
        w_direction = (unit_weight_group * percent_unit_direction_group) / 100
        w_bathroom = (unit_weight_group * percent_unit_bathroom_group) / 100
        w_pantry_inunit = (unit_weight_group * percent_unit_pantry_group) / 100
        w_floor = (unit_weight_group * percent_unit_floor_group) / 100
        w_ceiling = (unit_weight_group * percent_unit_ceiling_group) / 100
        w_columns = (unit_weight_group * percent_unit_column_group) / 100
        
        w_fac_cafe = (convenient_weight_group * percent_cafe_group) / 100
        w_fac_foodcourt = (convenient_weight_group * percent_food_court_group) / 100
        w_fac_market = (convenient_weight_group * percent_market_group) / 100
        w_fac_conv_store = (convenient_weight_group * percent_conv_store_group) / 100
        w_fac_ev = (convenient_weight_group * percent_ev_charger_group) / 100
        w_fac_bank = (convenient_weight_group * percent_bank_group) / 100
        w_fac_restaurant = (convenient_weight_group * percent_restuarant_group) / 100
        w_fac_pharma_clinic = (convenient_weight_group * percent_phamacy_group) / 100
        
        bathroom_condition = 'u.Bathroom_InUnit <> 1' if bath_pref == 0 else None
        pantry_condition = 'u.Pantry_InUnit = 1' if pantry_pref == 2 else None
        if bathroom_condition is not None and pantry_condition is not None:
            in_unit_condition = 'where ' + bathroom_condition + ' and ' + pantry_condition
        elif bathroom_condition is not None:
            in_unit_condition = 'where ' + bathroom_condition
        elif pantry_condition is not None:
            in_unit_condition = 'where ' + pantry_condition
        else:
            in_unit_condition = ''
    except ValueError:
        return to_problem(422, "Validation Error", "Invalid number format for a numeric field.")
    
    try:
        conn = get_db()
        cur = conn.cursor(dictionary=True)
        
        try:        
            rows = _office_point_calculate(actime_start_default, actime_end_default, work_start, work_end, in_unit_condition, 
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
                w_fac_ev)
        except Exception as e:
            return to_problem(409, "Conflict", f"Point Calculate Error: {e}")
            
        try:
            search_input = {
                            "Minimum_Cost": minimum_cost,
                            "Maximum_Cost": maximum_cost,
                            "Lease_Term": lease_term,
                            "Work_Start": work_start,
                            "Work_End": work_end,
                            "Work_Sat": work_sat,
                            "Work_Sun": work_sun,
                            "Parking_Needed": parking_needed,
                            "Minimum_Size": minimum_size,
                            "Maximum_Size": maximum_size,
                            "Location": ";".join(filter(None, [location_yarn, location_road, location_station])),
                            "Station_Need": station_need,
                            "Expressway_Need": expressway_need,
                            "Pantry_Preference": pantry_pref,
                            "Bathroom_Preference": bath_pref,
                            "Bank_Preference": fac_bank_pref,
                            "Cafe_Preference": fac_cafe_pref,
                            "Restaurant_Preference": fac_restaurant_pref,
                            "Foodcourt_Preference": fac_foodcourt_pref,
                            "Market_Preference": fac_market_pref,
                            "Convenience_Store_Preference": fac_conv_store_pref,
                            "Pharmacy_Preference": fac_pharmacy_pref,
                            "EV_Preference": fac_ev_pref,
                            "Cost_Weight": cost_weight_group,
                            "Size_Weight": size_weight_group,
                            "Location_Weight": location_weight_group,
                            "Building_Weight": building_weight_group,
                            "Unit_Weight": unit_weight_group,
                            "Convenient_Weight": convenient_weight_group
                            }
            
            search_input_json = json.dumps([search_input], ensure_ascii=False)
            search_input_query = """INSERT INTO tenant_user_search_input (Tenant_ID, Search_Input)
                                    VALUES (%s, %s)"""
            cur.execute(search_input_query, (Tenant_ID, search_input_json))
            search_input_id = cur.lastrowid
        except Exception as e:
            return to_problem(409, "Conflict", f"Insert Search Input Error: {e}")
            
        try:
            result_list = []
            for i, record in enumerate(rows[:5]):
                record_data = {}
            #   call function by unit_id and Member_Type and i+1
                record_data['Unit_ID'] = record['Unit_ID']
                record_data['Project_ID'] = record['Project_ID']
                record_data['Room_Source'] = record['Room_Source']
                result_list.append(record_data)
            
            #values = []
            #search_output_query = """INSERT INTO tenant_user_search_output (Search_ID, Tenant_ID, ....)
            #                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"""
            
            search_output_id = None #dummy
            unit_link_list = []
            column_to_update = None
            for i, unit in enumerate(result_list):
                allow_gen_link = False
                if Member_Type == 'Premium':
                    allow_gen_link = True
                    column_to_update = 'Premium_Search_Remaining' 
                elif Member_Type == 'Normal':
                    column_to_update = 'Normal_Search_Remaining'
                    if i > 2: 
                        allow_gen_link = True

                if allow_gen_link:
                    links_to_add = []
                    if unit['Room_Source'] == 'merge':
                        sub_unit_ids = find_unit_virtual_room(unit['Unit_ID'])
                        links_to_add = gen_link(sub_unit_ids, unit['Project_ID'], 1, search_output_id, None, 'merge')
                    else:
                        links_to_add = gen_link(unit['Unit_ID'], unit['Project_ID'], 1, search_output_id, None, 'single')
                    unit_link_list.extend(links_to_add)
                
                #data = (search_input_id, Tenant_ID, unit[''], unit[''], unit[''], unit[''], unit[''], unit[''], unit[''], unit_link)
                #values.append(data)
            #cur.executemany(search_output_query, values)
        except Exception as e:
            return to_problem(409, "Conflict", f"Generate Link or Insert Output error: {e}")
        
        if column_to_update:
            try:
                update_quota_query = f"""update tenant_user set {column_to_update} = {column_to_update} - 1 where Tenant_ID = %s"""
                cur.execute(update_quota_query, (Tenant_ID,))
                
                unit_link_list = [item for item in unit_link_list if item['Unit_Link'] is not None]
                conn.commit()
                
                return unit_link_list
            except Exception as e:
                conn.rollback()
                return to_problem(409, "Conflict", f"Update Search Quota error: {e}")
    finally:
        cur.close()
        conn.close()
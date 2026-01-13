from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists
from function_query_helper import _office_point_calculate
from typing import Optional, Tuple, Dict, Any, List
import math
import json

router = APIRouter()

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
    prefer_no_column: str = Form(None), #var
    
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
    fac_pharmacy_pref: str = Form(None),
    _ = Depends(get_current_user),
):
    try:
        default_score = 0.5
        
        minimum_cost = None if not minimum_cost else int(minimum_cost)
        maximum_cost = None if not maximum_cost else int(maximum_cost)
        if minimum_cost is not None and maximum_cost is None:
            maximum_cost = minimum_cost
        elif maximum_cost is not None and minimum_cost is None:
            minimum_cost = maximum_cost
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
        parking_needed = 12 if not parking_needed else int(parking_needed)
        parking_fee_default = 2000 if not parking_fee_default else int(parking_fee_default) #var
        actime_start_default = '07:30:00' if not actime_start_default else actime_start_default #var
        actime_end_default = '18:00:00' if not actime_end_default else actime_end_default #var
        
        size_weight_group = 30 if not size_weight_group else int(size_weight_group) #var
        percent_size_group = 100 if not percent_size_group else int(percent_size_group) #var
        minimum_size = None if not minimum_size else float(minimum_size)
        maximum_size = None if not maximum_size else float(maximum_size)
        if minimum_size is None and maximum_size is None:
            minimum_size = 200
            maximum_size = 250
        elif minimum_size is not None and maximum_size is None:
            maximum_size = minimum_size
        elif minimum_size is None and maximum_size is not None:
            minimum_size = maximum_size
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
        prefer_no_column = 1 if not prefer_no_column else int(prefer_no_column) #var
        
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
        fac_pharmacy_pref = 1 if not fac_pharmacy_pref else int(fac_pharmacy_pref)

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
        return rows
    except Exception as e:
        return to_problem(409, "Conflict", f"query error: {e}")
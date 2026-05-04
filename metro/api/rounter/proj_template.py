from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists
from function_query_helper import _select_full_proj_item, _select_proj_cate, _select_proj_cover, proj_lastest_date \
                                , proj_responsibilities, proj_content, proj_gallery, get_similar_proj, proj_more, get_prod_subparent
from typing import Optional, Tuple, Dict, Any, List

router = APIRouter()

@router.get("/proj-template/{Proj_ID}", status_code=200)
def proj_template_data(
    Proj_ID: int,
    _ = Depends(get_current_user),
):
    data = {}
    project_data = _select_full_proj_item(Proj_ID)
    if not project_data:
        return to_problem(404, "Project Not Found", "Project Not Found.")
    
    data["Proj_ID"] = Proj_ID
    data["Proj_URL"] = "metropolis/proj/" + project_data["Proj_URL_Tag"]
    data["Proj_Name"] = project_data.get("Name_EN")
    
    category_data = _select_proj_cate(Proj_ID, 'header')
    full_cate = category_data.get("Category_Header", None) if category_data else None
    data["Proj_Category"] = full_cate
    
    cover_data = _select_proj_cover(Proj_ID)
    data["Proj_Cover"] = cover_data
    
    information_data = []
    hide = {}
    country = project_data.get("Proj_Country", None)
    state = project_data.get("Proj_State", None)
    province = project_data.get("Proj_Province", None)
    district = project_data.get("Proj_District", None)
    sub_district = project_data.get("Proj_Sub_District", None)
    yarn = project_data.get("Proj_Yarn", None)
    
    if country == "Thailand":
        first_location = next((a for a in [yarn, district] if a), None)
        locations = [loc for loc in [first_location, province, country] if loc]
    else:
        locations = [loc for loc in [province, state, country] if loc]
    location_text = ", ".join(locations)
    hide["Location"] = location_text
    
    rai = project_data.get('Land_Rai', 0)
    ngan = project_data.get('Land_Ngan', 0)
    wa = project_data.get('Land_Wa', 0)
    if rai or ngan or wa:
        total_wa = (rai * 400) + (ngan * 100) + wa
        if total_wa > 0:
            final_rai = int(total_wa // 400)
            remain_wa = total_wa % 400
            final_ngan = int(remain_wa // 100)
            final_wa = remain_wa % 100
            formatted_wa = int(final_wa) if final_wa % 1 == 0 else round(final_wa, 2)
            land_area = f"{final_rai}-{final_ngan}-{formatted_wa}"
        else:
            land_area = None
    else:
        land_area = None
    area_sources = [(project_data.get("Usable_Area"), "sq.m."), (project_data.get("Commercial_Area"), "sq.m.")
                    , (land_area, "rai")]
    area = next(((val, unit) for val, unit in area_sources if val), (None, None))
    area_text = None
    if area[0]:
        area_value, unit = area
        if unit == "rai":
            area_text = f"{area_value} {unit}"
        else:
            area_text = f"{'{:,.0f}'.format(round(area_value))} {unit}"
    hide["Area"] = area_text
    
    date_data = proj_lastest_date(Proj_ID)
    year = date_data.get("Latest_Date", None) if date_data else None
    hide["Year"] = year
    
    hide["Responsibilities"] = proj_responsibilities(Proj_ID, 'hide')
    
    hide_data = {"Hide": hide}
    information_data.append(hide_data)
    
    full = {}
    full["Location"] = location_text
    full["Gross_Building_Area"] = f"{'{:,.0f}'.format(round(project_data.get('Usable_Area')))} sq.m." if project_data.get('Usable_Area') else None
    full["Gross_Rental_Area"] = f"{'{:,.0f}'.format(round(project_data.get('Commercial_Area')))} sq.m." if project_data.get('Commercial_Area') else None
    full["Land_Area"] = f"{land_area} rai" if land_area else None
    full["Started_Year"] = date_data.get("Start_Date", None) if date_data else None
    full["Completed_Year"] = date_data.get("Finish_Date", None) if date_data else None
    full["Renovated_Year"] = date_data.get("Renovated_Date", None) if date_data else None
    
    category_data = _select_proj_cate(Proj_ID, 'full')
    full["Category"] = category_data.get("Category_Group", None) if category_data else None
    
    full["Responsibilities"] = proj_responsibilities(Proj_ID, 'full')
    full_data = {"Full": full}
    
    information_data.append(full_data)
    data["Proj_Information"] = information_data
    
    content, profs = proj_content(Proj_ID)
    data["Content"] = content
    
    gallery = proj_gallery(Proj_ID)
    data["Gallery"] = gallery
    
    conn2 = get_db()
    cur2 = conn2.cursor(dictionary=True)
    prod = get_prod_subparent(cur2, Proj_ID, None, None)
    data["Product"] = prod
    cur2.close()
    conn2.close()
    
    similar_proj = get_similar_proj(profs, Proj_ID) if profs else None
    data["Similar_Proj"] = similar_proj
    
    more_proj = proj_more(Proj_ID)
    data["More_Proj"] = more_proj
    
    return data
from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists
from function_query_helper import _select_full_prof_item, _select_prof_cover, get_prof_proj, prof_more, get_gallery
from typing import Optional, Tuple, Dict, Any, List

router = APIRouter()

@router.get("/prof-template/{Prof_ID}", status_code=200)
def prof_template_data(
    Prof_ID: int,
    _ = Depends(get_current_user),
):
    data = {}
    prof_data = _select_full_prof_item(Prof_ID)
    if not prof_data:
        return to_problem(404, "Professional Not Found", "Professional Not Found.")
    
    data["Prof_ID"] = Prof_ID
    data["Prof_URL"] = "metropolis/prof/" + prof_data["Prof_URL_Tag"]
    data["Prof_Name"] = prof_data.get("Name_EN")
    
    expertise_data = prof_data.get("Expertise_Text", None)
    data["Expertise_Topic"] = expertise_data.split(", ")[0].upper() if expertise_data else None
    
    data["Logo_URL"] = prof_data.get("Logo_URL", None)
    
    cover_data = _select_prof_cover(Prof_ID)
    data["Cover"] = cover_data
    
    data["Facebook"] = prof_data.get("FB_Link", None)
    data["Instagram"] = prof_data.get("IG_Link", None)
    data["Website"] = prof_data.get("Website", None)
    data["Line"] = prof_data.get("Line_Link", None)
    data["Youtube"] = prof_data.get("YT_Link", None)
    
    data["Expertise"] = expertise_data
    
    experience_data = prof_data.get("Experience_Text", None)
    data["Experience"] = experience_data
    
    country = prof_data.get("Prof_Country", None)
    state = prof_data.get("Prof_State", None)
    province = prof_data.get("Prof_Province", None)
    district = prof_data.get("Prof_District", None)
    sub_district = prof_data.get("Prof_Sub_District", None)
    yarn = prof_data.get("Prof_Yarn", None)
    
    if country == "Thailand":
        first_location = next((a for a in [yarn, district] if a), None)
        locations = [loc for loc in [first_location, province, country] if loc]
    else:
        locations = [loc for loc in [province, state, country] if loc]
    location_text = ", ".join(locations)
    data["Location"] = location_text
    
    data["Founder"] = prof_data.get("Owner_Text", None)
    data["Since"] = prof_data.get("Year_Found_Date", None)
    
    content = prof_data.get("Content", None)
    des = prof_data.get("Brief_Description", None)
    data["Content"] = next((a for a in [content, des] if a), None)
    
    gallery = get_gallery(Prof_ID, 'prof')
    data["Gallery"] = gallery
    
    prof_proj = get_prof_proj(Prof_ID)
    data["Proj"] = prof_proj
    
    more_prof = prof_more(Prof_ID)
    data["More_Prof"] = more_prof
    
    return data
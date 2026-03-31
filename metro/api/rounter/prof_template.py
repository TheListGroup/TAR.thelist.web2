from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists
from function_query_helper import _select_full_prof_item, _select_prof_cover, get_prof_proj, prof_more
from typing import Optional, Tuple, Dict, Any, List

router = APIRouter()

@router.get("/prof-template-test/{Prof_ID}", status_code=200)
def prof_template_data_test(
    Prof_ID: int,
    _ = Depends(get_current_user),
):
    return {"Prof_ID": Prof_ID,
            "Prof_Name": "HAS Design and Research",
            "Expertise_Topic": "Architect",
            "Logo_URL": "https://img.freepik.com/free-vector/modern-architecture-logo-template_23-2148100582.jpg",
            "Cover": "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=2000",
            "Facebook": "https://www.facebook.com/realist.co.th",
            "Instagram": None,
            "Website": "https://thelist.group/#realdata",
            "Line": None,
            "Youtube": "https://www.youtube.com/@THELISTGROUP",
            "Expertise": "Architect, Urban Designer, Landscape Architect",
            "Experience": "MUSEUM, EXHIBITION | CULTURALS",
            "Location": "Sukhumvit, Bangkok, Thailand",
            "Owner": "Anna Lee, Jenchieh Hung, Kulthida Songkittipakdee",
            "Year": 2025,
            "Content": """<div>
                        <div>ABOUT THIS PROFESSIONAL</div>
                        <div>
                            <div>
                                HAS design and research ก่อตั้งขึ้นในปี 2007 โดยสถาปนิก Kulthida Songkittipakdee และ Jenchieh Hung ซึ่งมีความเชี่ยวชาญในการออกแบบโครงการทางวัฒนธรรมและพื้นที่สาธารณะ สำนักงานของเรามุ่งเน้นการวิจัยและพัฒนาแนวทางทางสถาปัตยกรรมที่ตอบสนองต่อบริบททางสังคม วัฒนธรรม และสิ่งแวดล้อม โดยเชื่อว่าสถาปัตยกรรมควรเป็นสื่อกลางในการสร้างประสบการณ์และความหมายให้กับผู้ใช้งาน ผลงานของ HAS ได้รับการยอมรับทั้งในประเทศและต่างประเทศ ด้วยรางวัลต่างๆ เช่น AIA Design Award, World Architecture Festival และ Singapore Institute of Architects Award ซึ่งสะท้อนถึงความมุ่งมั่นในการสร้างสรรค์งานสถาปัตยกรรมที่มีคุณภาพและสอดคล้องกับบริบทท้องถิ่น
                            </div>
                            <div>
                                <!-- รูปภาพทีมงานสถาปนิก -->
                                <img src="https://images.unsplash.com/photo-1552664730-d307ca884978?q=80&w=800" alt="Architect Team">
                            </div>
                        </div>
                    </div>""",
            "Proj": [{"Proj_Category": "HOSPITALITY | HOTEL", "Proj_Name": "Modern Zen Residence"
                    , "Image": "https://plus.unsplash.com/premium_photo-1733760180239-ef05b25dd5ad?q=80&w=2071"},
                    {"Proj_Category": "HOSPITALITY | HOTEL", "Proj_Name": "Modern Zen Residence"
                    , "Image": "https://plus.unsplash.com/premium_photo-1689609950069-2961f80b1e70?q=80&w=687"},
                    {"Proj_Category": "HOSPITALITY | HOTEL", "Proj_Name": "Modern Zen Residence"
                    , "Image": "https://images.unsplash.com/photo-1770742159718-ca69558b6e80?q=80&w=1074"},
                    {"Proj_Category": "HOSPITALITY | HOTEL", "Proj_Name": "Modern Zen Residence"
                    , "Image": "https://images.unsplash.com/photo-1771170611835-8cb5c821966f?q=80&w=1172"},
                    {"Proj_Category": "HOSPITALITY | HOTEL", "Proj_Name": "Modern Zen Residence"
                    , "Image": "https://images.unsplash.com/photo-1771335976659-016c498e33c3?q=80&w=725"},
                    {"Proj_Category": "HOSPITALITY | HOTEL", "Proj_Name": "Modern Zen Residence"
                    , "Image": "https://images.unsplash.com/photo-1771197359037-4cbe33fed006?q=80&w=687"},
                    {"Proj_Category": "HOSPITALITY | HOTEL", "Proj_Name": "Modern Zen Residence"
                    , "Image": "https://images.unsplash.com/photo-1769501203673-159257ecb72d?q=80&w=764"},
                    {"Proj_Category": "HOSPITALITY | HOTEL", "Proj_Name": "Modern Zen Residence"
                    , "Image": "https://plus.unsplash.com/premium_photo-1733864822174-c469c50177a8?q=80&w=687"},
                    {"Proj_Category": "HOSPITALITY | HOTEL", "Proj_Name": "Modern Zen Residence"
                    , "Image": "https://plus.unsplash.com/premium_photo-1733760125610-3b5ebc834623?q=80&w=687"},
                    {"Proj_Category": "HOSPITALITY | HOTEL", "Proj_Name": "Modern Zen Residence"
                    , "Image": "https://plus.unsplash.com/premium_photo-1733760125038-06564d0a4568?q=80&w=1171"},
                    ],
            "More_Prof": [{"Prof_Name": "AA Studio", "Expertise": "Landscape Architect", "Category": "EXHIBITION"
                        , "Logo": "https://img.freepik.com/free-vector/modern-architecture-logo-template_23-2148100582.jpg"
                        , "Cover": "https://plus.unsplash.com/premium_photo-1733760180239-ef05b25dd5ad?q=80&w=2071"},
                        {"Prof_Name": "Modernist Co.", "Expertise": "Architect", "Category": "EXHIBITION"
                        , "Logo": "https://img.freepik.com/free-vector/modern-architecture-logo-template_23-2148100582.jpg"
                        , "Cover": "https://plus.unsplash.com/premium_photo-1733760180239-ef05b25dd5ad?q=80&w=2071"},
                        {"Prof_Name": "Green Space Design", "Expertise": "Landscape Architect", "Category": "ZOO, EXHIBITION"
                        , "Logo": "https://img.freepik.com/free-vector/modern-architecture-logo-template_23-2148100582.jpg"
                        , "Cover": "https://plus.unsplash.com/premium_photo-1733760180239-ef05b25dd5ad?q=80&w=2071"},
                        {"Prof_Name": "Modernist Co.", "Expertise": "Landscape Architect", "Category": "EXHIBITION, APARTMENTS"
                        , "Logo": "https://img.freepik.com/free-vector/modern-architecture-logo-template_23-2148100582.jpg"
                        , "Cover": "https://plus.unsplash.com/premium_photo-1733760180239-ef05b25dd5ad?q=80&w=2071"}
                        ]
            }

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
    data["Prof_URL"] = "metro/prof/" + prof_data["Prof_URL_Tag"]
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
    
    data["Owner"] = prof_data.get("Owner_Text", None)
    data["Since"] = prof_data.get("Year_Found_Date", None)
    
    content = prof_data.get("Content", None)
    des = prof_data.get("Brief_Description", None)
    data["Content"] = next((a for a in [content, des] if a), None)
    
    prof_proj = get_prof_proj(Prof_ID)
    data["Proj"] = prof_proj
    
    more_prof = prof_more(Prof_ID)
    data["More_Prof"] = more_prof
    
    return data
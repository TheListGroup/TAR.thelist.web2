from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists
from function_query_helper import _select_full_prod_item, _select_prod_cover, get_gallery, get_prod_resource, get_prod_parent, prod_url_gen \
    , get_breadcrumbs, get_prod_proj, get_entity_context, get_supplier, get_prod_all_specification
from typing import Optional, Tuple, Dict, Any, List

router = APIRouter()

@router.get("/sub-template/{Prod_ID}", status_code=200)
def prod_template_data(
    Prod_ID: int,
    _ = Depends(get_current_user),
):    
    data = {}
    prod_data = _select_full_prod_item(Prod_ID)
    if not prod_data:
        return to_problem(404, "Product Not Found", "Product Not Found.")
    
    prod_type = prod_data["Entity_Type"]
    if prod_type != 'suppliers':
        family_data = get_breadcrumbs(prod_data["Family_IDS"], Prod_ID)
        data["Breadcrumb"] = family_data if family_data else None
        if prod_type == 'series':
            data["Brand_Name"] = family_data[-2]["Name"].upper()
            data["Brand_URL"] = family_data[-2]["Url"].upper()
    
    data["Type"] = prod_type
    data["Prod_ID"] = Prod_ID
    data["Prod_Name"] = prod_data["Name_EN"].upper()
    if prod_type == 'suppliers':
        data["Logo_URL"] = prod_data["Logo_URL"]
        
        country = prod_data.get("Country", None)
        state = prod_data.get("State", None)
        province = prod_data.get("Province", None)
        district = prod_data.get("District", None)
        sub_district = prod_data.get("Sub_District", None)
        yarn = prod_data.get("Yarn", None)
        
        if country == "Thailand":
            first_location = next((a for a in [yarn, district] if a), None)
            locations = [loc for loc in [first_location, province, country] if loc]
        else:
            locations = [loc for loc in [province, state, country] if loc]
        location_text = ", ".join(locations)
        data["Location"] = location_text
    
    if prod_type != 'suppliers':
        supplier_name, brand_name, supplier_url, brand_url = get_entity_context(prod_data["Family_IDS"])
        data["Head_Parent"] = supplier_name
        data["Head_Parent_Url"] = supplier_url
        if prod_type == 'products':
            data["Head_Name"] = brand_name
            data["Head_Url"] = brand_url
    
    cover_data = _select_prod_cover(Prod_ID)
    data["Cover"] = cover_data if cover_data else None
    
    if prod_type != 'products':
        data["Brief_Description"] = prod_data["Brief_Description"]
        data["Category"] = prod_data["Category_Text"].split("|")[0].upper() if prod_data["Category_Text"] else None
        data["Facebook"] = prod_data["FB_Link"]
        data["Instagram"] = prod_data["IG_Link"]
        data["Line"] = prod_data["Line_Link"]
        data["Website"] = prod_data["Website"]
        data["Youtube"] = prod_data["YT_Link"]
        data["Url"] = prod_url_gen(prod_type, prod_data["Entity_URL_Tag"])
    data["Content"] = {"Topic": f"ABOUT THIS {prod_type[:-1].upper()}", "Content": prod_data["Content"]} if prod_data["Content"] else None
    
    if prod_type == 'products':
        data["spec"] = get_prod_all_specification(Prod_ID)
    
    gallery = get_gallery(Prod_ID, 'prod')
    data["Gallery"] = gallery
    
    resource = get_prod_resource(Prod_ID)
    data["RESOURCES"] = resource if resource else None
    
    if prod_type != 'suppliers':
        proj = get_prod_proj(Prod_ID)
        data["FEATURED"] = {"Title": "FEATURED IN PROJECTS", "Data": proj} if proj else None
    
    if prod_type != 'products':
        parent_data, product_data = get_prod_parent(prod_data["Family_IDS"])
        data["Parent"] = parent_data if parent_data else None
    
        product_list = []
        if product_data:
            for p in product_data:
                p["Head_Name"] = prod_data['Name_EN'].upper()
            product_list.append({"Title": f"PRODUCTS FROM {prod_data['Name_EN'].upper()}"
                                , "Product": product_data})
        data["Product"] = product_list if product_list else None
    
    if prod_type != 'suppliers':
        supp_id = prod_data["Family_IDS"].split(",")[0]
        data["Supplier"] = get_supplier(supp_id)
    
    return data

@router.get("/sub-template-test/{Prod_ID}", status_code=200)
def prod_template_data_test(
    Prod_ID: int,
    _ = Depends(get_current_user),
):
    if Prod_ID == 1: #supplier
        return {"Type": "Supplier",
                "Prod_ID": Prod_ID,
                "Prod_Name": "CHANINTR",
                "Logo_URL": "/uploads/professional/0001/logo/000001-S-180.webp",
                "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp",
                "Brief_Description": "we believe in living well, in the everyday and in the most special moments.",
                "Category": "FURNITURE",
                "Facebook": "https://www.facebook.com/realist.co.th",
                "Instagram": None,
                "Website": "https://thelist.group/#realdata",
                "Youtube": "https://www.youtube.com/@THELISTGROUP",
                "Url": "https://www.facebook.com/realist.co.th",
                "Location": "CHANINTR Head Office 110 Sukhumvit 26 Khlong Tan, Khlong Toei, Bangkok",
                "Content": [{"Topic": "ABOUT THIS SUPPLIER",
                            "Content": """<div>
                                        <div>
                                            <div>
                                                CHANINTR began as a furniture importer, launching in Bangkok in 1994 with the brands Baker and McGuire. We were drawn to their shared approach to living — one of relaxed luxury that we were surrounded by while growing up in America. But it was their commitment to quality, attention to craftsmanship, and grace of their service — placing importance on relationships with those they work with — that we wanted to share with our customers.
                                            </div>
                                            <div>
                                                Over the past three decades, our business and our family of brands have grown but our approach has remained constant. Quality and service are still part of everything we do. We consider every detail, from fitting a joint to furnishing a full apartment, and believe that relationships extend beyond the first interaction. They last a lifetime.
                                            </div>
                                            <div>
                                                These values have informed our understanding of the home and how we help to build it. Through our brand partners, which produce everything from furniture to fixtures, and our services, which range from styling and consultancy to full-service interior architecture and design, we endeavor to create spaces that exceed expectations. At CHANINTR, we believe in living well, in the everyday and in the most special moments.
                                            </div>
                                            <div>
                                                <img src="/uploads/professional/0026/cover/000011-H-1920.webp" alt="Architect Team">
                                            </div>
                                            <div>
                                                CHANINTR began as a furniture importer, launching in Bangkok in 1994 with the brands Baker and McGuire. We were drawn to their shared approach to living — one of relaxed luxury that we were surrounded by while growing up in America. But it was their commitment to quality, attention to craftsmanship, and grace of their service — placing importance on relationships with those they work with — that we wanted to share with our customers.
                                            </div>
                                            <div>
                                                Over the past three decades, our business and our family of brands have grown but our approach has remained constant. Quality and service are still part of everything we do. We consider every detail, from fitting a joint to furnishing a full apartment, and believe that relationships extend beyond the first interaction. They last a lifetime.
                                            </div>
                                            <div>
                                                These values have informed our understanding of the home and how we help to build it. Through our brand partners, which produce everything from furniture to fixtures, and our services, which range from styling and consultancy to full-service interior architecture and design, we endeavor to create spaces that exceed expectations. At CHANINTR, we believe in living well, in the everyday and in the most special moments.
                                            </div>
                                        </div>
                                    </div>"""}],
                "Gallery": [{"Url": "/uploads/project/0001/gallery/0001/000002-H-1440.webp", "Image_Order": 1, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000003-H-1440.webp", "Image_Order": 2, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000004-H-1440.webp", "Image_Order": 3, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000005-H-1440.webp", "Image_Order": 4, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000006-H-1440.webp", "Image_Order": 5, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000007-H-1440.webp", "Image_Order": 6, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000008-H-1440.webp", "Image_Order": 7, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000009-H-1440.webp", "Image_Order": 8, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000010-H-1440.webp", "Image_Order": 9, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000011-H-1440.webp", "Image_Order": 10, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000012-H-1440.webp", "Image_Order": 11, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000013-H-1440.webp", "Image_Order": 12, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000014-H-1440.webp", "Image_Order": 13, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000015-H-1440.webp", "Image_Order": 14, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000016-H-1440.webp", "Image_Order": 15, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000017-H-1440.webp", "Image_Order": 16, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000018-H-1440.webp", "Image_Order": 17, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000019-H-1440.webp", "Image_Order": 18, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000020-H-1440.webp", "Image_Order": 19, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000021-H-1440.webp", "Image_Order": 20, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000022-H-1440.webp", "Image_Order": 21, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000023-H-1440.webp", "Image_Order": 22, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000024-H-1440.webp", "Image_Order": 23, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000025-H-1440.webp", "Image_Order": 24, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000026-H-1440.webp", "Image_Order": 25, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000027-H-1440.webp", "Image_Order": 26, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000028-H-1440.webp", "Image_Order": 27, "Image_Name": None, "Image_Description": None}],
                "RESOURCES": [{"Type": "DOCX", "Size": "2.4 MB", "Name": "Price Book: CHANINTR"}
                                , {"Type": "PDF", "Size": "2.4 MB", "Name": "CHANINTR Product Portfolio"}
                                , {"Type": "JPG", "Size": "0.42 MB", "Name": "CHANINTR Sample Overview"}
                                , {"Type": "PDF", "Size": "5.2 MB", "Name": "Price Book: CHANINTR Guide"}],
                "Parant": [{"Type": "Brand"
                            , "Name": "MILLERKNOLL"
                            , "Brief_Description": "Redefining modern for the 21st century."
                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                            , "Url": "https://thelist.group/#realdata"
                            , "Parent": [{"Type": "SubBrand", "Head_Name": "Millerknoll", "Name": "HAY", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "SubBrand", "Head_Name": "Millerknoll", "Name": "Herman Miller", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "SubBrand", "Head_Name": "Millerknoll", "Name": "Title", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "SubBrand", "Head_Name": "Millerknoll", "Name": "Knoll", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "SubBrand", "Head_Name": "Millerknoll", "Name": "DatesWeiser", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "SubBrand", "Head_Name": "Millerknoll", "Name": "DWR Collection", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Millerknoll", "Name": "Armchair", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Millerknoll", "Name": "Palissade Table", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}]}
                        , {"Type": "Brand"
                            , "Name": "SAINT-LOUIS"
                            , "Brief_Description": "Absolute simplicity, infinite possibility"
                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                            , "Url": "https://thelist.group/#realdata"
                            , "Parent": [{"Type": "Product", "Head_Name": "Saint-Louis", "Name": "Title", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Saint-Louis", "Name": "Title", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Saint-Louis", "Name": "Title", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Saint-Louis", "Name": "Title", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Saint-Louis", "Name": "Title", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Saint-Louis", "Name": "Title", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Saint-Louis", "Name": "Title", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Saint-Louis", "Name": "Title", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}]}
                        , {"Type": "Brand"
                            , "Name": "OCCHIO"
                            , "Brief_Description": "Where German engineering meets luxury"
                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                            , "Url": "https://thelist.group/#realdata"
                            , "Parent": [{"Type": "Product", "Head_Name": "Occhio", "Name": "Mito largo", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Occhio", "Name": "Mito sospeso 40 flat", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Occhio", "Name": "Mito sospeso move 40 pure", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Occhio", "Name": "Mito volo 140 up", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Occhio", "Name": "Mito Ball", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Occhio", "Name": "Piu R alto track", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Occhio", "Name": "Piu R alto 3d up", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Occhio", "Name": "Piu R piano in", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}]}
                        ],
                "Product": [{"Title": "PRODUCTS FROM CHANINTR"
                            , "Product": [{"Head_Name": "Chanintr", "Name": "Mito largo", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Mito sospeso 40 flat", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Mito sospeso move 40 pure", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Mito volo 140 up", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Mito Ball", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Piu R alto track", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Piu R alto 3d up", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Piu R piano in", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Mito largo", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Mito sospeso 40 flat", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Mito sospeso move 40 pure", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Mito volo 140 up", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Framery Four - Lite", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Lox Swivel Chair, 5-Star Base with Casters", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "Piu R alto 3d up", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Chanintr", "Name": "375 Relaxchair", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}]
                            }],
                "Carousel": [{"Title": "OTHER SUPPLIERS"
                                , "Data": [{"Name": "Euro Creations", "Category": "Luxury Furniture", "Count_Prod": 20000
                                            , "Logo": "/uploads/professional/0001/logo/000001-S-180.webp"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "CHANINTR", "Category": "High-end FUNITURE", "Count_Prod": 20000
                                            , "Logo": "/uploads/professional/0001/logo/000001-S-180.webp"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "MOTIF Art of Living", "Category": "Lighting, Small Objects", "Count_Prod": 20000
                                            , "Logo": "/uploads/professional/0001/logo/000001-S-180.webp"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "Arkitektura", "Category": "Kitchen, Bath Specialist", "Count_Prod": 10000
                                            , "Logo": "/uploads/professional/0001/logo/000001-S-180.webp"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "Design Republic", "Category": "Contemporary Design", "Count_Prod": 1000
                                            , "Logo": "/uploads/professional/0001/logo/000001-S-180.webp"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        ]
                            }]
                }
    if Prod_ID == 2: #brand
        return {"Type": "Brand",
                "Prod_ID": Prod_ID,
                "Breadcrumb": [{"Name": "CHANINTR", "Url": "https://thelist.group/#realdata", "order": 1}
                                , {"Name": "MillerKnoll", "Url": None, "order":2}],
                "Prod_Name": "MillerKnoll",
                "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp",
                "Brief_Description": "Redefining modern for the 21st century",
                "Category": "FURNITURE",
                "Head_Parent": "CHANINTR",
                "Facebook": "https://www.facebook.com/realist.co.th",
                "Instagram": None,
                "Website": "https://thelist.group/#realdata",
                "Youtube": "https://www.youtube.com/@THELISTGROUP",
                "Url": "https://www.facebook.com/realist.co.th",
                "Content": [{"Topic": "ABOUT THIS BRAND",
                            "Content": """<div>
                                        <div>
                                            <div>
                                                MillerKnoll is a global collective of design brands built on the foundation of two icons of modernism: Herman Miller and Knoll. Our portfolio also includes furniture and accessories for commercial and residential spaces from Colebrook Bosson Saunders, DatesWeiser, Design Within Reach, Edelman, Geiger, HAY, HOLLY HUNT, Knoll Textiles, Maharam, Muuto, NaughtOne, and Spinneybeck | FilzFelt.  Guided by a shared purpose—design for the good of humankind—we generate insights, pioneer innovations, and champion ideas to help spaces better support how people live, work, and gather today.  We reach customers across office, residential, healthcare, and education markets through a network of MillerKnoll dealers, all of whom are highly credentialed, independently owned businesses. In addition, we manage an ever-expanding global retail footprint delivering world-class brick-and-mortar and ecommerce experiences.
                                            </div>
                                            <div>
                                                <img src="/uploads/professional/0026/cover/000011-H-1920.webp" alt="Architect Team">
                                            </div>
                                            <div>
                                                Esteemed American furniture manufacturer Herman Miller is famed for their commitment to great design, environmental sustainability, community service, and customer well-being. The brand gained global prominence in the mid-20th century through successful collaborations with legendary designers such as Charles and Ray Eames, George Nelson and Isamu Noguchi. Iconic creations like the Eames Lounge Chair, Nelson Bubble Lamps, Molded Plywood Chair, and Noguchi Table are among their most celebrated works
                                            </div>
                                            <div>
                                                In the 1960s, Herman Miller introduced their office furniture line, revolutionizing workplaces with the concept of office cubicles. Since then, the brand has been recognized as a pioneer of smart office solutions. Combining forward-thinking designs with functionality, their products are designed to enhance comfort and productivity in the workplace. Many award-winning Herman Miller chairs, including the iconic Aeron Chair, hailed as “America’s best-selling chair,” are celebrated worldwide for their ergonomic features and timeless appeal. 
                                            </div>
                                            <div>
                                                To explore luxury Herman Miller ergonomic work chairs and other office chair designs in Thailand, the exclusive authorized Herman Miller retailer store in Thailand.
                                            </div>
                                        </div>
                                    </div>"""}],
                "Gallery": [{"Url": "/uploads/project/0001/gallery/0001/000002-H-1440.webp", "Image_Order": 1, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000003-H-1440.webp", "Image_Order": 2, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000004-H-1440.webp", "Image_Order": 3, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000005-H-1440.webp", "Image_Order": 4, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000006-H-1440.webp", "Image_Order": 5, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000007-H-1440.webp", "Image_Order": 6, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000008-H-1440.webp", "Image_Order": 7, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000009-H-1440.webp", "Image_Order": 8, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000010-H-1440.webp", "Image_Order": 9, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000011-H-1440.webp", "Image_Order": 10, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000012-H-1440.webp", "Image_Order": 11, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000013-H-1440.webp", "Image_Order": 12, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000014-H-1440.webp", "Image_Order": 13, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000015-H-1440.webp", "Image_Order": 14, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000016-H-1440.webp", "Image_Order": 15, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000017-H-1440.webp", "Image_Order": 16, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000018-H-1440.webp", "Image_Order": 17, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000019-H-1440.webp", "Image_Order": 18, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000020-H-1440.webp", "Image_Order": 19, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000021-H-1440.webp", "Image_Order": 20, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000022-H-1440.webp", "Image_Order": 21, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000023-H-1440.webp", "Image_Order": 22, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000024-H-1440.webp", "Image_Order": 23, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000025-H-1440.webp", "Image_Order": 24, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000026-H-1440.webp", "Image_Order": 25, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000027-H-1440.webp", "Image_Order": 26, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000028-H-1440.webp", "Image_Order": 27, "Image_Name": None, "Image_Description": None}],
                "RESOURCES": [{"Type": "DOCX", "Size": "2.4 MB", "Name": "Price Book: CHANINTR"}
                                , {"Type": "PDF", "Size": "2.4 MB", "Name": "CHANINTR Product Portfolio"}
                                , {"Type": "JPG", "Size": "0.42 MB", "Name": "CHANINTR Sample Overview"}
                                , {"Type": "PDF", "Size": "5.2 MB", "Name": "Price Book: CHANINTR Guide"}],
                "FEATURED": [{"Title": "FEATURED IN PROJECTS"
                                , "Data": [{"Name": "Modern Zen Residence", "Category": "HOSPITALITY | HOTEL", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                            , {"Name": "Minimalist Residence", "Category": "RESIDENTIAL | VILLA", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                            , {"Name": "Brick House", "Category": "CULTURAL | PAVILION", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                            , {"Name": "Modern Zen Residence", "Category": "HOSPITALITY | HOTEL", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                            , {"Name": "Minimalist Residence", "Category": "RESIDENTIAL | VILLA", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                            , {"Name": "Brick House", "Category": "CULTURAL | PAVILION", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                        ]}
                            ],
                "Parant": [{"Type": "SubBrand"
                            , "Name": "HAY"
                            , "Brief_Description": "Everyday designs reimagined"
                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                            , "Url": "https://thelist.group/#realdata"
                            , "Parent": [{"Type": "series", "Head_Name": "HAY", "Name": "About Chair", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "series", "Head_Name": "HAY", "Name": "Palissade Cantilever", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "series", "Head_Name": "HAY", "Name": "Deville Collection", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "series", "Head_Name": "HAY", "Name": "Manolito Stool", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "series", "Head_Name": "HAY", "Name": "Aplat Table Lamp", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "series", "Head_Name": "HAY", "Name": "Host Portable Lamp", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "HAY", "Name": "HOST Portable Lamp", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "HAY", "Name": "Configurator", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}]}
                        , {"Type": "SubBrand"
                            , "Name": "NAUGHTONE"
                            , "Brief_Description": "Absolute simplicity, infinite possibility"
                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                            , "Url": "https://thelist.group/#realdata"
                            , "Parent": [{"Type": "Product", "Head_Name": "Naughtone", "Name": "Pullman Chair", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Naughtone", "Name": "Eames Shell Chairs", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Naughtone", "Name": "Tier Café Table", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Naughtone", "Name": "Dalby Bar-Height Table", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Naughtone", "Name": "Pullman Booth", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Naughtone", "Name": "Mimo Club Chair", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Naughtone", "Name": "Mimo Modular Seating", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Naughtone", "Name": "Ali Cafe Table", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}]}
                        , {"Type": "SubBrand"
                            , "Name": "HERMAN MILLER"
                            , "Brief_Description": "Problem-solving designs that inspire the best in people"
                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                            , "Url": "https://thelist.group/#realdata"
                            , "Parent": [{"Type": "series", "Head_Name": "Herman Miller", "Name": "Aeron", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "series", "Head_Name": "Herman Miller", "Name": "Onyx Ultra-matte", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "series", "Head_Name": "Herman Miller", "Name": "Eames Shell Chairs", "Count_Prod": 114, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Herman Miller", "Name": "Nelson Cigar Lotus Floor Lamp", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Herman Miller", "Name": "Girard Flower Table", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Herman Miller", "Name": "Everywhere Tables", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Herman Miller", "Name": "Land Credenza", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Type": "Product", "Head_Name": "Herman Miller", "Name": "Bay Work Pod", "Count_Prod": None, "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}]}
                        ],
                "Product": [{"Title": "PRODUCTS FROM MILLERKNOLL"
                            , "Product": [{"Head_Name": "MillerKnoll", "Name": "Private Office", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "MillerKnoll", "Name": "One Open Plan", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "MillerKnoll", "Name": "One Meeting and Huddle Rooms", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "MillerKnoll", "Name": "Tuexdo Component Sofa", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        ]
                            }],
                "Supplier": [{"Name": "Euro Creations", "Category": "Luxury Furniture", "Count": 20000
                                , "Logo": "/uploads/professional/0001/logo/000001-S-180.webp"
                                , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}],
                "Carousel": [{"Title": "BRANDS FROM EURO CREATIONS"
                                , "Data": [{"Name": "NAUGTONE", "Parent": "MILLERKNOLL", "Category": "KITCHENWARE", "Count_Prod": 100
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "KNOLL", "Parent": "MILLERKNOLL", "Category": "LIGHTNING", "Count_Prod": 100
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "BAKER FURNITURE", "Parent": None, "Category": "LIVING FURNITURE", "Count_Prod": 100
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "TUCCI", "Parent": None, "Category": "FURNITURE", "Count_Prod": 100
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "LEMA", "Parent": None, "Category": "FURNITURE", "Count_Prod": 100
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        ]}
                            , {"Title": "OTHER BRANDS"
                                , "Data": [{"Name": "NAUGTONE", "Parent": "MILLERKNOLL", "Category": "KITCHENWARE", "Count_Prod": 100
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "KNOLL", "Parent": "MILLERKNOLL", "Category": "LIGHTNING", "Count_Prod": 100
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "BAKER FURNITURE", "Parent": None, "Category": "LIVING FURNITURE", "Count_Prod": 100
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "TUCCI", "Parent": None, "Category": "FURNITURE", "Count_Prod": 100
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        , {"Name": "LEMA", "Parent": None, "Category": "FURNITURE", "Count_Prod": 100
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"
                                            , "Url": "https://thelist.group/#realdata"}
                                        ]}
                            ]
                }
    if Prod_ID == 3: #product
        return {"Type": "Product",
                "Prod_ID": Prod_ID,
                "Breadcrumb": [{"Name": "CHANINTR", "Url": "https://thelist.group/#realdata", "order": 1}
                                , {"Name": "MillerKnoll", "Url": "https://thelist.group/#realdata", "order": 2}
                                , {"Name": "HAY", "Url": "https://thelist.group/#realdata", "order": 3}
                                , {"Name": "About A Chair", "Url": None, "order": 4}],
                "Prod_Name": "About A Chair LAYOUT Chair 154",
                "Head_Name": "HAY",
                "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp",
                "Head_Parent": "CHANINTR",
                "Content": [{"Topic": "ABOUT THIS PRODUCT",
                            "Content": """<div>
                                        <div>
                                            <div>
                                                Part of the iconic About A Collection from HAY, the About A Chair 100 Series Task Chair offers a sophisticated answer to the casual task chair. Crafted for flexibility, its aluminum swivel base with casters makes mobility easy, while the high backrest and sculptural, curved seat ensure lasting comfort. Available in standard molded foam or a soft quilted version and customizable with a range of fabrics and finishes, the many combinations of frame, shell, and colors makes it a versatile way to add personality to any space.
                                            </div>
                                        </div>
                                    </div>"""}],
                "spec": [{"Key_Name": "width", "Display": "Width", "Value": {"24.41"}, "Unit": "in", "Order": 1}
                        , {"Key_Name": "height", "Display": "Height", "Value": {"32.68-37.4"}, "Unit": "in", "Order": 2}
                        , {"Key_Name": "weight", "Display": "Weight", "Value": {"24.8"}, "Unit": "kg", "Order": 3}
                        , {"Key_Name": "meterials", "Display": "Meterials", "Value": {"Steel Mesh"}, "Unit": None, "Order": 4}
                        , {"Key_Name": "voltage","Display": "Voltage", "Value": {"Rw 52"}, "Unit": "dB", "Order": 5}
                        , {"Key_Name": "manufactured_date","Display": "Manufactured Date", "Value": {"12 Mar 2026"}, "Unit": None, "Order": 6}
                        , {"Key_Name": "price","Display": "Price", "Value": {"240,000"}, "Unit": "bath", "Order": 7}
                        , {"Key_Name": "colours","Display": "Colours", "Value": {"#E2D092","#EEEAE7","#768D95","#A08060","#D0D0D0"}, "Unit": None, "Order": 8}],
                "Gallery": [{"Url": "/uploads/project/0001/gallery/0001/000002-H-1440.webp", "Image_Order": 1, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000003-H-1440.webp", "Image_Order": 2, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000004-H-1440.webp", "Image_Order": 3, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000005-H-1440.webp", "Image_Order": 4, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000006-H-1440.webp", "Image_Order": 5, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000007-H-1440.webp", "Image_Order": 6, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000008-H-1440.webp", "Image_Order": 7, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000009-H-1440.webp", "Image_Order": 8, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000010-H-1440.webp", "Image_Order": 9, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000011-H-1440.webp", "Image_Order": 10, "Image_Name": None, "Image_Description": None}
                        , {"Url": "/uploads/project/0001/gallery/0001/000012-H-1440.webp", "Image_Order": 11, "Image_Name": None, "Image_Description": None}],
                "RESOURCES": [{"Type": "PDF", "Size": "5.2 MB", "Name": "About A Chair 154 product sheet"}
                                , {"Type": "ZIP", "Size": "42.1 MB", "Name": "HAY Sample Overview"}
                                , {"Type": "PDF", "Size": "2.4 MB", "Name": "Price Book: HAY"}
                                , {"Type": "PDF", "Size": "2.4 MB", "Name": "HAY Product Portfolio"}],
                "FEATURED": [{"Title": "FEATURED IN PROJECTS"
                                , "Data": [{"Name": "Modern Zen Residence", "Category": "HOSPITALITY | HOTEL", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                            , {"Name": "Minimalist Residence", "Category": "RESIDENTIAL | VILLA", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                            , {"Name": "Brick House", "Category": "CULTURAL | PAVILION", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                            , {"Name": "Modern Zen Residence", "Category": "HOSPITALITY | HOTEL", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                            , {"Name": "Minimalist Residence", "Category": "RESIDENTIAL | VILLA", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                            , {"Name": "Brick House", "Category": "CULTURAL | PAVILION", "URL": "villa-zai-0037"
                                                , "Cover": "/metro/uploads/project/0037/cover/000088-H-450.webp"}
                                        ]}
                            ],
                "Supplier": [{"Name": "Euro Creations", "Category": "Luxury Furniture", "Count": 20000
                                , "Logo": "/uploads/professional/0001/logo/000001-S-180.webp"
                                , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}],
                "Carousel": [{"Title": "PRODUCTS FROM EURO CREATIONS"
                                , "Data": [{"Head_Name": "HAY | About A Chair", "Name": "Layout Chair 112", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "HAY | About A Chair", "Name": "Layout Chair 124", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "HAY | Palissade Collection", "Name": "Eames Shell Chairs", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Quilton Collection", "Name": "Pullman Chair", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Quilton Collection", "Name": "Eames Shell Chairs", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        ]}
                            , {"Title": "OTHER PRODUCTS"
                                , "Data": [{"Head_Name": "HAY | About A Chair", "Name": "Layout Chair 112", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "HAY | About A Chair", "Name": "Layout Chair 124", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "HAY | Palissade Collection", "Name": "Eames Shell Chairs", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Quilton Collection", "Name": "Pullman Chair", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        , {"Head_Name": "Quilton Collection", "Name": "Eames Shell Chairs", "Url": "https://thelist.group/#realdata"
                                            , "Cover": "/uploads/professional/0026/cover/000011-H-1920.webp"}
                                        ]}
                            ]
                }
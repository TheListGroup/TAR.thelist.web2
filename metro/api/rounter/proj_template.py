from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from function_utility import to_problem, apply_etag_and_return, etag_of, require_row_exists
from function_query_helper import _select_full_proj_item, _select_proj_cate, _select_proj_cover, proj_lastest_date \
                                , proj_responsibilities, proj_content, proj_gallery, get_similar_proj, proj_more
from typing import Optional, Tuple, Dict, Any, List

router = APIRouter()

@router.get("/proj-template-test/{Proj_ID}", status_code=200)
def proj_template_data(
    Proj_ID: int,
    _ = Depends(get_current_user),
):
    return {"Proj_ID": Proj_ID,
            "Proj_URL": f"metro/proj/riva-vista-riverfront-resort-0002",
            "Proj_Name": "RIVA VISTA RIVERFRONT RESORT",
            "Proj_Category": "HOTELS | HOSPITALITY",
            "Proj_Cover": "/metro/uploads/project/0002/cover/000005-H-1920.webp",
            "Proj_Information": [{"Hide": {"Location": "Mueang Chiang Rai, Chiang Rai, Thailand",
                                            "Area": "5,530 sq.m.",
                                            "Year": "2023",
                                            "Responsibilities": [{"Res": "Architect Offices", 
                                                                "Prof": [{"Prof_Name": "IDIN Architects", "Member": None
                                                                        , "Anchor": "01-IDIN-Architects"}]}
                                                                , {"Res": "Interior Designers or Interior Architects",
                                                                "Prof": [{"Prof_Name": "IDIN Architects", "Member": None
                                                                        , "Anchor": "02-IDIN-Architects"}]}
                                                                , {"Res": "Landscape Designers or Landscape Architects",
                                                                "Prof": [{"Prof_Name": "Vista Pagoda Co., Ltd.", "Member": None
                                                                        , "Anchor": "03-Vista-Pagoda-Co.,-Ltd."}]}
                                                                ]
                                            }},
                                {"Full": {"Location": "Mueang Chiang Rai, Chiang Rai, Thailand",
                                            "Gross_Building_Area": "5,530 sq.m.",
                                            "Gross_Rental_Area": None,
                                            "Land_Area": None,
                                            "Started_Year": "2019",
                                            "Completed_Year": "2023",
                                            "Renovated_Year": None,
                                            "Category": "HOTELS",
                                            "Responsibilities": [{"Res": "Architect Offices", 
                                                                "Prof": [{"Prof_Name": "IDIN Architects", "Member": None
                                                                        , "Anchor": "01-IDIN-Architects"}]}
                                                                , {"Res": "Interior Designers or Interior Architects",
                                                                "Prof": [{"Prof_Name": "IDIN Architects", "Member": None
                                                                        , "Anchor": "02-IDIN-Architects"}]}
                                                                , {"Res": "Landscape Designers or Landscape Architects",
                                                                "Prof": [{"Prof_Name": "Vista Pagoda Co., Ltd.", "Member": None
                                                                        , "Anchor": "03-Vista-Pagoda-Co.,-Ltd."}]}
                                                                , {"Res": "Main Contractor",
                                                                "Prof": [{"Prof_Name": "Phanpongthai Company Limited", "Member": None
                                                                        , "Anchor": False}]}
                                                                , {"Res": "Photographer",
                                                                "Prof": [{"Prof_Name": "DOF SkyGround", "Member": None
                                                                        , "Anchor": False}]}
                                                                , {"Res": "Project Owner",
                                                                "Prof": [{"Prof_Name": "Lanna Resort Partnership Limited", "Member": None
                                                                        , "Anchor": False}]}
                                                                ]
                                            }
                                }],
            "Content": [{"Topic": "ARCHITECTURAL DESIGN"
                        , "Prof": "IDIN Architects"
                        , "Anchor": "01-IDIN-Architects"
                        , "Content": """<div>
                                    <!-- ส่วนหัวข้อ -->
                                    <div>
                                        <div>ARCHITECTURAL DESIGN by IDIN Architects</div>
                                    </div>
                                    <!-- ย่อหน้าที่ 1 -->
                                    <div>
                                        <div>
                                            Riva Vista Riverfront Resort เป็นโรงแรมขนาด 61 ห้อง ตั้งอยู่ริมแม่น้ำกก ใจกลางจังหวัดเชียงราย เมืองที่มีเอกลักษณ์ทางวัฒนธรรมล้านนาและกำลังเติบโตอย่างรวดเร็วในฐานะจุดหมายปลายทางด้านการท่องเที่ยว
                                        </div>
                                    </div>
                                    <!-- รูปภาพหลัก -->
                                    <div>
                                        <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000001-H-1440.webp" alt="Interior design main view">
                                    </div>
                                    <!-- ย่อหน้าที่ 2 -->
                                    <div>
                                        <div>
                                            แนวคิดหลักของโครงการคือการผสมผสานสถาปัตยกรรมสมัยใหม่เข้ากับภาษาสถาปัตยกรรมพื้นถิ่นล้านนา เปรียบเสมือนการนำวัตถุดิบดั้งเดิมมาปรุงด้วยเทคนิคร่วมสมัย เพื่อสร้างสมดุลระหว่างความเก่าและความใหม่
                                        </div>
                                    </div>
                                    <!-- ส่วนรูปภาพคู่ -->
                                    <div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000002-H-1440.webp" alt="Interior detail 1">
                                        </div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000003-H-1440.webp" alt="Interior detail 2">
                                        </div>
                                    </div>
                                    <!-- ย่อหน้าสุดท้าย -->
                                    <div>
                                        <div>
                                            ลักษณะของพื้นที่โครงการมีความพิเศษ เนื่องจากถูกถนนแบ่งออกเป็นสองแปลง โดยแปลงที่ติดแม่น้ำกกถูกออกแบบให้เป็นอาคารหลักที่รองรับห้องอาหารแบบ All-day dining และห้องสวีต เพื่อใช้ประโยชน์จากวิวแม่น้ำ
                                        </div>
                                    </div>
                                    <div>
                                        <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000004-H-1440.webp" alt="Interior design main view">
                                    </div>
                                    <div>
                                        <div>
                                            การวางผังใช้ระบบทางเดินแบบ Single Corridor เพื่อให้ห้องพักทุกห้องสามารถมองเห็นวิวแม่น้ำได้ นอกจากนี้อาคารยังถูกแบ่งออกเป็นสองส่วน เพื่อเปิดมุมมองไปยังต้นจามจุรียักษ์เดิมของพื้นที่ และสร้างทางเชื่อมไปยังพื้นที่ริมน้ำ
                                        </div>
                                    </div>
                                    <div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000005-H-1440.webp" alt="Interior detail 1">
                                        </div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000006-H-1440.webp" alt="Interior detail 2">
                                        </div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000007-H-1440.webp" alt="Interior detail 2">
                                        </div>
                                    </div>
                                    <div>
                                        <div>
                                            อีกด้านหนึ่งของโครงการ ซึ่งอยู่หลังถนน ถูกออกแบบเป็นอาคารรูปตัว L โอบล้อมสระว่ายน้ำกลาง โดยห้องพักทุกห้องสามารถเข้าถึงสระได้โดยตรง เพื่อชดเชยการที่ไม่มีวิวแม่น้ำ มวลอาคารในส่วนนี้ประกอบด้วยพื้นที่สำคัญ เช่น ล็อบบี้ ห้องสัมมนา ฟิตเนส และสปา ซึ่งล้อมรอบลานกลางที่มีสระว่ายน้ำเป็นจุดศูนย์กลาง
                                        </div>
                                    </div>
                                    <div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000008-H-1440.webp" alt="Interior detail 1">
                                        </div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000009-H-1440.webp" alt="Interior detail 2">
                                        </div>
                                    </div>
                                    <div>
                                        <div>
                                            ในด้านรูปแบบสถาปัตยกรรม สถาปนิกใช้แนวคิดของความตัดกันระหว่างพื้นที่ทึบและพื้นที่เปิด ผสานกับโทนสีขาวที่เรียบง่ายและสงบนิ่ง
                                        </div>
                                    </div>
                                    <div>
                                        <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000010-H-1440.webp" alt="Interior design main view">
                                    </div>
                                    <div>
                                        <div>
                                            ฟาซาดฝั่งถนนยังนำบานประตูไม้เก่ามาประยุกต์เป็นแผงกันแดดของทางเดิน พร้อมแทรกกระถางต้นไม้ในตำแหน่งต่าง ๆ จนเกิดเป็นภาษาทางสถาปัตยกรรมเฉพาะตัวที่สะท้อนเอกลักษณ์ของโครงการ
                                        </div>
                                    </div>
                                    <div>
                                        <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000012-H-1440.webp" alt="Interior design main view">
                                    </div>
                                </div>"""},
                        {"Topic": "INTERIOR DESIGN"
                        , "Prof": "IDIN Architects"
                        , "Anchor": "02-IDIN-Architects"
                        , "Content": """<div>
                                    <!-- ส่วนหัวข้อ -->
                                    <div>
                                        <div>INTERIOR DESIGN by IDIN Architects</div>
                                    </div>
                                    <!-- ย่อหน้าที่ 1 -->
                                    <div>
                                        <div>
                                            การออกแบบภายในของ Riva Vista Riverfront Resort ยังคงสานต่อแนวคิดการผสมผสานระหว่างสถาปัตยกรรมร่วมสมัยกับเอกลักษณ์พื้นถิ่นล้านนา โดยนำองค์ประกอบดั้งเดิมของสถาปัตยกรรมล้านนามาตีความใหม่ให้สอดคล้องกับบริบทของโรงแรมร่วมสมัย
                                        </div>
                                    </div>
                                    <!-- รูปภาพหลัก -->
                                    <div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000013-H-1440.webp" alt="Interior detail 1">
                                        </div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000014-H-1440.webp" alt="Interior detail 2">
                                        </div>
                                    </div>
                                    <!-- ย่อหน้าที่ 2 -->
                                    <div>
                                        <div>
                                            หนึ่งในแนวคิดสำคัญคือการหยิบยกองค์ประกอบพื้นถิ่นมาใช้เป็นแรงบันดาลใจในการออกแบบเฟอร์นิเจอร์และพื้นที่ภายใน ตัวอย่างเช่น “เติ๋น” ซึ่งเป็นแท่นยกระดับอเนกประสงค์ในบ้านล้านนา ถูกนำมาปรับใช้เป็นพื้นที่นั่งเล่นหรือพื้นที่ใช้งานหลากหลายรูปแบบภายในโรงแรม
                                        </div>
                                    </div>
                                    <!-- ส่วนรูปภาพคู่ -->
                                    <div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000015-H-1440.webp" alt="Interior detail 1">
                                        </div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000016-H-1440.webp" alt="Interior detail 2">
                                        </div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000017-H-1440.webp" alt="Interior detail 3">
                                        </div>
                                    </div>
                                    <!-- ย่อหน้าสุดท้าย -->
                                    <div>
                                        <div>
                                            อีกองค์ประกอบหนึ่งคือ “ควัน” โครงแขวนเก็บของแบบดั้งเดิมที่มีลักษณะเป็นตะแกรงไม้ไขว้ติดกับเพดาน ซึ่งถูกตีความใหม่เป็นองค์ประกอบตกแต่งเพดานที่สร้างจังหวะและมิติให้กับพื้นที่ภายใน
                                        </div>
                                    </div>
                                    <div>
                                        <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000018-H-1440.webp" alt="Interior design main view">
                                    </div>
                                    <div>
                                        <div>
                                            นอกจากนี้ยังมี “ร้านน้ำ” หรือ “ฮ้านน้ำ” ซึ่งเป็นชั้นวางน้ำที่ชาวล้านนาใช้วางเหยือกน้ำต้อนรับผู้สัญจรผ่านไปมา แนวคิดขององค์ประกอบนี้ถูกนำมาปรับใช้กับเฟอร์นิเจอร์และชั้นวางภายใน เพื่อสะท้อนวัฒนธรรมการต้อนรับแบบท้องถิ่น
                                        </div>
                                    </div>
                                    <div>
                                        <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000019-H-1440.webp" alt="Interior design main view">
                                    </div>
                                    <div>
                                        <div>
                                            วัสดุที่ใช้ภายในเน้นไม้และงานต่อไม้แบบดั้งเดิม โดยตั้งใจโชว์รายละเอียดของรอยต่อไม้ เพื่อสะท้อนภูมิปัญญาช่างไม้พื้นถิ่น ผสมผสานกับโทนสีที่เรียบง่ายและการออกแบบร่วมสมัย ทำให้พื้นที่ภายในของโรงแรมมีบรรยากาศอบอุ่น เรียบง่าย และยังคงกลิ่นอายของสถาปัตยกรรมล้านนาไว้อย่างชัดเจน
                                        </div>
                                    </div>
                                    <div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000020-H-1440.webp" alt="Interior detail 1">
                                        </div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000021-H-1440.webp" alt="Interior detail 2">
                                        </div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000022-H-1440.webp" alt="Interior detail 3">
                                        </div>
                                    </div>
                                </div>"""},
                        {"Topic": "LANDSCAPE DESIGN"
                        , "Prof": "Vista Pagoda Co., Ltd."
                        , "Anchor": "03-Vista Pagoda Co., Ltd."
                        , "Content": """<div>
                                    <!-- ส่วนหัวข้อ -->
                                    <div>
                                        <div>LANDSCAPE DESIGN by Vista Pagoda Co., Ltd.</div>
                                    </div>
                                    <!-- ย่อหน้าที่ 1 -->
                                    <div>
                                        <div>
                                            การออกแบบภูมิทัศน์ของ Riva Vista Riverfront Resort ให้ความสำคัญกับความสัมพันธ์ระหว่างอาคาร สภาพแวดล้อม และแม่น้ำกก ซึ่งเป็นองค์ประกอบสำคัญของบริบทพื้นที่ในจังหวัดเชียงราย
                                        </div>
                                    </div>
                                    <div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000023-H-1440.webp" alt="Interior detail 1">
                                        </div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000024-H-1440.webp" alt="Interior detail 2">
                                        </div>
                                    </div>
                                    <!-- ย่อหน้าที่ 2 -->
                                    <div>
                                        <div>
                                            หนึ่งในองค์ประกอบหลักของพื้นที่คือ ต้นจามจุรียักษ์ ที่มีอยู่เดิมในไซต์ สถาปนิกเลือกที่จะรักษาและใช้ต้นไม้ใหญ่ต้นนี้เป็นจุดสำคัญของพื้นที่ โดยออกแบบการวางอาคารให้เปิดมุมมองไปยังต้นไม้ พร้อมสร้างทางเดินที่เชื่อมต่อไปยังพื้นที่ริมน้ำ ทำให้ภูมิทัศน์ธรรมชาติกลายเป็นส่วนหนึ่งของประสบการณ์ของผู้เข้าพัก
                                        </div>
                                    </div>
                                    <!-- ส่วนรูปภาพคู่ -->
                                    <div>
                                        <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000025-H-1440.webp" alt="Interior detail 1">
                                    </div>
                                    <!-- ย่อหน้าสุดท้าย -->
                                    <div>
                                        <div>
                                            พื้นที่สระว่ายน้ำกลางถูกออกแบบให้เป็น courtyard ที่ล้อมรอบด้วยอาคารรูปตัว L สร้างพื้นที่กึ่งส่วนตัวสำหรับการพักผ่อนและกิจกรรมของผู้เข้าพัก ห้องพักหลายห้องสามารถเข้าถึงสระว่ายน้ำได้โดยตรง ซึ่งช่วยสร้างประสบการณ์การใช้งานพื้นที่กลางแจ้งที่ใกล้ชิดกับธรรมชาติ
                                        </div>
                                    </div>
                                    <div>
                                        <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000026-H-1440.webp" alt="Interior detail 1">
                                    </div>
                                    <div>
                                        <div>
                                            นอกจากนี้ การแทรกต้นไม้และกระถางต้นไม้ในบริเวณทางเดินและฟาซาดของอาคาร ยังช่วยสร้างความร่มรื่นและเชื่อมโยงพื้นที่สถาปัตยกรรมเข้ากับภูมิทัศน์โดยรอบ ส่งผลให้บรรยากาศโดยรวมของโครงการมีความผ่อนคลายและสอดคล้องกับธรรมชาติของพื้นที่ริมแม่น้ำ.
                                        </div>
                                    </div>
                                    <div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000027-H-1440.webp" alt="Interior detail 1">
                                        </div>
                                        <div>
                                            <img src="http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000028-H-1440.webp" alt="Interior detail 2">
                                        </div>
                                    </div>
                                </div>"""}],
            "Gallery": [{"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000001-H-1440.webp", "Image_Order": 1, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000002-H-1440.webp", "Image_Order": 2, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000003-H-1440.webp", "Image_Order": 3, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000004-H-1440.webp", "Image_Order": 4, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000005-H-1440.webp", "Image_Order": 5, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000006-H-1440.webp", "Image_Order": 6, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000007-H-1440.webp", "Image_Order": 7, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000008-H-1440.webp", "Image_Order": 8, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000009-H-1440.webp", "Image_Order": 9, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000010-H-1440.webp", "Image_Order": 10, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0001/000012-H-1440.webp", "Image_Order": 11, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000013-H-1440.webp", "Image_Order": 12, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000014-H-1440.webp", "Image_Order": 13, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000015-H-1440.webp", "Image_Order": 14, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000016-H-1440.webp", "Image_Order": 15, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000017-H-1440.webp", "Image_Order": 16, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000018-H-1440.webp", "Image_Order": 17, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000019-H-1440.webp", "Image_Order": 18, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000020-H-1440.webp", "Image_Order": 19, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000021-H-1440.webp", "Image_Order": 20, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0002/000022-H-1440.webp", "Image_Order": 21, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000023-H-1440.webp", "Image_Order": 22, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000024-H-1440.webp", "Image_Order": 23, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000025-H-1440.webp", "Image_Order": 24, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000026-H-1440.webp", "Image_Order": 25, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000027-H-1440.webp", "Image_Order": 26, "Image_Name": None, "Image_Description": None}
                        , {"Url": "http://159.223.76.99/metro/uploads/project/0002/gallery/0003/000028-H-1440.webp", "Image_Order": 27, "Image_Name": None, "Image_Description": None}],
            "Similar Project": [{"Prof_ID": 7, "Prof": "IDIN Architects", "Image": None, "Res": "Architectural Design", "Experience": "Commercial, Hospitality, Residential",
                                "Proj": [{"Prof_ID": 7, "Proj_ID": 3, "Name": "aaa", "Category": "Hospitality | Hotels", "URL": "aaa-0003", "Cover": None}]
                                },
                                {"Prof_ID": 8, "Prof": "Vista Pagoda Co., Ltd.", "Image": None, "Res": "Landscape Design", "Experience": "Commercial",
                                "Proj": [{"Prof_ID": 8, "Proj_ID": 1, "Name": "x", "Category": "Hospitality | Resorts", "URL": "x-0001",
                                        "Cover": [{"Image_Url": "/metro/uploads/project/0001/cover/000019-H-450.webp"}
                                                ,{"Image_Url": "/metro/uploads/project/0001/cover/000020-H-350.webp"}
                                                ]
                                        },
                                        {"Prof_ID": 8, "Proj_ID": 4, "Name": "bbbb", "Category": "Hospitality | Hotels", "URL": "bbbb-0004", "Cover": None}]
                                }],
            "More_Proj": [{"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Urban Loft Conversation",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Vertical Forest Tower",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Cultural Heritage Museum",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "LIBLARY | CULTURAL",
                            "Name": "Floating Pavilion",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "The Obsidian Monolith",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Ethereal Void Pavilion",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Luminous Concrete Gallery",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Crestview Modern Residency",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Axis Point Museum",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "The Floating Atrium",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Zenith Urban Lab",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Shadow & Light Sanctuary",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Minimalist Horizon House",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "The Geometric Fold",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Pure Form Studio",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Echoing Silence Library",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "The Translucent Courtyard",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Monochromatic Peak",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Tectonic Flow Center",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"},
                        {"Proj_Category": "MUSEUM | CULTURAL",
                            "Name": "Urban Loft Conversation",
                            "Image": "https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?auto=format&fit=crop&q=80&w=1200"}]
            }

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
    data["Proj_URL"] = "metro/proj/" + project_data["Proj_URL_Tag"]
    data["Proj_Name"] = project_data.get("Name_EN")
    
    category_data = _select_proj_cate(Proj_ID, 'header')
    full_cate = category_data.get("Category_Header", None)
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
    if rai and ngan and wa:
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
    year = date_data.get("Latest_Date", None)
    hide["Year"] = year
    
    hide["Responsibilities"] = proj_responsibilities(Proj_ID, 'hide')
    
    hide_data = {"Hide": hide}
    information_data.append(hide_data)
    
    full = {}
    full["Location"] = location_text
    full["Gross_Building_Area"] = f"{'{:,.0f}'.format(round(project_data.get('Usable_Area')))} sq.m." if project_data.get('Usable_Area') else None
    full["Gross_Rental_Area"] = f"{'{:,.0f}'.format(round(project_data.get('Commercial_Area')))} sq.m." if project_data.get('Commercial_Area') else None
    full["Land_Area"] = f"{land_area} rai" if land_area else None
    full["Started_Year"] = date_data.get("Start_Date", None)
    full["Completed_Year"] = date_data.get("Finish_Date", None)
    full["Renovated_Year"] = date_data.get("Renovated_Date", None)
    
    category_data = _select_proj_cate(Proj_ID, 'full')
    full["Category"] = category_data.get("Category_Group", None)
    
    full["Responsibilities"] = proj_responsibilities(Proj_ID, 'full')
    full_data = {"Full": full}
    
    information_data.append(full_data)
    data["Proj_Information"] = information_data
    
    content, profs = proj_content(Proj_ID)
    data["Content"] = content
    
    gallery = proj_gallery(Proj_ID)
    data["Gallery"] = gallery
    
    similar_proj = get_similar_proj(profs, Proj_ID)
    data["Similar_Proj"] = similar_proj
    
    sub_cate = full_cate.split(" | ")[-1]
    more_proj = proj_more(Proj_ID, sub_cate)
    data["More_Proj"] = more_proj
    
    return data
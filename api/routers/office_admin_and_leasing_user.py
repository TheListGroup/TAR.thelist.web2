from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status, UploadFile, File
from db import get_db
from auth import get_current_user  # << ใช้ตัวเดิม (รองรับ ADMIN_TOKEN หรือ JWT)
from pydantic import constr
from function_utility import to_problem, apply_etag_and_return
from function_query_helper import _select_full_admin_and_leasing_user
import os, uuid, shutil
from PIL import Image
from enum import Enum

router = APIRouter()
TABLE = "office_admin_and_leasing_user"

UPLOAD_DIR = "/var/www/html/real-lease/uploads"
PUBLIC_PREFIX = "/real-lease/uploads"
ALLOWED_EXT = {".jpg", ".jpeg", ".png", ".webp", ".gif"}

os.makedirs(UPLOAD_DIR, exist_ok=True)

class RoleEnum(Enum):
    realist = "realist"
    agent = "agent"
    leasing = "leasing"

PhoneNumber = constr(pattern=r'^\+?[0-9]{7,15}$')

def _save_one_file(f: UploadFile, user_id: int) -> dict:
    name = f.filename or "unnamed"
    ext = os.path.splitext(name)[1].lower()
    if ext not in ALLOWED_EXT:
        raise HTTPException(status_code=400, detail=f"File type not allowed: {ext}")

    filename = f"{user_id:05d}.webp"
    dest_path = os.path.join(UPLOAD_DIR, filename)
    image = Image.open(f.file).convert("RGB")  # convert to RGB for webp
    image.save(dest_path, "WEBP", quality=85)
    
    return os.path.join(PUBLIC_PREFIX, filename)

# ----------------------------------------------------- INSERT --------------------------------------------------------------------------------------------
@router.post("/insert", status_code=201)
def insert_office_admin_and_leasing_user_and_return_full_record(
    response: Response,
    Role: RoleEnum = Form(...),
    Company_Name: str = Form(...),
    Phone_Number: PhoneNumber = Form(...),
    FullName: str = Form(...),
    Email: str = Form(...),
    User_Name: str = Form(...),
    Password: str = Form(...),
    Profile_Picture: UploadFile = File(None),
    User_Status: str = Form("1"),
    _ = Depends(get_current_user),
):
    try:
        User_Status = User_Status if User_Status else '1'
        if Role == RoleEnum.realist:
            Role_format = 1
        elif Role == RoleEnum.agent:
            Role_format = 2
        elif Role == RoleEnum.leasing:
            Role_format = 3

    except ValueError:
        return to_problem(422, "Validation Error", "Invalid Data")
    
    try:
        conn = get_db()
        cur = conn.cursor()
        sql = f"""
            INSERT INTO {TABLE}
            (Role_ID, Company_Name, Phone_Number, User_FullName, Email, User_User_Name, User_Password, Profile_Picture, User_Status)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cur.execute(sql, (
            Role_format, Company_Name, Phone_Number, FullName, Email, User_Name, Password, None, User_Status
        ))
        conn.commit()
        new_id = cur.lastrowid
        
        if Profile_Picture:
            file_name = _save_one_file(Profile_Picture, new_id)
            sql = f"""
                UPDATE {TABLE}
                SET Profile_Picture=%s
                WHERE User_ID=%s
            """
            cur.execute(sql, (file_name, new_id))
            conn.commit()

        cur.close()
        conn.close()
    except Exception as e:
        return to_problem(409, "Conflict", f"Insert failed: {e}")

    row = _select_full_admin_and_leasing_user(new_id)
    if not row:
        return to_problem(500, "Server Error", "Created but cannot fetch newly created resource.")
    response.headers["Location"] = f"/office-admin-and-leasing-user/select-office-admin-and-leasing-user/{new_id}"
    return apply_etag_and_return(response, row)
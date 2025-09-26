# /var/www/fastapi/main.py
from fastapi import FastAPI
from auth import router as auth_router
#from routers.office_unit_min import router as office_unit_min_router
from routers.office_unit import router as office_unit_router
from routers.office_admin_and_leasing_user import router as office_admin_and_leasing_user_router
from routers.office_project import router as office_project_router
from routers.office_building import router as office_building_router
import os

ROOT_PATH = os.getenv("ROOT_PATH", "")  # เว้นว่างได้ถ้าเข้าตรงพอร์ต

app = FastAPI(
    title="API",
    root_path=ROOT_PATH,           # >> สำคัญเมื่ออยู่ใต้ subpath
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",   # ปล่อยค่าเริ่มต้นนี้ไว้
)

app.router.redirect_slashes = False
# เดิม: /api
# ใหม่: /fastapi
app.include_router(auth_router, prefix="/fastapi",  tags=["auth"])
#app.include_router(office_unit_router, prefix="/fastapi/office-units", tags=["office_unit"])
app.include_router(office_unit_router, prefix="/office-units", tags=["office_unit"])
app.include_router(office_admin_and_leasing_user_router, prefix="/office-admin-and-leasing-user", tags=["office_admin_and_leasing_user"])
app.include_router(office_project_router, prefix="/office-project", tags=["office_project"])
app.include_router(office_building_router, prefix="/office-building", tags=["office_building"])
# /var/www/fastapi/main.py
from fastapi import FastAPI
from auth import router as auth_router
from routers.prof import router as prof_router
from routers.proj_template import router as proj_template_router
from routers.prof_template import router as prof_template_router
from routers.proj import router as proj_router
import os

ROOT_PATH = os.getenv("ROOT_PATH", "/metro/fastapi")  # เว้นว่างได้ถ้าเข้าตรงพอร์ต

app = FastAPI(
    title="API",
    root_path=ROOT_PATH,           # >> สำคัญเมื่ออยู่ใต้ subpath
    docs_url="/docs",
    redoc_url="/redoc",
    openapi_url="/openapi.json",   # ปล่อยค่าเริ่มต้นนี้ไว้
)

app.router.redirect_slashes = False
@app.get("/health")
def health():
    return {"status": "ok"}
# เดิม: /api
# ใหม่: /fastapi
app.include_router(auth_router, prefix="/fastapi",  tags=["auth"])
app.include_router(prof_router, prefix="/professionals", tags=["prof"])
app.include_router(proj_template_router, prefix="/project-template", tags=["proj-template"])
app.include_router(prof_template_router, prefix="/professional-template", tags=["prof-template"])
app.include_router(proj_router, prefix="/projects", tags=["proj"])
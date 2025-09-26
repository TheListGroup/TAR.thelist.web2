# /var/www/fastapi/auth.py
from fastapi import APIRouter, HTTPException, status, Header
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from datetime import datetime, timedelta
from pydantic import BaseModel
import os, secrets

router = APIRouter()

HARDCODED_ADMIN_TOKEN = "XHoSLQapNT0ZRpjzsv8BAB0vWQHJPjR81n5FKi3GixM"

# ====== JWT (ยังคงเผื่อรองรับได้ ถ้าคุณจะใช้ในอนาคต) ======
SECRET_KEY = os.getenv("JWT_SECRET_KEY", "your_secret_key_here")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60"))

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/fastapi/login")

class LoginRequest(BaseModel):
    username: str
    password: str

# ตัวอย่างเดิม (ถ้าไม่ใช้ก็ไม่เรียก)
DEMO_USER = {"username": "admin@example.com", "password": "secret123"}

def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# ====== Long-lived Admin Token (โหมดที่คุณต้องการ) ======
# ตั้งค่า ADMIN_TOKEN ไว้ใน env หรือไฟล์
#_ADMIN_TOKEN = os.getenv("ADMIN_TOKEN")
_ADMIN_TOKEN = HARDCODED_ADMIN_TOKEN or os.getenv("ADMIN_TOKEN")
_ADMIN_TOKEN_FILE = os.getenv("ADMIN_TOKEN_FILE")
#_ADMIN_TOKEN_FILE = os.getenv("ADMIN_TOKEN_FILE")
if not _ADMIN_TOKEN and _ADMIN_TOKEN_FILE:
    try:
        with open(_ADMIN_TOKEN_FILE, "r", encoding="utf-8") as f:
            _ADMIN_TOKEN = f.read().strip()
    except Exception:
        pass

def generate_admin_token(nbytes: int = 32) -> str:
    """ใช้สำหรับ 'สร้าง' token ที่จะใช้ยาวๆ (รันครั้งเดียวแล้วเก็บค่าไปใส่ที่ ENV/ไฟล์)"""
    return secrets.token_urlsafe(nbytes)

def _raise_unauthorized(detail: str = "Unauthorized"):
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail=detail,
        headers={"WWW-Authenticate": "Bearer"},
    )

def get_current_user(Authorization: str | None = Header(default=None), X_Admin_Token: str | None = Header(default=None)):
    """
    กลไกตรวจสอบสิทธิ์:
    1) ถ้ามี ADMIN_TOKEN กำหนดไว้ → ตรวจสอบว่า:
       - Authorization: Bearer <token> หรือ
       - X-Admin-Token: <token>
       ตรงกับ ADMIN_TOKEN → อนุญาตทันที (ใช้เป็น long-lived token)
    2) ถ้าไม่พบ/ไม่ตรง → (option) ลองตรวจ JWT เดิม (เพื่อ backward compatible)
    """
    # ---- Admin token path (แนะนำให้ใช้โหมดนี้เป็นหลัก) ----
    token = None
    if Authorization and Authorization.lower().startswith("bearer "):
        token = Authorization.split(" ", 1)[1].strip()
    if X_Admin_Token and not token:
        token = X_Admin_Token.strip()

    if _ADMIN_TOKEN:
        if not token:
            _raise_unauthorized("Missing admin token")
        if token == _ADMIN_TOKEN:
            # คืนข้อมูลผู้ใช้แบบง่ายๆ ให้ dependency อื่นๆ ใช้ได้ต่อ
            return {"sub": "admin", "auth": "admin_token"}
        # ถ้าไม่ตรง ลอง JWT ต่อด้านล่าง (เพื่อความยืดหยุ่น); ถ้าไม่ต้องการ ให้ _raise_unauthorized เลยก็ได้

    # ---- JWT fallback (optional / เผื่อยังต้องการ) ----
    if not token:
        _raise_unauthorized("Missing token")

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        sub = payload.get("sub")
        if not sub:
            _raise_unauthorized("Token missing subject")
        return {"sub": sub, "auth": "jwt"}
    except JWTError:
        _raise_unauthorized("Invalid token")

# ====== (เดิม) /login ยังอยู่ เผื่อใช้ได้ในอนาคต ======
@router.post("/login")
def login(body: LoginRequest):
    if body.username == DEMO_USER["username"] and body.password == DEMO_USER["password"]:
        token = create_access_token({"sub": body.username})
        return {"access_token": token, "token_type": "bearer"}
    raise HTTPException(status_code=401, detail="Invalid username or password")

# เผื่อ front/proxy เติมสแลช
@router.post("/login/")
def login_with_slash(body: LoginRequest):
    return login(body)

# ====== CLI ช่วยสร้าง token ======
if __name__ == "__main__":
    print(generate_admin_token())

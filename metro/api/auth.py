# /var/www/fastapi/auth.py
from fastapi import APIRouter, HTTPException, status, Header
import os, hmac

router = APIRouter()

# ====== CONFIG ======
# กำหนด ADMIN_TOKEN ใน .env ให้ “ตรงกับ” ที่ PHP/Nginx ใส่มา
_ADMIN_TOKEN = os.getenv("ADMIN_TOKEN") or "XHoSLQapNT0ZRpjzsv8BAB0vWQHJPjR81n5FKi3GixM"
#_ADMIN_TOKEN = os.getenv("ADMIN_TOKEN") #, "") or ""
# เปิด/ปิดการรองรับ JWT fallback (ค่าเริ่มต้นปิด)
_ENABLE_JWT_FALLBACK = os.getenv("ENABLE_JWT_FALLBACK", "0") == "1"

# (optional) ถ้าจะใช้ JWT fallback จริงๆ ค่อยเตรียมค่าเหล่านี้
SECRET_KEY  = os.getenv("SECRET_KEY", "")
ALGORITHM   = os.getenv("ALGORITHM", "HS256")

def _unauth(detail="Unauthorized"):
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=detail)

def _forbid(detail="Forbidden"):
    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=detail)

def _consteq(a: str | None, b: str | None) -> bool:
    # เทียบแบบ constant-time
    return bool(a) and bool(b) and hmac.compare_digest(a, b)

def _extract_token(
    authorization: str | None,
    x_admin_token: str | None,
    x_api_token: str | None,
) -> str | None:
    """
    ลำดับความสำคัญ:
    1) X-Api-Token        (Nginx/bridge มักจะใส่ให้)
    2) X-Admin-Token      (ส่งมาตรงๆ)
    3) Authorization: Bearer <token>
    """
    if x_api_token:
        return x_api_token.strip()
    if x_admin_token:
        return x_admin_token.strip()
    if authorization and authorization.lower().startswith("bearer "):
        return authorization.split(" ", 1)[1].strip()
    return None


# ========= DEPENDENCY หลัก =========
async def get_current_user(
    authorization: str | None = Header(default=None, alias="Authorization"),
    x_admin_token: str | None = Header(default=None, alias="X-Admin-Token"),
    x_api_token: str | None = Header(default=None, alias="X-Api-Token"),
):
    """
    โหมดแนะนำ: ใช้ ADMIN_TOKEN ตัวเดียว (long-lived) ที่ตั้งใน .env
    - รับจากหัวข้อใดก็ได้: X-Api-Token / X-Admin-Token / Authorization: Bearer
    - เทียบแบบ constant-time (hmac.compare_digest)
    - ปิด JWT fallback โดยค่าเริ่มต้น (เปิดได้ด้วย ENABLE_JWT_FALLBACK=1)
    """
    token = _extract_token(authorization, x_admin_token, x_api_token)

    # 1) Admin token path (แนะนำให้ใช้หลัก)
    if _ADMIN_TOKEN:
        if not token:
            _unauth("Missing admin token")
        if _consteq(token, _ADMIN_TOKEN):
            # success
            return {"sub": "admin", "auth": "admin_token"}
        # ถ้าไม่ตรง แล้วไม่เปิด fallback → จบเลย
        if not _ENABLE_JWT_FALLBACK:
            _unauth("Invalid admin token")

    # 2) (ถ้าจำเป็นจริงๆ) JWT fallback
    if not _ENABLE_JWT_FALLBACK:
        _unauth("Missing or invalid token")

    # ---- JWT ตรวจ (ต้องมี PyJWT/JOSE ติดตั้งเอง) ----
    # from jose import jwt, JWTError
    try:
        from jose import jwt, JWTError
    except Exception:
        _unauth("JWT not supported on server")

    if not token:
        _unauth("Missing token")
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        sub = payload.get("sub")
        if not sub:
            _unauth("Token missing subject")
        return {"sub": sub, "auth": "jwt"}
    except Exception:
        _unauth("Invalid token")


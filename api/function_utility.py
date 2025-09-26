# /var/www/fastapi/routers/office_unit_min.py
from fastapi import APIRouter, Form, Depends, Query, Response, Header, HTTPException, Request, status
from fastapi.responses import JSONResponse
from typing import Optional, Tuple, Dict, Any, List
import hashlib, json
from datetime import datetime, timezone
from urllib.parse import urlencode, urlunparse, urlparse, parse_qsl

def iso8601_z(dt) -> Optional[str]:
    """แปลง datetime เป็น ISO8601 ลงท้าย Z; รับได้ทั้ง str/datetime/None"""
    if dt is None:
        return None
    if isinstance(dt, str):
        # สมมติ DB คืนมาเป็น str อยู่แล้ว
        return dt if dt.endswith("Z") else dt
    if isinstance(dt, datetime):
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        else:
            dt = dt.astimezone(timezone.utc)
        return dt.isoformat().replace("+00:00", "Z")
    return str(dt)

def to_problem(status_code:int, title:str, detail:str, type_url:str = "", errors:List[dict]|None=None, headers:Dict[str,str]|None=None):
    body = {
        "type": type_url or f"https://api.example.com/errors/{title.lower().replace(' ', '_')}",
        "title": title,
        "status": status_code,
        "detail": detail
    }
    if errors:
        body["errors"] = errors
    return JSONResponse(status_code=status_code, content=body, media_type="application/problem+json", headers=headers or {})

def etag_of(obj: Dict[str, Any]) -> str:
    """คำนวณ ETag จาก payload (stable, short)"""
    payload = json.dumps(obj, sort_keys=True, default=str).encode("utf-8")
    digest = hashlib.sha256(payload).hexdigest()[:16]
    return f'"{digest}"'

def apply_etag_and_return(response: Response, obj: Dict[str, Any]) -> Dict[str, Any]:
    et = etag_of(obj)
    response.headers["ETag"] = et
    return obj

def normalize_unit_row(row: Dict[str, Any]) -> Dict[str, Any]:
    """ทำความสะอาด row: แปลงวันที่เป็น ISO8601Z"""
    if not row:
        return row
    for k in ("Created_Date", "Last_Updated_Date", "Available"):
        if k in row:
            row[k] = iso8601_z(row[k])
    return row

def build_pagination_links(request: Request, page:int, size:int, total:int) -> Dict[str, Optional[str]]:
    pages = max((total + size - 1) // size, 1)
    def make_url(new_page:int) -> str:
        url = urlparse(str(request.url))
        qs = dict(parse_qsl(url.query, keep_blank_values=True))
        # รองรับ page[number]/page[size] ตามแนวทาง
        qs["page[number]"] = str(new_page)
        qs["page[size]"] = str(size)
        new_qs = urlencode(qs, doseq=True)
        return urlunparse((url.scheme, url.netloc, url.path, url.params, new_qs, url.fragment))

    links = {
        "self": make_url(page),
        "next": make_url(page + 1) if page < pages else None,
        "prev": make_url(page - 1) if page > 1 else None
    }
    return links

def require_row_exists(row: Dict[str, Any], unit_id: int, text_type: str):
    if not row:
        raise HTTPException(status_code=404, detail=f"{text_type} '{unit_id}' was not found")

def normalize_row(row: Dict[str, Any]) -> Dict[str, Any]:
    """ทำความสะอาด row: แปลงวันที่เป็น ISO8601Z"""
    if not row:
        return row
    for k in ("Created_Date", "Last_Updated_Date"):
        if k in row:
            row[k] = iso8601_z(row[k])
    return row
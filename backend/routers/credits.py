from fastapi import APIRouter, HTTPException, Header
from pydantic import BaseModel
from ..services.firebase_service import deduct_credits, get_user
import firebase_admin.auth as fb_auth

router = APIRouter()


class DeductRequest(BaseModel):
    amount: int = 5


class DeductResponse(BaseModel):
    success: bool
    remaining_credits: int


@router.post("/api/credits/deduct", response_model=DeductResponse)
async def deduct_user_credits(
    body: DeductRequest,
    authorization: str = Header(...),
):
    token = authorization.removeprefix("Bearer ").strip()
    try:
        decoded = fb_auth.verify_id_token(token)
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid auth token")

    uid = decoded["uid"]
    user = await get_user(uid)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")

    current_credits: int = user.get("credits", 0)
    if current_credits < body.amount:
        raise HTTPException(status_code=402, detail="Insufficient credits")

    remaining = await deduct_credits(uid, body.amount)
    return DeductResponse(success=True, remaining_credits=remaining)

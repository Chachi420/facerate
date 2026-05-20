from fastapi import APIRouter, HTTPException, Header
from pydantic import BaseModel
import firebase_admin.auth as fb_auth
from services.firebase_service import (
    award_credits,
    activate_pro,
    is_purchase_processed,
    record_purchase,
)
from services.google_play_service import verify_product_purchase, verify_subscription

router = APIRouter()

PACKAGE_NAME = "com.facerate.app"

# How many credits each product awards
CREDIT_AMOUNTS: dict[str, int] = {
    "credits_10": 10,
    "credits_30": 30,
    "credits_100": 100,
}


class VerifyRequest(BaseModel):
    product_id: str
    purchase_token: str


class VerifyResponse(BaseModel):
    success: bool
    credits_awarded: int = 0
    is_pro: bool = False
    total_credits: int = 0


@router.post("/api/iap/verify", response_model=VerifyResponse)
async def verify_purchase(
    body: VerifyRequest,
    authorization: str = Header(...),
):
    # Authenticate user via Firebase ID token
    token = authorization.removeprefix("Bearer ").strip()
    try:
        decoded = fb_auth.verify_id_token(token)
    except Exception:
        raise HTTPException(status_code=401, detail="Invalid auth token")

    uid = decoded["uid"]

    # Idempotency: reject already-processed purchase tokens
    if await is_purchase_processed(uid, body.purchase_token):
        raise HTTPException(
            status_code=409,
            detail="This purchase has already been credited to your account.",
        )

    # ── Consumable credit packs ──────────────────────────────────────
    if body.product_id in CREDIT_AMOUNTS:
        valid = await verify_product_purchase(
            PACKAGE_NAME, body.product_id, body.purchase_token
        )
        if not valid:
            raise HTTPException(
                status_code=400,
                detail="Purchase could not be verified with Google Play.",
            )

        amount = CREDIT_AMOUNTS[body.product_id]
        total = await award_credits(uid, amount)
        await record_purchase(uid, body.purchase_token, body.product_id)

        return VerifyResponse(
            success=True,
            credits_awarded=amount,
            total_credits=total,
        )

    # ── Pro subscription ─────────────────────────────────────────────
    if body.product_id == "pro_monthly":
        expires_ms = await verify_subscription(
            PACKAGE_NAME, body.product_id, body.purchase_token
        )
        if expires_ms is None:
            raise HTTPException(
                status_code=400,
                detail="Subscription could not be verified with Google Play.",
            )

        total = await activate_pro(uid, expires_ms)
        await record_purchase(uid, body.purchase_token, body.product_id)

        return VerifyResponse(success=True, is_pro=True, total_credits=total)

    raise HTTPException(
        status_code=400,
        detail=f"Unknown product: {body.product_id}",
    )

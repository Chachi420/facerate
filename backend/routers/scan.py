import time
import uuid
from collections import defaultdict
from datetime import datetime, timezone
from typing import Optional
from fastapi import APIRouter, File, UploadFile, Form, HTTPException, Header
from models.scan_models import ScanResponse
from services import vision_service, firebase_service
from services.firebase_service import deduct_credits, award_credits, get_user, verify_id_token

router = APIRouter()

MAX_IMAGE_SIZE = 10 * 1024 * 1024  # 10MB
_rate_limit_store: dict[str, list[float]] = defaultdict(list)
RATE_LIMIT = 10
RATE_WINDOW = 60


def _compute_what_changed(current_score: float, prev_score: float | None, days_since: int | None) -> str | None:
    if prev_score is None:
        return None
    delta = current_score - prev_score
    if days_since == 0 and delta > 0.3:
        return "Score's up from your last scan today — the lighting is working for you."
    if days_since == 0 and delta < -0.3:
        return "Score dipped from earlier today — try better lighting or a more neutral expression."
    if days_since is not None and days_since >= 7 and delta > 0.5:
        return "Biggest score jump in over a week."
    if delta > 0.8:
        return "That's your highest read in a while — something is clicking."
    if delta > 0.3:
        return "A steady improvement from last time."
    if delta < -0.5:
        return "Score is down today — could be lighting, expression, or just a different angle."
    if abs(delta) <= 0.2:
        return "Essentially the same as last time — your face is consistent."
    return None


@router.post("/api/scan", response_model=ScanResponse)
async def scan_face(
    image: UploadFile = File(...),
    user_id: str = Form(default="guest"),
    mood: str = Form(default="good"),
    mode: str = Form(default="honest"),
    prev_scan_id: str = Form(default=None),
    authorization: Optional[str] = Header(default=None),
):
    # Resolve the caller's uid from the bearer token or fall back to guest.
    # The form-field user_id is NOT trusted for non-guest requests.
    if authorization and authorization.startswith("Bearer "):
        token = authorization[7:]
        try:
            user_id = verify_id_token(token)
        except Exception:
            raise HTTPException(status_code=401, detail="Invalid or expired authentication token.")
    elif user_id != "guest":
        # Non-guest request with no auth token — reject.
        raise HTTPException(status_code=401, detail="Authentication required.")

    now = time.time()
    _rate_limit_store[user_id] = [t for t in _rate_limit_store[user_id] if now - t < RATE_WINDOW]
    if len(_rate_limit_store[user_id]) >= RATE_LIMIT:
        raise HTTPException(status_code=429, detail="Rate limit exceeded. Max 10 scans per minute.")
    _rate_limit_store[user_id].append(now)

    image_bytes = await image.read()
    if len(image_bytes) > MAX_IMAGE_SIZE:
        raise HTTPException(status_code=400, detail="Image too large. Max 10MB allowed.")

    if not image.content_type or not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image.")

    # ── Credit gate ──────────────────────────────────────────────────
    # Guests scan for free. Pro users are unlimited. Everyone else needs 1 credit.
    credit_deducted = False
    if user_id != "guest":
        try:
            user = await get_user(user_id)
            if user and not user.get("isPro", False):
                try:
                    await deduct_credits(user_id, 1)
                    credit_deducted = True
                except ValueError:
                    raise HTTPException(
                        status_code=402,
                        detail="Not enough credits. Visit the shop to get more.",
                    )
        except HTTPException:
            raise
        except Exception:
            # Firestore is unavailable — fail closed for authenticated users
            # rather than granting a free scan.
            raise HTTPException(
                status_code=503,
                detail="Credit verification is temporarily unavailable. Please try again in a moment.",
            )

    try:
        analysis = await vision_service.analyze_face(image_bytes, mode)
    except Exception as e:
        # Refund the credit if AI analysis fails
        if credit_deducted:
            try:
                await award_credits(user_id, 1)
            except Exception:
                pass
        raise HTTPException(status_code=502, detail=f"AI analysis failed: {str(e)}")

    if analysis.get("error") == "no_face":
        pun = analysis.get("pun", "That's not a face! Please use a clear selfie.")
        raise HTTPException(status_code=400, detail={"error_type": "no_face", "message": pun})

    scan_id = str(uuid.uuid4())
    created_at = datetime.now(timezone.utc)
    current_score = analysis.get("score", 0.0)

    # Fetch previous scan for delta + what_changed
    prev_score = None
    what_changed = None
    days_since = None
    try:
        if user_id != "guest":
            prev_scans = await firebase_service.get_recent_scans(user_id, limit=1, exclude_id=prev_scan_id)
            if prev_scans:
                prev = prev_scans[0]
                prev_score = float(prev.get("score", 0))
                prev_date = prev.get("createdAt")
                if prev_date:
                    try:
                        pd = prev_date if isinstance(prev_date, datetime) else prev_date.replace(tzinfo=None)
                        cd = created_at.replace(tzinfo=None)
                        days_since = (cd - pd).days
                    except Exception:
                        days_since = None
                what_changed = _compute_what_changed(current_score, prev_score, days_since)
    except Exception:
        pass  # Non-critical — don't fail the scan

    delta = (current_score - prev_score) if prev_score is not None else None

    scan_data = {
        "scanId": scan_id,
        "score": current_score,
        "percentile": analysis.get("percentile", 50),
        "faceShape": analysis.get("face_shape", "oval"),
        "archetype": analysis.get("archetype", "Bold Classic"),
        "archetypeDescription": analysis.get("archetype_description", ""),
        "features": analysis.get("features", {}),
        "goldenRatioScore": analysis.get("golden_ratio_score", 7.0),
        "skinTone": analysis.get("skin_tone", ""),
        "skinType": analysis.get("skin_type", "normal"),
        "strengths": analysis.get("strengths", []),
        "areasToImprove": analysis.get("areas_to_improve", []),
        "haircutRecommendations": analysis.get("haircut_recommendations", []),
        "beardTips": analysis.get("beard_tips", ""),
        "skincareRoutine": analysis.get("skincare_routine", []),
        "glassesFrames": analysis.get("glasses_frames", []),
        "collarTips": analysis.get("collar_tips", ""),
        "featureTips": analysis.get("feature_tips", {}),
        "celebrityLookalike": analysis.get("celebrity_lookalike", {}),
        "fictionalCharacter": analysis.get("fictional_character", {}),
        "perceivedAge": analysis.get("perceived_age", 25),
        "vibe": analysis.get("vibe", ""),
        "animal": analysis.get("animal", {}),
        "moodLogged": mood,
        "createdAt": created_at,
        "delta": delta,
        "previousScore": prev_score,
        "whatChanged": what_changed,
    }

    try:
        await firebase_service.save_scan_result(user_id, scan_id, scan_data)
        await firebase_service.update_user_stats(user_id, created_at)
    except Exception:
        pass

    animal_raw = analysis.get("animal", {})
    celeb_raw = analysis.get("celebrity_lookalike", {})
    char_raw = analysis.get("fictional_character", {})
    features_raw = analysis.get("features", {})

    return ScanResponse(
        scan_id=scan_id,
        score=current_score,
        percentile=analysis.get("percentile", 50),
        face_shape=analysis.get("face_shape", "oval"),
        archetype=analysis.get("archetype", "Bold Classic"),
        archetype_description=analysis.get("archetype_description", ""),
        features={
            k: {"score": v.get("score", 0.0), "description": v.get("description", "")}
            for k, v in features_raw.items()
        },
        golden_ratio_score=analysis.get("golden_ratio_score", 7.0),
        skin_tone=analysis.get("skin_tone", ""),
        skin_type=analysis.get("skin_type", "normal"),
        strengths=analysis.get("strengths", []),
        areas_to_improve=analysis.get("areas_to_improve", []),
        haircut_recommendations=analysis.get("haircut_recommendations", []),
        beard_tips=analysis.get("beard_tips", ""),
        skincare_routine=analysis.get("skincare_routine", []),
        glasses_frames=analysis.get("glasses_frames", []),
        collar_tips=analysis.get("collar_tips", ""),
        feature_tips=analysis.get("feature_tips", {}),
        celebrity_lookalike={
            "name": celeb_raw.get("name", ""),
            "match_percentage": celeb_raw.get("match_percentage", 70),
            "reason": celeb_raw.get("reason", ""),
        },
        fictional_character={
            "name": char_raw.get("name", ""),
            "franchise": char_raw.get("franchise", ""),
            "match_percentage": char_raw.get("match_percentage", 70),
            "reason": char_raw.get("reason", ""),
        },
        perceived_age=analysis.get("perceived_age", 25),
        vibe=analysis.get("vibe", ""),
        animal={
            "name": animal_raw.get("name", ""),
            "emoji": animal_raw.get("emoji", "🐾"),
            "rarity": animal_raw.get("rarity", "Common"),
            "reason": animal_raw.get("reason", ""),
            "vibe_description": animal_raw.get("vibe_description", ""),
        },
        mood_logged=mood,
        created_at=created_at.isoformat(),
        delta=delta,
        previous_score=prev_score,
        what_changed=what_changed,
    )

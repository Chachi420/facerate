import time
import uuid
from collections import defaultdict
from datetime import datetime, timezone
from fastapi import APIRouter, File, UploadFile, Form, HTTPException
from models.scan_models import ScanResponse
from services import kimi_service, firebase_service

router = APIRouter()

MAX_IMAGE_SIZE = 10 * 1024 * 1024  # 10MB
_rate_limit_store: dict[str, list[float]] = defaultdict(list)
RATE_LIMIT = 10
RATE_WINDOW = 60


@router.post("/api/scan", response_model=ScanResponse)
async def scan_face(
    image: UploadFile = File(...),
    user_id: str = Form(...),
    mood: str = Form(default="good"),
    mode: str = Form(default="honest"),
):
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

    try:
        analysis = await kimi_service.analyze_face(image_bytes, mode)
    except Exception as e:
        raise HTTPException(status_code=502, detail=f"AI analysis failed: {str(e)}")

    if analysis.get("error") == "no_face":
        pun = analysis.get("pun", "That's not a face! Please use a clear selfie.")
        raise HTTPException(status_code=400, detail={"error_type": "no_face", "message": pun})

    scan_id = str(uuid.uuid4())
    created_at = datetime.now(timezone.utc)

    scan_data = {
        "scanId": scan_id,
        "score": analysis.get("score", 0.0),
        "percentile": analysis.get("percentile", 50),
        "faceShape": analysis.get("face_shape", "oval"),
        "archetype": analysis.get("archetype", "Bold Classic"),
        "archetypeDescription": analysis.get("archetype_description", ""),
        "features": analysis.get("features", {}),
        "goldenRatioScore": analysis.get("golden_ratio_score", 7.0),
        "skinTone": analysis.get("skin_tone", ""),
        "strengths": analysis.get("strengths", []),
        "areasToImprove": analysis.get("areas_to_improve", []),
        "haircutRecommendations": analysis.get("haircut_recommendations", []),
        "beardTips": analysis.get("beard_tips", ""),
        "skincareRoutine": analysis.get("skincare_routine", []),
        "glassesFrames": analysis.get("glasses_frames", []),
        "collarTips": analysis.get("collar_tips", ""),
        "celebrityLookalike": analysis.get("celebrity_lookalike", {}),
        "fictionalCharacter": analysis.get("fictional_character", {}),
        "perceivedAge": analysis.get("perceived_age", 25),
        "vibe": analysis.get("vibe", ""),
        "animal": analysis.get("animal", {}),
        "moodLogged": mood,
        "createdAt": created_at,
    }

    try:
        await firebase_service.save_scan_result(user_id, scan_id, scan_data)
        await firebase_service.update_user_stats(user_id, created_at)
    except Exception:
        pass  # Don't fail the scan if Firestore write fails

    animal_raw = analysis.get("animal", {})
    celeb_raw = analysis.get("celebrity_lookalike", {})
    char_raw = analysis.get("fictional_character", {})
    features_raw = analysis.get("features", {})

    return ScanResponse(
        scan_id=scan_id,
        score=analysis.get("score", 0.0),
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
        strengths=analysis.get("strengths", []),
        areas_to_improve=analysis.get("areas_to_improve", []),
        haircut_recommendations=analysis.get("haircut_recommendations", []),
        beard_tips=analysis.get("beard_tips", ""),
        skincare_routine=analysis.get("skincare_routine", []),
        glasses_frames=analysis.get("glasses_frames", []),
        collar_tips=analysis.get("collar_tips", ""),
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
    )

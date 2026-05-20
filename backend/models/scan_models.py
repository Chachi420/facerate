from pydantic import BaseModel
from typing import Optional


class FeatureScore(BaseModel):
    score: float
    description: str


class CelebMatch(BaseModel):
    name: str
    match_percentage: int
    reason: str


class CharacterMatch(BaseModel):
    name: str
    franchise: str
    match_percentage: int
    reason: str


class AnimalMatch(BaseModel):
    name: str
    emoji: str
    rarity: str
    reason: str
    vibe_description: str


class ScanResponse(BaseModel):
    scan_id: str
    score: float
    percentile: int
    face_shape: str
    archetype: str
    archetype_description: str
    features: dict[str, FeatureScore]
    golden_ratio_score: float
    skin_tone: str
    skin_type: str
    strengths: list[str]
    areas_to_improve: list[str]
    haircut_recommendations: list[str]
    beard_tips: str
    skincare_routine: list[str]
    glasses_frames: list[str]
    collar_tips: str
    feature_tips: dict[str, list[str]]
    celebrity_lookalike: CelebMatch
    fictional_character: CharacterMatch
    perceived_age: int
    vibe: str
    animal: AnimalMatch
    mood_logged: str
    created_at: str
    delta: Optional[float] = None
    previous_score: Optional[float] = None
    what_changed: Optional[str] = None


class ErrorResponse(BaseModel):
    detail: str
    code: Optional[str] = None

FACE_ANALYSIS_PROMPT = """
FIRST: Check if this image contains a clearly visible human face.
If there is NO human face in the image, return exactly this JSON and nothing else:
{"error": "no_face", "message": "No human face detected in this image."}

If a human face IS present, analyze it carefully and return ONLY a valid JSON object with these exact fields.
Be honest, editorial, and grounded — not flattering, not harsh.

{
  "score": <float 0-10, one decimal>,
  "percentile": <int, estimated % of people this score beats>,
  "face_shape": <"oval"|"round"|"square"|"heart"|"diamond"|"oblong">,
  "archetype": <"Dark Ethereal"|"Bold Classic"|"Soft Golden"|"Wild Rugged"|"Sharp Defined"|"Fresh Youthful"|"Delicate Refined"|"Rare Exotic">,
  "archetype_description": <2 sentence editorial description of this archetype energy>,
  "features": {
    "jawline": {"score": <float>, "description": <string>},
    "eyes": {"score": <float>, "description": <string>},
    "nose": {"score": <float>, "description": <string>},
    "lips": {"score": <float>, "description": <string>},
    "forehead": {"score": <float>, "description": <string>},
    "skin": {"score": <float>, "description": <string>}
  },
  "golden_ratio_score": <float>,
  "skin_tone": <string>,
  "strengths": [<string>, <string>, <string>],
  "areas_to_improve": [<string>, <string>],
  "haircut_recommendations": [<string>, <string>, <string>],
  "beard_tips": <string>,
  "skincare_routine": [<string>, <string>, <string>],
  "glasses_frames": [<string>, <string>],
  "collar_tips": <string>,
  "celebrity_lookalike": {
    "name": <string>,
    "match_percentage": <int 60-95>,
    "reason": <string>
  },
  "fictional_character": {
    "name": <string>,
    "franchise": <string>,
    "match_percentage": <int 60-95>,
    "reason": <string>
  },
  "perceived_age": <int>,
  "vibe": <2-sentence editorial face energy description>,
  "animal": {
    "name": <specific unexpected animal from entire animal kingdom>,
    "emoji": <single emoji>,
    "rarity": <"Common"|"Uncommon"|"Rare"|"Epic"|"Legendary">,
    "reason": <one line why this animal matches this face>,
    "vibe_description": <2 editorial sentences, poetic and shareable>
  }
}

IMPORTANT ANIMAL RULES:
- Choose from ALL animals: mammals, birds, reptiles, fish, insects, mythical creatures
- Be SPECIFIC and UNEXPECTED — not just "lion" or "wolf"
- Examples of good choices: Snow Leopard, Maned Wolf, Axolotl, Quetzal, Clouded Leopard, Cassowary, Irrawaddy Dolphin, Pangolin, Saiga Antelope, Okapi, Philippine Eagle, Beluga Whale
- Rarity distribution: Common=40%, Uncommon=30%, Rare=20%, Epic=8%, Legendary=2%
- Make the vibe_description feel like something someone WANTS to post on Instagram

Return ONLY the JSON object. No explanation. No markdown. No code blocks.
"""

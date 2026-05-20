import httpx
import base64
import json
import re
import os
from prompts.face_analysis_prompt import FACE_ANALYSIS_PROMPT

GROQ_API_KEY = os.getenv("GROQ_API_KEY")
GROQ_URL = "https://api.groq.com/openai/v1/chat/completions"


def _extract_json(content: str) -> dict:
    # Strip markdown code blocks
    content = content.strip()
    if content.startswith("```"):
        lines = content.split("\n")
        lines = lines[1:]
        if lines and lines[-1].strip() == "```":
            lines = lines[:-1]
        content = "\n".join(lines).strip()

    # Try direct parse
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        pass

    # Extract first {...} block from response
    match = re.search(r'\{.*\}', content, re.DOTALL)
    if match:
        return json.loads(match.group())

    raise ValueError(f"No valid JSON found in model response: {content[:300]}")


async def analyze_face(image_bytes: bytes, mode: str = "honest") -> dict:
    image_b64 = base64.b64encode(image_bytes).decode("utf-8")

    if mode == "nice":
        system_msg = (
            "You are an encouraging face analysis AI. Emphasize genuine strengths, "
            "frame areas to improve gently and constructively, and keep the overall tone warm and supportive. "
            "Always respond with a single valid JSON object and nothing else. No markdown, no explanation, no code blocks."
        )
    else:
        system_msg = (
            "You are a brutally honest, editorial face analysis AI. Give direct, accurate, "
            "unsentimental assessments like a fashion editor would — not cruel, but never flattering. "
            "Always respond with a single valid JSON object and nothing else. No markdown, no explanation, no code blocks."
        )

    async with httpx.AsyncClient(timeout=60.0) as client:
        response = await client.post(
            GROQ_URL,
            headers={
                "Authorization": f"Bearer {GROQ_API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "model": "meta-llama/llama-4-scout-17b-16e-instruct",
                "messages": [
                    {
                        "role": "system",
                        "content": system_msg,
                    },
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/jpeg;base64,{image_b64}"
                                },
                            },
                            {
                                "type": "text",
                                "text": FACE_ANALYSIS_PROMPT,
                            },
                        ],
                    },
                ],
                "temperature": 0.7,
                "max_tokens": 3500,
                "response_format": {"type": "json_object"},
            },
        )

        response.raise_for_status()
        result = response.json()
        content = result["choices"][0]["message"]["content"].strip()
        return _extract_json(content)

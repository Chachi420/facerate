import os
import time
from collections import defaultdict
from contextlib import asynccontextmanager
from dotenv import load_dotenv
from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

from routers import scan, health, credits
from services import firebase_service

# Simple in-memory rate limiter: 10 req/min per user_id
_rate_limit_store: dict[str, list[float]] = defaultdict(list)
RATE_LIMIT = 10
RATE_WINDOW = 60  # seconds


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        firebase_service.init_firebase()
    except Exception as e:
        print(f"WARNING: Firebase init failed: {e}")
    yield


app = FastAPI(title="FaceRate API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    if request.url.path == "/api/scan":
        user_id = None
        try:
            form = await request.form()
            user_id = form.get("user_id")
        except Exception:
            pass

        if user_id:
            now = time.time()
            timestamps = _rate_limit_store[user_id]
            _rate_limit_store[user_id] = [t for t in timestamps if now - t < RATE_WINDOW]
            if len(_rate_limit_store[user_id]) >= RATE_LIMIT:
                from fastapi.responses import JSONResponse
                return JSONResponse(
                    status_code=429,
                    content={"detail": "Rate limit exceeded. Max 10 scans per minute."},
                )
            _rate_limit_store[user_id].append(now)

    return await call_next(request)


app.include_router(scan.router)
app.include_router(health.router)
app.include_router(credits.router)

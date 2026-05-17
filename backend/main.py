import os
from contextlib import asynccontextmanager
from dotenv import load_dotenv
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

from routers import scan, health, credits
from services import firebase_service


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
    return await call_next(request)


app.include_router(scan.router)
app.include_router(health.router)
app.include_router(credits.router)

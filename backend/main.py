from contextlib import asynccontextmanager
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

from routers import scan, health, credits, iap
from services import firebase_service


@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        firebase_service.init_firebase()
    except Exception as e:
        print(f"WARNING: Firebase init failed: {e}")
    yield


app = FastAPI(title="FaceRate API", version="1.0.0", lifespan=lifespan)

# The API authenticates every mutating request with a Firebase Bearer token,
# not cookies, so credentialed CORS is unnecessary. Keeping allow_credentials
# False is also what lets the wildcard origin stay valid per the CORS spec.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(scan.router)
app.include_router(health.router)
app.include_router(credits.router)
app.include_router(iap.router)

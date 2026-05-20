import os
import json
from datetime import datetime, timezone
import firebase_admin
from firebase_admin import credentials, firestore

_db = None


def get_db():
    global _db
    if _db is None:
        raise RuntimeError("Firebase not initialized. Call init_firebase() first.")
    return _db


def init_firebase():
    global _db
    if firebase_admin._apps:
        _db = firestore.client()
        return

    service_account_json = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON")
    if not service_account_json:
        raise ValueError("FIREBASE_SERVICE_ACCOUNT_JSON env var is not set")

    service_account = json.loads(service_account_json)
    cred = credentials.Certificate(service_account)
    firebase_admin.initialize_app(cred)
    _db = firestore.client()


async def save_scan_result(user_id: str, scan_id: str, scan_data: dict) -> None:
    db = get_db()
    scan_ref = db.collection("users").document(user_id).collection("scans").document(scan_id)
    scan_ref.set(scan_data)


async def update_user_stats(user_id: str, scan_date: datetime) -> None:
    db = get_db()
    user_ref = db.collection("users").document(user_id)

    user_doc = user_ref.get()
    if not user_doc.exists:
        user_ref.set(
            {
                "uid": user_id,
                "credits": 0,
                "isPro": False,
                "totalScans": 1,
                "streak": 1,
                "lastScanDate": scan_date,
                "createdAt": scan_date,
                "saveHistory": False,
            }
        )
        return

    user_data = user_doc.to_dict()
    last_scan = user_data.get("lastScanDate")
    streak = user_data.get("streak", 0)

    if last_scan:
        days_diff = (scan_date - last_scan).days if hasattr(last_scan, "days") else 0
        try:
            last_dt = last_scan if isinstance(last_scan, datetime) else last_scan.replace(tzinfo=None)
            scan_dt = scan_date.replace(tzinfo=None) if scan_date.tzinfo else scan_date
            days_diff = (scan_dt - last_dt).days
        except Exception:
            days_diff = 0

        if 1 <= days_diff <= 7:
            streak = streak + 1
        elif days_diff > 7:
            streak = 1

    user_ref.update(
        {
            "totalScans": firestore.Increment(1),
            "lastScanDate": scan_date,
            "streak": streak,
        }
    )


async def get_recent_scans(user_id: str, limit: int = 1, exclude_id: str | None = None) -> list[dict]:
    db = get_db()
    scans_ref = db.collection("users").document(user_id).collection("scans")
    query = scans_ref.order_by("createdAt", direction="DESCENDING").limit(limit + (1 if exclude_id else 0))
    docs = query.stream()
    results = []
    for doc in docs:
        data = doc.to_dict()
        if exclude_id and data.get("scanId") == exclude_id:
            continue
        results.append(data)
        if len(results) >= limit:
            break
    return results


async def get_user(user_id: str) -> dict | None:
    db = get_db()
    doc = db.collection("users").document(user_id).get()
    return doc.to_dict() if doc.exists else None


async def award_credits(user_id: str, amount: int) -> int:
    """Add credits to a user. Returns new total. Creates the user document if missing."""
    db = get_db()
    user_ref = db.collection("users").document(user_id)
    result = {"total": None}

    @firestore.transactional
    def _award(transaction, ref):
        snapshot = ref.get(transaction=transaction)
        if not snapshot.exists:
            transaction.set(ref, {"uid": user_id, "credits": amount, "isPro": False})
            result["total"] = amount
        else:
            current = snapshot.get("credits") or 0
            new_total = current + amount
            transaction.update(ref, {"credits": new_total})
            result["total"] = new_total

    transaction = db.transaction()
    _award(transaction, user_ref)
    return result["total"]


async def activate_pro(user_id: str, expires_at_ms: int) -> int:
    """Set isPro=True on a user. Returns current credit balance."""
    db = get_db()
    user_ref = db.collection("users").document(user_id)
    user_ref.update({"isPro": True, "proExpiresAt": expires_at_ms})
    doc = user_ref.get()
    return (doc.to_dict() or {}).get("credits", 0)


async def is_purchase_processed(user_id: str, purchase_token: str) -> bool:
    """Return True if this purchase token has already been credited (idempotency)."""
    db = get_db()
    doc = (
        db.collection("users")
        .document(user_id)
        .collection("purchases")
        .document(purchase_token)
        .get()
    )
    return doc.exists


async def record_purchase(user_id: str, purchase_token: str, product_id: str) -> None:
    """Store a processed purchase token to prevent double-crediting."""
    db = get_db()
    (
        db.collection("users")
        .document(user_id)
        .collection("purchases")
        .document(purchase_token)
        .set({"productId": product_id, "processedAt": datetime.now(timezone.utc)})
    )


async def deduct_credits(user_id: str, amount: int) -> int:
    """Atomically deduct credits. Returns remaining balance. Raises ValueError if insufficient."""
    db = get_db()
    user_ref = db.collection("users").document(user_id)
    result = {"remaining": None}

    @firestore.transactional
    def _deduct(transaction, ref):
        snapshot = ref.get(transaction=transaction)
        if not snapshot.exists:
            raise ValueError("User not found")
        current = snapshot.get("credits") or 0
        if current < amount:
            raise ValueError("Insufficient credits")
        remaining = current - amount
        transaction.update(ref, {"credits": remaining})
        result["remaining"] = remaining

    transaction = db.transaction()
    _deduct(transaction, user_ref)
    return result["remaining"]

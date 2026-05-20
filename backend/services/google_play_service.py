"""
Google Play Developer API receipt verification.

Setup required (one-time):
1. In Google Play Console → Setup → API access, link your Google Cloud project.
2. Grant the Firebase service account (from FIREBASE_SERVICE_ACCOUNT_JSON) the
   "Release manager" or "Financial data viewer" role in Play Console.
   Alternatively, set GOOGLE_PLAY_VERIFY_DISABLED=true to skip verification
   during development / before Play Console is configured.
"""

import os
import json
from datetime import datetime, timezone

_service = None


def _get_service():
    global _service
    if _service is not None:
        return _service

    # Import lazily — googleapiclient is optional; fail clearly if missing.
    try:
        from google.oauth2 import service_account
        from googleapiclient.discovery import build
    except ImportError:
        raise RuntimeError(
            "google-api-python-client is not installed. "
            "Run: pip install google-api-python-client"
        )

    sa_json = os.getenv("FIREBASE_SERVICE_ACCOUNT_JSON")
    if not sa_json:
        raise RuntimeError("FIREBASE_SERVICE_ACCOUNT_JSON env var is not set")

    creds = service_account.Credentials.from_service_account_info(
        json.loads(sa_json),
        scopes=["https://www.googleapis.com/auth/androidpublisher"],
    )
    _service = build("androidpublisher", "v3", credentials=creds)
    return _service


def _is_disabled() -> bool:
    return os.getenv("GOOGLE_PLAY_VERIFY_DISABLED", "").lower() in ("1", "true", "yes")


async def verify_product_purchase(
    package_name: str, product_id: str, purchase_token: str
) -> bool:
    """
    Returns True if the one-time product purchase is valid (purchased, not cancelled).
    Returns False on any error or invalid state.
    Set GOOGLE_PLAY_VERIFY_DISABLED=true to bypass during development.
    """
    if _is_disabled():
        print(f"[IAP] GOOGLE_PLAY_VERIFY_DISABLED — skipping verification for {product_id}")
        return True

    try:
        service = _get_service()
        result = (
            service.purchases()
            .products()
            .get(
                packageName=package_name,
                productId=product_id,
                token=purchase_token,
            )
            .execute()
        )
        # purchaseState: 0 = purchased, 1 = cancelled
        return result.get("purchaseState", 1) == 0
    except Exception as e:
        print(f"[IAP] Google Play product verification error: {e}")
        return False


async def verify_subscription(
    package_name: str, subscription_id: str, purchase_token: str
) -> int | None:
    """
    Returns expiryTimeMillis (int) if the subscription is active, None otherwise.
    Set GOOGLE_PLAY_VERIFY_DISABLED=true to bypass during development.
    """
    if _is_disabled():
        print(f"[IAP] GOOGLE_PLAY_VERIFY_DISABLED — skipping verification for {subscription_id}")
        # Return a far-future expiry so Pro activates in dev mode
        now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
        return now_ms + (30 * 24 * 60 * 60 * 1000)  # 30 days from now

    try:
        service = _get_service()
        result = (
            service.purchases()
            .subscriptions()
            .get(
                packageName=package_name,
                subscriptionId=subscription_id,
                token=purchase_token,
            )
            .execute()
        )
        expiry_ms = int(result.get("expiryTimeMillis", 0))
        now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
        return expiry_ms if expiry_ms > now_ms else None
    except Exception as e:
        print(f"[IAP] Google Play subscription verification error: {e}")
        return None

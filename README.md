# FaceRate

AI-powered face analysis Android app. Upload a selfie → get an animal archetype, rarity tier, face score, celebrity match, and glow-up plan. Built for virality on Instagram and TikTok.

## Tech Stack

| Layer | Technology |
|---|---|
| Flutter app | Riverpod + Go Router |
| Backend | FastAPI + Python 3.11 |
| AI | Kimi (Moonshot AI) Vision API |
| Auth | Firebase Auth |
| Database | Cloud Firestore |
| Ads | Google AdMob |
| IAP | Google Play Billing |
| Hosting | Google Cloud Run |

## Setup

### Backend

1. Copy `.env.example` to `.env` and fill in your keys:
   ```
   KIMI_API_KEY=sk-...
   FIREBASE_SERVICE_ACCOUNT_JSON={...}
   ```

2. Run locally:
   ```bash
   cd backend
   pip install -r requirements.txt
   uvicorn main:app --reload --port 8000
   ```

3. Deploy to Cloud Run:
   ```bash
   gcloud run deploy facerate-api --source . --region us-central1 --allow-unauthenticated
   ```

### Flutter App

1. Set up Firebase:
   ```bash
   cd app
   flutterfire configure --project=your-firebase-project-id
   ```
   This generates `lib/firebase_options.dart`.

2. Add `google-services.json` to `android/app/`.

3. Update `lib/core/constants/app_constants.dart`:
   - Set `apiBaseUrl` to your Cloud Run URL
   - Replace AdMob IDs with real ones from AdMob console

4. Run:
   ```bash
   flutter pub get
   flutter run
   ```

5. Release build:
   ```bash
   flutter build appbundle --release
   ```

## Environment Variables (Cloud Run)

```
KIMI_API_KEY=sk-...
FIREBASE_SERVICE_ACCOUNT_JSON={...service account JSON...}
```

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /scans/{scanId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```


# Setup Guide
## Backend
```bash
npm i
npm run dev
# Swagger → http://localhost:4000/api/docs
```
Set environment as per `.env.example` (FCM key optional).

## Mobile
```bash
flutter pub get
flutter run --dart-define=API_BASE=http://localhost:4000
```

## Admin (Web)
```bash
flutter pub get
flutter run -d chrome --dart-define=API_BASE=http://localhost:4000
```


# SyncTalk – Elite Engineering Build
Real‑time messaging, group calls, and AI assistance — production‑grade architecture crafted for performance and clarity.

## Repositories
- **Mobile (Flutter):** Telegram‑style chat, WebRTC mesh, AI assist, offline outbox
- **Backend (Node/TS/Express):** JWT (access+refresh), Socket.IO (presence/chat/calls), Zod validation, Swagger, FCM
- **Admin (Flutter Web):** Users, roles, bans, moderation (delete), audit logs

## Fast Start
- Backend: `npm i && npm run dev` → http://localhost:4000/api/docs
- Mobile: `flutter pub get && flutter run --dart-define=API_BASE=http://localhost:4000`
- Admin: `flutter pub get && flutter run -d chrome --dart-define=API_BASE=http://localhost:4000`

## Highlights
- WebRTC **mesh signaling** with Socket.IO
- **AI assist**: suggest reply pipeline
- **Presence + typing + read receipts**
- **FCM push** + tap → opens chat
- **Admin moderation** + **audit logs**

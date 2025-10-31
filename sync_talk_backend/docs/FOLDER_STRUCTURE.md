
# Folder Structure
## Backend
- `src/modules/{auth,users,conversations,messages,ai,audit}`
- `src/core` (middleware, security)
- `src/app.ts` mounts routers; Socket.IO wired in `server.ts`

## Mobile
- `lib/src/features/{auth,home,chat,call,profile,ai}`
- `lib/src/services/{api,session,sockets,push_service,...}`

## Admin
- `lib/src/screens/{login,dashboard,messages_moderation,audit_logs}`
- `lib/src/api.dart` shared Dio instance

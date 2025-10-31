
# API Guide (Summary)
- `POST /api/auth/register` — create account
- `POST /api/auth/login` — returns `{ accessToken, refreshToken, user }`
- `POST /api/auth/refresh` — rotates tokens
- `GET  /api/users` — list/search users
- `POST /api/users/me` — update profile (displayName, avatarUrl)
- `POST /api/users/:id/role` — set role (admin)
- `POST /api/users/:id/ban` / `.../unban` — moderation (admin)
- `GET  /api/conversations` / `POST /api/conversations`
- `GET  /api/messages/:conversationId?cursor&limit`
- `POST /api/messages/:conversationId` — send (text/attachments)
- `POST /api/messages/:id/read` — mark read
- `DELETE /api/messages/:id` — delete (admin)
- `POST /api/ai/suggest` / `POST /api/ai/reply`
- `GET  /api/audit` — list audit entries (admin)

**Swagger**: `/api/docs`.

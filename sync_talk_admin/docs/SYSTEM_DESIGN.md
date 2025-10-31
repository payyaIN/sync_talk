
# System Design
SyncTalk is a low‑latency chat and calling system with clear isolation between API, realtime, and clients.

## Data Flow (Happy Path)
1. Client authenticates → receives **access** + **refresh** tokens.
2. WebSocket connects on `/presence` + `/chat` namespaces.
3. Sending a message → validate (Zod) → persist (Mongo) → emit `message:new` to room.
4. Read receipts → `message:read` event + persistence.
5. FCM push enqueued on new message for offline recipients.
6. Calls: peers join a conversation call; server returns peers; mesh offers/answers/ICE exchanged with targeted emits.

## Scaling Notes
- Horizontal scale behind sticky load balancer (later: Redis adapter for Socket.IO).
- Separate **uploads** from API (CDN later).
- MongoDB with proper TTL indexes for sessions and trimmed audit trail.

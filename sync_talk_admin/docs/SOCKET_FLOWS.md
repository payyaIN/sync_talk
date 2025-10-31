
# Socket Flows
## Presence (`/presence`)
- `online { userId }` / `offline { userId }`

## Chat (`/chat`)
- `room:join { conversationId }`
- `typing { conversationId, userId }`
- `message:new { id, conversationId, sender, content, attachments, createdAt }`
- `message:read { messageId, userId }`

## Calls (`/chat` namespace, conversation room)
- `call:join { conversationId }` → server emits `call:peers { peers: [...] }`
- `call:offer { to, sdp, type }`
- `call:answer { to, sdp, type }`
- `call:ice { to, candidate, sdpMid, sdpMLineIndex }`
- `call:peer-leave { peerId }`

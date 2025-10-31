
# WebRTC Mesh Signaling
Each peer creates a **RTCPeerConnection** per remote peer.
- Join → get `peers[]` → for each, create **offer**.
- Answerers set remote description and create **answer**.
- ICE candidates forwarded via Socket.IO targeted events.
- STUN: `stun:stun.l.google.com:19302` (turn later if needed).

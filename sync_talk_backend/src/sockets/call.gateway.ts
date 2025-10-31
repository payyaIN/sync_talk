
import type { Server, Socket } from 'socket.io';
type RoomPeers = Map<string, Set<string>>; // conversationId -> set of socket ids
const rooms: RoomPeers = new Map();
export function registerCall(io: Server) {
  const nsp = io.of('/chat');
  function peersOf(convId: string) { if (!rooms.has(convId)) rooms.set(convId, new Set()); return rooms.get(convId)!; }
  nsp.on('connection', (socket: Socket) => {
    socket.on('call:join', (data: { conversationId: string }) => {
      const convId = String(data.conversationId);
      socket.join(convId);
      const peers = peersOf(convId);
      for (const pid of peers) { nsp.to(pid).emit('call:peer-join', { conversationId: convId, peerId: socket.id }); }
      nsp.to(socket.id).emit('call:peers', { conversationId: convId, peers: Array.from(peers) });
      peers.add(socket.id);
    });
    socket.on('call:leave', (data: { conversationId: string }) => {
      const convId = String(data.conversationId);
      const peers = peersOf(convId); peers.delete(socket.id); socket.leave(convId);
      nsp.to(convId).emit('call:peer-leave', { conversationId: convId, peerId: socket.id });
    });
    socket.on('disconnect', () => {
      for (const [convId, set] of rooms) { if (set.delete(socket.id)) { nsp.to(convId).emit('call:peer-leave', { conversationId: convId, peerId: socket.id }); } }
    });
    socket.on('call:offer', (data: { conversationId: string, to: string, sdp: string, type: string }) => { nsp.to(data.to).emit('call:offer', { from: socket.id, conversationId: data.conversationId, sdp: data.sdp, type: data.type }); });
    socket.on('call:answer', (data: { conversationId: string, to: string, sdp: string, type: string }) => { nsp.to(data.to).emit('call:answer', { from: socket.id, conversationId: data.conversationId, sdp: data.sdp, type: data.type }); });
    socket.on('call:ice', (data: { conversationId: string, to: string, candidate: string, sdpMid: string, sdpMLineIndex: number }) => { nsp.to(data.to).emit('call:ice', { from: socket.id, conversationId: data.conversationId, candidate: data.candidate, sdpMid: data.sdpMid, sdpMLineIndex: data.sdpMLineIndex }); });
    socket.on('call:end', (data: { conversationId: string }) => { const convId = String(data.conversationId); nsp.to(convId).emit('call:end', { conversationId: convId, from: socket.id }); });
  });
}

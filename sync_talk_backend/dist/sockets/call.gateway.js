"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerCall = registerCall;
const rooms = new Map();
function registerCall(io) {
    const nsp = io.of('/chat');
    function peersOf(convId) { if (!rooms.has(convId))
        rooms.set(convId, new Set()); return rooms.get(convId); }
    nsp.on('connection', (socket) => {
        socket.on('call:join', (data) => {
            const convId = String(data.conversationId);
            socket.join(convId);
            const peers = peersOf(convId);
            for (const pid of peers) {
                nsp.to(pid).emit('call:peer-join', { conversationId: convId, peerId: socket.id });
            }
            nsp.to(socket.id).emit('call:peers', { conversationId: convId, peers: Array.from(peers) });
            peers.add(socket.id);
        });
        socket.on('call:leave', (data) => {
            const convId = String(data.conversationId);
            const peers = peersOf(convId);
            peers.delete(socket.id);
            socket.leave(convId);
            nsp.to(convId).emit('call:peer-leave', { conversationId: convId, peerId: socket.id });
        });
        socket.on('disconnect', () => {
            for (const [convId, set] of rooms) {
                if (set.delete(socket.id)) {
                    nsp.to(convId).emit('call:peer-leave', { conversationId: convId, peerId: socket.id });
                }
            }
        });
        socket.on('call:offer', (data) => { nsp.to(data.to).emit('call:offer', { from: socket.id, conversationId: data.conversationId, sdp: data.sdp, type: data.type }); });
        socket.on('call:answer', (data) => { nsp.to(data.to).emit('call:answer', { from: socket.id, conversationId: data.conversationId, sdp: data.sdp, type: data.type }); });
        socket.on('call:ice', (data) => { nsp.to(data.to).emit('call:ice', { from: socket.id, conversationId: data.conversationId, candidate: data.candidate, sdpMid: data.sdpMid, sdpMLineIndex: data.sdpMLineIndex }); });
        socket.on('call:end', (data) => { const convId = String(data.conversationId); nsp.to(convId).emit('call:end', { conversationId: convId, from: socket.id }); });
    });
}

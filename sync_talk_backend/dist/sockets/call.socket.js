"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerCall = registerCall;
function registerCall(io) {
    const callNamespace = io.of('/call');
    callNamespace.on('connection', (socket) => {
        console.log('Call client connected:', socket.id);
        // Join a specific call room (usually conversationId)
        socket.on('join_call', (roomId) => {
            socket.join(roomId);
            console.log(`Socket ${socket.id} joined call room ${roomId}`);
        });
        // WebRTC Signaling Events
        socket.on('offer', (data) => {
            // data: { roomId, sdp, senderId }
            socket.to(data.roomId).emit('offer', data);
        });
        socket.on('answer', (data) => {
            // data: { roomId, sdp, senderId }
            socket.to(data.roomId).emit('answer', data);
        });
        socket.on('ice_candidate', (data) => {
            // data: { roomId, candidate, senderId }
            socket.to(data.roomId).emit('ice_candidate', data);
        });
        socket.on("disconnect", () => {
            console.log('Call client disconnected:', socket.id);
        });
    });
}

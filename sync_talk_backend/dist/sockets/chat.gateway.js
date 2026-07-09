"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerChat = registerChat;
function registerChat(io) {
    const nsp = io.of('/chat');
    nsp.on('connection', (socket) => {
        socket.on('room:join', (conversationId) => socket.join(conversationId));
        socket.on('typing', (data) => nsp.to(data.conversationId).emit('typing', data));
        socket.on('read', (data) => nsp.to(data.conversationId).emit('read', data));
    });
}

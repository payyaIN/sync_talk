"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerPresence = registerPresence;
const presenceState = new Map(); // userId -> connections
function registerPresence(io) {
    const nsp = io.of('/presence');
    nsp.on('connection', (socket) => {
        const userId = socket.handshake.auth?.userId;
        if (userId) {
            presenceState.set(userId, (presenceState.get(userId) || 0) + 1);
            nsp.emit('online', { userId });
        }
        socket.on('disconnect', () => {
            if (userId) {
                const count = (presenceState.get(userId) || 1) - 1;
                if (count <= 0) {
                    presenceState.delete(userId);
                    nsp.emit('offline', { userId });
                }
                else {
                    presenceState.set(userId, count);
                }
            }
        });
    });
}

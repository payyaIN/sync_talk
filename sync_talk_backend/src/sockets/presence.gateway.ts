
import type { Server } from 'socket.io';
const presenceState = new Map<string, number>(); // userId -> connections
export function registerPresence(io: Server) {
  const nsp = io.of('/presence');
  nsp.on('connection', (socket) => {
    const userId = socket.handshake.auth?.userId as string | undefined;
    if (userId) { presenceState.set(userId, (presenceState.get(userId) || 0) + 1); nsp.emit('online', { userId }); }
    socket.on('disconnect', () => {
      if (userId) {
        const count = (presenceState.get(userId) || 1) - 1;
        if (count <= 0) { presenceState.delete(userId); nsp.emit('offline', { userId }); }
        else { presenceState.set(userId, count); }
      }
    });
  });
}

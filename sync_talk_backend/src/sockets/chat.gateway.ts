
import type { Server, Socket } from 'socket.io';
export function registerChat(io: Server) {
  const nsp = io.of('/chat');
  nsp.on('connection', (socket: Socket) => {
    socket.on('room:join', (conversationId: string) => socket.join(conversationId));
    socket.on('typing', (data) => nsp.to(data.conversationId).emit('typing', data));
    socket.on('read', (data) => nsp.to(data.conversationId).emit('read', data));
  });
}

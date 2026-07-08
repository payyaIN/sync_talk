import { Server, Socket } from 'socket.io';

export function registerCall(io: Server) {
    const callNamespace = io.of('/call');

    callNamespace.on('connection', (socket: Socket) => {
        console.log('Call client connected:', socket.id);

        // Join a specific call room (usually conversationId)
        socket.on('join_call', (roomId: string) => {
            socket.join(roomId);
            console.log(`Socket ${socket.id} joined call room ${roomId}`);
        });

        // WebRTC Signaling Events
        socket.on('offer', (data: any) => {
            // data: { roomId, sdp, senderId }
            socket.to(data.roomId).emit('offer', data);
        });

        socket.on('answer', (data: any) => {
            // data: { roomId, sdp, senderId }
            socket.to(data.roomId).emit('answer', data);
        });

        socket.on('ice_candidate', (data: any) => {
            // data: { roomId, candidate, senderId }
            socket.to(data.roomId).emit('ice_candidate', data);
        });

        socket.on("disconnect", () => {
            console.log('Call client disconnected:', socket.id);
        });
    });
}

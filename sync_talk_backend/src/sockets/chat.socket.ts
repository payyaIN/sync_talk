import { Server, Socket } from 'socket.io';
import { Message } from '../modules/messages/message.model';
import { Conversation } from '../modules/conversations/conversation.model';

export function registerChat(io: Server) {
  const chatNamespace = io.of('/chat');

  chatNamespace.on('connection', (socket: Socket) => {
    console.log('Chat client connected:', socket.id);

    // Join a conversation room
    socket.on("join_room", async (roomId: string) => {
      socket.join(roomId);
      console.log(`Socket ${socket.id} joined room ${roomId}`);
    });

    // Send a message
    socket.on("send_message", async (data: any) => {
      try {
        const { roomId, content, senderId, attachments } = data; // Expecting senderId from client for now, or use middleware to get from token

        // Save to DB
        const newMessage = await Message.create({
          conversation: roomId,
          sender: senderId,
          content: content,
          attachments: attachments || []
        });

        // Update conversation last message
        await Conversation.findByIdAndUpdate(roomId, {
          lastMessage: content,
          lastMessageAt: new Date()
        });

        // Emit to room
        // Populate sender details if needed, for now sending raw
        chatNamespace.to(roomId).emit("receive_message", newMessage);

      } catch (error) {
        console.error("Error sending message:", error);
        socket.emit("error", { message: "Failed to send message" });
      }
    });

    socket.on("disconnect", () => {
      console.log('Chat client disconnected:', socket.id);
    });
  });
}
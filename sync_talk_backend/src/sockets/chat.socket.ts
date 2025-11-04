// import { Message } from "../modules/messages/message.model";
// import { Conversation } from "../modules/conversations/conversation.model";

// // inside io.on("connection", (socket) => { ... })
// socket.on("join_room", async (roomId: string) => {
//   socket.join(roomId);
// });

// socket.on("send_message", async ({ roomId, message, forwardOf }: { roomId: string; message?: string; forwardOf?: string }) => {
//   const saved = await Message.create({
//     conversationId: roomId,
//     sender: socket.data.userId,
//     message: message || "",
//     forwardOf: forwardOf || null,
//     status: "sent",
//   });

//   // broadcast to room
//   io.to(roomId).emit("receive_message", saved);

//   // mark delivered as soon as it’s emitted
//   saved.status = "delivered";
//   await saved.save();
//   io.to(roomId).emit("message_status_update", { messageId: saved._id, status: "delivered", roomId });
// });

// // when user opens a chat, client emits seen
// socket.on("seen_messages", async (roomId: string) => {
//   // optional: don't mark your own messages as seen
//   await Message.updateMany(
//     { conversationId: roomId, status: { $ne: "seen" }, sender: { $ne: socket.data.userId } },
//     { $set: { status: "seen" } }
//   );

//   // also update readBy list
//   await Message.updateMany(
//     { conversationId: roomId, readBy: { $ne: socket.data.userId } },
//     { $push: { readBy: socket.data.userId } }
//   );

//   io.to(roomId).emit("messages_seen", { roomId });
// });

// src/sockets/chat.socket.ts
import { Server, Socket } from 'socket.io';

export function registerChat(io: Server) {
  const chatNamespace = io.of('/chat');
  
  chatNamespace.on('connection', (socket: Socket) => {
    console.log('Chat client connected:', socket.id);

    socket.on("join_room", async (roomId: string) => {
      socket.join(roomId);
      console.log(`Socket ${socket.id} joined room ${roomId}`);
    });

    socket.on("send_message", async (data: any) => {
      const { roomId, message } = data;
      chatNamespace.to(roomId).emit("receive_message", message);
    });

    socket.on("disconnect", () => {
      console.log('Chat client disconnected:', socket.id);
    });
  });
}
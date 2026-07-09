"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerChat = registerChat;
const message_model_1 = require("../modules/messages/message.model");
const conversation_model_1 = require("../modules/conversations/conversation.model");
function registerChat(io) {
    const chatNamespace = io.of('/chat');
    chatNamespace.on('connection', (socket) => {
        console.log('Chat client connected:', socket.id);
        // Join a conversation room
        socket.on("join_room", async (roomId) => {
            socket.join(roomId);
            console.log(`Socket ${socket.id} joined room ${roomId}`);
        });
        // Send a message
        socket.on("send_message", async (data) => {
            try {
                const { roomId, content, senderId, attachments } = data; // Expecting senderId from client for now, or use middleware to get from token
                // Save to DB
                const newMessage = await message_model_1.Message.create({
                    conversation: roomId,
                    sender: senderId,
                    content: content,
                    attachments: attachments || []
                });
                // Update conversation last message
                await conversation_model_1.Conversation.findByIdAndUpdate(roomId, {
                    lastMessage: content,
                    lastMessageAt: new Date()
                });
                // Emit to room
                // Populate sender details if needed, for now sending raw
                chatNamespace.to(roomId).emit("receive_message", newMessage);
            }
            catch (error) {
                console.error("Error sending message:", error);
                socket.emit("error", { message: "Failed to send message" });
            }
        });
        socket.on("disconnect", () => {
            console.log('Chat client disconnected:', socket.id);
        });
    });
}

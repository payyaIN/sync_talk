"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listMyChats = exports.createPrivateChat = void 0;
const conversation_model_1 = require("./conversation.model");
const response_1 = require("../../utils/response");
// Create/Get private conversation
const createPrivateChat = async (req, res) => {
    try {
        const { userId } = req.body; // person to talk to
        if (!userId)
            return (0, response_1.fail)(res, "User ID required");
        // Check if chat already exists
        let chat = await conversation_model_1.Conversation.findOne({
            isGroup: false,
            participants: { $all: [req.user.userId, userId] },
        });
        if (!chat) {
            chat = await conversation_model_1.Conversation.create({
                participants: [req.user.userId, userId],
            });
        }
        return (0, response_1.success)(res, "Chat ready", chat);
    }
    catch (error) {
        return (0, response_1.fail)(res, "Chat creation failed", 500);
    }
};
exports.createPrivateChat = createPrivateChat;
// List my chats
const listMyChats = async (req, res) => {
    try {
        const chats = await conversation_model_1.Conversation.find({
            participants: req.user.userId,
        })
            .populate("participants", "name email avatar")
            .sort({ updatedAt: -1 });
        return (0, response_1.success)(res, "Chats fetched", chats);
    }
    catch (error) {
        return (0, response_1.fail)(res, "Failed to load chats", 500);
    }
};
exports.listMyChats = listMyChats;

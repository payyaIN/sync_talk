"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.postMessage = exports.getMessages = void 0;
const message_model_1 = require("./message.model");
const conversation_model_1 = require("../conversations/conversation.model");
// import { successResponse, errorResponse } from "../../utils/response";
const response_1 = require("../../utils/response");
// Guard: ensure user is a participant
const ensureParticipant = async (userId, conversationId) => {
    const c = await conversation_model_1.Conversation.findById(conversationId).select("participants");
    if (!c)
        return false;
    return c.participants.some(p => p.toString() === userId);
};
// GET /messages/:conversationId?page=1&limit=30
const getMessages = async (req, res) => {
    const { conversationId } = req.params;
    const page = Number(req.query.page ?? 1);
    const limit = Number(req.query.limit ?? 30);
    const skip = (page - 1) * limit;
    const ok = await ensureParticipant(req.user.userId, conversationId);
    if (!ok)
        return (0, response_1.fail)(res, "Forbidden", 403);
    const list = await message_model_1.Message
        .find({ conversationId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate("sender", "name email avatar");
    return (0, response_1.success)(res, "Messages fetched", list.reverse());
};
exports.getMessages = getMessages;
// POST /messages  { conversationId, message }
const postMessage = async (req, res) => {
    const { conversationId, message } = req.body;
    if (!conversationId || !message)
        return (0, response_1.fail)(res, "Missing fields", 400);
    const ok = await ensureParticipant(req.user.userId, conversationId);
    if (!ok)
        return (0, response_1.fail)(res, "Forbidden", 403);
    const saved = await message_model_1.Message.create({
        conversationId,
        sender: req.user.userId,
        message
    });
    await conversation_model_1.Conversation.findByIdAndUpdate(conversationId, { lastMessageAt: new Date() });
    // Socket broadcast will also happen; HTTP returns saved message
    return (0, response_1.success)(res, "Message sent", await saved.populate("sender", "name email avatar"));
};
exports.postMessage = postMessage;

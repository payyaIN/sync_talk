"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.messagesRouter = void 0;
const express_1 = require("express");
const auth_js_1 = require("../../middleware/auth.js");
const zod_1 = require("zod");
const message_model_js_1 = require("./message.model.js");
const conversation_model_js_1 = require("../conversations/conversation.model.js");
const fcm_1 = require("../../utils/fcm");
const audit_model_js_1 = require("../audit/audit.model.js");
exports.messagesRouter = (0, express_1.Router)();
exports.messagesRouter.get('/:conversationId', auth_js_1.requireAuth, async (req, res) => {
    const convId = req.params.conversationId;
    const cursor = req.query.cursor ? new Date(String(req.query.cursor)) : null;
    const limit = Math.min(Number(req.query.limit || 50), 100);
    const filter = { conversation: convId, parentMessage: { $exists: false } };
    if (cursor)
        filter.createdAt = { $lt: cursor };
    const messages = await message_model_js_1.Message.find(filter).sort({ createdAt: -1 }).limit(limit);
    const items = messages.map(m => ({ id: m._id.toString(), sender: m.sender, content: m.content, attachments: m.attachments, readBy: m.readBy, createdAt: m.createdAt }));
    const nextCursor = messages.length ? messages[messages.length - 1].createdAt.toISOString() : null;
    res.json({ items: items.reverse(), nextCursor });
});
const sendSchema = zod_1.z.object({ content: zod_1.z.string().default(''), attachments: zod_1.z.array(zod_1.z.string()).default([]), parentMessage: zod_1.z.string().optional() });
exports.messagesRouter.post('/:conversationId', auth_js_1.requireAuth, async (req, res) => {
    const convId = req.params.conversationId;
    const conv = await conversation_model_js_1.Conversation.findById(convId);
    if (!conv)
        return res.status(404).json({ error: 'Conversation not found' });
    if (!conv.participants.map(String).includes(req.user.sub))
        return res.status(403).json({ error: 'Forbidden' });
    const parsed = sendSchema.safeParse(req.body);
    if (!parsed.success)
        return res.status(400).json(parsed.error);
    const msg = await message_model_js_1.Message.create({ conversation: convId, sender: req.user.sub, ...parsed.data });
    conv.lastMessageAt = new Date();
    await conv.save();
    const io = req.app.get('io');
    io?.of('/chat').to(convId).emit('message:new', { conversationId: convId, id: msg._id.toString(), sender: msg.sender, content: msg.content, attachments: msg.attachments, createdAt: msg.createdAt });
    const tokens = global.__deviceTokens;
    if (tokens && process.env.FCM_SERVER_KEY) {
        for (const p of conv.participants.map(String)) {
            const token = tokens.get(p);
            if (token && p != String(req.user.sub)) {
                await (0, fcm_1.sendFcm)(process.env.FCM_SERVER_KEY, token, 'New message', String(parsed.data.content || 'Attachment'));
            }
        }
    }
    res.status(201).json({ id: msg._id.toString() });
});
exports.messagesRouter.post('/:id/read', auth_js_1.requireAuth, async (req, res) => {
    const id = req.params.id;
    const msg = await message_model_js_1.Message.findById(id);
    if (!msg)
        return res.status(404).json({ error: 'Message not found' });
    if (!msg.readBy.map(String).includes(req.user.sub)) {
        msg.readBy.push(req.user.sub);
        await msg.save();
        const io = req.app.get('io');
        io?.of('/chat').to(String(msg.conversation)).emit('message:read', { conversationId: String(msg.conversation), messageId: id, userId: req.user.sub });
    }
    res.json({ ok: true });
});
exports.messagesRouter.delete('/:id', auth_js_1.requireAuth, async (req, res) => {
    const id = req.params.id;
    const m = await message_model_js_1.Message.findByIdAndDelete(id);
    if (!m)
        return res.status(404).json({ error: 'Message not found' });
    const io = req.app.get('io');
    io?.of('/chat').to(String(m.conversation)).emit('message:deleted', { messageId: id });
    await audit_model_js_1.Audit.create({ actor: req.user.sub, action: 'deleteMessage', target: id, meta: { conversation: String(m.conversation) } });
    res.json({ ok: true });
});
/** Search messages (simple text match), filters by conversations user participates in */
exports.messagesRouter.get('/search', auth_js_1.requireAuth, async (req, res) => {
    const q = String(req.query.q || '').trim();
    if (!q)
        return res.json({ items: [] });
    // Find conversations for user, then match messages
    const convIds = (await Promise.resolve().then(() => __importStar(require('../conversations/conversation.model.js')))).Conversation
        .find({ participants: req.user.sub }).distinct('_id');
    const list = await message_model_js_1.Message.find({ conversation: { $in: await convIds }, content: { $regex: q, $options: 'i' } })
        .sort({ createdAt: -1 }).limit(50);
    res.json({ items: list.map(m => ({ id: m._id.toString(),
            conversation: m.conversation,
            sender: m.sender, content: m.content, createdAt: m.createdAt })) });
});

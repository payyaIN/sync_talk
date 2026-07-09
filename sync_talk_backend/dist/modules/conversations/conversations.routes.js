"use strict";
// import { Router } from "express";
// import { authMiddleware } from "../../middleware/auth.middleware";
// import { createPrivateChat, listMyChats } from "./conversation.controller";
Object.defineProperty(exports, "__esModule", { value: true });
exports.conversationsRouter = void 0;
// const router = Router();
// router.post("/private", authMiddleware, createPrivateChat);
// router.get("/", authMiddleware, listMyChats);
// export default router;
const express_1 = require("express");
const auth_js_1 = require("../../middleware/auth.js");
const zod_1 = require("zod");
const conversation_model_js_1 = require("./conversation.model.js");
exports.conversationsRouter = (0, express_1.Router)();
exports.conversationsRouter.get('/', auth_js_1.requireAuth, async (req, res) => {
    const list = await conversation_model_js_1.Conversation.find({ participants: req.user.sub })
        .populate('participants', 'displayName email avatarUrl')
        .sort({ updatedAt: -1 })
        .limit(100);
    res.json(list.map(c => ({
        id: c._id.toString(),
        participants: c.participants.map((p) => ({
            _id: p._id.toString(),
            displayName: p.displayName,
            email: p.email,
            avatarUrl: p.avatarUrl
        })),
        title: c.title,
        isGroup: c.isGroup,
        updatedAt: c.updatedAt,
        lastMessageAt: c.lastMessageAt
    })));
});
const createSchema = zod_1.z.object({ participants: zod_1.z.array(zod_1.z.string()).min(1), title: zod_1.z.string().optional(), isGroup: zod_1.z.boolean().optional() });
exports.conversationsRouter.post('/', auth_js_1.requireAuth, async (req, res) => {
    const parsed = createSchema.safeParse(req.body);
    if (!parsed.success)
        return res.status(400).json(parsed.error);
    const { participants, title, isGroup } = parsed.data;
    const unique = Array.from(new Set([...participants, req.user.sub]));
    const conv = await conversation_model_js_1.Conversation.create({ participants: unique, title, isGroup: !!isGroup });
    res.status(201).json({ id: conv._id.toString(), participants: conv.participants, title: conv.title, isGroup: conv.isGroup });
});
exports.conversationsRouter.get('/:id', auth_js_1.requireAuth, async (req, res) => {
    try {
        const conv = await conversation_model_js_1.Conversation.findOne({
            _id: req.params.id,
            participants: req.user.sub
        }).populate('participants', 'displayName email avatarUrl role');
        if (!conv)
            return res.status(404).json({ error: 'Conversation not found' });
        res.json({
            success: true,
            data: {
                id: conv._id.toString(),
                participants: conv.participants.map((p) => ({
                    _id: p._id.toString(),
                    displayName: p.displayName,
                    email: p.email,
                    avatarUrl: p.avatarUrl,
                    role: p.role
                })),
                title: conv.title,
                groupName: conv.groupName,
                isGroup: conv.isGroup,
                updatedAt: conv.updatedAt,
                lastMessageAt: conv.lastMessageAt
            }
        });
    }
    catch (error) {
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

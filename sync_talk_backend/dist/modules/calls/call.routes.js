"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.callsRouter = void 0;
const express_1 = require("express");
const auth_js_1 = require("../../middleware/auth.js");
const call_model_js_1 = require("./call.model.js");
exports.callsRouter = (0, express_1.Router)();
// Create call log entry
exports.callsRouter.post('/', auth_js_1.requireAuth, async (req, res) => {
    try {
        const userId = req.user._id;
        const { receiverId, isVideo, isMissed, duration } = req.body;
        if (!receiverId) {
            return res.status(400).json({ error: 'receiverId is required' });
        }
        const log = await call_model_js_1.Call.create({
            caller: userId,
            receiver: receiverId,
            isVideo: isVideo ?? false,
            isMissed: isMissed ?? false,
            duration
        });
        const populated = await call_model_js_1.Call.findById(log._id)
            .populate('caller', 'displayName email avatarUrl')
            .populate('receiver', 'displayName email avatarUrl');
        res.status(201).json(populated);
    }
    catch (e) {
        res.status(500).json({ error: e.message });
    }
});
// Get call history logs
exports.callsRouter.get('/', auth_js_1.requireAuth, async (req, res) => {
    try {
        const userId = req.user._id;
        const logs = await call_model_js_1.Call.find({
            $or: [{ caller: userId }, { receiver: userId }]
        })
            .populate('caller', 'displayName email avatarUrl')
            .populate('receiver', 'displayName email avatarUrl')
            .sort({ createdAt: -1 });
        res.json(logs);
    }
    catch (e) {
        res.status(500).json({ error: e.message });
    }
});

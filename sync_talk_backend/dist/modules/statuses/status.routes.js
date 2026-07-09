"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.statusRouter = void 0;
const express_1 = require("express");
const auth_js_1 = require("../../middleware/auth.js");
const status_model_js_1 = require("./status.model.js");
exports.statusRouter = (0, express_1.Router)();
// Create status
exports.statusRouter.post('/', auth_js_1.requireAuth, async (req, res) => {
    try {
        const userId = req.user._id;
        const { mediaUrl, caption } = req.body;
        if (!mediaUrl) {
            return res.status(400).json({ error: 'mediaUrl is required' });
        }
        const status = await status_model_js_1.Status.create({
            user: userId,
            mediaUrl,
            caption
        });
        const populated = await status_model_js_1.Status.findById(status._id).populate('user', 'displayName email avatarUrl');
        res.status(201).json(populated);
    }
    catch (e) {
        res.status(500).json({ error: e.message });
    }
});
// Get active statuses
exports.statusRouter.get('/', auth_js_1.requireAuth, async (req, res) => {
    try {
        const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000);
        const statuses = await status_model_js_1.Status.find({ createdAt: { $gte: cutoff } })
            .populate('user', 'displayName email avatarUrl')
            .sort({ createdAt: -1 });
        res.json(statuses);
    }
    catch (e) {
        res.status(500).json({ error: e.message });
    }
});

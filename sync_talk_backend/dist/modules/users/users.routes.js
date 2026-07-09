"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.usersRouter = void 0;
const express_1 = require("express");
const auth_js_1 = require("../../middleware/auth.js");
const user_model_js_1 = require("./user.model.js");
const audit_model_js_1 = require("../audit/audit.model.js");
exports.usersRouter = (0, express_1.Router)();
exports.usersRouter.get('/me', auth_js_1.requireAuth, async (req, res) => {
    const me = await user_model_js_1.User.findById(req.user.sub);
    if (!me)
        return res.status(404).json({ error: 'Not found' });
    res.json({ id: me._id.toString(), email: me.email, displayName: me.displayName, role: me.role, avatarUrl: me.avatarUrl });
});
exports.usersRouter.get('/search', auth_js_1.requireAuth, async (req, res) => {
    const q = (req.query.q || '').trim();
    if (!q)
        return res.json([]);
    const users = await user_model_js_1.User.find({ displayName: { $regex: q, $options: 'i' } }).limit(10);
    res.json(users.map(u => ({ id: u._id.toString(), displayName: u.displayName, email: u.email, avatarUrl: u.avatarUrl })));
});
exports.usersRouter.get('/', auth_js_1.requireAuth, auth_js_1.requireAdmin, async (_req, res) => {
    const users = await user_model_js_1.User.find().sort({ createdAt: -1 }).limit(200);
    res.json(users.map(u => ({ id: u._id.toString(), email: u.email, displayName: u.displayName, role: u.role, banned: u.banned })));
});
exports.usersRouter.post('/:id/ban', auth_js_1.requireAuth, auth_js_1.requireAdmin, async (req, res) => { await user_model_js_1.User.findByIdAndUpdate(req.params.id, { banned: true }); await audit_model_js_1.Audit.create({ actor: req.user.sub, action: 'ban', target: req.params.id }); res.json({ ok: true }); });
exports.usersRouter.post('/:id/unban', auth_js_1.requireAuth, auth_js_1.requireAdmin, async (req, res) => { await user_model_js_1.User.findByIdAndUpdate(req.params.id, { banned: false }); await audit_model_js_1.Audit.create({ actor: req.user.sub, action: 'unban', target: req.params.id }); res.json({ ok: true }); });
exports.usersRouter.post('/:id/role', auth_js_1.requireAuth, auth_js_1.requireAdmin, async (req, res) => { const role = req.body?.role || 'user'; await user_model_js_1.User.findByIdAndUpdate(req.params.id, { role }); await audit_model_js_1.Audit.create({ actor: req.user.sub, action: 'setRole', target: req.params.id, meta: { role } }); res.json({ ok: true }); });
/** Device token register for FCM */
exports.usersRouter.post('/device', auth_js_1.requireAuth, async (req, res) => {
    const token = req.body?.token || '';
    if (!token)
        return res.status(400).json({ error: 'token required' });
    global.__deviceTokens = global.__deviceTokens || new Map();
    global.__deviceTokens.set(req.user.sub, token);
    res.json({ ok: true });
});
/** Update my profile (displayName, avatarUrl) */
exports.usersRouter.post('/me', auth_js_1.requireAuth, async (req, res) => {
    const displayName = req.body?.displayName;
    const avatarUrl = req.body?.avatarUrl;
    const update = {};
    if (displayName)
        update.displayName = displayName;
    if (avatarUrl !== undefined)
        update.avatarUrl = avatarUrl;
    await user_model_js_1.User.findByIdAndUpdate(req.user.sub, update);
    res.json({ ok: true });
});

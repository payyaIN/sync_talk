"use strict";
// import { Router } from "express";
// import { register, login, getProfile } from "./auth.controller";
// import { authLimiter } from "../../middleware/rate.middleware";
// import { authMiddleware } from "../../middleware/auth.middleware";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.authRouter = void 0;
// const router = Router();
// router.post("/register", authLimiter, register);
// router.post("/login", authLimiter, login);
// router.get("/me", authMiddleware, getProfile);
// export default router;
const express_1 = require("express");
const zod_1 = require("zod");
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const user_model_js_1 = require("../users/user.model.js");
const refreshToken_model_js_1 = require("./refreshToken.model.js");
const jwt_js_1 = require("./jwt.js");
const env_js_1 = require("../../config/env.js");
const google_auth_library_1 = require("google-auth-library");
exports.authRouter = (0, express_1.Router)();
const googleClientId = env_js_1.config.googleClientId;
const googleClient = googleClientId ? new google_auth_library_1.OAuth2Client(googleClientId) : null;
const registerSchema = zod_1.z.object({ email: zod_1.z.string().email(), password: zod_1.z.string().min(6), displayName: zod_1.z.string().min(1) });
exports.authRouter.post('/register', async (req, res) => {
    const parsed = registerSchema.safeParse(req.body);
    if (!parsed.success)
        return res.status(400).json(parsed.error);
    const { email, password, displayName } = parsed.data;
    const exists = await user_model_js_1.User.findOne({ email });
    if (exists)
        return res.status(409).json({ error: 'Email already in use' });
    const passwordHash = await bcryptjs_1.default.hash(password, 10);
    const user = await user_model_js_1.User.create({ email, passwordHash, displayName });
    res.status(201).json({ id: user._id.toString(), email: user.email, displayName: user.displayName });
});
const loginSchema = zod_1.z.object({ email: zod_1.z.string().email(), password: zod_1.z.string().min(6) });
exports.authRouter.post('/login', async (req, res) => {
    const parsed = loginSchema.safeParse(req.body);
    if (!parsed.success)
        return res.status(400).json(parsed.error);
    const { email, password } = parsed.data;
    const user = await user_model_js_1.User.findOne({ email });
    if (!user || !user.passwordHash)
        return res.status(401).json({ error: 'Invalid credentials' });
    if (user.banned)
        return res.status(403).json({ error: 'User banned' });
    const ok = await bcryptjs_1.default.compare(password, user.passwordHash);
    if (!ok)
        return res.status(401).json({ error: 'Invalid credentials' });
    const accessToken = (0, jwt_js_1.signAccess)({ sub: user._id.toString(), email: user.email, role: user.role });
    const refreshToken = (0, jwt_js_1.signRefresh)({ sub: user._id.toString() });
    const expiresSec = parseInt(String(process.env.REFRESH_EXPIRES_IN || '2592000s').replace('s', '')) || 2592000;
    const expiresAt = new Date(Date.now() + expiresSec * 1000);
    await refreshToken_model_js_1.RefreshToken.create({ user: user._id, token: refreshToken, expiresAt });
    res.json({ accessToken, refreshToken, user: { id: user._id.toString(), email: user.email, displayName: user.displayName, role: user.role } });
});
const googleSchema = zod_1.z.object({ idToken: zod_1.z.string().min(10) });
exports.authRouter.post('/google', async (req, res) => {
    if (!googleClient)
        return res.status(400).json({ error: 'Google Sign-In not configured' });
    const parsed = googleSchema.safeParse(req.body);
    if (!parsed.success)
        return res.status(400).json(parsed.error);
    try {
        const ticket = await googleClient.verifyIdToken({ idToken: parsed.data.idToken, audience: googleClientId });
        const payload = ticket.getPayload();
        if (!payload?.email)
            return res.status(400).json({ error: 'Invalid Google token' });
        let user = await user_model_js_1.User.findOne({ email: payload.email });
        if (!user)
            user = await user_model_js_1.User.create({ email: payload.email, displayName: payload.name || payload.email.split('@')[0], avatarUrl: payload.picture });
        if (user.banned)
            return res.status(403).json({ error: 'User banned' });
        const accessToken = (0, jwt_js_1.signAccess)({ sub: user._id.toString(), email: user.email, role: user.role });
        const refreshToken = (0, jwt_js_1.signRefresh)({ sub: user._id.toString() });
        const expiresSec = parseInt(String(process.env.REFRESH_EXPIRES_IN || '2592000s').replace('s', '')) || 2592000;
        const expiresAt = new Date(Date.now() + expiresSec * 1000);
        await refreshToken_model_js_1.RefreshToken.create({ user: user._id, token: refreshToken, expiresAt });
        res.json({ accessToken, refreshToken, user: { id: user._id.toString(), email: user.email, displayName: user.displayName, role: user.role, avatarUrl: user.avatarUrl } });
    }
    catch (e) {
        res.status(401).json({ error: 'Google verification failed' });
    }
});
const refreshSchema = zod_1.z.object({ refreshToken: zod_1.z.string().min(1) });
exports.authRouter.post('/refresh', async (req, res) => {
    const parsed = refreshSchema.safeParse(req.body);
    if (!parsed.success)
        return res.status(400).json(parsed.error);
    const { refreshToken } = parsed.data;
    const found = await refreshToken_model_js_1.RefreshToken.findOne({ token: refreshToken });
    if (!found)
        return res.status(401).json({ error: 'Invalid refresh token' });
    try {
        const decoded = (0, jwt_js_1.verifyRefresh)(refreshToken);
        await refreshToken_model_js_1.RefreshToken.deleteOne({ token: refreshToken });
        const newRefresh = (0, jwt_js_1.signRefresh)({ sub: decoded.sub });
        const expiresSec = parseInt(String(process.env.REFRESH_EXPIRES_IN || '2592000s').replace('s', '')) || 2592000;
        const expiresAt = new Date(Date.now() + expiresSec * 1000);
        await refreshToken_model_js_1.RefreshToken.create({ user: decoded.sub, token: newRefresh, expiresAt });
        const accessToken = (0, jwt_js_1.signAccess)({ sub: decoded.sub });
        res.json({ accessToken, refreshToken: newRefresh });
    }
    catch {
        return res.status(401).json({ error: 'Expired refresh token' });
    }
});
exports.authRouter.post('/logout', async (req, res) => { const token = req.body?.refreshToken; if (token)
    await refreshToken_model_js_1.RefreshToken.deleteOne({ token }); res.json({ ok: true }); });

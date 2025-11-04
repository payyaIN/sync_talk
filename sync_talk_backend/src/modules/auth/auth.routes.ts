// import { Router } from "express";
// import { register, login, getProfile } from "./auth.controller";
// import { authLimiter } from "../../middleware/rate.middleware";
// import { authMiddleware } from "../../middleware/auth.middleware";

// const router = Router();

// router.post("/register", authLimiter, register);
// router.post("/login", authLimiter, login);
// router.get("/me", authMiddleware, getProfile);

// export default router;



import { Router } from 'express';
import { z } from 'zod';
import bcrypt from 'bcryptjs';
import { User } from '../users/user.model.js';
import { RefreshToken } from './refreshToken.model.js';
import { signAccess, signRefresh, verifyRefresh } from './jwt.js';
import { config } from '../../config/env.js';
import { OAuth2Client } from 'google-auth-library';
import { Types } from 'mongoose';

export const authRouter = Router();
const googleClientId = config.googleClientId;
const googleClient = googleClientId ? new OAuth2Client(googleClientId) : null;

const registerSchema = z.object({ email: z.string().email(), password: z.string().min(6), displayName: z.string().min(1) });
authRouter.post('/register', async (req, res) => {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json(parsed.error);
  const { email, password, displayName } = parsed.data;
  const exists = await User.findOne({ email });
  if (exists) return res.status(409).json({ error: 'Email already in use' });
  const passwordHash = await bcrypt.hash(password, 10);
  const user = await User.create({ email, passwordHash, displayName });
  res.status(201).json({  id: (user._id as Types.ObjectId).toString(), email: user.email, displayName: user.displayName });
});

const loginSchema = z.object({ email: z.string().email(), password: z.string().min(6) });
authRouter.post('/login', async (req, res) => {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json(parsed.error);
  const { email, password } = parsed.data;
  const user = await User.findOne({ email });
  if (!user || !user.passwordHash) return res.status(401).json({ error: 'Invalid credentials' });
  if (user.banned) return res.status(403).json({ error: 'User banned' });
  const ok = await bcrypt.compare(password, user.passwordHash);
  if (!ok) return res.status(401).json({ error: 'Invalid credentials' });
  const accessToken = signAccess({ sub: (user._id as Types.ObjectId).toString(), email: user.email, role: user.role });
  const refreshToken = signRefresh({ sub: (user._id as Types.ObjectId).toString() });
  const expiresSec = parseInt(String(process.env.REFRESH_EXPIRES_IN || '2592000s').replace('s','')) || 2592000;
  const expiresAt = new Date(Date.now() + expiresSec * 1000);
  await RefreshToken.create({ user: user._id, token: refreshToken, expiresAt });
  res.json({ accessToken, refreshToken, user: { id: (user._id as Types.ObjectId).toString(), email: user.email, displayName: user.displayName, role: user.role } });
});

const googleSchema = z.object({ idToken: z.string().min(10) });
authRouter.post('/google', async (req, res) => {
  if (!googleClient) return res.status(400).json({ error: 'Google Sign-In not configured' });
  const parsed = googleSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json(parsed.error);
  try {
    const ticket = await googleClient.verifyIdToken({ idToken: parsed.data.idToken, audience: googleClientId });
    const payload = ticket.getPayload();
    if (!payload?.email) return res.status(400).json({ error: 'Invalid Google token' });
    let user = await User.findOne({ email: payload.email });
    if (!user) user = await User.create({ email: payload.email, displayName: payload.name || payload.email.split('@')[0], avatarUrl: payload.picture });
    if (user.banned) return res.status(403).json({ error: 'User banned' });
    const accessToken = signAccess({ sub: (user._id as Types.ObjectId).toString(), email: user.email, role: user.role });
    const refreshToken = signRefresh({ sub: (user._id as Types.ObjectId).toString() });
    const expiresSec = parseInt(String(process.env.REFRESH_EXPIRES_IN || '2592000s').replace('s','')) || 2592000;
    const expiresAt = new Date(Date.now() + expiresSec * 1000);
    await RefreshToken.create({ user: user._id, token: refreshToken, expiresAt });
    res.json({ accessToken, refreshToken, user: { id: (user._id as Types.ObjectId).toString(), email: user.email, displayName: user.displayName, role: user.role, avatarUrl: user.avatarUrl } });
  } catch (e) {
    res.status(401).json({ error: 'Google verification failed' });
  }
});

const refreshSchema = z.object({ refreshToken: z.string().min(1) });
authRouter.post('/refresh', async (req, res) => {
  const parsed = refreshSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json(parsed.error);
  const { refreshToken } = parsed.data;
  const found = await RefreshToken.findOne({ token: refreshToken });
  if (!found) return res.status(401).json({ error: 'Invalid refresh token' });
  try {
    const decoded = verifyRefresh(refreshToken) as any;
    await RefreshToken.deleteOne({ token: refreshToken });
    const newRefresh = signRefresh({ sub: decoded.sub });
    const expiresSec = parseInt(String(process.env.REFRESH_EXPIRES_IN || '2592000s').replace('s','')) || 2592000;
    const expiresAt = new Date(Date.now() + expiresSec * 1000);
    await RefreshToken.create({ user: decoded.sub, token: newRefresh, expiresAt });
    const accessToken = signAccess({ sub: decoded.sub });
    res.json({ accessToken, refreshToken: newRefresh });
  } catch {
    return res.status(401).json({ error: 'Expired refresh token' });
  }
});
authRouter.post('/logout', async (req, res) => { const token = req.body?.refreshToken; if (token) await RefreshToken.deleteOne({ token }); res.json({ ok: true }); });


import { Router } from 'express';
import { requireAuth, AuthedRequest, requireAdmin } from '../../middleware/auth.js';
import { User } from './user.model.js';
import { Audit } from '../audit/audit.model.js';

export const usersRouter = Router();
usersRouter.get('/me', requireAuth, async (req: AuthedRequest, res) => {
  const me = await User.findById(req.user!.sub);
  if (!me) return res.status(404).json({ error: 'Not found' });
  res.json({ id: me._id.toString(), email: me.email, displayName: me.displayName, role: me.role, avatarUrl: me.avatarUrl });
});
usersRouter.get('/search', requireAuth, async (req, res) => {
  const q = (req.query.q as string || '').trim();
  if (!q) return res.json([]);
  const users = await User.find({ displayName: { $regex: q, $options: 'i' } }).limit(10);
  res.json(users.map(u => ({ id: u._id.toString(), displayName: u.displayName, email: u.email, avatarUrl: u.avatarUrl })));
});
usersRouter.get('/', requireAuth, requireAdmin, async (_req, res) => {
  const users = await User.find().sort({ createdAt: -1 }).limit(200);
  res.json(users.map(u => ({ id: u._id.toString(), email: u.email, displayName: u.displayName, role: u.role, banned: u.banned })));
});
usersRouter.post('/:id/ban', requireAuth, requireAdmin, async (req:AuthedRequest, res) => { await User.findByIdAndUpdate(req.params.id, { banned: true }); await Audit.create({ actor: req.user!.sub, action: 'ban', target: req.params.id }); res.json({ ok: true }); });
usersRouter.post('/:id/unban', requireAuth, requireAdmin, async (req:AuthedRequest, res) => { await User.findByIdAndUpdate(req.params.id, { banned: false }); await Audit.create({ actor: req.user!.sub, action: 'unban', target: req.params.id }); res.json({ ok: true }); });
usersRouter.post('/:id/role', requireAuth, requireAdmin, async (req:AuthedRequest, res) => { const role = (req.body?.role as string) || 'user'; await User.findByIdAndUpdate(req.params.id, { role }); await Audit.create({ actor: req.user!.sub, action: 'setRole', target: req.params.id, meta: { role } }); res.json({ ok: true }); });

/** Device token register for FCM */
usersRouter.post('/device', requireAuth, async (req: AuthedRequest, res) => {
  const token = (req.body?.token as string) || '';
  if (!token) return res.status(400).json({ error: 'token required' });
  (global as any).__deviceTokens = (global as any).__deviceTokens || new Map<string,string>();
  (global as any).__deviceTokens.set(req.user!.sub, token);
  res.json({ ok: true });
});


/** Update my profile (displayName, avatarUrl) */
usersRouter.post('/me', requireAuth, async (req: AuthedRequest, res) => {
  const displayName = (req.body?.displayName as string|undefined);
  const avatarUrl = (req.body?.avatarUrl as string|undefined);
  const update:any = {};
  if (displayName) update.displayName = displayName;
  if (avatarUrl !== undefined) update.avatarUrl = avatarUrl;
  await User.findByIdAndUpdate(req.user!.sub, update);
  res.json({ ok: true });
});

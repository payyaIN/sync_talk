
import { Router } from 'express';
import { requireAuth, AuthedRequest } from '../../core/middleware/auth.js';
import { z } from 'zod';
import { Message } from './message.model.js';
import { Conversation } from '../conversations/conversation.model.js';
import { config } from '../../config/env.js';
import { sendFcm } from '../../core/utils/fcm.js';

export const messagesRouter = Router();

messagesRouter.get('/:conversationId', requireAuth, async (req: AuthedRequest, res) => {
  const convId = req.params.conversationId;
  const cursor = req.query.cursor ? new Date(String(req.query.cursor)) : null;
  const limit = Math.min(Number(req.query.limit || 50), 100);
  const filter: any = { conversation: convId, parentMessage: { $exists: false } };
  if (cursor) filter.createdAt = { $lt: cursor };
  const messages = await Message.find(filter).sort({ createdAt: -1 }).limit(limit);
  const items = messages.map(m => ({ id: m._id.toString(), sender: m.sender, content: m.content, attachments: m.attachments, readBy: m.readBy, createdAt: m.createdAt }));
  const nextCursor = messages.length ? messages[messages.length-1].createdAt.toISOString() : null;
  res.json({ items: items.reverse(), nextCursor });
});

const sendSchema = z.object({ content: z.string().default(''), attachments: z.array(z.string()).default([]), parentMessage: z.string().optional() });
messagesRouter.post('/:conversationId', requireAuth, async (req: AuthedRequest, res) => {
  const convId = req.params.conversationId;
  const conv = await Conversation.findById(convId);
  if (!conv) return res.status(404).json({ error: 'Conversation not found' });
  if (!conv.participants.map(String).includes(req.user!.sub)) return res.status(403).json({ error: 'Forbidden' });
  const parsed = sendSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json(parsed.error);
  const msg = await Message.create({ conversation: convId, sender: req.user!.sub, ...parsed.data });
  conv.lastMessageAt = new Date(); await conv.save();
  const io = req.app.get('io'); io?.of('/chat').to(convId).emit('message:new', { conversationId: convId, id: msg._id.toString(), sender: msg.sender, content: msg.content, attachments: msg.attachments, createdAt: msg.createdAt });
  const tokens: Map<string,string> | undefined = (global as any).__deviceTokens;
  if (tokens && process.env.FCM_SERVER_KEY) {
    for (const p of conv.participants.map(String)) {
      const token = tokens.get(p);
      if (token && p != String(req.user!.sub)) {
        await sendFcm(process.env.FCM_SERVER_KEY!, token, 'New message', String(parsed.data.content || 'Attachment'));
      }
    }
  }
  res.status(201).json({ id: msg._id.toString() });
});

messagesRouter.post('/:id/read', requireAuth, async (req: AuthedRequest, res) => {
  const id = req.params.id;
  const msg = await Message.findById(id);
  if (!msg) return res.status(404).json({ error: 'Message not found' });
  if (!msg.readBy.map(String).includes(req.user!.sub)) {
    msg.readBy.push(req.user!.sub);
    await msg.save();
    const io = req.app.get('io');
    io?.of('/chat').to(String(msg.conversation)).emit('message:read', { conversationId: String(msg.conversation), messageId: id, userId: req.user!.sub });
  }
  res.json({ ok: true });
});


/** delete message (admin) */
import { requireAdmin } from '../../core/middleware/auth.js';
import { Audit } from '../audit/audit.model.js';
messagesRouter.delete('/:id', requireAuth, requireAdmin, async (req: AuthedRequest, res) => {
  const id = req.params.id;
  const m = await Message.findByIdAndDelete(id);
  if (!m) return res.status(404).json({ error: 'Message not found' });
  const io = req.app.get('io');
  io?.of('/chat').to(String(m.conversation)).emit('message:deleted', { messageId: id });
  await Audit.create({ actor: req.user!.sub, action: 'deleteMessage', target: id, meta: { conversation: String(m.conversation) } });
  res.json({ ok: true });
});


/** Search messages (simple text match), filters by conversations user participates in */
messagesRouter.get('/search', requireAuth, async (req: AuthedRequest, res) => {
  const q = String(req.query.q || '').trim();
  if (!q) return res.json({ items: [] });
  // Find conversations for user, then match messages
  const convIds = (await import('../conversations/conversation.model.js')).Conversation
    .find({ participants: req.user!.sub }).distinct('_id');
  const list = await Message.find({ conversation: { $in: await convIds }, content: { $regex: q, $options: 'i' } })
    .sort({ createdAt: -1 }).limit(50);
  res.json({ items: list.map(m => ({ id: m._id.toString(), conversation: m.conversation, sender: m.sender, content: m.content, createdAt: m.createdAt })) });
});

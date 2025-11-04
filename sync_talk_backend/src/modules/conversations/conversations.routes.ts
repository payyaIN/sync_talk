// import { Router } from "express";
// import { authMiddleware } from "../../middleware/auth.middleware";
// import { createPrivateChat, listMyChats } from "./conversation.controller";

// const router = Router();

// router.post("/private", authMiddleware, createPrivateChat);
// router.get("/", authMiddleware, listMyChats);

// export default router;



import { Router } from 'express';
import { requireAuth, AuthedRequest } from '../../middleware/auth.js';
import { z } from 'zod';
import { Conversation } from './conversation.model.js';
import { Types } from 'mongoose';

export const conversationsRouter = Router();
conversationsRouter.get('/', requireAuth, async (req: AuthedRequest, res) => {
  const list = await Conversation.find({ participants: req.user!.sub }).sort({ updatedAt: -1 }).limit(100);
  res.json(list.map(c => ({ id: (c._id as Types.ObjectId).toString(), 
    participants: c.participants, title: c.title, isGroup: c.isGroup, 
    updatedAt: c.updatedAt, lastMessageAt: c.lastMessageAt })));
});
const createSchema = z.object({ participants: z.array(z.string()).min(1), title: z.string().optional(), isGroup: z.boolean().optional() });
conversationsRouter.post('/', requireAuth, async (req: AuthedRequest, res) => {
  const parsed = createSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json(parsed.error);
  const { participants, title, isGroup } = parsed.data;
  const unique = Array.from(new Set([...participants, req.user!.sub]));
  const conv = await Conversation.create({ participants: unique, title, isGroup: !!isGroup });
  res.status(201).json({ id: (conv._id as Types.ObjectId).toString(), participants: conv.participants, title: conv.title, isGroup: conv.isGroup });
});

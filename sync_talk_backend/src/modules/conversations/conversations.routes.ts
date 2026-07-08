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
  const list = await Conversation.find({ participants: req.user!.sub })
    .populate('participants', 'displayName email avatarUrl')
    .sort({ updatedAt: -1 })
    .limit(100);
  res.json(list.map(c => ({ 
    id: (c._id as Types.ObjectId).toString(), 
    participants: c.participants.map((p: any) => ({ 
      _id: (p._id as Types.ObjectId).toString(), 
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
const createSchema = z.object({ participants: z.array(z.string()).min(1), title: z.string().optional(), isGroup: z.boolean().optional() });
conversationsRouter.post('/', requireAuth, async (req: AuthedRequest, res) => {
  const parsed = createSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json(parsed.error);
  const { participants, title, isGroup } = parsed.data;
  const unique = Array.from(new Set([...participants, req.user!.sub]));
  const conv = await Conversation.create({ participants: unique, title, isGroup: !!isGroup });
  res.status(201).json({ id: (conv._id as Types.ObjectId).toString(), participants: conv.participants, title: conv.title, isGroup: conv.isGroup });
});

conversationsRouter.get('/:id', requireAuth, async (req: AuthedRequest, res) => {
  try {
    const conv = await Conversation.findOne({
      _id: req.params.id,
      participants: req.user!.sub
    }).populate('participants', 'displayName email avatarUrl role');

    if (!conv) return res.status(404).json({ error: 'Conversation not found' });
    
    res.json({
      success: true,
      data: {
        id: (conv._id as Types.ObjectId).toString(),
        participants: conv.participants.map((p: any) => ({
          _id: (p._id as Types.ObjectId).toString(),
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
  } catch (error) {
    res.status(500).json({ error: 'Internal Server Error' });
  }
});

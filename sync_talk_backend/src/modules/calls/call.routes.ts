import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { Call } from './call.model.js';

export const callsRouter = Router();

// Create call log entry
callsRouter.post('/', requireAuth, async (req, res) => {
  try {
    const userId = (req as any).user._id;
    const { receiverId, isVideo, isMissed, duration } = req.body;
    if (!receiverId) {
      return res.status(400).json({ error: 'receiverId is required' });
    }
    const log = await Call.create({
      caller: userId,
      receiver: receiverId,
      isVideo: isVideo ?? false,
      isMissed: isMissed ?? false,
      duration
    });
    const populated = await Call.findById(log._id)
      .populate('caller', 'displayName email avatarUrl')
      .populate('receiver', 'displayName email avatarUrl');
    res.status(201).json(populated);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

// Get call history logs
callsRouter.get('/', requireAuth, async (req, res) => {
  try {
    const userId = (req as any).user._id;
    const logs = await Call.find({
      $or: [{ caller: userId }, { receiver: userId }]
    })
      .populate('caller', 'displayName email avatarUrl')
      .populate('receiver', 'displayName email avatarUrl')
      .sort({ createdAt: -1 });
    res.json(logs);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

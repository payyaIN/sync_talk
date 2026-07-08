import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { Status } from './status.model.js';

export const statusRouter = Router();

// Create status
statusRouter.post('/', requireAuth, async (req, res) => {
  try {
    const userId = (req as any).user._id;
    const { mediaUrl, caption } = req.body;
    if (!mediaUrl) {
      return res.status(400).json({ error: 'mediaUrl is required' });
    }
    const status = await Status.create({
      user: userId,
      mediaUrl,
      caption
    });
    const populated = await Status.findById(status._id).populate('user', 'displayName email avatarUrl');
    res.status(201).json(populated);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

// Get active statuses
statusRouter.get('/', requireAuth, async (req, res) => {
  try {
    const cutoff = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const statuses = await Status.find({ createdAt: { $gte: cutoff } })
      .populate('user', 'displayName email avatarUrl')
      .sort({ createdAt: -1 });
    res.json(statuses);
  } catch (e: any) {
    res.status(500).json({ error: e.message });
  }
});

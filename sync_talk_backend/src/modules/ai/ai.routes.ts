
import { Router } from 'express';
import { requireAuth } from '../../middleware/auth.js';
import { z } from 'zod';
import { config } from '../../config/env.js';
export const aiRouter = Router();
const suggestSchema = z.object({ prompt: z.string().min(1) });
aiRouter.post('/suggest', requireAuth, async (req, res) => {
  const parsed = suggestSchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json(parsed.error);
  const prompt = parsed.data.prompt;
  if (!config.openAiKey) return res.json({ suggestion: `You said: ${prompt.substring(0,80)}… (AI stub)` });
  return res.json({ suggestion: `Echo: ${prompt}` });
});
const replySchema = z.object({ context: z.array(z.string()).min(1) });
aiRouter.post('/reply', requireAuth, async (req, res) => {
  const parsed = replySchema.safeParse(req.body);
  if (!parsed.success) return res.status(400).json(parsed.error);
  const last = parsed.data.context[parsed.data.context.length-1];
  const canned = last.endsWith('?') ? "Here's what I think…" : "Acknowledged.";
  return res.json({ reply: canned });
});

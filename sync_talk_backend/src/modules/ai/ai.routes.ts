import { Router } from 'express';
import { requireAuth, AuthedRequest } from '../../middleware/auth.js';
import { z } from 'zod';
import { config } from '../../config/env.js';
import { GoogleGenAI } from '@google/genai';
import { AiMessage } from './ai_message.model.js';

export const aiRouter = Router();

const aiClient = config.geminiApiKey ? new GoogleGenAI({ apiKey: config.geminiApiKey }) : null;

const suggestSchema = z.object({ prompt: z.string().min(1) });
aiRouter.post('/suggest', requireAuth, async (req: AuthedRequest, res) => {
  try {
    const parsed = suggestSchema.safeParse(req.body);
    if (!parsed.success) return res.status(400).json(parsed.error);
    const prompt = parsed.data.prompt;
    const userId = req.user?.sub || req.user?.userId || req.user?.id;

    if (!aiClient) {
      return res.json({ suggestion: `Please configure your GEMINI_API_KEY in the backend .env file to enable the real AI assistant.\n\nYour message was: ${prompt}` });
    }

    // Save User message
    await AiMessage.create({ userId, sender: 'me', message: prompt });

    const response = await aiClient.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: prompt,
    });
    
    // Save AI response
    await AiMessage.create({ userId, sender: 'ai', message: response.text });

    return res.json({ suggestion: response.text });
  } catch (error) {
    console.error('AI Suggestion Error:', error);
    return res.status(500).json({ error: 'Failed to generate AI response.' });
  }
});

const replySchema = z.object({ context: z.array(z.string()).min(1) });
aiRouter.post('/reply', requireAuth, async (req, res) => {
  try {
    const parsed = replySchema.safeParse(req.body);
    if (!parsed.success) return res.status(400).json(parsed.error);
    
    if (!aiClient) {
      return res.json({ reply: 'AI is not configured. Add GEMINI_API_KEY.' });
    }

    const context = parsed.data.context.join('\n');
    const response = await aiClient.models.generateContent({
      model: 'gemini-2.5-flash',
      contents: `Generate a short, helpful quick reply to the following conversation context:\n\n${context}`,
    });

    return res.json({ reply: response.text });
  } catch (error) {
    console.error('AI Reply Error:', error);
    return res.status(500).json({ error: 'Failed to generate AI reply.' });
  }
});

aiRouter.get('/history', requireAuth, async (req: AuthedRequest, res) => {
  try {
    const userId = req.user?.sub || req.user?.userId || req.user?.id;
    const messages = await AiMessage.find({ userId }).sort({ createdAt: 1 });
    
    // Format for mobile app
    const formatted = messages.map(m => ({
      sender: m.sender,
      message: m.message
    }));

    return res.json({ history: formatted });
  } catch (error) {
    console.error('AI History Error:', error);
    return res.status(500).json({ error: 'Failed to fetch AI history.' });
  }
});

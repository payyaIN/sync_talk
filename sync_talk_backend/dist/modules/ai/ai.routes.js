"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.aiRouter = void 0;
const express_1 = require("express");
const auth_js_1 = require("../../middleware/auth.js");
const zod_1 = require("zod");
const env_js_1 = require("../../config/env.js");
const genai_1 = require("@google/genai");
const ai_message_model_js_1 = require("./ai_message.model.js");
exports.aiRouter = (0, express_1.Router)();
const aiClient = env_js_1.config.geminiApiKey ? new genai_1.GoogleGenAI({ apiKey: env_js_1.config.geminiApiKey }) : null;
const suggestSchema = zod_1.z.object({ prompt: zod_1.z.string().min(1) });
exports.aiRouter.post('/suggest', auth_js_1.requireAuth, async (req, res) => {
    try {
        const parsed = suggestSchema.safeParse(req.body);
        if (!parsed.success)
            return res.status(400).json(parsed.error);
        const prompt = parsed.data.prompt;
        const userId = req.user?.sub || req.user?.userId || req.user?.id;
        if (!aiClient) {
            return res.json({ suggestion: `Please configure your GEMINI_API_KEY in the backend .env file to enable the real AI assistant.\n\nYour message was: ${prompt}` });
        }
        // Save User message
        await ai_message_model_js_1.AiMessage.create({ userId, sender: 'me', message: prompt });
        const response = await aiClient.models.generateContent({
            model: 'gemini-2.5-flash',
            contents: prompt,
        });
        // Save AI response
        await ai_message_model_js_1.AiMessage.create({ userId, sender: 'ai', message: response.text });
        return res.json({ suggestion: response.text });
    }
    catch (error) {
        console.error('AI Suggestion Error:', error);
        return res.status(500).json({ error: 'Failed to generate AI response.' });
    }
});
const replySchema = zod_1.z.object({ context: zod_1.z.array(zod_1.z.string()).min(1) });
exports.aiRouter.post('/reply', auth_js_1.requireAuth, async (req, res) => {
    try {
        const parsed = replySchema.safeParse(req.body);
        if (!parsed.success)
            return res.status(400).json(parsed.error);
        if (!aiClient) {
            return res.json({ reply: 'AI is not configured. Add GEMINI_API_KEY.' });
        }
        const context = parsed.data.context.join('\n');
        const response = await aiClient.models.generateContent({
            model: 'gemini-2.5-flash',
            contents: `Generate a short, helpful quick reply to the following conversation context:\n\n${context}`,
        });
        return res.json({ reply: response.text });
    }
    catch (error) {
        console.error('AI Reply Error:', error);
        return res.status(500).json({ error: 'Failed to generate AI reply.' });
    }
});
exports.aiRouter.get('/history', auth_js_1.requireAuth, async (req, res) => {
    try {
        const userId = req.user?.sub || req.user?.userId || req.user?.id;
        const messages = await ai_message_model_js_1.AiMessage.find({ userId }).sort({ createdAt: 1 });
        // Format for mobile app
        const formatted = messages.map(m => ({
            sender: m.sender,
            message: m.message
        }));
        return res.json({ history: formatted });
    }
    catch (error) {
        console.error('AI History Error:', error);
        return res.status(500).json({ error: 'Failed to fetch AI history.' });
    }
});

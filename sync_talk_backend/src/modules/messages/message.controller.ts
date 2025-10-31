import { Request, Response } from "express";
import mongoose from "mongoose";
import { Message } from "./message.model";
import { Conversation } from "../conversations/conversation.model";
import { successResponse, errorResponse } from "../../utils/response";
import { AuthRequest } from "../../middleware/auth.middleware";

// Guard: ensure user is a participant
const ensureParticipant = async (userId: string, conversationId: string) => {
  const c = await Conversation.findById(conversationId).select("participants");
  if (!c) return false;
  return c.participants.some(p => p.toString() === userId);
};

// GET /messages/:conversationId?page=1&limit=30
export const getMessages = async (req: AuthRequest, res: Response) => {
  const { conversationId } = req.params;
  const page  = Number(req.query.page ?? 1);
  const limit = Number(req.query.limit ?? 30);
  const skip  = (page - 1) * limit;

  const ok = await ensureParticipant(req.user!.userId, conversationId);
  if (!ok) return errorResponse(res, "Forbidden", 403);

  const list = await Message
    .find({ conversationId })
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit)
    .populate("sender", "name email avatar");

  return successResponse(res, "Messages fetched", list.reverse());
};

// POST /messages  { conversationId, message }
export const postMessage = async (req: AuthRequest, res: Response) => {
  const { conversationId, message } = req.body;
  if (!conversationId || !message) return errorResponse(res, "Missing fields", 400);

  const ok = await ensureParticipant(req.user!.userId, conversationId);
  if (!ok) return errorResponse(res, "Forbidden", 403);

  const saved = await Message.create({
    conversationId,
    sender: req.user!.userId,
    message
  });

  await Conversation.findByIdAndUpdate(conversationId, { lastMessageAt: new Date() });

  // Socket broadcast will also happen; HTTP returns saved message
  return successResponse(res, "Message sent", await saved.populate("sender", "name email avatar"));
};

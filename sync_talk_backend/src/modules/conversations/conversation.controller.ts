import { Request, Response } from "express";
import { Conversation } from "./conversation.model";
import { success, fail } from "../../utils/response";
import { AuthRequest } from "../../middleware/auth.middleware";

// Create/Get private conversation
export const createPrivateChat = async (req: AuthRequest, res: Response) => {
  try {
    const { userId } = req.body; // person to talk to

    if (!userId) return fail(res, "User ID required");

    // Check if chat already exists
    let chat = await Conversation.findOne({
      isGroup: false,
      participants: { $all: [req.user!.userId, userId] },
    });

    if (!chat) {
      chat = await Conversation.create({
        participants: [req.user!.userId, userId],
      });
    }

    return success(res, "Chat ready", chat);
  } catch (error) {
    return fail(res, "Chat creation failed", 500);
  }
};

// List my chats
export const listMyChats = async (req: AuthRequest, res: Response) => {
  try {
    const chats = await Conversation.find({
      participants: req.user!.userId,
    })
      .populate("participants", "name email avatar")
      .sort({ updatedAt: -1 });

    return success(res, "Chats fetched", chats);
  } catch (error) {
    return fail(res, "Failed to load chats", 500);
  }
};

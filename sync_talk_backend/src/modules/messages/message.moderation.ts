import { Request, Response } from "express";
import { Message } from "./message.model";
import { Conversation } from "../conversations/conversation.model";
import { AuthRequest } from "../../middleware/auth.middleware";

// DELETE /messages/:id  (soft delete)
export const deleteMessage = async (req: AuthRequest, res: Response) => {
  try {
    const messageId = req.params.id;

    const msg = await Message.findById(messageId);
    if (!msg) return res.status(404).json({ message: "Message not found" });

    // Users can delete only their own message
    if (msg.sender.toString() !== req.user!.userId)
      return res.status(403).json({ message: "Not allowed" });

    msg.content = "🗑️ message deleted";
    await msg.save();

    return res.json({ message: "Message deleted" });
  } catch {
    return res.status(500).json({ message: "Delete failed" });
  }
};

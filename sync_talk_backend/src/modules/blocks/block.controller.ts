import { Request, Response } from "express";
import { Block } from "./blocked.model";
import { AuthRequest } from "../../middleware/auth.middleware";

// POST /block/:userId
export const blockUser = async (req: AuthRequest, res: Response) => {
  await Block.create({ blocker: req.user!.userId, blocked: req.params.userId });
  res.json({ message: "User blocked" });
};

// DELETE /block/:userId
export const unblockUser = async (req: AuthRequest, res: Response) => {
  await Block.deleteOne({ blocker: req.user!.userId, blocked: req.params.userId });
  res.json({ message: "User unblocked" });
};

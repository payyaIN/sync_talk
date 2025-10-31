import { Request, Response } from "express";
import { User } from "../users/user.model";
import { Block } from "../blocks/blocked.model";

export const banUser = async (req: Request, res: Response) => {
  await User.findByIdAndUpdate(req.params.userId, { role: "banned" });
  return res.json({ message: "User banned" });
};

export const muteUser = async (req: Request, res: Response) => {
  await Block.create({ blocker: "SYSTEM", blocked: req.params.userId });
  return res.json({ message: "User muted globally" });
};

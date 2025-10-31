import { Request, Response } from "express";
import mongoose from "mongoose";
import { Conversation } from "./conversation.model";
import { AuthRequest } from "../../middleware/auth.middleware";

export const getGroupDetails = async (req: AuthRequest, res: Response) => {
  const group = await Conversation.findById(req.params.id)
    .populate("participants", "name email avatar")
    .populate("admins", "name email avatar");
  if (!group || !group.isGroup) return res.status(404).json({ message: "Group not found" });
  res.json({ success: true, data: group });
};

export const addMembers = async (req: AuthRequest, res: Response) => {
  const { conversationId, members } = req.body;
  const group = await Conversation.findById(conversationId);
  if (!group || !group.isGroup) return res.status(404).json({ message: "Group not found" });

  const me = new mongoose.Types.ObjectId(req.user!.userId);
  const isAdmin = group.admins.some(a => a.toString() === me.toString());
  if (!isAdmin) return res.status(403).json({ message: "Only admins can add members" });

  const toAdd = (members as string[]).map(id => new mongoose.Types.ObjectId(id));
  const set = new Set(group.participants.map(p => p.toString()));
  toAdd.forEach(m => set.add(m.toString()));
  group.participants = Array.from(set).map(id => new mongoose.Types.ObjectId(id));
  await group.save();
  res.json({ success: true, message: "Members added", data: group });
};

export const removeMember = async (req: AuthRequest, res: Response) => {
  const { conversationId, userId } = req.body;
  const group = await Conversation.findById(conversationId);
  if (!group || !group.isGroup) return res.status(404).json({ message: "Group not found" });

  const me = req.user!.userId;
  const isAdmin = group.admins.some(a => a.toString() === me);
  if (!isAdmin) return res.status(403).json({ message: "Only admins can remove members" });

  group.participants = group.participants.filter(p => p.toString() !== userId);
  // If user was admin, drop admin too
  group.admins = group.admins.filter(a => a.toString() !== userId);
  await group.save();
  res.json({ success: true, message: "Member removed", data: group });
};

export const leaveGroup = async (req: AuthRequest, res: Response) => {
  const { conversationId } = req.body;
  const group = await Conversation.findById(conversationId);
  if (!group || !group.isGroup) return res.status(404).json({ message: "Group not found" });

  const me = req.user!.userId;
  group.participants = group.participants.filter(p => p.toString() !== me);
  group.admins = group.admins.filter(a => a.toString() !== me);

  // Edge case: no admins left → promote first participant as admin
  if (group.admins.length === 0 && group.participants.length > 0) {
    group.admins = [group.participants[0] as any];
  }
  await group.save();
  res.json({ success: true, message: "Left group", data: group });
};

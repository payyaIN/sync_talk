"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.leaveGroup = exports.removeMember = exports.addMembers = exports.getGroupDetails = void 0;
const mongoose_1 = __importDefault(require("mongoose"));
const conversation_model_1 = require("./conversation.model");
const getGroupDetails = async (req, res) => {
    const group = await conversation_model_1.Conversation.findById(req.params.id)
        .populate("participants", "name email avatar")
        .populate("admins", "name email avatar");
    if (!group || !group.isGroup)
        return res.status(404).json({ message: "Group not found" });
    res.json({ success: true, data: group });
};
exports.getGroupDetails = getGroupDetails;
const addMembers = async (req, res) => {
    const { conversationId, members } = req.body;
    const group = await conversation_model_1.Conversation.findById(conversationId);
    if (!group || !group.isGroup)
        return res.status(404).json({ message: "Group not found" });
    if (!group.admins || group.admins.length === 0) {
        return res.status(500).json({ message: "Group has no admins" });
    }
    const me = new mongoose_1.default.Types.ObjectId(req.user.userId);
    const isAdmin = group.admins.some(a => a.toString() === me.toString());
    if (!isAdmin)
        return res.status(403).json({ message: "Only admins can add members" });
    const toAdd = members.map(id => new mongoose_1.default.Types.ObjectId(id));
    const set = new Set(group.participants.map(p => p.toString()));
    toAdd.forEach(m => set.add(m.toString()));
    group.participants = Array.from(set).map(id => new mongoose_1.default.Types.ObjectId(id));
    await group.save();
    res.json({ success: true, message: "Members added", data: group });
};
exports.addMembers = addMembers;
const removeMember = async (req, res) => {
    const { conversationId, userId } = req.body;
    const group = await conversation_model_1.Conversation.findById(conversationId);
    if (!group || !group.isGroup)
        return res.status(404).json({ message: "Group not found" });
    if (!group.admins || group.admins.length === 0) {
        return res.status(500).json({ message: "Group has no admins" });
    }
    const me = req.user.userId;
    const isAdmin = group.admins.some(a => a.toString() === me);
    if (!isAdmin)
        return res.status(403).json({ message: "Only admins can remove members" });
    group.participants = group.participants.filter(p => p.toString() !== userId);
    // If user was admin, drop admin too
    group.admins = group.admins.filter(a => a.toString() !== userId);
    await group.save();
    res.json({ success: true, message: "Member removed", data: group });
};
exports.removeMember = removeMember;
const leaveGroup = async (req, res) => {
    const { conversationId } = req.body;
    const group = await conversation_model_1.Conversation.findById(conversationId);
    if (!group || !group.isGroup)
        return res.status(404).json({ message: "Group not found" });
    if (!group.admins || group.admins.length === 0) {
        return res.status(500).json({ message: "Group has no admins" });
    }
    const me = req.user.userId;
    group.participants = group.participants.filter(p => p.toString() !== me);
    group.admins = group.admins.filter(a => a.toString() !== me);
    // Edge case: no admins left → promote first participant as admin
    if (group.admins.length === 0 && group.participants.length > 0) {
        group.admins = [group.participants[0]];
    }
    await group.save();
    res.json({ success: true, message: "Left group", data: group });
};
exports.leaveGroup = leaveGroup;

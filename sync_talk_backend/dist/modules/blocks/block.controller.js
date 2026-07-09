"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.unblockUser = exports.blockUser = void 0;
const blocked_model_1 = require("./blocked.model");
// POST /block/:userId
const blockUser = async (req, res) => {
    await blocked_model_1.Block.create({ blocker: req.user.userId, blocked: req.params.userId });
    res.json({ message: "User blocked" });
};
exports.blockUser = blockUser;
// DELETE /block/:userId
const unblockUser = async (req, res) => {
    await blocked_model_1.Block.deleteOne({ blocker: req.user.userId, blocked: req.params.userId });
    res.json({ message: "User unblocked" });
};
exports.unblockUser = unblockUser;

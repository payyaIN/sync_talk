"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.muteUser = exports.banUser = void 0;
const user_model_1 = require("../users/user.model");
const blocked_model_1 = require("../blocks/blocked.model");
const banUser = async (req, res) => {
    await user_model_1.User.findByIdAndUpdate(req.params.userId, { role: "banned" });
    return res.json({ message: "User banned" });
};
exports.banUser = banUser;
const muteUser = async (req, res) => {
    await blocked_model_1.Block.create({ blocker: "SYSTEM", blocked: req.params.userId });
    return res.json({ message: "User muted globally" });
};
exports.muteUser = muteUser;

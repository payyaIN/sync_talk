"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.searchUsers = void 0;
const user_model_1 = require("../users/user.model");
const response_1 = require("../../utils/response");
const searchUsers = async (req, res) => {
    try {
        const q = req.query.q?.toString().trim() || "";
        if (!q)
            return (0, response_1.success)(res, "Search result", []);
        const users = await user_model_1.User.find({
            $or: [
                { name: { $regex: q, $options: "i" } },
                { email: { $regex: q, $options: "i" } }
            ]
        }).select("-password");
        return (0, response_1.success)(res, "Search result", users);
    }
    catch (error) {
        return (0, response_1.fail)(res, "Search failed", 500);
    }
};
exports.searchUsers = searchUsers;

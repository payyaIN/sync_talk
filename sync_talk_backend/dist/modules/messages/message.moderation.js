"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteMessage = void 0;
const message_model_1 = require("./message.model");
// DELETE /messages/:id  (soft delete)
const deleteMessage = async (req, res) => {
    try {
        const messageId = req.params.id;
        const msg = await message_model_1.Message.findById(messageId);
        if (!msg)
            return res.status(404).json({ message: "Message not found" });
        // Users can delete only their own message
        if (msg.sender.toString() !== req.user.userId)
            return res.status(403).json({ message: "Not allowed" });
        msg.content = "🗑️ message deleted";
        await msg.save();
        return res.json({ message: "Message deleted" });
    }
    catch {
        return res.status(500).json({ message: "Delete failed" });
    }
};
exports.deleteMessage = deleteMessage;

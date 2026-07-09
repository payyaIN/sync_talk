"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const auth_middleware_1 = require("../../middleware/auth.middleware");
const block_controller_1 = require("./block.controller");
const router = (0, express_1.Router)();
router.post("/:userId", auth_middleware_1.authMiddleware, block_controller_1.blockUser);
router.delete("/:userId", auth_middleware_1.authMiddleware, block_controller_1.unblockUser);
exports.default = router;

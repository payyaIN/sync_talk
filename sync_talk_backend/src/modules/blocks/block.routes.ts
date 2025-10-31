import { Router } from "express";
import { authMiddleware } from "../../middleware/auth.middleware";
import { blockUser, unblockUser } from "./block.controller";

const router = Router();

router.post("/:userId", authMiddleware, blockUser);
router.delete("/:userId", authMiddleware, unblockUser);

export default router;

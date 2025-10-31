import { Router } from "express";
import { banUser, muteUser } from "./actions.controller";
import { authMiddleware } from "../../middleware/auth.middleware";
import { adminOnly } from "../../middleware/admin.middleware";

const router = Router();

router.post("/ban/:userId", authMiddleware, adminOnly, banUser);
router.post("/mute/:userId", authMiddleware, adminOnly, muteUser);

export default router;

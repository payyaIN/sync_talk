import { Router } from "express";
import { getMyProfile, searchUsers } from "./user.controller";
import { authMiddleware } from "../../middleware/auth.middleware";

const router = Router();

router.get("/me", authMiddleware, getMyProfile);
router.get("/search", authMiddleware, searchUsers);

export default router;

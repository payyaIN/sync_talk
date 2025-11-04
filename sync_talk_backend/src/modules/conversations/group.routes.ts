import router from "modules/admin/actions.routes";
import { getGroupDetails, addMembers, removeMember, leaveGroup } from "./group.controller";
import { authMiddleware } from "middleware/auth.middleware";

router.get("/:id", authMiddleware, getGroupDetails);
router.post("/members/add", authMiddleware, addMembers);
router.post("/members/remove", authMiddleware, removeMember);
router.post("/leave", authMiddleware, leaveGroup);

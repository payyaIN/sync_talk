import { getGroupDetails, addMembers, removeMember, leaveGroup } from "./group.controller";

router.get("/:id", authMiddleware, getGroupDetails);
router.post("/members/add", authMiddleware, addMembers);
router.post("/members/remove", authMiddleware, removeMember);
router.post("/leave", authMiddleware, leaveGroup);

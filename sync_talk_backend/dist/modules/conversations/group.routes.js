"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const actions_routes_1 = __importDefault(require("modules/admin/actions.routes"));
const group_controller_1 = require("./group.controller");
const auth_middleware_1 = require("middleware/auth.middleware");
actions_routes_1.default.get("/:id", auth_middleware_1.authMiddleware, group_controller_1.getGroupDetails);
actions_routes_1.default.post("/members/add", auth_middleware_1.authMiddleware, group_controller_1.addMembers);
actions_routes_1.default.post("/members/remove", auth_middleware_1.authMiddleware, group_controller_1.removeMember);
actions_routes_1.default.post("/leave", auth_middleware_1.authMiddleware, group_controller_1.leaveGroup);

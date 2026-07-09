"use strict";
// import { Response, NextFunction } from "express";
// import { AuthRequest } from "./auth.middleware";
// import { User } from "../modules/auth/user.model";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAdmin = void 0;
const requireAdmin = (req, res, next) => {
    // Check for user role from JWT token (already in req.user from auth middleware)
    if (!req.user)
        return res.status(401).json({ message: "Unauthorized" });
    if (req.user.role !== 'admin') {
        return res.status(403).json({ message: 'Admin access required' });
    }
    next();
};
exports.requireAdmin = requireAdmin;

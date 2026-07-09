"use strict";
// import { NextFunction, Request, Response } from 'express';
// import jwt from 'jsonwebtoken';
// import { config } from '../config/env.js';
// export interface AuthedRequest extends Request { user?: any }
// export function requireAuth(req: AuthedRequest, res: Response, next: NextFunction) {
//   const header = req.headers.authorization || '';
//   const token = header.startsWith('Bearer ') ? header.slice(7) : null;
//   if (!token) return res.status(401).json({ error: 'Missing token' });
//   try { const decoded = jwt.verify(token, config.jwt.accessSecret); req.user = decoded; next(); }
//   catch { return res.status(401).json({ error: 'Invalid token' }); }
// }
// export function requireAdmin(req: AuthedRequest, res: Response, next: NextFunction) {
//   if (req.user?.role !== 'admin') return res.status(403).json({ error: 'Admin only' });
//   next();
// }
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireAuth = requireAuth;
exports.requireAdmin = requireAdmin;
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
// import { cfg } from "../config/env.js";
const env_js_1 = require("../config/env.js");
function requireAuth(req, res, next) {
    const h = req.headers.authorization;
    if (!h)
        return res.status(401).json({ message: "Missing Authorization" });
    const token = h.replace("Bearer ", "").trim();
    try {
        // const payload = jwt.verify(token, cfg.jwtSecret as string) as any;
        const payload = jsonwebtoken_1.default.verify(token, env_js_1.config.jwt.accessSecret);
        req.user = payload;
        return next();
    }
    catch (err) {
        return res.status(401).json({ message: "Invalid token" });
    }
}
function requireAdmin(req, res, next) {
    if (!req.user)
        return res.status(401).json({ message: "Unauthorized" });
    if (req.user.role !== "admin")
        return res.status(403).json({ message: "Admin only" });
    next();
}

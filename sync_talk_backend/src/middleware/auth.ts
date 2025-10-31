
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

import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import { cfg } from "../config/env.js";

export interface AuthedRequest extends Request {
  user?: { userId: string; role?: string; [k: string]: any };
}

export function requireAuth(req: AuthedRequest, res: Response, next: NextFunction) {
  const h = req.headers.authorization;
  if (!h) return res.status(401).json({ message: "Missing Authorization" });
  const token = h.replace("Bearer ", "").trim();
  try {
    const payload = jwt.verify(token, cfg.jwtSecret as string) as any;
    req.user = payload;
    return next();
  } catch (err) {
    return res.status(401).json({ message: "Invalid token" });
  }
}

export function requireAdmin(req: AuthedRequest, res: Response, next: NextFunction) {
  if (!req.user) return res.status(401).json({ message: "Unauthorized" });
  if (req.user.role !== "admin") return res.status(403).json({ message: "Admin only" });
  next();
}

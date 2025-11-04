// import { Response, NextFunction } from "express";
// import { AuthRequest } from "./auth.middleware";
// import { User } from "../modules/auth/user.model";

// export const adminOnly = async (req: AuthRequest, res: Response, next: NextFunction) => {
//   const user = await User.findById(req.user?.userId);
//   if (!user || user.role !== "admin") {
//     return res.status(403).json({ message: "Admin access required" });
//   }
//   next();
// };

// src/middleware/admin.middleware.ts
import { NextFunction, Response } from 'express';
import { AuthedRequest } from '../middleware/auth';

export const requireAdmin = (req: AuthedRequest, res: Response, next: NextFunction) => {
  // Check for user role from JWT token (already in req.user from auth middleware)
  if (!req.user) return res.status(401).json({ message: "Unauthorized" });
  
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Admin access required' });
  }
  
  next();
};
import { Response, NextFunction } from "express";
import { AuthRequest } from "./auth.middleware";
import { User } from "../modules/auth/user.model";

export const adminOnly = async (req: AuthRequest, res: Response, next: NextFunction) => {
  const user = await User.findById(req.user?.userId);
  if (!user || user.role !== "admin") {
    return res.status(403).json({ message: "Admin access required" });
  }
  next();
};

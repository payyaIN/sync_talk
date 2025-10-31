import { Request, Response } from "express";
import { User } from "./user.model";
import { success, fail } from "../../utils/response";

export const searchUsers = async (req: Request, res: Response) => {
  try {
    const q = req.query.q?.toString().trim() || "";
    if (!q) return success(res, "Search result", []);

    const users = await User.find({
      $or: [
        { name: { $regex: q, $options: "i" } },
        { email: { $regex: q, $options: "i" } }
      ]
    }).select("-password");

    return success(res, "Search result", users);
  } catch (error) {
    return fail(res, "Search failed", 500);
  }
};

import { Request, Response } from "express";
import bcrypt from "bcryptjs";
import jwt from "jsonwebtoken";
import { User } from "./user.model";
import { success, fail } from "../../utils/response";

export const register = async (req: Request, res: Response) => {
  try {
    const { name, email, password } = req.body;

    const exists = await User.findOne({ email });
    if (exists) return fail(res, "Email already registered");

    const hash = await bcrypt.hash(password, 10);
    const user = await User.create({ name, email, password: hash });

    return success(res, "User registered", user);
  } catch (error) {
    return fail(res, "Registration failed", 500);
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) return fail(res, "Invalid email or password");

    const match = await bcrypt.compare(password, user.password);
    if (!match) return fail(res, "Invalid email or password");

    const token = jwt.sign({ userId: user._id }, process.env.JWT_SECRET!, {
      expiresIn: "7d",
    });

    return res.json({ success: true, message: "Login success", token, user });
  } catch (error) {
    return fail(res, "Login failed", 500);
  }
};

export const getProfile = async (req: any, res: Response) => {
  try {
    const user = await User.findById(req.user.userId).select("-password");
    if (!user) return fail(res, "User not found", 404);
    return success(res, "Profile fetched", user);
  } catch {
    return fail(res, "Failed to fetch profile", 500);
  }
};

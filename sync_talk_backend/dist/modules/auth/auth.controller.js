"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProfile = exports.login = exports.register = void 0;
const bcryptjs_1 = __importDefault(require("bcryptjs"));
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const user_model_1 = require("../users/user.model");
const response_1 = require("../../utils/response");
const register = async (req, res) => {
    try {
        const { displayName, email, password } = req.body;
        const exists = await user_model_1.User.findOne({ email });
        if (exists)
            return (0, response_1.fail)(res, "Email already registered");
        const hash = await bcryptjs_1.default.hash(password, 10);
        const user = await user_model_1.User.create({ displayName, email, passwordHash: hash });
        return (0, response_1.success)(res, "User registered", user);
    }
    catch (error) {
        console.error("Register Error:", error);
        return (0, response_1.fail)(res, "Registration failed", 500);
    }
};
exports.register = register;
const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await user_model_1.User.findOne({ email });
        if (!user)
            return (0, response_1.fail)(res, "Invalid email or password");
        const match = await bcryptjs_1.default.compare(password, user.passwordHash);
        if (!match)
            return (0, response_1.fail)(res, "Invalid email or password");
        const token = jsonwebtoken_1.default.sign({ userId: user._id }, process.env.JWT_SECRET, {
            expiresIn: "7d",
        });
        return res.json({ success: true, message: "Login success", token, user });
    }
    catch (error) {
        return (0, response_1.fail)(res, "Login failed", 500);
    }
};
exports.login = login;
const getProfile = async (req, res) => {
    try {
        const user = await user_model_1.User.findById(req.user.userId).select("-password");
        if (!user)
            return (0, response_1.fail)(res, "User not found", 404);
        return (0, response_1.success)(res, "Profile fetched", user);
    }
    catch {
        return (0, response_1.fail)(res, "Failed to fetch profile", 500);
    }
};
exports.getProfile = getProfile;

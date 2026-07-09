"use strict";
// import { Router } from "express";
// import multer from "multer";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.uploadsRouter = void 0;
// const router = Router();
// const upload = multer({ dest: "uploads/" });
// router.post("/file", upload.single("file"), async (req, res) => {
//   try {
//     // TODO: Replace this with real Cloudinary upload
//     const fileUrl = `uploads/${req.file?.filename}`;
//     res.json({ success: true, url: fileUrl });
//   } catch (e) {
//     res.status(500).json({ success: false, message: "Upload failed" });
//   }
// });
// export default router;
const express_1 = require("express");
const multer_1 = __importDefault(require("multer"));
const path_1 = __importDefault(require("path"));
const fs_1 = __importDefault(require("fs"));
const auth_js_1 = require("../../middleware/auth.js");
const uuid_1 = require("uuid");
const env_js_1 = require("../../config/env.js");
const UPLOAD_DIR = env_js_1.config.uploadDir;
fs_1.default.mkdirSync(UPLOAD_DIR, { recursive: true });
const storage = multer_1.default.diskStorage({
    destination: (_req, _file, cb) => cb(null, UPLOAD_DIR),
    filename: (_req, file, cb) => { const ext = path_1.default.extname(file.originalname); cb(null, `${(0, uuid_1.v4)()}${ext}`); }
});
const upload = (0, multer_1.default)({ storage });
exports.uploadsRouter = (0, express_1.Router)();
exports.uploadsRouter.post('/', auth_js_1.requireAuth, upload.single('file'), (req, res) => {
    const file = req.file;
    const url = `/uploads/${file.filename}`;
    res.status(201).json({ url, name: file.originalname, size: file.size });
});

// import { Router } from "express";
// import multer from "multer";

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



import { Router } from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import { requireAuth } from '../../middleware/auth.js';
import { v4 as uuid } from 'uuid';
import { config } from '../../config/env.js';

const UPLOAD_DIR = config.uploadDir;
fs.mkdirSync(UPLOAD_DIR, { recursive: true });
const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, UPLOAD_DIR),
  filename: (_req, file, cb) => { const ext = path.extname(file.originalname); cb(null, `${uuid()}${ext}`); }
});
const upload = multer({ storage });
export const uploadsRouter = Router();
uploadsRouter.post('/', requireAuth, upload.single('file'), (req, res) => {
  const file = (req as any).file as Express.Multer.File;
  const url = `/uploads/${file.filename}`;
  res.status(201).json({ url, name: file.originalname, size: file.size });
});

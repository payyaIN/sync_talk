import { Response } from "express";

export const success = (res: Response, message: string, data?: any) =>
  res.status(200).json({ success: true, message, data });

export const fail = (res: Response, message: string, code = 400) =>
  res.status(code).json({ success: false, message });

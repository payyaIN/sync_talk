"use strict";
// import jwt from 'jsonwebtoken';
// import { config } from '../../config/env.js';
// export const signAccess=(p:object)=> jwt.sign(p, config.jwt.accessSecret, { expiresIn: config.jwt.accessExpiresIn });
// export const signRefresh=(p:object)=> jwt.sign(p, config.jwt.refreshSecret, { expiresIn: config.jwt.refreshExpiresIn });
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.verifyRefresh = exports.signRefresh = exports.signAccess = void 0;
// src/modules/auth/jwt.ts
// import jwt, { SignOptions } from 'jsonwebtoken';
// import { config } from '../../config/env.js';
// export const signAccess = (p: object) => {
//   const options: SignOptions = { expiresIn: config.jwt.accessExpiresIn };
//   return jwt.sign(p, config.jwt.accessSecret, options);
// };
// export const signRefresh = (p: object) => {
//   const options: SignOptions = { expiresIn: config.jwt.refreshExpiresIn };
//   return jwt.sign(p, config.jwt.refreshSecret, options);
// };
// export const verifyRefresh = (t: string) => 
//   jwt.verify(t, config.jwt.refreshSecret);
// File: sync_talk_backend/src/modules/auth/jwt.ts
// Fixed version with proper TypeScript type casting
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
const env_js_1 = require("../../config/env.js");
const signAccess = (p) => {
    return jsonwebtoken_1.default.sign(p, env_js_1.config.jwt.accessSecret, {
        expiresIn: env_js_1.config.jwt.accessExpiresIn
    });
};
exports.signAccess = signAccess;
const signRefresh = (p) => {
    return jsonwebtoken_1.default.sign(p, env_js_1.config.jwt.refreshSecret, {
        expiresIn: env_js_1.config.jwt.refreshExpiresIn
    });
};
exports.signRefresh = signRefresh;
const verifyRefresh = (t) => jsonwebtoken_1.default.verify(t, env_js_1.config.jwt.refreshSecret);
exports.verifyRefresh = verifyRefresh;

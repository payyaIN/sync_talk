import jwt from 'jsonwebtoken';
import { config } from '../../config/env.js';
export const signAccess=(p:object)=> jwt.sign(p, config.jwt.accessSecret, { expiresIn: config.jwt.accessExpiresIn });
export const signRefresh=(p:object)=> jwt.sign(p, config.jwt.refreshSecret, { expiresIn: config.jwt.refreshExpiresIn });
export const verifyRefresh=(t:string)=> jwt.verify(t, config.jwt.refreshSecret);

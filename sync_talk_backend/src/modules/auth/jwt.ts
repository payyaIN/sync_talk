// import jwt from 'jsonwebtoken';
// import { config } from '../../config/env.js';
// export const signAccess=(p:object)=> jwt.sign(p, config.jwt.accessSecret, { expiresIn: config.jwt.accessExpiresIn });
// export const signRefresh=(p:object)=> jwt.sign(p, config.jwt.refreshSecret, { expiresIn: config.jwt.refreshExpiresIn });

// src/modules/auth/jwt.ts
import jwt, { SignOptions } from 'jsonwebtoken';
import { config } from '../../config/env.js';

export const signAccess = (p: object) => {
  const options: SignOptions = { expiresIn: config.jwt.accessExpiresIn };
  return jwt.sign(p, config.jwt.accessSecret, options);
};

export const signRefresh = (p: object) => {
  const options: SignOptions = { expiresIn: config.jwt.refreshExpiresIn };
  return jwt.sign(p, config.jwt.refreshSecret, options);
};

export const verifyRefresh = (t: string) => 
  jwt.verify(t, config.jwt.refreshSecret);
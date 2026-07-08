import express from 'express';
import http from 'http';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';
import path from 'path';
import { authRouter } from './modules/auth/auth.routes.js';
import { usersRouter } from './modules/users/users.routes.js';
import { conversationsRouter } from './modules/conversations/conversations.routes.js';
import { messagesRouter } from './modules/messages/messages.routes.js';
import { uploadsRouter } from './modules/uploads/uploads.routes.js';
import { statusRouter } from './modules/statuses/status.routes.js';
import { callsRouter } from './modules/calls/call.routes.js';
import { aiRouter } from './modules/ai/ai.routes.js';
import { auditRouter } from './modules/audit/audit.routes.js';
import { docsRouter } from './swagger.js';
import { config } from './config/env.js';
import { errorHandler } from './middleware/errorHandler';


export function createApp() {
  const app = express();
  app.use(cors());
  app.use(helmet());
  app.use(morgan('dev'));
  app.use(express.json({ limit: '5mb' }));
  app.use(rateLimit({ windowMs: 60_000, max: 300 }));
  app.get('/health', (_req, res) => res.json({ ok: true }));
  app.use('/api/auth', authRouter);
  app.use('/api/users', usersRouter);
  app.use('/api/conversations', conversationsRouter);
  app.use('/api/messages', messagesRouter);
  app.use('/api/uploads', uploadsRouter);
  app.use('/api/status', statusRouter);
  app.use('/api/calls', callsRouter);
  app.use('/api/ai', aiRouter);
  app.use('/api/audit', auditRouter);
  app.use('/api/docs', docsRouter);
  // app.use("/upload", uploadRoutes);
  app.use('/uploads', express.static(path.resolve(config.uploadDir)));
  app.use(errorHandler);
  return app;
}

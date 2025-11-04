
// import { Router } from 'express';
// import { requireAuth, requireAdmin } from '../../middleware/auth.js';
// import { Audit } from './audit.model.js';
// export const auditRouter = Router();
// auditRouter.get('/', requireAuth, requireAdmin, async (_req, res) => {
//   const items = await Audit.find().sort({ createdAt: -1 }).limit(200);
//   res.json(items.map(a => ({ id: a._id.toString(), actor: a.actor, action: a.action, target: a.target, createdAt: a.createdAt, meta: a.meta })));
// });

import { Router } from 'express';
import { Types } from 'mongoose';  // ADD THIS
import { requireAuth, requireAdmin } from '../../middleware/auth.js';
import { Audit } from './audit.model.js';

export const auditRouter = Router();

auditRouter.get('/', requireAuth, requireAdmin, async (_req, res) => {
  const items = await Audit.find().sort({ createdAt: -1 }).limit(200);
  res.json(items.map(a => ({ 
    id: (a._id as Types.ObjectId).toString(),  
    actor: a.actor, 
    action: a.action, 
    target: a.target, 
    createdAt: a.createdAt, 
    meta: a.meta 
  })));
});

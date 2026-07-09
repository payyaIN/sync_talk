"use strict";
// import { Router } from 'express';
// import { requireAuth, requireAdmin } from '../../middleware/auth.js';
// import { Audit } from './audit.model.js';
// export const auditRouter = Router();
// auditRouter.get('/', requireAuth, requireAdmin, async (_req, res) => {
//   const items = await Audit.find().sort({ createdAt: -1 }).limit(200);
//   res.json(items.map(a => ({ id: a._id.toString(), actor: a.actor, action: a.action, target: a.target, createdAt: a.createdAt, meta: a.meta })));
// });
Object.defineProperty(exports, "__esModule", { value: true });
exports.auditRouter = void 0;
const express_1 = require("express");
const auth_js_1 = require("../../middleware/auth.js");
const audit_model_js_1 = require("./audit.model.js");
exports.auditRouter = (0, express_1.Router)();
exports.auditRouter.get('/', auth_js_1.requireAuth, auth_js_1.requireAdmin, async (_req, res) => {
    const items = await audit_model_js_1.Audit.find().sort({ createdAt: -1 }).limit(200);
    res.json(items.map(a => ({
        id: a._id.toString(),
        actor: a.actor,
        action: a.action,
        target: a.target,
        createdAt: a.createdAt,
        meta: a.meta
    })));
});

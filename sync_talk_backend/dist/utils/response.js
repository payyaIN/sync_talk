"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fail = exports.success = void 0;
const success = (res, message, data) => res.status(200).json({ success: true, message, data });
exports.success = success;
const fail = (res, message, code = 400) => res.status(code).json({ success: false, message });
exports.fail = fail;

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.securityLog = void 0;
const securityLog = (...args) => console.log("⚠️ Security Alert:", ...args);
exports.securityLog = securityLog;

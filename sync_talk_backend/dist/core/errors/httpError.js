"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HttpError = void 0;
class HttpError extends Error {
    constructor(s, m, d) { super(m); this.status = s; this.details = d; }
}
exports.HttpError = HttpError;

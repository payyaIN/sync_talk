"use strict";
// import { NextFunction, Request, Response } from 'express';
// import { HttpError } from '../errors/httpError.js';
// export function errorHandler(
// err:any,
// _req:Request,
// res:Response,
// _next:NextFunction
// ){
//  const status=err instanceof HttpError?err.status:500; 
// const payload:any={ error: err.message||'Internal Server Error' };
//  if(err?.details) payload.details=err.details;
//  res.status(status).json(payload);}
Object.defineProperty(exports, "__esModule", { value: true });
exports.notFound = notFound;
exports.errorHandler = errorHandler;
function notFound(_req, res) {
    res.status(404).json({ message: "Not found" });
}
function errorHandler(err, _req, res, _next) {
    console.error(err);
    const status = err?.status || 500;
    const message = err?.message || "Server error";
    res.status(status).json({ message });
}

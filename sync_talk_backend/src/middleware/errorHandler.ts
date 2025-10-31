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


// import { NextFunction, Request, Response } from 'express';
// import { HttpError } from '../errors/httpError.js';
// export function errorHandler(
//   err: any,
//   req: Request,
//   res: Response,
//   _next: NextFunction
// ) {
//   const requestId = req.headers['x-request-id'] || 
//                     `req_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;

//   const status = err instanceof HttpError ? err.status : 500;
//   const payload: any = {
//     error: err.message || 'Internal Server Error',
//     requestId,
//     timestamp: new Date().toISOString(),
//   };
//   if (err?.details) {
//     payload.details = err.details;
//   }

//   // Add validation errors if present (e.g., from Zod)
//   if (err?.errors) {
//     payload.errors = err.errors;
//   }

//    const isDevelopment = process.env.NODE_ENV !== 'production';
  
//   console.error(`\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
//   console.error(`❌ ERROR [${status}] - ${requestId}`);
//   console.error(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`);
//   console.error(`📍 Endpoint: ${req.method} ${req.path}`);
//   console.error(`👤 User: ${(req as any).user?.id || 'Anonymous'}`);
//   console.error(`🕐 Time: ${new Date().toISOString()}`);
//   console.error(`💬 Message: ${err.message}`);
  
//   // Log additional details if available
//   if (err.details) {
//     console.error(`📝 Details:`, err.details);
//   }
//     if (isDevelopment && err.stack) {
//     console.error(`📚 Stack Trace:`);
//     console.error(err.stack);
//   }
  
//   console.error(`━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n`);
// if (isDevelopment) {
//     payload.stack = err.stack;
//     payload.path = req.path;
//     payload.method = req.method;
//   }

//   // Send error response
//   res.status(status).json(payload);
// }
// export function notFoundHandler(req: Request, res: Response) {
//   const message = `Route ${req.method} ${req.path} not found`;
  
//   console.warn(`⚠️ 404 - ${message}`);
  
//   res.status(404).json({
//     error: message,
//     timestamp: new Date().toISOString(),
//     availableRoutes: [
//       '/health',
//       '/api/auth/*',
//       '/api/users/*',
//       '/api/conversations/*',
//       '/api/messages/*',
//       '/api/uploads/*',
//       '/api/ai/*',
//       '/api/audit/*',
//       '/api/docs',
//     ],
//   });
// }
// export function asyncHandler(fn: Function) {
//   return (req: Request, res: Response, next: NextFunction) => {
//     Promise.resolve(fn(req, res, next)).catch(next);
//   };
// }

import { Request, Response, NextFunction } from "express";

export function notFound(_req: Request, res: Response) {
  res.status(404).json({ message: "Not found" });
}

export function errorHandler(err: any, _req: Request, res: Response, _next: NextFunction) {
  console.error(err);
  const status = err?.status || 500;
  const message = err?.message || "Server error";
  res.status(status).json({ message });
}

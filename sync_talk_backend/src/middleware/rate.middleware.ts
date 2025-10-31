import rateLimit from "express-rate-limit";

export const authLimiter = rateLimit({
  windowMs: 10 * 60 * 1000,
  max: 20,
  message: "Too many attempts. Try again later.",
});

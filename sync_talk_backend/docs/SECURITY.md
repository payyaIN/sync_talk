
# Security
- **JWT** access (short TTL) + **refresh** (rotation + reuse detection)
- Helmet, CORS, rate‑limit; Zod for payload validation
- Passwords hashed (bcrypt); Google OAuth supported
- Uploads served from dedicated route with type checks
- Socket auth on namespaces; targeted emits for signaling

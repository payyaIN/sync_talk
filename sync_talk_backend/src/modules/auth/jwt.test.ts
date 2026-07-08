import { signAccess, signRefresh, verifyRefresh } from './jwt';
import jwt from 'jsonwebtoken';

describe('JWT Utilities', () => {
  const payload = { sub: 'test-user-id', email: 'test@example.com', role: 'user' };

  test('should sign a valid access token', () => {
    const token = signAccess(payload);
    expect(token).toBeDefined();
    expect(typeof token).toBe('string');
    
    // Verify token structure
    const decoded = jwt.decode(token) as any;
    expect(decoded.sub).toBe(payload.sub);
    expect(decoded.email).toBe(payload.email);
    expect(decoded.role).toBe(payload.role);
  });

  test('should sign a valid refresh token', () => {
    const token = signRefresh({ sub: payload.sub });
    expect(token).toBeDefined();
    expect(typeof token).toBe('string');
    
    const decoded = jwt.decode(token) as any;
    expect(decoded.sub).toBe(payload.sub);
  });

  test('should verify a valid refresh token', () => {
    const token = signRefresh({ sub: payload.sub });
    const verified = verifyRefresh(token) as any;
    expect(verified.sub).toBe(payload.sub);
  });

  test('should fail verifying an invalid token', () => {
    expect(() => {
      verifyRefresh('invalid-token-string');
    }).toThrow();
  });
});

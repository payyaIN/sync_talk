"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const jwt_1 = require("./jwt");
const jsonwebtoken_1 = __importDefault(require("jsonwebtoken"));
describe('JWT Utilities', () => {
    const payload = { sub: 'test-user-id', email: 'test@example.com', role: 'user' };
    test('should sign a valid access token', () => {
        const token = (0, jwt_1.signAccess)(payload);
        expect(token).toBeDefined();
        expect(typeof token).toBe('string');
        // Verify token structure
        const decoded = jsonwebtoken_1.default.decode(token);
        expect(decoded.sub).toBe(payload.sub);
        expect(decoded.email).toBe(payload.email);
        expect(decoded.role).toBe(payload.role);
    });
    test('should sign a valid refresh token', () => {
        const token = (0, jwt_1.signRefresh)({ sub: payload.sub });
        expect(token).toBeDefined();
        expect(typeof token).toBe('string');
        const decoded = jsonwebtoken_1.default.decode(token);
        expect(decoded.sub).toBe(payload.sub);
    });
    test('should verify a valid refresh token', () => {
        const token = (0, jwt_1.signRefresh)({ sub: payload.sub });
        const verified = (0, jwt_1.verifyRefresh)(token);
        expect(verified.sub).toBe(payload.sub);
    });
    test('should fail verifying an invalid token', () => {
        expect(() => {
            (0, jwt_1.verifyRefresh)('invalid-token-string');
        }).toThrow();
    });
});

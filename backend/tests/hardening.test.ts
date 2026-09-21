import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import express from 'express';
import request from 'supertest';
import { createApp } from '../src/server.js';
import { MemoryRateLimiter } from '../src/middleware/rate-limiter.middleware.js';
import { errorHandler } from '../src/middleware/error.middleware.js';
import { AppError } from '../src/utils/app-error.js';
import { env } from '../src/config/env.js';

describe('Phase 10: Backend Security & Hardening Tests', () => {
  let app: ReturnType<typeof createApp>;

  beforeEach(() => {
    app = createApp();
  });

  describe('Security Headers', () => {
    it('sets standard defensive HTTP security headers on all responses', async () => {
      const res = await request(app).get('/api/health');

      expect(res.status).toBe(200);
      expect(res.headers['x-content-type-options']).toBe('nosniff');
      expect(res.headers['x-frame-options']).toBe('DENY');
      expect(res.headers['x-xss-protection']).toBe('0');
      expect(res.headers['referrer-policy']).toBe('strict-origin-when-cross-origin');
      expect(res.headers['content-security-policy']).toBeDefined();
      expect(res.headers['x-powered-by']).toBeUndefined();
    });
  });

  describe('Rate Limiting', () => {
    it('enforces rate limit thresholds and returns 429 with Retry-After header', async () => {
      const testLimiter = new MemoryRateLimiter({
        windowMs: 5000,
        maxRequests: 3,
        message: 'Rate limit exceeded in test',
        skipInTest: false,
      });

      const expressApp = express();
      expressApp.get('/test-rate-limit', testLimiter.middleware(), (_req, res) => {
        res.json({ ok: true });
      });

      // Request 1: Allowed
      const res1 = await request(expressApp).get('/test-rate-limit');
      expect(res1.status).toBe(200);
      expect(res1.headers['x-ratelimit-remaining']).toBe('2');

      // Request 2: Allowed
      const res2 = await request(expressApp).get('/test-rate-limit');
      expect(res2.status).toBe(200);
      expect(res2.headers['x-ratelimit-remaining']).toBe('1');

      // Request 3: Allowed
      const res3 = await request(expressApp).get('/test-rate-limit');
      expect(res3.status).toBe(200);
      expect(res3.headers['x-ratelimit-remaining']).toBe('0');

      // Request 4: Throttled (429)
      const res4 = await request(expressApp).get('/test-rate-limit');
      expect(res4.status).toBe(429);
      expect(res4.headers['retry-after']).toBeDefined();
      expect(res4.body.error.code).toBe('TOO_MANY_REQUESTS');
      expect(res4.body.error.message).toBe('Rate limit exceeded in test');

      testLimiter.destroy();
    });
  });

  describe('CORS Enforcement', () => {
    it('allows mobile apps / server requests with null origin', async () => {
      const res = await request(app).get('/api/health');
      expect(res.status).toBe(200);
    });

    it('allows whitelisted origins configured in environment', async () => {
      const allowedOrigin = env.CORS_ORIGIN.split(',')[0].trim();
      const res = await request(app)
        .get('/api/health')
        .set('Origin', allowedOrigin);

      expect(res.status).toBe(200);
      expect(res.headers['access-control-allow-origin']).toBe(allowedOrigin);
    });
  });

  describe('Input Validation & Safe Error Responses', () => {
    it('rejects invalid search query limit with 400 and validation details', async () => {
      const res = await request(app).get('/api/search?q=rock&limit=-5');

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('VALIDATION_ERROR');
    });

    it('sanitizes potential credentials and token leaks from error messages', async () => {
      const errorApp = express();
      errorApp.get('/test-leak-error', (_req, _res, next) => {
        next(new AppError('Database failure with Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9 and client_id=secret_123', 500));
      });
      errorApp.use(errorHandler);

      const res = await request(errorApp).get('/test-leak-error');
      expect(res.status).toBe(500);
      expect(res.body.error.message).not.toContain('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9');
      expect(res.body.error.message).not.toContain('secret_123');
      expect(res.body.error.message).toContain('REDACTED');
    });

    it('rejects payloads larger than 1mb', async () => {
      // 1.5 MB payload
      const largePayload = 'a'.repeat(1.5 * 1024 * 1024);
      const res = await request(app)
        .post('/api/auth/login')
        .set('Content-Type', 'application/json')
        .send(`{"email":"test@melo.stream","password":"${largePayload}"}`);

      expect(res.status).toBe(413); // Payload Too Large
    });
  });
});

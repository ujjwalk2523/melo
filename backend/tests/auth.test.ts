import { describe, it, expect, beforeEach } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/server.js';
import { getCloudStore } from '../src/db/cloud-store.factory.js';
import { MemoryCloudStore } from '../src/db/memory-cloud-store.js';

describe('Phase 7: Backend Authentication & Profile API', () => {
  const app = createApp();
  const cloudStore = getCloudStore() as MemoryCloudStore;

  beforeEach(() => {
    if ('clear' in cloudStore) {
      cloudStore.clear();
    }
  });

  describe('POST /api/auth/register', () => {
    it('validates required fields, email format, and password length', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send({ email: 'bad-email', password: 'short', displayName: '' });

      expect(res.status).toBe(400);
      expect(res.body.error).toBe('Validation Error');
      expect(res.body.details).toBeDefined();
    });

    it('successfully registers a new user with hashed password and returns tokens', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send({
          email: 'alice@melo.stream',
          password: 'Password123!',
          displayName: 'Alice Explorer',
        });

      expect(res.status).toBe(201);
      expect(res.body.user).toBeDefined();
      expect(res.body.user.email).toBe('alice@melo.stream');
      expect(res.body.user.displayName).toBe('Alice Explorer');
      expect(res.body.tokens).toBeDefined();
      expect(res.body.tokens.accessToken).toBeDefined();
      expect(res.body.tokens.refreshToken).toBeDefined();
      expect(res.body.tokens.tokenType).toBe('Bearer');
      // Critical security: never return password or hash
      expect(res.body.user.password).toBeUndefined();
      expect(res.body.user.passwordHash).toBeUndefined();
    });

    it('rejects duplicate email registration with 409 Conflict', async () => {
      await request(app).post('/api/auth/register').send({
        email: 'bob@melo.stream',
        password: 'Password123!',
        displayName: 'Bob Original',
      });

      const duplicateRes = await request(app).post('/api/auth/register').send({
        email: 'BOB@melo.stream', // case-insensitive check
        password: 'AnotherPassword456!',
        displayName: 'Bob Duplicate',
      });

      expect(duplicateRes.status).toBe(409);
      expect(duplicateRes.body.error).toBe('Conflict');
    });
  });

  describe('POST /api/auth/login', () => {
    beforeEach(async () => {
      await request(app).post('/api/auth/register').send({
        email: 'carol@melo.stream',
        password: 'SecurePassword123!',
        displayName: 'Carol Synth',
      });
    });

    it('rejects invalid password with 401 Unauthorized', async () => {
      const res = await request(app).post('/api/auth/login').send({
        email: 'carol@melo.stream',
        password: 'WrongPassword!',
      });

      expect(res.status).toBe(401);
      expect(res.body.message).toContain('Invalid email or password');
    });

    it('rejects non-existent email with 401 Unauthorized', async () => {
      const res = await request(app).post('/api/auth/login').send({
        email: 'nonexistent@melo.stream',
        password: 'SecurePassword123!',
      });

      expect(res.status).toBe(401);
      expect(res.body.message).toContain('Invalid email or password');
    });

    it('successfully logs in with valid credentials and returns tokens', async () => {
      const res = await request(app).post('/api/auth/login').send({
        email: 'carol@melo.stream',
        password: 'SecurePassword123!',
      });

      expect(res.status).toBe(200);
      expect(res.body.user.email).toBe('carol@melo.stream');
      expect(res.body.user.displayName).toBe('Carol Synth');
      expect(res.body.tokens.accessToken).toBeDefined();
      expect(res.body.tokens.refreshToken).toBeDefined();
    });
  });

  describe('POST /api/auth/refresh', () => {
    it('successfully refreshes token given a valid refresh token', async () => {
      const reg = await request(app).post('/api/auth/register').send({
        email: 'dan@melo.stream',
        password: 'Password123!',
        displayName: 'Dan LoFi',
      });

      const refreshToken = reg.body.tokens.refreshToken;

      const refreshRes = await request(app)
        .post('/api/auth/refresh')
        .send({ refreshToken });

      expect(refreshRes.status).toBe(200);
      expect(refreshRes.body.tokens.accessToken).toBeDefined();
      expect(refreshRes.body.tokens.refreshToken).toBeDefined();
    });

    it('rejects invalid refresh tokens with 401 Unauthorized', async () => {
      const res = await request(app)
        .post('/api/auth/refresh')
        .send({ refreshToken: 'invalid.token.here' });

      expect(res.status).toBe(401);
      expect(res.body.error).toBe('Unauthorized');
    });
  });

  describe('POST /api/auth/forgot-password', () => {
    it('returns generic confirmation message without revealing if email exists', async () => {
      const res = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: 'anyuser@example.com' });

      expect(res.status).toBe(200);
      expect(res.body.message).toBe(
        'If an account exists for this email, a password reset link has been sent.'
      );
    });
  });

  describe('Protected Profile & Account Deletion: /api/auth/me', () => {
    let accessToken: string;
    let userId: string;

    beforeEach(async () => {
      const reg = await request(app).post('/api/auth/register').send({
        email: 'eva@melo.stream',
        password: 'Password123!',
        displayName: 'Eva Producer',
      });
      accessToken = reg.body.tokens.accessToken;
      userId = reg.body.user.id;
    });

    it('rejects unauthenticated request without token with 401', async () => {
      const res = await request(app).get('/api/auth/me');
      expect(res.status).toBe(401);
      expect(res.body.error).toBe('Unauthorized');
    });

    it('rejects request with malformed Authorization header', async () => {
      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', 'Basic 12345');
      expect(res.status).toBe(401);
    });

    it('returns current profile for authenticated user via GET /api/auth/me', async () => {
      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(res.status).toBe(200);
      expect(res.body.id).toBe(userId);
      expect(res.body.email).toBe('eva@melo.stream');
      expect(res.body.displayName).toBe('Eva Producer');
    });

    it('updates display name via PATCH /api/auth/me', async () => {
      const res = await request(app)
        .patch('/api/auth/me')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ displayName: 'Eva New Name' });

      expect(res.status).toBe(200);
      expect(res.body.displayName).toBe('Eva New Name');

      // Verify persistence on subsequent GET
      const getRes = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${accessToken}`);
      expect(getRes.body.displayName).toBe('Eva New Name');
    });

    it('deletes account and revokes access via DELETE /api/auth/me', async () => {
      const deleteRes = await request(app)
        .delete('/api/auth/me')
        .set('Authorization', `Bearer ${accessToken}`);

      expect(deleteRes.status).toBe(200);
      expect(deleteRes.body.message).toContain('deleted successfully');

      // Next request with same token fails because user is gone
      const nextRes = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${accessToken}`);
      expect(nextRes.status).toBe(404);
    });
  });
});

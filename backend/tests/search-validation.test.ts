import { describe, it, expect } from 'vitest';
import request from 'supertest';
import { app } from '../src/server.js';

describe('Search Validation API', () => {
  it('should return 400 when query is missing', async () => {
    const res = await request(app).get('/api/search');
    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('EMPTY_QUERY');
  });

  it('should return 400 when query is only whitespace', async () => {
    const res = await request(app).get('/api/search?q=%20%20%20');
    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('EMPTY_QUERY');
  });

  it('should return 400 when query exceeds 100 characters', async () => {
    const longQuery = 'a'.repeat(101);
    const res = await request(app).get(`/api/search?q=${longQuery}`);
    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('QUERY_TOO_LONG');
  });

  it('should return 400 when requested provider is unknown', async () => {
    const res = await request(app).get('/api/search?q=ambient&provider=spotify_unauthorized');
    expect(res.status).toBe(400);
    expect(res.body.success).toBe(false);
    expect(res.body.error.code).toBe('INVALID_PROVIDER');
  });
});

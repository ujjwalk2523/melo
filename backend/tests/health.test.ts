import { describe, it, expect } from 'vitest';
import request from 'supertest';
import { app } from '../src/server.js';

describe('Health Check API', () => {
  it('GET /api/health should return 200 with service information', async () => {
    const response = await request(app).get('/api/health');

    expect(response.status).toBe(200);
    expect(response.body).toMatchObject({
      success: true,
      service: 'melo-api',
      status: 'healthy',
    });
    expect(response.body.timestamp).toBeDefined();
  });

  it('GET /api/unknown-route should return 404', async () => {
    const response = await request(app).get('/api/unknown-route');

    expect(response.status).toBe(404);
    expect(response.body.success).toBe(false);
    expect(response.body.error.code).toBe('ROUTE_NOT_FOUND');
  });
});

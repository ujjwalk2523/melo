import express, { Express } from 'express';
import cors from 'cors';
import { env } from './config/env.js';
import { ProviderRegistry } from './services/provider-registry.js';
import { MusicService } from './services/music.service.js';
import { healthRouter } from './routes/health.routes.js';
import { createSearchRouter } from './routes/search.routes.js';
import { createTrackRouter } from './routes/track.routes.js';
import { errorHandler } from './middleware/error.middleware.js';
import { notFoundHandler } from './middleware/not-found.middleware.js';

import { getCloudStore } from './db/cloud-store.factory.js';
import { AuthService } from './auth/auth.service.js';
import { SyncService } from './sync/sync.service.js';
import { createAuthRouter } from './routes/auth.routes.js';
import { createSyncRouter } from './routes/sync.routes.js';

export function createApp(): Express {
  const app = express();

  // Configure CORS
  const allowedOrigins = env.CORS_ORIGIN.split(',').map((o) => o.trim());
  app.use(
    cors({
      origin: (origin, callback) => {
        // Allow mobile apps, curl, server-to-server (no Origin header)
        if (!origin) return callback(null, true);
        if (allowedOrigins.includes(origin) || allowedOrigins.includes('*')) {
          return callback(null, true);
        }
        return callback(null, true); // Permissive in dev mode for local emulator testing
      },
      methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    })
  );

  app.use(express.json());

  // Instantiate services
  const registry = new ProviderRegistry();
  const musicService = new MusicService(registry);
  const cloudStore = getCloudStore();
  const authService = new AuthService(cloudStore);
  const syncService = new SyncService(cloudStore);

  // Mount API routers
  app.use('/api', healthRouter);
  app.use('/api', createSearchRouter(musicService));
  app.use('/api', createTrackRouter(musicService));
  app.use('/api', createAuthRouter(authService));
  app.use('/api', createSyncRouter(syncService, authService));

  // 404 and error handlers
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
}

export const app = createApp();

if (process.env.NODE_ENV !== 'test') {
  const server = app.listen(env.PORT, () => {
    console.log(`🎵 Melo Music Backend running on port ${env.PORT} [${env.NODE_ENV}]`);
    console.log(`🔗 Health check available at http://localhost:${env.PORT}/api/health`);
  });

  process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
      console.log('HTTP server closed');
    });
  });
}

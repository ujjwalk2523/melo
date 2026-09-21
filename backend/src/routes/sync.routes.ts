import { Router } from 'express';
import { SyncController } from '../controllers/sync.controller.js';
import { SyncService } from '../sync/sync.service.js';
import { AuthService } from '../auth/auth.service.js';
import { createAuthMiddleware } from '../auth/auth.middleware.js';

export function createSyncRouter(syncService: SyncService, authService: AuthService): Router {
  const router = Router();
  const controller = new SyncController(syncService);
  const requireAuth = createAuthMiddleware(authService);

  // All sync endpoints require verified authentication
  router.get('/sync/state', requireAuth, controller.pull);
  router.post('/sync/pull', requireAuth, controller.pull);
  router.post('/sync/push', requireAuth, controller.push);
  router.post('/sync', requireAuth, controller.sync);

  return router;
}

import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller.js';
import { AuthService } from '../auth/auth.service.js';
import { createAuthMiddleware } from '../auth/auth.middleware.js';

export function createAuthRouter(authService: AuthService): Router {
  const router = Router();
  const controller = new AuthController(authService);
  const requireAuth = createAuthMiddleware(authService);

  // Public authentication endpoints
  router.post('/auth/register', controller.register);
  router.post('/auth/login', controller.login);
  router.post('/auth/refresh', controller.refresh);
  router.post('/auth/logout', controller.logout);
  router.post('/auth/forgot-password', controller.forgotPassword);

  // Protected user identity and profile endpoints
  router.get('/auth/me', requireAuth, controller.getMe);
  router.patch('/auth/me', requireAuth, controller.updateMe);
  router.delete('/auth/me', requireAuth, controller.deleteMe);

  // Profile alias endpoints
  router.get('/profile', requireAuth, controller.getMe);
  router.patch('/profile', requireAuth, controller.updateMe);

  return router;
}

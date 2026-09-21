import { Request, Response, NextFunction } from 'express';
import { AuthService } from './auth.service.js';

export interface AuthenticatedRequest extends Request {
  user?: {
    userId: string;
    email: string;
  };
}

export function createAuthMiddleware(authService: AuthService) {
  return (req: AuthenticatedRequest, res: Response, next: NextFunction): void => {
    const authHeader = req.headers.authorization;
    if (!authHeader) {
      res.status(401).json({
        error: 'Unauthorized',
        message: 'Missing Authorization header. Expected Bearer token.',
      });
      return;
    }

    const parts = authHeader.split(' ');
    if (parts.length !== 2 || parts[0].toLowerCase() !== 'bearer') {
      res.status(401).json({
        error: 'Unauthorized',
        message: 'Malformed Authorization header. Format: Bearer <token>',
      });
      return;
    }

    const token = parts[1];
    try {
      const payload = authService.verifyToken(token, 'access');
      req.user = {
        userId: payload.userId,
        email: payload.email,
      };
      next();
    } catch (err: any) {
      res.status(401).json({
        error: 'Unauthorized',
        message: err.message || 'Invalid or expired token',
      });
    }
  };
}

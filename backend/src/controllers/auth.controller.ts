import { Response } from 'express';
import { z } from 'zod';
import { AuthService } from '../auth/auth.service.js';
import { AuthenticatedRequest } from '../auth/auth.middleware.js';

const registerSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters long'),
  displayName: z.string().min(1, 'Display name cannot be empty').max(50),
});

const loginSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
  password: z.string().min(1, 'Password is required'),
});

const refreshSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

const forgotPasswordSchema = z.object({
  email: z.string().email('Please enter a valid email address'),
});

const updateProfileSchema = z.object({
  displayName: z.string().min(1).max(50).optional(),
  avatarUrl: z.string().url().nullable().optional(),
});

export class AuthController {
  constructor(private authService: AuthService) {}

  register = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
    try {
      const parsed = registerSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({
          error: 'Validation Error',
          details: parsed.error.flatten().fieldErrors,
        });
        return;
      }

      const result = await this.authService.register(parsed.data);
      res.status(201).json(result);
    } catch (err: any) {
      const status = err.statusCode || 500;
      res.status(status).json({
        error: status === 409 ? 'Conflict' : 'Registration Failed',
        message: err.message,
      });
    }
  };

  login = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
    try {
      const parsed = loginSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({
          error: 'Validation Error',
          details: parsed.error.flatten().fieldErrors,
        });
        return;
      }

      const result = await this.authService.login(parsed.data);
      res.status(200).json(result);
    } catch (err: any) {
      const status = err.statusCode || 500;
      res.status(status).json({
        error: status === 401 ? 'Unauthorized' : 'Login Failed',
        message: err.message,
      });
    }
  };

  refresh = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
    try {
      const parsed = refreshSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({
          error: 'Validation Error',
          details: parsed.error.flatten().fieldErrors,
        });
        return;
      }

      const tokens = await this.authService.refreshTokens(parsed.data.refreshToken);
      res.status(200).json({ tokens });
    } catch (err: any) {
      res.status(401).json({
        error: 'Unauthorized',
        message: err.message || 'Token refresh failed',
      });
    }
  };

  logout = async (_req: AuthenticatedRequest, res: Response): Promise<void> => {
    // Client clears secure tokens; server confirms successful session termination
    res.status(200).json({ message: 'Logged out successfully' });
  };

  forgotPassword = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
    try {
      const parsed = forgotPasswordSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({
          error: 'Validation Error',
          details: parsed.error.flatten().fieldErrors,
        });
        return;
      }

      const result = await this.authService.forgotPassword(parsed.data.email);
      res.status(200).json(result);
    } catch (err: any) {
      res.status(500).json({ error: 'Server Error', message: err.message });
    }
  };

  getMe = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }

      const profile = await this.authService.getProfile(userId);
      res.status(200).json(profile);
    } catch (err: any) {
      const status = err.statusCode || 500;
      res.status(status).json({ error: 'Failed to fetch user profile', message: err.message });
    }
  };

  updateMe = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }

      const parsed = updateProfileSchema.safeParse(req.body);
      if (!parsed.success) {
        res.status(400).json({
          error: 'Validation Error',
          details: parsed.error.flatten().fieldErrors,
        });
        return;
      }

      const updated = await this.authService.updateProfile(userId, parsed.data);
      res.status(200).json(updated);
    } catch (err: any) {
      const status = err.statusCode || 500;
      res.status(status).json({ error: 'Failed to update profile', message: err.message });
    }
  };

  deleteMe = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
    try {
      const userId = req.user?.userId;
      if (!userId) {
        res.status(401).json({ error: 'Unauthorized' });
        return;
      }

      await this.authService.deleteAccount(userId);
      res.status(200).json({ message: 'Account and associated cloud data deleted successfully' });
    } catch (err: any) {
      const status = err.statusCode || 500;
      res.status(status).json({ error: 'Failed to delete account', message: err.message });
    }
  };
}

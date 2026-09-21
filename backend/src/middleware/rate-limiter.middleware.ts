import { Request, Response, NextFunction } from 'express';

interface RateLimitRecord {
  count: number;
  resetTime: number;
}

interface RateLimiterOptions {
  windowMs: number;
  maxRequests: number;
  message?: string;
  skipInTest?: boolean;
}

/**
 * Lightweight, zero-dependency in-memory sliding-window rate limiter.
 */
export class MemoryRateLimiter {
  private clients = new Map<string, RateLimitRecord>();
  private cleanupTimer: NodeJS.Timeout | null = null;

  constructor(private options: RateLimiterOptions) {
    // Periodically sweep expired clients every 60s
    this.cleanupTimer = setInterval(() => this.cleanup(), 60000);
    if (this.cleanupTimer.unref) {
      this.cleanupTimer.unref();
    }
  }

  private cleanup(): void {
    const now = Date.now();
    for (const [key, record] of this.clients.entries()) {
      if (now > record.resetTime) {
        this.clients.delete(key);
      }
    }
  }

  public reset(): void {
    this.clients.clear();
  }

  public destroy(): void {
    if (this.cleanupTimer) {
      clearInterval(this.cleanupTimer);
      this.cleanupTimer = null;
    }
    this.clients.clear();
  }

  public middleware() {
    return (req: Request, res: Response, next: NextFunction): void => {
      // Allow skipping in test environment if configured
      if (this.options.skipInTest && process.env.NODE_ENV === 'test') {
        return next();
      }

      // Extract client IP / identifier
      const ip =
        (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() ||
        req.socket.remoteAddress ||
        '127.0.0.1';

      const now = Date.now();
      const record = this.clients.get(ip);

      if (!record || now > record.resetTime) {
        // Initial window
        this.clients.set(ip, {
          count: 1,
          resetTime: now + this.options.windowMs,
        });
        res.setHeader('X-RateLimit-Limit', this.options.maxRequests);
        res.setHeader('X-RateLimit-Remaining', this.options.maxRequests - 1);
        return next();
      }

      record.count++;
      const remaining = Math.max(0, this.options.maxRequests - record.count);
      const retryAfterSeconds = Math.ceil((record.resetTime - now) / 1000);

      res.setHeader('X-RateLimit-Limit', this.options.maxRequests);
      res.setHeader('X-RateLimit-Remaining', remaining);

      if (record.count > this.options.maxRequests) {
        res.setHeader('Retry-After', retryAfterSeconds);
        res.status(429).json({
          success: false,
          error: {
            code: 'TOO_MANY_REQUESTS',
            message:
              this.options.message ||
              'Too many requests. Please slow down and try again later.',
            statusCode: 429,
          },
        });
        return;
      }

      next();
    };
  }
}

// Pre-configured rate limiters for different endpoint sensitivity tiers
export const generalRateLimiter = new MemoryRateLimiter({
  windowMs: 60 * 1000, // 1 minute
  maxRequests: 120, // 120 reqs/min
  message: 'Too many API requests. Please wait a moment before retrying.',
  skipInTest: true,
});

export const authRateLimiter = new MemoryRateLimiter({
  windowMs: 60 * 1000, // 1 minute
  maxRequests: 20, // 20 attempts/min
  message: 'Too many authentication attempts. Please try again in one minute.',
  skipInTest: true,
});

export const downloadInfoRateLimiter = new MemoryRateLimiter({
  windowMs: 60 * 1000,
  maxRequests: 30,
  message: 'Too many download requests. Please wait a moment before retrying.',
  skipInTest: true,
});

import { Request, Response, NextFunction } from 'express';
import { env } from '../config/env.js';

/**
 * Production-grade HTTP security headers middleware.
 * Enforces defense-in-depth against MIME sniffing, clickjacking, and XSS.
 */
export function securityHeaders(_req: Request, res: Response, next: NextFunction): void {
  // Prevent browser from MIME-sniffing response content-type
  res.setHeader('X-Content-Type-Options', 'nosniff');

  // Prevent clickjacking by denying iframe embedding
  res.setHeader('X-Frame-Options', 'DENY');

  // Modern XSS protection header
  res.setHeader('X-XSS-Protection', '0');

  // Strict Referrer policy
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');

  // Restrict REST API resource loading and execution
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'none'; frame-ancestors 'none'; base-uri 'none';"
  );

  // Enforce HTTPS in production via HSTS
  if (env.NODE_ENV === 'production') {
    res.setHeader(
      'Strict-Transport-Security',
      'max-age=31536000; includeSubDomains; preload'
    );
  }

  // Remove Express fingerprint header
  res.removeHeader('X-Powered-By');

  next();
}

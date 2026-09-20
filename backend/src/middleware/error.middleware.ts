import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error.js';
import { env } from '../config/env.js';

export function errorHandler(
  err: Error | AppError,
  _req: Request,
  res: Response,
  _next: NextFunction
): void {
  const isAppError = err instanceof AppError;
  const statusCode = isAppError ? err.statusCode : 500;
  const code = isAppError ? err.code : 'INTERNAL_SERVER_ERROR';

  // Sanitize message: never leak sensitive information
  let message = err.message || 'An unexpected error occurred';
  if (statusCode === 500 && env.NODE_ENV === 'production') {
    message = 'An internal server error occurred';
  }

  // Remove potential token or credential leaks from error message
  message = message.replace(/client_id=[^&\s]+/gi, 'client_id=REDACTED');
  message = message.replace(/api_key=[^&\s]+/gi, 'api_key=REDACTED');

  if (env.NODE_ENV !== 'test' && statusCode >= 500) {
    console.error(`[ERROR ${statusCode}]:`, err);
  }

  res.status(statusCode).json({
    success: false,
    error: {
      code,
      message,
      statusCode,
    },
  });
}

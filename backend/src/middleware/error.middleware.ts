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
  const anyErr = err as any;
  const statusCode = isAppError ? err.statusCode : anyErr.status || anyErr.statusCode || 500;
  const code = isAppError
    ? err.code
    : anyErr.type === 'entity.too.large'
    ? 'PAYLOAD_TOO_LARGE'
    : 'INTERNAL_SERVER_ERROR';

  // Sanitize message: never leak sensitive information
  let message = err.message || 'An unexpected error occurred';
  if (statusCode === 500 && env.NODE_ENV === 'production') {
    message = 'An internal server error occurred';
  }

  // Remove potential token, credential, or connection string leaks from error message
  message = message.replace(/client_id=[^&\s]+/gi, 'client_id=REDACTED');
  message = message.replace(/api_key=[^&\s]+/gi, 'api_key=REDACTED');
  message = message.replace(/Bearer\s+[A-Za-z0-9\-\._~\+\/]+=*/gi, 'Bearer REDACTED');
  message = message.replace(/password=[^&\s]+/gi, 'password=REDACTED');
  message = message.replace(/postgres(ql)?:\/\/[^\s]+/gi, 'postgres://REDACTED');
  message = message.replace(/https:\/\/[a-zA-Z0-9\-_.]+\.supabase\.co/gi, 'https://REDACTED.supabase.co');

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

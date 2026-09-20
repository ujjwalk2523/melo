/**
 * Centralized application error class.
 */
export class AppError extends Error {
  public readonly statusCode: number;
  public readonly isOperational: boolean;
  public readonly code?: string;

  constructor(message: string, statusCode = 500, code?: string) {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.isOperational = true;

    Object.setPrototypeOf(this, new.target.prototype);
    Error.captureStackTrace(this, this.constructor);
  }

  static badRequest(message: string, code = 'BAD_REQUEST'): AppError {
    return new AppError(message, 400, code);
  }

  static notFound(message: string, code = 'NOT_FOUND'): AppError {
    return new AppError(message, 404, code);
  }

  static rateLimit(message = 'Provider rate limit reached. Please try again later.', code = 'RATE_LIMIT'): AppError {
    return new AppError(message, 429, code);
  }

  static providerError(message: string, statusCode = 502, code = 'PROVIDER_ERROR'): AppError {
    return new AppError(message, statusCode, code);
  }

  static internal(message = 'An unexpected internal server error occurred', code = 'INTERNAL_ERROR'): AppError {
    return new AppError(message, 500, code);
  }
}

import { Request, Response, NextFunction } from 'express';
import { AppError } from '../utils/app-error.js';

export function notFoundHandler(req: Request, _res: Response, next: NextFunction): void {
  next(AppError.notFound(`Route '${req.method} ${req.originalUrl}' not found`, 'ROUTE_NOT_FOUND'));
}

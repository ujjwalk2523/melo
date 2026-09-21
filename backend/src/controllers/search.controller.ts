import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { MusicService } from '../services/music.service.js';

const searchQuerySchema = z.object({
  q: z.string().default(''),
  provider: z.string().optional(),
  limit: z.coerce.number().int().min(1).max(100).optional(),
});

export function createSearchController(musicService: MusicService) {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const parsed = searchQuerySchema.safeParse(req.query);
      if (!parsed.success) {
        res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'Invalid search query parameters',
            details: parsed.error.flatten().fieldErrors,
          },
        });
        return;
      }

      const { q, provider, limit } = parsed.data;
      const results = await musicService.search(q, provider, { limit });

      res.status(200).json({
        success: true,
        query: results.query,
        provider: results.provider,
        totalResults: results.totalResults,
        results: results.results,
      });
    } catch (error) {
      next(error);
    }
  };
}

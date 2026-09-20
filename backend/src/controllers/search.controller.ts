import { Request, Response, NextFunction } from 'express';
import { MusicService } from '../services/music.service.js';

export function createSearchController(musicService: MusicService) {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
      const q = typeof req.query.q === 'string' ? req.query.q : '';
      const provider = typeof req.query.provider === 'string' ? req.query.provider : undefined;
      const limit = typeof req.query.limit === 'string' ? parseInt(req.query.limit, 10) : undefined;

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

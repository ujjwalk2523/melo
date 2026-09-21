import { Request, Response, NextFunction } from 'express';
import { MusicService } from '../services/music.service.js';

export function createRecommendationController(musicService: MusicService) {
  return {
    getTrending: async (req: Request, res: Response, next: NextFunction): Promise<void> => {
      try {
        const provider = req.query.provider ? String(req.query.provider) : undefined;
        const limit = req.query.limit ? Math.min(Math.max(1, parseInt(String(req.query.limit), 10) || 20), 50) : 20;

        const songs = await musicService.getTrending(provider, limit);

        res.status(200).json({
          success: true,
          data: {
            songs,
            count: songs.length,
          },
        });
      } catch (error) {
        next(error);
      }
    },

    getDiscover: async (req: Request, res: Response, next: NextFunction): Promise<void> => {
      try {
        const genresParam = req.query.genres ? String(req.query.genres) : undefined;
        const genres = genresParam ? genresParam.split(',').map((g) => g.trim()).filter(Boolean) : undefined;
        const limit = req.query.limit ? Math.min(Math.max(1, parseInt(String(req.query.limit), 10) || 20), 50) : 20;

        const songs = await musicService.getDiscover(genres, limit);

        res.status(200).json({
          success: true,
          data: {
            songs,
            count: songs.length,
          },
        });
      } catch (error) {
        next(error);
      }
    },
  };
}

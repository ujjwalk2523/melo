import { Request, Response, NextFunction } from 'express';
import { MusicService } from '../services/music.service.js';

export function createTrackController(musicService: MusicService) {
  return {
    getTrack: async (req: Request, res: Response, next: NextFunction): Promise<void> => {
      try {
        const { provider, trackId } = req.params;
        const song = await musicService.getTrack(provider, trackId);

        res.status(200).json({
          success: true,
          data: song,
        });
      } catch (error) {
        next(error);
      }
    },

    getStream: async (req: Request, res: Response, next: NextFunction): Promise<void> => {
      try {
        const { provider, trackId } = req.params;
        const stream = await musicService.getStream(provider, trackId);

        res.status(200).json({
          success: true,
          data: stream,
        });
      } catch (error) {
        next(error);
      }
    },
  };
}

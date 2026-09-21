import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { MusicService } from '../services/music.service.js';

const trackParamSchema = z.object({
  provider: z.string().min(1).max(50),
  trackId: z.string().min(1).max(200),
});

export function createTrackController(musicService: MusicService) {
  return {
    getTrack: async (req: Request, res: Response, next: NextFunction): Promise<void> => {
      try {
        const parsed = trackParamSchema.safeParse(req.params);
        if (!parsed.success) {
          res.status(400).json({
            success: false,
            error: {
              code: 'VALIDATION_ERROR',
              message: 'Invalid provider or trackId parameter',
            },
          });
          return;
        }

        const { provider, trackId } = parsed.data;
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

    getDownloadInfo: async (req: Request, res: Response, next: NextFunction): Promise<void> => {
      try {
        const { provider, trackId } = req.params;
        const song = await musicService.getTrack(provider, trackId);

        if (!song) {
          res.status(404).json({
            success: false,
            error: {
              code: 'TRACK_NOT_FOUND',
              message: `Track not found: ${provider}:${trackId}`,
            },
          });
          return;
        }

        res.status(200).json({
          success: true,
          data: {
            provider,
            trackId: song.providerTrackId || trackId,
            songId: song.id,
            title: song.title,
            artist: song.artist,
            isDownloadable: song.isDownloadable,
            downloadUrl: song.downloadUrl || null,
            expiresAt: null,
            restrictions: song.isDownloadable
              ? null
              : 'Provider does not authorize offline downloading for this track',
          },
        });
      } catch (error) {
        next(error);
      }
    },
  };
}

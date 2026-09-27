import axios from 'axios';
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

    streamAudio: async (req: Request, res: Response, next: NextFunction): Promise<void> => {
      try {
        const { provider, trackId } = req.params;
        const cleanId = trackId.replace(/^audius:/, '');

        let targetUrl: string;
        if (provider === 'audius') {
          targetUrl = `https://api.audius.co/v1/tracks/${cleanId}/stream?app_name=melo_app`;
        } else {
          const streamInfo = await musicService.getStream(provider, cleanId);
          targetUrl = streamInfo.url;
        }

        const headers: Record<string, string> = {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)',
        };
        if (req.headers.range) {
          headers['range'] = req.headers.range as string;
        }

        const upstream = await axios.get(targetUrl, {
          headers,
          responseType: 'stream',
          maxRedirects: 5,
          validateStatus: (status) => status >= 200 && status < 400,
        });

        res.status(upstream.status);
        res.setHeader('content-type', String(upstream.headers['content-type'] || 'audio/mpeg'));
        if (upstream.headers['content-length']) {
          res.setHeader('content-length', String(upstream.headers['content-length']));
        }
        if (upstream.headers['content-range']) {
          res.setHeader('content-range', String(upstream.headers['content-range']));
        }
        res.setHeader('accept-ranges', String(upstream.headers['accept-ranges'] || 'bytes'));

        upstream.data.pipe(res);
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

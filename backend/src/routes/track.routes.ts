import { Router } from 'express';
import { createTrackController } from '../controllers/track.controller.js';
import { MusicService } from '../services/music.service.js';
import { downloadInfoRateLimiter } from '../middleware/rate-limiter.middleware.js';

export function createTrackRouter(musicService: MusicService): Router {
  const router = Router();
  const trackController = createTrackController(musicService);

  router.get('/tracks/:provider/:trackId', trackController.getTrack);
  router.get('/tracks/:provider/:trackId/stream', trackController.getStream);
  router.get(
    '/tracks/:provider/:trackId/download-info',
    downloadInfoRateLimiter.middleware(),
    trackController.getDownloadInfo
  );

  return router;
}

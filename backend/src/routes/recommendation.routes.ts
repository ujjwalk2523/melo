import { Router } from 'express';
import { createRecommendationController } from '../controllers/recommendation.controller.js';
import { MusicService } from '../services/music.service.js';

export function createRecommendationRouter(musicService: MusicService): Router {
  const router = Router();
  const controller = createRecommendationController(musicService);

  router.get('/recommendations/trending', controller.getTrending);
  router.get('/recommendations/discover', controller.getDiscover);

  return router;
}

import { Router } from 'express';
import { createSearchController } from '../controllers/search.controller.js';
import { MusicService } from '../services/music.service.js';

export function createSearchRouter(musicService: MusicService): Router {
  const router = Router();
  const searchController = createSearchController(musicService);

  router.get('/search', searchController);

  return router;
}

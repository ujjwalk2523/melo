import { describe, it, expect, beforeEach } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/server.js';
import { MusicService } from '../src/services/music.service.js';
import { ProviderRegistry } from '../src/services/provider-registry.js';
import { MusicProvider } from '../src/providers/music-provider.interface.js';
import { Song, SearchResult } from '../src/types/music.js';

class MockProvider implements MusicProvider {
  name = 'mock';

  async search(query: string, options?: { limit?: number }): Promise<SearchResult> {
    const limit = options?.limit ?? 10;
    const songs: Song[] = [];
    for (let i = 1; i <= limit; i++) {
      songs.push({
        id: `mock_${query}_${i}`,
        title: `Track ${i} for ${query}`,
        artist: `Artist ${i}`,
        album: `Album ${i}`,
        durationSeconds: 180 + i,
        provider: 'mock',
        isDownloadable: true,
        explicit: false,
      });
    }
    return { results: songs, totalResults: songs.length, query, provider: 'mock' };
  }

  async getTrack(trackId: string): Promise<Song | null> {
    return {
      id: trackId,
      title: 'Mock Title',
      artist: 'Mock Artist',
      album: 'Mock Album',
      durationSeconds: 200,
      provider: 'mock',
      isDownloadable: true,
    };
  }
}

describe('Phase 9: Backend Recommendation Endpoints', () => {
  let app: any;
  let mockService: MusicService;

  beforeEach(() => {
    const registry = new ProviderRegistry();
    registry.register(new MockProvider());
    registry.setDefault('mock');
    mockService = new MusicService(registry);
    app = createApp(mockService);
  });

  describe('GET /api/recommendations/trending', () => {
    it('returns trending songs successfully', async () => {
      const response = await request(app).get('/api/recommendations/trending');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.songs).toBeInstanceOf(Array);
      expect(response.body.data.songs.length).toBeGreaterThan(0);
      expect(response.body.data.count).toBe(response.body.data.songs.length);
    });

    it('respects the limit query parameter', async () => {
      const response = await request(app).get('/api/recommendations/trending?limit=5');

      expect(response.status).toBe(200);
      expect(response.body.data.songs.length).toBe(5);
      expect(response.body.data.count).toBe(5);
    });

    it('clamps negative or out-of-bounds limit parameters safely', async () => {
      const response = await request(app).get('/api/recommendations/trending?limit=-10');

      expect(response.status).toBe(200);
      expect(response.body.data.songs.length).toBe(1);
    });
  });

  describe('GET /api/recommendations/discover', () => {
    it('returns discovery songs successfully', async () => {
      const response = await request(app).get('/api/recommendations/discover');

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data.songs).toBeInstanceOf(Array);
      expect(response.body.data.count).toBe(response.body.data.songs.length);
    });

    it('filters discovery tracks based on specified genre queries', async () => {
      const response = await request(app).get('/api/recommendations/discover?genres=synthwave,electronic');

      expect(response.status).toBe(200);
      expect(response.body.data.songs[0].id).toContain('synthwave');
    });

    it('respects the limit query parameter for discovery', async () => {
      const response = await request(app).get('/api/recommendations/discover?limit=3');

      expect(response.status).toBe(200);
      expect(response.body.data.songs.length).toBe(3);
    });
  });
});

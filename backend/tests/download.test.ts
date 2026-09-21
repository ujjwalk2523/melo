import { describe, it, expect, beforeEach } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/server.js';
import { AudiusProvider } from '../src/providers/audius/audius.provider.js';
import { JamendoProvider } from '../src/providers/jamendo/jamendo.provider.js';
import { ProviderRegistry } from '../src/services/provider-registry.js';
import { MusicService } from '../src/services/music.service.js';

describe('Phase 8: Download Info & Provider Authorization', () => {
  let app: any;

  beforeEach(() => {
    app = createApp();
  });

  describe('Audius Provider Download Authorization', () => {
    it('normalizes downloadable track when provider explicitly permits it', () => {
      const provider = new AudiusProvider('https://discoveryprovider.audius.co', 'melo-test');
      const normalized = provider.normalizeTrack({
        id: 'track_auth_1',
        title: 'Authorized Track',
        duration: 210,
        is_downloadable: true,
        download: { cid: 'QmExampleCid123' },
        user: { id: 'u_1', name: 'Audius Creator' },
      });

      expect(normalized.isDownloadable).toBe(true);
      expect(normalized.downloadUrl).toBeDefined();
      expect(normalized.downloadUrl).toContain('/v1/tracks/track_auth_1/download');
      expect(normalized.downloadUrl).toContain('app_name=melo-test');
    });

    it('rejects download when is_downloadable is false or download is null', () => {
      const provider = new AudiusProvider('https://discoveryprovider.audius.co', 'melo-test');
      
      const unauth1 = provider.normalizeTrack({
        id: 'track_unauth_1',
        title: 'Restricted Track',
        is_downloadable: false,
        download: null,
      });
      expect(unauth1.isDownloadable).toBe(false);
      expect(unauth1.downloadUrl).toBeUndefined();

      const unauth2 = provider.normalizeTrack({
        id: 'track_unauth_2',
        title: 'Missing Download Object',
        is_downloadable: true,
        download: null,
      });
      expect(unauth2.isDownloadable).toBe(false);
      expect(unauth2.downloadUrl).toBeUndefined();
    });
  });

  describe('Jamendo Provider Download Authorization', () => {
    it('normalizes downloadable track when audiodownload_allowed is true', () => {
      const provider = new JamendoProvider('https://api.jamendo.com/v3.0', 'test_client_id');
      const normalized = provider.normalizeTrack({
        id: 'jamendo_99',
        name: 'Open Audio',
        duration: 180,
        artist_name: 'Indie Artist',
        audiodownload_allowed: true,
        audiodownload: 'https://mp3d.jamendo.com/download/track/99/mp32/',
      });

      expect(normalized.isDownloadable).toBe(true);
      expect(normalized.downloadUrl).toBe('https://mp3d.jamendo.com/download/track/99/mp32/');
    });

    it('denies download when audiodownload_allowed is false', () => {
      const provider = new JamendoProvider('https://api.jamendo.com/v3.0', 'test_client_id');
      const normalized = provider.normalizeTrack({
        id: 'jamendo_100',
        name: 'Stream Only Audio',
        duration: 180,
        audiodownload_allowed: false,
        audiodownload: 'https://mp3d.jamendo.com/download/track/100/mp32/',
      });

      expect(normalized.isDownloadable).toBe(false);
      expect(normalized.downloadUrl).toBeUndefined();
    });
  });

  describe('GET /api/tracks/:provider/:trackId/download-info', () => {
    let mockApp: any;
    const authorizedSong = {
      id: 'mock:dl_1',
      provider: 'mock',
      providerTrackId: 'dl_1',
      title: 'Mock Downloadable Track',
      artist: 'Artist',
      durationSeconds: 200,
      isDownloadable: true,
      downloadUrl: 'https://example.com/audio/dl_1.mp3',
      explicit: false,
    };
    const restrictedSong = {
      id: 'mock:stream_only',
      provider: 'mock',
      providerTrackId: 'stream_only',
      title: 'Stream Only Track',
      artist: 'Artist',
      durationSeconds: 150,
      isDownloadable: false,
      explicit: false,
    };

    beforeEach(() => {
      const mockProvider = {
        name: 'mock',
        search: async () => ({ query: '', provider: 'mock', totalResults: 0, results: [] }),
        getTrack: async (id: string) => {
          if (id === 'dl_1') return authorizedSong;
          if (id === 'stream_only') return restrictedSong;
          return null;
        },
      };

      const registry = new ProviderRegistry();
      registry.register(mockProvider);
      const musicService = new MusicService(registry);
      mockApp = createApp(musicService);
    });

    it('returns authorized download-info when provider authorizes download', async () => {
      const res = await request(mockApp).get('/api/tracks/mock/dl_1/download-info');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.isDownloadable).toBe(true);
      expect(res.body.data.downloadUrl).toBe('https://example.com/audio/dl_1.mp3');
      expect(res.body.data.restrictions).toBeNull();
    });

    it('returns restricted download-info when provider forbids download', async () => {
      const res = await request(mockApp).get('/api/tracks/mock/stream_only/download-info');
      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.isDownloadable).toBe(false);
      expect(res.body.data.downloadUrl).toBeNull();
      expect(res.body.data.restrictions).toContain('Provider does not authorize offline downloading');
    });

    it('returns 404 for non-existent track', async () => {
      const res = await request(mockApp).get('/api/tracks/mock/nonexistent_track/download-info');
      expect(res.status).toBe(404);
      expect(res.body.success).toBe(false);
      expect(res.body.error.code).toBe('NOT_FOUND');
    });

    it('returns 400 for unsupported provider', async () => {
      const res = await request(mockApp).get('/api/tracks/spotify/track_123/download-info');
      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
    });
  });
});

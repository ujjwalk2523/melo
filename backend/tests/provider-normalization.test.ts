import { describe, it, expect } from 'vitest';
import { AudiusProvider } from '../src/providers/audius/audius.provider.js';
import { JamendoProvider } from '../src/providers/jamendo/jamendo.provider.js';

describe('Provider Normalization & Download Safety', () => {
  const audiusProvider = new AudiusProvider();
  const jamendoProvider = new JamendoProvider('https://api.jamendo.com/v3.0', 'test_client_id');

  describe('Audius Normalization', () => {
    it('correctly maps raw track without download permission', () => {
      const rawAudius = {
        id: 'track123',
        title: 'Cosmic Synth',
        duration: 215,
        genre: 'Synthwave',
        release_date: '2025-01-01',
        is_downloadable: false,
        download: null,
        user: {
          id: 'user456',
          name: 'Synth Master',
          handle: 'synthmaster',
        },
        artwork: {
          '480x480': 'https://audius.co/art/480.jpg',
        },
      };

      const normalized = audiusProvider.normalizeTrack(rawAudius);

      expect(normalized).toEqual({
        id: 'audius:track123',
        provider: 'audius',
        providerTrackId: 'track123',
        title: 'Cosmic Synth',
        artist: 'Synth Master',
        artistId: 'user456',
        artworkUrl: 'https://audius.co/art/480.jpg',
        durationSeconds: 215,
        streamUrl: expect.stringContaining('/v1/tracks/track123/stream'),
        downloadUrl: undefined,
        isDownloadable: false,
        explicit: false,
        genre: 'Synthwave',
        releaseDate: '2025-01-01',
      });
    });

    it('sets isDownloadable true ONLY when is_downloadable is true and download object exists', () => {
      const rawAuthorized = {
        id: 'track999',
        title: 'Free Audio',
        duration: 120,
        is_downloadable: true,
        download: { cid: 'QmExampleCid' },
        user: { name: 'Free Creator' },
      };

      const normalized = audiusProvider.normalizeTrack(rawAuthorized);
      expect(normalized.isDownloadable).toBe(true);
      expect(normalized.downloadUrl).toBeDefined();
      expect(normalized.downloadUrl).toContain('/v1/tracks/track999/download');
    });

    it('refuses downloadUrl if is_downloadable is true but download is null', () => {
      const rawMissingDownload = {
        id: 'track888',
        title: 'Gated Audio',
        duration: 150,
        is_downloadable: true,
        download: null,
        user: { name: 'Gated Creator' },
      };

      const normalized = audiusProvider.normalizeTrack(rawMissingDownload);
      expect(normalized.isDownloadable).toBe(false);
      expect(normalized.downloadUrl).toBeUndefined();
    });
  });

  describe('Jamendo Normalization', () => {
    it('correctly maps raw track with strict download authorization check', () => {
      const rawJamendoNonDownloadable = {
        id: 'jm100',
        name: 'Acoustic Morning',
        duration: 180,
        artist_name: 'Guitarist Joe',
        artist_id: 'art1',
        album_name: 'Strings',
        album_id: 'alb1',
        image: 'https://jamendo.com/img.jpg',
        audio: 'https://jamendo.com/stream.mp3',
        audiodownload: 'https://jamendo.com/download.mp3',
        audiodownload_allowed: false, // Explicitly false!
        releasedate: '2024-05-10',
      };

      const normalized = jamendoProvider.normalizeTrack(rawJamendoNonDownloadable);

      expect(normalized.id).toBe('jamendo:jm100');
      expect(normalized.provider).toBe('jamendo');
      expect(normalized.isDownloadable).toBe(false);
      expect(normalized.downloadUrl).toBeUndefined();
      expect(normalized.title).toBe('Acoustic Morning');
      expect(normalized.artist).toBe('Guitarist Joe');
      expect(normalized.streamUrl).toBe('https://jamendo.com/stream.mp3');
    });

    it('authorizes download only when audiodownload_allowed is true', () => {
      const rawJamendoDownloadable = {
        id: 'jm200',
        name: 'CC0 Track',
        duration: 140,
        artist_name: 'Open Artist',
        audio: 'https://jamendo.com/stream2.mp3',
        audiodownload: 'https://jamendo.com/download2.mp3',
        audiodownload_allowed: true,
      };

      const normalized = jamendoProvider.normalizeTrack(rawJamendoDownloadable);
      expect(normalized.isDownloadable).toBe(true);
      expect(normalized.downloadUrl).toBe('https://jamendo.com/download2.mp3');
    });
  });
});

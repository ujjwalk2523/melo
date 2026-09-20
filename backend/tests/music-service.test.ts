import { describe, it, expect, vi } from 'vitest';
import { ProviderRegistry } from '../src/services/provider-registry.js';
import { MusicService } from '../src/services/music.service.js';
import { MusicProvider } from '../src/providers/interfaces/music-provider.js';
import { Song, SearchResult } from '../src/types/music.js';

describe('MusicService and ProviderRegistry', () => {
  it('registers and retrieves providers correctly', () => {
    const registry = new ProviderRegistry();
    expect(registry.listProviders()).toContain('audius');
    expect(registry.listProviders()).toContain('jamendo');
    expect(registry.getDefaultName()).toBe('audius');

    const audius = registry.get('audius');
    expect(audius.name).toBe('audius');

    const jamendo = registry.get('jamendo');
    expect(jamendo.name).toBe('jamendo');
  });

  it('throws for unknown provider', () => {
    const registry = new ProviderRegistry();
    expect(() => registry.get('unsupported')).toThrowError(/Unknown music provider 'unsupported'/);
  });

  it('MusicService searches with specified provider using mock provider', async () => {
    const mockSong: Song = {
      id: 'mock:1',
      provider: 'mock',
      providerTrackId: '1',
      title: 'Mock Track',
      artist: 'Mock Artist',
      durationSeconds: 180,
      isDownloadable: false,
      explicit: false,
    };

    const mockResult: SearchResult = {
      query: 'chill',
      provider: 'mock',
      totalResults: 1,
      results: [mockSong],
    };

    const mockProvider: MusicProvider = {
      name: 'mock',
      search: vi.fn().mockResolvedValue(mockResult),
      getTrack: vi.fn().mockResolvedValue(mockSong),
    };

    const registry = new ProviderRegistry();
    registry.register(mockProvider);

    const service = new MusicService(registry);
    const result = await service.search('chill', 'mock');

    expect(result).toEqual(mockResult);
    expect(mockProvider.search).toHaveBeenCalledWith('chill', undefined);
  });

  it('MusicService fetches single track and throws 404 if not found', async () => {
    const mockProvider: MusicProvider = {
      name: 'mock',
      search: vi.fn(),
      getTrack: vi.fn().mockResolvedValue(null),
    };

    const registry = new ProviderRegistry();
    registry.register(mockProvider);

    const service = new MusicService(registry);
    await expect(service.getTrack('mock', '999')).rejects.toThrowError(/Track '999' not found/);
  });
});

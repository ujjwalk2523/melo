import { ProviderRegistry } from './provider-registry.js';
import { Song, SearchResult, SearchOptions, StreamInfo } from '../types/music.js';
import { AppError } from '../utils/app-error.js';

export class MusicService {
  constructor(private readonly registry: ProviderRegistry) {}

  public async search(
    rawQuery: string,
    providerName?: string,
    options?: SearchOptions
  ): Promise<SearchResult> {
    const query = (rawQuery || '').trim();

    if (!query) {
      throw AppError.badRequest('Search query cannot be empty', 'EMPTY_QUERY');
    }

    if (query.length > 100) {
      throw AppError.badRequest('Search query cannot exceed 100 characters', 'QUERY_TOO_LONG');
    }

    const provider = this.registry.get(providerName);
    return provider.search(query, options);
  }

  public async getTrack(providerName: string, trackId: string): Promise<Song> {
    if (!providerName?.trim()) {
      throw AppError.badRequest('Provider name is required', 'MISSING_PROVIDER');
    }

    if (!trackId?.trim()) {
      throw AppError.badRequest('Track ID is required', 'MISSING_TRACK_ID');
    }

    const provider = this.registry.get(providerName);
    const track = await provider.getTrack(trackId);

    if (!track) {
      throw AppError.notFound(`Track '${trackId}' not found on provider '${provider.name}'`);
    }

    return track;
  }

  public async getStream(providerName: string, trackId: string): Promise<StreamInfo> {
    const provider = this.registry.get(providerName);

    if (!provider.getStream) {
      throw AppError.badRequest(`Provider '${provider.name}' does not support stream resolution`);
    }

    const stream = await provider.getStream(trackId);
    if (!stream) {
      throw AppError.notFound(`Stream for track '${trackId}' could not be resolved`);
    }

    return stream;
  }
}

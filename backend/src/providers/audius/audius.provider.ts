import axios, { AxiosInstance } from 'axios';
import { env } from '../../config/env.js';
import { Song, SearchOptions, SearchResult, StreamInfo } from '../../types/music.js';
import { MusicProvider } from '../interfaces/music-provider.js';
import { AppError } from '../../utils/app-error.js';

interface AudiusTrackPayload {
  id: string;
  title: string;
  duration?: number;
  genre?: string;
  release_date?: string;
  is_downloadable?: boolean;
  download?: { cid?: string } | null;
  user?: {
    id?: string;
    name?: string;
    handle?: string;
  };
  artwork?: {
    '150x150'?: string;
    '480x480'?: string;
    '1000x1000'?: string;
  };
}

export class AudiusProvider implements MusicProvider {
  public readonly name = 'audius';
  private readonly client: AxiosInstance;
  private readonly appName: string;
  private readonly baseUrl: string;

  constructor(baseUrl?: string, appName?: string) {
    this.baseUrl = baseUrl || env.AUDIUS_API_URL;
    this.appName = appName || env.AUDIUS_APP_NAME;

    this.client = axios.create({
      baseURL: this.baseUrl,
      timeout: 10000,
      headers: {
        Accept: 'application/json',
      },
    });
  }

  public async search(query: string, options?: SearchOptions): Promise<SearchResult> {
    try {
      const limit = options?.limit || 15;
      const response = await this.client.get('/v1/tracks/search', {
        params: {
          query,
          app_name: this.appName,
          limit,
        },
      });

      const rawTracks: AudiusTrackPayload[] = response.data?.data || [];
      const songs: Song[] = rawTracks.map((raw) => this.normalizeTrack(raw));

      return {
        query,
        provider: this.name,
        totalResults: songs.length,
        results: songs,
      };
    } catch (error: any) {
      if (axios.isAxiosError(error)) {
        if (error.response?.status === 429) {
          throw AppError.rateLimit('Audius API rate limit exceeded');
        }
        throw AppError.providerError(
          `Audius search failed: ${error.message}`,
          error.response?.status || 502
        );
      }
      throw error;
    }
  }

  public async getTrack(trackId: string): Promise<Song | null> {
    try {
      // Allow passing either composite id "audius:95wro" or clean id "95wro"
      const cleanId = trackId.replace(/^audius:/, '');
      const response = await this.client.get(`/v1/tracks/${cleanId}`, {
        params: {
          app_name: this.appName,
        },
      });

      const raw: AudiusTrackPayload | undefined = response.data?.data;
      if (!raw) return null;

      return this.normalizeTrack(raw);
    } catch (error: any) {
      if (axios.isAxiosError(error) && error.response?.status === 404) {
        return null;
      }
      throw AppError.providerError(`Audius getTrack failed: ${error.message}`);
    }
  }

  public async getStream(trackId: string): Promise<StreamInfo | null> {
    const cleanId = trackId.replace(/^audius:/, '');
    const url = `${this.baseUrl}/v1/tracks/${cleanId}/stream?app_name=${encodeURIComponent(this.appName)}`;
    return {
      url,
      format: 'mp3',
    };
  }

  /**
   * Safe normalization into Melo domain model.
   * Strictly verifies download safety.
   */
  public normalizeTrack(raw: AudiusTrackPayload): Song {
    const rawId = String(raw.id);
    const id = `audius:${rawId}`;

    const artworkUrl =
      raw.artwork?.['480x480'] ||
      raw.artwork?.['1000x1000'] ||
      raw.artwork?.['150x150'] ||
      undefined;

    // STEP 8: Download permission safety.
    // Strictly verify if downloading is authorized by Audius metadata.
    const isDownloadable = Boolean(raw.is_downloadable === true && raw.download !== null);
    const downloadUrl = isDownloadable
      ? `${this.baseUrl}/v1/tracks/${rawId}/download?app_name=${encodeURIComponent(this.appName)}`
      : undefined;

    const streamUrl = `${this.baseUrl}/v1/tracks/${rawId}/stream?app_name=${encodeURIComponent(this.appName)}`;

    return {
      id,
      provider: this.name,
      providerTrackId: rawId,
      title: raw.title || 'Untitled Track',
      artist: raw.user?.name || raw.user?.handle || 'Unknown Artist',
      artistId: raw.user?.id ? String(raw.user.id) : undefined,
      artworkUrl,
      durationSeconds: Math.round(raw.duration || 0),
      streamUrl,
      downloadUrl,
      isDownloadable,
      explicit: false,
      genre: raw.genre || undefined,
      releaseDate: raw.release_date || undefined,
    };
  }
}

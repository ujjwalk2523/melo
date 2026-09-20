import axios, { AxiosInstance } from 'axios';
import { env } from '../../config/env.js';
import { Song, SearchOptions, SearchResult, StreamInfo } from '../../types/music.js';
import { MusicProvider } from '../interfaces/music-provider.js';
import { AppError } from '../../utils/app-error.js';

interface JamendoTrackPayload {
  id: string | number;
  name: string;
  duration?: number;
  artist_name?: string;
  artist_id?: string | number;
  album_name?: string;
  album_id?: string | number;
  image?: string;
  audio?: string;
  audiodownload?: string;
  audiodownload_allowed?: boolean;
  releasedate?: string;
}

export class JamendoProvider implements MusicProvider {
  public readonly name = 'jamendo';
  private readonly client: AxiosInstance;
  private readonly clientId: string;
  private readonly baseUrl: string;

  constructor(baseUrl?: string, clientId?: string) {
    this.baseUrl = baseUrl || env.JAMENDO_API_URL;
    this.clientId = clientId !== undefined ? clientId : env.JAMENDO_CLIENT_ID;

    this.client = axios.create({
      baseURL: this.baseUrl,
      timeout: 10000,
      headers: {
        Accept: 'application/json',
      },
    });
  }

  /**
   * Checks whether the provider is configured with the required Client ID.
   */
  public isConfigured(): boolean {
    return Boolean(this.clientId && this.clientId.trim().length > 0);
  }

  public async search(query: string, options?: SearchOptions): Promise<SearchResult> {
    if (!this.isConfigured()) {
      throw AppError.providerError(
        'Jamendo provider requires a JAMENDO_CLIENT_ID. Please set JAMENDO_CLIENT_ID in your environment.',
        503,
        'JAMENDO_NOT_CONFIGURED'
      );
    }

    try {
      const limit = options?.limit || 15;
      const response = await this.client.get('/tracks/', {
        params: {
          client_id: this.clientId,
          format: 'jsonpretty',
          limit,
          namesearch: query,
        },
      });

      const rawTracks: JamendoTrackPayload[] = response.data?.results || [];
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
          throw AppError.rateLimit('Jamendo API rate limit reached');
        }
        throw AppError.providerError(
          `Jamendo search failed: ${error.message}`,
          error.response?.status || 502
        );
      }
      throw error;
    }
  }

  public async getTrack(trackId: string): Promise<Song | null> {
    if (!this.isConfigured()) {
      throw AppError.providerError(
        'Jamendo provider requires a JAMENDO_CLIENT_ID. Please set JAMENDO_CLIENT_ID in your environment.',
        503,
        'JAMENDO_NOT_CONFIGURED'
      );
    }

    try {
      const cleanId = trackId.replace(/^jamendo:/, '');
      const response = await this.client.get('/tracks/', {
        params: {
          client_id: this.clientId,
          format: 'jsonpretty',
          id: cleanId,
        },
      });

      const results: JamendoTrackPayload[] = response.data?.results || [];
      if (results.length === 0) return null;

      return this.normalizeTrack(results[0]);
    } catch (error: any) {
      if (axios.isAxiosError(error) && error.response?.status === 404) {
        return null;
      }
      throw AppError.providerError(`Jamendo getTrack failed: ${error.message}`);
    }
  }

  public async getStream(trackId: string): Promise<StreamInfo | null> {
    const track = await this.getTrack(trackId);
    if (!track?.streamUrl) return null;

    return {
      url: track.streamUrl,
      format: 'mp3',
    };
  }

  /**
   * Safe normalization into Melo domain model.
   * Strictly enforces download permission flag.
   */
  public normalizeTrack(raw: JamendoTrackPayload): Song {
    const rawId = String(raw.id);
    const id = `jamendo:${rawId}`;

    // STEP 8: Jamendo provides `audiodownload_allowed` and `audiodownload`.
    // STRICT check: only set isDownloadable true if audiodownload_allowed is explicitly true.
    const isDownloadable = Boolean(raw.audiodownload_allowed === true && raw.audiodownload);
    const downloadUrl = isDownloadable ? raw.audiodownload : undefined;

    return {
      id,
      provider: this.name,
      providerTrackId: rawId,
      title: raw.name || 'Untitled Track',
      artist: raw.artist_name || 'Unknown Artist',
      artistId: raw.artist_id ? String(raw.artist_id) : undefined,
      album: raw.album_name || undefined,
      albumId: raw.album_id ? String(raw.album_id) : undefined,
      artworkUrl: raw.image || undefined,
      durationSeconds: Math.round(raw.duration || 0),
      streamUrl: raw.audio || undefined,
      downloadUrl,
      isDownloadable,
      explicit: false,
      releaseDate: raw.releasedate || undefined,
    };
  }
}

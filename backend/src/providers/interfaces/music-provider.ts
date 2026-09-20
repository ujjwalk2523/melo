import { Song, Artist, Album, SearchOptions, SearchResult, StreamInfo } from '../../types/music.js';

/**
 * Common contract for all music data providers (Audius, Jamendo, etc.)
 */
export interface MusicProvider {
  /** Canonical name of the provider in lowercase, e.g. 'audius' or 'jamendo' */
  readonly name: string;

  /**
   * Search tracks, artists, or albums with query parameters.
   */
  search(query: string, options?: SearchOptions): Promise<SearchResult>;

  /**
   * Retrieve single track metadata by its provider-specific track ID.
   */
  getTrack(trackId: string): Promise<Song | null>;

  /**
   * Optional: retrieve artist profile and top tracks.
   */
  getArtist?(artistId: string): Promise<Artist | null>;

  /**
   * Optional: retrieve album information and tracklist.
   */
  getAlbum?(albumId: string): Promise<Album | null>;

  /**
   * Optional: retrieve direct or authorized stream information.
   */
  getStream?(trackId: string): Promise<StreamInfo | null>;
}

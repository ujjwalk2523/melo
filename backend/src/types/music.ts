/**
 * Normalized Music Domain Models for Melo.
 *
 * These types are completely provider-agnostic. No raw Audius, Jamendo,
 * or third-party schema structures are directly exposed to clients.
 */

export interface Song {
  /** Global composite unique identifier, e.g. "audius:95wro" or "jamendo:12345" */
  id: string;

  /** Name of the provider, e.g. 'audius' | 'jamendo' */
  provider: string;

  /** Native track identifier within the provider */
  providerTrackId: string;

  /** Track title */
  title: string;

  /** Main performing artist name */
  artist: string;

  /** Optional provider artist ID */
  artistId?: string;

  /** Album or collection title if available */
  album?: string;

  /** Album ID if available */
  albumId?: string;

  /** Artwork / cover image URL */
  artworkUrl?: string;

  /** Track duration in seconds */
  durationSeconds: number;

  /** Direct streaming URL or provider stream endpoint */
  streamUrl?: string;

  /** Direct download URL if explicitly authorized by the provider */
  downloadUrl?: string;

  /**
   * STRICT: Indicates whether downloading this track is explicitly authorized.
   * NEVER assume true unless the provider contract explicitly confirms it.
   */
  isDownloadable: boolean;

  /** Whether the track contains explicit content */
  explicit: boolean;

  /** Genre tag if present */
  genre?: string;

  /** Release date in ISO 8601 format (YYYY-MM-DD) */
  releaseDate?: string;

  /** Popularity or score metric */
  popularity?: number;
}

export interface Artist {
  id: string;
  provider: string;
  name: string;
  avatarUrl?: string;
  bio?: string;
  genre?: string;
  followersCount?: number;
}

export interface Album {
  id: string;
  provider: string;
  title: string;
  artist: string;
  artistId?: string;
  artworkUrl?: string;
  releaseDate?: string;
  trackCount: number;
}

export interface Playlist {
  id: string;
  provider: string;
  title: string;
  description?: string;
  artworkUrl?: string;
  songs: Song[];
  creator: string;
}

export interface SearchOptions {
  limit?: number;
  offset?: number;
  genre?: string;
}

export interface SearchResult {
  query: string;
  provider: string;
  totalResults: number;
  results: Song[];
}

export interface StreamInfo {
  url: string;
  format?: string;
  bitrateKbps?: number;
  expiresAt?: string;
}

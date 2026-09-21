export interface CloudUser {
  id: string;
  email: string;
  passwordHash?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface CloudUserProfile {
  userId: string;
  displayName: string;
  avatarUrl?: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface CloudFavorite {
  userId: string;
  songId: string;
  songMetadata: Record<string, any>;
  isDeleted: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface CloudHistoryEntry {
  userId: string;
  songId: string;
  songMetadata: Record<string, any>;
  playedAt: Date;
  playCount: number;
  updatedAt: Date;
}

export interface CloudPlaylist {
  id: string;
  userId: string;
  name: string;
  description?: string | null;
  artworkUrl?: string | null;
  isDeleted: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface CloudPlaylistSong {
  playlistId: string;
  userId: string;
  songId: string;
  songMetadata: Record<string, any>;
  position: number;
  addedAt: Date;
}

export interface CloudUserPreferences {
  userId: string;
  audioQuality: string;
  gaplessPlayback: boolean;
  normalizeVolume: boolean;
  crossfadeDuration: number;
  offlineOnly: boolean;
  downloadOnWifiOnly: boolean;
  updatedAt: Date;
}

export interface CloudSyncMetadata {
  userId: string;
  lastSyncAt: Date;
  serverRevision: number;
}

export interface ICloudStore {
  // User & Profile
  findUserByEmail(email: string): Promise<CloudUser | null>;
  findUserById(id: string): Promise<CloudUser | null>;
  createUser(email: string, passwordHash?: string): Promise<CloudUser>;
  deleteUser(userId: string): Promise<void>;

  getProfile(userId: string): Promise<CloudUserProfile | null>;
  upsertProfile(userId: string, data: { displayName: string; avatarUrl?: string | null }): Promise<CloudUserProfile>;

  // Favorites
  getFavorites(userId: string): Promise<CloudFavorite[]>;
  upsertFavorite(userId: string, songId: string, metadata: Record<string, any>, isDeleted?: boolean, updatedAt?: Date): Promise<void>;

  // Listening History
  getHistory(userId: string): Promise<CloudHistoryEntry[]>;
  recordHistory(userId: string, songId: string, metadata: Record<string, any>, playedAt: Date, playCount?: number): Promise<void>;
  clearHistory(userId: string): Promise<void>;

  // Playlists
  getPlaylists(userId: string): Promise<CloudPlaylist[]>;
  upsertPlaylist(playlist: CloudPlaylist): Promise<void>;
  deletePlaylist(userId: string, playlistId: string): Promise<void>;

  // Playlist Songs
  getPlaylistSongs(userId: string, playlistId?: string): Promise<CloudPlaylistSong[]>;
  replacePlaylistSongs(userId: string, playlistId: string, songs: CloudPlaylistSong[]): Promise<void>;
  upsertPlaylistSong(song: CloudPlaylistSong): Promise<void>;
  removePlaylistSong(userId: string, playlistId: string, songId: string): Promise<void>;

  // Preferences
  getPreferences(userId: string): Promise<CloudUserPreferences | null>;
  upsertPreferences(preferences: CloudUserPreferences): Promise<CloudUserPreferences>;

  // Sync Metadata
  getSyncMetadata(userId: string): Promise<CloudSyncMetadata>;
  updateSyncMetadata(userId: string): Promise<CloudSyncMetadata>;
}

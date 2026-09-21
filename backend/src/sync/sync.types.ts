import {
  CloudFavorite,
  CloudHistoryEntry,
  CloudPlaylist,
  CloudPlaylistSong,
  CloudUserPreferences,
  CloudSyncMetadata,
} from '../db/cloud-store.interface.js';

export type SyncEntityType =
  | 'favorite'
  | 'playlist'
  | 'playlist_song'
  | 'history'
  | 'preference';

export type SyncOperationType = 'upsert' | 'delete';

export interface SyncOperation {
  id: string; // client operation ID
  entityType: SyncEntityType;
  entityId: string;
  operationType: SyncOperationType;
  payload: Record<string, any>;
  clientTimestamp: string;
}

export interface SyncPullResponse {
  favorites: CloudFavorite[];
  playlists: CloudPlaylist[];
  playlistSongs: CloudPlaylistSong[];
  history: CloudHistoryEntry[];
  preferences: CloudUserPreferences | null;
  metadata: CloudSyncMetadata;
  serverTimestamp: string;
}

export interface SyncPushRequest {
  operations: SyncOperation[];
  lastSyncTimestamp?: string;
}

export interface SyncPushResponse {
  processedCount: number;
  metadata: CloudSyncMetadata;
  serverTimestamp: string;
}

export interface FullSyncRequest {
  operations?: SyncOperation[];
}

export interface FullSyncResponse {
  pushedCount: number;
  state: SyncPullResponse;
}

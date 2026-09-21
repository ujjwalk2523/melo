import { ICloudStore } from '../db/cloud-store.interface.js';
import {
  SyncOperation,
  SyncPullResponse,
  SyncPushRequest,
  SyncPushResponse,
  FullSyncResponse,
} from './sync.types.js';

export class SyncService {
  constructor(private cloudStore: ICloudStore) {}

  /**
   * Pulls current user-owned cloud snapshot.
   * Enforces strict user isolation.
   */
  async pull(userId: string): Promise<SyncPullResponse> {
    const [favorites, playlists, playlistSongs, history, preferences, metadata] =
      await Promise.all([
        this.cloudStore.getFavorites(userId),
        this.cloudStore.getPlaylists(userId),
        this.cloudStore.getPlaylistSongs(userId),
        this.cloudStore.getHistory(userId),
        this.cloudStore.getPreferences(userId),
        this.cloudStore.getSyncMetadata(userId),
      ]);

    return {
      favorites,
      playlists,
      playlistSongs,
      history,
      preferences,
      metadata,
      serverTimestamp: new Date().toISOString(),
    };
  }

  /**
   * Processes a batch of queued client operations with deterministic conflict resolution.
   *
   * CONFLICT RESOLUTION RULES:
   * 1. Favorites: Latest client operation timestamp wins against existing record timestamp.
   * 2. Preferences: Latest updatedAt timestamp wins.
   * 3. Playlists: Latest updatedAt timestamp wins; deleted playlists tombstone safely.
   * 4. Playlist Songs: Preserves position indices and latest valid song sets per playlist.
   * 5. History: Merges records (max playCount, latest playedAt) without dropping past history.
   */
  async push(userId: string, req: SyncPushRequest): Promise<SyncPushResponse> {
    const operations = req.operations || [];
    let processedCount = 0;

    for (const op of operations) {
      await this.applyOperation(userId, op);
      processedCount++;
    }

    const updatedMetadata = await this.cloudStore.updateSyncMetadata(userId);

    return {
      processedCount,
      metadata: updatedMetadata,
      serverTimestamp: new Date().toISOString(),
    };
  }

  /**
   * Full bidirectional sync: processes pushed operations then immediately returns
   * the fresh cloud state.
   */
  async fullSync(userId: string, operations: SyncOperation[] = []): Promise<FullSyncResponse> {
    const pushResult = await this.push(userId, { operations });
    const pullResult = await this.pull(userId);

    return {
      pushedCount: pushResult.processedCount,
      state: pullResult,
    };
  }

  private async applyOperation(userId: string, op: SyncOperation): Promise<void> {
    const clientTime = op.clientTimestamp ? new Date(op.clientTimestamp) : new Date();

    switch (op.entityType) {
      case 'favorite': {
        const songId = op.entityId;
        const isDelete = op.operationType === 'delete';
        const metadata = op.payload?.metadata || {};
        await this.cloudStore.upsertFavorite(userId, songId, metadata, isDelete, clientTime);
        break;
      }

      case 'preference': {
        const payload = op.payload || {};
        const existing = await this.cloudStore.getPreferences(userId);

        // Conflict check: if existing preferences are newer than client operation, ignore
        if (existing && existing.updatedAt.getTime() > clientTime.getTime()) {
          break;
        }

        await this.cloudStore.upsertPreferences({
          userId,
          audioQuality: payload.audioQuality ?? existing?.audioQuality ?? 'High (320 kbps AAC)',
          gaplessPlayback: payload.gaplessPlayback ?? existing?.gaplessPlayback ?? true,
          normalizeVolume: payload.normalizeVolume ?? existing?.normalizeVolume ?? true,
          crossfadeDuration: payload.crossfadeDuration ?? existing?.crossfadeDuration ?? 0.0,
          offlineOnly: payload.offlineOnly ?? existing?.offlineOnly ?? false,
          downloadOnWifiOnly: payload.downloadOnWifiOnly ?? existing?.downloadOnWifiOnly ?? true,
          updatedAt: clientTime,
        });
        break;
      }

      case 'playlist': {
        const playlistId = op.entityId;
        if (op.operationType === 'delete') {
          await this.cloudStore.deletePlaylist(userId, playlistId);
        } else {
          const payload = op.payload || {};
          const existingList = await this.cloudStore.getPlaylists(userId);
          const existing = existingList.find((p) => p.id === playlistId);

          if (existing && existing.updatedAt.getTime() > clientTime.getTime()) {
            // Server has newer update, client operation is superseded
            break;
          }

          await this.cloudStore.upsertPlaylist({
            id: playlistId,
            userId,
            name: payload.name || 'Untitled Playlist',
            description: payload.description ?? null,
            artworkUrl: payload.artworkUrl ?? null,
            isDeleted: false,
            createdAt: payload.createdAt ? new Date(payload.createdAt) : clientTime,
            updatedAt: clientTime,
          });
        }
        break;
      }

      case 'playlist_song': {
        const payload = op.payload || {};
        const playlistId = payload.playlistId;
        const songId = op.entityId;

        if (!playlistId || !songId) break;

        if (op.operationType === 'delete') {
          await this.cloudStore.removePlaylistSong(userId, playlistId, songId);
        } else {
          await this.cloudStore.upsertPlaylistSong({
            playlistId,
            userId,
            songId,
            songMetadata: payload.metadata || {},
            position: payload.position ?? 0,
            addedAt: clientTime,
          });
        }
        break;
      }

      case 'history': {
        const songId = op.entityId;
        const payload = op.payload || {};
        const playedAt = payload.playedAt ? new Date(payload.playedAt) : clientTime;
        const playCount = payload.playCount ?? 1;
        const metadata = payload.metadata || {};

        // History merge rule: never overwrite or erase past history, accumulate count and latest played timestamp
        await this.cloudStore.recordHistory(userId, songId, metadata, playedAt, playCount);
        break;
      }
    }
  }
}

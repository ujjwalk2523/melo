import crypto from 'crypto';
import {
  CloudUser,
  CloudUserProfile,
  CloudFavorite,
  CloudHistoryEntry,
  CloudPlaylist,
  CloudPlaylistSong,
  CloudUserPreferences,
  CloudSyncMetadata,
  ICloudStore,
} from './cloud-store.interface.js';

export class MemoryCloudStore implements ICloudStore {
  private users = new Map<string, CloudUser>();
  private profiles = new Map<string, CloudUserProfile>();
  private favorites = new Map<string, CloudFavorite>(); // key: `${userId}:${songId}`
  private history = new Map<string, CloudHistoryEntry>(); // key: `${userId}:${songId}`
  private playlists = new Map<string, CloudPlaylist>(); // key: `${userId}:${playlistId}`
  private playlistSongs = new Map<string, CloudPlaylistSong>(); // key: `${userId}:${playlistId}:${songId}`
  private preferences = new Map<string, CloudUserPreferences>(); // key: userId
  private syncMetadata = new Map<string, CloudSyncMetadata>(); // key: userId

  async findUserByEmail(email: string): Promise<CloudUser | null> {
    const normalized = email.trim().toLowerCase();
    for (const user of this.users.values()) {
      if (user.email.toLowerCase() === normalized) {
        return { ...user };
      }
    }
    return null;
  }

  async findUserById(id: string): Promise<CloudUser | null> {
    const user = this.users.get(id);
    return user ? { ...user } : null;
  }

  async createUser(email: string, passwordHash?: string): Promise<CloudUser> {
    const normalized = email.trim().toLowerCase();
    const id = crypto.randomUUID();
    const now = new Date();
    const user: CloudUser = {
      id,
      email: normalized,
      passwordHash,
      createdAt: now,
      updatedAt: now,
    };
    this.users.set(id, user);

    // Initialize default metadata & preferences
    this.syncMetadata.set(id, {
      userId: id,
      lastSyncAt: now,
      serverRevision: 1,
    });

    return { ...user };
  }

  async deleteUser(userId: string): Promise<void> {
    this.users.delete(userId);
    this.profiles.delete(userId);
    this.preferences.delete(userId);
    this.syncMetadata.delete(userId);

    for (const key of Array.from(this.favorites.keys())) {
      if (key.startsWith(`${userId}:`)) this.favorites.delete(key);
    }
    for (const key of Array.from(this.history.keys())) {
      if (key.startsWith(`${userId}:`)) this.history.delete(key);
    }
    for (const key of Array.from(this.playlists.keys())) {
      if (key.startsWith(`${userId}:`)) this.playlists.delete(key);
    }
    for (const key of Array.from(this.playlistSongs.keys())) {
      if (key.startsWith(`${userId}:`)) this.playlistSongs.delete(key);
    }
  }

  async getProfile(userId: string): Promise<CloudUserProfile | null> {
    const profile = this.profiles.get(userId);
    return profile ? { ...profile } : null;
  }

  async upsertProfile(
    userId: string,
    data: { displayName: string; avatarUrl?: string | null }
  ): Promise<CloudUserProfile> {
    const existing = this.profiles.get(userId);
    const now = new Date();
    const profile: CloudUserProfile = {
      userId,
      displayName: data.displayName,
      avatarUrl: data.avatarUrl !== undefined ? data.avatarUrl : existing?.avatarUrl,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    };
    this.profiles.set(userId, profile);
    return { ...profile };
  }

  async getFavorites(userId: string): Promise<CloudFavorite[]> {
    const results: CloudFavorite[] = [];
    for (const fav of this.favorites.values()) {
      if (fav.userId === userId && !fav.isDeleted) {
        results.push({ ...fav });
      }
    }
    return results;
  }

  async upsertFavorite(
    userId: string,
    songId: string,
    metadata: Record<string, any>,
    isDeleted: boolean = false,
    updatedAt?: Date
  ): Promise<void> {
    const key = `${userId}:${songId}`;
    const existing = this.favorites.get(key);
    const now = updatedAt ?? new Date();

    this.favorites.set(key, {
      userId,
      songId,
      songMetadata: metadata,
      isDeleted,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    });
  }

  async getHistory(userId: string): Promise<CloudHistoryEntry[]> {
    const results: CloudHistoryEntry[] = [];
    for (const entry of this.history.values()) {
      if (entry.userId === userId) {
        results.push({ ...entry });
      }
    }
    return results.sort((a, b) => b.playedAt.getTime() - a.playedAt.getTime());
  }

  async recordHistory(
    userId: string,
    songId: string,
    metadata: Record<string, any>,
    playedAt: Date,
    playCount: number = 1
  ): Promise<void> {
    const key = `${userId}:${songId}`;
    const existing = this.history.get(key);
    const now = new Date();

    if (existing) {
      this.history.set(key, {
        userId,
        songId,
        songMetadata: Object.keys(metadata).length > 0 ? metadata : existing.songMetadata,
        playedAt: playedAt > existing.playedAt ? playedAt : existing.playedAt,
        playCount: Math.max(existing.playCount + 1, playCount),
        updatedAt: now,
      });
    } else {
      this.history.set(key, {
        userId,
        songId,
        songMetadata: metadata,
        playedAt,
        playCount,
        updatedAt: now,
      });
    }
  }

  async clearHistory(userId: string): Promise<void> {
    for (const key of Array.from(this.history.keys())) {
      if (key.startsWith(`${userId}:`)) {
        this.history.delete(key);
      }
    }
  }

  async getPlaylists(userId: string): Promise<CloudPlaylist[]> {
    const results: CloudPlaylist[] = [];
    for (const pl of this.playlists.values()) {
      if (pl.userId === userId && !pl.isDeleted) {
        results.push({ ...pl });
      }
    }
    return results.sort((a, b) => b.updatedAt.getTime() - a.updatedAt.getTime());
  }

  async upsertPlaylist(playlist: CloudPlaylist): Promise<void> {
    const key = `${playlist.userId}:${playlist.id}`;
    this.playlists.set(key, { ...playlist });
  }

  async deletePlaylist(userId: string, playlistId: string): Promise<void> {
    const key = `${userId}:${playlistId}`;
    const existing = this.playlists.get(key);
    if (existing) {
      this.playlists.set(key, {
        ...existing,
        isDeleted: true,
        updatedAt: new Date(),
      });
    }
    // Remove songs for this playlist
    for (const songKey of Array.from(this.playlistSongs.keys())) {
      if (songKey.startsWith(`${userId}:${playlistId}:`)) {
        this.playlistSongs.delete(songKey);
      }
    }
  }

  async getPlaylistSongs(userId: string, playlistId?: string): Promise<CloudPlaylistSong[]> {
    const results: CloudPlaylistSong[] = [];
    for (const s of this.playlistSongs.values()) {
      if (s.userId === userId && (!playlistId || s.playlistId === playlistId)) {
        results.push({ ...s });
      }
    }
    return results.sort((a, b) => a.position - b.position);
  }

  async replacePlaylistSongs(
    userId: string,
    playlistId: string,
    songs: CloudPlaylistSong[]
  ): Promise<void> {
    for (const key of Array.from(this.playlistSongs.keys())) {
      if (key.startsWith(`${userId}:${playlistId}:`)) {
        this.playlistSongs.delete(key);
      }
    }
    for (const s of songs) {
      const key = `${userId}:${playlistId}:${s.songId}`;
      this.playlistSongs.set(key, { ...s, userId, playlistId });
    }
  }

  async upsertPlaylistSong(song: CloudPlaylistSong): Promise<void> {
    const key = `${song.userId}:${song.playlistId}:${song.songId}`;
    this.playlistSongs.set(key, { ...song });
  }

  async removePlaylistSong(userId: string, playlistId: string, songId: string): Promise<void> {
    const key = `${userId}:${playlistId}:${songId}`;
    this.playlistSongs.delete(key);
  }

  async getPreferences(userId: string): Promise<CloudUserPreferences | null> {
    const prefs = this.preferences.get(userId);
    return prefs ? { ...prefs } : null;
  }

  async upsertPreferences(preferences: CloudUserPreferences): Promise<CloudUserPreferences> {
    const updated = {
      ...preferences,
      updatedAt: new Date(),
    };
    this.preferences.set(preferences.userId, updated);
    return { ...updated };
  }

  async getSyncMetadata(userId: string): Promise<CloudSyncMetadata> {
    let meta = this.syncMetadata.get(userId);
    if (!meta) {
      meta = {
        userId,
        lastSyncAt: new Date(),
        serverRevision: 1,
      };
      this.syncMetadata.set(userId, meta);
    }
    return { ...meta };
  }

  async updateSyncMetadata(userId: string): Promise<CloudSyncMetadata> {
    const current = await this.getSyncMetadata(userId);
    const updated: CloudSyncMetadata = {
      userId,
      lastSyncAt: new Date(),
      serverRevision: current.serverRevision + 1,
    };
    this.syncMetadata.set(userId, updated);
    return { ...updated };
  }

  // Clear everything for test tear downs
  clear(): void {
    this.users.clear();
    this.profiles.clear();
    this.favorites.clear();
    this.history.clear();
    this.playlists.clear();
    this.playlistSongs.clear();
    this.preferences.clear();
    this.syncMetadata.clear();
  }
}

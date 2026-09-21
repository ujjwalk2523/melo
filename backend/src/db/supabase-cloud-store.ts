import { createClient, SupabaseClient } from '@supabase/supabase-js';
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
import { MemoryCloudStore } from './memory-cloud-store.js';

export class SupabaseCloudStore implements ICloudStore {
  private client: SupabaseClient | null = null;
  private fallbackStore = new MemoryCloudStore();

  constructor(supabaseUrl?: string, supabaseKey?: string) {
    if (supabaseUrl && supabaseKey) {
      try {
        this.client = createClient(supabaseUrl, supabaseKey, {
          auth: { persistSession: false },
        });
      } catch (err) {
        console.warn('Failed to initialize Supabase client, using fallback store:', err);
      }
    }
  }

  async findUserByEmail(email: string): Promise<CloudUser | null> {
    if (!this.client) return this.fallbackStore.findUserByEmail(email);
    const { data, error } = await this.client
      .from('users')
      .select('*')
      .eq('email', email.trim().toLowerCase())
      .maybeSingle();
    if (error || !data) return null;
    return {
      id: data.id,
      email: data.email,
      passwordHash: data.password_hash,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at),
    };
  }

  async findUserById(id: string): Promise<CloudUser | null> {
    if (!this.client) return this.fallbackStore.findUserById(id);
    const { data, error } = await this.client
      .from('users')
      .select('*')
      .eq('id', id)
      .maybeSingle();
    if (error || !data) return null;
    return {
      id: data.id,
      email: data.email,
      passwordHash: data.password_hash,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at),
    };
  }

  async createUser(email: string, passwordHash?: string): Promise<CloudUser> {
    if (!this.client) return this.fallbackStore.createUser(email, passwordHash);
    const { data, error } = await this.client
      .from('users')
      .insert({
        email: email.trim().toLowerCase(),
        password_hash: passwordHash,
      })
      .select()
      .single();
    if (error || !data) {
      throw new Error(`Failed to create user in Supabase: ${error?.message}`);
    }
    return {
      id: data.id,
      email: data.email,
      passwordHash: data.password_hash,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at),
    };
  }

  async deleteUser(userId: string): Promise<void> {
    if (!this.client) return this.fallbackStore.deleteUser(userId);
    await this.client.from('users').delete().eq('id', userId);
  }

  async getProfile(userId: string): Promise<CloudUserProfile | null> {
    if (!this.client) return this.fallbackStore.getProfile(userId);
    const { data, error } = await this.client
      .from('user_profiles')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();
    if (error || !data) return null;
    return {
      userId: data.user_id,
      displayName: data.display_name,
      avatarUrl: data.avatar_url,
      createdAt: new Date(data.created_at),
      updatedAt: new Date(data.updated_at),
    };
  }

  async upsertProfile(
    userId: string,
    data: { displayName: string; avatarUrl?: string | null }
  ): Promise<CloudUserProfile> {
    if (!this.client) return this.fallbackStore.upsertProfile(userId, data);
    const { data: result, error } = await this.client
      .from('user_profiles')
      .upsert({
        user_id: userId,
        display_name: data.displayName,
        avatar_url: data.avatarUrl,
        updated_at: new Date().toISOString(),
      })
      .select()
      .single();
    if (error || !result) {
      throw new Error(`Failed to upsert profile: ${error?.message}`);
    }
    return {
      userId: result.user_id,
      displayName: result.display_name,
      avatarUrl: result.avatar_url,
      createdAt: new Date(result.created_at),
      updatedAt: new Date(result.updated_at),
    };
  }

  async getFavorites(userId: string): Promise<CloudFavorite[]> {
    if (!this.client) return this.fallbackStore.getFavorites(userId);
    const { data, error } = await this.client
      .from('favorites')
      .select('*')
      .eq('user_id', userId)
      .eq('is_deleted', false);
    if (error || !data) return [];
    return data.map((d) => ({
      userId: d.user_id,
      songId: d.song_id,
      songMetadata: d.song_metadata,
      isDeleted: d.is_deleted,
      createdAt: new Date(d.created_at),
      updatedAt: new Date(d.updated_at),
    }));
  }

  async upsertFavorite(
    userId: string,
    songId: string,
    metadata: Record<string, any>,
    isDeleted: boolean = false,
    updatedAt?: Date
  ): Promise<void> {
    if (!this.client) return this.fallbackStore.upsertFavorite(userId, songId, metadata, isDeleted, updatedAt);
    await this.client.from('favorites').upsert({
      user_id: userId,
      song_id: songId,
      song_metadata: metadata,
      is_deleted: isDeleted,
      updated_at: (updatedAt ?? new Date()).toISOString(),
    });
  }

  async getHistory(userId: string): Promise<CloudHistoryEntry[]> {
    if (!this.client) return this.fallbackStore.getHistory(userId);
    const { data, error } = await this.client
      .from('listening_history')
      .select('*')
      .eq('user_id', userId)
      .order('played_at', { ascending: false });
    if (error || !data) return [];
    return data.map((d) => ({
      userId: d.user_id,
      songId: d.song_id,
      songMetadata: d.song_metadata,
      playedAt: new Date(d.played_at),
      playCount: d.play_count,
      updatedAt: new Date(d.updated_at),
    }));
  }

  async recordHistory(
    userId: string,
    songId: string,
    metadata: Record<string, any>,
    playedAt: Date,
    playCount: number = 1
  ): Promise<void> {
    if (!this.client) return this.fallbackStore.recordHistory(userId, songId, metadata, playedAt, playCount);
    await this.client.from('listening_history').upsert({
      user_id: userId,
      song_id: songId,
      song_metadata: metadata,
      played_at: playedAt.toISOString(),
      play_count: playCount,
      updated_at: new Date().toISOString(),
    });
  }

  async clearHistory(userId: string): Promise<void> {
    if (!this.client) return this.fallbackStore.clearHistory(userId);
    await this.client.from('listening_history').delete().eq('user_id', userId);
  }

  async getPlaylists(userId: string): Promise<CloudPlaylist[]> {
    if (!this.client) return this.fallbackStore.getPlaylists(userId);
    const { data, error } = await this.client
      .from('playlists')
      .select('*')
      .eq('user_id', userId)
      .eq('is_deleted', false)
      .order('updated_at', { ascending: false });
    if (error || !data) return [];
    return data.map((d) => ({
      id: d.id,
      userId: d.user_id,
      name: d.name,
      description: d.description,
      artworkUrl: d.artwork_url,
      isDeleted: d.is_deleted,
      createdAt: new Date(d.created_at),
      updatedAt: new Date(d.updated_at),
    }));
  }

  async upsertPlaylist(playlist: CloudPlaylist): Promise<void> {
    if (!this.client) return this.fallbackStore.upsertPlaylist(playlist);
    await this.client.from('playlists').upsert({
      id: playlist.id,
      user_id: playlist.userId,
      name: playlist.name,
      description: playlist.description,
      artwork_url: playlist.artworkUrl,
      is_deleted: playlist.isDeleted,
      updated_at: playlist.updatedAt.toISOString(),
    });
  }

  async deletePlaylist(userId: string, playlistId: string): Promise<void> {
    if (!this.client) return this.fallbackStore.deletePlaylist(userId, playlistId);
    await this.client.from('playlists').update({
      is_deleted: true,
      updated_at: new Date().toISOString(),
    }).eq('id', playlistId).eq('user_id', userId);
  }

  async getPlaylistSongs(userId: string, playlistId?: string): Promise<CloudPlaylistSong[]> {
    if (!this.client) return this.fallbackStore.getPlaylistSongs(userId, playlistId);
    let query = this.client
      .from('playlist_songs')
      .select('*')
      .eq('user_id', userId);
    if (playlistId) {
      query = query.eq('playlist_id', playlistId);
    }
    const { data, error } = await query.order('position', { ascending: true });
    if (error || !data) return [];
    return data.map((d) => ({
      playlistId: d.playlist_id,
      userId: d.user_id,
      songId: d.song_id,
      songMetadata: d.song_metadata,
      position: d.position,
      addedAt: new Date(d.added_at),
    }));
  }

  async replacePlaylistSongs(
    userId: string,
    playlistId: string,
    songs: CloudPlaylistSong[]
  ): Promise<void> {
    if (!this.client) return this.fallbackStore.replacePlaylistSongs(userId, playlistId, songs);
    await this.client.from('playlist_songs').delete().eq('playlist_id', playlistId).eq('user_id', userId);
    if (songs.length > 0) {
      await this.client.from('playlist_songs').insert(
        songs.map((s) => ({
          playlist_id: playlistId,
          user_id: userId,
          song_id: s.songId,
          song_metadata: s.songMetadata,
          position: s.position,
          added_at: s.addedAt.toISOString(),
        }))
      );
    }
  }

  async upsertPlaylistSong(song: CloudPlaylistSong): Promise<void> {
    if (!this.client) return this.fallbackStore.upsertPlaylistSong(song);
    await this.client.from('playlist_songs').upsert({
      playlist_id: song.playlistId,
      user_id: song.userId,
      song_id: song.songId,
      song_metadata: song.songMetadata,
      position: song.position,
      added_at: song.addedAt.toISOString(),
    });
  }

  async removePlaylistSong(userId: string, playlistId: string, songId: string): Promise<void> {
    if (!this.client) return this.fallbackStore.removePlaylistSong(userId, playlistId, songId);
    await this.client
      .from('playlist_songs')
      .delete()
      .eq('playlist_id', playlistId)
      .eq('user_id', userId)
      .eq('song_id', songId);
  }

  async getPreferences(userId: string): Promise<CloudUserPreferences | null> {
    if (!this.client) return this.fallbackStore.getPreferences(userId);
    const { data, error } = await this.client
      .from('user_preferences')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();
    if (error || !data) return null;
    return {
      userId: data.user_id,
      audioQuality: data.audio_quality,
      gaplessPlayback: data.gapless_playback,
      normalizeVolume: data.normalize_volume,
      crossfadeDuration: parseFloat(data.crossfade_duration),
      offlineOnly: data.offline_only,
      downloadOnWifiOnly: data.download_on_wifi_only,
      updatedAt: new Date(data.updated_at),
    };
  }

  async upsertPreferences(preferences: CloudUserPreferences): Promise<CloudUserPreferences> {
    if (!this.client) return this.fallbackStore.upsertPreferences(preferences);
    const { data, error } = await this.client
      .from('user_preferences')
      .upsert({
        user_id: preferences.userId,
        audio_quality: preferences.audioQuality,
        gapless_playback: preferences.gaplessPlayback,
        normalize_volume: preferences.normalizeVolume,
        crossfade_duration: preferences.crossfadeDuration,
        offline_only: preferences.offlineOnly,
        download_on_wifi_only: preferences.downloadOnWifiOnly,
        updated_at: new Date().toISOString(),
      })
      .select()
      .single();
    if (error || !data) {
      throw new Error(`Failed to upsert preferences: ${error?.message}`);
    }
    return {
      userId: data.user_id,
      audioQuality: data.audio_quality,
      gaplessPlayback: data.gapless_playback,
      normalizeVolume: data.normalize_volume,
      crossfadeDuration: parseFloat(data.crossfade_duration),
      offlineOnly: data.offline_only,
      downloadOnWifiOnly: data.download_on_wifi_only,
      updatedAt: new Date(data.updated_at),
    };
  }

  async getSyncMetadata(userId: string): Promise<CloudSyncMetadata> {
    if (!this.client) return this.fallbackStore.getSyncMetadata(userId);
    const { data, error } = await this.client
      .from('sync_metadata')
      .select('*')
      .eq('user_id', userId)
      .maybeSingle();
    if (error || !data) {
      return {
        userId,
        lastSyncAt: new Date(),
        serverRevision: 1,
      };
    }
    return {
      userId: data.user_id,
      lastSyncAt: new Date(data.last_sync_at),
      serverRevision: parseInt(data.server_revision, 10),
    };
  }

  async updateSyncMetadata(userId: string): Promise<CloudSyncMetadata> {
    if (!this.client) return this.fallbackStore.updateSyncMetadata(userId);
    const current = await this.getSyncMetadata(userId);
    const nextRevision = current.serverRevision + 1;
    const now = new Date();
    await this.client.from('sync_metadata').upsert({
      user_id: userId,
      last_sync_at: now.toISOString(),
      server_revision: nextRevision,
    });
    return {
      userId,
      lastSyncAt: now,
      serverRevision: nextRevision,
    };
  }
}

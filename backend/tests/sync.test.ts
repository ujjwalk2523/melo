import { describe, it, expect, beforeEach } from 'vitest';
import request from 'supertest';
import { createApp } from '../src/server.js';
import { getCloudStore } from '../src/db/cloud-store.factory.js';
import { MemoryCloudStore } from '../src/db/memory-cloud-store.js';

describe('Phase 7: Backend Sync Engine & User Isolation', () => {
  const app = createApp();
  const cloudStore = getCloudStore() as MemoryCloudStore;

  let userAToken: string;
  let userAId: string;
  let userBToken: string;
  let userBId: string;

  beforeEach(async () => {
    if ('clear' in cloudStore) {
      cloudStore.clear();
    }

    // Register User A
    const resA = await request(app).post('/api/auth/register').send({
      email: 'usera@melo.stream',
      password: 'Password123!',
      displayName: 'User Alpha',
    });
    userAToken = resA.body.tokens.accessToken;
    userAId = resA.body.user.id;

    // Register User B
    const resB = await request(app).post('/api/auth/register').send({
      email: 'userb@melo.stream',
      password: 'Password123!',
      displayName: 'User Beta',
    });
    userBToken = resB.body.tokens.accessToken;
    userBId = resB.body.user.id;
  });

  it('rejects unauthenticated requests to /api/sync/state with 401', async () => {
    const res = await request(app).get('/api/sync/state');
    expect(res.status).toBe(401);
  });

  it('enforces strict user isolation: User A cannot see User B data', async () => {
    // User A pushes a favorite
    await request(app)
      .post('/api/sync/push')
      .set('Authorization', `Bearer ${userAToken}`)
      .send({
        operations: [
          {
            id: 'op-1',
            entityType: 'favorite',
            entityId: 'audius:alpha_track',
            operationType: 'upsert',
            payload: {
              metadata: { title: 'Alpha Song', artist: 'Artist A' },
            },
            clientTimestamp: new Date().toISOString(),
          },
        ],
      });

    // User A pulls: sees their favorite
    const resA = await request(app)
      .get('/api/sync/state')
      .set('Authorization', `Bearer ${userAToken}`);
    expect(resA.body.favorites.length).toBe(1);
    expect(resA.body.favorites[0].songId).toBe('audius:alpha_track');

    // User B pulls: sees 0 favorites
    const resB = await request(app)
      .get('/api/sync/state')
      .set('Authorization', `Bearer ${userBToken}`);
    expect(resB.body.favorites.length).toBe(0);
  });

  it('handles push operations for favorites (upsert and delete)', async () => {
    const now = new Date();
    // 1. Add favorite
    const pushRes1 = await request(app)
      .post('/api/sync/push')
      .set('Authorization', `Bearer ${userAToken}`)
      .send({
        operations: [
          {
            id: 'op-fav-add',
            entityType: 'favorite',
            entityId: 'jamendo:track_101',
            operationType: 'upsert',
            payload: {
              metadata: { title: 'Chill Lo-Fi', artist: 'Beat Maker' },
            },
            clientTimestamp: now.toISOString(),
          },
        ],
      });
    expect(pushRes1.status).toBe(200);
    expect(pushRes1.body.processedCount).toBe(1);

    // Verify added
    const check1 = await request(app)
      .get('/api/sync/state')
      .set('Authorization', `Bearer ${userAToken}`);
    expect(check1.body.favorites.length).toBe(1);

    // 2. Remove favorite
    const later = new Date(now.getTime() + 1000);
    const pushRes2 = await request(app)
      .post('/api/sync/push')
      .set('Authorization', `Bearer ${userAToken}`)
      .send({
        operations: [
          {
            id: 'op-fav-del',
            entityType: 'favorite',
            entityId: 'jamendo:track_101',
            operationType: 'delete',
            payload: {},
            clientTimestamp: later.toISOString(),
          },
        ],
      });
    expect(pushRes2.status).toBe(200);

    // Verify removed
    const check2 = await request(app)
      .get('/api/sync/state')
      .set('Authorization', `Bearer ${userAToken}`);
    expect(check2.body.favorites.length).toBe(0);
  });

  it('handles push for playlists and songs while preserving order', async () => {
    const time = new Date().toISOString();
    const pushRes = await request(app)
      .post('/api/sync/push')
      .set('Authorization', `Bearer ${userAToken}`)
      .send({
        operations: [
          {
            id: 'op-pl-1',
            entityType: 'playlist',
            entityId: 'pl_cyber_night',
            operationType: 'upsert',
            payload: {
              name: 'Cyber Night',
              description: 'Dark synthwave gems',
            },
            clientTimestamp: time,
          },
          {
            id: 'op-pl-song-1',
            entityType: 'playlist_song',
            entityId: 'audius:track_01',
            operationType: 'upsert',
            payload: {
              playlistId: 'pl_cyber_night',
              position: 0,
              metadata: { title: 'First Song' },
            },
            clientTimestamp: time,
          },
          {
            id: 'op-pl-song-2',
            entityType: 'playlist_song',
            entityId: 'audius:track_02',
            operationType: 'upsert',
            payload: {
              playlistId: 'pl_cyber_night',
              position: 1,
              metadata: { title: 'Second Song' },
            },
            clientTimestamp: time,
          },
        ],
      });

    expect(pushRes.status).toBe(200);
    expect(pushRes.body.processedCount).toBe(3);

    const pull = await request(app)
      .get('/api/sync/state')
      .set('Authorization', `Bearer ${userAToken}`);

    expect(pull.body.playlists.length).toBe(1);
    expect(pull.body.playlists[0].name).toBe('Cyber Night');
    expect(pull.body.playlistSongs.length).toBe(2);
    expect(pull.body.playlistSongs[0].songId).toBe('audius:track_01');
    expect(pull.body.playlistSongs[0].position).toBe(0);
    expect(pull.body.playlistSongs[1].songId).toBe('audius:track_02');
    expect(pull.body.playlistSongs[1].position).toBe(1);
  });

  it('merges listening history records without losing past plays', async () => {
    const time1 = new Date('2026-09-20T10:00:00Z').toISOString();
    const time2 = new Date('2026-09-21T12:00:00Z').toISOString();

    // Push first play
    await request(app)
      .post('/api/sync/push')
      .set('Authorization', `Bearer ${userAToken}`)
      .send({
        operations: [
          {
            id: 'op-hist-1',
            entityType: 'history',
            entityId: 'audius:history_song',
            operationType: 'upsert',
            payload: {
              playedAt: time1,
              playCount: 1,
              metadata: { title: 'Memory Lane' },
            },
            clientTimestamp: time1,
          },
        ],
      });

    // Push second play of same song
    await request(app)
      .post('/api/sync/push')
      .set('Authorization', `Bearer ${userAToken}`)
      .send({
        operations: [
          {
            id: 'op-hist-2',
            entityType: 'history',
            entityId: 'audius:history_song',
            operationType: 'upsert',
            payload: {
              playedAt: time2,
              playCount: 2,
              metadata: { title: 'Memory Lane' },
            },
            clientTimestamp: time2,
          },
        ],
      });

    const pull = await request(app)
      .get('/api/sync/state')
      .set('Authorization', `Bearer ${userAToken}`);

    expect(pull.body.history.length).toBe(1);
    expect(pull.body.history[0].songId).toBe('audius:history_song');
    expect(pull.body.history[0].playCount).toBe(2);
    expect(new Date(pull.body.history[0].playedAt).toISOString()).toBe(time2);
  });

  it('resolves preferences conflict: latest updatedAt wins', async () => {
    const olderTime = new Date('2026-09-20T00:00:00Z').toISOString();
    const newerTime = new Date('2026-09-21T00:00:00Z').toISOString();

    // Set newer preference first
    await request(app)
      .post('/api/sync/push')
      .set('Authorization', `Bearer ${userAToken}`)
      .send({
        operations: [
          {
            id: 'op-pref-newer',
            entityType: 'preference',
            entityId: 'prefs',
            operationType: 'upsert',
            payload: {
              audioQuality: 'Hi-Res Lossless (FLAC 24-bit)',
              gaplessPlayback: true,
            },
            clientTimestamp: newerTime,
          },
        ],
      });

    // Try to overwrite with older timestamp (e.g. stale client coming online)
    await request(app)
      .post('/api/sync/push')
      .set('Authorization', `Bearer ${userAToken}`)
      .send({
        operations: [
          {
            id: 'op-pref-older',
            entityType: 'preference',
            entityId: 'prefs',
            operationType: 'upsert',
            payload: {
              audioQuality: 'Normal (160 kbps MP3)',
              gaplessPlayback: false,
            },
            clientTimestamp: olderTime,
          },
        ],
      });

    const pull = await request(app)
      .get('/api/sync/state')
      .set('Authorization', `Bearer ${userAToken}`);

    // Conflict rule ensured newer value was preserved!
    expect(pull.body.preferences?.audioQuality).toBe('Hi-Res Lossless (FLAC 24-bit)');
  });

  it('executes full bidirectional sync via POST /api/sync', async () => {
    const res = await request(app)
      .post('/api/sync')
      .set('Authorization', `Bearer ${userAToken}`)
      .send({
        operations: [
          {
            id: 'op-full-fav',
            entityType: 'favorite',
            entityId: 'jamendo:sync_track',
            operationType: 'upsert',
            payload: { metadata: { title: 'Synced Song' } },
            clientTimestamp: new Date().toISOString(),
          },
        ],
      });

    expect(res.status).toBe(200);
    expect(res.body.pushedCount).toBe(1);
    expect(res.body.state).toBeDefined();
    expect(res.body.state.favorites.length).toBe(1);
    expect(res.body.state.favorites[0].songId).toBe('jamendo:sync_track');
  });
});

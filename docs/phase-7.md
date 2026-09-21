# Phase 7 — Authentication, Cloud User Account, and Local/Cloud Sync

## 1. Overview & Architecture

Phase 7 brings user authentication, cloud profile management, and a robust offline-first synchronization engine to Melo without disrupting the existing local playback, Drift database, or guest user experience.

### Architecture Highlights
- **Local-First / Guest Preserved**: Melo remains 100% usable offline without requiring an account. Favorites, playlists, and listening history are persisted immediately to the local Drift SQLite database.
- **Secure Authentication**: Register, Login, Refresh, Logout, and Delete Account flows backed by JWT (Access + Refresh tokens) stored securely via `FlutterSecureStorage` (with hardware-backed keychain/keystore encryption) and fallback to memory storage for headless test environments.
- **Unified Sync Engine**: An offline-first event-queue sync engine (`SyncEngine`) with durable SQLite staging (`sync_queue_table`, `sync_metadata_table`), deterministic conflict resolution rules, and automatic network reconciliation.
- **Cloud Schema & RLS**: PostgreSQL schema configured for Supabase with granular Row-Level Security (RLS) guaranteeing tenant isolation (`auth.uid() = user_id`).
- **Dev/Test Flexibility**: Dual-backend support via `CLOUD_STORE_TYPE=memory` (in-memory mock store for rapid headless vitest suites and local development) or `CLOUD_STORE_TYPE=supabase` (production PostgreSQL via `@supabase/supabase-js`).

```
┌──────────────────────────────────────────────────────────┐
│                   Flutter Client (Melo)                  │
│                                                          │
│  ┌───────────────────────┐    ┌──────────────────────┐  │
│  │     GoRouter / UI     │    │   AuthStateProvider  │  │
│  │  (Guest / Auth aware) │    │  (Riverpod Notifier) │  │
│  └──────────┬────────────┘    └──────────┬───────────┘  │
│             │                            │              │
│  ┌──────────▼────────────┐    ┌──────────▼───────────┐  │
│  │   Drift SQLite DB     │◄───┤     SyncEngine       │  │
│  │ (Favorites, Playlists,│    │ (Push Queue, Pull    │  │
│  │  History, SyncQueue)  │    │  Reconciliation)     │  │
│  └───────────────────────┘    └──────────▲───────────┘  │
└──────────────────────────────────────────┼──────────────┘
                                           │ HTTPS / Bearer Token
┌──────────────────────────────────────────▼──────────────┐
│                Node.js + Express Backend                │
│                                                          │
│  ┌───────────────────────┐    ┌──────────────────────┐  │
│  │     /auth Routes      │    │     /sync Routes     │  │
│  │ (Register, Login, Me) │    │ (Pull, Push Ops)     │  │
│  └──────────┬────────────┘    └──────────┬───────────┘  │
│             │                            │              │
│  ┌──────────▼────────────────────────────▼───────────┐  │
│  │                 CloudStore Factory                │  │
│  │  (MemoryCloudStore  <-->  SupabaseCloudStore)     │  │
│  └──────────────────────┬────────────────────────────┘  │
└─────────────────────────┼───────────────────────────────┘
                          │ PostgreSQL RLS
┌─────────────────────────▼───────────────────────────────┐
│               Supabase / PostgreSQL Cloud               │
│  - profiles (id, email, display_name, avatar_url)       │
│  - cloud_favorites (user_id, song_id, metadata, created)│
│  - cloud_playlists (user_id, id, title, updated_at)     │
│  - cloud_playlist_songs (playlist_id, song_id, order)   │
│  - cloud_listening_history (user_id, song_id, plays)    │
│  - cloud_user_preferences (user_id, settings_json)      │
│  - sync_revisions (user_id, entity_type, revision)      │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Cloud Schema & Supabase RLS Setup

The cloud schema resides in `backend/src/db/schema.sql` and is designed to execute directly in Supabase or any standard PostgreSQL instance.

### Key Schema Tables
1. `public.profiles`: Stores primary user profile details referenced to Supabase's `auth.users(id)` with cascade deletion.
2. `public.cloud_favorites`: User-bookmarked tracks with song metadata JSON and unique `(user_id, song_id)`.
3. `public.cloud_playlists`: User custom playlists with client and server timestamps.
4. `public.cloud_playlist_songs`: Ordered song entries in playlists with unique `(playlist_id, song_id)`.
5. `public.cloud_listening_history`: Play counts and last played timestamps with unique `(user_id, song_id)`.
6. `public.cloud_user_preferences`: User audio preferences (quality, gapless, equalizer, crossfade) serialized as JSON.
7. `public.sync_revisions`: Monotonic revision counters for sync optimization and state hashing.

### Row-Level Security (RLS) Policies
Every cloud table enforces PostgreSQL Row Level Security:
```sql
ALTER TABLE public.cloud_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own cloud_favorites"
  ON public.cloud_favorites
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```
- Non-authenticated requests or requests with tokens belonging to other users are rejected at the database level.
- Cascade deletion ensures that when an account is deleted, all cloud records (favorites, playlists, history, preferences) are cleaned up cleanly.

---

## 3. Environment Variables

### Backend Configuration (`backend/.env`)
```env
# Server
PORT=3000
NODE_ENV=development

# Authentication
JWT_SECRET=super-secret-jwt-key-melo-2026-production-min-32-chars
JWT_REFRESH_SECRET=super-secret-refresh-key-melo-2026-production-min-32-chars
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=30d

# Cloud Store Selection
# Options: 'memory' (for automated vitest, local mock dev) or 'supabase' (for PostgreSQL)
CLOUD_STORE_TYPE=memory

# Supabase Credentials (Required when CLOUD_STORE_TYPE=supabase)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-public-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Jamendo Provider Configuration
JAMENDO_CLIENT_ID=
```

### Flutter Client Configuration
The mobile app communicates with the backend via configurable baseUrl (`MELO_API_URL`, defaults to `http://localhost:3000` or Android emulator `http://10.0.2.2:3000`).

---

## 4. Token Lifecycle & Session Persistence

1. **Registration & Login**:
   - Client sends credentials to `POST /api/auth/register` or `POST /api/auth/login`.
   - Backend issues:
     - `accessToken`: Short-lived JWT (1 hour) containing `{ userId, email, role }`.
     - `refreshToken`: Long-lived JWT (30 days).
     - User profile JSON.
2. **Session Persistence**:
   - Tokens and user metadata are saved in `FlutterSecureSessionStorage` using secure OS keychains (Keystore on Android, Keychain on iOS).
   - In automated testing, `InMemoryAuthSessionStorage` provides an isolated drop-in replacement.
3. **Session Restoration on Launch**:
   - On app startup, `AuthNotifier` reads stored tokens.
   - If an `accessToken` exists, it calls `GET /api/auth/me`. If valid, session is restored seamlessly and initial cloud sync is initiated.
   - If `accessToken` has expired, the client calls `POST /api/auth/refresh` with `refreshToken` to acquire fresh tokens without prompting the user.
   - If refresh fails (revoked or expired), the session is cleared, and the app gracefully remains in local guest mode.
4. **Logout**:
   - `POST /api/auth/logout` revokes tokens server-side.
   - Local storage deletes access token, refresh token, and cached user profile.
   - Local music, history, and playlists remain intact in local SQLite.

---

## 5. Offline-First Sync Queue Mechanics

Sync is governed by Drift's `SyncQueueTable`:
```
SyncQueueTable:
- id: integer (autoIncrement primary key)
- entityType: text ('favorite', 'playlist', 'history', 'preferences')
- entityId: text (ID of the target entity)
- operation: text ('upsert', 'delete')
- payloadJson: text (Serialized entity data)
- clientTimestamp: dateTime
- status: text ('pending', 'syncing', 'completed', 'failed')
- retryCount: integer (exponential backoff tracker)
- lastError: text (diagnostic message)
```

### Workflow
1. **Mutation Staging**: Any user action in the app (favoriting a song, creating a playlist, listening to a track) is committed to Drift SQLite immediately and simultaneously staged into `SyncQueueTable` with status `'pending'`.
2. **Immediate Local Availability**: Local UI updates with zero latency.
3. **Queue Processing**:
   - Triggered on login, network reconnection, periodic interval (every 45s), or manual "Sync Now" tap.
   - `SyncEngine` fetches all `'pending'` or `'failed'` operations (ordered by `clientTimestamp` ASC).
   - Bundles them and posts to `POST /api/sync/push`.
   - On success (200 OK), operations are marked `'completed'` and pruned.
   - On network failure, status is updated to `'failed'`, `retryCount` is incremented, and operations remain safe in SQLite.

---

## 6. Deterministic Conflict Resolution Rules

When reconciling local SQLite state with cloud data:
1. **Favorites**:
   - *Rule*: Latest operation wins (`clientTimestamp` comparison).
   - If a song is marked favorite locally while cloud recorded an earlier unfavorite, local favorite is retained and pushed.
2. **User Preferences**:
   - *Rule*: Last-Write-Wins (LWW) based on `updatedAt`.
   - The version with the higher timestamp is adopted.
3. **Listening History**:
   - *Rule*: Merge play counts and preserve latest timestamp.
   - `mergedPlayCount = max(localPlayCount, cloudPlayCount)`.
   - `mergedLastPlayed = max(localLastPlayed, cloudLastPlayed)`.
   - No listening activity is lost or erased.
4. **Playlists**:
   - *Rule*: Union and merge.
   - Playlists created on multiple devices are unioned.
   - For playlists with identical IDs, the version with the newer `updatedAt` is adopted.

---

## 7. Offline Behavior & Guest Mode Guarantee

- **No Blocking Login Wall**: Users are never forced to authenticate to play music or create playlists.
- **Offline Resilience**: When offline:
  - Playback and library features continue without interruption.
  - The Profile screen displays `Offline (Pending Changes)` with the pending count.
  - As soon as connectivity is restored, the `SyncEngine` drains the queue automatically.
- **Account Deletion**:
  - Requires explicit confirmation via modal dialog.
  - Calls `DELETE /api/auth/me`.
  - Backend purges all cloud records across tables via PostgreSQL cascade.
  - Client clears local tokens and returns smoothly to guest mode.

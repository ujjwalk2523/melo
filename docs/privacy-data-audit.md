# Melo — Privacy & Data Retention Audit

## 1. Overview & Privacy Principles
Melo is built on a **local-first, privacy-by-design** architecture. All critical user listening patterns, audio files, and recommendation matrices operate on-device by default. When cloud synchronization or streaming is utilized, user data transmission is strictly minimized, encrypted in transit, and subject to direct user ownership and deletion controls.

---

## 2. Data Classification Matrix

| Data Category | Storage Location | Retention Policy | Multi-Account Isolation / Logout Behavior |
| :--- | :--- | :--- | :--- |
| **Authentication Tokens** (JWT Access & Refresh) | `FlutterSecureStorage` (Keystore / Keyring) & Backend PostgreSQL | Purged upon explicit logout; invalid upon account deletion | Wiped completely from secure storage; invalidated on backend |
| **User Profile Data** (Email, Display Name) | Local cache & Backend PostgreSQL | Retained until account deletion; never sold or shared | Cleared from in-memory state; overwritten upon subsequent login |
| **Favorites & Playlists** | Drift SQLite (`favorites_table`, `playlists_table`) & Cloud PostgreSQL | Synced bidirectionally; deleted immediately upon user action | Sync queue wiped immediately on logout to prevent cross-account leakage |
| **Listening History** | Drift SQLite (`listening_history_table`) & Cloud PostgreSQL | Preserved for playback continuity and local taste profiling | Can be disabled via privacy toggle; wiped upon account deletion |
| **Recommendation & Feedback Data** | Drift SQLite (`recommendation_feedback_table`) & In-memory cache | 100% on-device; 5-minute cache TTL; permanent feedback records | In-memory cache cleared immediately on logout; preferences reset on deletion |
| **Downloaded Audio** | App-private storage (`downloads/` directory) | Retained until user deletes or clears storage via Profile screen | Scoped to app storage; checksum-verified before playback |
| **Application Logs** | Console / OS logger (`AppLogger`) | Ephemeral (in-memory / developer tools only; no external telemetry server) | All sensitive tokens, passwords, and emails automatically redacted |

---

## 3. Data Flow & Network Exposure

```
┌────────────────────────┐         HTTPS (TLS 1.3)        ┌────────────────────────┐
│      Melo Client       ├───────────────────────────────►│  Melo Express Backend   │
│                        │◄───────────────────────────────┤                        │
│ - No analytics SDKs    │  - Strict JSON schemas         │ - Security Headers     │
│ - No advertising IDs   │  - Bounded payloads (1MB)      │ - Rate Limiting        │
│ - Local recommendations│  - Redacted logs               │ - Supabase / Postgres  │
└────────────────────────┘                                └────────────────────────┘
            │                                                         │
            ▼ Direct Audio Stream                                     ▼
┌────────────────────────┐                                ┌────────────────────────┐
│  Decentralized Nodes   │                                │ Remote Storage/Database│
│  (Audius / Jamendo)    │                                │ (PostgreSQL via SSL)   │
└────────────────────────┘                                └────────────────────────┘
```

---

## 4. Multi-Account Data Isolation
When a user logs out via `authNotifier.logout()` or deletes their account via `authNotifier.deleteAccount()`:
1. **Sync Engine Reset**: `SyncEngine.resetSyncData()` is triggered, immediately dropping all pending sync queue items from `sync_queue_table` and resetting `sync_metadata_table`. This guarantees pending changes from Account A are never uploaded under Account B.
2. **Personalization Cache Purge**: `RecommendationNotifier.resetPersonalization()` purges in-memory taste vectors and candidate rankings.
3. **Secure Storage Excision**: Tokens and refresh credentials are deleted via `FlutterSecureStorage.deleteAll()`.
4. **Account Deletion (Right to be Forgotten)**: Calling `/api/auth/account` issues a cascading SQL delete across `users`, `user_preferences`, `favorites`, `playlists`, `playlist_songs`, and `listening_history` in PostgreSQL.

---

## 5. User Privacy Controls
- **Personalized Recommendations Toggle**: Users can toggle off personalized recommendations in Profile Settings (`pref_personalized_recs`). When disabled, "Made For You" and "Because You Liked" shelves are suppressed from the Home screen feed.
- **Listening History Exemption**: Users can disable history tracking from influencing recommendations via `pref_use_history_recs`.
- **Offline Mode**: When offline mode is active (`pref_offline_only`), zero background network requests or telemetry transmissions occur.
- **Storage Clearing**: Users can clear all downloaded files and local metadata cache at any time with a single tap in Settings.

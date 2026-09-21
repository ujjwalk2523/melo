# Phase 8 — Authorized Downloads and Offline Audio Playback

## 1. Overview & Architecture

Phase 8 implements authorized audio downloads and seamless offline playback in Melo. The architecture strictly adheres to legal and provider licensing requirements: tracks are **only** downloadable if the provider explicitly authorizes it (`isDownloadable == true` and valid `downloadUrl`). There is **zero** stream scraping, URL ripping, or DRM bypass.

### Architecture Highlights
- **Strict Rights Evaluation**: Every download request is validated through `DownloadPermissionEvaluator` before network traffic or disk allocation. Unauthorized tracks are rejected with typed `DownloadNotAuthorizedException` and informative user tooltips.
- **Atomic Two-Phase Storage Sandbox**: Downloads stream to temporary `.part` files in an application-private sandbox (`Melo/downloads/<provider>/<sanitizedTrackId>/audio.part`). Once the stream finishes and integrity is validated, the file is atomically renamed to its final path.
- **Drift SQLite Metadata Persistence**: Download status, file paths, total bytes, timestamps, and error messages persist durable records in `downloads_table` (`schemaVersion = 2`).
- **Concurrent Queue Management**: `DownloadManager` limits simultaneous active downloads to **2** to safeguard device memory, bandwidth, and battery life, automatically queueing subsequent requests.
- **Playback Source Resolution Hierarchy**: `PlaybackSourceResolver` implements a 3-tier deterministic resolution rule:
  1. **Priority 1 (Local File)**: If the track is downloaded and verified on disk, playback uses `LocalFileSource` with zero network overhead.
  2. **Priority 2 (Remote Stream)**: If online and the track is not downloaded, playback streams via `RemoteUrlSource`.
  3. **Priority 3 (Unavailable / Error Recovery)**: If offline and not downloaded, or if local audio has been corrupted/deleted externally, playback resolves to `UnavailableSource` with clear messaging, while auto-repairing database metadata in the background.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          Melo Flutter Client                            │
│                                                                         │
│  ┌──────────────────────┐               ┌───────────────────────────┐   │
│  │   FullPlayerScreen   │               │       ProfileScreen       │   │
│  │ (Download / Tooltip) │               │   (Clear Storage / Usage) │   │
│  └──────────┬───────────┘               └─────────────┬─────────────┘   │
│             │                                         │                 │
│  ┌──────────▼─────────────────────────────────────────▼─────────────┐   │
│  │                     DownloadManager                              │   │
│  │  - Max 2 concurrent tasks                                        │   │
│  │  - Queue scheduling & cancellation                               │   │
│  │  - .part file cleanup on cancel/failure                          │   │
│  └──────┬───────────────────┬─────────────────────────┬─────────────┘   │
│         │                   │                         │                 │
│  ┌──────▼────────────┐ ┌────▼─────────────────┐ ┌─────▼──────────────┐  │
│  │ DownloadStorage   │ │ DownloadRepository   │ │ PermissionEvaluator│  │
│  │ (App-Private Dir) │ │ (Drift SQLite DB)    │ │ (isDownloadable)   │  │
│  └──────┬────────────┘ └────┬─────────────────┘ └────────────────────┘  │
│         │                   │                                           │
│  ┌──────▼───────────────────▼────────────────────────────────────────┐  │
│  │               PlaybackSourceResolver                              │  │
│  │  1. Valid Local File  --> LocalFileSource                         │  │
│  │  2. Online Stream     --> RemoteUrlSource                         │  │
│  │  3. Offline/Missing   --> UnavailableSource                       │  │
│  └──────────────────────────┬────────────────────────────────────────┘  │
│                             │                                           │
│  ┌──────────────────────────▼────────────────────────────────────────┐  │
│  │             PlayerNotifier  / AudioPlayerService                  │  │
│  │  - setFilePath(path) for local audio files                        │  │
│  │  - setUrl(url) for streaming audio                                │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ Authorized Download Stream
                                      ▼
             ┌──────────────────────────────────────────────────┐
             │       Node.js Backend & Provider APIs            │
             │ - GET /api/tracks/:provider/:trackId/download-info│
             │ - Audius & Jamendo Direct Provider Downloads      │
             └──────────────────────────────────────────────────┘
```

---

## 2. Provider Rights & Authorization Verification

### Rights Evaluation Rule
Downloads are authorized **only** when:
1. `song.isDownloadable == true`
2. `song.downloadUrl != null && song.downloadUrl.isNotEmpty`

If a song cannot be downloaded:
- In the player UI: The download button displays a disabled icon with a tooltip: `"Offline download isn't available for this track."`
- In `DownloadManager`: Calling `downloadTrack(song)` throws `DownloadNotAuthorizedException` without initiating any network connection.

### Backend Download Info Endpoint
`GET /api/tracks/:provider/:trackId/download-info` returns verified provider authorization:
```json
{
  "provider": "jamendo",
  "trackId": "12345",
  "isDownloadable": true,
  "downloadUrl": "https://mp3d.jamendo.com/download/track/12345/mp32",
  "format": "mp3",
  "bitrate": "320kbps",
  "license": "Creative Commons"
}
```

---

## 3. Storage Hierarchy & Atomic File Commit

### Application Directory Sandbox
Audio files are sandboxed inside the app's document folder to prevent exposure to external file scanners or partial reads:
```
<AppDocumentsDir>/Melo/downloads/<provider>/<sanitizedTrackId>/audio.mp3
```

### Two-Phase Atomic Commit
1. **Streaming Phase**: Audio chunks are written to `<path>.part`.
2. **Progress Monitoring**: Progress callbacks stream byte updates `(receivedBytes / totalBytes)`.
3. **Atomic Rename**: Upon successful stream completion, the temporary file is atomically renamed to `audio.mp3`.
4. **Cleanup on Abort**: If cancelled, interrupted, or failed, the `.part` file is immediately deleted to avoid orphaned disk usage.

---

## 4. Concurrency Limiting & Queue Scheduling

- **Max 2 Concurrent Active Downloads**: If 3 or more tracks are queued, tracks 1 and 2 start downloading immediately (`DownloadStatus.downloading`), while track 3 enters `DownloadStatus.pending`.
- **FIFO Processing**: When an active download finishes, fails, or is cancelled, `DownloadManager._processNextInQueue()` immediately promotes the next pending task.
- **Durable Cancellation**: Users can cancel in-flight downloads. The `CancellationToken` terminates the active HTTP response stream, closes the file sink, and removes the `.part` file.

---

## 5. Playback Source Resolution Priority

`PlaybackSourceResolver` handles audio source resolution dynamically:

| Condition | Resolved AudioSource | Behavior |
| :--- | :--- | :--- |
| Downloaded & valid on disk | `LocalFileSource` | Audio plays locally from private sandbox with 0 network usage. |
| Not downloaded, network online | `RemoteUrlSource` | Audio streams from remote provider URL. |
| Offline mode enabled, not downloaded | `UnavailableSource` | Playback blocked; displays `"Offline-only mode is active and this track is not downloaded."` |
| Network disconnected, not downloaded | `UnavailableSource` | Playback blocked; displays `"No internet connection and track is not downloaded."` |
| Download record exists, but file deleted from disk | `RemoteUrlSource` (online) or `UnavailableSource` (offline) | Graceful fallback: repairs DB record to `failed` and streams remotely if online. |

---

## 6. UI Integration

- **FullPlayerScreen**:
  - `DownloadStatus.notDownloaded`: Outlined download icon triggers `downloadTrack`.
  - `DownloadStatus.pending` / `downloading`: Subtle circular progress indicator showing download percentage.
  - `DownloadStatus.completed`: Filled primary download badge with option to remove download.
  - `DownloadStatus.failed`: Warning icon with one-tap retry.
  - Not downloadable: Disabled icon with informative tooltip.
- **ProfileScreen**:
  - `Storage & Offline Mode` section shows total audio storage usage (e.g., `42.5 MB`).
  - `Clear All Downloads` action triggers confirmation dialog, removes all audio files from disk, and resets database download tables.
- **LibraryScreen**:
  - `Downloads` tab filters catalog to offline-available tracks backed by real-time Drift database stream.

---

## 7. Verification & Test Results

### Flutter Client Suite
- **100% Pass Rate**: 98 tests passed across all Phase 1–8 test suites:
  - `phase8_downloads_test.dart` (18/18 passed)
  - `phase7_auth_sync_test.dart` (27/27 passed)
  - `phase5_jamendo_test.dart` (11/11 passed)
  - `phase4_catalog_test.dart` (8/8 passed)
  - `phase3_player_test.dart` (9/9 passed)
  - `phase2_ui_test.dart` (13/13 passed)
  - `widget_test.dart` (12/12 passed)
- **Static Analysis**: `flutter analyze` completed with **0 issues found**.

### Node.js Backend Suite
- **100% Pass Rate**: 44 tests passed across all 7 test files in Vitest:
  - `tests/download.test.ts` (8/8 passed)
  - `tests/sync.test.ts` (7/7 passed)
  - `tests/auth.test.ts` (14/14 passed)
  - `tests/search-validation.test.ts` (4/4 passed)
  - `tests/provider-normalization.test.ts` (5/5 passed)
  - `tests/music-service.test.ts` (4/4 passed)
  - `tests/health.test.ts` (2/2 passed)
- **TypeScript Build**: `npm run build` succeeds with 0 errors.

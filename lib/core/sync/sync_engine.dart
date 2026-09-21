// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../../features/profile/data/user_preferences_repository.dart';
import 'sync_conflict_resolver.dart';
import 'sync_queue.dart';
import 'sync_repository.dart';
import 'sync_state.dart';

class SyncEngine {
  final AppDatabase _db;
  final SyncQueue _queue;
  final SyncRepository _api;
  final UserPreferencesRepository? _preferencesRepo;

  SyncState _state = const SyncState();
  final _stateController = StreamController<SyncState>.broadcast();
  Timer? _debounceTimer;
  bool _isSyncing = false;
  bool _isDisposed = false;

  SyncEngine({
    required AppDatabase db,
    required SyncQueue queue,
    required SyncRepository api,
    UserPreferencesRepository? preferencesRepo,
  }) : _db = db,
       _queue = queue,
       _api = api,
       _preferencesRepo = preferencesRepo {
    _loadInitialMetadata();
  }

  SyncState get state => _state;
  Stream<SyncState> get stateStream => _stateController.stream;

  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    if (!_stateController.isClosed) {
      _stateController.close();
    }
  }

  Future<void> _loadInitialMetadata() async {
    if (_isDisposed) return;
    try {
      final meta = await (_db.select(
        _db.syncMetadataTable,
      )..where((tbl) => tbl.id.equals('default'))).getSingleOrNull();

      final pending = await _queue.getPendingCount();

      _updateState(
        _state.copyWith(
          lastSuccessfulSyncAt: meta?.lastSuccessfulSyncAt,
          lastAttemptedSyncAt: meta?.lastAttemptedSyncAt,
          pendingCount: pending,
          status: pending > 0 ? SyncStatus.pending : SyncStatus.idle,
          lastError: meta?.lastSyncError,
        ),
      );
    } catch (_) {}
  }

  void _updateState(SyncState newState) {
    if (_isDisposed || _stateController.isClosed) return;
    _state = newState;
    _stateController.add(_state);
  }

  /// Called after local Drift writes to queue a change and schedule push.
  Future<void> enqueueOperation({
    required String id,
    String? userId,
    required String entityType,
    required String entityId,
    required String operationType,
    required Map<String, dynamic> payload,
    String? authToken,
  }) async {
    if (_isDisposed) return;
    try {
      await _queue.enqueue(
        id: id,
        userId: userId,
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        payload: payload,
      );

      if (_isDisposed) return;
      final pending = await _queue.getPendingCount();
      _updateState(
        _state.copyWith(pendingCount: pending, status: SyncStatus.pending),
      );

      // If authenticated, debounce push to avoid flooding backend
      if (authToken != null && authToken.isNotEmpty) {
        scheduleDebouncedPush(authToken);
      }
    } catch (_) {
      // Guard against concurrent database close during test disposal
    }
  }

  void scheduleDebouncedPush(String authToken) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      triggerPush(authToken);
    });
  }

  /// Executes login sync: merges cloud state with local state, then uploads pending local ops.
  Future<void> performLoginSync(String authToken, String userId) async {
    if (_isSyncing) return;
    _isSyncing = true;
    _updateState(
      _state.copyWith(
        status: SyncStatus.syncing,
        lastAttemptedSyncAt: DateTime.now(),
        clearError: true,
      ),
    );

    try {
      // 1. Pull cloud state
      final cloudData = await _api.pullState(authToken);

      // 2. Merge favorites into local database
      for (final fav in cloudData.favorites) {
        final songId = fav['songId'] as String;
        final isDeleted = fav['isDeleted'] as bool? ?? false;
        final metadata = fav['songMetadata'] as Map<String, dynamic>? ?? {};

        if (!isDeleted) {
          // Ensure normalized song metadata is cached in SongsTable
          if (metadata.isNotEmpty) {
            await _db
                .into(_db.songsTable)
                .insertOnConflictUpdate(
                  SongsTableCompanion(
                    id: Value(songId),
                    provider: Value(metadata['provider'] as String? ?? 'melo'),
                    providerTrackId: Value(
                      metadata['providerTrackId'] as String?,
                    ),
                    title: Value(
                      metadata['title'] as String? ?? 'Unknown Title',
                    ),
                    artist: Value(
                      metadata['artist'] as String? ?? 'Unknown Artist',
                    ),
                    album: Value(
                      metadata['album'] as String? ?? 'Unknown Album',
                    ),
                    artworkUrl: Value(metadata['artworkUrl'] as String? ?? ''),
                    durationMs: Value(metadata['durationMs'] as int? ?? 180000),
                    streamUrl: Value(metadata['streamUrl'] as String?),
                    isDownloadable: Value(
                      metadata['isDownloadable'] as bool? ?? false,
                    ),
                    genre: Value(metadata['genre'] as String?),
                    updatedAt: Value(DateTime.now()),
                  ),
                );
          }

          // Insert into local FavoritesTable if not present
          final existing = await (_db.select(
            _db.favoritesTable,
          )..where((tbl) => tbl.songId.equals(songId))).getSingleOrNull();

          if (existing == null) {
            await _db
                .into(_db.favoritesTable)
                .insert(
                  FavoritesTableCompanion.insert(
                    songId: songId,
                    createdAt: Value(
                      fav['createdAt'] != null
                          ? DateTime.parse(fav['createdAt'] as String)
                          : DateTime.now(),
                    ),
                  ),
                );
          }
        }
      }

      // 3. Merge playlists into local database
      for (final pl in cloudData.playlists) {
        final playlistId = pl['id'] as String;
        final isDeleted = pl['isDeleted'] as bool? ?? false;

        if (isDeleted) {
          await (_db.delete(
            _db.playlistsTable,
          )..where((tbl) => tbl.id.equals(playlistId))).go();
        } else {
          await _db
              .into(_db.playlistsTable)
              .insertOnConflictUpdate(
                PlaylistsTableCompanion(
                  id: Value(playlistId),
                  name: Value(pl['name'] as String? ?? 'Untitled'),
                  description: Value(pl['description'] as String?),
                  artworkUrl: Value(pl['artworkUrl'] as String?),
                  createdAt: Value(
                    pl['createdAt'] != null
                        ? DateTime.parse(pl['createdAt'] as String)
                        : DateTime.now(),
                  ),
                  updatedAt: Value(
                    pl['updatedAt'] != null
                        ? DateTime.parse(pl['updatedAt'] as String)
                        : DateTime.now(),
                  ),
                ),
              );
        }
      }

      // 4. Merge playlist songs
      for (final s in cloudData.playlistSongs) {
        final playlistId = s['playlistId'] as String;
        final songId = s['songId'] as String;
        final pos = s['position'] as int? ?? 0;
        final metadata = s['songMetadata'] as Map<String, dynamic>? ?? {};

        // Ensure song exists in SongsTable
        if (metadata.isNotEmpty) {
          await _db
              .into(_db.songsTable)
              .insertOnConflictUpdate(
                SongsTableCompanion(
                  id: Value(songId),
                  provider: Value(metadata['provider'] as String? ?? 'melo'),
                  title: Value(metadata['title'] as String? ?? 'Song'),
                  artist: Value(metadata['artist'] as String? ?? 'Artist'),
                  album: Value(metadata['album'] as String? ?? 'Album'),
                  artworkUrl: Value(metadata['artworkUrl'] as String? ?? ''),
                  durationMs: Value(metadata['durationMs'] as int? ?? 180000),
                ),
              );
        }

        // Insert into playlist_songs
        final exists =
            await (_db.select(_db.playlistSongsTable)..where(
                  (tbl) =>
                      tbl.playlistId.equals(playlistId) &
                      tbl.songId.equals(songId),
                ))
                .getSingleOrNull();

        if (exists == null) {
          await _db
              .into(_db.playlistSongsTable)
              .insert(
                PlaylistSongsTableCompanion.insert(
                  playlistId: playlistId,
                  songId: songId,
                  position: Value(pos),
                ),
              );
        }
      }

      // 5. Merge listening history
      for (final h in cloudData.history) {
        final songId = h['songId'] as String;
        final count = h['playCount'] as int? ?? 1;
        final playedAt = h['playedAt'] != null
            ? DateTime.parse(h['playedAt'] as String)
            : DateTime.now();

        final existing = await (_db.select(
          _db.listeningHistoryTable,
        )..where((tbl) => tbl.songId.equals(songId))).getSingleOrNull();

        if (existing == null) {
          await _db
              .into(_db.listeningHistoryTable)
              .insert(
                ListeningHistoryTableCompanion.insert(
                  songId: songId,
                  playedAt: Value(playedAt),
                  playCount: Value(count),
                ),
              );
        } else {
          final merged = SyncConflictResolver.mergeHistoryEntry(
            localPlayCount: existing.playCount,
            localPlayedAt: existing.playedAt,
            cloudPlayCount: count,
            cloudPlayedAt: playedAt,
          );
          await (_db.update(
            _db.listeningHistoryTable,
          )..where((tbl) => tbl.id.equals(existing.id))).write(
            ListeningHistoryTableCompanion(
              playCount: Value(merged.playCount),
              playedAt: Value(merged.playedAt),
            ),
          );
        }
      }

      // 6. Merge preferences
      if (cloudData.preferences != null && _preferencesRepo != null) {
        final p = cloudData.preferences!;

        // Check if cloud prefs should apply
        if (p['audioQuality'] != null) {
          await _preferencesRepo.setAudioQuality(p['audioQuality'] as String);
        }
        if (p['gaplessPlayback'] != null) {
          await _preferencesRepo.setGaplessPlayback(
            p['gaplessPlayback'] as bool,
          );
        }
        if (p['normalizeVolume'] != null) {
          await _preferencesRepo.setNormalizeVolume(
            p['normalizeVolume'] as bool,
          );
        }
        if (p['crossfadeDuration'] != null) {
          final cd = (p['crossfadeDuration'] as num).toDouble();
          await _preferencesRepo.setCrossfadeDuration(cd);
        }
      }

      // 7. Push local pending operations
      await _pushPendingOpsInternal(authToken);

      // 8. Record successful sync metadata
      final now = DateTime.now();
      await _db
          .into(_db.syncMetadataTable)
          .insertOnConflictUpdate(
            SyncMetadataTableCompanion(
              id: const Value('default'),
              lastSuccessfulSyncAt: Value(now),
              lastAttemptedSyncAt: Value(now),
              pendingOperationCount: const Value(0),
              lastSyncError: const Value(null),
            ),
          );

      _updateState(
        _state.copyWith(
          status: SyncStatus.success,
          lastSuccessfulSyncAt: now,
          lastAttemptedSyncAt: now,
          pendingCount: 0,
          clearError: true,
        ),
      );
    } catch (e) {
      final now = DateTime.now();
      final errStr = e.toString();
      final isOffline =
          errStr.toLowerCase().contains('offline') ||
          errStr.toLowerCase().contains('cannot reach server');

      _updateState(
        _state.copyWith(
          status: isOffline ? SyncStatus.offline : SyncStatus.error,
          lastAttemptedSyncAt: now,
          lastError: errStr,
        ),
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Triggers push of any pending queue operations to cloud.
  Future<void> triggerPush(String authToken) async {
    if (_isSyncing) return;
    _isSyncing = true;
    _updateState(_state.copyWith(status: SyncStatus.syncing));

    try {
      await _pushPendingOpsInternal(authToken);
      final now = DateTime.now();
      final remaining = await _queue.getPendingCount();

      await _db
          .into(_db.syncMetadataTable)
          .insertOnConflictUpdate(
            SyncMetadataTableCompanion(
              id: const Value('default'),
              lastSuccessfulSyncAt: Value(now),
              lastAttemptedSyncAt: Value(now),
              pendingOperationCount: Value(remaining),
              lastSyncError: const Value(null),
            ),
          );

      _updateState(
        _state.copyWith(
          status: remaining > 0 ? SyncStatus.pending : SyncStatus.success,
          lastSuccessfulSyncAt: now,
          pendingCount: remaining,
          clearError: true,
        ),
      );
    } catch (e) {
      final errStr = e.toString();
      final isOffline =
          errStr.toLowerCase().contains('offline') ||
          errStr.toLowerCase().contains('cannot reach server');

      _updateState(
        _state.copyWith(
          status: isOffline ? SyncStatus.offline : SyncStatus.error,
          lastError: errStr,
        ),
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _pushPendingOpsInternal(String authToken) async {
    final pendingOps = await _queue.getPendingOperations();
    if (pendingOps.isEmpty) return;

    await _api.pushOperations(authToken, pendingOps);
    await _queue.markCompleted(pendingOps.map((o) => o.id).toList());
  }

  Future<void> manualSync(String? authToken, String? userId) async {
    if (authToken == null || authToken.isEmpty || userId == null) {
      _updateState(_state.copyWith(status: SyncStatus.idle));
      return;
    }
    await performLoginSync(authToken, userId);
  }

  /// Clears queued operations, resets sync metadata and local sync state on logout.
  Future<void> resetSyncData() async {
    _debounceTimer?.cancel();
    try {
      await _queue.clearAll();
      await (_db.delete(_db.syncMetadataTable)).go();
    } catch (_) {}
    _updateState(const SyncState());
  }
}

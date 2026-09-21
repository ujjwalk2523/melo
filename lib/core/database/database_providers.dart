import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/features/downloads/data/download_metadata_repository_impl.dart';
import 'package:melo/features/downloads/domain/download_metadata_repository.dart';
import 'package:melo/features/favorites/data/favorites_repository_impl.dart';
import 'package:melo/features/favorites/domain/favorites_repository.dart';
import 'package:melo/features/history/data/history_repository_impl.dart';
import 'package:melo/features/history/domain/history_repository.dart';
import 'package:melo/features/player/data/player_snapshot_repository.dart';
import 'package:melo/features/playlists/data/playlist_repository_impl.dart';
import 'package:melo/features/playlists/domain/playlist_models.dart';
import 'package:melo/features/playlists/domain/playlist_repository.dart';
import 'package:melo/features/profile/data/user_preferences_repository.dart';
import 'package:melo/shared/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:melo/core/sync/sync_engine.dart';
import 'package:melo/core/sync/sync_providers.dart';
import 'package:melo/features/auth/providers/auth_provider.dart';

/// Database instance provider. Uses in-memory database during tests.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  final isTest = Platform.environment.containsKey('FLUTTER_TEST');
  final db = isTest ? AppDatabase.memory() : AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

String? _safeReadToken(Ref ref) {
  try {
    return ref.read(authStateProvider).accessToken;
  } catch (_) {
    return null;
  }
}

/// Favorites repository provider.
final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncEngine = ref.watch(syncEngineProvider);
  return FavoritesRepositoryImpl(db, syncEngine, () => _safeReadToken(ref));
});

/// History repository provider.
final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncEngine = ref.watch(syncEngineProvider);
  return HistoryRepositoryImpl(db, syncEngine, () => _safeReadToken(ref));
});

/// Playlist repository provider.
final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final syncEngine = ref.watch(syncEngineProvider);
  return PlaylistRepositoryImpl(db, syncEngine, () => _safeReadToken(ref));
});

/// Download metadata repository provider.
final downloadMetadataRepositoryProvider = Provider<DownloadMetadataRepository>(
  (ref) {
    final db = ref.watch(appDatabaseProvider);
    return DownloadMetadataRepositoryImpl(db);
  },
);

/// Player snapshot repository provider.
final playerSnapshotRepositoryProvider = Provider<PlayerSnapshotRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return PlayerSnapshotRepositoryImpl(db);
});

/// SharedPreferences instance provider (can be overridden in ProviderScope).
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

/// User preferences repository provider.
final userPreferencesRepositoryProvider = Provider<UserPreferencesRepository?>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  if (prefs == null) return null;
  return UserPreferencesRepository(prefs);
});

/// StateNotifier for reactive user preferences in Profile screen.
class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final UserPreferencesRepository? _repo;
  final SyncEngine? _syncEngine;
  final String? Function()? _getAuthToken;

  UserPreferencesNotifier(this._repo, [this._syncEngine, this._getAuthToken])
    : super(_repo?.getPreferences() ?? const UserPreferences());

  void _enqueueSync() {
    _syncEngine?.enqueueOperation(
      id: 'op_pref_${DateTime.now().millisecondsSinceEpoch}',
      entityType: 'preference',
      entityId: 'preferences',
      operationType: 'upsert',
      payload: {
        'audioQuality': state.audioQuality,
        'gaplessPlayback': state.gaplessPlayback,
        'normalizeVolume': state.normalizeVolume,
        'crossfadeDuration': state.crossfadeDuration,
        'offlineOnly': state.offlineOnly,
        'downloadOnWifiOnly': state.downloadOnWifiOnly,
      },
      authToken: _getAuthToken?.call(),
    );
  }

  Future<void> setAudioQuality(String quality) async {
    state = state.copyWith(audioQuality: quality);
    await _repo?.setAudioQuality(quality);
    _enqueueSync();
  }

  Future<void> setGaplessPlayback(bool enabled) async {
    state = state.copyWith(gaplessPlayback: enabled);
    await _repo?.setGaplessPlayback(enabled);
    _enqueueSync();
  }

  Future<void> setNormalizeVolume(bool enabled) async {
    state = state.copyWith(normalizeVolume: enabled);
    await _repo?.setNormalizeVolume(enabled);
    _enqueueSync();
  }

  Future<void> setCrossfadeDuration(double seconds) async {
    state = state.copyWith(crossfadeDuration: seconds);
    await _repo?.setCrossfadeDuration(seconds);
    _enqueueSync();
  }

  Future<void> setOfflineOnly(bool enabled) async {
    state = state.copyWith(offlineOnly: enabled);
    await _repo?.setOfflineOnly(enabled);
    _enqueueSync();
  }

  Future<void> setDownloadOnWifiOnly(bool enabled) async {
    state = state.copyWith(downloadOnWifiOnly: enabled);
    await _repo?.setDownloadOnWifiOnly(enabled);
    _enqueueSync();
  }

  Future<void> setPersonalizedRecommendations(bool enabled) async {
    state = state.copyWith(personalizedRecommendations: enabled);
    await _repo?.setPersonalizedRecommendations(enabled);
    _enqueueSync();
  }

  Future<void> setUseListeningHistoryForRecs(bool enabled) async {
    state = state.copyWith(useListeningHistoryForRecs: enabled);
    await _repo?.setUseListeningHistoryForRecs(enabled);
    _enqueueSync();
  }

  Future<void> setDiscoveryLevel(String level) async {
    state = state.copyWith(discoveryLevel: level);
    await _repo?.setDiscoveryLevel(level);
    _enqueueSync();
  }

  Future<void> resetPersonalizationPreferences() async {
    state = state.copyWith(
      personalizedRecommendations: true,
      useListeningHistoryForRecs: true,
      discoveryLevel: 'balanced',
    );
    await _repo?.resetPersonalizationPreferences();
    _enqueueSync();
  }
}

final userPreferencesNotifierProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
      final repo = ref.watch(userPreferencesRepositoryProvider);
      final syncEngine = ref.watch(syncEngineProvider);
      return UserPreferencesNotifier(
        repo,
        syncEngine,
        () => _safeReadToken(ref),
      );
    });

/// Reactive stream of favorited song IDs for instant O(1) checks in UI.
final favoriteSongIdsStreamProvider = StreamProvider<Set<String>>((ref) {
  final repo = ref.watch(favoritesRepositoryProvider);
  return repo.watchFavoriteIds();
});

/// Reactive stream of all favorited songs.
final favoriteSongsStreamProvider = StreamProvider<List<Song>>((ref) {
  final repo = ref.watch(favoritesRepositoryProvider);
  return repo.watchFavorites();
});

/// Reactive stream of recently played songs.
final recentlyPlayedStreamProvider = StreamProvider<List<Song>>((ref) {
  final repo = ref.watch(historyRepositoryProvider);
  return repo.watchRecentlyPlayed();
});

/// Reactive stream of user playlists.
final userPlaylistsStreamProvider = StreamProvider<List<Playlist>>((ref) {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.watchPlaylists();
});

/// Reactive stream of downloaded song IDs.
final downloadedSongIdsStreamProvider = StreamProvider<Set<String>>((ref) {
  final repo = ref.watch(downloadMetadataRepositoryProvider);
  return repo.watchDownloadedSongIds();
});

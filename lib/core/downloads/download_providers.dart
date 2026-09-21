import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/song.dart';
import '../database/database_providers.dart';
import 'download_manager.dart';
import 'download_repository.dart';
import 'download_service.dart';
import 'download_state.dart';
import 'download_storage.dart';

/// Provider for the app-private download filesystem storage.
final downloadStorageProvider = Provider<DownloadStorage>((ref) {
  return DownloadStorage();
});

/// Provider for the HTTP streaming download service.
final downloadServiceProvider = Provider<DownloadService>((ref) {
  return HttpDownloadService();
});

/// Provider for the DownloadRepository bridge to Drift.
final downloadRepositoryProvider = Provider<DownloadRepository>((ref) {
  final metaRepo = ref.watch(downloadMetadataRepositoryProvider);
  return DownloadRepository(metaRepo);
});

/// Central download manager coordinating queue, concurrency, and persistence.
final downloadManagerProvider = Provider<DownloadManager>((ref) {
  final storage = ref.watch(downloadStorageProvider);
  final service = ref.watch(downloadServiceProvider);
  final repository = ref.watch(downloadRepositoryProvider);
  final prefs = ref.watch(userPreferencesRepositoryProvider);

  final manager = DownloadManager(
    storage: storage,
    service: service,
    repository: repository,
    preferencesRepo: prefs,
  );

  if (!Platform.environment.containsKey('FLUTTER_TEST')) {
    manager.initialize();
  }

  ref.onDispose(() => manager.dispose());
  return manager;
});

/// Reactive stream provider for all currently downloaded song IDs.
final downloadedSongIdsProvider = StreamProvider<Set<String>>((ref) {
  final manager = ref.watch(downloadManagerProvider);
  return manager.watchDownloadedSongIds();
});

/// Reactive provider emitting the full list of downloaded [Song] models.
final downloadedSongsProvider = FutureProvider<List<Song>>((ref) async {
  // Re-run whenever the set of completed song IDs changes
  ref.watch(downloadedSongIdsProvider);
  final manager = ref.watch(downloadManagerProvider);
  return manager.getDownloadedSongs();
});

/// Stream provider for the reactive download state of an individual song.
final trackDownloadStateProvider =
    StreamProvider.family<TrackDownloadState, String>((ref, songId) {
  final manager = ref.watch(downloadManagerProvider);
  return manager.watchTrackDownloadState(songId);
});

/// Provider for total storage bytes consumed by downloaded audio.
final downloadStorageSizeProvider = FutureProvider<int>((ref) async {
  final manager = ref.watch(downloadManagerProvider);
  return manager.getTotalStorageBytes();
});

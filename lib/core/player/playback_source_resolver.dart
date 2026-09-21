import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/downloads/domain/download_metadata_repository.dart';
import '../../features/profile/data/user_preferences_repository.dart';
import '../../shared/models/song.dart';
import '../database/database_providers.dart';
import '../downloads/download_providers.dart';
import '../downloads/download_repository.dart';
import '../downloads/download_storage.dart';

/// Resolved audio playback source for the Melo audio player engine.
sealed class PlaybackSource {
  final Song song;

  const PlaybackSource(this.song);
}

/// Indicates audio should be played directly from an authorized local file.
class LocalFileSource extends PlaybackSource {
  final String filePath;

  const LocalFileSource(this.filePath, Song song) : super(song);
}

/// Indicates audio should be streamed from an authorized remote URL.
class RemoteUrlSource extends PlaybackSource {
  final String url;

  const RemoteUrlSource(this.url, Song song) : super(song);
}

/// Indicates the track cannot be played due to offline restrictions or missing resources.
class UnavailableSource extends PlaybackSource {
  final String reason;

  const UnavailableSource(this.reason, Song song) : super(song);
}

/// Central resolver implementing strict playback priority:
/// 1. Valid local authorized download
/// 2. Authorized remote stream (unless offline-only mode or disconnected)
/// 3. Unavailable with friendly reason
class PlaybackSourceResolver {
  final DownloadRepository downloadRepo;
  final DownloadStorage downloadStorage;
  final UserPreferencesRepository? preferencesRepo;

  /// Function to check network connectivity state.
  bool Function()? isNetworkOnline;

  PlaybackSourceResolver({
    required this.downloadRepo,
    required this.downloadStorage,
    this.preferencesRepo,
    this.isNetworkOnline,
  });

  /// Resolves the concrete playback source for a given song.
  Future<PlaybackSource> resolve(Song song) async {
    final prefs = preferencesRepo?.getPreferences();
    final offlineOnly = prefs?.offlineOnly ?? false;
    final isOnline = isNetworkOnline?.call() ?? true;

    // 1. Priority 1: Check for completed local download
    final meta = await downloadRepo.getMetadata(song.id);
    if (meta != null &&
        meta.status == DownloadStatus.completed &&
        meta.localPath != null) {
      final isValid = await downloadStorage.validateExistingFile(
        meta.localPath!,
      );
      if (isValid) {
        return LocalFileSource(meta.localPath!, song);
      } else {
        // File corrupted or removed externally: repair metadata
        await downloadRepo.recordFailed(
          songId: song.id,
          errorMessage: 'Downloaded file is missing or corrupted on disk.',
        );
      }
    }

    // 2. Offline-only mode check
    if (offlineOnly) {
      return UnavailableSource(
        'Offline-only mode is active and this track is not downloaded.',
        song,
      );
    }

    // 3. Network availability check
    if (!isOnline) {
      return UnavailableSource(
        'No internet connection and track is not downloaded for offline playback.',
        song,
      );
    }

    // 4. Priority 2: Authorized remote stream
    final streamUrl = song.streamUrl?.trim();
    if (streamUrl != null && streamUrl.isNotEmpty) {
      return RemoteUrlSource(streamUrl, song);
    }

    // 5. Unavailable
    return UnavailableSource('Playback is unavailable for this track.', song);
  }
}

/// Riverpod provider for [PlaybackSourceResolver].
final playbackSourceResolverProvider = Provider<PlaybackSourceResolver>((ref) {
  final downloadRepo = ref.watch(downloadRepositoryProvider);
  final downloadStorage = ref.watch(downloadStorageProvider);
  final prefsRepo = ref.watch(userPreferencesRepositoryProvider);
  return PlaybackSourceResolver(
    downloadRepo: downloadRepo,
    downloadStorage: downloadStorage,
    preferencesRepo: prefsRepo,
  );
});

import '../../features/downloads/domain/download_metadata_repository.dart';
import '../../shared/models/song.dart';
import 'download_state.dart';

/// Repository coordinating download metadata persistence in the local Drift SQLite database.
class DownloadRepository {
  final DownloadMetadataRepository _metadataRepo;

  DownloadRepository(this._metadataRepo);

  /// Initializes download tracking for a song in pending or downloading state.
  Future<void> recordDownloadStarted(Song song) async {
    await _metadataRepo.recordDownloadMetadata(
      song: song,
      status: DownloadStatus.downloading,
      downloadedBytes: 0,
      totalBytes: 0,
    );
  }

  /// Updates byte progress in Drift metadata.
  Future<void> recordProgress({
    required String songId,
    required int bytesDownloaded,
    required int totalBytes,
  }) async {
    await _metadataRepo.updateStatus(
      songId,
      DownloadStatus.downloading,
      downloadedBytes: bytesDownloaded,
      totalBytes: totalBytes,
    );
  }

  /// Marks a download as completed with its validated local path.
  Future<void> recordCompleted({
    required String songId,
    required String localPath,
    required int totalBytes,
  }) async {
    await _metadataRepo.updateStatus(
      songId,
      DownloadStatus.completed,
      localPath: localPath,
      downloadedBytes: totalBytes,
      totalBytes: totalBytes,
      errorMessage: null,
    );
  }

  /// Marks a download as failed with user-facing diagnostic reason.
  Future<void> recordFailed({
    required String songId,
    required String errorMessage,
  }) async {
    await _metadataRepo.updateStatus(
      songId,
      DownloadStatus.failed,
      errorMessage: errorMessage,
    );
  }

  /// Marks a download as paused.
  Future<void> recordPaused(String songId) async {
    await _metadataRepo.updateStatus(songId, DownloadStatus.paused);
  }

  /// Marks a download as cancelled.
  Future<void> recordCancelled(String songId) async {
    await _metadataRepo.updateStatus(songId, DownloadStatus.cancelled);
  }

  /// Removes download metadata from Drift database.
  Future<void> removeDownload(String songId) async {
    await _metadataRepo.removeDownloadMetadata(songId);
  }

  /// Returns all completed downloaded songs from local database.
  Future<List<Song>> getDownloadedSongs() {
    return _metadataRepo.getDownloadedSongs();
  }

  /// Continuous reactive stream of downloaded song IDs.
  Stream<Set<String>> watchDownloadedSongIds() {
    return _metadataRepo.watchDownloadedSongIds();
  }

  /// Retrieves metadata for a specific song if it exists.
  Future<DownloadMetadata?> getMetadata(String songId) {
    return _metadataRepo.getMetadata(songId);
  }

  /// Converts persistent Drift [DownloadMetadata] into reactive [TrackDownloadState].
  TrackDownloadState toTrackDownloadState(DownloadMetadata meta) {
    final progress = (meta.totalBytes > 0)
        ? (meta.downloadedBytes / meta.totalBytes).clamp(0.0, 1.0)
        : (meta.status == DownloadStatus.completed ? 1.0 : 0.0);

    return TrackDownloadState(
      songId: meta.songId,
      status: meta.status,
      progress: progress,
      bytesDownloaded: meta.downloadedBytes,
      totalBytes: meta.totalBytes,
      localPath: meta.localPath,
      errorMessage: meta.errorMessage,
    );
  }
}

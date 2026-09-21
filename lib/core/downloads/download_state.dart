import '../../features/downloads/domain/download_metadata_repository.dart';

/// Reactive state of a song's offline download lifecycle.
class TrackDownloadState {
  final String songId;
  final DownloadStatus status;
  final double progress; // 0.0 to 1.0
  final int bytesDownloaded;
  final int totalBytes;
  final String? localPath;
  final String? errorMessage;

  const TrackDownloadState({
    required this.songId,
    this.status = DownloadStatus.removed,
    this.progress = 0.0,
    this.bytesDownloaded = 0,
    this.totalBytes = 0,
    this.localPath,
    this.errorMessage,
  });

  const TrackDownloadState.notDownloaded(this.songId)
      : status = DownloadStatus.removed,
        progress = 0.0,
        bytesDownloaded = 0,
        totalBytes = 0,
        localPath = null,
        errorMessage = null;

  bool get isCompleted => status == DownloadStatus.completed;
  bool get isDownloading => status == DownloadStatus.downloading;
  bool get isPending => status == DownloadStatus.pending;
  bool get isFailed => status == DownloadStatus.failed;
  bool get isPaused => status == DownloadStatus.paused;
  bool get isCancelled => status == DownloadStatus.cancelled;
  bool get isNotDownloaded =>
      status == DownloadStatus.removed || status == DownloadStatus.cancelled;

  TrackDownloadState copyWith({
    String? songId,
    DownloadStatus? status,
    double? progress,
    int? bytesDownloaded,
    int? totalBytes,
    String? localPath,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TrackDownloadState(
      songId: songId ?? this.songId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      localPath: localPath ?? this.localPath,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackDownloadState &&
          runtimeType == other.runtimeType &&
          songId == other.songId &&
          status == other.status &&
          progress == other.progress &&
          bytesDownloaded == other.bytesDownloaded &&
          totalBytes == other.totalBytes &&
          localPath == other.localPath &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      songId.hashCode ^
      status.hashCode ^
      progress.hashCode ^
      bytesDownloaded.hashCode ^
      totalBytes.hashCode ^
      localPath.hashCode ^
      errorMessage.hashCode;

  @override
  String toString() {
    return 'TrackDownloadState(songId: $songId, status: $status, progress: ${(progress * 100).toStringAsFixed(1)}%, bytes: $bytesDownloaded/$totalBytes, path: $localPath, error: $errorMessage)';
  }
}

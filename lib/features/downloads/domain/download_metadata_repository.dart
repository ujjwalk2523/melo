import 'package:melo/shared/models/song.dart';

/// Status of download entry.
enum DownloadStatus {
  pending,
  downloading,
  completed,
  failed,
  removed,
  paused,
  cancelled,
}

/// Represents download metadata stored locally.
class DownloadMetadata {
  final String id;
  final String songId;
  final DownloadStatus status;
  final String? localPath;
  final int downloadedBytes;
  final int totalBytes;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DownloadMetadata({
    required this.id,
    required this.songId,
    required this.status,
    this.localPath,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });
}

/// Contract for managing downloaded song metadata.
abstract class DownloadMetadataRepository {
  Future<void> recordDownloadMetadata({
    required Song song,
    required DownloadStatus status,
    String? localPath,
    int downloadedBytes = 0,
    int totalBytes = 0,
    String? errorMessage,
  });

  Future<void> updateStatus(
    String songId,
    DownloadStatus status, {
    String? errorMessage,
    int? downloadedBytes,
    int? totalBytes,
    String? localPath,
  });

  Future<void> removeDownloadMetadata(String songId);

  Future<List<Song>> getDownloadedSongs();

  Stream<Set<String>> watchDownloadedSongIds();

  Future<DownloadMetadata?> getMetadata(String songId);
}

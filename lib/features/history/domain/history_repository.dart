import 'package:melo/shared/models/song.dart';

/// Contract for managing listening history and recently played tracks.
abstract class HistoryRepository {
  /// Records a song playback event in history (upserts song and adds/updates history record).
  Future<void> recordPlayed(Song song);

  /// Retrieves recently played songs ordered by playedAt descending.
  Future<List<Song>> getRecentlyPlayed({int limit = 50});

  /// Reactive stream emitting recently played songs.
  Stream<List<Song>> watchRecentlyPlayed({int limit = 50});

  /// Clears all listening history records.
  Future<void> clearHistory();
}

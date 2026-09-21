import 'dart:math';

/// Deterministic conflict resolution rules for Melo cloud/local sync.
///
/// CONFLICT RESOLUTION MANIFESTO:
/// 1. FAVORITES:
///    - Deterministic "Latest Operation Wins" by timestamp.
///    - If a song is marked un-favorited locally after cloud favorited time, it remains un-favorited.
///    - If cloud favorite timestamp is newer than local modification, cloud status applies.
///
/// 2. USER PREFERENCES:
///    - "Latest UpdatedAt Wins".
///    - Compares client preference timestamp with server updatedAt.
///    - Avoids resetting audio quality, crossfade, normalization from a stale client.
///
/// 3. PLAYLISTS:
///    - "Latest UpdatedAt Wins" for metadata (name, description, artwork).
///    - Tombstoned (deleted) playlists are honored if deletion timestamp is newer.
///
/// 4. PLAYLIST SONGS & ORDERING:
///    - Preserves sequential zero-indexed ordering.
///    - De-duplicates songs with composite key (playlistId, songId).
///    - Preserves ordering from the latest valid edit.
///
/// 5. LISTENING HISTORY:
///    - Merges records instead of overwriting.
///    - Play counts are accumulated: max(localCount, cloudCount) or additive.
///    - Latest playedAt timestamp is kept so no listening history is lost.
class SyncConflictResolver {
  /// Resolves conflict between local and cloud favorite state.
  /// Returns true if favorite should exist, false if removed.
  static bool resolveFavorite({
    required bool localIsFavorite,
    required DateTime localUpdatedAt,
    required bool cloudIsFavorite,
    required DateTime cloudUpdatedAt,
  }) {
    if (localUpdatedAt.isAfter(cloudUpdatedAt)) {
      return localIsFavorite;
    }
    return cloudIsFavorite;
  }

  /// Resolves conflict between local and cloud preference timestamp.
  /// Returns true if cloud preferences should overwrite local.
  static bool shouldApplyCloudPreferences({
    required DateTime localUpdatedAt,
    required DateTime cloudUpdatedAt,
  }) {
    return cloudUpdatedAt.isAfter(localUpdatedAt);
  }

  /// Resolves conflict between local and cloud playlist metadata.
  /// Returns true if cloud playlist should overwrite local.
  static bool shouldApplyCloudPlaylist({
    required DateTime localUpdatedAt,
    required DateTime cloudUpdatedAt,
  }) {
    return cloudUpdatedAt.isAfter(localUpdatedAt);
  }

  /// Merges listening history entry without dropping plays.
  static ({int playCount, DateTime playedAt}) mergeHistoryEntry({
    required int localPlayCount,
    required DateTime localPlayedAt,
    required int cloudPlayCount,
    required DateTime cloudPlayedAt,
  }) {
    final mergedCount = max(localPlayCount, cloudPlayCount);
    final mergedPlayedAt = localPlayedAt.isAfter(cloudPlayedAt)
        ? localPlayedAt
        : cloudPlayedAt;
    return (playCount: mergedCount, playedAt: mergedPlayedAt);
  }
}

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/database/database_converters.dart';
import 'package:melo/features/player/domain/models/player_state.dart';
import 'package:melo/shared/models/song.dart';

/// Represents a persistent snapshot of the audio player and queue.
class PlayerSnapshot {
  final Song? currentSong;
  final List<Song> queue;
  final int currentQueueIndex;
  final Duration position;
  final PlaybackRepeatMode repeatMode;
  final bool isShuffle;

  const PlayerSnapshot({
    this.currentSong,
    this.queue = const [],
    this.currentQueueIndex = 0,
    this.position = Duration.zero,
    this.repeatMode = PlaybackRepeatMode.off,
    this.isShuffle = false,
  });
}

abstract class PlayerSnapshotRepository {
  Future<void> saveSnapshot({
    required Song? currentSong,
    required List<Song> queue,
    required Duration position,
    required PlaybackRepeatMode repeatMode,
    required bool isShuffle,
  });

  Future<PlayerSnapshot?> loadSnapshot();

  Future<void> clearSnapshot();
}

class PlayerSnapshotRepositoryImpl implements PlayerSnapshotRepository {
  final AppDatabase _db;
  static const String _snapshotId = 'current_player_state';

  PlayerSnapshotRepositoryImpl(this._db);

  @override
  Future<void> saveSnapshot({
    required Song? currentSong,
    required List<Song> queue,
    required Duration position,
    required PlaybackRepeatMode repeatMode,
    required bool isShuffle,
  }) async {
    await _db.transaction(() async {
      // 1. Ensure all queue songs exist in SongsTable
      for (final song in queue) {
        await _db
            .into(_db.songsTable)
            .insertOnConflictUpdate(DatabaseConverters.songToCompanion(song));
      }
      if (currentSong != null && !queue.contains(currentSong)) {
        await _db
            .into(_db.songsTable)
            .insertOnConflictUpdate(
              DatabaseConverters.songToCompanion(currentSong),
            );
      }

      // 2. Serialize queue IDs
      final queueIds = queue.map((s) => s.id).toList();
      final currentIndex = currentSong != null ? queue.indexOf(currentSong) : 0;

      // 3. Upsert snapshot
      await _db
          .into(_db.playerSnapshotsTable)
          .insertOnConflictUpdate(
            PlayerSnapshotsTableCompanion(
              id: const Value(_snapshotId),
              currentSongId: Value(currentSong?.id),
              queueSongIds: Value(jsonEncode(queueIds)),
              currentQueueIndex: Value(currentIndex >= 0 ? currentIndex : 0),
              positionMs: Value(position.inMilliseconds),
              repeatMode: Value(repeatMode.name),
              isShuffle: Value(isShuffle),
              updatedAt: Value(DateTime.now()),
            ),
          );
    });
  }

  @override
  Future<PlayerSnapshot?> loadSnapshot() async {
    final row = await (_db.select(
      _db.playerSnapshotsTable,
    )..where((tbl) => tbl.id.equals(_snapshotId))).getSingleOrNull();

    if (row == null) return null;

    final queueIdsRaw = row.queueSongIds;
    List<String> queueIds = [];
    try {
      final decoded = jsonDecode(queueIdsRaw);
      if (decoded is List) {
        queueIds = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    // Load songs in queue order
    final queue = <Song>[];
    for (final id in queueIds) {
      final songData = await (_db.select(
        _db.songsTable,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (songData != null) {
        queue.add(DatabaseConverters.songFromData(songData));
      }
    }

    Song? currentSong;
    if (row.currentSongId != null) {
      final foundInQueue = queue
          .where((s) => s.id == row.currentSongId)
          .firstOrNull;
      if (foundInQueue != null) {
        currentSong = foundInQueue;
      } else {
        final songData = await (_db.select(
          _db.songsTable,
        )..where((tbl) => tbl.id.equals(row.currentSongId!))).getSingleOrNull();
        if (songData != null) {
          currentSong = DatabaseConverters.songFromData(songData);
        }
      }
    }

    final repeatMode = PlaybackRepeatMode.values.firstWhere(
      (e) => e.name == row.repeatMode,
      orElse: () => PlaybackRepeatMode.off,
    );

    return PlayerSnapshot(
      currentSong: currentSong,
      queue: queue,
      currentQueueIndex: row.currentQueueIndex,
      position: Duration(milliseconds: row.positionMs),
      repeatMode: repeatMode,
      isShuffle: row.isShuffle,
    );
  }

  @override
  Future<void> clearSnapshot() async {
    await (_db.delete(
      _db.playerSnapshotsTable,
    )..where((tbl) => tbl.id.equals(_snapshotId))).go();
  }
}

import 'package:drift/drift.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/database/database_converters.dart';
import 'package:melo/core/sync/sync_engine.dart';
import 'package:melo/features/history/domain/history_repository.dart';
import 'package:melo/shared/models/song.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final AppDatabase _db;
  final SyncEngine? _syncEngine;
  final String? Function()? _getAuthToken;

  HistoryRepositoryImpl(this._db, [this._syncEngine, this._getAuthToken]);

  @override
  Future<void> recordPlayed(Song song) async {
    final now = DateTime.now();
    int currentPlayCount = 1;

    await _db.transaction(() async {
      // 1. Ensure song metadata is stored
      await _db
          .into(_db.songsTable)
          .insertOnConflictUpdate(DatabaseConverters.songToCompanion(song));

      // 2. Check for existing history record for this song
      final existing = await (_db.select(
        _db.listeningHistoryTable,
      )..where((tbl) => tbl.songId.equals(song.id))).getSingleOrNull();

      if (existing != null) {
        currentPlayCount = existing.playCount + 1;
        // Update timestamp and increment play count
        await (_db.update(
          _db.listeningHistoryTable,
        )..where((tbl) => tbl.id.equals(existing.id))).write(
          ListeningHistoryTableCompanion(
            playedAt: Value(now),
            playCount: Value(currentPlayCount),
          ),
        );
      } else {
        // Insert new listening history entry
        await _db
            .into(_db.listeningHistoryTable)
            .insert(
              ListeningHistoryTableCompanion.insert(
                songId: song.id,
                playedAt: Value(now),
                playCount: const Value(1),
              ),
            );
      }
    });

    await _syncEngine?.enqueueOperation(
      id: 'op_hist_${song.id}_${now.millisecondsSinceEpoch}',
      entityType: 'history',
      entityId: song.id,
      operationType: 'upsert',
      payload: {
        'playedAt': now.toIso8601String(),
        'playCount': currentPlayCount,
        'metadata': {
          'id': song.id,
          'title': song.title,
          'artist': song.artist,
          'album': song.album,
          'artworkUrl': song.artworkUrl,
          'durationMs': song.duration.inMilliseconds,
          'provider': song.provider,
        },
      },
      authToken: _getAuthToken?.call(),
    );
  }

  @override
  Future<List<Song>> getRecentlyPlayed({int limit = 50}) async {
    final query =
        _db.select(_db.listeningHistoryTable).join([
            innerJoin(
              _db.songsTable,
              _db.songsTable.id.equalsExp(_db.listeningHistoryTable.songId),
            ),
          ])
          ..orderBy([OrderingTerm.desc(_db.listeningHistoryTable.playedAt)])
          ..limit(limit);

    final rows = await query.get();
    return rows.map((row) {
      final songData = row.readTable(_db.songsTable);
      return DatabaseConverters.songFromData(songData);
    }).toList();
  }

  @override
  Stream<List<Song>> watchRecentlyPlayed({int limit = 50}) {
    final query =
        _db.select(_db.listeningHistoryTable).join([
            innerJoin(
              _db.songsTable,
              _db.songsTable.id.equalsExp(_db.listeningHistoryTable.songId),
            ),
          ])
          ..orderBy([OrderingTerm.desc(_db.listeningHistoryTable.playedAt)])
          ..limit(limit);

    return query.watch().map((rows) {
      return rows.map((row) {
        final songData = row.readTable(_db.songsTable);
        return DatabaseConverters.songFromData(songData);
      }).toList();
    });
  }

  @override
  Future<void> clearHistory() async {
    await _db.delete(_db.listeningHistoryTable).go();
  }
}

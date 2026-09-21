import 'package:drift/drift.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/database/database_converters.dart';
import 'package:melo/features/downloads/domain/download_metadata_repository.dart';
import 'package:melo/shared/models/song.dart';

class DownloadMetadataRepositoryImpl implements DownloadMetadataRepository {
  final AppDatabase _db;

  DownloadMetadataRepositoryImpl(this._db);

  @override
  Future<void> recordDownloadMetadata({
    required Song song,
    required DownloadStatus status,
    String? localPath,
    int downloadedBytes = 0,
    int totalBytes = 0,
    String? errorMessage,
  }) async {
    await _db.transaction(() async {
      // 1. Ensure song metadata exists
      await _db
          .into(_db.songsTable)
          .insertOnConflictUpdate(DatabaseConverters.songToCompanion(song));

      // 2. Insert or update download metadata
      final downloadId = 'dl_${song.id}';
      await _db
          .into(_db.downloadsTable)
          .insertOnConflictUpdate(
            DownloadsTableCompanion(
              id: Value(downloadId),
              songId: Value(song.id),
              status: Value(status.name),
              localPath: Value(localPath),
              downloadedBytes: Value(downloadedBytes),
              totalBytes: Value(totalBytes),
              errorMessage: Value(errorMessage),
              createdAt: Value(DateTime.now()),
              updatedAt: Value(DateTime.now()),
            ),
          );
    });
  }

  @override
  Future<void> updateStatus(
    String songId,
    DownloadStatus status, {
    String? errorMessage,
    int? downloadedBytes,
    int? totalBytes,
    String? localPath,
  }) async {
    final companion = DownloadsTableCompanion(
      status: Value(status.name),
      updatedAt: Value(DateTime.now()),
      errorMessage: errorMessage != null
          ? Value(errorMessage)
          : const Value.absent(),
      downloadedBytes: downloadedBytes != null
          ? Value(downloadedBytes)
          : const Value.absent(),
      totalBytes: totalBytes != null ? Value(totalBytes) : const Value.absent(),
      localPath: localPath != null ? Value(localPath) : const Value.absent(),
    );

    await (_db.update(
      _db.downloadsTable,
    )..where((tbl) => tbl.songId.equals(songId))).write(companion);
  }

  @override
  Future<void> removeDownloadMetadata(String songId) async {
    await (_db.delete(
      _db.downloadsTable,
    )..where((tbl) => tbl.songId.equals(songId))).go();
  }

  @override
  Future<List<Song>> getDownloadedSongs() async {
    final query =
        _db.select(_db.downloadsTable).join([
            innerJoin(
              _db.songsTable,
              _db.songsTable.id.equalsExp(_db.downloadsTable.songId),
            ),
          ])
          ..where(
            _db.downloadsTable.status.equals(DownloadStatus.completed.name),
          )
          ..orderBy([OrderingTerm.desc(_db.downloadsTable.updatedAt)]);

    final rows = await query.get();
    return rows.map((row) {
      final songData = row.readTable(_db.songsTable);
      return DatabaseConverters.songFromData(songData);
    }).toList();
  }

  @override
  Stream<Set<String>> watchDownloadedSongIds() {
    return (_db.select(_db.downloadsTable)
          ..where((tbl) => tbl.status.equals(DownloadStatus.completed.name)))
        .watch()
        .map((rows) => rows.map((r) => r.songId).toSet());
  }

  @override
  Future<DownloadMetadata?> getMetadata(String songId) async {
    final row = await (_db.select(
      _db.downloadsTable,
    )..where((tbl) => tbl.songId.equals(songId))).getSingleOrNull();

    if (row == null) return null;

    final status = DownloadStatus.values.firstWhere(
      (e) => e.name == row.status,
      orElse: () => DownloadStatus.pending,
    );

    return DownloadMetadata(
      id: row.id,
      songId: row.songId,
      status: status,
      localPath: row.localPath,
      downloadedBytes: row.downloadedBytes,
      totalBytes: row.totalBytes,
      errorMessage: row.errorMessage,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

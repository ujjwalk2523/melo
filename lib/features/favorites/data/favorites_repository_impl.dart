import 'package:drift/drift.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/database/database_converters.dart';
import 'package:melo/features/favorites/domain/favorites_repository.dart';
import 'package:melo/shared/models/song.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final AppDatabase _db;

  FavoritesRepositoryImpl(this._db);

  @override
  Future<void> addFavorite(Song song) async {
    await _db.transaction(() async {
      // 1. Ensure song metadata is persisted in SongsTable
      await _db
          .into(_db.songsTable)
          .insertOnConflictUpdate(DatabaseConverters.songToCompanion(song));

      // 2. Insert favorite entry ignoring duplicates
      await _db
          .into(_db.favoritesTable)
          .insert(
            FavoritesTableCompanion.insert(songId: song.id),
            mode: InsertMode.insertOrIgnore,
          );
    });
  }

  @override
  Future<void> removeFavorite(String songId) async {
    await (_db.delete(
      _db.favoritesTable,
    )..where((tbl) => tbl.songId.equals(songId))).go();
  }

  @override
  Future<bool> isFavorite(String songId) async {
    final query = _db.select(_db.favoritesTable)
      ..where((tbl) => tbl.songId.equals(songId));
    final result = await query.getSingleOrNull();
    return result != null;
  }

  @override
  Future<bool> toggleFavorite(Song song) async {
    final currentlyFavorite = await isFavorite(song.id);
    if (currentlyFavorite) {
      await removeFavorite(song.id);
      return false;
    } else {
      await addFavorite(song);
      return true;
    }
  }

  @override
  Future<List<Song>> getFavorites() async {
    final query = _db.select(_db.favoritesTable).join([
      innerJoin(
        _db.songsTable,
        _db.songsTable.id.equalsExp(_db.favoritesTable.songId),
      ),
    ])..orderBy([OrderingTerm.desc(_db.favoritesTable.createdAt)]);

    final rows = await query.get();
    return rows.map((row) {
      final songData = row.readTable(_db.songsTable);
      return DatabaseConverters.songFromData(songData);
    }).toList();
  }

  @override
  Stream<Set<String>> watchFavoriteIds() {
    return _db
        .select(_db.favoritesTable)
        .watch()
        .map((rows) => rows.map((r) => r.songId).toSet());
  }

  @override
  Stream<List<Song>> watchFavorites() {
    final query = _db.select(_db.favoritesTable).join([
      innerJoin(
        _db.songsTable,
        _db.songsTable.id.equalsExp(_db.favoritesTable.songId),
      ),
    ])..orderBy([OrderingTerm.desc(_db.favoritesTable.createdAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final songData = row.readTable(_db.songsTable);
        return DatabaseConverters.songFromData(songData);
      }).toList();
    });
  }
}

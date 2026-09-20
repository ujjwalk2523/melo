import 'package:drift/drift.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/database/database_converters.dart';
import 'package:melo/features/playlists/domain/playlist_models.dart';
import 'package:melo/features/playlists/domain/playlist_repository.dart';
import 'package:melo/shared/models/song.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final AppDatabase _db;

  PlaylistRepositoryImpl(this._db);

  String _validatePlaylistName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Playlist name cannot be empty.');
    }
    if (trimmed.length > 100) {
      throw ArgumentError(
        'Playlist name is too long (maximum 100 characters).',
      );
    }
    return trimmed;
  }

  @override
  Future<Playlist> createPlaylist(String name, {String? description}) async {
    final validName = _validatePlaylistName(name);
    final now = DateTime.now();
    final playlistId = 'pl_${now.millisecondsSinceEpoch}';

    await _db
        .into(_db.playlistsTable)
        .insert(
          PlaylistsTableCompanion.insert(
            id: playlistId,
            name: validName,
            description: Value(description?.trim()),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );

    return Playlist(
      id: playlistId,
      name: validName,
      description: description?.trim(),
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> renamePlaylist(String id, String newName) async {
    final validName = _validatePlaylistName(newName);
    final exists = await (_db.select(
      _db.playlistsTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (exists == null) {
      throw ArgumentError('Playlist with ID "$id" does not exist.');
    }

    await (_db.update(
      _db.playlistsTable,
    )..where((tbl) => tbl.id.equals(id))).write(
      PlaylistsTableCompanion(
        name: Value(validName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deletePlaylist(String id) async {
    await _db.transaction(() async {
      // Remove all associated songs in this playlist
      await (_db.delete(
        _db.playlistSongsTable,
      )..where((tbl) => tbl.playlistId.equals(id))).go();

      // Remove the playlist entity
      await (_db.delete(
        _db.playlistsTable,
      )..where((tbl) => tbl.id.equals(id))).go();
    });
  }

  @override
  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    // 1. Verify playlist exists
    final playlist = await (_db.select(
      _db.playlistsTable,
    )..where((tbl) => tbl.id.equals(playlistId))).getSingleOrNull();

    if (playlist == null) {
      throw ArgumentError('Playlist with ID "$playlistId" does not exist.');
    }

    await _db.transaction(() async {
      // 2. Ensure song metadata exists in SongsTable
      await _db
          .into(_db.songsTable)
          .insertOnConflictUpdate(DatabaseConverters.songToCompanion(song));

      // 3. Check if song is already in this playlist (duplicate prevention)
      final existing =
          await (_db.select(_db.playlistSongsTable)..where(
                (tbl) =>
                    tbl.playlistId.equals(playlistId) &
                    tbl.songId.equals(song.id),
              ))
              .getSingleOrNull();

      if (existing != null) {
        return; // No duplicate copies allowed in one playlist
      }

      // 4. Determine next position
      final songsInPlaylist = await (_db.select(
        _db.playlistSongsTable,
      )..where((tbl) => tbl.playlistId.equals(playlistId))).get();

      final nextPos = songsInPlaylist.length;

      // 5. Insert playlist song
      await _db
          .into(_db.playlistSongsTable)
          .insert(
            PlaylistSongsTableCompanion.insert(
              playlistId: playlistId,
              songId: song.id,
              position: Value(nextPos),
              addedAt: Value(DateTime.now()),
            ),
          );

      // 6. Update playlist's updatedAt
      await (_db.update(_db.playlistsTable)
            ..where((tbl) => tbl.id.equals(playlistId)))
          .write(PlaylistsTableCompanion(updatedAt: Value(DateTime.now())));
    });
  }

  @override
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await (_db.delete(_db.playlistSongsTable)..where(
          (tbl) =>
              tbl.playlistId.equals(playlistId) & tbl.songId.equals(songId),
        ))
        .go();

    await (_db.update(_db.playlistsTable)
          ..where((tbl) => tbl.id.equals(playlistId)))
        .write(PlaylistsTableCompanion(updatedAt: Value(DateTime.now())));
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    final playlistsData = await (_db.select(
      _db.playlistsTable,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])).get();

    final result = <Playlist>[];
    for (final pl in playlistsData) {
      final songs = await getPlaylistSongs(pl.id);
      result.add(
        Playlist(
          id: pl.id,
          name: pl.name,
          description: pl.description,
          artworkUrl: pl.artworkUrl,
          trackCount: songs.length,
          songs: songs,
          createdAt: pl.createdAt,
          updatedAt: pl.updatedAt,
        ),
      );
    }
    return result;
  }

  @override
  Stream<List<Playlist>> watchPlaylists() {
    return _db.select(_db.playlistsTable).watch().asyncMap((
      playlistsData,
    ) async {
      final result = <Playlist>[];
      for (final pl in playlistsData) {
        final songs = await getPlaylistSongs(pl.id);
        result.add(
          Playlist(
            id: pl.id,
            name: pl.name,
            description: pl.description,
            artworkUrl: pl.artworkUrl,
            trackCount: songs.length,
            songs: songs,
            createdAt: pl.createdAt,
            updatedAt: pl.updatedAt,
          ),
        );
      }
      return result;
    });
  }

  @override
  Future<Playlist?> getPlaylist(String id) async {
    final pl = await (_db.select(
      _db.playlistsTable,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

    if (pl == null) return null;
    final songs = await getPlaylistSongs(id);
    return Playlist(
      id: pl.id,
      name: pl.name,
      description: pl.description,
      artworkUrl: pl.artworkUrl,
      trackCount: songs.length,
      songs: songs,
      createdAt: pl.createdAt,
      updatedAt: pl.updatedAt,
    );
  }

  @override
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    final query =
        _db.select(_db.playlistSongsTable).join([
            innerJoin(
              _db.songsTable,
              _db.songsTable.id.equalsExp(_db.playlistSongsTable.songId),
            ),
          ])
          ..where(_db.playlistSongsTable.playlistId.equals(playlistId))
          ..orderBy([OrderingTerm.asc(_db.playlistSongsTable.position)]);

    final rows = await query.get();
    return rows.map((row) {
      final songData = row.readTable(_db.songsTable);
      return DatabaseConverters.songFromData(songData);
    }).toList();
  }

  @override
  Stream<List<Song>> watchPlaylistSongs(String playlistId) {
    final query =
        _db.select(_db.playlistSongsTable).join([
            innerJoin(
              _db.songsTable,
              _db.songsTable.id.equalsExp(_db.playlistSongsTable.songId),
            ),
          ])
          ..where(_db.playlistSongsTable.playlistId.equals(playlistId))
          ..orderBy([OrderingTerm.asc(_db.playlistSongsTable.position)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final songData = row.readTable(_db.songsTable);
        return DatabaseConverters.songFromData(songData);
      }).toList();
    });
  }

  @override
  Future<void> reorderPlaylistSongs(
    String playlistId,
    List<String> songIdsInOrder,
  ) async {
    await _db.transaction(() async {
      for (int i = 0; i < songIdsInOrder.length; i++) {
        final songId = songIdsInOrder[i];
        await (_db.update(_db.playlistSongsTable)..where(
              (tbl) =>
                  tbl.playlistId.equals(playlistId) & tbl.songId.equals(songId),
            ))
            .write(PlaylistSongsTableCompanion(position: Value(i)));
      }
    });
  }
}

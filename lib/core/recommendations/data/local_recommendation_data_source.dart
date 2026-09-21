import 'package:drift/drift.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/recommendations/data/recommendation_data_source.dart';
import 'package:melo/core/recommendations/domain/recommendation_feedback.dart';
import 'package:melo/features/playlists/domain/playlist_models.dart';
import 'package:melo/features/profile/data/user_preferences_repository.dart';
import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/models/song.dart';

/// Local implementation of [RecommendationDataSource] using Drift SQLite and SharedPreferences.
class LocalRecommendationDataSource implements RecommendationDataSource {
  final AppDatabase db;
  final UserPreferencesRepository? preferencesRepo;

  LocalRecommendationDataSource({required this.db, this.preferencesRepo});

  @override
  Future<List<Song>> getFavorites() async {
    final query = db.select(db.favoritesTable).join([
      innerJoin(
        db.songsTable,
        db.songsTable.id.equalsExp(db.favoritesTable.songId),
      ),
    ])..orderBy([OrderingTerm.desc(db.favoritesTable.createdAt)]);

    final rows = await query.get();
    return rows
        .map((row) => _mapRowToSong(row.readTable(db.songsTable)))
        .toList();
  }

  @override
  Future<List<Song>> getListeningHistory() async {
    final query = db.select(db.listeningHistoryTable).join([
      innerJoin(
        db.songsTable,
        db.songsTable.id.equalsExp(db.listeningHistoryTable.songId),
      ),
    ])..orderBy([OrderingTerm.desc(db.listeningHistoryTable.playedAt)]);

    final rows = await query.get();
    return rows
        .map((row) => _mapRowToSong(row.readTable(db.songsTable)))
        .toList();
  }

  @override
  Future<List<Playlist>> getPlaylists() async {
    final rows = await (db.select(
      db.playlistsTable,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();

    final playlists = <Playlist>[];
    for (final row in rows) {
      final countQuery = db.selectOnly(db.playlistSongsTable)
        ..addColumns([db.playlistSongsTable.songId.count()])
        ..where(db.playlistSongsTable.playlistId.equals(row.id));
      final count =
          await countQuery
              .map((r) => r.read(db.playlistSongsTable.songId.count()))
              .getSingleOrNull() ??
          0;

      playlists.add(
        Playlist(
          id: row.id,
          name: row.name,
          description: row.description,
          artworkUrl: row.artworkUrl,
          trackCount: count,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
        ),
      );
    }
    return playlists;
  }

  @override
  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    final query =
        db.select(db.playlistSongsTable).join([
            innerJoin(
              db.songsTable,
              db.songsTable.id.equalsExp(db.playlistSongsTable.songId),
            ),
          ])
          ..where(db.playlistSongsTable.playlistId.equals(playlistId))
          ..orderBy([OrderingTerm.asc(db.playlistSongsTable.position)]);

    final rows = await query.get();
    return rows
        .map((row) => _mapRowToSong(row.readTable(db.songsTable)))
        .toList();
  }

  @override
  Future<List<Song>> getDownloadedSongs() async {
    final query = db.select(db.downloadsTable).join([
      innerJoin(
        db.songsTable,
        db.songsTable.id.equalsExp(db.downloadsTable.songId),
      ),
    ])..where(db.downloadsTable.status.equals('completed'));

    final rows = await query.get();
    return rows
        .map((row) => _mapRowToSong(row.readTable(db.songsTable)))
        .toList();
  }

  @override
  Future<List<Song>> getCatalogSongs() async {
    // 1. Fetch songs stored in Drift database
    final dbRows = await db.select(db.songsTable).get();
    final dbSongs = dbRows.map(_mapRowToSong).toList();

    // 2. Union with MockCatalog to guarantee rich candidate discovery pool
    final songMap = <String, Song>{};
    for (final song in MockCatalog.songs) {
      songMap[song.id] = song;
    }
    for (final song in dbSongs) {
      songMap[song.id] = song;
    }

    return songMap.values.toList();
  }

  @override
  Future<List<RecommendationFeedback>> getFeedback() async {
    final rows = await (db.select(
      db.recommendationFeedbackTable,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();

    return rows
        .map(
          (r) => RecommendationFeedback(
            id: r.id,
            feedbackType: FeedbackType.values.firstWhere(
              (e) => e.name == r.feedbackType,
              orElse: () => FeedbackType.notInterested,
            ),
            targetId: r.targetId,
            targetType: r.targetType,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveFeedback(RecommendationFeedback feedback) async {
    await db
        .into(db.recommendationFeedbackTable)
        .insert(
          RecommendationFeedbackTableCompanion.insert(
            feedbackType: feedback.feedbackType.name,
            targetId: feedback.targetId,
            targetType: feedback.targetType,
            createdAt: Value(feedback.createdAt),
          ),
        );
  }

  @override
  Future<void> clearFeedback() async {
    await db.delete(db.recommendationFeedbackTable).go();
  }

  @override
  UserPreferences getPreferences() {
    return preferencesRepo?.getPreferences() ?? const UserPreferences();
  }

  Song _mapRowToSong(SongsTableData row) {
    return Song(
      id: row.id,
      title: row.title,
      artist: row.artist,
      album: row.album,
      artworkUrl: row.artworkUrl,
      duration: Duration(milliseconds: row.durationMs),
      streamUrl: row.streamUrl,
      downloadUrl: row.downloadUrl,
      isDownloadable: row.isDownloadable,
      provider: row.provider,
      genre: row.genre,
      releaseDate: row.releaseDate,
    );
  }
}

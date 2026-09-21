import 'package:drift/drift.dart';

/// Normalized songs table persisting metadata across all providers.
class SongsTable extends Table {
  TextColumn get id => text()();
  TextColumn get provider => text()();
  TextColumn get providerTrackId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get album => text()();
  TextColumn get artworkUrl => text()();
  TextColumn get streamUrl => text().nullable()();
  TextColumn get downloadUrl => text().nullable()();
  BoolColumn get isDownloadable =>
      boolean().withDefault(const Constant(false))();
  IntColumn get durationMs => integer()();
  TextColumn get genre => text().nullable()();
  DateTimeColumn get releaseDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// User favorites table with unique constraint on songId.
class FavoritesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get songId => text().references(SongsTable, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {songId},
  ];
}

/// Listening history table recording playback events.
class ListeningHistoryTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get songId => text().references(SongsTable, #id)();
  DateTimeColumn get playedAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get playCount => integer().withDefault(const Constant(1))();
}

/// User-created playlists table.
class PlaylistsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get artworkUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Junction table between playlists and songs with composite uniqueness on (playlistId, songId).
class PlaylistSongsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get playlistId => text().references(PlaylistsTable, #id)();
  TextColumn get songId => text().references(SongsTable, #id)();
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {playlistId, songId},
  ];
}

/// Future download metadata table (Phase 6 metadata only, no audio download).
class DownloadsTable extends Table {
  TextColumn get id => text()();
  TextColumn get songId => text().references(SongsTable, #id)();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get localPath => text().nullable()();
  IntColumn get downloadedBytes => integer().withDefault(const Constant(0))();
  IntColumn get totalBytes => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {songId},
  ];
}

/// State snapshot table for player queue restoration across app restarts.
class PlayerSnapshotsTable extends Table {
  TextColumn get id => text()();
  TextColumn get currentSongId => text().nullable()();
  TextColumn get queueSongIds => text().withDefault(const Constant('[]'))();
  IntColumn get currentQueueIndex => integer().withDefault(const Constant(0))();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  TextColumn get repeatMode => text().withDefault(const Constant('off'))();
  BoolColumn get isShuffle => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Durable sync queue table storing pending cloud sync operations.
class SyncQueueTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()();
  TextColumn get entityType => text()(); // 'favorite', 'playlist', 'playlist_song', 'history', 'preference'
  TextColumn get entityId => text()();
  TextColumn get operationType => text()(); // 'upsert', 'delete'
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'syncing', 'failed', 'completed'

  @override
  Set<Column> get primaryKey => {id};
}

/// Sync metadata table tracking timestamps and synchronization status.
class SyncMetadataTable extends Table {
  TextColumn get id => text()(); // 'default'
  DateTimeColumn get lastSuccessfulSyncAt => dateTime().nullable()();
  DateTimeColumn get lastAttemptedSyncAt => dateTime().nullable()();
  IntColumn get pendingOperationCount => integer().withDefault(const Constant(0))();
  TextColumn get lastSyncError => text().nullable()();
  IntColumn get serverRevision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stores user recommendation feedback signals (hide song, hide artist, hide genre, less like this).
class RecommendationFeedbackTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get feedbackType => text()(); // 'hideSong', 'hideArtist', 'hideGenre', 'lessLikeThis', 'notInterested'
  TextColumn get targetId => text()(); // songId, artistName, or genre
  TextColumn get targetType => text()(); // 'song', 'artist', 'genre'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

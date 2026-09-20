import 'package:drift/drift.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/shared/models/song.dart';

/// Converters between Drift SQLite tables and Melo domain models.
class DatabaseConverters {
  /// Converts a Drift [SongsTableData] row into a domain [Song] model.
  static Song songFromData(SongsTableData data) {
    return Song(
      id: data.id,
      title: data.title,
      artist: data.artist,
      album: data.album,
      artworkUrl: data.artworkUrl,
      duration: Duration(milliseconds: data.durationMs),
      streamUrl: data.streamUrl,
      downloadUrl: data.downloadUrl,
      isDownloadable: data.isDownloadable,
      provider: data.provider,
      genre: data.genre,
      releaseDate: data.releaseDate,
    );
  }

  /// Converts a domain [Song] model into a Drift [SongsTableCompanion] for insertion/upsert.
  static SongsTableCompanion songToCompanion(Song song) {
    // Extract providerTrackId if id has format 'provider:trackId'
    String? providerTrackId;
    if (song.id.contains(':')) {
      providerTrackId = song.id.split(':').skip(1).join(':');
    }

    return SongsTableCompanion(
      id: Value(song.id),
      provider: Value(song.provider),
      providerTrackId: Value(providerTrackId),
      title: Value(song.title),
      artist: Value(song.artist),
      album: Value(song.album),
      artworkUrl: Value(song.artworkUrl),
      streamUrl: Value(song.streamUrl),
      downloadUrl: Value(song.downloadUrl),
      isDownloadable: Value(song.isDownloadable),
      durationMs: Value(song.duration.inMilliseconds),
      genre: Value(song.genre),
      releaseDate: Value(song.releaseDate),
      updatedAt: Value(DateTime.now()),
    );
  }
}

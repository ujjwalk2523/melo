import 'package:melo/features/playlists/domain/playlist_models.dart';
import 'package:melo/shared/models/song.dart';

/// Contract for managing user-created playlists and playlist tracks.
abstract class PlaylistRepository {
  /// Creates a new playlist with input validation (trimmed, non-empty, max length).
  Future<Playlist> createPlaylist(String name, {String? description});

  /// Renames an existing playlist with validation.
  Future<void> renamePlaylist(String id, String newName);

  /// Deletes a playlist and its associated playlist song entries.
  Future<void> deletePlaylist(String id);

  /// Adds a song to a playlist, preventing duplicate copies in the same playlist.
  Future<void> addSongToPlaylist(String playlistId, Song song);

  /// Removes a specific song from a playlist.
  Future<void> removeSongFromPlaylist(String playlistId, String songId);

  /// Retrieves all user playlists ordered by creation date descending.
  Future<List<Playlist>> getPlaylists();

  /// Reactive stream emitting all user playlists.
  Stream<List<Playlist>> watchPlaylists();

  /// Retrieves a single playlist by ID, including its songs.
  Future<Playlist?> getPlaylist(String id);

  /// Retrieves the list of songs belonging to a playlist ordered by position ascending.
  Future<List<Song>> getPlaylistSongs(String playlistId);

  /// Reactive stream emitting songs belonging to a playlist ordered by position.
  Stream<List<Song>> watchPlaylistSongs(String playlistId);

  /// Reorders songs in a playlist based on the new order of song IDs.
  Future<void> reorderPlaylistSongs(
    String playlistId,
    List<String> songIdsInOrder,
  );
}

import 'package:melo/shared/models/song.dart';

/// Contract for managing locally persisted favorite / liked songs.
abstract class FavoritesRepository {
  /// Adds a song to favorites, persisting song metadata and the favorite entry.
  Future<void> addFavorite(Song song);

  /// Removes a song from favorites by song ID.
  Future<void> removeFavorite(String songId);

  /// Checks if a song ID is currently marked as favorite.
  Future<bool> isFavorite(String songId);

  /// Toggles favorite status for a given song. Returns true if now favorite, false otherwise.
  Future<bool> toggleFavorite(Song song);

  /// Retrieves the list of all favorited songs ordered by addition date descending.
  Future<List<Song>> getFavorites();

  /// Reactive stream emitting the current Set of all favorited song IDs.
  Stream<Set<String>> watchFavoriteIds();

  /// Reactive stream emitting the list of favorited songs.
  Stream<List<Song>> watchFavorites();
}

import '../../../shared/data/mock_catalog.dart';
import '../../../shared/models/song.dart';
import 'search_api.dart';

/// Result wrapper indicating data source and songs.
class SearchResultPayload {
  final List<Song> songs;
  final bool isOfflineFallback;
  final String? errorMessage;

  const SearchResultPayload({
    required this.songs,
    this.isOfflineFallback = false,
    this.errorMessage,
  });
}

/// Repository responsible for executing music searches with automatic fallback.
class SearchRepository {
  final SearchApi _api;

  SearchRepository([SearchApi? api]) : _api = api ?? SearchApi();

  /// Executes search against real Melo backend, gracefully falling back to MockCatalog if offline.
  Future<SearchResultPayload> searchSongs(
    String query, {
    String? provider,
    int? limit,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SearchResultPayload(songs: []);
    }

    try {
      final songs = await _api.searchSongs(
        trimmed,
        provider: provider,
        limit: limit,
      );

      return SearchResultPayload(songs: songs, isOfflineFallback: false);
    } catch (e) {
      // Backend unavailable or network error: gracefully fall back to MockCatalog
      final fallbackSongs = fallbackMockSearch(trimmed);
      return SearchResultPayload(
        songs: fallbackSongs,
        isOfflineFallback: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Explicit mock catalog search filter for offline development or testing.
  static List<Song> fallbackMockSearch(String query) {
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) return const [];

    return MockCatalog.songs.where((song) {
      final matchesTitle = song.title.toLowerCase().contains(lower);
      final matchesArtist = song.artist.toLowerCase().contains(lower);
      final matchesAlbum = song.album.toLowerCase().contains(lower);
      final matchesGenre = song.genre?.toLowerCase().contains(lower) ?? false;
      return matchesTitle || matchesArtist || matchesAlbum || matchesGenre;
    }).toList();
  }
}

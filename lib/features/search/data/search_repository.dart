import '../../../core/network/saavn_service.dart';
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
  final SaavnService? _saavnService;

  SearchRepository([SearchApi? api, SaavnService? saavnService])
      : _api = api ?? SearchApi(),
        _saavnService = saavnService;

  /// Executes search across free music providers (Saavn, Audius, Jamendo),
  /// gracefully falling back to MockCatalog if completely offline.
  Future<SearchResultPayload> searchSongs(
    String query, {
    String? provider,
    int? limit,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SearchResultPayload(songs: []);
    }

    // 1. If explicit backend provider requested (audius, jamendo)
    if (provider == 'audius' || provider == 'jamendo') {
      try {
        final songs = await _api.searchSongs(
          trimmed,
          provider: provider,
          limit: limit,
        );
        return SearchResultPayload(songs: songs, isOfflineFallback: false);
      } catch (e) {
        final fallback = fallbackMockSearch(trimmed);
        return SearchResultPayload(
          songs: fallback,
          isOfflineFallback: true,
          errorMessage: e.toString(),
        );
      }
    }

    // 2. If Saavn service is available (primary provider for all Indian and global music)
    if (_saavnService != null) {
      try {
        final saavnSongs = await _saavnService.searchSongs(
          trimmed,
          limit: limit ?? 20,
        );
        if (saavnSongs.isNotEmpty) {
          return SearchResultPayload(songs: saavnSongs, isOfflineFallback: false);
        }
      } catch (_) {
        // If Saavn fails or has network error, fall through to backend or mock
      }
    }

    // 3. Fallback to Melo backend service
    try {
      final songs = await _api.searchSongs(
        trimmed,
        provider: provider,
        limit: limit,
      );
      if (songs.isNotEmpty) {
        return SearchResultPayload(songs: songs, isOfflineFallback: false);
      }
    } catch (_) {
      // Backend error, continue to mock fallback
    }

    // 4. Offline MockCatalog fallback
    final fallbackSongs = fallbackMockSearch(trimmed);
    return SearchResultPayload(
      songs: fallbackSongs,
      isOfflineFallback: true,
    );
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

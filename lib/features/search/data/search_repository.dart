import '../../../core/network/saavn_service.dart';
import '../../../core/utils/fuzzy_search_engine.dart';
import '../../../shared/data/mock_catalog.dart';
import '../../../shared/models/song.dart';
import 'search_api.dart';

/// Result wrapper indicating data source and songs.
class SearchResultPayload {
  final List<Song> songs;
  final bool isOfflineFallback;
  final String? errorMessage;
  final String? suggestedQuery;

  const SearchResultPayload({
    required this.songs,
    this.isOfflineFallback = false,
    this.errorMessage,
    this.suggestedQuery,
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

    final typoCorrection = FuzzySearchEngine.suggestCorrection(trimmed);

    // 1. If explicit backend provider requested (audius, jamendo)
    if (provider == 'audius' || provider == 'jamendo') {
      try {
        final songs = await _api.searchSongs(
          trimmed,
          provider: provider,
          limit: limit,
        );
        return SearchResultPayload(
          songs: songs,
          isOfflineFallback: false,
          suggestedQuery: typoCorrection != trimmed ? typoCorrection : null,
        );
      } catch (e) {
        final fallback = fallbackMockSearch(trimmed);
        return SearchResultPayload(
          songs: fallback,
          isOfflineFallback: true,
          errorMessage: e.toString(),
          suggestedQuery: typoCorrection != trimmed ? typoCorrection : null,
        );
      }
    }

    // 2. If Saavn service is available (primary provider for all Indian and global music)
    if (_saavnService != null) {
      try {
        var saavnSongs = await _saavnService.searchSongs(
          trimmed,
          limit: limit ?? 20,
        );

        // If no results for the typed query, try intelligent typo correction
        if (saavnSongs.isEmpty && typoCorrection != null && typoCorrection.toLowerCase() != trimmed.toLowerCase()) {
          final correctedSongs = await _saavnService.searchSongs(
            typoCorrection,
            limit: limit ?? 20,
          );
          if (correctedSongs.isNotEmpty) {
            return SearchResultPayload(
              songs: correctedSongs,
              isOfflineFallback: false,
              suggestedQuery: typoCorrection,
            );
          }
        }

        if (saavnSongs.isNotEmpty) {
          return SearchResultPayload(
            songs: saavnSongs,
            isOfflineFallback: false,
            suggestedQuery: typoCorrection != trimmed ? typoCorrection : null,
          );
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
        return SearchResultPayload(
          songs: songs,
          isOfflineFallback: false,
          suggestedQuery: typoCorrection != trimmed ? typoCorrection : null,
        );
      }
    } catch (_) {
      // Backend error, continue to mock fallback
    }

    // 4. Offline MockCatalog fallback with intelligent fuzzy ranking
    final fallbackSongs = fallbackMockSearch(trimmed);
    return SearchResultPayload(
      songs: fallbackSongs,
      isOfflineFallback: true,
      suggestedQuery: typoCorrection != trimmed ? typoCorrection : null,
    );
  }

  /// Explicit mock catalog search filter for offline development or testing with fuzzy tolerance.
  static List<Song> fallbackMockSearch(String query) {
    final lower = query.trim().toLowerCase();
    if (lower.isEmpty) return const [];

    // 1. Direct contains matches
    final direct = MockCatalog.songs.where((song) {
      final matchesTitle = song.title.toLowerCase().contains(lower);
      final matchesArtist = song.artist.toLowerCase().contains(lower);
      final matchesAlbum = song.album.toLowerCase().contains(lower);
      final matchesGenre = song.genre?.toLowerCase().contains(lower) ?? false;
      return matchesTitle || matchesArtist || matchesAlbum || matchesGenre;
    }).toList();

    if (direct.isNotEmpty) {
      return direct;
    }

    // 2. Fuzzy ranking
    final fuzzyRanked = FuzzySearchEngine.rankSongs(MockCatalog.songs, query);
    if (fuzzyRanked.isNotEmpty) {
      return fuzzyRanked;
    }

    // 3. Typo alias correction fallback
    final correction = FuzzySearchEngine.suggestCorrection(query);
    if (correction != null) {
      return FuzzySearchEngine.rankSongs(MockCatalog.songs, correction);
    }

    return const [];
  }
}

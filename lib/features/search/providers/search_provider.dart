import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/saavn_service.dart';
import '../../../shared/data/mock_catalog.dart';
import '../../../shared/models/album.dart';
import '../../../shared/models/artist.dart';
import '../../../shared/models/song.dart';
import '../data/search_repository.dart';

/// Current search text query.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Selected search category tab: 'All', 'Songs', 'Artists', 'Albums'.
final searchCategoryFilterProvider = StateProvider<String>((ref) => 'All');

/// Active music provider name filter (e.g. 'audius', 'jamendo', null for default).
final searchProviderFilterProvider = StateProvider<String?>((ref) => null);

/// Search repository instance provider.
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  final saavnService = ref.watch(saavnServiceProvider);
  return SearchRepository(null, saavnService);
});

/// State notifier managing recent search queries.
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier()
    : super([
        'Honey Singh',
        'Shubh',
        'Pawan Singh',
        'Kishore Kumar',
        'Masoom Sharma',
        'Sidhu Moose Wala',
      ]);

  void add(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final updated = List<String>.from(state)..remove(trimmed);
    updated.insert(0, trimmed);
    if (updated.length > 8) {
      state = updated.sublist(0, 8);
    } else {
      state = updated;
    }
  }

  void remove(String query) {
    state = state.where((q) => q != query).toList();
  }

  void clear() {
    state = [];
  }
}

final recentSearchesProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
      return RecentSearchesNotifier();
    });

/// Live asynchronous search query executing against Melo backend service.
final liveSearchProvider = FutureProvider.autoDispose<SearchResultPayload>((
  ref,
) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) {
    return const SearchResultPayload(songs: []);
  }

  final provider = ref.watch(searchProviderFilterProvider);
  final repository = ref.watch(searchRepositoryProvider);

  return repository.searchSongs(query, provider: provider);
});

/// Indicates whether a network search query is currently resolving.
final isSearchLoadingProvider = Provider<bool>((ref) {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return false;
  return ref.watch(liveSearchProvider).isLoading;
});

/// Indicates whether the search results came from offline mock fallback.
final isOfflineSearchFallbackProvider = Provider<bool>((ref) {
  final liveSearch = ref.watch(liveSearchProvider);
  return liveSearch.value?.isOfflineFallback ?? false;
});

/// Filtered songs matching search query.
///
/// Uses live backend results when resolved, with instant fallback to MockCatalog
/// when offline or while waiting for live resolution.
final searchSongResultsProvider = Provider<List<Song>>((ref) {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return const [];

  final liveSearchAsync = ref.watch(liveSearchProvider);

  return liveSearchAsync.when(
    data: (payload) => payload.songs,
    loading: () => SearchRepository.fallbackMockSearch(query),
    error: (_, _) => SearchRepository.fallbackMockSearch(query),
  );
});

/// Filtered artists matching search query.
final searchArtistResultsProvider = Provider<List<Artist>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return const [];

  return MockCatalog.artists.where((artist) {
    final matchesName = artist.name.toLowerCase().contains(query);
    final matchesGenre = artist.genre.toLowerCase().contains(query);
    return matchesName || matchesGenre;
  }).toList();
});

/// Filtered albums matching search query.
final searchAlbumResultsProvider = Provider<List<Album>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return const [];

  return MockCatalog.albums.where((album) {
    final matchesTitle = album.title.toLowerCase().contains(query);
    final matchesArtist = album.artist.toLowerCase().contains(query);
    final matchesGenre = album.genre.toLowerCase().contains(query);
    return matchesTitle || matchesArtist || matchesGenre;
  }).toList();
});

/// Backward compatibility search results provider.
final searchResultsProvider = searchSongResultsProvider;

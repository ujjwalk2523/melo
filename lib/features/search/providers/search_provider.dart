import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/models/album.dart';
import 'package:melo/shared/models/artist.dart';
import 'package:melo/shared/models/song.dart';

/// Current search text query.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Selected search category tab: 'All', 'Songs', 'Artists', 'Albums'.
final searchCategoryFilterProvider = StateProvider<String>((ref) => 'All');

/// State notifier managing recent search queries.
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier()
    : super(['Synthwave', 'Kaelen Vance', 'Lo-Fi Chill', 'Astraea']);

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

/// Filtered songs matching search query.
final searchSongResultsProvider = Provider<List<Song>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return const [];

  return MockCatalog.songs.where((song) {
    final matchesTitle = song.title.toLowerCase().contains(query);
    final matchesArtist = song.artist.toLowerCase().contains(query);
    final matchesAlbum = song.album.toLowerCase().contains(query);
    final matchesGenre = song.genre?.toLowerCase().contains(query) ?? false;
    return matchesTitle || matchesArtist || matchesAlbum || matchesGenre;
  }).toList();
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

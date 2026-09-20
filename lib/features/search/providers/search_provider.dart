import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/shared/data/mock_songs.dart';
import 'package:melo/shared/models/song.dart';

/// Current search text query.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Selected search category filter.
final searchCategoryFilterProvider = StateProvider<String>((ref) => 'All');

/// Reactive search results filtering mock catalog by query and category.
final searchResultsProvider = Provider<List<Song>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final allSongs = MockSongs.items;

  if (query.isEmpty) {
    return const [];
  }

  return allSongs.where((song) {
    final matchesTitle = song.title.toLowerCase().contains(query);
    final matchesArtist = song.artist.toLowerCase().contains(query);
    final matchesAlbum = song.album.toLowerCase().contains(query);
    final matchesGenre = song.genre?.toLowerCase().contains(query) ?? false;

    return matchesTitle || matchesArtist || matchesAlbum || matchesGenre;
  }).toList();
});

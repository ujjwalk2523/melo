import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/database/database_providers.dart';
import 'package:melo/features/search/providers/search_provider.dart';
import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/models/playlist.dart';
import '../ai_playlist_generator.dart';

/// Reactive provider that delivers real-time AI-generated playlists
/// (Daily Mixes, Artist Radios, and Search-reactive Flow playlists)
/// based on active listening history, search activity, and favorites.
final aiPlaylistsProvider = Provider<List<Playlist>>((ref) {
  final recentTracks = ref.watch(recentlyPlayedStreamProvider).value ?? [];
  final recentSearches = ref.watch(recentSearchesProvider);
  final favorites = ref.watch(favoriteSongsStreamProvider).value ?? [];

  return AiPlaylistGenerator.generatePlaylists(
    recentTracks: recentTracks,
    recentSearches: recentSearches,
    favorites: favorites,
    allCatalogSongs: MockCatalog.songs,
  );
});

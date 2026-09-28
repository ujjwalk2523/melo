import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/models/album.dart';
import 'package:melo/shared/models/artist.dart';
import 'package:melo/shared/models/playlist.dart';
import 'package:melo/shared/models/song.dart';

/// Provides Quick Picks for the Home Screen.
final quickPicksProvider = Provider<List<Song>>((ref) {
  return MockCatalog.songs.take(6).toList();
});

/// Provides Continue Listening track.
final continueListeningProvider = Provider<Song?>((ref) {
  return MockCatalog.songs.isNotEmpty ? MockCatalog.songs[0] : null;
});

/// Provides Trending Now music tracks.
final trendingSongsProvider = Provider<List<Song>>((ref) {
  return [
    MockCatalog.songs[1],
    MockCatalog.songs[4],
    MockCatalog.songs[6],
    MockCatalog.songs[8],
    MockCatalog.songs[11],
  ];
});

/// Provides Chill / Lo-Fi genre tracks.
final chillLoFiProvider = Provider<List<Song>>((ref) {
  return MockCatalog.songs
      .where(
        (s) =>
            s.genre == 'Lo-Fi Chill' ||
            s.genre == 'Chillstep' ||
            s.genre == 'Ambient',
      )
      .toList();
});

/// Provides Fresh Discoveries tracks.
final freshDiscoveriesProvider = Provider<List<Song>>((ref) {
  return MockCatalog.songs.reversed.take(6).toList();
});

/// Provides Indian & Regional music tracks (Bollywood, Punjabi, Bhojpuri, Haryanvi, Retro).
final indianHitsProvider = Provider<List<Song>>((ref) {
  return MockCatalog.songs.where((s) => s.provider == 'saavn').toList();
});

/// Provides featured albums.
final featuredAlbumsProvider = Provider<List<Album>>((ref) {
  return MockCatalog.albums;
});

/// Provides featured artists.
final featuredArtistsProvider = Provider<List<Artist>>((ref) {
  return MockCatalog.artists;
});

/// Provides curated playlists.
final curatedPlaylistsProvider = Provider<List<Playlist>>((ref) {
  return MockCatalog.playlists;
});

/// Backward compatibility provider for tests.
final recentlyPlayedProvider = quickPicksProvider;
final recommendedSongsProvider = freshDiscoveriesProvider;

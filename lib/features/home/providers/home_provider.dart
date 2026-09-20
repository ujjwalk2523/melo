import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/shared/data/mock_songs.dart';
import 'package:melo/shared/models/song.dart';

/// Provides recently played songs for the Home Screen.
final recentlyPlayedProvider = Provider<List<Song>>((ref) {
  return MockSongs.items.sublist(0, 4);
});

/// Provides personalized recommendation songs.
final recommendedSongsProvider = Provider<List<Song>>((ref) {
  return MockSongs.items.sublist(2, 6);
});

/// Provides trending music tracks.
final trendingSongsProvider = Provider<List<Song>>((ref) {
  return MockSongs.items.reversed.toList();
});

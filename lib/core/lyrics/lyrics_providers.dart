import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/song.dart';
import 'lyrics_model.dart';
import 'lyrics_service.dart';

/// Provider for singleton [LyricsService].
final lyricsServiceProvider = Provider<LyricsService>((ref) {
  return LyricsService();
});

/// Reactive family provider fetching lyrics for a given song.
final songLyricsProvider = FutureProvider.family<TrackLyrics, Song>((ref, song) async {
  final service = ref.watch(lyricsServiceProvider);
  return service.getLyrics(
    trackTitle: song.title,
    artist: song.artist,
    duration: song.duration,
  );
});

import 'package:flutter_test/flutter_test.dart';
import 'package:melo/core/recommendations/ai_playlist_generator.dart';
import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/models/song.dart';

void main() {
  group('AiPlaylistGenerator Tests', () {
    test('generates Daily Mix 1 and Artist Mix when searches contain Indian artists', () {
      final playlists = AiPlaylistGenerator.generatePlaylists(
        recentTracks: [],
        recentSearches: ['Honey Singh', 'Shubh'],
        favorites: [],
        allCatalogSongs: MockCatalog.songs,
      );

      expect(playlists, isNotEmpty);

      // Verify Daily Mix 1 is present with Desi artists
      final dailyMix1 = playlists.firstWhere((p) => p.id == 'ai-daily-mix-1');
      expect(dailyMix1.badge, equals('DAILY MIX'));
      expect(dailyMix1.songs.length, greaterThanOrEqualTo(2));
      expect(dailyMix1.songs.any((s) => s.artist.contains('Honey Singh')), isTrue);

      // Verify Artist Mix is present
      final artistMix = playlists.firstWhere(
        (p) => p.badge == 'ARTIST MIX' && p.title.contains('Honey Singh'),
      );
      expect(artistMix.title, equals('Yo Yo Honey Singh Mix'));
      expect(artistMix.songs.any((s) => s.title == 'Brown Rang'), isTrue);
    });

    test('generates real-time AI Flow playlist based on latest search query', () {
      final playlists = AiPlaylistGenerator.generatePlaylists(
        recentTracks: [],
        recentSearches: ['Kishore Kumar', 'Synthwave'],
        favorites: [],
        allCatalogSongs: MockCatalog.songs,
      );

      final aiFlow = playlists.firstWhere(
        (p) => p.badge == 'AI GENERATED' && p.id == 'ai-flow-latest-search',
      );
      expect(aiFlow.title, contains('Kishore Kumar'));
      expect(aiFlow.description, contains('Kishore Kumar'));
      expect(aiFlow.songs.isNotEmpty, isTrue);
      expect(aiFlow.songs.any((s) => s.artist.contains('Kishore')), isTrue);
    });

    test('generates Track Radio Flow when searches are empty but recent tracks exist', () {
      final sampleTrack = MockCatalog.songs.firstWhere((s) => s.title == 'Obsidian Pulse');

      final playlists = AiPlaylistGenerator.generatePlaylists(
        recentTracks: [sampleTrack],
        recentSearches: [],
        favorites: [],
        allCatalogSongs: MockCatalog.songs,
      );

      final radioFlow = playlists.firstWhere(
        (p) => p.badge == 'AI GENERATED' && p.id == 'ai-flow-track-radio',
      );
      expect(radioFlow.title, equals('Obsidian Pulse Radio'));
      expect(radioFlow.songs.first.id, equals(sampleTrack.id));
      expect(radioFlow.songs.length, greaterThan(1));
    });

    test('every playlist computes positive trackCount and totalDuration', () {
      final playlists = AiPlaylistGenerator.generatePlaylists(
        recentTracks: MockCatalog.songs.take(2).toList(),
        recentSearches: ['Honey Singh', 'Chill'],
        favorites: [],
        allCatalogSongs: MockCatalog.songs,
      );

      for (final p in playlists) {
        expect(p.trackCount, equals(p.songs.length));
        expect(p.trackCount, greaterThan(0));
        expect(p.totalDuration.inSeconds, greaterThan(0));
        expect(p.badge, isNotNull);
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:melo/core/recommendations/ai_mashup_generator.dart';
import 'package:melo/core/recommendations/ai_playlist_generator.dart';
import 'package:melo/core/utils/fuzzy_search_engine.dart';
import 'package:melo/features/search/data/search_repository.dart';
import 'package:melo/shared/data/mock_catalog.dart';

void main() {
  group('Phase 10: Fuzzy Search Engine & Typo Tolerance', () {
    test('suggests accurate correction for common Romanized Hindi/Punjabi typos', () {
      expect(FuzzySearchEngine.suggestCorrection('hony'), equals('honey singh'));
      expect(FuzzySearchEngine.suggestCorrection('hony singh'), equals('honey singh'));
      expect(FuzzySearchEngine.suggestCorrection('chesks'), equals('cheques'));
      expect(FuzzySearchEngine.suggestCorrection('brwn rng'), equals('brown rang'));
      expect(FuzzySearchEngine.suggestCorrection('arjit'), equals('arijit singh'));
      expect(FuzzySearchEngine.suggestCorrection('mosewala'), equals('sidhu moose wala'));
    });

    test('ranks catalog songs using typo-tolerant fuzzy distance', () {
      final results = FuzzySearchEngine.rankSongs(MockCatalog.songs, 'hony');
      expect(results, isNotEmpty);
      expect(results.any((s) => s.artist.contains('Honey Singh')), isTrue);
    });

    test('SearchRepository fallbackMockSearch finds songs despite typos', () {
      final results = SearchRepository.fallbackMockSearch('chesks');
      expect(results, isNotEmpty);
      expect(results.first.title.toLowerCase(), contains('cheques'));
    });
  });

  group('Phase 10: AI Playlists Length (15-20+ Tracks Depth)', () {
    test('Daily Mixes synthesized contain at least 15 tracks each', () {
      final playlists = AiPlaylistGenerator.generatePlaylists(
        recentTracks: [],
        recentSearches: ['Honey Singh', 'Synthwave'],
        favorites: [],
        allCatalogSongs: MockCatalog.songs,
      );

      final mix1 = playlists.firstWhere((p) => p.id == 'ai-daily-mix-1');
      expect(mix1.songs.length, greaterThanOrEqualTo(15));

      final mix2 = playlists.firstWhere((p) => p.id == 'ai-daily-mix-2');
      expect(mix2.songs.length, greaterThanOrEqualTo(15));
    });
  });

  group('Phase 10: AI Mashup & Personalized Playlists', () {
    test('generates interleaved AI Mashup with synergy score and tags', () {
      final mashup = AiMashupGenerator.generateMashup(
        entityA: 'Yo Yo Honey Singh',
        entityB: 'Shubh',
      );

      expect(mashup.title, equals('Yo Yo Honey Singh × Shubh'));
      expect(mashup.synergyScore, inInclusiveRange(85, 99));
      expect(mashup.songs.length, greaterThanOrEqualTo(16));

      final playlist = mashup.toPlaylist();
      expect(playlist.badge, equals('AI MASHUP'));
      expect(playlist.songs.length, equals(mashup.songs.length));
    });

    test('generates Personalized AI Mood Playlist from custom prompt', () {
      final playlist = AiMashupGenerator.generatePersonalizedMoodPlaylist(
        moodPrompt: 'Late night drive with soft lo-fi beats',
      );

      expect(playlist.badge, equals('PERSONALIZED AI'));
      expect(playlist.songs.length, greaterThanOrEqualTo(16));
      expect(playlist.description, contains('Late night drive'));
    });
  });
}

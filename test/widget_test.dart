import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melo/core/constants/app_constants.dart';
import 'package:melo/features/player/domain/models/player_state.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/features/search/providers/search_provider.dart';
import 'package:melo/main.dart';
import 'package:melo/shared/data/mock_catalog.dart';

void main() {
  group('MeloApp Smoke & Navigation Tests', () {
    testWidgets('MeloApp boots successfully and displays all navigation tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: MeloApp()));
      await tester.pumpAndSettle();

      // Verify the 4 primary navigation destinations exist
      expect(find.text(AppConstants.navHome), findsOneWidget);
      expect(find.text(AppConstants.navSearch), findsOneWidget);
      expect(find.text(AppConstants.navLibrary), findsOneWidget);
      expect(find.text(AppConstants.navProfile), findsOneWidget);
    });
  });

  group('PlayerNotifier Unit Tests', () {
    test('Initial state has no active song and is initial status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(playerNotifierProvider);
      expect(state.status, PlayerStatus.initial);
      expect(state.currentSong, isNull);
      expect(state.hasSong, isFalse);
    });

    test('Playing a song updates status to playing and populates queue', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final song = MockCatalog.songs.first;
      container.read(playerNotifierProvider.notifier).play(song);

      final state = container.read(playerNotifierProvider);
      expect(state.status, PlayerStatus.playing);
      expect(state.currentSong?.id, song.id);
      expect(state.isPlaying, isTrue);
      expect(state.queue, contains(song));
    });

    test('Toggling play/pause updates playback status', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final song = MockCatalog.songs.first;
      final notifier = container.read(playerNotifierProvider.notifier);

      notifier.play(song);
      expect(container.read(playerNotifierProvider).isPlaying, isTrue);

      notifier.pause();
      expect(
        container.read(playerNotifierProvider).status,
        PlayerStatus.paused,
      );

      notifier.resume();
      expect(container.read(playerNotifierProvider).isPlaying, isTrue);
    });

    test('Toggling favorites adds and removes song id from favorites set', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(playerNotifierProvider.notifier);
      const testSongId = 'melo-test-fav';

      expect(
        container.read(playerNotifierProvider).isSongFavorite(testSongId),
        isFalse,
      );

      notifier.toggleFavorite(testSongId);
      expect(
        container.read(playerNotifierProvider).isSongFavorite(testSongId),
        isTrue,
      );

      notifier.toggleFavorite(testSongId);
      expect(
        container.read(playerNotifierProvider).isSongFavorite(testSongId),
        isFalse,
      );
    });

    test('Seeking updates playback position within duration bounds', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final song = MockCatalog.songs.first;
      final notifier = container.read(playerNotifierProvider.notifier);
      notifier.play(song);

      notifier.seek(const Duration(seconds: 45));
      expect(container.read(playerNotifierProvider).position.inSeconds, 45);
      expect(
        container.read(playerNotifierProvider).progressFraction,
        greaterThan(0.0),
      );
    });
  });

  group('SearchProvider Unit Tests', () {
    test('Search query correctly filters catalog', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initially empty
      expect(container.read(searchSongResultsProvider), isEmpty);

      // Search for 'Synthwave'
      container.read(searchQueryProvider.notifier).state = 'Synthwave';
      final results = container.read(searchSongResultsProvider);
      expect(results, isNotEmpty);
      expect(results.any((s) => s.genre == 'Synthwave'), isTrue);
    });
  });
}

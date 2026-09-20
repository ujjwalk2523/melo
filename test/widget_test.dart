import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melo/core/constants/app_constants.dart';
import 'package:melo/features/player/domain/models/player_state.dart';
import 'package:melo/features/player/presentation/screens/full_player_screen.dart';
import 'package:melo/features/player/presentation/widgets/mini_player.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:melo/features/search/providers/search_provider.dart';
import 'package:melo/main.dart';
import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/widgets/song_card.dart';

void main() {
  group('MeloApp Smoke & Navigation Tests', () {
    testWidgets('MeloApp boots successfully and displays all navigation tabs', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const ProviderScope(child: MeloApp()));
      await tester.pumpAndSettle();

      // Verify the 4 primary navigation destinations exist
      expect(find.text(AppConstants.navHome), findsOneWidget);
      expect(find.text(AppConstants.navSearch), findsOneWidget);
      expect(find.text(AppConstants.navLibrary), findsOneWidget);
      expect(find.text(AppConstants.navProfile), findsOneWidget);
    });

    testWidgets(
      'Full End-to-End Smoke Test: Tab navigation, playback, mini & full player',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(const ProviderScope(child: MeloApp()));
        await tester.pumpAndSettle();

        // 1. Home tab: Verify headers and content
        expect(find.text('MELO STREAM'), findsOneWidget);
        expect(find.text('Quick Picks'), findsOneWidget);
        expect(find.text('Trending Now'), findsOneWidget);

        // Initially MiniPlayer has no song title inside it
        expect(
          find.descendant(
            of: find.byType(MiniPlayer),
            matching: find.text('Solar Flare'),
          ),
          findsNothing,
        );

        // 2. Tap a song card in Home
        final songCardFinder = find.byType(SongCard).first;
        expect(songCardFinder, findsOneWidget);
        await tester.tap(songCardFinder);
        await tester.pumpAndSettle();

        // Mini Player is now active and displays song title inside MiniPlayer
        expect(
          find.descendant(
            of: find.byType(MiniPlayer),
            matching: find.text('Solar Flare'),
          ),
          findsOneWidget,
        );

        // 3. Mini Player play/pause toggle
        final pauseButtonFinder = find.byTooltip('Pause');
        expect(pauseButtonFinder, findsOneWidget);
        await tester.tap(pauseButtonFinder);
        await tester.pumpAndSettle();

        final playButtonFinder = find.byTooltip('Play');
        expect(playButtonFinder, findsOneWidget);
        await tester.tap(playButtonFinder);
        await tester.pumpAndSettle();

        // 4. Tap Mini Player to open Full Player
        await tester.tap(find.byType(MiniPlayer));
        await tester.pumpAndSettle();

        // Verify Full Player is open
        expect(find.byType(FullPlayerScreen), findsOneWidget);
        expect(find.text('PLAYING FROM PLAYLIST'), findsOneWidget);
        expect(find.byTooltip('Collapse'), findsOneWidget);
        expect(find.byTooltip('Shuffle'), findsOneWidget);
        expect(find.byTooltip('Repeat'), findsOneWidget);

        // 5. Seek on slider
        final sliderFinder = find.byType(Slider);
        expect(sliderFinder, findsOneWidget);

        // 6. Dismiss Full Player
        await tester.tap(find.byTooltip('Collapse'));
        await tester.pumpAndSettle();
        expect(find.byType(FullPlayerScreen), findsNothing);

        // 7. Navigate to Search tab while player stays active
        await tester.tap(find.text(AppConstants.navSearch));
        await tester.pumpAndSettle();
        expect(find.byType(SearchBarWidget), findsOneWidget);
        expect(find.text('Browse All Genres'), findsOneWidget);
        // MiniPlayer remains visible
        expect(find.byType(MiniPlayer), findsOneWidget);

        // 8. Navigate to Library tab
        await tester.tap(find.text(AppConstants.navLibrary));
        await tester.pumpAndSettle();
        expect(find.text('Your Library'), findsOneWidget);
        expect(find.text('Liked Songs'), findsWidgets);
        // MiniPlayer remains visible
        expect(find.byType(MiniPlayer), findsOneWidget);

        // 9. Navigate to Profile tab
        await tester.tap(find.text(AppConstants.navProfile));
        await tester.pumpAndSettle();
        expect(find.text('Ujjwal'), findsOneWidget);
        expect(find.text('Playback & Audio Quality'), findsOneWidget);
        expect(find.byType(MiniPlayer), findsOneWidget);
      },
    );
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

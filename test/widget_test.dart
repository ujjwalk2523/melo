import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melo/core/constants/app_constants.dart';
import 'package:melo/features/player/domain/models/player_state.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/main.dart';
import 'package:melo/shared/data/mock_songs.dart';

void main() {
  group('MeloApp Smoke & Navigation Tests', () {
    testWidgets('MeloApp boots successfully and displays all navigation tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProviderScope(child: MeloApp()));

      // Wait for router transition
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

      final song = MockSongs.items.first;
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

      final song = MockSongs.items.first;
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
  });
}

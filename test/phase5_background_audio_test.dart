import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/models/song.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testSong1 = const Song(
    id: 'audius_track_1',
    title: 'Neon Horizon',
    artist: 'Cyber Dreamer',
    album: 'Future Waves',
    duration: Duration(seconds: 210),
    artworkUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
    streamUrl:
        'https://audius-creator-1.audius.co/v1/tracks/audius_track_1/stream',
    provider: 'audius',
  );

  final testSong2 = const Song(
    id: 'audius_track_2',
    title: 'Starlight Echoes',
    artist: 'Solar Flare',
    album: 'Cosmic Journey',
    duration: Duration(seconds: 195),
    artworkUrl: '',
    streamUrl:
        'https://audius-creator-1.audius.co/v1/tracks/audius_track_2/stream',
    provider: 'audius',
  );

  group('Phase 5: MeloAudioHandler Unit Tests', () {
    late MeloAudioHandler handler;

    setUp(() {
      handler = MeloAudioHandler();
    });

    tearDown(() async {
      await handler.dispose();
    });

    test('songToMediaItem correctly maps domain Song to MediaItem', () {
      final mediaItem = handler.songToMediaItem(testSong1);

      expect(mediaItem.id, testSong1.id);
      expect(mediaItem.title, testSong1.title);
      expect(mediaItem.artist, testSong1.artist);
      expect(mediaItem.album, testSong1.album);
      expect(mediaItem.duration, testSong1.duration);
      expect(mediaItem.artUri, Uri.parse(testSong1.artworkUrl));
    });

    test(
      'songToMediaItem gracefully handles empty artwork URL without crashing',
      () {
        final mediaItem = handler.songToMediaItem(testSong2);

        expect(mediaItem.id, testSong2.id);
        expect(mediaItem.title, testSong2.title);
        expect(mediaItem.artist, testSong2.artist);
        expect(mediaItem.artUri, isNull);
      },
    );

    test('updateCurrentSong and setSongQueue push data to mediaItem and queue streams', () async {
      handler.updateCurrentSong(testSong1);
      handler.setSongQueue([testSong1, testSong2]);

      expect(handler.mediaItem.value?.id, testSong1.id);
      expect(handler.queue.value.length, 2);
      expect(handler.queue.value.first.id, testSong1.id);
      expect(handler.queue.value.last.id, testSong2.id);
    });

    test(
      'updatePlaybackState publishes correct controls, actions, and timestamps',
      () {
        handler.updatePlaybackState(
          isPlaying: true,
          processingStatus: AudioProcessingStatus.ready,
          position: const Duration(seconds: 45),
          bufferedPosition: const Duration(seconds: 80),
          queueIndex: 0,
        );

        final state = handler.playbackState.value;
        expect(state.playing, isTrue);
        expect(state.processingState, AudioProcessingState.ready);
        expect(state.updatePosition, const Duration(seconds: 45));
        expect(state.bufferedPosition, const Duration(seconds: 80));
        expect(state.queueIndex, 0);

        // Verify compact notification controls (prev, play/pause, next)
        expect(state.androidCompactActionIndices, [0, 1, 2]);
        expect(state.controls, contains(MediaControl.skipToPrevious));
        expect(state.controls, contains(MediaControl.pause));
        expect(state.controls, contains(MediaControl.skipToNext));
        expect(state.controls, contains(MediaControl.stop));
      },
    );

    test('Incoming handler actions trigger registered callbacks', () async {
      var playCalled = false;
      var pauseCalled = false;
      var stopCalled = false;
      var nextCalled = false;
      var prevCalled = false;
      Duration? seekTarget;
      int? queueItemTarget;

      handler.onPlayAction = () async => playCalled = true;
      handler.onPauseAction = () async => pauseCalled = true;
      handler.onStopAction = () async => stopCalled = true;
      handler.onNextAction = () async => nextCalled = true;
      handler.onPreviousAction = () async => prevCalled = true;
      handler.onSeekAction = (pos) async => seekTarget = pos;
      handler.onSkipToQueueItemAction = (idx) async => queueItemTarget = idx;

      await handler.play();
      expect(playCalled, isTrue);

      await handler.pause();
      expect(pauseCalled, isTrue);

      await handler.skipToNext();
      expect(nextCalled, isTrue);

      await handler.skipToPrevious();
      expect(prevCalled, isTrue);

      await handler.seek(const Duration(seconds: 90));
      expect(seekTarget, const Duration(seconds: 90));

      await handler.skipToQueueItem(3);
      expect(queueItemTarget, 3);

      await handler.stop();
      expect(stopCalled, isTrue);
      expect(
        handler.playbackState.value.processingState,
        AudioProcessingState.idle,
      );
      expect(handler.playbackState.value.playing, isFalse);
    });
  });

  group('Phase 5: Bidirectional Synchronization (Riverpod & AudioHandler)', () {
    late ProviderContainer container;
    late FakeAudioPlayerService fakeService;
    late MeloAudioHandler handler;

    setUp(() {
      fakeService = FakeAudioPlayerService();
      handler = MeloAudioHandler();

      container = ProviderContainer(
        overrides: [
          audioPlayerServiceProvider.overrideWithValue(fakeService),
          audioHandlerProvider.overrideWithValue(handler),
        ],
      );
    });

    tearDown(() async {
      container.dispose();
      fakeService.dispose();
      await handler.dispose();
    });

    test(
      'Playing a track in Riverpod synchronizes metadata to AudioHandler',
      () async {
        final notifier = container.read(playerNotifierProvider.notifier);
        await notifier.play(testSong1, queue: [testSong1, testSong2]);

        // Notification/Lock-screen MediaItem matches Riverpod current song
        expect(handler.mediaItem.value?.id, testSong1.id);
        expect(handler.mediaItem.value?.title, testSong1.title);
        expect(handler.mediaItem.value?.artist, testSong1.artist);

        // Notification playback state matches Riverpod status
        expect(handler.playbackState.value.playing, isTrue);
        expect(
          handler.playbackState.value.processingState,
          AudioProcessingState.ready,
        );
        expect(handler.queue.value.length, 2);
      },
    );

    test('Pausing and resuming via PlayerNotifier updates AudioHandler playbackState', () async {
      final notifier = container.read(playerNotifierProvider.notifier);
      await notifier.play(testSong1);

      await notifier.pause();
      expect(container.read(playerNotifierProvider).isPlaying, isFalse);
      expect(handler.playbackState.value.playing, isFalse);

      await notifier.resume();
      expect(container.read(playerNotifierProvider).isPlaying, isTrue);
      expect(handler.playbackState.value.playing, isTrue);
    });

    test('External AudioHandler actions (e.g. notification Next / Prev) drive PlayerNotifier', () async {
      final notifier = container.read(playerNotifierProvider.notifier);
      await notifier.play(testSong1, queue: [testSong1, testSong2]);

      expect(
        container.read(playerNotifierProvider).currentSong?.id,
        testSong1.id,
      );
      expect(handler.mediaItem.value?.id, testSong1.id);

      // External notification trigger: next
      await handler.skipToNext();

      expect(
        container.read(playerNotifierProvider).currentSong?.id,
        testSong2.id,
      );
      expect(handler.mediaItem.value?.id, testSong2.id);

      // External notification trigger: previous
      await handler.skipToPrevious();

      expect(
        container.read(playerNotifierProvider).currentSong?.id,
        testSong1.id,
      );
      expect(handler.mediaItem.value?.id, testSong1.id);
    });

    test(
      'External AudioHandler seek updates PlayerNotifier position',
      () async {
        final notifier = container.read(playerNotifierProvider.notifier);
        await notifier.play(testSong1);

        await handler.seek(const Duration(seconds: 40));

        expect(
          container.read(playerNotifierProvider).position,
          const Duration(seconds: 40),
        );
        expect(
          handler.playbackState.value.updatePosition,
          const Duration(seconds: 40),
        );
      },
    );

    test(
      'External AudioHandler pause and play toggle playback in PlayerNotifier',
      () async {
        final notifier = container.read(playerNotifierProvider.notifier);
        await notifier.play(testSong1);

        await handler.pause();
        expect(
          container.read(playerNotifierProvider).status,
          PlayerStatus.paused,
        );
        expect(handler.playbackState.value.playing, isFalse);

        await handler.play();
        expect(
          container.read(playerNotifierProvider).status,
          PlayerStatus.playing,
        );
        expect(handler.playbackState.value.playing, isTrue);
      },
    );

    test(
      'External AudioHandler stop halts playback and resets position',
      () async {
        final notifier = container.read(playerNotifierProvider.notifier);
        await notifier.play(testSong1);

        await handler.stop();
        expect(
          container.read(playerNotifierProvider).status,
          PlayerStatus.stopped,
        );
        expect(container.read(playerNotifierProvider).position, Duration.zero);
        expect(handler.playbackState.value.playing, isFalse);
      },
    );
  });
}

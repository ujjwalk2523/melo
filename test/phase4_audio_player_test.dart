import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/models/song.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 4: AudioPlayerService Unit Tests', () {
    late FakeAudioPlayerService fakeService;

    setUp(() {
      fakeService = FakeAudioPlayerService();
    });

    tearDown(() {
      fakeService.dispose();
    });

    test(
      'Initial state of FakeAudioPlayerService is idle and zero position',
      () {
        expect(fakeService.position, Duration.zero);
        expect(fakeService.duration, isNull);
        expect(fakeService.bufferedPosition, Duration.zero);
        expect(fakeService.isPlaying, isFalse);
      },
    );

    test('setUrl sets duration and ready state', () async {
      final duration = await fakeService.setUrl(
        'https://audius.co/stream/track1.mp3',
      );
      expect(duration, const Duration(minutes: 3, seconds: 30));
      expect(fakeService.duration, const Duration(minutes: 3, seconds: 30));
    });

    test('play, pause, and stop update playback state', () async {
      await fakeService.setUrl('https://audius.co/stream/track1.mp3');
      await fakeService.play();
      expect(fakeService.isPlaying, isTrue);

      await fakeService.pause();
      expect(fakeService.isPlaying, isFalse);

      await fakeService.stop();
      expect(fakeService.isPlaying, isFalse);
      expect(fakeService.position, Duration.zero);
    });

    test('seek updates position within bounds', () async {
      await fakeService.setUrl('https://audius.co/stream/track1.mp3');
      await fakeService.seek(const Duration(seconds: 60));
      expect(fakeService.position, const Duration(seconds: 60));
    });

    test('emitBuffering and emitCompleted emit state stream updates', () async {
      final states = <AudioProcessingStatus>[];
      final sub = fakeService.playerStateStream.listen((event) {
        states.add(event.processingStatus);
      });

      fakeService.emitBuffering();
      fakeService.emitCompleted();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(states, contains(AudioProcessingStatus.buffering));
      expect(states, contains(AudioProcessingStatus.completed));
      await sub.cancel();
    });
  });

  group('Phase 4: PlayerNotifier Engine & State Integration', () {
    late ProviderContainer container;
    late FakeAudioPlayerService fakeService;

    final testSong1 = const Song(
      id: 'audius_track_1',
      title: 'Midnight Resonance',
      artist: 'Aura Weaver',
      album: 'Dark Dimensions',
      duration: Duration(seconds: 200),
      artworkUrl: 'https://images.unsplash.com/photo-1',
      streamUrl:
          'https://audius-creator-1.audius.co/v1/tracks/audius_track_1/stream',
      provider: 'audius',
    );

    final testSong2 = const Song(
      id: 'audius_track_2',
      title: 'Neon Drift',
      artist: 'Kavinsky Wave',
      album: 'Retro Pulse',
      duration: Duration(seconds: 180),
      artworkUrl: 'https://images.unsplash.com/photo-2',
      streamUrl:
          'https://audius-creator-1.audius.co/v1/tracks/audius_track_2/stream',
      provider: 'audius',
    );

    setUp(() {
      fakeService = FakeAudioPlayerService();
      container = ProviderContainer(
        overrides: [audioPlayerServiceProvider.overrideWithValue(fakeService)],
      );
    });

    tearDown(() {
      container.dispose();
      fakeService.dispose();
    });

    test('Initial player state is initial with no current song', () {
      final state = container.read(playerNotifierProvider);
      expect(state.status, PlayerStatus.initial);
      expect(state.currentSong, isNull);
      expect(state.hasSong, isFalse);
      expect(state.position, Duration.zero);
      expect(state.repeatMode, PlaybackRepeatMode.off);
      expect(state.isShuffled, isFalse);
    });

    test(
      'Playing a track sets song, updates status to playing, and sets queue',
      () async {
        final notifier = container.read(playerNotifierProvider.notifier);
        await notifier.playSong(testSong1, queue: [testSong1, testSong2]);

        final state = container.read(playerNotifierProvider);
        expect(state.currentSong, testSong1);
        expect(state.status, PlayerStatus.playing);
        expect(state.queue.length, 2);
        expect(state.hasSong, isTrue);
        expect(state.isPlaying, isTrue);
      },
    );

    test('Pause and resume toggle between playing and paused', () async {
      final notifier = container.read(playerNotifierProvider.notifier);
      await notifier.playSong(testSong1);

      await notifier.pause();
      expect(
        container.read(playerNotifierProvider).status,
        PlayerStatus.paused,
      );
      expect(container.read(playerNotifierProvider).isPlaying, isFalse);

      await notifier.resume();
      expect(
        container.read(playerNotifierProvider).status,
        PlayerStatus.playing,
      );
      expect(container.read(playerNotifierProvider).isPlaying, isTrue);
    });

    test('togglePlayPause correctly switches playback status', () async {
      final notifier = container.read(playerNotifierProvider.notifier);
      await notifier.playSong(testSong1);

      await notifier.togglePlayPause();
      expect(
        container.read(playerNotifierProvider).status,
        PlayerStatus.paused,
      );

      await notifier.togglePlayPause();
      expect(
        container.read(playerNotifierProvider).status,
        PlayerStatus.playing,
      );
    });

    test('Seek clamps negative durations to zero and overflow durations to track max', () async {
      final notifier = container.read(playerNotifierProvider.notifier);
      await notifier.playSong(testSong1);

      // Seek negative
      await notifier.seek(const Duration(seconds: -15));
      expect(container.read(playerNotifierProvider).position, Duration.zero);

      // Seek overflow (> duration: 3 min 30 sec)
      await notifier.seek(const Duration(seconds: 350));
      expect(
        container.read(playerNotifierProvider).position,
        const Duration(minutes: 3, seconds: 30),
      );

      // Seek valid
      await notifier.seek(const Duration(seconds: 75));
      expect(
        container.read(playerNotifierProvider).position,
        const Duration(seconds: 75),
      );
    });

    test(
      'Queue navigation: nextSong and previousSong navigate cleanly',
      () async {
        final notifier = container.read(playerNotifierProvider.notifier);
        await notifier.playSong(testSong1, queue: [testSong1, testSong2]);

        expect(
          container.read(playerNotifierProvider).currentSong?.id,
          testSong1.id,
        );

        // Advance to next
        await notifier.nextSong();
        expect(
          container.read(playerNotifierProvider).currentSong?.id,
          testSong2.id,
        );

        // Previous song within 3 seconds goes back to testSong1
        await notifier.previousSong();
        expect(
          container.read(playerNotifierProvider).currentSong?.id,
          testSong1.id,
        );
      },
    );

    test('Repeat mode cycles through off -> all -> one -> off', () {
      final notifier = container.read(playerNotifierProvider.notifier);
      expect(
        container.read(playerNotifierProvider).repeatMode,
        PlaybackRepeatMode.off,
      );
      expect(container.read(playerNotifierProvider).isRepeat, isFalse);

      notifier.toggleRepeat();
      expect(
        container.read(playerNotifierProvider).repeatMode,
        PlaybackRepeatMode.all,
      );
      expect(container.read(playerNotifierProvider).isRepeat, isTrue);
      expect(container.read(playerNotifierProvider).isRepeatOne, isFalse);

      notifier.toggleRepeat();
      expect(
        container.read(playerNotifierProvider).repeatMode,
        PlaybackRepeatMode.one,
      );
      expect(container.read(playerNotifierProvider).isRepeat, isTrue);
      expect(container.read(playerNotifierProvider).isRepeatOne, isTrue);

      notifier.toggleRepeat();
      expect(
        container.read(playerNotifierProvider).repeatMode,
        PlaybackRepeatMode.off,
      );
      expect(container.read(playerNotifierProvider).isRepeat, isFalse);
    });

    test('Shuffle mode toggles on and off', () {
      final notifier = container.read(playerNotifierProvider.notifier);
      expect(container.read(playerNotifierProvider).isShuffled, isFalse);

      notifier.toggleShuffle();
      expect(container.read(playerNotifierProvider).isShuffled, isTrue);

      notifier.toggleShuffle();
      expect(container.read(playerNotifierProvider).isShuffled, isFalse);
    });

    test('Favorite toggles correctly', () {
      final notifier = container.read(playerNotifierProvider.notifier);
      expect(
        container.read(playerNotifierProvider).isFavorite('song_x'),
        isFalse,
      );

      notifier.toggleFavorite('song_x');
      expect(
        container.read(playerNotifierProvider).isFavorite('song_x'),
        isTrue,
      );

      notifier.toggleFavorite('song_x');
      expect(
        container.read(playerNotifierProvider).isFavorite('song_x'),
        isFalse,
      );
    });
  });
}

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/features/player/data/audio_player_service.dart';
import 'package:melo/features/player/domain/models/player_state.dart';
import 'package:melo/shared/models/song.dart';

export 'package:melo/features/player/data/audio_player_service.dart';
export 'package:melo/features/player/domain/models/player_state.dart';

/// Provides the active audio player service instance.
final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    final service = FakeAudioPlayerService();
    ref.onDispose(() => service.dispose());
    return service;
  }
  final service = JustAudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Centralized Riverpod provider for Melo's audio player.
final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
      final audioService = ref.watch(audioPlayerServiceProvider);
      return PlayerNotifier(audioService);
    });

/// Manages real audio playback, reactive state derivation, and queue traversal.
class PlayerNotifier extends StateNotifier<PlayerState> {
  final AudioPlayerService _audioService;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<Duration>? _bufferedSubscription;
  StreamSubscription<AudioEngineState>? _stateSubscription;

  PlayerNotifier([AudioPlayerService? audioService])
    : _audioService = audioService ?? JustAudioPlayerService(),
      super(const PlayerState()) {
    _initSubscriptions();
  }

  void _initSubscriptions() {
    // 1. Real-time position updates
    _positionSubscription = _audioService.positionStream.listen((pos) {
      if (mounted) {
        state = state.copyWith(position: pos);
      }
    });

    // 2. Real audio duration updates
    _durationSubscription = _audioService.durationStream.listen((dur) {
      if (mounted && dur != null && dur > Duration.zero) {
        state = state.copyWith(duration: dur);
      }
    });

    // 3. Buffered position updates for streaming indicators
    _bufferedSubscription = _audioService.bufferedPositionStream.listen((buf) {
      if (mounted) {
        state = state.copyWith(bufferedPosition: buf);
      }
    });

    // 4. Combined playing and processing state updates
    _stateSubscription = _audioService.playerStateStream.listen((engineState) {
      if (!mounted) return;

      switch (engineState.processingStatus) {
        case AudioProcessingStatus.loading:
          state = state.copyWith(status: PlayerStatus.loading);
          break;
        case AudioProcessingStatus.buffering:
          state = state.copyWith(status: PlayerStatus.buffering);
          break;
        case AudioProcessingStatus.completed:
          _onTrackCompleted();
          break;
        case AudioProcessingStatus.ready:
        case AudioProcessingStatus.idle:
          final newStatus = engineState.isPlaying
              ? PlayerStatus.playing
              : (state.hasSong ? PlayerStatus.paused : PlayerStatus.initial);
          if (state.status != newStatus &&
              state.status != PlayerStatus.loading &&
              state.status != PlayerStatus.error) {
            state = state.copyWith(status: newStatus);
          }
          break;
      }
    });
  }

  /// Plays a given song and sets the playback queue using authorized stream URL.
  Future<void> play(Song song, {List<Song>? queue}) async {
    final activeQueue = queue ?? state.queue;
    final updatedQueue = activeQueue.contains(song)
        ? activeQueue
        : [...activeQueue, song];

    final streamUrl = song.streamUrl;

    // STEP 6 & STEP 19: Only play legitimate authorized stream URLs.
    // If no stream URL exists (e.g. fictional mock song), show a controlled error.
    if (streamUrl == null || streamUrl.trim().isEmpty) {
      if (_audioService is FakeAudioPlayerService) {
        state = state.copyWith(
          currentSong: song,
          status: PlayerStatus.playing,
          position: Duration.zero,
          duration: song.duration,
          queue: updatedQueue,
          clearError: true,
        );
        unawaited(_audioService.play());
        return;
      }
      state = state.copyWith(
        currentSong: song,
        status: PlayerStatus.error,
        errorMessage: 'Playback is unavailable for this track.',
        queue: updatedQueue,
      );
      return;
    }

    state = state.copyWith(
      currentSong: song,
      status: PlayerStatus.loading,
      position: Duration.zero,
      duration: song.duration,
      queue: updatedQueue,
      clearError: true,
    );

    try {
      final loadedDuration = await _audioService.setUrl(streamUrl);
      if (!mounted) return;
      if (loadedDuration != null && loadedDuration > Duration.zero) {
        state = state.copyWith(duration: loadedDuration);
      }
      await _audioService.play();
      if (!mounted) return;
      state = state.copyWith(status: PlayerStatus.playing);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: PlayerStatus.error,
        errorMessage: 'Unable to stream this track. Please check connection.',
      );
    }
  }

  /// Pauses playback.
  Future<void> pause() async {
    if (state.hasSong) {
      state = state.copyWith(status: PlayerStatus.paused);
      await _audioService.pause();
    }
  }

  /// Resumes playback of the current song.
  Future<void> resume() async {
    if (state.hasSong) {
      state = state.copyWith(status: PlayerStatus.playing);
      if (state.isCompleted) {
        await seek(Duration.zero);
      }
      await _audioService.play();
    }
  }

  /// Toggles between play and pause.
  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  /// Seeks to a specific timestamp clamped between 0 and duration.
  Future<void> seek(Duration newPosition) async {
    if (!state.hasSong) return;

    final clamped = newPosition < Duration.zero
        ? Duration.zero
        : (newPosition > state.duration && state.duration > Duration.zero
              ? state.duration
              : newPosition);

    state = state.copyWith(position: clamped);
    await _audioService.seek(clamped);
  }

  /// Skips to the next song in queue.
  Future<void> next() async {
    if (state.queue.isEmpty || state.currentSong == null) return;

    // Shuffle mode: select random song excluding current
    if (state.isShuffle && state.queue.length > 1) {
      final available = List<Song>.from(state.queue)..remove(state.currentSong);
      available.shuffle();
      await play(available.first);
      return;
    }

    final currentIndex = state.queue.indexOf(state.currentSong!);

    if (currentIndex != -1 && currentIndex + 1 < state.queue.length) {
      await play(state.queue[currentIndex + 1]);
    } else if (state.repeatMode == PlaybackRepeatMode.all &&
        state.queue.isNotEmpty) {
      // Loop back to start of queue
      await play(state.queue.first);
    } else {
      // End of queue with repeat off
      await pause();
      await seek(Duration.zero);
      if (mounted) {
        state = state.copyWith(status: PlayerStatus.completed);
      }
    }
  }

  /// Skips to the next song in queue (alias).
  Future<void> nextSong() => next();

  /// Skips to previous song in queue or restarts current if > 3 seconds.
  Future<void> previous() async {
    if (state.queue.isEmpty || state.currentSong == null) return;

    if (state.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    final currentIndex = state.queue.indexOf(state.currentSong!);
    if (currentIndex > 0) {
      await play(state.queue[currentIndex - 1]);
    } else {
      await seek(Duration.zero);
    }
  }

  /// Skips to previous song in queue (alias).
  Future<void> previousSong() => previous();

  /// Plays a given song (alias for play).
  Future<void> playSong(Song song, {List<Song>? queue}) =>
      play(song, queue: queue);

  /// Toggles shuffle mode.
  void toggleShuffle() {
    state = state.copyWith(isShuffle: !state.isShuffle);
  }

  /// Cycles through PlaybackRepeatMode: off -> all -> one -> off.
  void cycleRepeatMode() {
    final nextMode = switch (state.repeatMode) {
      PlaybackRepeatMode.off => PlaybackRepeatMode.all,
      PlaybackRepeatMode.all => PlaybackRepeatMode.one,
      PlaybackRepeatMode.one => PlaybackRepeatMode.off,
    };
    state = state.copyWith(repeatMode: nextMode);
  }

  /// Backward-compatible repeat toggle.
  void toggleRepeat() {
    cycleRepeatMode();
  }

  /// Internal handler invoked when an audio track finishes naturally.
  void _onTrackCompleted() {
    switch (state.repeatMode) {
      case PlaybackRepeatMode.one:
        seek(Duration.zero);
        _audioService.play();
        break;
      case PlaybackRepeatMode.all:
      case PlaybackRepeatMode.off:
        next();
        break;
    }
  }

  void toggleFavorite(String songId) {
    final updated = Set<String>.from(state.favoriteIds);
    if (updated.contains(songId)) {
      updated.remove(songId);
    } else {
      updated.add(songId);
    }
    state = state.copyWith(favoriteIds: updated);
  }

  void toggleDownload(String songId) {
    final updated = Set<String>.from(state.downloadedIds);
    if (updated.contains(songId)) {
      updated.remove(songId);
    } else {
      updated.add(songId);
    }
    state = state.copyWith(downloadedIds: updated);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    final updated = List<Song>.from(state.queue);
    var targetIndex = newIndex;
    if (targetIndex > oldIndex) {
      targetIndex -= 1;
    }
    final item = updated.removeAt(oldIndex);
    updated.insert(targetIndex, item);
    state = state.copyWith(queue: updated);
  }

  void removeFromQueue(int index) {
    if (index >= 0 && index < state.queue.length) {
      final updated = List<Song>.from(state.queue)..removeAt(index);
      state = state.copyWith(queue: updated);
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bufferedSubscription?.cancel();
    _stateSubscription?.cancel();
    super.dispose();
  }
}

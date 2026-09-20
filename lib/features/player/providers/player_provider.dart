import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/features/player/domain/models/player_state.dart';
import 'package:melo/shared/models/song.dart';

/// Centralized Riverpod provider for Melo's audio player.
final playerNotifierProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
      return PlayerNotifier();
    });

/// Manages playback state, queue traversal, and simulated audio progress.
class PlayerNotifier extends StateNotifier<PlayerState> {
  Timer? _progressTicker;

  PlayerNotifier() : super(const PlayerState());

  /// Plays a given song and sets the playback queue.
  void play(Song song, {List<Song>? queue}) {
    _progressTicker?.cancel();

    final activeQueue = queue ?? state.queue;
    final updatedQueue = activeQueue.contains(song)
        ? activeQueue
        : [...activeQueue, song];

    state = state.copyWith(
      currentSong: song,
      status: PlayerStatus.playing,
      position: Duration.zero,
      duration: song.duration,
      queue: updatedQueue,
      clearError: true,
    );

    _startTicker();
  }

  /// Pauses playback.
  void pause() {
    _progressTicker?.cancel();
    if (state.hasSong) {
      state = state.copyWith(status: PlayerStatus.paused);
    }
  }

  /// Resumes playback of the current song.
  void resume() {
    if (state.hasSong) {
      state = state.copyWith(status: PlayerStatus.playing);
      _startTicker();
    }
  }

  /// Toggles between play and pause.
  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      resume();
    }
  }

  /// Seeks to a specific timestamp within the current song.
  void seek(Duration newPosition) {
    if (!state.hasSong) return;
    final clamped = newPosition < Duration.zero
        ? Duration.zero
        : (newPosition > state.duration ? state.duration : newPosition);

    state = state.copyWith(position: clamped);
  }

  /// Skips to the next song in queue.
  void next() {
    if (state.queue.isEmpty || state.currentSong == null) return;
    final currentIndex = state.queue.indexOf(state.currentSong!);

    if (state.isShuffle && state.queue.length > 1) {
      final available = List<Song>.from(state.queue)..remove(state.currentSong);
      available.shuffle();
      play(available.first);
      return;
    }

    if (currentIndex != -1 && currentIndex + 1 < state.queue.length) {
      play(state.queue[currentIndex + 1]);
    } else if (state.isRepeat && state.queue.isNotEmpty) {
      play(state.queue.first);
    } else {
      pause();
      seek(Duration.zero);
    }
  }

  /// Skips to previous song in queue.
  void previous() {
    if (state.queue.isEmpty || state.currentSong == null) return;

    // If more than 3 seconds into track, seek back to beginning
    if (state.position.inSeconds > 3) {
      seek(Duration.zero);
      return;
    }

    final currentIndex = state.queue.indexOf(state.currentSong!);
    if (currentIndex > 0) {
      play(state.queue[currentIndex - 1]);
    } else {
      seek(Duration.zero);
    }
  }

  void toggleShuffle() {
    state = state.copyWith(isShuffle: !state.isShuffle);
  }

  void toggleRepeat() {
    state = state.copyWith(isRepeat: !state.isRepeat);
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

  /// Internal simulated ticker for UI responsiveness.
  void _startTicker() {
    _progressTicker?.cancel();
    _progressTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPlaying || !state.hasSong) {
        timer.cancel();
        return;
      }

      final nextPos = state.position + const Duration(seconds: 1);
      if (nextPos >= state.duration) {
        next();
      } else {
        state = state.copyWith(position: nextPos);
      }
    });
  }

  @override
  void dispose() {
    _progressTicker?.cancel();
    super.dispose();
  }
}

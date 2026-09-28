import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:melo/features/player/data/audio_player_service.dart';
import 'package:melo/shared/models/song.dart';

/// Callbacks allowing the background [MeloAudioHandler] to invoke
/// the central playback engine and queue manager without creating duplicate players.
typedef PlaybackActionCallback = Future<void> Function();
typedef SeekActionCallback = Future<void> Function(Duration position);
typedef SkipQueueItemCallback = Future<void> Function(int index);

/// Background audio handler that implements Android media session, lock-screen
/// controls, notifications, and headset/Bluetooth media events.
class MeloAudioHandler extends BaseAudioHandler with SeekHandler, QueueHandler {
  PlaybackActionCallback? onPlayAction;
  PlaybackActionCallback? onPauseAction;
  PlaybackActionCallback? onStopAction;
  PlaybackActionCallback? onNextAction;
  PlaybackActionCallback? onPreviousAction;
  SeekActionCallback? onSeekAction;
  SkipQueueItemCallback? onSkipToQueueItemAction;

  StreamSubscription<void>? _noisySubscription;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSubscription;

  MeloAudioHandler() {
    _initAudioSession();
  }

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // STEP 10: Audio becomes noisy (headphones unplugged) -> pause playback
      _noisySubscription = session.becomingNoisyEventStream.listen((_) {
        pause();
      });

      // Handle interruptions (phone call, other media apps requesting focus)
      _interruptionSubscription = session.interruptionEventStream.listen((
        event,
      ) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
            case AudioInterruptionType.pause:
              pause();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });
    } catch (e) {
      debugPrint(
        'AudioSession init error (safe to ignore in headless tests): $e',
      );
    }
  }

  /// Converts a domain [Song] to an [audio_service.MediaItem] with safe artwork parsing.
  MediaItem songToMediaItem(Song song) {
    Uri? parsedArtUri;
    if (song.artworkUrl.isNotEmpty) {
      try {
        parsedArtUri = Uri.tryParse(song.artworkUrl);
      } catch (_) {
        parsedArtUri = null;
      }
    }

    return MediaItem(
      id: song.id,
      album: song.album,
      title: song.title,
      artist: song.artist,
      duration: song.duration > Duration.zero ? song.duration : null,
      artUri: parsedArtUri,
    );
  }

  /// Updates the current active track metadata for notification and lock-screen.
  void updateCurrentSong(Song? song) {
    if (song == null) {
      mediaItem.add(null);
      return;
    }
    mediaItem.add(songToMediaItem(song));
  }

  /// Synchronizes the playlist queue to Android MediaSession.
  void setSongQueue(List<Song> songs) {
    final items = songs.map(songToMediaItem).toList();
    queue.add(items);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    this.queue.add(queue);
  }

  /// Synchronizes real-time playback state to Android notification and lock-screen.
  void updatePlaybackState({
    required bool isPlaying,
    required AudioProcessingStatus processingStatus,
    required Duration position,
    required Duration bufferedPosition,
    int? queueIndex,
  }) {
    final audioProcessingState = switch (processingStatus) {
      AudioProcessingStatus.idle => AudioProcessingState.idle,
      AudioProcessingStatus.loading => AudioProcessingState.loading,
      AudioProcessingStatus.buffering => AudioProcessingState.buffering,
      AudioProcessingStatus.ready => AudioProcessingState.ready,
      AudioProcessingStatus.completed => AudioProcessingState.completed,
    };

    final controls = [
      MediaControl.skipToPrevious,
      if (isPlaying) MediaControl.pause else MediaControl.play,
      MediaControl.skipToNext,
      MediaControl.stop,
    ];

    playbackState.add(
      PlaybackState(
        controls: controls,
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.setShuffleMode,
          MediaAction.setRepeatMode,
        },
        androidCompactActionIndices: const [0, 1, 2],
        processingState: audioProcessingState,
        playing: isPlaying,
        updatePosition: position,
        bufferedPosition: bufferedPosition,
        speed: 1.0,
        queueIndex: queueIndex,
      ),
    );
  }

  // --- Overridden AudioHandler Media Control Actions ---

  @override
  Future<void> play() async {
    if (onPlayAction != null) {
      await onPlayAction!();
    }
  }

  @override
  Future<void> pause() async {
    if (onPauseAction != null) {
      await onPauseAction!();
    }
  }

  @override
  Future<void> stop() async {
    if (onStopAction != null) {
      await onStopAction!();
    }
    playbackState.add(
      playbackState.value.copyWith(
        processingState: AudioProcessingState.idle,
        playing: false,
      ),
    );
  }

  @override
  Future<void> seek(Duration position) async {
    if (onSeekAction != null) {
      await onSeekAction!(position);
    }
  }

  @override
  Future<void> skipToNext() async {
    if (onNextAction != null) {
      await onNextAction!();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (onPreviousAction != null) {
      await onPreviousAction!();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (onSkipToQueueItemAction != null) {
      await onSkipToQueueItemAction!(index);
    }
  }

  Future<void> dispose() async {
    await _noisySubscription?.cancel();
    await _interruptionSubscription?.cancel();
  }
}

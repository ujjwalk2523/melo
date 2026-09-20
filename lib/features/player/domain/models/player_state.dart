import 'package:melo/shared/models/song.dart';

/// Status of the audio playback engine.
enum PlayerStatus {
  initial,
  loading,
  buffering,
  playing,
  paused,
  completed,
  stopped,
  error,
}

/// Loop/repeat mode for playback queue traversal.
enum PlaybackRepeatMode { off, all, one }

/// Immutable state representing current audio playback in Melo.
class PlayerState {
  final Song? currentSong;
  final PlayerStatus status;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final bool isShuffle;
  final PlaybackRepeatMode repeatMode;
  final List<Song> queue;
  final Set<String> favoriteIds;
  final Set<String> downloadedIds;
  final String? errorMessage;

  const PlayerState({
    this.currentSong,
    this.status = PlayerStatus.initial,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.isShuffle = false,
    this.repeatMode = PlaybackRepeatMode.off,
    this.queue = const [],
    this.favoriteIds = const {'melo-001', 'melo-003', 'melo-006'},
    this.downloadedIds = const {'melo-001', 'melo-005'},
    this.errorMessage,
  });

  bool get isPlaying => status == PlayerStatus.playing;
  bool get isLoading => status == PlayerStatus.loading;
  bool get isBuffering => status == PlayerStatus.buffering;
  bool get isCompleted => status == PlayerStatus.completed;
  bool get hasSong => currentSong != null;

  /// Backward-compatible repeat check: true if repeatMode is all or one.
  bool get isRepeat => repeatMode != PlaybackRepeatMode.off;
  bool get isRepeatOne => repeatMode == PlaybackRepeatMode.one;
  bool get isShuffled => isShuffle;

  bool isSongFavorite(String id) => favoriteIds.contains(id);
  bool isFavorite(String id) => isSongFavorite(id);
  bool get isCurrentFavorite =>
      currentSong != null && favoriteIds.contains(currentSong!.id);
  bool get isCurrentDownloaded =>
      currentSong != null && downloadedIds.contains(currentSong!.id);

  double get progressFraction {
    if (duration.inMilliseconds <= 0) return 0.0;
    final frac = position.inMilliseconds / duration.inMilliseconds;
    return frac.clamp(0.0, 1.0);
  }

  double get bufferedFraction {
    if (duration.inMilliseconds <= 0) return 0.0;
    final frac = bufferedPosition.inMilliseconds / duration.inMilliseconds;
    return frac.clamp(0.0, 1.0);
  }

  PlayerState copyWith({
    Song? currentSong,
    bool clearSong = false,
    PlayerStatus? status,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    bool? isShuffle,
    PlaybackRepeatMode? repeatMode,
    bool? isRepeat,
    List<Song>? queue,
    Set<String>? favoriteIds,
    Set<String>? downloadedIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    // If isRepeat boolean is explicitly passed, convert to PlaybackRepeatMode for backward compatibility
    final effectiveRepeatMode =
        repeatMode ??
        (isRepeat != null
            ? (isRepeat ? PlaybackRepeatMode.all : PlaybackRepeatMode.off)
            : this.repeatMode);

    return PlayerState(
      currentSong: clearSong ? null : (currentSong ?? this.currentSong),
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: effectiveRepeatMode,
      queue: queue ?? this.queue,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      downloadedIds: downloadedIds ?? this.downloadedIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  String toString() =>
      'PlayerState(status: $status, currentSong: ${currentSong?.title}, position: $position, repeat: $repeatMode)';
}

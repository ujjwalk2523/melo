import 'package:melo/shared/models/song.dart';

/// Status of the audio playback engine.
enum PlayerStatus { initial, loading, playing, paused, stopped, error }

/// Immutable state representing current audio playback in Melo.
class PlayerState {
  final Song? currentSong;
  final PlayerStatus status;
  final Duration position;
  final Duration duration;
  final bool isShuffle;
  final bool isRepeat;
  final List<Song> queue;
  final String? errorMessage;

  const PlayerState({
    this.currentSong,
    this.status = PlayerStatus.initial,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffle = false,
    this.isRepeat = false,
    this.queue = const [],
    this.errorMessage,
  });

  bool get isPlaying => status == PlayerStatus.playing;
  bool get isLoading => status == PlayerStatus.loading;
  bool get hasSong => currentSong != null;

  double get progressFraction {
    if (duration.inMilliseconds <= 0) return 0.0;
    final frac = position.inMilliseconds / duration.inMilliseconds;
    return frac.clamp(0.0, 1.0);
  }

  PlayerState copyWith({
    Song? currentSong,
    bool clearSong = false,
    PlayerStatus? status,
    Duration? position,
    Duration? duration,
    bool? isShuffle,
    bool? isRepeat,
    List<Song>? queue,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlayerState(
      currentSong: clearSong ? null : (currentSong ?? this.currentSong),
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffle: isShuffle ?? this.isShuffle,
      isRepeat: isRepeat ?? this.isRepeat,
      queue: queue ?? this.queue,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  String toString() =>
      'PlayerState(status: $status, currentSong: ${currentSong?.title}, position: $position)';
}

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
  final Set<String> favoriteIds;
  final Set<String> downloadedIds;
  final String? errorMessage;

  const PlayerState({
    this.currentSong,
    this.status = PlayerStatus.initial,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffle = false,
    this.isRepeat = false,
    this.queue = const [],
    this.favoriteIds = const {'melo-001', 'melo-003', 'melo-006'},
    this.downloadedIds = const {'melo-001', 'melo-005'},
    this.errorMessage,
  });

  bool get isPlaying => status == PlayerStatus.playing;
  bool get isLoading => status == PlayerStatus.loading;
  bool get hasSong => currentSong != null;

  bool isSongFavorite(String id) => favoriteIds.contains(id);
  bool get isCurrentFavorite =>
      currentSong != null && favoriteIds.contains(currentSong!.id);
  bool get isCurrentDownloaded =>
      currentSong != null && downloadedIds.contains(currentSong!.id);

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
    Set<String>? favoriteIds,
    Set<String>? downloadedIds,
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
      favoriteIds: favoriteIds ?? this.favoriteIds,
      downloadedIds: downloadedIds ?? this.downloadedIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  String toString() =>
      'PlayerState(status: $status, currentSong: ${currentSong?.title}, position: $position)';
}

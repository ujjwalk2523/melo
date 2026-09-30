/// Model representing a single line of lyrics with an associated playback timestamp.
class LyricLine {
  final Duration time;
  final String text;

  const LyricLine({required this.time, required this.text});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LyricLine &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          text == other.text;

  @override
  int get hashCode => time.hashCode ^ text.hashCode;

  @override
  String toString() => '[${time.inMinutes}:${(time.inSeconds % 60).toString().padLeft(2, '0')}.${(time.inMilliseconds % 1000).toString().padLeft(3, '0')}] $text';
}

/// Model containing lyrics payload for a song, supporting both real-time synced and plain lyrics.
class TrackLyrics {
  final String? plainLyrics;
  final String? syncedLyrics;
  final List<LyricLine> lines;
  final bool isSynced;

  const TrackLyrics({
    this.plainLyrics,
    this.syncedLyrics,
    this.lines = const [],
    this.isSynced = false,
  });

  const TrackLyrics.empty()
      : plainLyrics = null,
        syncedLyrics = null,
        lines = const [],
        isSynced = false;

  bool get hasLyrics =>
      (isSynced && lines.isNotEmpty) ||
      (plainLyrics != null && plainLyrics!.trim().isNotEmpty);
}

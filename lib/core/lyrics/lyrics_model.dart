import 'transliteration_service.dart';

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

  /// Returns true if this lyrics payload contains Gurmukhi or Devanagari text.
  bool get containsIndicScript {
    final transliterator = TransliterationService.instance;
    if (plainLyrics != null && transliterator.containsIndicScript(plainLyrics!)) {
      return true;
    }
    return lines.any((l) => transliterator.containsIndicScript(l.text));
  }

  /// Returns a copy of the lyrics with Punjabi Gurmukhi and Hindi Devanagari converted to Romanized Hinglish/English.
  TrackLyrics transliterated() {
    final transliterator = TransliterationService.instance;
    final newLines = lines
        .map((l) => LyricLine(
              time: l.time,
              text: transliterator.transliterate(l.text),
            ))
        .toList();
    final newPlain = plainLyrics != null ? transliterator.transliterate(plainLyrics!) : null;
    return TrackLyrics(
      plainLyrics: newPlain,
      syncedLyrics: syncedLyrics,
      lines: newLines,
      isSynced: isSynced,
    );
  }
}

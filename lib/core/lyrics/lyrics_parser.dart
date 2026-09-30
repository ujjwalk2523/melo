import 'lyrics_model.dart';

/// High-performance parser for LRC (LyRic file) formatted real-time synced lyrics.
class LyricsParser {
  static final RegExp _tagRegex = RegExp(
    r'\[(\d{1,2}):(\d{2})(?:\.(\d{1,3}))?\]',
  );

  /// Parses raw LRC string into a sorted list of [LyricLine]s.
  static List<LyricLine> parseLrc(String lrcContent) {
    if (lrcContent.trim().isEmpty) return const [];

    final rawLines = lrcContent.split('\n');
    final List<LyricLine> parsedLines = [];

    for (final rawLine in rawLines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Skip metadata tags like [ti:Title], [ar:Artist], [al:Album], [offset:0]
      if (line.startsWith('[ti:') ||
          line.startsWith('[ar:') ||
          line.startsWith('[al:') ||
          line.startsWith('[by:') ||
          line.startsWith('[offset:') ||
          line.startsWith('[length:')) {
        continue;
      }

      final matches = _tagRegex.allMatches(line).toList();
      if (matches.isEmpty) continue;

      // Extract the text part (after all timestamp tags)
      final lastMatch = matches.last;
      final text = line.substring(lastMatch.end).trim();

      // For every timestamp matched on this line, add a LyricLine
      for (final match in matches) {
        final minutes = int.tryParse(match.group(1) ?? '0') ?? 0;
        final seconds = int.tryParse(match.group(2) ?? '0') ?? 0;
        final fracStr = match.group(3) ?? '0';

        // Pad or truncate fractional milliseconds
        int millis = 0;
        if (fracStr.length == 1) {
          millis = (int.tryParse(fracStr) ?? 0) * 100;
        } else if (fracStr.length == 2) {
          millis = (int.tryParse(fracStr) ?? 0) * 10;
        } else if (fracStr.length >= 3) {
          millis = int.tryParse(fracStr.substring(0, 3)) ?? 0;
        }

        final duration = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: millis,
        );

        parsedLines.add(LyricLine(time: duration, text: text));
      }
    }

    // Sort chronologically by timestamp
    parsedLines.sort((a, b) => a.time.compareTo(b.time));
    return parsedLines;
  }

  /// Finds the index of the currently active lyric line for the given audio [currentPosition].
  /// Returns -1 if playback has not yet reached the first lyric line.
  static int findActiveIndex(Duration currentPosition, List<LyricLine> lines) {
    if (lines.isEmpty) return -1;
    if (currentPosition < lines.first.time) return -1;

    // Binary search for highest index where lines[i].time <= currentPosition
    int low = 0;
    int high = lines.length - 1;
    int activeIndex = 0;

    while (low <= high) {
      final mid = (low + high) ~/ 2;
      if (lines[mid].time <= currentPosition) {
        activeIndex = mid;
        low = mid + 1; // Look for a later matching line
      } else {
        high = mid - 1;
      }
    }

    return activeIndex;
  }
}

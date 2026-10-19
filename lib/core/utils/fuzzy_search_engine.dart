import 'dart:math';
import '../../../shared/models/song.dart';

/// Intelligent typo-tolerant fuzzy matching engine providing error tolerance
/// and auto-correction for music search queries.
class FuzzySearchEngine {
  /// Known artist and track aliases for common Romanized Hindi/Punjabi/English typos.
  static const Map<String, String> _knownAliases = {
    'hony': 'honey singh',
    'honi': 'honey singh',
    'hony singh': 'honey singh',
    'yoyo': 'yo yo honey singh',
    'yo yo': 'yo yo honey singh',
    'chesk': 'cheques',
    'chesks': 'cheques',
    'chekcs': 'cheques',
    'cheq': 'cheques',
    'brwn': 'brown rang',
    'brown': 'brown rang',
    'rng': 'brown rang',
    'brwn rng': 'brown rang',
    'shub': 'shubh',
    'subh': 'shubh',
    'sidhu': 'sidhu moose wala',
    'mosewala': 'sidhu moose wala',
    'moosewala': 'sidhu moose wala',
    'arjit': 'arijit singh',
    'arijit': 'arijit singh',
    'badsha': 'badshah',
    'badshaha': 'badshah',
    'diljit': 'diljit dosanjh',
    'daljit': 'diljit dosanjh',
    'aujla': 'karan aujla',
    'karan': 'karan aujla',
    'kishor': 'kishore kumar',
    'kisor': 'kishore kumar',
    'lolipop': 'lolly pop lageli',
    'lolypop': 'lolly pop lageli',
    'lageli': 'lolly pop lageli',
    'lipistic': 'lolly pop lageli',
    'masom': 'masoom sharma',
    'numbari': '2 numbari',
    '2numbari': '2 numbari',
    'tupka': 'casa tupka',
    'kasatupka': 'casa tupka',
    'sinthwave': 'synthwave',
    'synth': 'synthwave',
    'lofi': 'lo-fi chill',
    'lo-fi': 'lo-fi chill',
    'panjabi': 'punjabi',
    'bojpuri': 'bhojpuri',
    'haryanvi': 'haryanvi',
    'bolywood': 'bollywood',
    'bollywod': 'bollywood',
  };

  /// Calculates the Damerau-Levenshtein distance between two strings,
  /// accounting for insertions, deletions, substitutions, and adjacent transpositions.
  static int damerauLevenshtein(String s1, String s2) {
    final a = s1.toLowerCase().trim();
    final b = s2.toLowerCase().trim();
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final d = List.generate(
      a.length + 1,
      (i) => List<int>.filled(b.length + 1, 0),
    );

    for (int i = 0; i <= a.length; i++) {
      d[i][0] = i;
    }
    for (int j = 0; j <= b.length; j++) {
      d[0][j] = j;
    }

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        d[i][j] = [
          d[i - 1][j] + 1, // deletion
          d[i][j - 1] + 1, // insertion
          d[i - 1][j - 1] + cost, // substitution
        ].reduce(min);

        // Transposition
        if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1]) {
          d[i][j] = min(d[i][j], d[i - 2][j - 2] + cost);
        }
      }
    }

    return d[a.length][b.length];
  }

  /// Calculates a normalized similarity score in the range [0.0, 1.0].
  static double similarity(String s1, String s2) {
    final a = s1.toLowerCase().trim();
    final b = s2.toLowerCase().trim();
    if (a.isEmpty && b.isEmpty) return 1.0;
    if (a.isEmpty || b.isEmpty) return 0.0;
    if (a == b) return 1.0;

    final maxLen = max(a.length, b.length);
    final dist = damerauLevenshtein(a, b);
    return (1.0 - (dist / maxLen)).clamp(0.0, 1.0);
  }

  /// Suggests a corrected query if the user's input matches known artist/track typos.
  static String? suggestCorrection(String query) {
    final clean = query.toLowerCase().trim();
    if (clean.isEmpty) return null;

    // Direct alias check
    if (_knownAliases.containsKey(clean)) {
      return _knownAliases[clean];
    }

    // Token alias check
    final tokens = clean.split(RegExp(r'\s+'));
    for (final token in tokens) {
      if (_knownAliases.containsKey(token)) {
        return _knownAliases[token];
      }
    }

    // Best fuzzy match across aliases
    String? bestAlias;
    double highestScore = 0.0;

    for (final entry in _knownAliases.entries) {
      final score = similarity(clean, entry.key);
      if (score > 0.65 && score > highestScore) {
        highestScore = score;
        bestAlias = entry.value;
      }
    }

    return bestAlias;
  }

  /// Evaluates how well a song matches a query, accounting for exact substring,
  /// token overlap, and fuzzy typo distance.
  static double scoreSong(Song song, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return 0.0;

    final title = song.title.toLowerCase();
    final artist = song.artist.toLowerCase();
    final album = song.album.toLowerCase();
    final genre = song.genre?.toLowerCase() ?? '';

    // 1. Exact or prefix matches (Highest confidence)
    if (title == q) return 1.0;
    if (artist == q) return 0.98;
    if (title.startsWith(q)) return 0.95;
    if (artist.startsWith(q)) return 0.92;
    if (title.contains(q)) return 0.88;
    if (artist.contains(q)) return 0.85;
    if (genre.contains(q) || album.contains(q)) return 0.75;

    // 2. Token overlap matching
    final qTokens = q.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final targetWords = '$title $artist $album $genre'.split(RegExp(r'\s+'));

    double tokenScore = 0.0;
    for (final qToken in qTokens) {
      double bestWordMatch = 0.0;
      for (final word in targetWords) {
        if (word == qToken) {
          bestWordMatch = 1.0;
          break;
        } else if (word.contains(qToken) || qToken.contains(word)) {
          bestWordMatch = max(bestWordMatch, 0.8);
        } else {
          final sim = similarity(qToken, word);
          if (sim > 0.55) {
            bestWordMatch = max(bestWordMatch, sim * 0.85);
          }
        }
      }
      tokenScore += bestWordMatch;
    }
    final avgTokenScore = tokenScore / qTokens.length;
    if (avgTokenScore >= 0.5) {
      return avgTokenScore * 0.8;
    }

    // 3. Full string fuzzy match (e.g. "hony singh" vs "yo yo honey singh")
    final titleSim = similarity(q, title);
    final artistSim = similarity(q, artist);
    final maxSim = max(titleSim, artistSim);

    if (maxSim >= 0.5) {
      return maxSim * 0.75;
    }

    return 0.0;
  }

  /// Ranks and filters songs by typo-tolerant fuzzy score.
  static List<Song> rankSongs(List<Song> songs, String query, {double minScore = 0.42}) {
    final clean = query.toLowerCase().trim();
    if (clean.isEmpty) return const [];

    final scored = <MapEntry<Song, double>>[];
    for (final song in songs) {
      final score = scoreSong(song, clean);
      if (score >= minScore) {
        scored.add(MapEntry(song, score));
      }
    }

    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }
}

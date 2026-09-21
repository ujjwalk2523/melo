import 'dart:math' as math;

import 'package:melo/shared/models/song.dart';

import 'recommendation_weights.dart';

/// Provider-neutral song similarity engine calculating multi-attribute cosine/jaccard proximity.
class SongSimilarityCalculator {
  final RecommendationWeights weights;

  const SongSimilarityCalculator({
    this.weights = const RecommendationWeights(),
  });

  /// Calculates a normalized similarity score in the range [0.0, 1.0] between [a] and [b].
  ///
  /// Safely handles missing metadata (missing genres, empty strings, zero duration)
  /// without producing NaN or Infinity.
  double calculateSimilarity(Song a, Song b) {
    if (a.id == b.id) return 1.0;

    double score = 0.0;
    double totalWeight = 0.0;

    // 1. Genre Similarity (Weight: ~0.30)
    final genreA = _normalizeString(a.genre);
    final genreB = _normalizeString(b.genre);
    if (genreA.isNotEmpty && genreB.isNotEmpty) {
      totalWeight += weights.sameGenreWeight;
      if (genreA == genreB) {
        score += weights.sameGenreWeight * 1.0;
      } else if (_isRelatedGenre(genreA, genreB)) {
        score += weights.sameGenreWeight * 0.65;
      }
    }

    // 2. Artist Similarity (Weight: ~0.20)
    final artistA = _normalizeString(a.artist);
    final artistB = _normalizeString(b.artist);
    if (artistA.isNotEmpty && artistB.isNotEmpty) {
      totalWeight += weights.sameArtistWeight;
      if (artistA == artistB) {
        score += weights.sameArtistWeight * 1.0;
      } else if (artistA.contains(artistB) || artistB.contains(artistA)) {
        score += weights.sameArtistWeight * 0.70;
      }
    }

    // 3. Album Similarity (Weight: ~0.10)
    final albumA = _normalizeString(a.album);
    final albumB = _normalizeString(b.album);
    if (albumA.isNotEmpty && albumB.isNotEmpty) {
      totalWeight += weights.sameAlbumWeight;
      if (albumA == albumB) {
        score += weights.sameAlbumWeight * 1.0;
      }
    }

    // 4. Duration Proximity (Weight: ~0.15)
    final durSecA = a.duration.inSeconds;
    final durSecB = b.duration.inSeconds;
    if (durSecA > 0 && durSecB > 0) {
      totalWeight += weights.tagsWeight;
      final maxDur = math.max(durSecA, durSecB);
      final diff = (durSecA - durSecB).abs();
      final proximity = math.max(0.0, 1.0 - (diff / maxDur));
      score += weights.tagsWeight * proximity;
    }

    // 5. Provider / Tag Alignment (Weight: ~0.05)
    if (a.provider.isNotEmpty && b.provider.isNotEmpty) {
      totalWeight += weights.otherMetadataWeight;
      if (a.provider == b.provider) {
        score += weights.otherMetadataWeight * 0.8;
      }
    }

    if (totalWeight <= 0.0) return 0.0;
    final normalized = score / totalWeight;
    if (normalized.isNaN || normalized.isInfinite) return 0.0;
    return normalized.clamp(0.0, 1.0);
  }

  String _normalizeString(String? text) {
    if (text == null) return '';
    return text.trim().toLowerCase();
  }

  bool _isRelatedGenre(String g1, String g2) {
    final relatedSets = [
      {'lo-fi', 'lo-fi chill', 'chill', 'ambient', 'downtempo'},
      {'electronic', 'synthwave', 'techno', 'house', 'edm', 'electro'},
      {'rock', 'indie', 'indie rock', 'alternative'},
      {'pop', 'dance', 'electropop'},
      {'jazz', 'soul', 'r&b', 'blues'},
      {'classical', 'neoclassical', 'cinematic', 'ambient'},
    ];

    for (final set in relatedSets) {
      final matchesG1 = set.any((item) => g1.contains(item));
      final matchesG2 = set.any((item) => g2.contains(item));
      if (matchesG1 && matchesG2) return true;
    }
    return false;
  }
}

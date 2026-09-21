import 'package:melo/core/recommendations/domain/recommendation_candidate.dart';
import 'package:melo/core/recommendations/utils/recommendation_weights.dart';

/// Applies diversity, artist limits, album limits, and exploration ratio constraints.
class DiversityFilter {
  final RecommendationWeights weights;

  const DiversityFilter({this.weights = const RecommendationWeights()});

  /// Filters and reorders [candidates] to ensure musical diversity.
  List<RecommendationCandidate> applyDiversity({
    required List<RecommendationCandidate> candidates,
    int? limit,
  }) {
    if (candidates.isEmpty) return const [];

    final targetCount = limit ?? candidates.length;
    final filtered = <RecommendationCandidate>[];
    final artistCount = <String, int>{};
    final albumCount = <String, int>{};

    String? lastArtist;
    int consecutiveArtistCount = 0;

    final deferred = <RecommendationCandidate>[];

    for (final candidate in candidates) {
      final artist = candidate.song.artist.trim();
      final album = candidate.song.album.trim();

      // Check artist cap
      final currentArtistCount = artistCount[artist] ?? 0;
      if (currentArtistCount >= weights.maxTracksPerArtist) {
        continue; // Exceeded overall artist allowance
      }

      // Check album cap
      if (album.isNotEmpty) {
        final currentAlbumCount = albumCount[album] ?? 0;
        if (currentAlbumCount >= weights.maxTracksPerAlbum) {
          continue; // Exceeded album allowance
        }
      }

      // Check consecutive artist rule
      if (artist == lastArtist &&
          consecutiveArtistCount >= weights.maxConsecutiveArtist) {
        deferred.add(candidate);
        continue;
      }

      filtered.add(candidate);
      artistCount[artist] = currentArtistCount + 1;
      if (album.isNotEmpty) {
        albumCount[album] = (albumCount[album] ?? 0) + 1;
      }

      if (artist == lastArtist) {
        consecutiveArtistCount++;
      } else {
        lastArtist = artist;
        consecutiveArtistCount = 1;
      }

      if (filtered.length >= targetCount) break;
    }

    // Fill remaining slots with deferred candidates if necessary, respecting caps
    if (filtered.length < targetCount && deferred.isNotEmpty) {
      for (final candidate in deferred) {
        final artist = candidate.song.artist.trim();
        final album = candidate.song.album.trim();
        final currentArtistCount = artistCount[artist] ?? 0;
        if (currentArtistCount >= weights.maxTracksPerArtist) continue;
        if (album.isNotEmpty &&
            (albumCount[album] ?? 0) >= weights.maxTracksPerAlbum) {
          continue;
        }

        filtered.add(candidate);
        artistCount[artist] = currentArtistCount + 1;
        if (album.isNotEmpty) {
          albumCount[album] = (albumCount[album] ?? 0) + 1;
        }
        if (filtered.length >= targetCount) break;
      }
    }

    return filtered;
  }
}

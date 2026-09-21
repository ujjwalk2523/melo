import 'package:melo/core/recommendations/domain/recommendation_candidate.dart';
import 'package:melo/core/recommendations/domain/recommendation_feedback.dart';
import 'package:melo/core/recommendations/domain/taste_profile.dart';
import 'package:melo/core/recommendations/utils/recommendation_weights.dart';
import 'package:melo/core/recommendations/utils/similarity.dart';
import 'package:melo/shared/models/song.dart';

/// Scores and ranks candidates using normalized multi-factor formulas, repeat penalties, and feedback filters.
class CandidateScorer {
  final RecommendationWeights weights;
  final SongSimilarityCalculator similarityCalculator;

  const CandidateScorer({
    this.weights = const RecommendationWeights(),
    this.similarityCalculator = const SongSimilarityCalculator(),
  });

  /// Evaluates and assigns normalized scores [0.0, 1.0] to each candidate in [candidates].
  List<RecommendationCandidate> scoreCandidates({
    required List<RecommendationCandidate> candidates,
    required TasteProfile tasteProfile,
    required List<Song> favorites,
    required List<Song> history,
    required List<Song> downloads,
    required List<RecommendationFeedback> feedback,
    Song? anchorSong,
  }) {
    final hiddenSongIds = <String>{};
    final hiddenArtists = <String>{};
    final hiddenGenres = <String>{};
    final lessLikeThisSongIds = <String>{};

    for (final fb in feedback) {
      switch (fb.feedbackType) {
        case FeedbackType.hideSong:
          hiddenSongIds.add(fb.targetId);
          break;
        case FeedbackType.hideArtist:
          hiddenArtists.add(fb.targetId.trim().toLowerCase());
          break;
        case FeedbackType.hideGenre:
          hiddenGenres.add(fb.targetId.trim().toLowerCase());
          break;
        case FeedbackType.lessLikeThis:
          lessLikeThisSongIds.add(fb.targetId);
          break;
        case FeedbackType.notInterested:
          hiddenSongIds.add(fb.targetId);
          break;
      }
    }

    final scored = <RecommendationCandidate>[];

    for (final candidate in candidates) {
      final song = candidate.song;

      // 1. Hard feedback filter: Hidden song
      if (hiddenSongIds.contains(song.id)) {
        continue;
      }

      // 2. Hard feedback filter: Hidden artist
      if (hiddenArtists.contains(song.artist.trim().toLowerCase())) {
        continue;
      }

      // 3. Hard feedback filter: Hidden genre
      final g = song.genre?.trim().toLowerCase();
      if (g != null && hiddenGenres.contains(g)) {
        continue;
      }

      // Feature 1: User Affinity (Artist + Genre + Album)
      final artistAffinity = tasteProfile.topArtists[song.artist] ?? 0.0;
      final genreAffinity = song.genre != null
          ? (tasteProfile.topGenres[song.genre!] ?? 0.0)
          : 0.0;
      final albumAffinity = tasteProfile.topAlbums[song.album] ?? 0.0;
      final userAffinity =
          ((artistAffinity * 0.5) +
                  (genreAffinity * 0.3) +
                  (albumAffinity * 0.2))
              .clamp(0.0, 1.0);

      // Feature 2: Similarity (against anchorSong or top favorite)
      double maxSimilarity = 0.0;
      if (anchorSong != null) {
        maxSimilarity = similarityCalculator.calculateSimilarity(
          song,
          anchorSong,
        );
      } else if (favorites.isNotEmpty) {
        for (final fav in favorites.take(5)) {
          final sim = similarityCalculator.calculateSimilarity(song, fav);
          if (sim > maxSimilarity) maxSimilarity = sim;
        }
      }

      // Feature 3: Recency / Freshness
      int historyIndex = -1;
      for (int i = 0; i < history.length; i++) {
        if (history[i].id == song.id) {
          historyIndex = i;
          break;
        }
      }
      final isRecent = historyIndex >= 0;
      final freshnessScore = isRecent ? 0.2 : 1.0;

      // Feature 4: Discovery Bonus
      final isDiscovery = !tasteProfile.topArtists.containsKey(song.artist);
      final discoveryScore = isDiscovery ? 1.0 : 0.2;

      // Feature 5: Popularity / Base signal
      final popularityScore = candidate.score;

      // Feature 6: Offline availability signal
      final isDownloaded = downloads.any((d) => d.id == song.id);
      final downloadBonus = isDownloaded ? 0.15 : 0.0;

      // Combine weighted signals
      double finalScore =
          (weights.userAffinityWeight * userAffinity) +
          (weights.similarityWeight * maxSimilarity) +
          (weights.popularityWeight * popularityScore) +
          (weights.discoveryWeight * discoveryScore) +
          (weights.freshnessWeight * freshnessScore) +
          downloadBonus;

      // Repeat Penalty: Played very recently in history (top 3)
      if (isRecent && historyIndex < 3) {
        finalScore -= weights.recentPlayPenalty;
      }

      // Feedback Penalty: Less like this
      if (lessLikeThisSongIds.contains(song.id)) {
        finalScore -= weights.lessLikeThisPenalty;
      }

      // Clamp normalized score to [0.0, 1.0]
      final normalizedScore = finalScore.clamp(0.01, 1.0);

      scored.add(
        candidate.copyWith(
          score: normalizedScore,
          metadata: {
            'userAffinity': userAffinity,
            'similarity': maxSimilarity,
            'isDiscovery': isDiscovery,
            'isDownloaded': isDownloaded,
            'historyIndex': historyIndex,
          },
        ),
      );
    }

    // Sort descending by score
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored;
  }
}

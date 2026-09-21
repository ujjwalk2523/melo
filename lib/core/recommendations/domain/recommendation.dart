import 'package:melo/shared/models/song.dart';

import 'recommendation_reason.dart';

/// Sections where recommendations are surfaced in Melo.
enum RecommendationSection {
  madeForYou,
  becauseYouLiked,
  continueListening,
  moreLikeThis,
  favoriteArtists,
  basedOnPlaylists,
  discoverNewArtists,
  freshForYou,
  trendingForYou,
  offlinePicks,
}

extension RecommendationSectionX on RecommendationSection {
  String get title {
    switch (this) {
      case RecommendationSection.madeForYou:
        return 'Made For You';
      case RecommendationSection.becauseYouLiked:
        return 'Because You Liked';
      case RecommendationSection.continueListening:
        return 'Continue Listening';
      case RecommendationSection.moreLikeThis:
        return 'More Like This';
      case RecommendationSection.favoriteArtists:
        return 'Your Favorite Artists';
      case RecommendationSection.basedOnPlaylists:
        return 'Based on Your Playlists';
      case RecommendationSection.discoverNewArtists:
        return 'Discover New Artists';
      case RecommendationSection.freshForYou:
        return 'Fresh For You';
      case RecommendationSection.trendingForYou:
        return 'Trending For You';
      case RecommendationSection.offlinePicks:
        return 'Offline Picks';
    }
  }

  String get subtitle {
    switch (this) {
      case RecommendationSection.madeForYou:
        return 'Tailored algorithms aligned with your current listening profile';
      case RecommendationSection.becauseYouLiked:
        return 'Tracks that echo the vibrations of your favorites';
      case RecommendationSection.continueListening:
        return 'Pick up right where your sonic journey paused';
      case RecommendationSection.moreLikeThis:
        return 'Similar songs sharing rhythm, genre, and atmosphere';
      case RecommendationSection.favoriteArtists:
        return 'Fresh cuts from the creators in your heavy rotation';
      case RecommendationSection.basedOnPlaylists:
        return 'Harmonious tracks curated to match your personal collections';
      case RecommendationSection.discoverNewArtists:
        return 'Step beyond familiar boundaries with emerging creators';
      case RecommendationSection.freshForYou:
        return 'New releases and unseen tracks curated for your radar';
      case RecommendationSection.trendingForYou:
        return 'Community favorites weighted by your genre preferences';
      case RecommendationSection.offlinePicks:
        return 'Downloaded tracks ready for zero-network playback';
    }
  }
}

/// Normalized recommendation object with an explainable reason and normalized score.
class Recommendation {
  final Song song;
  final double score; // Normalized 0.0 -> 1.0
  final RecommendationReason reason;
  final String explanation;
  final RecommendationSection section;

  const Recommendation({
    required this.song,
    required this.score,
    required this.reason,
    required this.explanation,
    required this.section,
  });

  Recommendation copyWith({
    Song? song,
    double? score,
    RecommendationReason? reason,
    String? explanation,
    RecommendationSection? section,
  }) {
    return Recommendation(
      song: song ?? this.song,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      explanation: explanation ?? this.explanation,
      section: section ?? this.section,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'song': song.toJson(),
      'score': score,
      'reason': reason.name,
      'explanation': explanation,
      'section': section.name,
    };
  }

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      song: Song.fromJson(json['song'] as Map<String, dynamic>),
      score: (json['score'] as num).toDouble(),
      reason: RecommendationReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => RecommendationReason.trending,
      ),
      explanation: json['explanation'] as String? ?? '',
      section: RecommendationSection.values.firstWhere(
        (e) => e.name == json['section'],
        orElse: () => RecommendationSection.madeForYou,
      ),
    );
  }

  @override
  String toString() =>
      'Recommendation(${song.title} by ${song.artist}, score: ${score.toStringAsFixed(2)}, reason: ${reason.name})';
}

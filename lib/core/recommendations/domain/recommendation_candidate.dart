import 'package:melo/shared/models/song.dart';
import 'recommendation_reason.dart';

/// An intermediate candidate song evaluated during the recommendation pipeline.
class RecommendationCandidate {
  final Song song;
  final String source; // 'favorites', 'history', 'playlist', 'trending', 'genre', 'artist', 'catalog'
  final RecommendationReason defaultReason;
  final Map<String, dynamic> metadata;
  double score;

  RecommendationCandidate({
    required this.song,
    required this.source,
    required this.defaultReason,
    this.metadata = const {},
    this.score = 0.0,
  });

  RecommendationCandidate copyWith({
    Song? song,
    String? source,
    RecommendationReason? defaultReason,
    Map<String, dynamic>? metadata,
    double? score,
  }) {
    return RecommendationCandidate(
      song: song ?? this.song,
      source: source ?? this.source,
      defaultReason: defaultReason ?? this.defaultReason,
      metadata: metadata ?? this.metadata,
      score: score ?? this.score,
    );
  }
}

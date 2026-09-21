import 'package:melo/shared/models/song.dart';

/// Execution context passed to the recommendation engine to parameterize candidate generation.
class RecommendationContext {
  final bool isOffline;
  final Song? currentSong;
  final String discoveryLevel; // 'familiar', 'balanced', 'explore'
  final int limit;
  final int? seed;
  final bool allowHistory;
  final bool allowPersonalization;

  const RecommendationContext({
    this.isOffline = false,
    this.currentSong,
    this.discoveryLevel = 'balanced',
    this.limit = 20,
    this.seed,
    this.allowHistory = true,
    this.allowPersonalization = true,
  });

  RecommendationContext copyWith({
    bool? isOffline,
    Song? currentSong,
    String? discoveryLevel,
    int? limit,
    int? seed,
    bool? allowHistory,
    bool? allowPersonalization,
  }) {
    return RecommendationContext(
      isOffline: isOffline ?? this.isOffline,
      currentSong: currentSong ?? this.currentSong,
      discoveryLevel: discoveryLevel ?? this.discoveryLevel,
      limit: limit ?? this.limit,
      seed: seed ?? this.seed,
      allowHistory: allowHistory ?? this.allowHistory,
      allowPersonalization: allowPersonalization ?? this.allowPersonalization,
    );
  }
}

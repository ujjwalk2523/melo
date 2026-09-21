/// Centralized, configurable weights, thresholds, and limits for the recommendation engine.
///
/// Ensures no magic numbers or arbitrary constants are hardcoded across feature implementations.
class RecommendationWeights {
  // Interaction signal weights
  final double favoriteWeight;
  final double completedPlayWeight;
  final double repeatPlayWeight;
  final double playlistAddWeight;
  final double partialPlayWeight;
  final double skipPenaltyWeight;
  final double searchClickWeight;
  final double downloadWeight;

  // Completion ratio thresholds
  final double earlySkipThreshold; // < 0.25
  final double partialListenThreshold; // 0.25 - 0.60
  final double strongListenThreshold; // 0.60 - 0.85
  final double completedThreshold; // > 0.85

  // Similarity weights (sum to 1.0)
  final double sameGenreWeight;
  final double sameMoodWeight;
  final double sameArtistWeight;
  final double tagsWeight;
  final double sameAlbumWeight;
  final double otherMetadataWeight;

  // Candidate scoring feature weights (sum to 1.0)
  final double userAffinityWeight;
  final double similarityWeight;
  final double recencyWeight;
  final double completionWeight;
  final double popularityWeight;
  final double discoveryWeight;
  final double freshnessWeight;

  // Penalty weights
  final double recentPlayPenalty;
  final double skipPenalty;
  final double hideArtistPenalty;
  final double hideGenrePenalty;
  final double lessLikeThisPenalty;

  // Diversity limits
  final int maxConsecutiveArtist;
  final int maxTracksPerArtist;
  final int maxTracksPerAlbum;

  // Exploration ratio: (familiar, discovery)
  final double familiarRatio;
  final double discoveryRatio;

  const RecommendationWeights({
    this.favoriteWeight = 5.0,
    this.completedPlayWeight = 3.0,
    this.repeatPlayWeight = 2.0,
    this.playlistAddWeight = 4.0,
    this.partialPlayWeight = 1.0,
    this.skipPenaltyWeight = -2.0,
    this.searchClickWeight = 1.0,
    this.downloadWeight = 3.0,
    this.earlySkipThreshold = 0.25,
    this.partialListenThreshold = 0.60,
    this.strongListenThreshold = 0.85,
    this.completedThreshold = 0.85,
    this.sameGenreWeight = 0.30,
    this.sameMoodWeight = 0.20,
    this.sameArtistWeight = 0.20,
    this.tagsWeight = 0.15,
    this.sameAlbumWeight = 0.10,
    this.otherMetadataWeight = 0.05,
    this.userAffinityWeight = 0.30,
    this.similarityWeight = 0.25,
    this.recencyWeight = 0.10,
    this.completionWeight = 0.10,
    this.popularityWeight = 0.10,
    this.discoveryWeight = 0.10,
    this.freshnessWeight = 0.05,
    this.recentPlayPenalty = 0.25,
    this.skipPenalty = 0.35,
    this.hideArtistPenalty = 0.90,
    this.hideGenrePenalty = 0.80,
    this.lessLikeThisPenalty = 0.40,
    this.maxConsecutiveArtist = 2,
    this.maxTracksPerArtist = 3,
    this.maxTracksPerAlbum = 2,
    this.familiarRatio = 0.70,
    this.discoveryRatio = 0.30,
  });

  /// Factory constructor configured for specific discovery levels.
  factory RecommendationWeights.forDiscoveryLevel(String level) {
    switch (level.toLowerCase()) {
      case 'familiar':
        return const RecommendationWeights(
          familiarRatio: 0.85,
          discoveryRatio: 0.15,
          userAffinityWeight: 0.40,
          similarityWeight: 0.30,
          discoveryWeight: 0.05,
        );
      case 'explore':
        return const RecommendationWeights(
          familiarRatio: 0.50,
          discoveryRatio: 0.50,
          userAffinityWeight: 0.20,
          similarityWeight: 0.20,
          discoveryWeight: 0.25,
        );
      case 'balanced':
      default:
        return const RecommendationWeights(
          familiarRatio: 0.70,
          discoveryRatio: 0.30,
        );
    }
  }

  RecommendationWeights copyWith({
    double? favoriteWeight,
    double? completedPlayWeight,
    double? repeatPlayWeight,
    double? playlistAddWeight,
    double? partialPlayWeight,
    double? skipPenaltyWeight,
    double? searchClickWeight,
    double? downloadWeight,
    double? earlySkipThreshold,
    double? partialListenThreshold,
    double? strongListenThreshold,
    double? completedThreshold,
    double? sameGenreWeight,
    double? sameMoodWeight,
    double? sameArtistWeight,
    double? tagsWeight,
    double? sameAlbumWeight,
    double? otherMetadataWeight,
    double? userAffinityWeight,
    double? similarityWeight,
    double? recencyWeight,
    double? completionWeight,
    double? popularityWeight,
    double? discoveryWeight,
    double? freshnessWeight,
    double? recentPlayPenalty,
    double? skipPenalty,
    double? hideArtistPenalty,
    double? hideGenrePenalty,
    double? lessLikeThisPenalty,
    int? maxConsecutiveArtist,
    int? maxTracksPerArtist,
    int? maxTracksPerAlbum,
    double? familiarRatio,
    double? discoveryRatio,
  }) {
    return RecommendationWeights(
      favoriteWeight: favoriteWeight ?? this.favoriteWeight,
      completedPlayWeight: completedPlayWeight ?? this.completedPlayWeight,
      repeatPlayWeight: repeatPlayWeight ?? this.repeatPlayWeight,
      playlistAddWeight: playlistAddWeight ?? this.playlistAddWeight,
      partialPlayWeight: partialPlayWeight ?? this.partialPlayWeight,
      skipPenaltyWeight: skipPenaltyWeight ?? this.skipPenaltyWeight,
      searchClickWeight: searchClickWeight ?? this.searchClickWeight,
      downloadWeight: downloadWeight ?? this.downloadWeight,
      earlySkipThreshold: earlySkipThreshold ?? this.earlySkipThreshold,
      partialListenThreshold:
          partialListenThreshold ?? this.partialListenThreshold,
      strongListenThreshold:
          strongListenThreshold ?? this.strongListenThreshold,
      completedThreshold: completedThreshold ?? this.completedThreshold,
      sameGenreWeight: sameGenreWeight ?? this.sameGenreWeight,
      sameMoodWeight: sameMoodWeight ?? this.sameMoodWeight,
      sameArtistWeight: sameArtistWeight ?? this.sameArtistWeight,
      tagsWeight: tagsWeight ?? this.tagsWeight,
      sameAlbumWeight: sameAlbumWeight ?? this.sameAlbumWeight,
      otherMetadataWeight: otherMetadataWeight ?? this.otherMetadataWeight,
      userAffinityWeight: userAffinityWeight ?? this.userAffinityWeight,
      similarityWeight: similarityWeight ?? this.similarityWeight,
      recencyWeight: recencyWeight ?? this.recencyWeight,
      completionWeight: completionWeight ?? this.completionWeight,
      popularityWeight: popularityWeight ?? this.popularityWeight,
      discoveryWeight: discoveryWeight ?? this.discoveryWeight,
      freshnessWeight: freshnessWeight ?? this.freshnessWeight,
      recentPlayPenalty: recentPlayPenalty ?? this.recentPlayPenalty,
      skipPenalty: skipPenalty ?? this.skipPenalty,
      hideArtistPenalty: hideArtistPenalty ?? this.hideArtistPenalty,
      hideGenrePenalty: hideGenrePenalty ?? this.hideGenrePenalty,
      lessLikeThisPenalty: lessLikeThisPenalty ?? this.lessLikeThisPenalty,
      maxConsecutiveArtist: maxConsecutiveArtist ?? this.maxConsecutiveArtist,
      maxTracksPerArtist: maxTracksPerArtist ?? this.maxTracksPerArtist,
      maxTracksPerAlbum: maxTracksPerAlbum ?? this.maxTracksPerAlbum,
      familiarRatio: familiarRatio ?? this.familiarRatio,
      discoveryRatio: discoveryRatio ?? this.discoveryRatio,
    );
  }
}

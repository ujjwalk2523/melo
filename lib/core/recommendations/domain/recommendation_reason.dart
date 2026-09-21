/// Deterministic, explainable reasons why a song was selected for recommendation.
enum RecommendationReason {
  recentlyLiked,
  similarToFavorite,
  frequentArtist,
  frequentGenre,
  playlistMatch,
  recentlyPlayed,
  continueListening,
  discoverNewArtist,
  discoverNewGenre,
  trending,
  freshPick,
  offlineAvailable,
  moodMatch,
  albumAffinity,
}

/// Helper extension providing human-friendly template titles and keys.
extension RecommendationReasonX on RecommendationReason {
  String get displayName {
    switch (this) {
      case RecommendationReason.recentlyLiked:
        return 'Because You Liked';
      case RecommendationReason.similarToFavorite:
        return 'Similar to Your Favorites';
      case RecommendationReason.frequentArtist:
        return 'From Your Top Artists';
      case RecommendationReason.frequentGenre:
        return 'Because You Listen to';
      case RecommendationReason.playlistMatch:
        return 'Based on Your Playlists';
      case RecommendationReason.recentlyPlayed:
        return 'Based on Recent Rotation';
      case RecommendationReason.continueListening:
        return 'Continue Listening';
      case RecommendationReason.discoverNewArtist:
        return 'Discover New Artists';
      case RecommendationReason.discoverNewGenre:
        return 'Explore New Genres';
      case RecommendationReason.trending:
        return 'Trending For You';
      case RecommendationReason.freshPick:
        return 'Fresh For You';
      case RecommendationReason.offlineAvailable:
        return 'Available Offline';
      case RecommendationReason.moodMatch:
        return 'Matching Your Vibe';
      case RecommendationReason.albumAffinity:
        return 'From Albums You Love';
    }
  }
}

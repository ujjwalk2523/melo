import 'package:melo/core/recommendations/domain/recommendation_candidate.dart';
import 'package:melo/core/recommendations/domain/recommendation_reason.dart';
import 'package:melo/core/recommendations/domain/taste_profile.dart';
import 'package:melo/shared/models/song.dart';

/// Produces deterministic, data-grounded explanations explaining why a track was recommended.
class RecommendationExplainer {
  const RecommendationExplainer();

  /// Generates a human-friendly explanation sentence for a candidate song.
  String explain({
    required RecommendationCandidate candidate,
    required TasteProfile tasteProfile,
    required List<Song> favorites,
    Song? anchorSong,
  }) {
    final song = candidate.song;

    switch (candidate.defaultReason) {
      case RecommendationReason.similarToFavorite:
        if (favorites.isNotEmpty) {
          final topFav = favorites.first;
          return 'Because you liked "${topFav.title}"';
        }
        return 'Similar to your top bookmarked tracks';

      case RecommendationReason.frequentArtist:
        return 'Because you often listen to ${song.artist}';

      case RecommendationReason.frequentGenre:
        if (song.genre != null && song.genre!.isNotEmpty) {
          return 'Because you listen to ${song.genre}';
        }
        return 'Aligned with your favorite musical styles';

      case RecommendationReason.playlistMatch:
        return 'More like the tracks in your custom playlists';

      case RecommendationReason.continueListening:
        return 'Pick up where you left off';

      case RecommendationReason.recentlyPlayed:
        return 'Based on your recent listening rotation';

      case RecommendationReason.discoverNewArtist:
        return 'Discover an emerging artist in ${song.genre ?? "music"}';

      case RecommendationReason.discoverNewGenre:
        return 'Explore fresh sounds beyond your usual rotation';

      case RecommendationReason.offlineAvailable:
        return 'Available offline for zero-network listening';

      case RecommendationReason.albumAffinity:
        return 'From an album you have had on repeat';

      case RecommendationReason.moodMatch:
        return 'Resonating with your current acoustic vibe';

      case RecommendationReason.trending:
        return 'Trending across the Melo community';

      case RecommendationReason.freshPick:
      default:
        if (anchorSong != null) {
          return 'More like "${anchorSong.title}"';
        }
        return 'Curated discovery for your sonic radar';
    }
  }
}

import 'dart:math' as math;

import 'package:melo/core/recommendations/domain/recommendation_candidate.dart';
import 'package:melo/core/recommendations/domain/recommendation_context.dart';
import 'package:melo/core/recommendations/domain/recommendation_reason.dart';
import 'package:melo/core/recommendations/domain/taste_profile.dart';
import 'package:melo/core/recommendations/utils/similarity.dart';
import 'package:melo/shared/models/song.dart';

/// Generates diverse candidate pools from 10 distinct recommendation sources.
class CandidateGenerator {
  final SongSimilarityCalculator similarityCalculator;

  const CandidateGenerator({
    this.similarityCalculator = const SongSimilarityCalculator(),
  });

  /// Generates a deduplicated list of [RecommendationCandidate] instances across all sources.
  List<RecommendationCandidate> generateCandidates({
    required List<Song> catalog,
    required List<Song> favorites,
    required List<Song> history,
    required List<List<Song>> playlistSongGroups,
    required List<Song> downloads,
    required TasteProfile tasteProfile,
    required RecommendationContext context,
  }) {
    if (context.isOffline) {
      return _generateOfflineCandidates(downloads, favorites, history);
    }

    if (tasteProfile.isColdStart) {
      return _generateColdStartCandidates(catalog, context);
    }

    final candidateMap = <String, RecommendationCandidate>{};

    void addCandidate(
      Song song,
      String source,
      RecommendationReason reason, {
      double baseScore = 0.5,
    }) {
      if (!candidateMap.containsKey(song.id)) {
        candidateMap[song.id] = RecommendationCandidate(
          song: song,
          source: source,
          defaultReason: reason,
          score: baseScore,
        );
      }
    }

    // Source 1: Favorite Similarity
    for (final song in catalog) {
      for (final fav in favorites) {
        if (song.id == fav.id) continue;
        final sim = similarityCalculator.calculateSimilarity(song, fav);
        if (sim >= 0.50) {
          addCandidate(
            song,
            'favorite_similarity',
            RecommendationReason.similarToFavorite,
            baseScore: 0.60 + (sim * 0.35),
          );
        }
      }
    }

    // Source 2: Frequent / Top Artist
    for (final song in catalog) {
      final affinity = tasteProfile.topArtists[song.artist] ?? 0.0;
      if (affinity > 0.3) {
        addCandidate(
          song,
          'artist_affinity',
          RecommendationReason.frequentArtist,
          baseScore: 0.55 + (affinity * 0.35),
        );
      }
    }

    // Source 3: Frequent / Top Genre
    for (final song in catalog) {
      final genre = song.genre?.trim();
      if (genre != null && genre.isNotEmpty) {
        final affinity = tasteProfile.topGenres[genre] ?? 0.0;
        if (affinity > 0.25) {
          addCandidate(
            song,
            'genre_affinity',
            RecommendationReason.frequentGenre,
            baseScore: 0.50 + (affinity * 0.35),
          );
        }
      }
    }

    // Source 4: Playlist Similarity
    for (final group in playlistSongGroups) {
      for (final pSong in group) {
        for (final song in catalog) {
          if (song.id == pSong.id) continue;
          final sim = similarityCalculator.calculateSimilarity(song, pSong);
          if (sim >= 0.60) {
            addCandidate(
              song,
              'playlist_similarity',
              RecommendationReason.playlistMatch,
              baseScore: 0.55 + (sim * 0.30),
            );
          }
        }
      }
    }

    // Source 5: Recent Listening / Continue Listening
    for (int i = 0; i < math.min(history.length, 5); i++) {
      final song = history[i];
      addCandidate(
        song,
        'recent_history',
        RecommendationReason.continueListening,
        baseScore: 0.70 - (i * 0.05),
      );
    }

    // Source 6: Trending / Popular Catalog
    for (int i = 0; i < math.min(catalog.length, 10); i++) {
      final song = catalog[i];
      addCandidate(
        song,
        'trending',
        RecommendationReason.trending,
        baseScore: 0.50,
      );
    }

    // Source 7: New Artists (Discovery)
    for (final song in catalog) {
      final isNewArtist = !tasteProfile.topArtists.containsKey(song.artist);
      if (isNewArtist &&
          song.genre != null &&
          tasteProfile.topGenres.containsKey(song.genre)) {
        addCandidate(
          song,
          'new_artists',
          RecommendationReason.discoverNewArtist,
          baseScore: 0.60,
        );
      }
    }

    // Source 8: New Genres (Exploration)
    for (final song in catalog) {
      final genre = song.genre?.trim();
      if (genre != null &&
          genre.isNotEmpty &&
          !tasteProfile.topGenres.containsKey(genre)) {
        addCandidate(
          song,
          'new_genres',
          RecommendationReason.discoverNewGenre,
          baseScore: 0.45,
        );
      }
    }

    // Source 9: Album Affinity
    for (final song in catalog) {
      final albumAffinity = tasteProfile.topAlbums[song.album] ?? 0.0;
      if (albumAffinity > 0.4) {
        addCandidate(
          song,
          'album_affinity',
          RecommendationReason.albumAffinity,
          baseScore: 0.60 + (albumAffinity * 0.30),
        );
      }
    }

    // Source 10: Provider Catalog Exploration / Fresh Picks
    for (final song in catalog) {
      if (!candidateMap.containsKey(song.id)) {
        addCandidate(
          song,
          'catalog_exploration',
          RecommendationReason.freshPick,
          baseScore: 0.40,
        );
      }
    }

    return candidateMap.values.toList();
  }

  List<RecommendationCandidate> _generateOfflineCandidates(
    List<Song> downloads,
    List<Song> favorites,
    List<Song> history,
  ) {
    final candidateMap = <String, RecommendationCandidate>{};
    for (final song in downloads) {
      candidateMap[song.id] = RecommendationCandidate(
        song: song,
        source: 'downloads',
        defaultReason: RecommendationReason.offlineAvailable,
        score: 0.90,
      );
    }
    return candidateMap.values.toList();
  }

  List<RecommendationCandidate> _generateColdStartCandidates(
    List<Song> catalog,
    RecommendationContext context,
  ) {
    final candidates = <RecommendationCandidate>[];
    final random = context.seed != null
        ? math.Random(context.seed!)
        : math.Random(42);

    final shuffled = List<Song>.from(catalog)..shuffle(random);
    for (int i = 0; i < shuffled.length; i++) {
      final song = shuffled[i];
      candidates.add(
        RecommendationCandidate(
          song: song,
          source: 'cold_start_curated',
          defaultReason: i < 5
              ? RecommendationReason.trending
              : RecommendationReason.freshPick,
          score: 0.50 - (i * 0.01),
        ),
      );
    }
    return candidates;
  }
}

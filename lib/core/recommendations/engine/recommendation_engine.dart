import 'package:melo/core/recommendations/data/recommendation_data_source.dart';
import 'package:melo/core/recommendations/domain/recommendation.dart';
import 'package:melo/core/recommendations/domain/recommendation_context.dart';
import 'package:melo/core/recommendations/domain/recommendation_feedback.dart';
import 'package:melo/core/recommendations/domain/recommendation_reason.dart';
import 'package:melo/core/recommendations/domain/taste_profile.dart';
import 'package:melo/core/recommendations/engine/candidate_generator.dart';
import 'package:melo/core/recommendations/engine/candidate_scorer.dart';
import 'package:melo/core/recommendations/engine/diversity_filter.dart';
import 'package:melo/core/recommendations/engine/feature_extractor.dart';
import 'package:melo/core/recommendations/engine/recommendation_explainer.dart';
import 'package:melo/core/recommendations/utils/recommendation_weights.dart';
import 'package:melo/core/recommendations/utils/similarity.dart';
import 'package:melo/shared/models/song.dart';

/// Primary orchestrator for personalized music recommendations, taste profiling, and feedback.
class RecommendationEngine {
  final RecommendationDataSource dataSource;
  final RecommendationWeights weights;
  final FeatureExtractor featureExtractor;
  final CandidateGenerator candidateGenerator;
  final CandidateScorer candidateScorer;
  final DiversityFilter diversityFilter;
  final RecommendationExplainer explainer;
  final SongSimilarityCalculator similarityCalculator;

  // In-memory cache
  Map<RecommendationSection, List<Recommendation>>? _cachedSections;
  TasteProfile? _cachedTasteProfile;

  RecommendationEngine({
    required this.dataSource,
    RecommendationWeights? weights,
    FeatureExtractor? featureExtractor,
    CandidateGenerator? candidateGenerator,
    CandidateScorer? candidateScorer,
    DiversityFilter? diversityFilter,
    RecommendationExplainer? explainer,
    SongSimilarityCalculator? similarityCalculator,
  }) : weights = weights ?? const RecommendationWeights(),
       similarityCalculator =
           similarityCalculator ?? const SongSimilarityCalculator(),
       featureExtractor =
           featureExtractor ??
           FeatureExtractor(weights: weights ?? const RecommendationWeights()),
       candidateGenerator =
           candidateGenerator ??
           CandidateGenerator(
             similarityCalculator:
                 similarityCalculator ?? const SongSimilarityCalculator(),
           ),
       candidateScorer =
           candidateScorer ??
           CandidateScorer(
             weights: weights ?? const RecommendationWeights(),
             similarityCalculator:
                 similarityCalculator ?? const SongSimilarityCalculator(),
           ),
       diversityFilter =
           diversityFilter ??
           DiversityFilter(weights: weights ?? const RecommendationWeights()),
       explainer = explainer ?? const RecommendationExplainer();

  /// Invalidates in-memory recommendation caches when user data updates.
  void invalidateCache() {
    _cachedSections = null;
    _cachedTasteProfile = null;
  }

  /// Calculates or returns cached user [TasteProfile].
  Future<TasteProfile> getTasteProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedTasteProfile != null) {
      return _cachedTasteProfile!;
    }

    final prefs = dataSource.getPreferences();
    final allowHistory = prefs.offlineOnly
        ? false
        : true; // user preference respect

    final favorites = await dataSource.getFavorites();
    final history = allowHistory
        ? await dataSource.getListeningHistory()
        : <Song>[];
    final playlists = await dataSource.getPlaylists();
    final playlistSongGroups = <List<Song>>[];
    for (final p in playlists) {
      playlistSongGroups.add(await dataSource.getPlaylistSongs(p.id));
    }
    final downloads = await dataSource.getDownloadedSongs();

    final profile = featureExtractor.extractTasteProfile(
      favorites: favorites,
      history: history,
      playlistSongGroups: playlistSongGroups,
      downloads: downloads,
    );

    _cachedTasteProfile = profile;
    return profile;
  }

  /// Returns organized recommendation sections mapped by [RecommendationSection].
  Future<Map<RecommendationSection, List<Recommendation>>> getSections({
    RecommendationContext? context,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedSections != null) {
      return _cachedSections!;
    }

    final effectiveContext = context ?? const RecommendationContext();
    final tasteProfile = await getTasteProfile(forceRefresh: forceRefresh);
    final catalog = await dataSource.getCatalogSongs();
    final favorites = await dataSource.getFavorites();
    final history = effectiveContext.allowHistory
        ? await dataSource.getListeningHistory()
        : <Song>[];
    final playlists = await dataSource.getPlaylists();
    final playlistSongGroups = <List<Song>>[];
    for (final p in playlists) {
      playlistSongGroups.add(await dataSource.getPlaylistSongs(p.id));
    }
    final downloads = await dataSource.getDownloadedSongs();
    final feedback = await dataSource.getFeedback();

    // 1. Candidate Generation
    final rawCandidates = candidateGenerator.generateCandidates(
      catalog: catalog,
      favorites: favorites,
      history: history,
      playlistSongGroups: playlistSongGroups,
      downloads: downloads,
      tasteProfile: tasteProfile,
      context: effectiveContext,
    );

    // 2. Candidate Scoring
    final scoredCandidates = candidateScorer.scoreCandidates(
      candidates: rawCandidates,
      tasteProfile: tasteProfile,
      favorites: favorites,
      history: history,
      downloads: downloads,
      feedback: feedback,
      anchorSong: effectiveContext.currentSong,
    );

    // 3. Diversity Filtering
    final diverseCandidates = diversityFilter.applyDiversity(
      candidates: scoredCandidates,
      limit: effectiveContext.limit * 3,
    );

    // 4. Section Partitioning
    final sections = <RecommendationSection, List<Recommendation>>{};

    void addSection(RecommendationSection section, List<Recommendation> recs) {
      if (recs.isNotEmpty) {
        sections[section] = recs;
      }
    }

    // Made For You (General Top Scored)
    final madeForYou = diverseCandidates.take(10).map((c) {
      return Recommendation(
        song: c.song,
        score: c.score,
        reason: c.defaultReason,
        explanation: explainer.explain(
          candidate: c,
          tasteProfile: tasteProfile,
          favorites: favorites,
        ),
        section: RecommendationSection.madeForYou,
      );
    }).toList();
    addSection(RecommendationSection.madeForYou, madeForYou);

    // Because You Liked...
    if (favorites.isNotEmpty) {
      final becauseYouLiked = diverseCandidates
          .where(
            (c) => c.defaultReason == RecommendationReason.similarToFavorite,
          )
          .take(8)
          .map((c) {
            return Recommendation(
              song: c.song,
              score: c.score,
              reason: RecommendationReason.similarToFavorite,
              explanation: explainer.explain(
                candidate: c,
                tasteProfile: tasteProfile,
                favorites: favorites,
              ),
              section: RecommendationSection.becauseYouLiked,
            );
          })
          .toList();
      addSection(RecommendationSection.becauseYouLiked, becauseYouLiked);
    }

    // Favorite Artists
    final favoriteArtists = diverseCandidates
        .where((c) => c.defaultReason == RecommendationReason.frequentArtist)
        .take(8)
        .map((c) {
          return Recommendation(
            song: c.song,
            score: c.score,
            reason: RecommendationReason.frequentArtist,
            explanation: explainer.explain(
              candidate: c,
              tasteProfile: tasteProfile,
              favorites: favorites,
            ),
            section: RecommendationSection.favoriteArtists,
          );
        })
        .toList();
    addSection(RecommendationSection.favoriteArtists, favoriteArtists);

    // Discover New Artists
    final discover = diverseCandidates
        .where(
          (c) =>
              c.defaultReason == RecommendationReason.discoverNewArtist ||
              c.defaultReason == RecommendationReason.discoverNewGenre,
        )
        .take(8)
        .map((c) {
          return Recommendation(
            song: c.song,
            score: c.score,
            reason: c.defaultReason,
            explanation: explainer.explain(
              candidate: c,
              tasteProfile: tasteProfile,
              favorites: favorites,
            ),
            section: RecommendationSection.discoverNewArtists,
          );
        })
        .toList();
    addSection(RecommendationSection.discoverNewArtists, discover);

    // Offline Picks (if downloads exist)
    if (downloads.isNotEmpty) {
      final offlinePicks = downloads.take(8).map((s) {
        return Recommendation(
          song: s,
          score: 0.95,
          reason: RecommendationReason.offlineAvailable,
          explanation: 'Ready for offline listening',
          section: RecommendationSection.offlinePicks,
        );
      }).toList();
      addSection(RecommendationSection.offlinePicks, offlinePicks);
    }

    _cachedSections = sections;
    return sections;
  }

  /// Direct helper returning flat top recommendations ("Made For You").
  Future<List<Recommendation>> getForYou({int limit = 20}) async {
    final sections = await getSections(
      context: RecommendationContext(limit: limit),
    );
    return sections[RecommendationSection.madeForYou] ?? const [];
  }

  /// Provider-neutral song similarity search for "More Like This" player action.
  Future<List<Song>> getSimilarSongs(Song song, {int limit = 10}) async {
    final catalog = await dataSource.getCatalogSongs();
    final scored = <Song, double>{};

    for (final other in catalog) {
      if (other.id == song.id) continue;
      final sim = similarityCalculator.calculateSimilarity(song, other);
      if (sim > 0.1) {
        scored[other] = sim;
      }
    }

    final sorted = scored.keys.toList()
      ..sort((a, b) => scored[b]!.compareTo(scored[a]!));
    return sorted.take(limit).toList();
  }

  /// Queries pure discovery recommendations.
  Future<List<Recommendation>> getDiscoverRecommendations({
    int limit = 20,
  }) async {
    final sections = await getSections(
      context: RecommendationContext(discoveryLevel: 'explore', limit: limit),
    );
    return sections[RecommendationSection.discoverNewArtists] ??
        sections[RecommendationSection.madeForYou] ??
        const [];
  }

  /// Queries trending recommendations weighted by taste profile.
  Future<List<Recommendation>> getTrendingForYou({int limit = 20}) async {
    final sections = await getSections(
      context: RecommendationContext(limit: limit),
    );
    return sections[RecommendationSection.trendingForYou] ??
        sections[RecommendationSection.madeForYou] ??
        const [];
  }

  /// Queries offline recommendations from local disk downloads.
  Future<List<Recommendation>> getOfflineRecommendations({
    int limit = 20,
  }) async {
    final sections = await getSections(
      context: RecommendationContext(isOffline: true, limit: limit),
      forceRefresh: true,
    );
    return sections[RecommendationSection.offlinePicks] ?? const [];
  }

  /// Records user feedback and purges in-memory caches.
  Future<void> recordFeedback(RecommendationFeedback feedback) async {
    await dataSource.saveFeedback(feedback);
    invalidateCache();
  }

  /// Resets recommendation taste profile, feedback, and cached recommendations.
  Future<void> resetPersonalization() async {
    await dataSource.clearFeedback();
    invalidateCache();
  }

  /// Manual refresh triggering cache invalidation.
  Future<void> refresh() async {
    invalidateCache();
    await getSections(forceRefresh: true);
  }
}

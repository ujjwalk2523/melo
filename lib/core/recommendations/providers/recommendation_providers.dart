import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melo/core/database/database_providers.dart';
import 'package:melo/core/recommendations/data/local_recommendation_data_source.dart';
import 'package:melo/core/recommendations/data/recommendation_data_source.dart';
import 'package:melo/core/recommendations/domain/recommendation.dart';
import 'package:melo/core/recommendations/domain/recommendation_feedback.dart';
import 'package:melo/core/recommendations/domain/taste_profile.dart';
import 'package:melo/core/recommendations/engine/recommendation_engine.dart';
import 'package:melo/core/recommendations/utils/recommendation_weights.dart';
import 'package:melo/features/profile/data/user_preferences_repository.dart';

enum RecommendationStatus {
  idle,
  loading,
  ready,
  refreshing,
  empty,
  error,
}

class RecommendationState {
  final RecommendationStatus status;
  final Map<RecommendationSection, List<Recommendation>> sections;
  final TasteProfile? tasteProfile;
  final bool isColdStart;
  final DateTime? lastUpdated;
  final String? errorMessage;

  const RecommendationState({
    this.status = RecommendationStatus.idle,
    this.sections = const {},
    this.tasteProfile,
    this.isColdStart = true,
    this.lastUpdated,
    this.errorMessage,
  });

  RecommendationState copyWith({
    RecommendationStatus? status,
    Map<RecommendationSection, List<Recommendation>>? sections,
    TasteProfile? tasteProfile,
    bool? isColdStart,
    DateTime? lastUpdated,
    String? errorMessage,
  }) {
    return RecommendationState(
      status: status ?? this.status,
      sections: sections ?? this.sections,
      tasteProfile: tasteProfile ?? this.tasteProfile,
      isColdStart: isColdStart ?? this.isColdStart,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: errorMessage,
    );
  }
}

/// Central weights provider.
final recommendationWeightsProvider = Provider<RecommendationWeights>((ref) {
  final prefsRepo = ref.watch(userPreferencesRepositoryProvider);
  final prefs = prefsRepo?.getPreferences() ?? const UserPreferences();
  return RecommendationWeights.forDiscoveryLevel(prefs.offlineOnly ? 'familiar' : prefs.discoveryLevel);
});

/// Recommendation data source provider.
final recommendationDataSourceProvider = Provider<RecommendationDataSource>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final prefsRepo = ref.watch(userPreferencesRepositoryProvider);
  return LocalRecommendationDataSource(db: db, preferencesRepo: prefsRepo);
});

/// Recommendation engine instance provider.
final recommendationEngineProvider = Provider<RecommendationEngine>((ref) {
  final dataSource = ref.watch(recommendationDataSourceProvider);
  final weights = ref.watch(recommendationWeightsProvider);
  return RecommendationEngine(
    dataSource: dataSource,
    weights: weights,
  );
});

/// Reactive taste profile stream/future.
final tasteProfileProvider = FutureProvider<TasteProfile>((ref) async {
  final engine = ref.watch(recommendationEngineProvider);
  return engine.getTasteProfile();
});

/// Recommendation state notifier for Home and discovery surfaces.
class RecommendationNotifier extends StateNotifier<RecommendationState> {
  final RecommendationEngine _engine;

  RecommendationNotifier(this._engine) : super(const RecommendationState()) {
    // Only auto-load if not in headless unit test environment
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      loadRecommendations();
    }
  }

  Future<void> loadRecommendations({bool forceRefresh = false}) async {
    if (state.status == RecommendationStatus.loading || state.status == RecommendationStatus.refreshing) {
      return;
    }

    state = state.copyWith(
      status: forceRefresh ? RecommendationStatus.refreshing : RecommendationStatus.loading,
    );

    try {
      final tasteProfile = await _engine.getTasteProfile(forceRefresh: forceRefresh);
      final sections = await _engine.getSections(forceRefresh: forceRefresh);

      state = state.copyWith(
        status: sections.isEmpty ? RecommendationStatus.empty : RecommendationStatus.ready,
        sections: sections,
        tasteProfile: tasteProfile,
        isColdStart: tasteProfile.isColdStart,
        lastUpdated: DateTime.now(),
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: RecommendationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    _engine.invalidateCache();
    await loadRecommendations(forceRefresh: true);
  }

  Future<void> recordFeedback(RecommendationFeedback feedback) async {
    await _engine.recordFeedback(feedback);
    await refresh();
  }

  Future<void> resetPersonalization() async {
    await _engine.resetPersonalization();
    await refresh();
  }
}

final recommendationStateProvider =
    StateNotifierProvider<RecommendationNotifier, RecommendationState>((ref) {
  final engine = ref.watch(recommendationEngineProvider);
  return RecommendationNotifier(engine);
});

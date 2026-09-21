import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/database/database_providers.dart';
import 'package:melo/core/recommendations/data/local_recommendation_data_source.dart';
import 'package:melo/core/recommendations/data/recommendation_data_source.dart';
import 'package:melo/core/recommendations/domain/recommendation_candidate.dart';
import 'package:melo/core/recommendations/domain/recommendation_context.dart';
import 'package:melo/core/recommendations/domain/recommendation_feedback.dart';
import 'package:melo/core/recommendations/domain/recommendation_reason.dart';
import 'package:melo/core/recommendations/domain/taste_profile.dart';
import 'package:melo/core/recommendations/engine/candidate_generator.dart';
import 'package:melo/core/recommendations/engine/candidate_scorer.dart';
import 'package:melo/core/recommendations/engine/diversity_filter.dart';
import 'package:melo/core/recommendations/engine/feature_extractor.dart';
import 'package:melo/core/recommendations/engine/recommendation_engine.dart';
import 'package:melo/core/recommendations/engine/recommendation_explainer.dart';
import 'package:melo/core/recommendations/providers/recommendation_providers.dart';
import 'package:melo/core/recommendations/utils/recommendation_weights.dart';
import 'package:melo/core/recommendations/utils/similarity.dart';
import 'package:melo/features/home/presentation/screens/home_screen.dart';
import 'package:melo/features/player/presentation/screens/full_player_screen.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/features/playlists/domain/playlist_models.dart';
import 'package:melo/features/profile/data/user_preferences_repository.dart';
import 'package:melo/features/profile/presentation/screens/profile_screen.dart';
import 'package:melo/shared/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRecommendationDataSource implements RecommendationDataSource {
  List<Song> catalog = [];
  List<Song> favorites = [];
  List<Song> history = [];
  List<Playlist> playlists = [];
  Map<String, List<Song>> playlistSongs = {};
  List<Song> downloads = [];
  List<RecommendationFeedback> feedback = [];
  UserPreferences preferences = const UserPreferences();

  @override
  Future<List<Song>> getCatalogSongs() async => catalog;

  @override
  Future<List<Song>> getFavorites() async => favorites;

  @override
  Future<List<Song>> getListeningHistory() async => history;

  @override
  Future<List<Playlist>> getPlaylists() async => playlists;

  @override
  Future<List<Song>> getPlaylistSongs(String playlistId) async =>
      playlistSongs[playlistId] ?? [];

  @override
  Future<List<Song>> getDownloadedSongs() async => downloads;

  @override
  Future<List<RecommendationFeedback>> getFeedback() async => feedback;

  @override
  Future<void> saveFeedback(RecommendationFeedback item) async {
    feedback.removeWhere(
      (f) => f.targetId == item.targetId && f.feedbackType == item.feedbackType,
    );
    feedback.add(item);
  }

  @override
  Future<void> clearFeedback() async {
    feedback.clear();
  }

  @override
  UserPreferences getPreferences() => preferences;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const songA = Song(
    id: 's_a',
    title: 'Neon Nights',
    artist: 'Cyber Synth',
    album: 'Retro Future',
    duration: Duration(seconds: 200),
    genre: 'Synthwave',
    streamUrl: 'https://stream.test/s_a.mp3',
    artworkUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
    provider: 'audius',
  );

  const songB = Song(
    id: 's_b',
    title: 'Laser Sunset',
    artist: 'Cyber Synth',
    album: 'Retro Future',
    duration: Duration(seconds: 210),
    genre: 'Synthwave',
    streamUrl: 'https://stream.test/s_b.mp3',
    artworkUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
    provider: 'audius',
  );

  const songC = Song(
    id: 's_c',
    title: 'Midnight Drive',
    artist: 'Outrun 84',
    album: 'Grid Horizon',
    duration: Duration(seconds: 195),
    genre: 'Synthwave',
    streamUrl: 'https://stream.test/s_c.mp3',
    artworkUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
    provider: 'audius',
  );

  const songD = Song(
    id: 's_d',
    title: 'Acoustic Rain',
    artist: 'Folk Whispers',
    album: 'Wooden Cabin',
    duration: Duration(seconds: 150),
    genre: 'Acoustic',
    streamUrl: 'https://stream.test/s_d.mp3',
    artworkUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
    provider: 'jamendo',
  );

  const songE = Song(
    id: 's_e',
    title: 'Deep Techno Pulse',
    artist: 'Sub Zero',
    album: 'Dark Warehouse',
    duration: Duration(seconds: 360),
    genre: 'Techno',
    streamUrl: 'https://stream.test/s_e.mp3',
    artworkUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
    provider: 'jamendo',
  );

  group('Taste Profile & Feature Extraction', () {
    test('Empty interactions produce cold-start taste profile', () {
      const extractor = FeatureExtractor();
      final profile = extractor.extractTasteProfile(
        favorites: [],
        history: [],
        playlistSongGroups: [],
      );

      expect(profile.isColdStart, isTrue);
      expect(profile.topGenres, isEmpty);
      expect(profile.topArtists, isEmpty);
    });

    test(
      'Completed plays, favorites and playlists build strong affinities',
      () {
        const extractor = FeatureExtractor();
        final profile = extractor.extractTasteProfile(
          favorites: [songA],
          history: [songA, songA, songC],
          playlistSongGroups: [
            [songA, songB],
          ],
          downloads: [songA],
        );

        expect(profile.isColdStart, isFalse);
        expect(profile.totalFavorites, equals(1));
        expect(profile.totalPlays, equals(3));
        expect(profile.topArtists.containsKey('Cyber Synth'), isTrue);
        expect(profile.topGenres.containsKey('Synthwave'), isTrue);
        expect(
          profile.topArtists['Cyber Synth']! >
              (profile.topArtists['Outrun 84'] ?? 0.0),
          isTrue,
        );
      },
    );
  });

  group('Song Similarity Calculator', () {
    const similarity = SongSimilarityCalculator();

    test('Identical artist and genre yield high similarity', () {
      final sim = similarity.calculateSimilarity(songA, songB);
      expect(sim, greaterThan(0.6));
    });

    test('Same genre but different artist gives moderate similarity', () {
      final sim = similarity.calculateSimilarity(songA, songC);
      expect(sim, greaterThan(0.2));
      expect(sim, lessThan(0.8));
    });

    test('Completely different genre and artist yields low similarity', () {
      final sim = similarity.calculateSimilarity(songA, songD);
      expect(sim, lessThan(0.3));
    });

    test('Missing genre/album safely falls back without exceptions or NaN', () {
      const bareSong1 = Song(
        id: 'bare_1',
        title: 'Song One',
        artist: 'Artist X',
        album: '',
        artworkUrl: '',
        provider: 'audius',
        duration: Duration(seconds: 180),
        streamUrl: 'https://test/1.mp3',
      );
      const bareSong2 = Song(
        id: 'bare_2',
        title: 'Song Two',
        artist: 'Artist X',
        album: '',
        artworkUrl: '',
        provider: 'audius',
        duration: Duration(seconds: 190),
        streamUrl: 'https://test/2.mp3',
      );

      final sim = similarity.calculateSimilarity(bareSong1, bareSong2);
      expect(sim.isNaN, isFalse);
      expect(sim.isInfinite, isFalse);
      expect(sim, greaterThan(0.2)); // Same artist match
    });
  });

  group('Candidate Generation & Multi-source Pool', () {
    const generator = CandidateGenerator();

    test('CandidateGenerator generates candidates across sources', () {
      final profile = const FeatureExtractor().extractTasteProfile(
        favorites: [songA],
        history: [songA, songC],
        playlistSongGroups: [],
        downloads: [songA],
      );

      final candidates = generator.generateCandidates(
        catalog: [songA, songB, songC, songD, songE],
        favorites: [songA],
        history: [songA, songC],
        playlistSongGroups: [],
        downloads: [songA],
        tasteProfile: profile,
        context: const RecommendationContext(),
      );

      expect(candidates, isNotEmpty);
      final sources = candidates.map((c) => c.source).toSet();
      expect(sources.isNotEmpty, isTrue);
    });

    test('Offline context strictly filters candidates to downloaded songs', () {
      final profile = const FeatureExtractor().extractTasteProfile(
        favorites: [songA],
        history: [songA],
        playlistSongGroups: [],
        downloads: [songA],
      );

      final candidates = generator.generateCandidates(
        catalog: [songA, songB, songC, songD, songE],
        favorites: [songA],
        history: [songA],
        playlistSongGroups: [],
        downloads: [songA],
        tasteProfile: profile,
        context: const RecommendationContext(isOffline: true),
      );

      expect(candidates, isNotEmpty);
      for (final c in candidates) {
        expect(c.song.id, equals(songA.id));
      }
    });

    test('Cold start generates trending and discover candidates', () {
      final emptyProfile = TasteProfile.empty();
      final candidates = generator.generateCandidates(
        catalog: [songA, songB, songC, songD, songE],
        favorites: [],
        history: [],
        playlistSongGroups: [],
        downloads: [],
        tasteProfile: emptyProfile,
        context: const RecommendationContext(),
      );

      expect(candidates, isNotEmpty);
      expect(
        candidates.any(
          (c) =>
              c.defaultReason == RecommendationReason.trending ||
              c.defaultReason == RecommendationReason.discoverNewArtist,
        ),
        isTrue,
      );
    });
  });

  group('Candidate Scoring & Feedback Exclusions', () {
    const scorer = CandidateScorer();

    test('Scores are normalized between 0.0 and 1.0', () {
      final profile = TasteProfile(
        topGenres: {'Synthwave': 0.9},
        topArtists: {'Cyber Synth': 0.95},
        isColdStart: false,
      );

      final candidate = RecommendationCandidate(
        song: songA,
        source: 'artist_affinity',
        defaultReason: RecommendationReason.frequentArtist,
        score: 0.8,
      );

      final scoredList = scorer.scoreCandidates(
        candidates: [candidate],
        tasteProfile: profile,
        favorites: [songA],
        history: [],
        downloads: [],
        feedback: [],
      );

      expect(scoredList, isNotEmpty);
      expect(scoredList.first.score, greaterThanOrEqualTo(0.0));
      expect(scoredList.first.score, lessThanOrEqualTo(1.0));
    });

    test('Hidden song feedback filters out the candidate', () {
      final profile = TasteProfile.empty();
      final candidate = RecommendationCandidate(
        song: songA,
        source: 'trending',
        defaultReason: RecommendationReason.trending,
        score: 0.8,
      );

      final feedback = [
        RecommendationFeedback(
          feedbackType: FeedbackType.hideSong,
          targetId: songA.id,
          targetType: 'song',
        ),
      ];

      final scoredList = scorer.scoreCandidates(
        candidates: [candidate],
        tasteProfile: profile,
        favorites: [],
        history: [],
        downloads: [],
        feedback: feedback,
      );

      expect(scoredList, isEmpty);
    });

    test('Hidden artist feedback filters out all tracks by artist', () {
      final profile = TasteProfile.empty();
      final candidate = RecommendationCandidate(
        song: songA,
        source: 'trending',
        defaultReason: RecommendationReason.trending,
        score: 0.8,
      );

      final feedback = [
        RecommendationFeedback(
          feedbackType: FeedbackType.hideArtist,
          targetId: songA.artist,
          targetType: 'artist',
        ),
      ];

      final scoredList = scorer.scoreCandidates(
        candidates: [candidate],
        tasteProfile: profile,
        favorites: [],
        history: [],
        downloads: [],
        feedback: feedback,
      );

      expect(scoredList, isEmpty);
    });

    test(
      'Repeat penalty dampens score for recently played tracks in history',
      () {
        final profile = TasteProfile(
          topGenres: {'Synthwave': 0.9},
          topArtists: {'Cyber Synth': 0.9},
          isColdStart: false,
        );

        final candidate = RecommendationCandidate(
          song: songB,
          source: 'genre_affinity',
          defaultReason: RecommendationReason.frequentGenre,
          score: 0.8,
        );

        final scoredFresh = scorer
            .scoreCandidates(
              candidates: [candidate],
              tasteProfile: profile,
              favorites: [],
              history: [],
              downloads: [],
              feedback: [],
            )
            .first;

        final scoredRecent = scorer
            .scoreCandidates(
              candidates: [candidate],
              tasteProfile: profile,
              favorites: [],
              history: [songB, songB],
              downloads: [],
              feedback: [],
            )
            .first;

        expect(scoredRecent.score, lessThan(scoredFresh.score));
      },
    );

    test('Hidden genre feedback filters out all tracks matching genre', () {
      final profile = TasteProfile.empty();
      final candidate = RecommendationCandidate(
        song: songA, // Genre: Synthwave
        source: 'trending',
        defaultReason: RecommendationReason.trending,
        score: 0.8,
      );

      final feedback = [
        RecommendationFeedback(
          feedbackType: FeedbackType.hideGenre,
          targetId: 'Synthwave',
          targetType: 'genre',
        ),
      ];

      final scoredList = scorer.scoreCandidates(
        candidates: [candidate],
        tasteProfile: profile,
        favorites: [],
        history: [],
        downloads: [],
        feedback: feedback,
      );

      expect(scoredList, isEmpty);
    });

    test('lessLikeThis feedback strongly penalizes candidate score', () {
      final profile = TasteProfile.empty();
      final candidate = RecommendationCandidate(
        song: songA,
        source: 'trending',
        defaultReason: RecommendationReason.trending,
        score: 0.8,
      );

      final scoredNormal = scorer
          .scoreCandidates(
            candidates: [candidate],
            tasteProfile: profile,
            favorites: [],
            history: [],
            downloads: [],
            feedback: [],
          )
          .first;

      final feedback = [
        RecommendationFeedback(
          feedbackType: FeedbackType.lessLikeThis,
          targetId: songA.id,
          targetType: 'song',
        ),
      ];

      final scoredPenalized = scorer
          .scoreCandidates(
            candidates: [candidate],
            tasteProfile: profile,
            favorites: [],
            history: [],
            downloads: [],
            feedback: feedback,
          )
          .first;

      expect(scoredPenalized.score, lessThan(scoredNormal.score));
    });
  });

  group('Diversity Filtering', () {
    const filter = DiversityFilter();

    test('Applies artist cap (max 3 per artist)', () {
      final sameArtistCandidates = List.generate(
        6,
        (i) => RecommendationCandidate(
          song: Song(
            id: 'same_artist_$i',
            title: 'Track $i',
            artist: 'One Artist',
            album: 'Album $i',
            artworkUrl: '',
            provider: 'audius',
            duration: const Duration(seconds: 180),
            streamUrl: 'https://test/$i.mp3',
          ),
          source: 'artist',
          defaultReason: RecommendationReason.frequentArtist,
          score: 0.9 - (i * 0.05),
        ),
      );

      final filtered = filter.applyDiversity(candidates: sameArtistCandidates);

      final count = filtered.where((r) => r.song.artist == 'One Artist').length;
      expect(count, equals(3));
    });

    test('Applies album cap (max 2 per album)', () {
      final sameAlbumCandidates = List.generate(
        5,
        (i) => RecommendationCandidate(
          song: Song(
            id: 'same_album_$i',
            title: 'Track $i',
            artist: 'Artist $i',
            album: 'Greatest Hits',
            artworkUrl: '',
            provider: 'audius',
            duration: const Duration(seconds: 180),
            streamUrl: 'https://test/$i.mp3',
          ),
          source: 'album',
          defaultReason: RecommendationReason.albumAffinity,
          score: 0.9 - (i * 0.05),
        ),
      );

      final filtered = filter.applyDiversity(candidates: sameAlbumCandidates);

      final count = filtered
          .where((r) => r.song.album == 'Greatest Hits')
          .length;
      expect(count, equals(2));
    });
  });

  group('Deterministic Explanations', () {
    const explainer = RecommendationExplainer();

    test('Generates truthful, data-grounded explanations', () {
      final profile = TasteProfile(
        topGenres: {'Synthwave': 0.9},
        topArtists: {'Cyber Synth': 0.85},
        isColdStart: false,
      );

      final expArtist = explainer.explain(
        candidate: RecommendationCandidate(
          song: songA,
          source: 'artist_affinity',
          defaultReason: RecommendationReason.frequentArtist,
        ),
        tasteProfile: profile,
        favorites: [songA],
      );
      expect(expArtist, contains('Cyber Synth'));

      final expGenre = explainer.explain(
        candidate: RecommendationCandidate(
          song: songC,
          source: 'genre_affinity',
          defaultReason: RecommendationReason.frequentGenre,
        ),
        tasteProfile: profile,
        favorites: [],
      );
      expect(expGenre, contains('Synthwave'));

      final expTrending = explainer.explain(
        candidate: RecommendationCandidate(
          song: songD,
          source: 'trending',
          defaultReason: RecommendationReason.trending,
        ),
        tasteProfile: TasteProfile.empty(),
        favorites: [],
      );
      expect(expTrending, contains('Trending'));
    });
  });

  group('Recommendation Engine Caching & Invalidation', () {
    test(
      'Returns cached recommendations within TTL and refreshes when forced',
      () async {
        final dataSource = FakeRecommendationDataSource();
        dataSource.catalog = [songA, songB, songC, songD, songE];
        dataSource.favorites = [songA];

        final engine = RecommendationEngine(dataSource: dataSource);

        final res1 = await engine.getSections();
        expect(res1, isNotEmpty);

        // Add new song to favorites
        dataSource.favorites.add(songB);

        // Immediate call returns cached
        final res2 = await engine.getSections();
        expect(res2.length, equals(res1.length));

        // Force refresh invalidates cache
        final res3 = await engine.getSections(forceRefresh: true);
        expect(res3, isNotEmpty);
      },
    );

    test(
      'getSimilarSongs returns ranked similar songs to a seed song',
      () async {
        final dataSource = FakeRecommendationDataSource();
        dataSource.catalog = [songA, songB, songC, songD, songE];

        final engine = RecommendationEngine(dataSource: dataSource);
        final similar = await engine.getSimilarSongs(songA, limit: 3);

        expect(similar, isNotEmpty);
        expect(similar.any((s) => s.id == songA.id), isFalse); // Excludes self
        expect(similar.first.id, equals(songB.id)); // Same artist & genre
      },
    );
  });

  group('User Preferences & Settings Integration', () {
    late SharedPreferences prefs;
    late UserPreferencesRepository prefsRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      prefsRepo = UserPreferencesRepository(prefs);
    });

    test('Default recommendation preferences are properly initialized', () {
      final initial = prefsRepo.getPreferences();
      expect(initial.personalizedRecommendations, isTrue);
      expect(initial.useListeningHistoryForRecs, isTrue);
      expect(initial.discoveryLevel, equals('balanced'));
    });

    test('Preferences can be toggled and updated', () async {
      await prefsRepo.setPersonalizedRecommendations(false);
      expect(prefsRepo.getPreferences().personalizedRecommendations, isFalse);

      await prefsRepo.setDiscoveryLevel('explore');
      expect(prefsRepo.getPreferences().discoveryLevel, equals('explore'));

      await prefsRepo.resetPersonalizationPreferences();
      expect(prefsRepo.getPreferences().personalizedRecommendations, isTrue);
      expect(prefsRepo.getPreferences().discoveryLevel, equals('balanced'));
    });
  });

  group('UI & Widget Integration Tests', () {
    late FakeRecommendationDataSource dataSource;
    late SharedPreferences prefs;
    late UserPreferencesRepository prefsRepo;
    late FakeAudioPlayerService fakePlayer;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      prefsRepo = UserPreferencesRepository(prefs);

      dataSource = FakeRecommendationDataSource();
      dataSource.catalog = [songA, songB, songC, songD, songE];
      dataSource.favorites = [songA];
      dataSource.history = [songA, songC];
      fakePlayer = FakeAudioPlayerService();
    });

    tearDown(() {
      fakePlayer.dispose();
    });

    testWidgets('HomeScreen renders recommendation sections', (tester) async {
      final db = AppDatabase.memory();
      final engine = RecommendationEngine(dataSource: dataSource);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            sharedPreferencesProvider.overrideWithValue(prefs),
            userPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
            recommendationDataSourceProvider.overrideWithValue(dataSource),
            recommendationEngineProvider.overrideWithValue(engine),
            recentlyPlayedStreamProvider.overrideWith(
              (ref) => Stream.value([]),
            ),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Home should render greeting header
      expect(find.byType(HomeScreen), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets(
      'FullPlayerScreen displays More Like This button and opens sheet',
      (tester) async {
        final engine = RecommendationEngine(dataSource: dataSource);
        final notifier = PlayerNotifier(
          fakePlayer,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
        );
        await notifier.playSong(songA);

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              userPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
              recommendationDataSourceProvider.overrideWithValue(dataSource),
              recommendationEngineProvider.overrideWithValue(engine),
              playerNotifierProvider.overrideWith((ref) => notifier),
            ],
            child: const MaterialApp(home: FullPlayerScreen()),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Find More Like This button by tooltip
        final moreLikeThisBtn = find.byTooltip('More Like This');
        expect(moreLikeThisBtn, findsOneWidget);

        // Tap it to open modal bottom sheet
        await tester.tap(moreLikeThisBtn);
        await tester.pumpAndSettle();

        // Modal bottom sheet should show header
        expect(find.textContaining('More Like'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );

    testWidgets('ProfileScreen shows Music Intelligence settings and dialogs', (
      tester,
    ) async {
      final db = AppDatabase.memory();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            sharedPreferencesProvider.overrideWithValue(prefs),
            userPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
            recommendationDataSourceProvider.overrideWithValue(dataSource),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Music Intelligence section headers and items
      final musicHeader = find.text('Music Intelligence & Recommendations');
      await tester.scrollUntilVisible(musicHeader, 100.0);
      expect(musicHeader, findsOneWidget);

      final discoveryLevelTile = find.text('Discovery Level');
      await tester.scrollUntilVisible(discoveryLevelTile, 50.0);
      expect(discoveryLevelTile, findsOneWidget);

      // Tap Discovery Level to verify dialog opens
      await tester.tap(discoveryLevelTile);
      await tester.pumpAndSettle();
      expect(find.text('Select Discovery Level'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });

  group('LocalRecommendationDataSource & Drift Feedback Persistence', () {
    test(
      'Saves, retrieves, and clears recommendation feedback in Drift',
      () async {
        final db = AppDatabase.memory();
        final localDataSource = LocalRecommendationDataSource(db: db);

        // Initially empty
        final initial = await localDataSource.getFeedback();
        expect(initial, isEmpty);

        // Save hideSong feedback
        final fb1 = RecommendationFeedback(
          feedbackType: FeedbackType.hideSong,
          targetId: 'track_123',
          targetType: 'song',
        );
        await localDataSource.saveFeedback(fb1);

        // Save hideArtist feedback
        final fb2 = RecommendationFeedback(
          feedbackType: FeedbackType.hideArtist,
          targetId: 'Artist XYZ',
          targetType: 'artist',
        );
        await localDataSource.saveFeedback(fb2);

        final retrieved = await localDataSource.getFeedback();
        expect(retrieved.length, equals(2));
        expect(
          retrieved.any(
            (f) =>
                f.targetId == 'track_123' &&
                f.feedbackType == FeedbackType.hideSong,
          ),
          isTrue,
        );
        expect(
          retrieved.any(
            (f) =>
                f.targetId == 'Artist XYZ' &&
                f.feedbackType == FeedbackType.hideArtist,
          ),
          isTrue,
        );

        // Clear feedback
        await localDataSource.clearFeedback();
        final afterClear = await localDataSource.getFeedback();
        expect(afterClear, isEmpty);

        await db.close();
      },
    );
  });

  group('Domain Models & Serialization', () {
    test('TasteProfile toJson and fromJson roundtrip correctly', () {
      final profile = TasteProfile(
        topArtists: {'Cyber Synth': 0.9},
        topGenres: {'Synthwave': 0.8},
        topAlbums: {'Retro Future': 0.7},
        recentArtists: ['Cyber Synth'],
        recentGenres: ['Synthwave'],
        favoriteProviders: ['audius'],
        totalPlays: 10,
        totalFavorites: 5,
        totalSkips: 1,
        totalDownloads: 2,
        isColdStart: false,
      );

      final json = profile.toJson();
      final revived = TasteProfile.fromJson(json);

      expect(revived.isColdStart, isFalse);
      expect(revived.totalPlays, equals(10));
      expect(revived.totalFavorites, equals(5));
      expect(revived.topArtists['Cyber Synth'], equals(0.9));
      expect(revived.topGenres['Synthwave'], equals(0.8));
    });

    test('RecommendationFeedback toJson and fromJson roundtrip correctly', () {
      final fb = RecommendationFeedback(
        id: 42,
        feedbackType: FeedbackType.hideGenre,
        targetId: 'Techno',
        targetType: 'genre',
        createdAt: DateTime(2026, 9, 21, 20, 0, 0),
      );

      final json = fb.toJson();
      final revived = RecommendationFeedback.fromJson(json);

      expect(revived.id, equals(42));
      expect(revived.feedbackType, equals(FeedbackType.hideGenre));
      expect(revived.targetId, equals('Techno'));
      expect(revived.targetType, equals('genre'));
    });

    test(
      'RecommendationWeights.forDiscoveryLevel configures exploration ratios',
      () {
        final familiarWeights = RecommendationWeights.forDiscoveryLevel(
          'familiar',
        );
        expect(familiarWeights.familiarRatio, equals(0.85));
        expect(familiarWeights.discoveryRatio, equals(0.15));

        final exploreWeights = RecommendationWeights.forDiscoveryLevel(
          'explore',
        );
        expect(exploreWeights.familiarRatio, equals(0.50));
        expect(exploreWeights.discoveryRatio, equals(0.50));
      },
    );
  });
}

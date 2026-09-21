import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/database/database_providers.dart';
import 'package:melo/core/network/api_client.dart';
import 'package:melo/core/recommendations/domain/recommendation.dart';
import 'package:melo/core/recommendations/domain/recommendation_reason.dart';
import 'package:melo/core/recommendations/providers/recommendation_providers.dart';
import 'package:melo/core/sync/sync_engine.dart';
import 'package:melo/core/sync/sync_queue.dart';
import 'package:melo/core/sync/sync_repository.dart';
import 'package:melo/core/utils/app_logger.dart';
import 'package:melo/features/auth/data/auth_repository.dart';
import 'package:melo/features/auth/domain/auth_state.dart';
import 'package:melo/features/auth/domain/auth_user.dart';
import 'package:melo/features/auth/providers/auth_provider.dart';
import 'package:melo/features/home/presentation/screens/home_screen.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/features/profile/data/user_preferences_repository.dart';
import 'package:melo/shared/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 10: AppLogger Sanitization & Categorical Tagging', () {
    test('redacts Bearer tokens, passwords, and api keys from log output', () {
      const sensitiveMessage =
          'User logged in with email: test.user+melo@example.com, password: SuperSecretPassword123, '
          'auth: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.t-IDNpbGlua0qXOmjh, '
          'client_secret: top_secret_key_456';

      final sanitized = AppLogger.sanitize(sensitiveMessage);

      expect(sanitized, isNot(contains('SuperSecretPassword123')));
      expect(
        sanitized,
        isNot(contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9')),
      );
      expect(sanitized, isNot(contains('top_secret_key_456')));
      expect(sanitized, contains('Bearer REDACTED'));
      expect(sanitized, contains('password=REDACTED'));
      expect(sanitized, contains('client_secret=REDACTED'));
      expect(sanitized, contains('t***@example.com'));
    });

    test(
      'supports all standard log levels and categories without exception',
      () {
        expect(
          () => AppLogger.debug('Debug trace', category: LogCategory.player),
          returnsNormally,
        );
        expect(
          () => AppLogger.info('Info notice', category: LogCategory.auth),
          returnsNormally,
        );
        expect(
          () => AppLogger.warning('Warning event', category: LogCategory.sync),
          returnsNormally,
        );
        expect(
          () => AppLogger.error(
            'Error report',
            category: LogCategory.database,
            error: Exception('Test exception'),
          ),
          returnsNormally,
        );
      },
    );
  });

  group('Phase 10: ApiClient Resiliency & Exponential Retry', () {
    test(
      'retries transient 503 errors up to maxRetries before succeeding',
      () async {
        int attempts = 0;

        final mockClient = MockClient((request) async {
          attempts++;
          if (attempts < 3) {
            return http.Response(
              jsonEncode({
                'error': {
                  'message': 'Service temporarily overloaded',
                  'statusCode': 503,
                },
              }),
              503,
              headers: {'content-type': 'application/json'},
            );
          }
          return http.Response(
            jsonEncode({
              'results': [
                {'id': 'audius:song1', 'title': 'Resilient Beat'},
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final apiClient = ApiClient(
          client: mockClient,
          baseUrl: 'https://api.melo.stream',
          maxRetries: 2,
          retryBaseDelay: const Duration(milliseconds: 10),
        );

        final result = await apiClient.get('/search');
        expect(result['results'], isNotEmpty);
        expect(attempts, 3); // 1 initial + 2 retries
      },
    );

    test('does NOT retry client-side 4xx errors (immediate failure)', () async {
      int attempts = 0;

      final mockClient = MockClient((request) async {
        attempts++;
        return http.Response(
          jsonEncode({
            'error': {'message': 'Bad Request', 'statusCode': 400},
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = ApiClient(
        client: mockClient,
        baseUrl: 'https://api.melo.stream',
        maxRetries: 2,
        retryBaseDelay: const Duration(milliseconds: 10),
      );

      await expectLater(
        apiClient.get('/invalid-endpoint'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
      expect(attempts, 1); // Zero retries on 4xx
    });
  });

  group('Phase 10: Multi-Account Data Isolation & Session Teardown', () {
    test('logout clears local sync queue and resets sync state', () async {
      final db = AppDatabase.memory();
      addTearDown(db.close);

      final queue = SyncQueue(db);
      final api = SyncRepository();
      final syncEngine = SyncEngine(db: db, queue: queue, api: api);
      addTearDown(syncEngine.dispose);

      // Enqueue dummy sync operation
      await syncEngine.enqueueOperation(
        id: 'op-1',
        userId: 'user-a',
        entityType: 'favorite',
        entityId: 'song-1',
        operationType: 'upsert',
        payload: {'songId': 'song-1'},
      );

      final pendingBefore = await queue.getPendingCount();
      expect(pendingBefore, 1);

      bool clearedPersonalData = false;
      final mockAuthRepo = _MockAuthRepository();
      final authNotifier = AuthNotifier(mockAuthRepo, syncEngine, () async {
        clearedPersonalData = true;
      });

      // Set authenticated state
      authNotifier.state = AuthState(
        status: AuthStatus.authenticated,
        user: AuthUser(
          id: 'user-a',
          email: 'user@a.com',
          displayName: 'User A',
          createdAt: DateTime.now(),
        ),
        accessToken: 'mock_token',
      );

      // Trigger logout
      await authNotifier.logout();

      // State should be unauthenticated
      expect(authNotifier.state.status, AuthStatus.unauthenticated);
      expect(authNotifier.state.accessToken, isNull);

      // Sync queue should be wiped clean to prevent leaking to another account
      final pendingAfter = await queue.getPendingCount();
      expect(pendingAfter, 0);
      expect(clearedPersonalData, isTrue);
    });
  });

  group('Phase 10: Recommendation Privacy Toggle Enforcement', () {
    testWidgets(
      'HomeScreen suppresses personalized sections when personalizedRecommendations is false',
      (tester) async {
        SharedPreferences.setMockInitialValues({
          'pref_personalized_recs': false, // Privacy mode active
        });
        final sharedPrefs = await SharedPreferences.getInstance();
        final prefsRepo = UserPreferencesRepository(sharedPrefs);
        final db = AppDatabase.memory();
        addTearDown(db.close);

        const testSong = Song(
          id: 'audius:privacy-1',
          provider: 'audius',
          title: 'Private Echoes',
          artist: 'Ghost Producer',
          album: 'Aura',
          duration: Duration(minutes: 3),
          streamUrl: 'https://stream.example/song.mp3',
          artworkUrl: 'https://stream.example/art.jpg',
        );

        const dummyRecommendation = Recommendation(
          song: testSong,
          score: 0.95,
          reason: RecommendationReason.frequentArtist,
          explanation: 'Matched artist',
          section: RecommendationSection.madeForYou,
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              sharedPreferencesProvider.overrideWithValue(sharedPrefs),
              userPreferencesRepositoryProvider.overrideWithValue(prefsRepo),
              userPreferencesNotifierProvider.overrideWith(
                (ref) => UserPreferencesNotifier(prefsRepo),
              ),
              recentlyPlayedStreamProvider.overrideWith(
                (ref) => Stream.value([]),
              ),
              recommendationStateProvider.overrideWith(
                (ref) => _MockRecommendationNotifier(
                  RecommendationState(
                    status: RecommendationStatus.ready,
                    sections: {
                      RecommendationSection.madeForYou: [dummyRecommendation],
                      RecommendationSection.becauseYouLiked: [
                        dummyRecommendation,
                      ],
                    },
                  ),
                ),
              ),
            ],
            child: const MaterialApp(home: HomeScreen()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // "Made For You" and "Because You Liked" headers should NOT be found because privacy toggle is off
        expect(find.text('Made For You'), findsNothing);
        expect(find.text('Because You Liked'), findsNothing);

        // Clean unmount
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
    );
  });

  group('Phase 10: Player Resiliency & Empty Queue Safety', () {
    test('next and previous on empty queue do not throw and remain safe', () {
      final notifier = PlayerNotifier();
      addTearDown(notifier.dispose);

      expect(notifier.state.queue, isEmpty);
      expect(() => notifier.next(), returnsNormally);
      expect(() => notifier.previous(), returnsNormally);
      expect(notifier.state.status, PlayerStatus.initial);
    });
  });
}

class _MockAuthRepository implements AuthRepository {
  @override
  Future<AuthState> restoreSession() async => AuthState.unauthenticated;

  @override
  Future<AuthState> login({
    required String email,
    required String password,
  }) async => AuthState.unauthenticated;

  @override
  Future<AuthState> register({
    required String email,
    required String password,
    required String displayName,
  }) async => AuthState.unauthenticated;

  @override
  Future<void> logout([String? currentAccessToken]) async {}

  @override
  Future<String> forgotPassword(String email) async => 'Sent';

  @override
  Future<AuthUser> updateProfile(
    String token, {
    String? displayName,
    String? avatarUrl,
  }) async => AuthUser(
    id: '1',
    email: 'a@a.com',
    displayName: 'Updated',
    createdAt: DateTime.now(),
  );

  @override
  Future<void> deleteAccount(String token) async {}
}

class _MockRecommendationNotifier extends StateNotifier<RecommendationState>
    implements RecommendationNotifier {
  _MockRecommendationNotifier(super.state);

  @override
  Future<void> loadRecommendations({bool forceRefresh = false}) async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> recordFeedback(dynamic feedback) async {}

  @override
  Future<void> resetPersonalization() async {}
}

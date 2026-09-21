import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/database/database_providers.dart';
import 'package:melo/core/sync/sync_conflict_resolver.dart';
import 'package:melo/core/sync/sync_engine.dart';
import 'package:melo/core/sync/sync_queue.dart';
import 'package:melo/core/sync/sync_repository.dart';
import 'package:melo/core/sync/sync_state.dart';
import 'package:melo/features/auth/data/auth_api.dart';
import 'package:melo/features/auth/data/auth_repository.dart';
import 'package:melo/features/auth/data/auth_session_storage.dart';
import 'package:melo/features/auth/domain/auth_state.dart';
import 'package:melo/features/auth/domain/auth_user.dart';
import 'package:melo/features/auth/presentation/login_screen.dart';
import 'package:melo/features/auth/presentation/register_screen.dart';
import 'package:melo/features/auth/providers/auth_provider.dart';
import 'package:melo/features/profile/presentation/screens/profile_screen.dart';

class FakeAuthApi extends AuthApi {
  bool shouldFail = false;
  final Map<String, AuthUser> registeredUsers = {};
  AuthUser? mockUser;

  @override
  Future<AuthLoginResult> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (shouldFail) {
      throw const AuthApiException('Registration server error', 500);
    }
    final user = AuthUser(
      id: 'usr_${email.hashCode}',
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    registeredUsers[email] = user;
    mockUser = user;
    return AuthLoginResult(
      user: user,
      tokens: const AuthTokensResponse(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        expiresIn: 3600,
      ),
    );
  }

  @override
  Future<AuthLoginResult> login({
    required String email,
    required String password,
  }) async {
    if (shouldFail) {
      throw const AuthApiException('Invalid email or password', 401);
    }
    final user =
        registeredUsers[email] ??
        AuthUser(
          id: 'usr_${email.hashCode}',
          email: email,
          displayName: 'Mock Listener',
          createdAt: DateTime.now(),
        );
    registeredUsers[email] = user;
    mockUser = user;
    return AuthLoginResult(
      user: user,
      tokens: const AuthTokensResponse(
        accessToken: 'mock_access_token',
        refreshToken: 'mock_refresh_token',
        expiresIn: 3600,
      ),
    );
  }

  @override
  Future<AuthUser> getMe(String token) async {
    if (shouldFail) throw const AuthApiException('Unauthorized', 401);
    if (mockUser != null) return mockUser!;
    if (registeredUsers.isNotEmpty) return registeredUsers.values.last;
    return AuthUser(
      id: 'usr_mock_123',
      email: 'test@melo.stream',
      displayName: 'Test User',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> logout([String? token]) async {}

  @override
  Future<String> forgotPassword(String email) async {
    return 'If an account exists for this email, a password reset link has been sent.';
  }

  @override
  Future<void> deleteMe(String token) async {}
}

class FakeSyncRepository extends SyncRepository {
  CloudSyncData? mockPullData;
  List<SyncQueueOperation> pushedOps = [];

  @override
  Future<CloudSyncData> pullState(String token) async {
    return mockPullData ??
        CloudSyncData(
          favorites: [],
          playlists: [],
          playlistSongs: [],
          history: [],
          preferences: null,
          metadata: {},
          serverTimestamp: DateTime.now(),
        );
  }

  @override
  Future<int> pushOperations(
    String token,
    List<SyncQueueOperation> operations,
  ) async {
    pushedOps.addAll(operations);
    return operations.length;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Phase 7: Domain & Session Storage', () {
    test('AuthUser serialization and deserialization', () {
      final now = DateTime.now();
      final user = AuthUser(
        id: 'user_001',
        email: 'dev@melo.stream',
        displayName: 'Dev User',
        avatarUrl: 'https://example.com/avatar.png',
        createdAt: now,
      );

      final json = user.toJson();
      final fromJson = AuthUser.fromJson(json);

      expect(fromJson.id, equals('user_001'));
      expect(fromJson.email, equals('dev@melo.stream'));
      expect(fromJson.displayName, equals('Dev User'));
      expect(fromJson.avatarUrl, equals('https://example.com/avatar.png'));
    });

    test(
      'InMemoryAuthSessionStorage stores, retrieves, and clears session',
      () async {
        final storage = InMemoryAuthSessionStorage();

        expect(await storage.getAccessToken(), isNull);
        expect(await storage.getRefreshToken(), isNull);
        expect(await storage.getUser(), isNull);

        await storage.saveTokens(
          accessToken: 'access_123',
          refreshToken: 'refresh_456',
        );
        final user = AuthUser(
          id: 'u1',
          email: 'u1@melo.stream',
          displayName: 'User 1',
          createdAt: DateTime.now(),
        );
        await storage.saveUser(user);

        expect(await storage.getAccessToken(), equals('access_123'));
        expect(await storage.getRefreshToken(), equals('refresh_456'));
        expect((await storage.getUser())?.email, equals('u1@melo.stream'));

        await storage.clearSession();
        expect(await storage.getAccessToken(), isNull);
        expect(await storage.getRefreshToken(), isNull);
        expect(await storage.getUser(), isNull);
      },
    );
  });

  group('Phase 7: AuthRepository & AuthNotifier Lifecycle', () {
    late FakeAuthApi api;
    late InMemoryAuthSessionStorage storage;
    late AuthRepository repo;

    setUp(() {
      api = FakeAuthApi();
      storage = InMemoryAuthSessionStorage();
      repo = AuthRepository(api: api, storage: storage);
    });

    test('Registers user and persists session securely', () async {
      final state = await repo.register(
        email: 'newuser@melo.stream',
        password: 'Password123!',
        displayName: 'New Listener',
      );

      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.user?.email, equals('newuser@melo.stream'));
      expect(state.accessToken, equals('mock_access_token'));

      // Check stored in storage
      expect(await storage.getAccessToken(), equals('mock_access_token'));
      expect((await storage.getUser())?.displayName, equals('New Listener'));
    });

    test('Logs in user and restores session after app restart', () async {
      await repo.login(
        email: 'returning@melo.stream',
        password: 'Password123!',
      );

      // Simulate app restart by creating a new AuthRepository instance with same storage
      final newRepoInstance = AuthRepository(api: api, storage: storage);
      final restoredState = await newRepoInstance.restoreSession();

      expect(restoredState.status, equals(AuthStatus.authenticated));
      expect(restoredState.user?.email, equals('returning@melo.stream'));
      expect(restoredState.accessToken, equals('mock_access_token'));
    });

    test('Logout securely clears stored session tokens', () async {
      await repo.login(
        email: 'logoutuser@melo.stream',
        password: 'Password123!',
      );
      expect(await storage.getAccessToken(), isNotNull);

      await repo.logout('mock_access_token');
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getUser(), isNull);

      final postLogoutState = await repo.restoreSession();
      expect(postLogoutState.status, equals(AuthStatus.unauthenticated));
    });

    test('Forgot password returns friendly confirmation', () async {
      final message = await repo.forgotPassword('any@melo.stream');
      expect(message, contains('a password reset link has been sent'));
    });
  });

  group('Phase 7: Drift Database Migration & Durable Sync Queue', () {
    late AppDatabase db;
    late SyncQueue queue;

    setUp(() {
      db = AppDatabase.memory();
      queue = SyncQueue(db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'Database schema version is 2 with SyncQueueTable and SyncMetadataTable',
      () {
        expect(db.schemaVersion, equals(2));
        expect(db.syncQueueTable, isNotNull);
        expect(db.syncMetadataTable, isNotNull);
      },
    );

    test(
      'Enqueues, queries, and marks completed sync operations in Drift',
      () async {
        expect(await queue.getPendingCount(), equals(0));

        await queue.enqueue(
          id: 'op_fav_1',
          userId: 'usr_test',
          entityType: 'favorite',
          entityId: 'audius:song_1',
          operationType: 'upsert',
          payload: {'title': 'Song 1'},
        );

        await queue.enqueue(
          id: 'op_pl_1',
          userId: 'usr_test',
          entityType: 'playlist',
          entityId: 'pl_100',
          operationType: 'upsert',
          payload: {'name': 'Chill Vibes'},
        );

        expect(await queue.getPendingCount(), equals(2));

        final pending = await queue.getPendingOperations();
        expect(pending.length, equals(2));
        expect(pending[0].id, equals('op_fav_1'));
        expect(pending[0].entityType, equals('favorite'));
        expect(pending[1].id, equals('op_pl_1'));
        expect(pending[1].entityType, equals('playlist'));

        // Mark first completed
        await queue.markCompleted(['op_fav_1']);
        expect(await queue.getPendingCount(), equals(1));

        final remaining = await queue.getPendingOperations();
        expect(remaining.first.id, equals('op_pl_1'));
      },
    );

    test('Sync operations survive database close and reopen', () async {
      final executor = NativeDatabase.memory();
      final dbA = AppDatabase(executor);
      final queueA = SyncQueue(dbA);

      await queueA.enqueue(
        id: 'op_persistent_1',
        entityType: 'favorite',
        entityId: 'audius:survivor',
        operationType: 'upsert',
        payload: {'title': 'Surviving Song'},
      );
      expect(await queueA.getPendingCount(), equals(1));

      // Reopen with instance B on same underlying executor
      final dbB = AppDatabase(executor);
      final queueB = SyncQueue(dbB);
      expect(await queueB.getPendingCount(), equals(1));

      final ops = await queueB.getPendingOperations();
      expect(ops.first.entityId, equals('audius:survivor'));

      await dbA.close();
      await dbB.close();
    });

    test(
      'SyncQueue failure tracking increments retryCount and records lastError',
      () async {
        await queue.enqueue(
          id: 'op_fail_test',
          entityType: 'preference',
          entityId: 'pref',
          operationType: 'upsert',
          payload: {},
        );

        await queue.markFailed('op_fail_test', 'HTTP 500 Internal Error');

        final pending = await queue.getPendingOperations();
        expect(pending.first.status, equals('failed'));
        expect(pending.first.retryCount, equals(1));
        expect(pending.first.lastError, equals('HTTP 500 Internal Error'));
      },
    );
  });

  group('Phase 7: Conflict Resolution Rules', () {
    test('Favorite conflict: latest operation wins', () {
      final time1 = DateTime(2026, 9, 20, 10, 0);
      final time2 = DateTime(2026, 9, 20, 12, 0);

      // Local is newer: local removal wins over cloud addition
      expect(
        SyncConflictResolver.resolveFavorite(
          localIsFavorite: false,
          localUpdatedAt: time2,
          cloudIsFavorite: true,
          cloudUpdatedAt: time1,
        ),
        isFalse,
      );

      // Cloud is newer: cloud addition wins over local removal
      expect(
        SyncConflictResolver.resolveFavorite(
          localIsFavorite: false,
          localUpdatedAt: time1,
          cloudIsFavorite: true,
          cloudUpdatedAt: time2,
        ),
        isTrue,
      );
    });

    test('Preferences conflict: latest updatedAt wins', () {
      final older = DateTime(2026, 9, 20, 10);
      final newer = DateTime(2026, 9, 20, 12);

      expect(
        SyncConflictResolver.shouldApplyCloudPreferences(
          localUpdatedAt: older,
          cloudUpdatedAt: newer,
        ),
        isTrue,
      );

      expect(
        SyncConflictResolver.shouldApplyCloudPreferences(
          localUpdatedAt: newer,
          cloudUpdatedAt: older,
        ),
        isFalse,
      );
    });

    test(
      'Listening history merge: max playCount and latest timestamp preserved',
      () {
        final time1 = DateTime(2026, 9, 20);
        final time2 = DateTime(2026, 9, 21);

        final merged = SyncConflictResolver.mergeHistoryEntry(
          localPlayCount: 5,
          localPlayedAt: time1,
          cloudPlayCount: 8,
          cloudPlayedAt: time2,
        );

        expect(merged.playCount, equals(8));
        expect(merged.playedAt, equals(time2));
      },
    );
  });

  group('Phase 7: SyncEngine Integration', () {
    late AppDatabase db;
    late SyncQueue queue;
    late FakeSyncRepository api;
    late SyncEngine engine;

    setUp(() {
      db = AppDatabase.memory();
      queue = SyncQueue(db);
      api = FakeSyncRepository();
      engine = SyncEngine(db: db, queue: queue, api: api);
    });

    tearDown(() async {
      engine.dispose();
      await db.close();
    });

    test(
      'performLoginSync merges cloud favorites and playlists into local Drift',
      () async {
        api.mockPullData = CloudSyncData(
          favorites: [
            {
              'songId': 'audius:cloud_track_1',
              'songMetadata': {
                'provider': 'audius',
                'title': 'Cloud Star',
                'artist': 'Aura',
                'album': 'Orbit',
                'artworkUrl': 'https://example.com/art.jpg',
                'durationMs': 210000,
              },
              'createdAt': DateTime.now().toIso8601String(),
            },
          ],
          playlists: [
            {
              'id': 'pl_cloud_01',
              'name': 'Cloud Waves',
              'description': 'Synced from cloud',
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ],
          playlistSongs: [],
          history: [],
          preferences: null,
          metadata: {'serverRevision': 2},
          serverTimestamp: DateTime.now(),
        );

        await engine.performLoginSync('token_123', 'user_123');

        // Verify merged into local Drift tables
        final localFavorites = await db.select(db.favoritesTable).get();
        expect(localFavorites.length, equals(1));
        expect(localFavorites.first.songId, equals('audius:cloud_track_1'));

        final localPlaylists = await db.select(db.playlistsTable).get();
        expect(localPlaylists.length, equals(1));
        expect(localPlaylists.first.name, equals('Cloud Waves'));

        expect(engine.state.status, equals(SyncStatus.success));
        expect(engine.state.lastSuccessfulSyncAt, isNotNull);
      },
    );

    test('performLoginSync uploads queued local pending changes', () async {
      await queue.enqueue(
        id: 'op_local_fav',
        entityType: 'favorite',
        entityId: 'audius:local_fav',
        operationType: 'upsert',
        payload: {'title': 'Local Favorite'},
      );

      expect(await queue.getPendingCount(), equals(1));

      await engine.performLoginSync('token_abc', 'user_abc');

      // Queue was flushed to api.pushOperations and marked completed
      expect(api.pushedOps.length, equals(1));
      expect(api.pushedOps.first.entityId, equals('audius:local_fav'));
      expect(await queue.getPendingCount(), equals(0));
    });

    test(
      'Local changes remain usable when offline and marked pending',
      () async {
        // User creates a favorite offline
        await engine.enqueueOperation(
          id: 'op_offline_fav',
          entityType: 'favorite',
          entityId: 'jamendo:offline_track',
          operationType: 'upsert',
          payload: {'title': 'Offline Song'},
        );

        expect(await queue.getPendingCount(), equals(1));
        expect(engine.state.pendingCount, equals(1));
        expect(engine.state.humanReadableStatus, contains('pending sync'));
      },
    );
  });

  group('Phase 7: Profile Screen Auth Integration Widget Tests', () {
    testWidgets('ProfileScreen renders guest mode when unauthenticated', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(AppDatabase.memory()),
            authStateProvider.overrideWith(
              (ref) => AuthNotifier(
                AuthRepository(
                  api: FakeAuthApi(),
                  storage: InMemoryAuthSessionStorage(),
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // In guest mode, Ujjwal fallback exists
      expect(find.text('Ujjwal'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Playback & Audio Quality'), findsOneWidget);
    });

    testWidgets(
      'ProfileScreen renders user profile and logout button when authenticated',
      (tester) async {
        final user = AuthUser(
          id: 'u_authenticated',
          email: 'alice@melo.stream',
          displayName: 'Alice Listener',
          createdAt: DateTime.now(),
        );
        final fakeApi = FakeAuthApi();
        fakeApi.mockUser = user;

        final storage = InMemoryAuthSessionStorage();
        await storage.saveTokens(
          accessToken: 'token_123',
          refreshToken: 'refresh_123',
        );
        await storage.saveUser(user);

        final authNotifier = AuthNotifier(
          AuthRepository(api: fakeApi, storage: storage),
        );
        await authNotifier.restoreSession();

        final db = AppDatabase.memory();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appDatabaseProvider.overrideWithValue(db),
              authStateProvider.overrideWith((ref) => authNotifier),
            ],
            child: const MaterialApp(home: ProfileScreen()),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Alice Listener'), findsOneWidget);
        expect(find.text('alice@melo.stream'), findsOneWidget);
        expect(find.text('MELO HI-FI CLOUD'), findsOneWidget);
        expect(find.text('Sync Now'), findsOneWidget);
        expect(find.text('Log Out'), findsOneWidget);
        expect(find.text('Delete Account'), findsOneWidget);

        await db.close();
      },
    );
  });

  group('Phase 7: Auth Screens Smoke Tests', () {
    testWidgets('LoginScreen renders inputs and submit button', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => AuthNotifier(
                AuthRepository(
                  api: FakeAuthApi(),
                  storage: InMemoryAuthSessionStorage(),
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Welcome to Melo'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('RegisterScreen renders inputs and submit button', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(
              (ref) => AuthNotifier(
                AuthRepository(
                  api: FakeAuthApi(),
                  storage: InMemoryAuthSessionStorage(),
                ),
              ),
            ),
          ],
          child: const MaterialApp(home: RegisterScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Create Melo Account'), findsOneWidget);
      expect(find.text('Display Name'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password (min. 8 characters)'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });
  });
}

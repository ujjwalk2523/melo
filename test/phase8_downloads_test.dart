import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/database/database_providers.dart';
import 'package:melo/core/downloads/download_errors.dart';
import 'package:melo/core/downloads/download_manager.dart';
import 'package:melo/core/downloads/download_permission.dart';
import 'package:melo/core/downloads/download_providers.dart';
import 'package:melo/core/downloads/download_repository.dart';
import 'package:melo/core/downloads/download_service.dart';
import 'package:melo/core/downloads/download_state.dart';
import 'package:melo/core/downloads/download_storage.dart';
import 'package:melo/core/player/playback_source_resolver.dart';
import 'package:melo/features/auth/data/auth_api.dart';
import 'package:melo/features/auth/data/auth_repository.dart';
import 'package:melo/features/auth/data/auth_session_storage.dart';
import 'package:melo/features/auth/domain/auth_user.dart';
import 'package:melo/features/auth/providers/auth_provider.dart';
import 'package:melo/features/downloads/data/download_metadata_repository_impl.dart';
import 'package:melo/features/downloads/domain/download_metadata_repository.dart';
import 'package:melo/features/library/presentation/screens/library_screen.dart';
import 'package:melo/features/player/presentation/screens/full_player_screen.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/features/profile/data/user_preferences_repository.dart';
import 'package:melo/features/profile/presentation/screens/profile_screen.dart';
import 'package:melo/shared/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthApi extends AuthApi {
  @override
  Future<AuthUser> getMe(String token) async {
    return AuthUser(
      id: 'u_test',
      email: 'test@melo.stream',
      displayName: 'Test Listener',
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory testDir;
  late AppDatabase db;
  late DownloadStorage storage;
  late FakeDownloadService downloadService;
  late DownloadRepository downloadRepo;
  late UserPreferencesRepository prefsRepo;
  late SharedPreferences prefs;

  final downloadableSong1 = const Song(
    id: 'audius_track_1',
    title: 'Solar Wind',
    artist: 'Aura',
    album: 'Cosmic Journey',
    duration: Duration(seconds: 180),
    artworkUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23',
    streamUrl:
        'https://audius-creator.audius.co/v1/tracks/audius_track_1/stream',
    downloadUrl:
        'https://audius-creator.audius.co/v1/tracks/audius_track_1/download',
    provider: 'audius',
    isDownloadable: true,
  );

  final downloadableSong2 = const Song(
    id: 'jamendo_track_2',
    title: 'Neon Drift',
    artist: 'SynthWave',
    album: 'Night City',
    duration: Duration(seconds: 210),
    artworkUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4',
    streamUrl: 'https://mp3d.jamendo.com/download/track/2/mp32',
    downloadUrl: 'https://mp3d.jamendo.com/download/track/2/mp32',
    provider: 'jamendo',
    isDownloadable: true,
  );

  final downloadableSong3 = const Song(
    id: 'jamendo_track_3',
    title: 'Electric Pulse',
    artist: 'Pulse',
    album: 'Synthetics',
    duration: Duration(seconds: 240),
    artworkUrl: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745',
    streamUrl: 'https://mp3d.jamendo.com/download/track/3/mp32',
    downloadUrl: 'https://mp3d.jamendo.com/download/track/3/mp32',
    provider: 'jamendo',
    isDownloadable: true,
  );

  final restrictedSong = const Song(
    id: 'audius_restricted_99',
    title: 'Exclusive Track',
    artist: 'VIP Artist',
    album: 'Locked Vault',
    duration: Duration(seconds: 150),
    artworkUrl: '',
    streamUrl: 'https://audius-creator.audius.co/v1/tracks/audius_restricted_99/stream',
    downloadUrl: null,
    provider: 'audius',
    isDownloadable: false,
  );

  setUp(() async {
    testDir = Directory.systemTemp.createTempSync('melo_phase8_test_');
    db = AppDatabase.memory();
    storage = DownloadStorage(testDir);
    downloadService = FakeDownloadService();
    final metaRepo = DownloadMetadataRepositoryImpl(db);
    downloadRepo = DownloadRepository(metaRepo);

    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    prefsRepo = UserPreferencesRepository(prefs);
  });

  tearDown(() async {
    await db.close();
    if (await testDir.exists()) {
      try {
        await testDir.delete(recursive: true);
      } catch (_) {}
    }
  });

  group('Phase 8: Download Permission & Authorization Validation', () {
    test('Grants download authorization only for tracks with isDownloadable and downloadUrl', () {
      const evaluator = DownloadPermissionEvaluator();

      final perm1 = evaluator.evaluate(downloadableSong1);
      expect(perm1.isAuthorized, isTrue);

      final perm2 = evaluator.evaluate(restrictedSong);
      expect(perm2.isAuthorized, isFalse);
      expect(
        (perm2 as NotAuthorizedDownloadPermission).reason,
        contains("isn't available"),
      );

      final missingUrlSong = downloadableSong1.copyWith(downloadUrl: '');
      final perm3 = evaluator.evaluate(missingUrlSong);
      expect(perm3.isAuthorized, isFalse);
    });

    test('DownloadManager rejects unauthorized downloads and throws DownloadNotAuthorizedException', () async {
      final manager = DownloadManager(
        storage: storage,
        service: downloadService,
        repository: downloadRepo,
        preferencesRepo: prefsRepo,
      );

      expect(
        () => manager.downloadTrack(restrictedSong),
        throwsA(isA<DownloadNotAuthorizedException>()),
      );

      final state = manager.getTrackDownloadState(restrictedSong.id);
      expect(state.status, equals(DownloadStatus.failed));
      expect(state.errorMessage, isNotNull);

      manager.dispose();
    });
  });

  group('Phase 8: Download Execution, Progress & State Machine', () {
    test(
      'Executes download lifecycle: pending -> downloading -> completed',
      () async {
        final manager = DownloadManager(
          storage: storage,
          service: downloadService,
          repository: downloadRepo,
          preferencesRepo: prefsRepo,
        );

        final stateList = <TrackDownloadState>[];
        final sub = manager
            .watchTrackDownloadState(downloadableSong1.id)
            .listen(stateList.add);

        await manager.downloadTrack(downloadableSong1);
        await manager.waitUntilComplete(downloadableSong1.id);

        final finalState = manager.getTrackDownloadState(downloadableSong1.id);
        expect(finalState.status, equals(DownloadStatus.completed));
        expect(finalState.progress, equals(1.0));
        expect(finalState.localPath, isNotNull);

        final file = File(finalState.localPath!);
        expect(await file.exists(), isTrue);
        expect(await file.length(), greaterThan(0));

        // Check Drift persistence
        final meta = await downloadRepo.getMetadata(downloadableSong1.id);
        expect(meta, isNotNull);
        expect(meta!.status, equals(DownloadStatus.completed));
        expect(meta.localPath, equals(finalState.localPath));

        await sub.cancel();
        manager.dispose();
      },
    );

    test(
      'Cancels active download, cleans .part file, and records cancelled state',
      () async {
        final slowService = FakeDownloadService(
          chunkDelay: const Duration(milliseconds: 100),
        );
        final manager = DownloadManager(
          storage: storage,
          service: slowService,
          repository: downloadRepo,
          preferencesRepo: prefsRepo,
        );

        await manager.downloadTrack(downloadableSong1);
        // Let download start
        await Future<void>.delayed(const Duration(milliseconds: 30));

        await manager.cancelDownload(downloadableSong1.id);
        // Allow background streaming loop to abort and delete temp file
        await Future<void>.delayed(const Duration(milliseconds: 150));

        final state = manager.getTrackDownloadState(downloadableSong1.id);
        expect(state.isCompleted, isFalse);

        final tempFile = await storage.getTempAudioFile(downloadableSong1);
        expect(await tempFile.exists(), isFalse);

        final finalFile = await storage.getFinalAudioFile(downloadableSong1);
        expect(await finalFile.exists(), isFalse);

        manager.dispose();
      },
    );

    test(
      'Removes completed download, deletes audio from disk, and removes DB row',
      () async {
        final manager = DownloadManager(
          storage: storage,
          service: downloadService,
          repository: downloadRepo,
          preferencesRepo: prefsRepo,
        );

        await manager.downloadTrack(downloadableSong1);
        await manager.waitUntilComplete(downloadableSong1.id);

        var state = manager.getTrackDownloadState(downloadableSong1.id);
        expect(state.isCompleted, isTrue);

        await manager.removeDownload(downloadableSong1);

        state = manager.getTrackDownloadState(downloadableSong1.id);
        expect(state.isCompleted, isFalse);

        final finalFile = await storage.getFinalAudioFile(downloadableSong1);
        expect(await finalFile.exists(), isFalse);

        final meta = await downloadRepo.getMetadata(downloadableSong1.id);
        expect(meta, isNull);

        manager.dispose();
      },
    );

    test('Retry resumes download after a failure', () async {
      final failingService = FakeDownloadService(
        shouldFail: true,
        failureException: const NetworkUnavailableException(
          'Simulated network drop',
        ),
      );
      final manager = DownloadManager(
        storage: storage,
        service: failingService,
        repository: downloadRepo,
        preferencesRepo: prefsRepo,
      );

      await manager.downloadTrack(downloadableSong1);
      await manager.waitUntilComplete(downloadableSong1.id);

      var state = manager.getTrackDownloadState(downloadableSong1.id);
      expect(state.status, equals(DownloadStatus.failed));

      // Swap in working service for retry
      failingService.shouldFail = false;
      failingService.failureException = null;
      await manager.retryDownload(downloadableSong1);
      await manager.waitUntilComplete(downloadableSong1.id);

      state = manager.getTrackDownloadState(downloadableSong1.id);
      expect(state.status, equals(DownloadStatus.completed));

      manager.dispose();
    });
  });

  group('Phase 8: Concurrency Limiting (Max 2 Concurrent Downloads)', () {
    test('Limits active downloads to 2 and queues subsequent tracks', () async {
      final slowService = FakeDownloadService(
        fakeFileSizeBytes: 50000,
        chunkDelay: const Duration(milliseconds: 60),
      );

      final manager = DownloadManager(
        storage: storage,
        service: slowService,
        repository: downloadRepo,
        preferencesRepo: prefsRepo,
        maxConcurrentDownloads: 2,
      );

      await manager.downloadTrack(downloadableSong1);
      await manager.downloadTrack(downloadableSong2);
      await manager.downloadTrack(downloadableSong3);

      // Immediately: track 1 & 2 are downloading, track 3 is pending
      expect(
        manager.getTrackDownloadState(downloadableSong1.id).status,
        equals(DownloadStatus.downloading),
      );
      expect(
        manager.getTrackDownloadState(downloadableSong2.id).status,
        equals(DownloadStatus.downloading),
      );
      expect(
        manager.getTrackDownloadState(downloadableSong3.id).status,
        equals(DownloadStatus.pending),
      );

      // Wait for queue processing to complete all 3 tracks
      await Future<void>.delayed(const Duration(milliseconds: 800));

      expect(
        manager.getTrackDownloadState(downloadableSong1.id).status,
        equals(DownloadStatus.completed),
      );
      expect(
        manager.getTrackDownloadState(downloadableSong2.id).status,
        equals(DownloadStatus.completed),
      );
      expect(
        manager.getTrackDownloadState(downloadableSong3.id).status,
        equals(DownloadStatus.completed),
      );

      manager.dispose();
    });
  });

  group('Phase 8: Startup Recovery & Storage Reconciliation', () {
    test('Reconciles storage on startup: validates disk files against Drift DB records', () async {
      final manager = DownloadManager(
        storage: storage,
        service: downloadService,
        repository: downloadRepo,
        preferencesRepo: prefsRepo,
      );

      // 1. Download track 1 completely
      await manager.downloadTrack(downloadableSong1);
      while (!manager.getTrackDownloadState(downloadableSong1.id).isCompleted) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }

      // 2. Manually insert track 2 into DB but do NOT create file on disk (simulating external deletion)
      await downloadRepo.recordDownloadStarted(downloadableSong2);
      await downloadRepo.recordCompleted(
        songId: downloadableSong2.id,
        localPath: '${testDir.path}/missing/audio.file',
        totalBytes: 2048,
      );

      // Run recovery
      await manager.recoverInterruptedDownloads();

      // Track 1 should be completed
      final state1 = manager.getTrackDownloadState(downloadableSong1.id);
      expect(state1.status, equals(DownloadStatus.completed));

      // Track 2 should be marked failed in DB and manager
      final state2 = manager.getTrackDownloadState(downloadableSong2.id);
      expect(state2.status, equals(DownloadStatus.failed));
      expect(state2.errorMessage, contains('missing or unreadable'));

      final meta2 = await downloadRepo.getMetadata(downloadableSong2.id);
      expect(meta2!.status, equals(DownloadStatus.failed));

      manager.dispose();
    });

    test('Clears all downloads from disk and database', () async {
      final manager = DownloadManager(
        storage: storage,
        service: downloadService,
        repository: downloadRepo,
        preferencesRepo: prefsRepo,
      );

      await manager.downloadTrack(downloadableSong1);
      await manager.waitUntilComplete(downloadableSong1.id);

      final usedBytesBefore = await manager.getTotalStorageBytes();
      expect(usedBytesBefore, greaterThan(0));

      await manager.clearAllDownloads();

      final usedBytesAfter = await manager.getTotalStorageBytes();
      expect(usedBytesAfter, equals(0));

      final downloadedSongs = await manager.getDownloadedSongs();
      expect(downloadedSongs, isEmpty);

      manager.dispose();
    });
  });

  group('Phase 8: Playback Source Resolution Priority', () {
    late PlaybackSourceResolver resolver;

    setUp(() {
      resolver = PlaybackSourceResolver(
        downloadRepo: downloadRepo,
        downloadStorage: storage,
        preferencesRepo: prefsRepo,
      );
    });

    test('Priority 1: Resolves to LocalFileSource when downloaded file is valid on disk', () async {
      // Download track
      final manager = DownloadManager(
        storage: storage,
        service: downloadService,
        repository: downloadRepo,
        preferencesRepo: prefsRepo,
      );
      await manager.downloadTrack(downloadableSong1);
      await manager.waitUntilComplete(downloadableSong1.id);

      final source = await resolver.resolve(downloadableSong1);
      expect(source, isA<LocalFileSource>());
      expect((source as LocalFileSource).filePath, isNotEmpty);
      expect(await File(source.filePath).exists(), isTrue);

      manager.dispose();
    });

    test(
      'Priority 2: Resolves to RemoteUrlSource when online and not downloaded',
      () async {
        final source = await resolver.resolve(downloadableSong2);
        expect(source, isA<RemoteUrlSource>());
        expect(
          (source as RemoteUrlSource).url,
          equals(downloadableSong2.streamUrl),
        );
      },
    );

    test('Offline mode: Resolves to UnavailableSource when track is not downloaded', () async {
      // Set offline-only mode in preferences
      await prefsRepo.setOfflineOnly(true);

      final source = await resolver.resolve(downloadableSong2);
      expect(source, isA<UnavailableSource>());
      expect(
        (source as UnavailableSource).reason,
        contains('Offline-only mode is active'),
      );
    });

    test(
      'Disconnected network: Resolves to UnavailableSource when not downloaded',
      () async {
        resolver.isNetworkOnline = () => false;

        final source = await resolver.resolve(downloadableSong2);
        expect(source, isA<UnavailableSource>());
        expect(
          (source as UnavailableSource).reason,
          contains('No internet connection'),
        );
      },
    );

    test('Fallback: Falls back to RemoteUrlSource if local file is missing on disk', () async {
      // Record completed in DB but don't create file
      await downloadRepo.recordDownloadStarted(downloadableSong1);
      await downloadRepo.recordCompleted(
        songId: downloadableSong1.id,
        localPath: '${testDir.path}/non_existent.file',
        totalBytes: 1024,
      );

      final source = await resolver.resolve(downloadableSong1);
      // Corrupt/missing local file falls back to remote stream while online
      expect(source, isA<RemoteUrlSource>());

      // And repairs metadata
      final meta = await downloadRepo.getMetadata(downloadableSong1.id);
      expect(meta!.status, equals(DownloadStatus.failed));
    });
  });

  group('Phase 8: Player Integration with Local Playback', () {
    test('PlayerNotifier plays local file when track is downloaded', () async {
      final fakePlayer = FakeAudioPlayerService();
      final manager = DownloadManager(
        storage: storage,
        service: downloadService,
        repository: downloadRepo,
        preferencesRepo: prefsRepo,
      );

      await manager.downloadTrack(downloadableSong1);
      await manager.waitUntilComplete(downloadableSong1.id);

      final resolver = PlaybackSourceResolver(
        downloadRepo: downloadRepo,
        downloadStorage: storage,
        preferencesRepo: prefsRepo,
      );

      final notifier = PlayerNotifier(
        fakePlayer,
        null,
        null,
        null,
        null,
        resolver,
        manager,
        downloadRepo,
      );

      await notifier.play(downloadableSong1);

      // Verify FakeAudioPlayer loaded local path, not remote URL
      expect(fakePlayer.lastLoadedPath, isNotNull);
      expect(fakePlayer.lastLoadedPath, contains(downloadableSong1.id));
      expect(fakePlayer.lastLoadedUrl, isNull);
      expect(notifier.state.status, equals(PlayerStatus.playing));

      notifier.dispose();
      manager.dispose();
      fakePlayer.dispose();
    });
  });

  group('Phase 8: UI Widget Tests (FullPlayer & ProfileScreen)', () {
    testWidgets('FullPlayer download button shows correct states', (
      tester,
    ) async {
      final fakePlayer = FakeAudioPlayerService();
      final manager = DownloadManager(
        storage: storage,
        service: downloadService,
        repository: downloadRepo,
        preferencesRepo: prefsRepo,
      );

      final notifier = PlayerNotifier(
        fakePlayer,
        null,
        null,
        null,
        null,
        null,
        manager,
        downloadRepo,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            downloadStorageProvider.overrideWithValue(storage),
            downloadServiceProvider.overrideWithValue(downloadService),
            downloadRepositoryProvider.overrideWithValue(downloadRepo),
            downloadManagerProvider.overrideWithValue(manager),
            playerNotifierProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(home: FullPlayerScreen()),
        ),
      );

      // 1. Play authorized downloadable track
      await notifier.play(downloadableSong1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Download icon should be present
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);

      // 2. Play non-downloadable track
      await notifier.play(restrictedSong);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Disabled download icon with tooltip
      expect(
        find.byTooltip("Offline download isn't available for this track."),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('ProfileScreen shows Clear All Downloads and storage usage', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            authStateProvider.overrideWith(
              (ref) => AuthNotifier(
                AuthRepository(
                  api: _FakeAuthApi(),
                  storage: InMemoryAuthSessionStorage(),
                ),
              ),
            ),
            downloadStorageSizeProvider.overrideWith(
              (ref) => Future.value(1024 * 1024 * 5),
            ), // 5.0 MB
          ],
          child: const MaterialApp(home: ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final clearAllFinder = find.text('Clear All Downloads');
      await tester.scrollUntilVisible(clearAllFinder, 100.0);
      expect(clearAllFinder, findsOneWidget);
      expect(find.textContaining('5.0 MB'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('LibraryScreen integrates downloadedSongsProvider', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            downloadedSongsProvider.overrideWith(
              (ref) => Future.value([downloadableSong1]),
            ),
          ],
          child: const MaterialApp(home: LibraryScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Your Library'), findsOneWidget);
      expect(find.text('Downloads'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}

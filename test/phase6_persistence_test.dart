import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/database/database_converters.dart';
import 'package:melo/features/downloads/data/download_metadata_repository_impl.dart';
import 'package:melo/features/downloads/domain/download_metadata_repository.dart';
import 'package:melo/features/favorites/data/favorites_repository_impl.dart';
import 'package:melo/features/history/data/history_repository_impl.dart';
import 'package:melo/features/player/data/player_snapshot_repository.dart';
import 'package:melo/features/player/domain/models/player_state.dart';
import 'package:melo/features/playlists/data/playlist_repository_impl.dart';
import 'package:melo/features/profile/data/user_preferences_repository.dart';
import 'package:melo/shared/models/song.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testSong1 = Song(
    id: 'audius:track_001',
    title: 'Neon Skyline',
    artist: 'Aura Weaver',
    album: 'Cyber Dreams',
    artworkUrl: 'https://example.com/art1.jpg',
    duration: const Duration(seconds: 210),
    streamUrl: 'https://example.com/stream1.mp3',
    downloadUrl: 'https://example.com/dl1.mp3',
    isDownloadable: true,
    provider: 'audius',
    genre: 'Synthwave',
  );

  final testSong2 = Song(
    id: 'jamendo:track_999',
    title: 'Rainy Cafe',
    artist: 'Lo-Fi Chillers',
    album: 'Coffee & Books',
    artworkUrl: 'https://example.com/art2.jpg',
    duration: const Duration(seconds: 180),
    streamUrl: 'https://example.com/stream2.mp3',
    provider: 'jamendo',
    genre: 'Lo-Fi',
  );

  final testSong3 = Song(
    id: 'mock:track_777',
    title: 'Solar Eclipse',
    artist: 'Cosmic Beats',
    album: 'Space Voyage',
    artworkUrl: 'https://example.com/art3.jpg',
    duration: const Duration(seconds: 240),
    streamUrl: 'https://example.com/stream3.mp3',
    provider: 'mock',
    genre: 'Ambient',
  );

  group('Phase 6: Database Core & Normalized Songs', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.memory();
    });

    tearDown(() async {
      await db.close();
    });

    test('Database initializes with schema version', () {
      expect(db.schemaVersion, greaterThanOrEqualTo(1));
    });

    test('Persists normalized songs from different providers without key collision', () async {
      await db
          .into(db.songsTable)
          .insert(DatabaseConverters.songToCompanion(testSong1));
      await db
          .into(db.songsTable)
          .insert(DatabaseConverters.songToCompanion(testSong2));

      final allSongs = await db.select(db.songsTable).get();
      expect(allSongs.length, equals(2));

      final audiusSong = allSongs.firstWhere((s) => s.provider == 'audius');
      expect(audiusSong.id, equals('audius:track_001'));
      expect(audiusSong.title, equals('Neon Skyline'));
      expect(audiusSong.isDownloadable, isTrue);

      final jamendoSong = allSongs.firstWhere((s) => s.provider == 'jamendo');
      expect(jamendoSong.id, equals('jamendo:track_999'));
      expect(jamendoSong.providerTrackId, equals('track_999'));
    });
  });

  group('Phase 6: Favorites Repository', () {
    late AppDatabase db;
    late FavoritesRepositoryImpl favoritesRepo;

    setUp(() {
      db = AppDatabase.memory();
      favoritesRepo = FavoritesRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('addFavorite persists song and sets favorite status', () async {
      await favoritesRepo.addFavorite(testSong1);

      final isFav = await favoritesRepo.isFavorite(testSong1.id);
      expect(isFav, isTrue);

      final favorites = await favoritesRepo.getFavorites();
      expect(favorites.length, equals(1));
      expect(favorites.first.title, equals('Neon Skyline'));
    });

    test('Duplicate addFavorite does not throw or create duplicates', () async {
      await favoritesRepo.addFavorite(testSong1);
      await favoritesRepo.addFavorite(testSong1);

      final favorites = await favoritesRepo.getFavorites();
      expect(favorites.length, equals(1));
    });

    test('removeFavorite removes song from favorites', () async {
      await favoritesRepo.addFavorite(testSong1);
      await favoritesRepo.addFavorite(testSong2);

      await favoritesRepo.removeFavorite(testSong1.id);

      expect(await favoritesRepo.isFavorite(testSong1.id), isFalse);
      expect(await favoritesRepo.isFavorite(testSong2.id), isTrue);
      final remaining = await favoritesRepo.getFavorites();
      expect(remaining.length, equals(1));
      expect(remaining.first.id, equals(testSong2.id));
    });

    test('toggleFavorite adds then removes song', () async {
      final nowFavorite = await favoritesRepo.toggleFavorite(testSong1);
      expect(nowFavorite, isTrue);
      expect(await favoritesRepo.isFavorite(testSong1.id), isTrue);

      final nowUnfavorite = await favoritesRepo.toggleFavorite(testSong1);
      expect(nowUnfavorite, isFalse);
      expect(await favoritesRepo.isFavorite(testSong1.id), isFalse);
    });

    test('watchFavoriteIds emits updated set reactively', () async {
      final stream = favoritesRepo.watchFavoriteIds();

      expectLater(
        stream,
        emitsInOrder([
          isEmpty,
          {testSong1.id},
          {testSong1.id, testSong2.id},
          {testSong2.id},
        ]),
      );

      await Future.delayed(const Duration(milliseconds: 10));
      await favoritesRepo.addFavorite(testSong1);
      await Future.delayed(const Duration(milliseconds: 10));
      await favoritesRepo.addFavorite(testSong2);
      await Future.delayed(const Duration(milliseconds: 10));
      await favoritesRepo.removeFavorite(testSong1.id);
    });
  });

  group('Phase 6: Listening History Repository', () {
    late AppDatabase db;
    late HistoryRepositoryImpl historyRepo;

    setUp(() {
      db = AppDatabase.memory();
      historyRepo = HistoryRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('recordPlayed records playback event with timestamp', () async {
      await historyRepo.recordPlayed(testSong1);

      final history = await historyRepo.getRecentlyPlayed();
      expect(history.length, equals(1));
      expect(history.first.id, equals(testSong1.id));
    });

    test(
      'repeated play of same song increments playCount and updates order',
      () async {
        await historyRepo.recordPlayed(testSong1);
        await Future.delayed(const Duration(milliseconds: 20));
        await historyRepo.recordPlayed(testSong2);
        await Future.delayed(const Duration(milliseconds: 20));

        // Play song1 again
        await historyRepo.recordPlayed(testSong1);

        final history = await historyRepo.getRecentlyPlayed();
        expect(history.length, equals(2));
        // Song1 should now be first (most recent)
        expect(history.first.id, equals(testSong1.id));
        expect(history.last.id, equals(testSong2.id));

        final historyRows = await db.select(db.listeningHistoryTable).get();
        final song1Row = historyRows.firstWhere(
          (r) => r.songId == testSong1.id,
        );
        expect(song1Row.playCount, equals(2));
      },
    );

    test('clearHistory removes all history records', () async {
      await historyRepo.recordPlayed(testSong1);
      await historyRepo.recordPlayed(testSong2);

      await historyRepo.clearHistory();

      final history = await historyRepo.getRecentlyPlayed();
      expect(history, isEmpty);
    });
  });

  group('Phase 6: Playlists Repository', () {
    late AppDatabase db;
    late PlaylistRepositoryImpl playlistRepo;

    setUp(() {
      db = AppDatabase.memory();
      playlistRepo = PlaylistRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('createPlaylist creates playlist with validation', () async {
      final playlist = await playlistRepo.createPlaylist(
        '  Late Night Beats  ',
        description: 'Chill vibe for study',
      );

      expect(playlist.name, equals('Late Night Beats'));
      expect(playlist.description, equals('Chill vibe for study'));

      // Validate empty name throws
      expect(
        () => playlistRepo.createPlaylist('   '),
        throwsA(isA<ArgumentError>()),
      );

      // Validate excessively long name throws
      expect(
        () => playlistRepo.createPlaylist('A' * 105),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('renamePlaylist updates playlist name', () async {
      final pl = await playlistRepo.createPlaylist('Old Name');
      await playlistRepo.renamePlaylist(pl.id, 'New Name');

      final updated = await playlistRepo.getPlaylist(pl.id);
      expect(updated?.name, equals('New Name'));
    });

    test(
      'addSongToPlaylist prevents duplicate copies and preserves order',
      () async {
        final pl = await playlistRepo.createPlaylist('Favorites Mix');

        await playlistRepo.addSongToPlaylist(pl.id, testSong1);
        await playlistRepo.addSongToPlaylist(pl.id, testSong2);
        // Attempt to add duplicate
        await playlistRepo.addSongToPlaylist(pl.id, testSong1);

        final songs = await playlistRepo.getPlaylistSongs(pl.id);
        expect(songs.length, equals(2));
        expect(songs[0].id, equals(testSong1.id));
        expect(songs[1].id, equals(testSong2.id));
      },
    );

    test('reorderPlaylistSongs reorders songs in playlist', () async {
      final pl = await playlistRepo.createPlaylist('Reorder Playlist');
      await playlistRepo.addSongToPlaylist(pl.id, testSong1);
      await playlistRepo.addSongToPlaylist(pl.id, testSong2);
      await playlistRepo.addSongToPlaylist(pl.id, testSong3);

      // Reorder: song3, song1, song2
      await playlistRepo.reorderPlaylistSongs(pl.id, [
        testSong3.id,
        testSong1.id,
        testSong2.id,
      ]);

      final reordered = await playlistRepo.getPlaylistSongs(pl.id);
      expect(reordered[0].id, equals(testSong3.id));
      expect(reordered[1].id, equals(testSong1.id));
      expect(reordered[2].id, equals(testSong2.id));
    });

    test('deletePlaylist removes playlist and its junction rows', () async {
      final pl = await playlistRepo.createPlaylist('To Delete');
      await playlistRepo.addSongToPlaylist(pl.id, testSong1);

      await playlistRepo.deletePlaylist(pl.id);

      final fetched = await playlistRepo.getPlaylist(pl.id);
      expect(fetched, isNull);

      final junctionRows = await (db.select(
        db.playlistSongsTable,
      )..where((tbl) => tbl.playlistId.equals(pl.id))).get();
      expect(junctionRows, isEmpty);
    });
  });

  group('Phase 6: Download Metadata Repository (Metadata Only)', () {
    late AppDatabase db;
    late DownloadMetadataRepositoryImpl downloadRepo;

    setUp(() {
      db = AppDatabase.memory();
      downloadRepo = DownloadMetadataRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'recordDownloadMetadata saves metadata without actual audio file',
      () async {
        await downloadRepo.recordDownloadMetadata(
          song: testSong1,
          status: DownloadStatus.completed,
          localPath: '/local/audio/fake_path.mp3',
          downloadedBytes: 5242880,
          totalBytes: 5242880,
        );

        final metadata = await downloadRepo.getMetadata(testSong1.id);
        expect(metadata, isNotNull);
        expect(metadata?.status, equals(DownloadStatus.completed));
        expect(metadata?.downloadedBytes, equals(5242880));

        final downloadedSongs = await downloadRepo.getDownloadedSongs();
        expect(downloadedSongs.length, equals(1));
        expect(downloadedSongs.first.id, equals(testSong1.id));
      },
    );

    test('updateStatus updates download state', () async {
      await downloadRepo.recordDownloadMetadata(
        song: testSong2,
        status: DownloadStatus.pending,
      );

      await downloadRepo.updateStatus(testSong2.id, DownloadStatus.failed);

      final meta = await downloadRepo.getMetadata(testSong2.id);
      expect(meta?.status, equals(DownloadStatus.failed));
    });
  });

  group('Phase 6: Player Snapshot & Queue Persistence', () {
    late AppDatabase db;
    late PlayerSnapshotRepositoryImpl snapshotRepo;

    setUp(() {
      db = AppDatabase.memory();
      snapshotRepo = PlayerSnapshotRepositoryImpl(db);
    });

    tearDown(() async {
      await db.close();
    });

    test(
      'saveSnapshot and loadSnapshot restores queue, song, and settings',
      () async {
        await snapshotRepo.saveSnapshot(
          currentSong: testSong2,
          queue: [testSong1, testSong2, testSong3],
          position: const Duration(seconds: 45),
          repeatMode: PlaybackRepeatMode.all,
          isShuffle: true,
        );

        final restored = await snapshotRepo.loadSnapshot();
        expect(restored, isNotNull);
        expect(restored?.currentSong?.id, equals(testSong2.id));
        expect(restored?.queue.length, equals(3));
        expect(restored?.queue[0].id, equals(testSong1.id));
        expect(restored?.queue[1].id, equals(testSong2.id));
        expect(restored?.queue[2].id, equals(testSong3.id));
        expect(restored?.position.inSeconds, equals(45));
        expect(restored?.repeatMode, equals(PlaybackRepeatMode.all));
        expect(restored?.isShuffle, isTrue);
      },
    );
  });

  group('Phase 6: User Preferences Repository', () {
    test('Reads default settings and persists updates', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = UserPreferencesRepository(prefs);

      final defaults = repo.getPreferences();
      expect(defaults.audioQuality, equals('Hi-Res Lossless (FLAC 24-bit)'));
      expect(defaults.gaplessPlayback, isTrue);
      expect(defaults.normalizeVolume, isTrue);
      expect(defaults.crossfadeDuration, equals(3.0));
      expect(defaults.offlineOnly, isFalse);
      expect(defaults.downloadOnWifiOnly, isTrue);

      // Mutate preferences
      await repo.setAudioQuality('High (320 kbps AAC)');
      await repo.setGaplessPlayback(false);
      await repo.setCrossfadeDuration(6.0);
      await repo.setOfflineOnly(true);

      final updated = repo.getPreferences();
      expect(updated.audioQuality, equals('High (320 kbps AAC)'));
      expect(updated.gaplessPlayback, isFalse);
      expect(updated.crossfadeDuration, equals(6.0));
      expect(updated.offlineOnly, isTrue);
    });
  });

  group('Phase 6: Restart & Persistence Across Database Reopen', () {
    test('Data written to Database Instance A survives close and reopen in Instance B', () async {
      final tempDir = Directory.systemTemp.createTempSync(
        'melo_persistence_test_',
      );
      final dbFile = File(p.join(tempDir.path, 'reopen_test.sqlite'));

      try {
        // 1. Open Database Instance A
        final dbA = AppDatabase(NativeDatabase(dbFile));
        final favoritesRepoA = FavoritesRepositoryImpl(dbA);
        final playlistRepoA = PlaylistRepositoryImpl(dbA);
        final historyRepoA = HistoryRepositoryImpl(dbA);

        // Write playlist, favorites, and history
        final playlistA = await playlistRepoA.createPlaylist('Workout Tracks');
        await playlistRepoA.addSongToPlaylist(playlistA.id, testSong1);
        await playlistRepoA.addSongToPlaylist(playlistA.id, testSong2);
        await favoritesRepoA.addFavorite(testSong3);
        await historyRepoA.recordPlayed(testSong1);

        // Close Database Instance A
        await dbA.close();

        // 2. Open Database Instance B pointing to same SQLite file
        final dbB = AppDatabase(NativeDatabase(dbFile));
        final favoritesRepoB = FavoritesRepositoryImpl(dbB);
        final playlistRepoB = PlaylistRepositoryImpl(dbB);
        final historyRepoB = HistoryRepositoryImpl(dbB);

        // Verify playlist survived restart
        final playlistsB = await playlistRepoB.getPlaylists();
        expect(playlistsB.length, equals(1));
        expect(playlistsB.first.name, equals('Workout Tracks'));
        final playlistSongsB = await playlistRepoB.getPlaylistSongs(
          playlistsB.first.id,
        );
        expect(playlistSongsB.length, equals(2));
        expect(playlistSongsB[0].id, equals(testSong1.id));
        expect(playlistSongsB[1].id, equals(testSong2.id));

        // Verify favorite survived restart
        final isFav3 = await favoritesRepoB.isFavorite(testSong3.id);
        expect(isFav3, isTrue);
        final favsB = await favoritesRepoB.getFavorites();
        expect(favsB.length, equals(1));
        expect(favsB.first.title, equals('Solar Eclipse'));

        // Verify listening history survived restart
        final historyB = await historyRepoB.getRecentlyPlayed();
        expect(historyB.length, equals(1));
        expect(historyB.first.title, equals('Neon Skyline'));

        await dbB.close();
      } finally {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    });
  });
}

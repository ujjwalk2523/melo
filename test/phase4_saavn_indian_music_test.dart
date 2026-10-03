import 'package:flutter_test/flutter_test.dart';
import 'package:melo/core/network/saavn_service.dart';
import 'package:melo/core/player/playback_source_resolver.dart';
import 'package:melo/core/downloads/download_repository.dart';
import 'package:melo/core/downloads/download_storage.dart';
import 'package:melo/features/downloads/domain/download_metadata_repository.dart';
import 'package:melo/features/search/data/search_repository.dart';
import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/models/song.dart';

class _FakeDownloadRepo implements DownloadRepository {
  @override
  Future<DownloadMetadata?> getMetadata(String songId) async => null;
  @override
  Future<void> recordFailed({required String songId, required String errorMessage}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDownloadStorage implements DownloadStorage {
  @override
  Future<bool> validateExistingFile(String path) async => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Phase 4: Free Indian Music (Saavn Integration)', () {
    test('SaavnService.decryptMediaUrl decrypts DES-encrypted media tokens accurately', () {
      // Known token from JioSaavn
      const token = 'ID2ieOjCrwfgWvL5sXl4B1ImC5QfbsDyrBAWC97DSvbuFjCjHV1Dc/ZM2Ut7gz3z/m6RImgLg8VKNUcLxkWCmBw7tS9a8Gtq';
      final streamUrl = SaavnService.decryptMediaUrl(token);

      expect(streamUrl, isNotNull);
      expect(streamUrl, startsWith('https://aac.saavncdn.com/'));
      expect(streamUrl, endsWith('_320.mp4'));
    });

    test('MockCatalog includes Indian regional hits and classics', () {
      final songs = MockCatalog.songs;

      // Hindi / Honey Singh
      final brownRang = songs.firstWhere((s) => s.title == 'Brown Rang');
      expect(brownRang.artist, contains('Honey Singh'));
      expect(brownRang.provider, 'saavn');
      expect(brownRang.streamUrl, contains('aac.saavncdn.com'));

      // Punjabi / Shubh
      final cheques = songs.firstWhere((s) => s.title == 'Cheques');
      expect(cheques.artist, 'Shubh');
      expect(cheques.streamUrl, contains('aac.saavncdn.com'));

      // Bhojpuri / Pawan Singh
      final lollypop = songs.firstWhere((s) => s.title == 'Lolly Pop Lageli');
      expect(lollypop.artist, 'Pawan Singh');
      expect(lollypop.genre, 'Bhojpuri');

      // Haryanvi / Masoom Sharma
      final numbari = songs.firstWhere((s) => s.title == '2 Numbari');
      expect(numbari.artist, contains('Masoom Sharma'));
      expect(numbari.genre, 'Haryanvi');

      // Retro Classic / Kishore Kumar
      final roop = songs.firstWhere((s) => s.title == 'Roop Tera Mastana');
      expect(roop.artist, 'Kishore Kumar');
      expect(roop.genre, 'Retro Classics');
    });

    test('MockCatalog curated playlists include Desi and Regional collections', () {
      final playlists = MockCatalog.playlists;
      expect(playlists.any((p) => p.title.contains('Bollywood & Punjabi')), isTrue);
      expect(playlists.any((p) => p.title.contains('Bhojpuri Dhamaka')), isTrue);
      expect(playlists.any((p) => p.title.contains('Haryanvi Top Beats')), isTrue);
      expect(playlists.any((p) => p.title.contains('Golden Era')), isTrue);
    });

    test('PlaybackSourceResolver resolves Saavn tracks with direct remote stream', () async {
      final resolver = PlaybackSourceResolver(
        downloadRepo: _FakeDownloadRepo(),
        downloadStorage: _FakeDownloadStorage(),
      );

      final honeySinghTrack = MockCatalog.songs.firstWhere((s) => s.title == 'Brown Rang');
      final source = await resolver.resolve(honeySinghTrack);

      expect(source, isA<RemoteUrlSource>());
      final remote = source as RemoteUrlSource;
      expect(remote.url, contains('aac.saavncdn.com'));
      expect(remote.song.id, 'saavn:vj2tW1iy');
    });

    test('SearchRepository fallbackMockSearch finds Indian songs by artist or title', () {
      final pawanResults = SearchRepository.fallbackMockSearch('Pawan Singh');
      expect(pawanResults, isNotEmpty);
      expect(pawanResults.first.title, 'Lolly Pop Lageli');

      final honeyResults = SearchRepository.fallbackMockSearch('Honey Singh');
      expect(honeyResults, isNotEmpty);
      expect(honeyResults.any((s) => s.title == 'Brown Rang'), isTrue);

      final haryanviResults = SearchRepository.fallbackMockSearch('Haryanvi');
      expect(haryanviResults, isNotEmpty);
      expect(haryanviResults.first.artist, contains('Masoom Sharma'));
    });
  });
}

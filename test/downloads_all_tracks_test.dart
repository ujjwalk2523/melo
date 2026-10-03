import 'package:flutter_test/flutter_test.dart';
import 'package:melo/core/downloads/download_permission.dart';
import 'package:melo/shared/models/song.dart';

void main() {
  group('DownloadPermissionEvaluator All-Tracks Tests', () {
    const evaluator = DownloadPermissionEvaluator();

    test('Authorizes tracks with explicit downloadUrl', () {
      const song = Song(
        id: 'song-1',
        title: 'Song 1',
        artist: 'Artist 1',
        album: 'Album 1',
        artworkUrl: 'https://example.com/art.jpg',
        duration: Duration(seconds: 180),
        provider: 'audius',
        streamUrl: 'https://stream.example.com/1.mp3',
        downloadUrl: 'https://download.example.com/1.mp3',
        isDownloadable: true,
      );

      final perm = evaluator.evaluate(song);
      expect(perm.isAuthorized, isTrue);
      expect((perm as AuthorizedDownloadPermission).url, equals('https://download.example.com/1.mp3'));
    });

    test('Authorizes tracks with streamUrl fallback when downloadUrl is omitted', () {
      const song = Song(
        id: 'saavn-track-1',
        title: 'Brown Rang',
        artist: 'Yo Yo Honey Singh',
        album: 'International Villager',
        artworkUrl: 'https://example.com/art.jpg',
        duration: Duration(seconds: 180),
        provider: 'saavn',
        streamUrl: 'https://akamai.cdn.saavn.com/brown_rang.mp4',
        downloadUrl: null,
        isDownloadable: true,
      );

      final perm = evaluator.evaluate(song);
      expect(perm.isAuthorized, isTrue);
      expect((perm as AuthorizedDownloadPermission).url, equals('https://akamai.cdn.saavn.com/brown_rang.mp4'));
    });

    test('Rejects tracks when isDownloadable is explicitly false', () {
      const song = Song(
        id: 'restricted-1',
        title: 'Restricted',
        artist: 'Artist',
        album: 'Locked Album',
        artworkUrl: 'https://example.com/art.jpg',
        duration: Duration(seconds: 180),
        provider: 'audius',
        streamUrl: 'https://stream.example.com/1.mp3',
        isDownloadable: false,
      );

      final perm = evaluator.evaluate(song);
      expect(perm.isAuthorized, isFalse);
    });
  });
}

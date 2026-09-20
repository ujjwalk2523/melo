import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:melo/core/network/api_client.dart';
import 'package:melo/features/search/data/search_api.dart';
import 'package:melo/features/search/data/search_repository.dart';
import 'package:melo/features/search/providers/search_provider.dart';
import 'package:melo/shared/models/song.dart';

void main() {
  group('Phase 3: Song Model Parsing & Serialization', () {
    test('Song.fromJson parses normalized backend payload correctly', () {
      final json = {
        'id': 'audius:95wro',
        'provider': 'audius',
        'providerTrackId': '95wro',
        'title': 'Stars In The Sky',
        'artist': 'Lofi Beats',
        'artworkUrl': 'https://audius.co/art/480.jpg',
        'durationSeconds': 180,
        'streamUrl':
            'https://discoveryprovider.audius.co/v1/tracks/95wro/stream',
        'downloadUrl': null,
        'isDownloadable': false,
        'genre': 'Lo-Fi',
        'releaseDate': '2025-01-15T00:00:00.000Z',
      };

      final song = Song.fromJson(json);

      expect(song.id, 'audius:95wro');
      expect(song.provider, 'audius');
      expect(song.title, 'Stars In The Sky');
      expect(song.artist, 'Lofi Beats');
      expect(song.artworkUrl, 'https://audius.co/art/480.jpg');
      expect(song.duration.inSeconds, 180);
      expect(song.streamUrl, contains('/tracks/95wro/stream'));
      expect(song.downloadUrl, isNull);
      expect(song.isDownloadable, isFalse);
      expect(song.genre, 'Lo-Fi');
      expect(song.releaseDate, isNotNull);
    });

    test('Song.toJson serializes domain attributes accurately', () {
      const song = Song(
        id: 'jamendo:101',
        title: 'Open Source Groove',
        artist: 'Creative Commoners',
        album: 'Free Sounds',
        artworkUrl: 'https://jamendo.com/img.jpg',
        duration: Duration(minutes: 3, seconds: 12),
        streamUrl: 'https://jamendo.com/audio.mp3',
        downloadUrl: 'https://jamendo.com/download.mp3',
        isDownloadable: true,
        provider: 'jamendo',
        genre: 'Funk',
      );

      final json = song.toJson();

      expect(json['id'], 'jamendo:101');
      expect(json['provider'], 'jamendo');
      expect(json['durationSeconds'], 192);
      expect(json['isDownloadable'], isTrue);
      expect(json['downloadUrl'], 'https://jamendo.com/download.mp3');
    });
  });

  group('Phase 3: SearchRepository & Offline Mock Fallback', () {
    test('SearchRepository gracefully falls back to MockCatalog on network failure', () async {
      // Mock an API client with an invalid baseUrl to trigger network failure
      final offlineApi = SearchApi(
        ApiClient(baseUrl: 'http://invalid-unreachable-melo-host:9999/api'),
      );
      final repository = SearchRepository(offlineApi);

      final result = await repository.searchSongs('Synthwave');

      // Must succeed via fallback without throwing
      expect(result.isOfflineFallback, isTrue);
      expect(result.songs, isNotEmpty);
      expect(result.songs.any((s) => s.genre == 'Synthwave'), isTrue);
    });

    test(
      'SearchRepository fallbackMockSearch filters songs matching query',
      () {
        final results = SearchRepository.fallbackMockSearch('Kaelen Vance');
        expect(results, isNotEmpty);
        expect(results.every((s) => s.artist == 'Kaelen Vance'), isTrue);
      },
    );

    test(
      'Empty search query returns empty list immediately without network call',
      () async {
        final repository = SearchRepository();
        final result = await repository.searchSongs('   ');
        expect(result.songs, isEmpty);
        expect(result.isOfflineFallback, isFalse);
      },
    );
  });

  group('Phase 3: SearchProvider Integration & Providers', () {
    test('searchSongResultsProvider provides instant results via mock fallback when offline', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Initially empty
      expect(container.read(searchSongResultsProvider), isEmpty);
      expect(container.read(isSearchLoadingProvider), isFalse);

      // Query 'Solar'
      container.read(searchQueryProvider.notifier).state = 'Solar';

      // Reads results synchronously
      final results = container.read(searchSongResultsProvider);
      expect(results, isNotEmpty);
      expect(results.first.title, contains('Solar'));
    });

    test('searchProviderFilterProvider allows selecting specific provider', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(searchProviderFilterProvider), isNull);

      container.read(searchProviderFilterProvider.notifier).state = 'audius';
      expect(container.read(searchProviderFilterProvider), 'audius');

      container.read(searchProviderFilterProvider.notifier).state = 'jamendo';
      expect(container.read(searchProviderFilterProvider), 'jamendo');
    });
  });
}

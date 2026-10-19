import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:melo/core/database/app_database.dart';
import 'package:melo/core/youtube/youtube_sync_service.dart';
import 'package:melo/features/playlists/data/playlist_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('YouTubeSyncService Unit Tests', () {
    test('extractPlaylistId handles diverse URL formats and raw IDs', () {
      expect(
        YouTubeSyncService.extractPlaylistId('https://www.youtube.com/playlist?list=PLrAl6-Wk2_7k_lPZ_lP5t3_6r1s9vK8hM'),
        'PLrAl6-Wk2_7k_lPZ_lP5t3_6r1s9vK8hM',
      );
      expect(
        YouTubeSyncService.extractPlaylistId('https://music.youtube.com/playlist?list=RDCLAK5uy_n9Fbdw7e6ap-98_A-8JYBmPv64v-Uaq1g'),
        'RDCLAK5uy_n9Fbdw7e6ap-98_A-8JYBmPv64v-Uaq1g',
      );
      expect(
        YouTubeSyncService.extractPlaylistId('https://www.youtube.com/watch?v=6rvUyBiBtik&list=PLTestPlaylist12345&index=1'),
        'PLTestPlaylist12345',
      );
      expect(
        YouTubeSyncService.extractPlaylistId('PLrAl6-Wk2_7k_lPZ_lP5t3_6r1s9vK8hM'),
        'PLrAl6-Wk2_7k_lPZ_lP5t3_6r1s9vK8hM',
      );
      expect(
        YouTubeSyncService.extractPlaylistId('Check this out: https://youtube.com/playlist?list=PLMyFavoriteSongs123'),
        'PLMyFavoriteSongs123',
      );
    });

    test('syncPlaylist fetches real tracks from Innertube lockupViewModel and saves to database', () async {
      final mockData = {
        'header': {
          'playlistHeaderRenderer': {
            'title': {'simpleText': 'User Favorite Jams'},
          }
        },
        'contents': {
          'twoColumnBrowseResultsRenderer': {
            'tabs': [
              {
                'tabRenderer': {
                  'content': {
                    'sectionListRenderer': {
                      'contents': [
                        {
                          'itemSectionRenderer': {
                            'contents': [
                              {
                                'lockupViewModel': {
                                  'contentId': 'vid_001',
                                  'rendererContext': {
                                    'accessibilityContext': {
                                      'label': 'Kesariya - Brahmastra | Arijit Singh 4 minutes, 28 seconds',
                                    }
                                  },
                                  'metadata': {
                                    'contentMetadataViewModel': {
                                      'metadataRows': [
                                        {
                                          'metadataParts': [
                                            {'text': {'content': 'Sony Music India'}}
                                          ]
                                        }
                                      ]
                                    }
                                  }
                                }
                              },
                              {
                                'lockupViewModel': {
                                  'contentId': 'vid_002',
                                  'rendererContext': {
                                    'accessibilityContext': {
                                      'label': 'Chaleya - Jawan | Shah Rukh Khan | Anirudh, Arijit 3 minutes, 20 seconds',
                                    }
                                  },
                                  'metadata': {
                                    'contentMetadataViewModel': {
                                      'metadataRows': [
                                        {
                                          'metadataParts': [
                                            {'text': {'content': 'T-Series'}}
                                          ]
                                        }
                                      ]
                                    }
                                  }
                                }
                              }
                            ]
                          }
                        }
                      ]
                    }
                  }
                }
              }
            ]
          }
        }
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockData), 200, headers: {'content-type': 'application/json'});
      });

      final db = AppDatabase.memory();
      final playlistRepo = PlaylistRepositoryImpl(db);
      final syncService = YouTubeSyncService(client: mockClient);

      final result = await syncService.syncPlaylist(
        input: 'https://youtube.com/playlist?list=PLUserFavorites123',
        playlistRepo: playlistRepo,
      );

      expect(result.playlistTitle, 'User Favorite Jams');
      expect(result.matchedCount, 2);
      expect(result.songs.length, 2);
      expect(result.songs[0].title, contains('Kesariya'));
      expect(result.songs[1].title, contains('Chaleya'));
      expect(result.createdPlaylistId, isNotNull);

      // Verify persistence in SQLite database
      final savedPlaylists = await playlistRepo.getPlaylists();
      expect(savedPlaylists.length, 1);
      expect(savedPlaylists[0].name, 'User Favorite Jams');

      final savedSongs = await playlistRepo.getPlaylistSongs(result.createdPlaylistId!);
      expect(savedSongs.length, 2);
      expect(savedSongs[0].title, contains('Kesariya'));

      await db.close();
    });

    test('syncPlaylist fetches real tracks from YouTube Mix /next endpoint and saves to database', () async {
      final mockMixData = {
        'contents': {
          'twoColumnWatchNextResults': {
            'playlist': {
              'playlist': {
                'title': 'My Super Mix',
                'contents': [
                  {
                    'playlistPanelVideoRenderer': {
                      'videoId': 'mix_001',
                      'title': {'simpleText': 'Tum Hi Ho | Aashiqui 2'},
                      'shortBylineText': {
                        'runs': [{'text': 'Arijit Singh'}]
                      }
                    }
                  },
                  {
                    'playlistPanelVideoRenderer': {
                      'videoId': 'mix_002',
                      'title': {'simpleText': 'Raabta | Agent Vinod'},
                      'shortBylineText': {
                        'runs': [{'text': 'Arijit Singh'}]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockMixData), 200, headers: {'content-type': 'application/json'});
      });

      final db = AppDatabase.memory();
      final playlistRepo = PlaylistRepositoryImpl(db);
      final syncService = YouTubeSyncService(client: mockClient);

      final result = await syncService.syncPlaylist(
        input: 'https://www.youtube.com/watch?v=Emm3XW8eRrk&list=RDMMEmm3XW8eRrk',
        playlistRepo: playlistRepo,
      );

      expect(result.playlistTitle, 'My Super Mix');
      expect(result.matchedCount, 2);
      expect(result.songs.length, 2);
      expect(result.songs[0].title, contains('Tum Hi Ho'));
      expect(result.songs[1].title, contains('Raabta'));

      await db.close();
    });

    test('syncPlaylist safely truncates titles longer than 100 characters and saves to database', () async {
      final longTitle = 'Top 100 Bollywood Romantic Songs 2024 - Arijit Singh, Atif Aslam, Neha Kakkar, Jubin Nautiyal, B Praak | Best Hindi Hits Songs 2024 Official Playlist';
      expect(longTitle.length, greaterThan(100));

      final mockMixData = {
        'contents': {
          'twoColumnWatchNextResults': {
            'playlist': {
              'playlist': {
                'title': longTitle,
                'contents': [
                  {
                    'playlistPanelVideoRenderer': {
                      'videoId': 'long_001',
                      'title': {'simpleText': 'Apna Bana Le | Bhediya'},
                      'shortBylineText': {
                        'runs': [{'text': 'Arijit Singh'}]
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockMixData), 200, headers: {'content-type': 'application/json'});
      });

      final db = AppDatabase.memory();
      final playlistRepo = PlaylistRepositoryImpl(db);
      final syncService = YouTubeSyncService(client: mockClient);

      final result = await syncService.syncPlaylist(
        input: 'https://www.youtube.com/watch?v=Emm3XW8eRrk&list=RDMMEmm3XW8eRrk',
        playlistRepo: playlistRepo,
      );

      // Verify that title is <= 95 characters and contains ellipsis
      expect(result.playlistTitle.length, lessThanOrEqualTo(95));
      expect(result.playlistTitle, endsWith('...'));

      // Verify that playlist saved successfully in database without throwing
      final savedPlaylists = await playlistRepo.getPlaylists();
      expect(savedPlaylists.length, 1);
      expect(savedPlaylists[0].name.length, lessThanOrEqualTo(100));
      expect(savedPlaylists[0].name, result.playlistTitle);

      await db.close();
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/database/database_providers.dart';
import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/models/album.dart';
import 'package:melo/shared/models/artist.dart';
import 'package:melo/shared/models/playlist.dart';
import 'package:melo/shared/models/song.dart';

/// Provides Quick Picks for the Home Screen aligned with user preferences.
final quickPicksProvider = Provider<List<Song>>((ref) {
  final prefs = ref.watch(userPreferencesNotifierProvider);
  final preferredArtists = prefs.preferredArtists.map((a) => a.toLowerCase()).toSet();

  // If user has preferred artists, surface tracks from those artists in Quick Picks
  final matchingHits = indianCuratedCatalog.where(
    (s) => preferredArtists.contains(s.artist.toLowerCase()),
  ).toList();

  if (matchingHits.isNotEmpty) {
    return [
      ...matchingHits,
      ...indianCuratedCatalog.where((s) => !preferredArtists.contains(s.artist.toLowerCase())),
      ...MockCatalog.songs,
    ].take(6).toList();
  }

  return [
    ...indianCuratedCatalog.take(4),
    ...MockCatalog.songs.take(2),
  ];
});

/// Provides Continue Listening track.
final continueListeningProvider = Provider<Song?>((ref) {
  return indianCuratedCatalog.isNotEmpty ? indianCuratedCatalog[0] : MockCatalog.songs[0];
});

/// Provides Trending Now music tracks.
final trendingSongsProvider = Provider<List<Song>>((ref) {
  return [
    MockCatalog.songs[0],
    indianCuratedCatalog[0], // Kesariya
    indianCuratedCatalog[2], // Cheques
    indianCuratedCatalog[3], // 295
    indianCuratedCatalog[1], // Desi Kalakaar
    indianCuratedCatalog[4], // Softly
  ];
});

/// Provides Chill / Lo-Fi genre tracks.
final chillLoFiProvider = Provider<List<Song>>((ref) {
  return MockCatalog.songs
      .where(
        (s) =>
            s.genre == 'Lo-Fi Chill' ||
            s.genre == 'Chillstep' ||
            s.genre == 'Ambient',
      )
      .toList();
});

/// Provides Fresh Discoveries tracks.
final freshDiscoveriesProvider = Provider<List<Song>>((ref) {
  return [
    ...indianCuratedCatalog.reversed.take(4),
    ...MockCatalog.songs.reversed.take(4),
  ];
});

/// Authentic curated catalog of popular Indian & regional hit songs across Hindi, Punjabi, Bhojpuri, Haryanvi, Tamil, and Retro.
const List<Song> indianCuratedCatalog = [
  Song(
    id: 'saavn:kesariya_01',
    title: 'Kesariya',
    artist: 'Arijit Singh',
    album: 'Brahmastra',
    artworkUrl: 'https://c.saavncdn.com/191/Kesariya-From-Brahmastra-Hindi-2022-20220717092820-500x500.jpg',
    duration: Duration(minutes: 4, seconds: 28),
    isDownloadable: true,
    provider: 'saavn',
    genre: 'Bollywood Romantic',
  ),
  Song(
    id: 'saavn:desi_kalakaar_02',
    title: 'Desi Kalakaar',
    artist: 'Yo Yo Honey Singh',
    album: 'Desi Kalakaar',
    artworkUrl: 'https://c.saavncdn.com/152/Desi-Kalakaar-Hindi-2014-500x500.jpg',
    duration: Duration(minutes: 4, seconds: 18),
    isDownloadable: true,
    provider: 'saavn',
    genre: 'Desi Hip-Hop',
  ),
  Song(
    id: 'saavn:cheques_03',
    title: 'Cheques',
    artist: 'Shubh',
    album: 'Still Rollin',
    artworkUrl: 'https://c.saavncdn.com/044/Still-Rollin-Punjabi-2023-20230519141018-500x500.jpg',
    duration: Duration(minutes: 3, seconds: 3),
    isDownloadable: true,
    provider: 'saavn',
    genre: 'Punjabi Wave',
  ),
  Song(
    id: 'saavn:295_04',
    title: '295',
    artist: 'Sidhu Moose Wala',
    album: 'Moosetape',
    artworkUrl: 'https://c.saavncdn.com/409/Moosetape-Punjabi-2021-20210514120344-500x500.jpg',
    duration: Duration(minutes: 4, seconds: 30),
    isDownloadable: true,
    provider: 'saavn',
    genre: 'Punjabi Hip-Hop',
  ),
  Song(
    id: 'saavn:softly_05',
    title: 'Softly',
    artist: 'Karan Aujla',
    album: 'Making Memories',
    artworkUrl: 'https://c.saavncdn.com/264/Making-Memories-Punjabi-2023-20230818165509-500x500.jpg',
    duration: Duration(minutes: 2, seconds: 36),
    isDownloadable: true,
    provider: 'saavn',
    genre: 'Punjabi Pop',
  ),
  Song(
    id: 'saavn:lover_06',
    title: 'Lover',
    artist: 'Diljit Dosanjh',
    album: 'MoonChild Era',
    artworkUrl: 'https://c.saavncdn.com/791/MoonChild-Era-Punjabi-2021-20210822180808-500x500.jpg',
    duration: Duration(minutes: 3, seconds: 2),
    isDownloadable: true,
    provider: 'saavn',
    genre: 'Punjabi Pop',
  ),
  Song(
    id: 'saavn:lollypop_07',
    title: 'Lollypop Lagelu',
    artist: 'Pawan Singh',
    album: 'Lollypop Lagelu',
    artworkUrl: 'https://c.saavncdn.com/219/Lollipop-Lagelu-Bhojpuri-2008-500x500.jpg',
    duration: Duration(minutes: 4, seconds: 12),
    isDownloadable: true,
    provider: 'saavn',
    genre: 'Bhojpuri Hits',
  ),
  Song(
    id: 'saavn:badmashi_08',
    title: 'Badmashi Ka Rog',
    artist: 'Masoom Sharma',
    album: 'Badmashi Ka Rog',
    artworkUrl: 'https://c.saavncdn.com/123/Badmashi-Ka-Rog-Haryanvi-2022-500x500.jpg',
    duration: Duration(minutes: 3, seconds: 15),
    isDownloadable: true,
    provider: 'saavn',
    genre: 'Haryanvi Ragni',
  ),
  Song(
    id: 'saavn:pal_pal_09',
    title: 'Pal Pal Dil Ke Paas',
    artist: 'Kishore Kumar',
    album: 'Blackmail',
    artworkUrl: 'https://c.saavncdn.com/391/Blackmail-Hindi-1973-500x500.jpg',
    duration: Duration(minutes: 5, seconds: 28),
    isDownloadable: true,
    provider: 'saavn',
    genre: 'Retro Classics',
  ),
  Song(
    id: 'saavn:hukum_10',
    title: 'Hukum - Thalaivar Alappara',
    artist: 'Anirudh Ravichander',
    album: 'Jailer',
    artworkUrl: 'https://c.saavncdn.com/188/Jailer-Tamil-2023-20230728183020-500x500.jpg',
    duration: Duration(minutes: 3, seconds: 26),
    isDownloadable: true,
    provider: 'saavn',
    genre: 'Tamil Rock',
  ),
];

/// Provides Indian & Regional music tracks (Bollywood, Punjabi, Bhojpuri, Haryanvi, Retro).
final indianHitsProvider = Provider<List<Song>>((ref) {
  return indianCuratedCatalog;
});

/// Provides featured albums.
final featuredAlbumsProvider = Provider<List<Album>>((ref) {
  return MockCatalog.albums;
});

/// Provides featured artists dynamically personalized according to user selections.
final featuredArtistsProvider = Provider<List<Artist>>((ref) {
  final prefs = ref.watch(userPreferencesNotifierProvider);
  final preferredNames = prefs.preferredArtists;

  const defaultArtists = [
    Artist(id: 'art_arijit', name: 'Arijit Singh', genre: 'Bollywood Romantic', avatarUrl: '', monthlyListeners: 42500000),
    Artist(id: 'art_honey', name: 'Yo Yo Honey Singh', genre: 'Desi Hip-Hop / Party', avatarUrl: '', monthlyListeners: 18900000),
    Artist(id: 'art_shubh', name: 'Shubh', genre: 'Punjabi Wave / Trap', avatarUrl: '', monthlyListeners: 14200000),
    Artist(id: 'art_sidhu', name: 'Sidhu Moose Wala', genre: 'Punjabi Gangsta Rap', avatarUrl: '', monthlyListeners: 22800000),
    Artist(id: 'art_diljit', name: 'Diljit Dosanjh', genre: 'Punjabi Pop / Folk', avatarUrl: '', monthlyListeners: 21400000),
    Artist(id: 'art_karan', name: 'Karan Aujla', genre: 'Contemporary Punjabi', avatarUrl: '', monthlyListeners: 19800000),
    Artist(id: 'art_badshah', name: 'Badshah', genre: 'Commercial Hip-Hop', avatarUrl: '', monthlyListeners: 16500000),
    Artist(id: 'art_pawan', name: 'Pawan Singh', genre: 'Bhojpuri Superstar', avatarUrl: '', monthlyListeners: 9800000),
    Artist(id: 'art_masoom', name: 'Masoom Sharma', genre: 'Haryanvi Ragni / Beat', avatarUrl: '', monthlyListeners: 6200000),
    Artist(id: 'art_kishore', name: 'Kishore Kumar', genre: 'Golden Era Retro', avatarUrl: '', monthlyListeners: 11200000),
    Artist(id: 'art_anirudh', name: 'Anirudh Ravichander', genre: 'Tamil Rock / Pan-India', avatarUrl: '', monthlyListeners: 26000000),
    Artist(id: 'art_weeknd', name: 'The Weeknd', genre: 'Synthpop / Dark R&B', avatarUrl: '', monthlyListeners: 108000000),
    Artist(id: 'art_eminem', name: 'Eminem', genre: 'Classic Rap / Hip-Hop', avatarUrl: '', monthlyListeners: 68000000),
  ];

  final prioritized = <Artist>[];
  for (final name in preferredNames) {
    final match = defaultArtists.where((a) => a.name.toLowerCase() == name.toLowerCase());
    if (match.isNotEmpty) {
      prioritized.add(match.first);
    } else {
      prioritized.add(Artist(
        id: 'art_${name.hashCode.abs()}',
        name: name,
        genre: 'Your Pick',
        avatarUrl: '',
        monthlyListeners: 8000000,
      ));
    }
  }

  for (final a in defaultArtists) {
    if (!prioritized.any((p) => p.name.toLowerCase() == a.name.toLowerCase())) {
      prioritized.add(a);
    }
  }

  return prioritized;
});

/// Provides curated playlists.
final curatedPlaylistsProvider = Provider<List<Playlist>>((ref) {
  return MockCatalog.playlists;
});

/// Backward compatibility provider for tests.
final recentlyPlayedProvider = quickPicksProvider;
final recommendedSongsProvider = freshDiscoveriesProvider;

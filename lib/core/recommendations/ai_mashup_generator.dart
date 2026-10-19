import 'dart:math';
import 'package:flutter/material.dart';
import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/models/playlist.dart';
import 'package:melo/shared/models/song.dart';

/// Data model representing a generated AI Mashup / Spotify Blend playlist.
class AiMashupResult {
  final String title;
  final String description;
  final int synergyScore;
  final List<Song> songs;
  final List<Color> gradientColors;
  final String firstEntity;
  final String secondEntity;
  final List<String> vibeTags;

  const AiMashupResult({
    required this.title,
    required this.description,
    required this.synergyScore,
    required this.songs,
    required this.gradientColors,
    required this.firstEntity,
    required this.secondEntity,
    required this.vibeTags,
  });

  Playlist toPlaylist() {
    return Playlist(
      id: 'ai-mashup-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      badge: 'AI MASHUP',
      description: '$description • $synergyScore% Blend Match',
      artworkUrl: songs.isNotEmpty ? songs.first.artworkUrl : '',
      songs: songs,
      isCurated: false,
      creator: 'Melo AI Blend Studio',
    );
  }
}

/// Spotify-style AI Mashup & Blend generator.
class AiMashupGenerator {
  /// Preset iconic mashup recipe pairs.
  static const List<Map<String, dynamic>> presetMashups = [
    {
      'name': 'Honey Singh × Shubh',
      'entityA': 'Yo Yo Honey Singh',
      'entityB': 'Shubh',
      'type': 'artist',
      'tagline': 'Urban Desi Rap Royalty meets Flow Phenomenon',
      'colors': [Color(0xFFE11D48), Color(0xFFF59E0B)],
      'tags': ['Punjabi Pop', 'Hip Hop', 'Party Bass'],
    },
    {
      'name': 'Sidhu Moose Wala × Diljit Dosanjh',
      'entityA': 'Sidhu Moose Wala',
      'entityB': 'Diljit Dosanjh',
      'type': 'artist',
      'tagline': 'Punjab to Global Stadium Anthems',
      'colors': [Color(0xFFEA580C), Color(0xFF6366F1)],
      'tags': ['Folk Rap', 'Global Hits', 'Bhangra'],
    },
    {
      'name': 'Desi Pop × Synthwave',
      'entityA': 'Punjabi Pop',
      'entityB': 'Synthwave',
      'type': 'genre',
      'tagline': 'Neon Retrowave meets Punjabi Dance Beats',
      'colors': [Color(0xFFEC4899), Color(0xFF8B5CF6)],
      'tags': ['Neon Punjab', 'Cyber Beats', 'Retro Flow'],
    },
    {
      'name': 'Lo-Fi Chill × Bollywood Melodies',
      'entityA': 'Lo-Fi Chill',
      'entityB': 'Bollywood Romantic',
      'type': 'genre',
      'tagline': 'Midnight Rain, Warm Chai & Soulful Nostalgia',
      'colors': [Color(0xFF06B6D4), Color(0xFF10B981)],
      'tags': ['Rainy Lo-Fi', 'Warm Soul', 'Arijit & Kishore'],
    },
    {
      'name': 'Kishore Kumar × Arijit Singh',
      'entityA': 'Kishore Kumar',
      'entityB': 'Arijit Singh',
      'type': 'artist',
      'tagline': 'Two Golden Generations of Bollywood Soul',
      'colors': [Color(0xFF9333EA), Color(0xFF3B82F6)],
      'tags': ['Timeless Classics', 'Heartbreak & Joy', 'Acoustic'],
    },
    {
      'name': 'Cyber Techno × High Energy',
      'entityA': 'Techno',
      'entityB': 'Future Bass',
      'type': 'genre',
      'tagline': 'Futuristic Cybernetic Workout & Focus Flow',
      'colors': [Color(0xFF10B981), Color(0xFFF59E0B)],
      'tags': ['High BPM', '140+ Tempo', 'Electrified'],
    },
  ];

  /// Generates a rich, energy-balanced mashup playlist from two artists or vibes.
  static AiMashupResult generateMashup({
    required String entityA,
    required String entityB,
    List<Song>? catalog,
    List<Color>? customColors,
  }) {
    final pool = catalog ?? MockCatalog.songs;
    final lowerA = entityA.toLowerCase().trim();
    final lowerB = entityB.toLowerCase().trim();

    // Helper to extract songs matching query
    List<Song> filterSongs(String keyword) {
      return pool.where((s) {
        final a = s.artist.toLowerCase();
        final g = s.genre?.toLowerCase() ?? '';
        final t = s.title.toLowerCase();
        return a.contains(keyword) || g.contains(keyword) || t.contains(keyword);
      }).toList();
    }

    var listA = filterSongs(lowerA);
    var listB = filterSongs(lowerB);

    // If matches are few, broaden with general genre neighbors
    if (listA.isEmpty) {
      listA = pool.take(10).toList();
    }
    if (listB.isEmpty) {
      listB = pool.skip(10).take(10).toList();
    }

    // Interleave the tracks to create the blend experience (A1, B1, A2, B2...)
    final blendedSongs = <Song>[];
    final seenIds = <String>{};

    final maxLen = max(listA.length, listB.length);
    for (int i = 0; i < maxLen; i++) {
      if (i < listA.length) {
        final sA = listA[i];
        if (!seenIds.contains(sA.id)) {
          seenIds.add(sA.id);
          blendedSongs.add(sA);
        }
      }
      if (i < listB.length) {
        final sB = listB[i];
        if (!seenIds.contains(sB.id)) {
          seenIds.add(sB.id);
          blendedSongs.add(sB);
        }
      }
    }

    // Ensure at least 16 songs in the mashup
    if (blendedSongs.length < 16) {
      for (final song in pool) {
        if (blendedSongs.length >= 18) break;
        if (!seenIds.contains(song.id)) {
          seenIds.add(song.id);
          blendedSongs.add(song);
        }
      }
    }

    // Calculate a deterministic synergy score between 88% and 98%
    final combinedLen = entityA.length + entityB.length;
    final synergy = 88 + (combinedLen % 11);

    final colors = customColors ?? [
      const Color(0xFF6366F1),
      const Color(0xFFEC4899),
    ];

    return AiMashupResult(
      title: '$entityA × $entityB',
      description: 'AI Sonic Mashup blending the rhythm of $entityA and the soundscapes of $entityB',
      synergyScore: synergy,
      songs: blendedSongs,
      gradientColors: colors,
      firstEntity: entityA,
      secondEntity: entityB,
      vibeTags: [
        'AI Blend',
        'Dual Synergy',
        '${blendedSongs.length} Tracks',
      ],
    );
  }

  /// Synthesizes a Personalized AI Playlist from a freeform user mood prompt.
  static Playlist generatePersonalizedMoodPlaylist({
    required String moodPrompt,
    List<Song>? catalog,
  }) {
    final pool = catalog ?? MockCatalog.songs;
    final prompt = moodPrompt.toLowerCase().trim();

    // Scoring songs based on relevance to prompt
    final scored = <MapEntry<Song, double>>[];

    for (final song in pool) {
      double score = 0.0;
      final title = song.title.toLowerCase();
      final artist = song.artist.toLowerCase();
      final genre = song.genre?.toLowerCase() ?? '';

      // Direct word match
      final tokens = prompt.split(RegExp(r'\s+'));
      for (final token in tokens) {
        if (token.isEmpty) continue;
        if (title.contains(token)) score += 3.0;
        if (artist.contains(token)) score += 2.5;
        if (genre.contains(token)) score += 2.0;
      }

      // Mood keyword heuristics
      if (prompt.contains('drive') || prompt.contains('night')) {
        if (genre.contains('synth') || genre.contains('punjabi') || genre.contains('ambient')) score += 2.0;
      }
      if (prompt.contains('gym') || prompt.contains('workout') || prompt.contains('beast') || prompt.contains('energy')) {
        if (genre.contains('techno') || genre.contains('future bass') || genre.contains('punjabi')) score += 2.5;
      }
      if (prompt.contains('chill') || prompt.contains('relax') || prompt.contains('study') || prompt.contains('rain')) {
        if (genre.contains('lo-fi') || genre.contains('ambient') || genre.contains('indie')) score += 2.5;
      }
      if (prompt.contains('romantic') || prompt.contains('love') || prompt.contains('soul')) {
        if (genre.contains('romantic') || artist.contains('arijit') || artist.contains('kishore')) score += 3.0;
      }
      if (prompt.contains('desi') || prompt.contains('party') || prompt.contains('banger')) {
        if (genre.contains('punjabi') || genre.contains('bollywood') || genre.contains('bhojpuri')) score += 3.0;
      }

      scored.add(MapEntry(song, score));
    }

    scored.sort((a, b) => b.value.compareTo(a.value));

    // Take top matching songs
    var selected = scored.where((e) => e.value > 0).map((e) => e.key).toList();

    // If too few songs matched explicitly, supplement with pool to reach 18 tracks
    if (selected.length < 16) {
      final seenIds = selected.map((s) => s.id).toSet();
      for (final song in pool) {
        if (selected.length >= 18) break;
        if (!seenIds.contains(song.id)) {
          seenIds.add(song.id);
          selected.add(song);
        }
      }
    }

    // Capitalize prompt for title
    final cleanTitle = moodPrompt.length > 28
        ? '${moodPrompt.substring(0, 25).trim()}...'
        : moodPrompt;

    return Playlist(
      id: 'ai-custom-${DateTime.now().millisecondsSinceEpoch}',
      title: 'AI Mix: $cleanTitle',
      badge: 'PERSONALIZED AI',
      description: 'Personalized mix crafted for "$moodPrompt" • ${selected.length} tracks',
      artworkUrl: selected.isNotEmpty ? selected.first.artworkUrl : '',
      songs: selected,
      isCurated: false,
      creator: 'Melo Personalized AI',
    );
  }
}

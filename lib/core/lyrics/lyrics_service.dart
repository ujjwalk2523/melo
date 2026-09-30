import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'curated_lyrics.dart';
import 'lyrics_model.dart';
import 'lyrics_parser.dart';

/// Service for fetching real-time synced and plain lyrics from open LRCLIB database and curated catalog.
class LyricsService {
  final http.Client _client;
  final Map<String, TrackLyrics> _cache = {};

  static const String _userAgent = 'MeloMusicApp/1.0.0 (https://github.com/ujjwal/melo)';
  static const Duration _timeout = Duration(seconds: 4);

  LyricsService({http.Client? client}) : _client = client ?? http.Client();

  /// Retrieves lyrics for a song given title and artist.
  /// 1. Checks curated catalog for instant high-fidelity synced lyrics.
  /// 2. Queries open LRCLIB database for millions of community synced lyrics.
  /// 3. Falls back to dynamic rhythmic synced lyrics so no song ever lacks karaoke lyrics.
  Future<TrackLyrics> getLyrics({
    required String trackTitle,
    required String artist,
    Duration? duration,
  }) async {
    final cacheKey = '${trackTitle.toLowerCase().trim()}::${artist.toLowerCase().trim()}';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final cleanTitle = _sanitizeTitle(trackTitle);
    final cleanArtist = _sanitizeArtist(artist);

    // 1. Check curated catalog for instant synced lyrics
    final curated = CuratedLyrics.findCurated(cleanTitle, cleanArtist);
    if (curated != null && curated.hasLyrics) {
      _cache[cacheKey] = curated;
      return curated;
    }

    // 2. Try exact match from LRCLIB
    try {
      final queryParams = {
        'track_name': cleanTitle,
        'artist_name': cleanArtist,
        if (duration != null && duration.inSeconds > 0)
          'duration': duration.inSeconds.toString(),
      };

      final uri = Uri.https('lrclib.net', '/api/get', queryParams);
      final response = await _client
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lyrics = _parseApiResponse(data);
        if (lyrics.hasLyrics) {
          _cache[cacheKey] = lyrics;
          return lyrics;
        }
      }
    } catch (e) {
      debugPrint('LyricsService exact match error: $e');
    }

    // 3. Fallback to fuzzy search query in LRCLIB
    try {
      final searchUri = Uri.https('lrclib.net', '/api/search', {
        'q': '$cleanTitle $cleanArtist',
      });

      final response = await _client
          .get(searchUri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body);
        if (list is List && list.isNotEmpty) {
          // Look for first result with synced lyrics, otherwise first with plain lyrics
          Map<String, dynamic>? bestMatch;
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              if (item['syncedLyrics'] != null && (item['syncedLyrics'] as String).isNotEmpty) {
                bestMatch = item;
                break;
              }
              bestMatch ??= item;
            }
          }

          if (bestMatch != null) {
            final lyrics = _parseApiResponse(bestMatch);
            if (lyrics.hasLyrics) {
              _cache[cacheKey] = lyrics;
              return lyrics;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('LyricsService fuzzy search error: $e');
    }

    // 4. Final resilient fallback: dynamic rhythmic synced lyrics
    final dynamicLyrics = CuratedLyrics.generateDynamicLyrics(cleanTitle, cleanArtist);
    _cache[cacheKey] = dynamicLyrics;
    return dynamicLyrics;
  }

  TrackLyrics _parseApiResponse(Map<String, dynamic> data) {
    final synced = data['syncedLyrics'] as String?;
    final plain = data['plainLyrics'] as String?;

    if (synced != null && synced.trim().isNotEmpty) {
      final lines = LyricsParser.parseLrc(synced);
      if (lines.isNotEmpty) {
        return TrackLyrics(
          syncedLyrics: synced,
          plainLyrics: plain,
          lines: lines,
          isSynced: true,
        );
      }
    }

    if (plain != null && plain.trim().isNotEmpty) {
      return TrackLyrics(
        plainLyrics: plain,
        isSynced: false,
      );
    }

    return const TrackLyrics.empty();
  }

  String _sanitizeTitle(String title) {
    var cleaned = title;
    // Remove (From "...") or (Original ...)
    cleaned = cleaned.replaceAll(RegExp(r'\((?:From|Original|From the|Audio).*?\)', caseSensitive: false), '');
    // Remove feat. or ft.
    cleaned = cleaned.replaceAll(RegExp(r'\((?:feat\.|ft\.|with).*?\)', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\[.*?\]'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+-\s+.*$'), ''); // remove suffix e.g. " - Single"
    return cleaned.trim();
  }

  String _sanitizeArtist(String artist) {
    var cleaned = artist;
    // If multi-artist separated by comma or feat, take primary artist
    if (cleaned.contains(',')) {
      cleaned = cleaned.split(',').first;
    }
    cleaned = cleaned.replaceAll(RegExp(r'\s+feat\..*$', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s+ft\..*$', caseSensitive: false), '');
    return cleaned.trim();
  }

  void clearCache() {
    _cache.clear();
  }
}

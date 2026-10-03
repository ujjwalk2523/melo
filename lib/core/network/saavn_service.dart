import 'dart:convert';
import 'package:dart_des/dart_des.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saavn_play/saavn_play.dart';

import '../../shared/models/song.dart';

/// Service providing access to 100% free, high-fidelity Indian music streaming
/// covering Hindi (new & retro), Bhojpuri, Punjabi, Haryanvi, and all regional languages.
class SaavnService {
  final SaavnPlayClient _client;
  final Map<String, String> _urlCache = {};

  SaavnService([SaavnPlayClient? client]) : _client = client ?? SaavnPlayClient();

  static const String _desKey = '38346591';

  /// Decrypts a JioSaavn encrypted media token into a direct Akamai CDN audio URL.
  static String? decryptMediaUrl(String? encryptedMediaUrl, {String quality = '_320'}) {
    if (encryptedMediaUrl == null || encryptedMediaUrl.trim().isEmpty) {
      return null;
    }

    try {
      final encrypted = base64Decode(encryptedMediaUrl.trim());
      final decipher = DES(
        key: _desKey.codeUnits,
        mode: DESMode.ECB,
        paddingType: DESPaddingType.PKCS7,
      );
      final decrypted = decipher.decrypt(encrypted);
      final rawUrl = utf8.decode(decrypted);
      return rawUrl.replaceAll('_96', quality);
    } catch (_) {
      return null;
    }
  }

  /// Searches for songs matching [query] and returns normalized, playable [Song] models.
  Future<List<Song>> searchSongs(String query, {int limit = 15}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return const [];

    try {
      final searchRes = await _client.search.songs(cleanQuery);
      final rawResults = (searchRes['results'] as List?) ?? [];
      if (rawResults.isEmpty) return const [];

      final songItems = rawResults.take(limit).cast<Map<String, dynamic>>().toList();
      final songIds = songItems.map((item) => item['id']?.toString() ?? '').where((id) => id.isNotEmpty).toList();

      if (songIds.isEmpty) return const [];

      // Batch fetch song details to acquire encrypted media URLs in one network request
      Map<String, Map<String, dynamic>> detailsMap = {};
      try {
        final detailsResponse = await _client.songs.detailsById(songIds);
        final detailedSongs = (detailsResponse['songs'] as List?) ?? [];
        for (final item in detailedSongs) {
          if (item is Map<String, dynamic>) {
            final id = item['id']?.toString();
            if (id != null) {
              detailsMap[id] = item;
            }
          }
        }
      } catch (_) {
        // Fall back to basic search metadata if batch details lookup fails
      }

      final List<Song> normalizedSongs = [];

      for (final raw in songItems) {
        final id = raw['id']?.toString() ?? '';
        if (id.isEmpty) continue;

        final detailed = detailsMap[id] ?? raw;
        final moreInfo = (detailed['more_info'] as Map<String, dynamic>?) ?? (raw['more_info'] as Map<String, dynamic>?);

        final rawEncryptedUrl = moreInfo?['encrypted_media_url']?.toString();
        String? streamUrl;
        if (rawEncryptedUrl != null && rawEncryptedUrl.isNotEmpty) {
          streamUrl = decryptMediaUrl(rawEncryptedUrl);
          if (streamUrl != null) {
            _urlCache[id] = streamUrl;
            _urlCache['saavn:$id'] = streamUrl;
          }
        } else if (_urlCache.containsKey(id)) {
          streamUrl = _urlCache[id];
        }

        // Clean titles and HTML entities if any
        final rawTitle = (detailed['title'] ?? detailed['name'] ?? raw['title'] ?? raw['name'] ?? 'Unknown Song').toString();
        final title = _unescapeHtml(rawTitle);

        // Artists
        String artist = '';
        final artistMap = moreInfo?['artistMap'] as Map<String, dynamic>?;
        if (artistMap != null && artistMap['primary_artists'] is List) {
          final artistsList = artistMap['primary_artists'] as List;
          artist = artistsList.map((a) => a['name']?.toString() ?? '').where((s) => s.isNotEmpty).join(', ');
        }
        if (artist.isEmpty) {
          final rawSubtitle = (detailed['subtitle'] ?? raw['subtitle'] ?? '').toString();
          if (rawSubtitle.contains(' - ')) {
            artist = rawSubtitle.split(' - ').first;
          } else {
            artist = rawSubtitle;
          }
        }
        if (artist.isEmpty) {
          artist = (moreInfo?['music'] ?? 'Unknown Artist').toString();
        }
        artist = _unescapeHtml(artist);

        // Album
        final rawAlbum = (moreInfo?['album'] ?? detailed['album'] ?? raw['album'] ?? '').toString();
        final album = _unescapeHtml(rawAlbum);

        // Artwork
        String artworkUrl = (detailed['image'] ?? raw['image'] ?? '').toString();
        if (artworkUrl.contains('150x150')) {
          artworkUrl = artworkUrl.replaceAll('150x150', '500x500');
        } else if (artworkUrl.contains('50x50')) {
          artworkUrl = artworkUrl.replaceAll('50x50', '500x500');
        }

        // Duration
        final durationRaw = moreInfo?['duration']?.toString() ?? detailed['duration']?.toString() ?? '180';
        final durationSeconds = int.tryParse(durationRaw) ?? 180;

        // Language / Genre
        final language = (detailed['language'] ?? raw['language'] ?? 'Indian').toString();
        final formattedGenre = language.isNotEmpty ? language[0].toUpperCase() + language.substring(1) : 'Indian';

        // Release Date
        final releaseDateRaw = moreInfo?['release_date']?.toString();
        DateTime? releaseDate;
        if (releaseDateRaw != null) {
          releaseDate = DateTime.tryParse(releaseDateRaw);
        }

        normalizedSongs.add(
          Song(
            id: 'saavn:$id',
            title: title,
            artist: artist,
            album: album,
            artworkUrl: artworkUrl,
            duration: Duration(seconds: durationSeconds),
            streamUrl: streamUrl,
            downloadUrl: streamUrl,
            isDownloadable: streamUrl != null,
            provider: 'saavn',
            genre: formattedGenre,
            releaseDate: releaseDate,
          ),
        );
      }

      return normalizedSongs;
    } catch (e) {
      return const [];
    }
  }

  /// Resolves the direct playable stream URL for a given Saavn track ID.
  Future<String?> resolveStreamUrl(String trackId) async {
    final cleanId = trackId.startsWith('saavn:') ? trackId.substring(6) : trackId;

    if (_urlCache.containsKey(cleanId)) {
      return _urlCache[cleanId];
    }
    if (_urlCache.containsKey('saavn:$cleanId')) {
      return _urlCache['saavn:$cleanId'];
    }

    try {
      final detailsResponse = await _client.songs.detailsById([cleanId]);
      final detailedSongs = (detailsResponse['songs'] as List?) ?? [];
      if (detailedSongs.isNotEmpty && detailedSongs.first is Map<String, dynamic>) {
        final songData = detailedSongs.first as Map<String, dynamic>;
        final moreInfo = songData['more_info'] as Map<String, dynamic>?;
        final rawEncryptedUrl = moreInfo?['encrypted_media_url']?.toString();
        if (rawEncryptedUrl != null && rawEncryptedUrl.isNotEmpty) {
          final url = decryptMediaUrl(rawEncryptedUrl);
          if (url != null) {
            _urlCache[cleanId] = url;
            _urlCache['saavn:$cleanId'] = url;
            return url;
          }
        }
      }
    } catch (_) {}

    return null;
  }

  static String _unescapeHtml(String input) {
    return input
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&#039;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .trim();
  }
}

/// Riverpod provider for [SaavnService].
final saavnServiceProvider = Provider<SaavnService>((ref) {
  return SaavnService();
});

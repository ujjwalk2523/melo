import 'dart:math' as math;
import 'package:melo/core/recommendations/domain/taste_profile.dart';
import 'package:melo/core/recommendations/utils/recommendation_weights.dart';
import 'package:melo/shared/models/song.dart';

/// Extracts user music taste vectors, affinity scores, and behavioral signals.
class FeatureExtractor {
  final RecommendationWeights weights;

  const FeatureExtractor({
    this.weights = const RecommendationWeights(),
  });

  /// Builds a normalized [TasteProfile] from user interaction datasets.
  TasteProfile extractTasteProfile({
    required List<Song> favorites,
    required List<Song> history,
    required List<List<Song>> playlistSongGroups,
    List<Song> downloads = const [],
  }) {
    final totalInteractions =
        favorites.length + history.length + playlistSongGroups.fold(0, (sum, g) => sum + g.length) + downloads.length;

    if (totalInteractions == 0) {
      return TasteProfile.empty();
    }

    final artistScores = <String, double>{};
    final genreScores = <String, double>{};
    final albumScores = <String, double>{};
    final providerCounts = <String, int>{};
    final recentArtists = <String>[];
    final recentGenres = <String>[];

    void addSignal({
      required String artist,
      required String? genre,
      required String album,
      required String provider,
      required double weight,
    }) {
      final cleanArtist = artist.trim();
      final cleanGenre = genre?.trim() ?? '';
      final cleanAlbum = album.trim();

      if (cleanArtist.isNotEmpty) {
        artistScores[cleanArtist] = (artistScores[cleanArtist] ?? 0.0) + weight;
      }
      if (cleanGenre.isNotEmpty) {
        genreScores[cleanGenre] = (genreScores[cleanGenre] ?? 0.0) + weight;
      }
      if (cleanAlbum.isNotEmpty) {
        albumScores[cleanAlbum] = (albumScores[cleanAlbum] ?? 0.0) + weight;
      }
      if (provider.isNotEmpty) {
        providerCounts[provider] = (providerCounts[provider] ?? 0) + 1;
      }
    }

    // 1. Favorites (+5.0)
    for (final song in favorites) {
      addSignal(
        artist: song.artist,
        genre: song.genre,
        album: song.album,
        provider: song.provider,
        weight: weights.favoriteWeight,
      );
    }

    // 2. Playlists (+4.0)
    for (final group in playlistSongGroups) {
      for (final song in group) {
        addSignal(
          artist: song.artist,
          genre: song.genre,
          album: song.album,
          provider: song.provider,
          weight: weights.playlistAddWeight,
        );
      }
    }

    // 3. Downloads (+3.0)
    for (final song in downloads) {
      addSignal(
        artist: song.artist,
        genre: song.genre,
        album: song.album,
        provider: song.provider,
        weight: weights.downloadWeight,
      );
    }

    // 4. Listening History (recency, repeat plays)
    final historySongCounts = <String, int>{};
    for (final song in history) {
      final count = (historySongCounts[song.id] ?? 0) + 1;
      historySongCounts[song.id] = count;

      final isRepeat = count > 1;
      final playWeight = weights.completedPlayWeight + (isRepeat ? weights.repeatPlayWeight : 0.0);

      addSignal(
        artist: song.artist,
        genre: song.genre,
        album: song.album,
        provider: song.provider,
        weight: playWeight,
      );

      final cleanArtist = song.artist.trim();
      final cleanGenre = song.genre?.trim() ?? '';
      if (cleanArtist.isNotEmpty && !recentArtists.contains(cleanArtist)) {
        recentArtists.add(cleanArtist);
      }
      if (cleanGenre.isNotEmpty && !recentGenres.contains(cleanGenre)) {
        recentGenres.add(cleanGenre);
      }
    }

    // Normalize affinity scores to [0.0, 1.0]
    final normalizedArtists = _normalizeScores(artistScores);
    final normalizedGenres = _normalizeScores(genreScores);
    final normalizedAlbums = _normalizeScores(albumScores);

    final sortedProviders = providerCounts.keys.toList()
      ..sort((a, b) => providerCounts[b]!.compareTo(providerCounts[a]!));

    return TasteProfile(
      topArtists: normalizedArtists,
      topGenres: normalizedGenres,
      topAlbums: normalizedAlbums,
      recentArtists: recentArtists.take(10).toList(),
      recentGenres: recentGenres.take(10).toList(),
      favoriteProviders: sortedProviders,
      totalPlays: history.length,
      totalFavorites: favorites.length,
      totalDownloads: downloads.length,
      isColdStart: false,
    );
  }

  Map<String, double> _normalizeScores(Map<String, double> rawScores) {
    if (rawScores.isEmpty) return const {};
    final maxVal = rawScores.values.fold<double>(0.0, (m, v) => math.max(m, v));
    if (maxVal <= 0.0) return const {};

    final normalized = <String, double>{};
    for (final entry in rawScores.entries) {
      normalized[entry.key] = (entry.value / maxVal).clamp(0.0, 1.0);
    }
    return normalized;
  }
}

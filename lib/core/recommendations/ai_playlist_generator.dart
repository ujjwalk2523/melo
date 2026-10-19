import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/models/playlist.dart';
import 'package:melo/shared/models/song.dart';

/// Intelligent recommendation engine synthesizing real-time Spotify-style
/// AI Daily Mixes, Artist Radios, and Search-reactive playlist flows.
class AiPlaylistGenerator {
  /// Generates dynamic playlists based on user's recent listening history,
  /// recent search queries, and catalog tracks.
  static List<Playlist> generatePlaylists({
    required List<Song> recentTracks,
    required List<String> recentSearches,
    required List<Song> favorites,
    List<Song>? allCatalogSongs,
  }) {
    final catalog = allCatalogSongs ?? MockCatalog.songs;
    final List<Playlist> playlists = [];

    // 1. Determine User Affinity Profile
    final searchTerms = recentSearches.map((s) => s.toLowerCase().trim()).toList();

    // Helper to find catalog songs matching query/artist/genre
    List<Song> findByArtist(String artistKeyword) {
      final lower = artistKeyword.toLowerCase();
      return catalog.where((s) {
        return s.artist.toLowerCase().contains(lower) ||
            s.title.toLowerCase().contains(lower);
      }).toList();
    }

    List<Song> findByGenre(List<String> genres) {
      final lowerGenres = genres.map((g) => g.toLowerCase()).toSet();
      return catalog.where((s) {
        final g = s.genre?.toLowerCase() ?? '';
        return lowerGenres.any((lg) => g.contains(lg));
      }).toList();
    }

    // Helper ensuring every generated AI playlist has at least 15-20 tracks
    List<Song> ensurePlaylistDepth(List<Song> seedSongs, List<String> fallbackGenres, {int minCount = 16}) {
      final result = <Song>[...seedSongs];
      final seenIds = result.map((s) => s.id).toSet();

      // 1. First add songs from fallback genres
      final genreMatches = findByGenre(fallbackGenres);
      for (final song in genreMatches) {
        if (result.length >= minCount) break;
        if (!seenIds.contains(song.id)) {
          seenIds.add(song.id);
          result.add(song);
        }
      }

      // 2. If still below minCount, add any non-conflicting catalog tracks
      if (result.length < minCount) {
        for (final song in catalog) {
          if (result.length >= minCount) break;
          if (!seenIds.contains(song.id)) {
            seenIds.add(song.id);
            result.add(song);
          }
        }
      }

      return result;
    }

    // -----------------------------------------------------------------------
    // MIX 1: Desi & Punjabi Pop Daily Mix (Honey Singh, Shubh, Sidhu, Diljit)
    // -----------------------------------------------------------------------
    final desiSeed = catalog.where((s) {
      final g = s.genre?.toLowerCase() ?? '';
      final a = s.artist.toLowerCase();
      return s.provider == 'saavn' ||
          g.contains('punjabi') ||
          g.contains('bollywood') ||
          a.contains('honey singh') ||
          a.contains('shubh') ||
          a.contains('sidhu') ||
          a.contains('diljit') ||
          a.contains('karan aujla') ||
          a.contains('dhillon');
    }).toList();

    final desiSongs = ensurePlaylistDepth(
      desiSeed,
      ['punjabi pop', 'punjabi', 'bollywood', 'hip hop'],
      minCount: 18,
    );

    if (desiSongs.isNotEmpty) {
      final artists = desiSongs.map((s) => s.artist.split(',').first.trim()).toSet().take(4).join(', ');
      playlists.add(
        Playlist(
          id: 'ai-daily-mix-1',
          title: 'Daily Mix 1',
          badge: 'DAILY MIX',
          description: '$artists and more • ${desiSongs.length} tracks',
          artworkUrl: desiSongs.first.artworkUrl,
          songs: desiSongs,
          isCurated: true,
          creator: 'Made For You • Melo AI',
        ),
      );
    }

    // -----------------------------------------------------------------------
    // MIX 2: Top Search / Top Listened Artist Mix (e.g. "Yo Yo Honey Singh Mix")
    // -----------------------------------------------------------------------
    String? topArtistCandidate;
    // Check recent searches first
    for (final search in searchTerms) {
      final matches = findByArtist(search);
      if (matches.isNotEmpty) {
        topArtistCandidate = matches.first.artist.split(',').first.trim();
        break;
      }
    }
    // Fallback to recent tracks artist
    if (topArtistCandidate == null && recentTracks.isNotEmpty) {
      topArtistCandidate = recentTracks.first.artist.split(',').first.trim();
    }
    // Default fallback
    topArtistCandidate ??= 'Yo Yo Honey Singh';

    final artistSongs = catalog.where((s) {
      return s.artist.toLowerCase().contains(topArtistCandidate!.toLowerCase());
    }).toList();

    final fullArtistMixSongs = ensurePlaylistDepth(
      artistSongs,
      ['punjabi pop', 'bollywood', 'pop', 'hip hop'],
      minCount: 16,
    );

    if (fullArtistMixSongs.isNotEmpty) {
      final otherArtists = fullArtistMixSongs
          .where((s) => !s.artist.toLowerCase().contains(topArtistCandidate!.toLowerCase()))
          .map((s) => s.artist.split(',').first.trim())
          .toSet()
          .take(3)
          .join(', ');

      final desc = otherArtists.isNotEmpty
          ? 'With $topArtistCandidate, $otherArtists • ${fullArtistMixSongs.length} tracks'
          : 'Essential hits and journey of $topArtistCandidate • ${fullArtistMixSongs.length} tracks';

      playlists.add(
        Playlist(
          id: 'ai-artist-mix-${topArtistCandidate.toLowerCase().replaceAll(' ', '-')}',
          title: '$topArtistCandidate Mix',
          badge: 'ARTIST MIX',
          description: desc,
          artworkUrl: fullArtistMixSongs.first.artworkUrl,
          songs: fullArtistMixSongs,
          isCurated: true,
          creator: 'Made For You • Melo AI',
        ),
      );
    }

    // -----------------------------------------------------------------------
    // MIX 3: Cyberpunk, Synthwave & High Energy (Daily Mix 2)
    // -----------------------------------------------------------------------
    final electronicSeed = findByGenre(['synthwave', 'techno', 'electronic', 'future bass']);
    final electronicSongs = ensurePlaylistDepth(
      electronicSeed,
      ['synthwave', 'techno', 'future bass', 'electronic'],
      minCount: 16,
    );

    if (electronicSongs.isNotEmpty) {
      final topArtists = electronicSongs.map((s) => s.artist).toSet().take(3).join(', ');
      playlists.add(
        Playlist(
          id: 'ai-daily-mix-2',
          title: 'Daily Mix 2',
          badge: 'DAILY MIX',
          description: '$topArtists and more • ${electronicSongs.length} tracks',
          artworkUrl: electronicSongs.first.artworkUrl,
          songs: electronicSongs,
          isCurated: true,
          creator: 'Made For You • Melo AI',
        ),
      );
    }

    // -----------------------------------------------------------------------
    // MIX 4: Chill Lo-Fi & Atmospheric Beats (Daily Mix 3)
    // -----------------------------------------------------------------------
    final chillSeed = findByGenre(['lo-fi chill', 'chillstep', 'ambient', 'indie folk']);
    final chillSongs = ensurePlaylistDepth(
      chillSeed,
      ['lo-fi chill', 'chillstep', 'ambient', 'indie folk'],
      minCount: 16,
    );

    if (chillSongs.isNotEmpty) {
      final topArtists = chillSongs.map((s) => s.artist).toSet().take(3).join(', ');
      playlists.add(
        Playlist(
          id: 'ai-daily-mix-3',
          title: 'Daily Mix 3',
          badge: 'DAILY MIX',
          description: '$topArtists and more • ${chillSongs.length} tracks',
          artworkUrl: chillSongs.first.artworkUrl,
          songs: chillSongs,
          isCurated: true,
          creator: 'Made For You • Melo AI',
        ),
      );
    }

    // -----------------------------------------------------------------------
    // MIX 5: Bollywood Romantic & Soulful Ballads (Daily Mix 4)
    // -----------------------------------------------------------------------
    final romanticSeed = catalog.where((s) {
      final g = s.genre?.toLowerCase() ?? '';
      final a = s.artist.toLowerCase();
      return g.contains('romantic') ||
          a.contains('arijit') ||
          a.contains('pritam') ||
          s.title.toLowerCase().contains('kesariya') ||
          s.title.toLowerCase().contains('tum hi ho') ||
          s.title.toLowerCase().contains('channa') ||
          s.title.toLowerCase().contains('lover');
    }).toList();

    final romanticSongs = ensurePlaylistDepth(
      romanticSeed,
      ['bollywood romantic', 'bollywood', 'retro classics'],
      minCount: 16,
    );

    if (romanticSongs.isNotEmpty) {
      final topArtists = romanticSongs.map((s) => s.artist.split(',').first.trim()).toSet().take(3).join(', ');
      playlists.add(
        Playlist(
          id: 'ai-daily-mix-4',
          title: 'Daily Mix 4',
          badge: 'DAILY MIX',
          description: '$topArtists and more • ${romanticSongs.length} tracks',
          artworkUrl: romanticSongs.first.artworkUrl,
          songs: romanticSongs,
          isCurated: true,
          creator: 'Made For You • Melo AI',
        ),
      );
    }

    // -----------------------------------------------------------------------
    // MIX 6: Retro Bollywood & Regional Classics
    // -----------------------------------------------------------------------
    final retroSeed = catalog.where((s) {
      final g = s.genre?.toLowerCase() ?? '';
      final a = s.artist.toLowerCase();
      return g.contains('retro') ||
          g.contains('bhojpuri') ||
          g.contains('haryanvi') ||
          a.contains('kishore') ||
          a.contains('pawan') ||
          a.contains('masoom');
    }).toList();

    final retroSongs = ensurePlaylistDepth(
      retroSeed,
      ['retro classics', 'bhojpuri', 'haryanvi', 'bollywood'],
      minCount: 15,
    );

    if (retroSongs.isNotEmpty) {
      playlists.add(
        Playlist(
          id: 'ai-daily-mix-retro',
          title: 'Daily Mix: Desi Classics',
          badge: 'RETRO & REGIONAL',
          description: 'Kishore Kumar, Pawan Singh, Masoom Sharma • ${retroSongs.length} tracks',
          artworkUrl: retroSongs.first.artworkUrl,
          songs: retroSongs,
          isCurated: true,
          creator: 'Made For You • Melo AI',
        ),
      );
    }

    // -----------------------------------------------------------------------
    // MIX 7: Real-Time Search & Listening AI Flow
    // -----------------------------------------------------------------------
    if (recentSearches.isNotEmpty) {
      final latestSearch = recentSearches.first;
      final searchMatches = catalog.where((s) {
        final query = latestSearch.toLowerCase();
        return s.title.toLowerCase().contains(query) ||
            s.artist.toLowerCase().contains(query) ||
            (s.genre?.toLowerCase().contains(query) ?? false);
      }).toList();

      if (searchMatches.isNotEmpty) {
        final flowSongs = ensurePlaylistDepth(
          searchMatches,
          ['punjabi pop', 'bollywood', 'lo-fi chill', 'synthwave'],
          minCount: 16,
        );

        playlists.add(
          Playlist(
            id: 'ai-flow-latest-search',
            title: 'AI Flow: $latestSearch',
            badge: 'AI GENERATED',
            description: 'Dynamically synthesized for "$latestSearch" • ${flowSongs.length} tracks',
            artworkUrl: flowSongs.first.artworkUrl,
            songs: flowSongs,
            isCurated: false,
            creator: 'Melo Real-Time AI Flow',
          ),
        );
      }
    } else if (recentTracks.isNotEmpty) {
      final lastPlayed = recentTracks.first;
      final similar = catalog.where((s) =>
          s.id != lastPlayed.id &&
          (s.artist == lastPlayed.artist || s.genre == lastPlayed.genre)
      ).take(5).toList();

      final flowSongs = [lastPlayed, ...similar];
      playlists.add(
        Playlist(
          id: 'ai-flow-track-radio',
          title: '${lastPlayed.title} Radio',
          badge: 'AI GENERATED',
          description: 'Tracks inspired by your listening session with ${lastPlayed.title}',
          artworkUrl: lastPlayed.artworkUrl,
          songs: flowSongs,
          isCurated: false,
          creator: 'Melo Real-Time AI Flow',
        ),
      );
    }

    return playlists;
  }
}

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

    // -----------------------------------------------------------------------
    // MIX 1: Desi & Punjabi Pop Daily Mix (Honey Singh, Shubh, Sidhu)
    // -----------------------------------------------------------------------
    final desiSongs = catalog.where((s) {
      final g = s.genre?.toLowerCase() ?? '';
      final a = s.artist.toLowerCase();
      return s.provider == 'saavn' ||
          g.contains('punjabi') ||
          g.contains('bollywood') ||
          a.contains('honey singh') ||
          a.contains('shubh') ||
          a.contains('sidhu');
    }).toList();

    if (desiSongs.isNotEmpty) {
      final artists = desiSongs.map((s) => s.artist.split(',').first.trim()).toSet().take(3).join(', ');
      playlists.add(
        Playlist(
          id: 'ai-daily-mix-1',
          title: 'Daily Mix 1',
          badge: 'DAILY MIX',
          description: '$artists and more',
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

    // Supplement with closely aligned genre matches so the playlist is complete
    final candidateGenre = artistSongs.isNotEmpty ? artistSongs.first.genre : null;
    final alignedSongs = catalog.where((s) {
      final sameGenre = candidateGenre != null && s.genre == candidateGenre;
      final sameArtist = s.artist.toLowerCase().contains(topArtistCandidate!.toLowerCase());
      return sameGenre && !sameArtist;
    }).take(4).toList();

    final fullArtistMixSongs = [...artistSongs, ...alignedSongs];
    if (fullArtistMixSongs.isNotEmpty) {
      final relatedNames = alignedSongs.map((s) => s.artist.split(',').first.trim()).toSet().take(2).join(', ');
      final desc = relatedNames.isNotEmpty
          ? 'With $topArtistCandidate, $relatedNames and more'
          : 'The essential hits and sonic journey of $topArtistCandidate';

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
    final electronicSongs = findByGenre(['synthwave', 'techno', 'electronic', 'future bass']);
    if (electronicSongs.isNotEmpty) {
      final topArtists = electronicSongs.map((s) => s.artist).toSet().take(3).join(', ');
      playlists.add(
        Playlist(
          id: 'ai-daily-mix-2',
          title: 'Daily Mix 2',
          badge: 'DAILY MIX',
          description: '$topArtists and more',
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
    final chillSongs = findByGenre(['lo-fi chill', 'chillstep', 'ambient', 'indie folk']);
    if (chillSongs.isNotEmpty) {
      final topArtists = chillSongs.map((s) => s.artist).toSet().take(3).join(', ');
      playlists.add(
        Playlist(
          id: 'ai-daily-mix-3',
          title: 'Daily Mix 3',
          badge: 'DAILY MIX',
          description: '$topArtists and more',
          artworkUrl: chillSongs.first.artworkUrl,
          songs: chillSongs,
          isCurated: true,
          creator: 'Made For You • Melo AI',
        ),
      );
    }

    // -----------------------------------------------------------------------
    // MIX 5: Real-Time Search & Listening AI Flow
    // Reacts instantly to the latest active search or last played track!
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
        // Broaden with related songs from the same genre
        final primaryGenre = searchMatches.first.genre;
        final related = catalog.where((s) =>
            s.genre == primaryGenre &&
            !searchMatches.any((m) => m.id == s.id)
        ).take(3).toList();

        final flowSongs = [...searchMatches, ...related];
        playlists.add(
          Playlist(
            id: 'ai-flow-latest-search',
            title: 'AI Flow: $latestSearch',
            badge: 'AI GENERATED',
            description: 'Real-time mix dynamically synthesized for "$latestSearch"',
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

    // -----------------------------------------------------------------------
    // MIX 6: Retro Bollywood & Regional Classics
    // -----------------------------------------------------------------------
    final retroSongs = catalog.where((s) {
      final g = s.genre?.toLowerCase() ?? '';
      final a = s.artist.toLowerCase();
      return g.contains('retro') ||
          g.contains('bhojpuri') ||
          g.contains('haryanvi') ||
          a.contains('kishore') ||
          a.contains('pawan') ||
          a.contains('ajay');
    }).toList();

    if (retroSongs.isNotEmpty) {
      playlists.add(
        Playlist(
          id: 'ai-daily-mix-retro',
          title: 'Daily Mix: Desi Classics',
          badge: 'RETRO & REGIONAL',
          description: 'Kishore Kumar, Pawan Singh, Ajay Hooda and more',
          artworkUrl: retroSongs.first.artworkUrl,
          songs: retroSongs,
          isCurated: true,
          creator: 'Made For You • Melo AI',
        ),
      );
    }

    return playlists;
  }
}

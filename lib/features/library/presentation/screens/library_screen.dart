import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/database/database_providers.dart';
import 'package:melo/core/downloads/download_providers.dart';
import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/features/playlists/domain/playlist_models.dart' as domain;
import 'package:melo/features/playlists/presentation/widgets/ai_mashup_dialog.dart';
import 'package:melo/features/playlists/presentation/widgets/ai_playlist_creator_dialog.dart';
import 'package:melo/features/playlists/presentation/widgets/playlist_detail_sheet.dart';
import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/models/playlist.dart' as shared;
import 'package:melo/shared/models/song.dart';
import 'package:melo/shared/widgets/album_card.dart';
import 'package:melo/shared/widgets/aura_artwork.dart';
import 'package:melo/shared/widgets/empty_state.dart';
import 'package:melo/features/home/providers/home_provider.dart';
import 'package:melo/features/onboarding/presentation/screens/onboarding_taste_screen.dart';
import 'package:melo/features/playlists/presentation/widgets/youtube_sync_dialog.dart';
import 'package:melo/shared/widgets/artist_detail_sheet.dart';
import 'package:melo/shared/widgets/section_header.dart';
import 'package:melo/shared/widgets/song_tile.dart';

/// Primary Library screen managing playlists, favorites, offline downloads, artists, and albums.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = [
    'All',
    'Liked Songs',
    'Playlists',
    'Downloads',
    'Artists',
    'Albums',
  ];

  void _showCreatePlaylistDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLg,
        ),
        title: const Text(
          'New Playlist',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: textController,
          autofocus: true,
          maxLength: 100,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            counterText: '',
            hintText: 'Playlist name (max 100 characters)',
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusMd,
              borderSide: const BorderSide(color: AppColors.surfaceBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppDimensions.borderRadiusMd,
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                try {
                  await ref.read(playlistRepositoryProvider).createPlaylist(name);
                  if (ctx.mounted) Navigator.of(ctx).pop();
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not create playlist: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddPlaylistOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Add to Library',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.playlist_add_rounded, color: AppColors.primary),
              ),
              title: const Text(
                'Custom Playlist',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Create an empty playlist and add your own songs',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _showCreatePlaylistDialog(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFE11D48)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
              ),
              title: const Text(
                'Personalized AI Playlist',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Generate 18-20 tracks tailored to your prompt or mood',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                AiPlaylistCreatorDialog.show(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt_rounded, color: Colors.white),
              ),
              title: const Text(
                'AI Mashup Studio (Spotify Blend)',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Blend two artists, genres, or vibes into an interleaved mix',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                AiMashupDialog.show(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF0000),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_circle_fill_rounded, color: Colors.white),
              ),
              title: const Text(
                'Sync YouTube Playlist',
                style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Import YouTube link and sync songs with Hi-Res audio',
                style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                YouTubeSyncDialog.show(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerNotifierProvider);
    final currentSong = playerState.currentSong;

    // Database streams
    final dbFavorites = ref.watch(favoriteSongsStreamProvider).value ?? [];
    final dbPlaylists = ref.watch(userPlaylistsStreamProvider).value ?? [];

    // Combine database favorites with any mock favorites for seamless experience
    final mockFavorites = MockCatalog.songs
        .where(
          (s) =>
              playerState.isSongFavorite(s.id) &&
              !dbFavorites.any((df) => df.id == s.id),
        )
        .toList();
    final likedSongs = [...dbFavorites, ...mockFavorites];

    final realDownloadedSongs =
        ref.watch(downloadedSongsProvider).valueOrNull ?? [];
    final mockDownloaded = MockCatalog.songs
        .where(
          (s) =>
              playerState.downloadedIds.contains(s.id) &&
              !realDownloadedSongs.any((r) => r.id == s.id),
        )
        .toList();
    final downloadedSongs = [...realDownloadedSongs, ...mockDownloaded];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Library Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space16,
                AppDimensions.space16,
                AppDimensions.space16,
                AppDimensions.space4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Your Library',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.play_circle_fill_rounded,
                          size: 24,
                          color: Color(0xFFFF0000),
                        ),
                        tooltip: 'Sync YouTube',
                        onPressed: () => YouTubeSyncDialog.show(context),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.tune_rounded,
                          size: 22,
                          color: AppColors.primary,
                        ),
                        tooltip: 'Taste Profile',
                        onPressed: () => OnboardingTasteScreen.show(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded, size: 26),
                        color: AppColors.primary,
                        tooltip: 'New Playlist',
                        onPressed: () => _showAddPlaylistOptions(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space4,
              ),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = index == _selectedTabIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppDimensions.space8),
                    child: ChoiceChip(
                      label: Text(_tabs[index]),
                      selected: isSelected,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTabIndex = index;
                          });
                        }
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppDimensions.space4),

            // Library Body
            Expanded(
              child: _buildTabBody(
                context,
                currentSong,
                playerState,
                likedSongs,
                downloadedSongs,
                dbPlaylists,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBody(
    BuildContext context,
    Song? currentSong,
    dynamic playerState,
    List<Song> likedSongs,
    List<Song> downloadedSongs,
    List<domain.Playlist> dbPlaylists,
  ) {
    switch (_selectedTabIndex) {
      case 1:
        // Liked Songs
        if (likedSongs.isEmpty) {
          final recommended = ref.watch(indianHitsProvider);
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            children: [
              const EmptyState(
                icon: Icons.favorite_border_rounded,
                title: 'No liked songs yet',
                description:
                    'Songs you tap the heart on will be saved here. Tap the heart on these picks to get started:',
              ),
              const SizedBox(height: 16),
              ...recommended.take(6).map((song) {
                final isPlaying =
                    currentSong?.id == song.id && playerState.isPlaying;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SongTile(
                    song: song,
                    isPlaying: isPlaying,
                    isFavorite: playerState.isSongFavorite(song.id),
                    onFavoriteToggle: () {
                      ref
                          .read(playerNotifierProvider.notifier)
                          .toggleFavorite(song.id, song);
                    },
                    onTap: () {
                      ref
                          .read(playerNotifierProvider.notifier)
                          .play(song, queue: recommended);
                    },
                  ),
                );
              }),
            ],
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: AppDimensions.space40),
          itemCount: likedSongs.length,
          itemBuilder: (context, index) {
            final song = likedSongs[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SongTile(
                index: index + 1,
                song: song,
                isPlaying: currentSong?.id == song.id && playerState.isPlaying,
                isFavorite: true,
                onFavoriteToggle: () {
                  ref
                      .read(playerNotifierProvider.notifier)
                      .toggleFavorite(song.id, song);
                },
                onTap: () {
                  ref
                      .read(playerNotifierProvider.notifier)
                      .play(song, queue: likedSongs);
                },
              ),
            );
          },
        );

      case 2:
        // Playlists
        final allPlaylists = <Widget>[];

        // User-created playlists first
        for (final pl in dbPlaylists) {
          allPlaylists.add(
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space12),
              child: Material(
                color: AppColors.surfaceElevated,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusLg,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppDimensions.space12),
                  onTap: () {
                    final sharedPl = shared.Playlist(
                      id: pl.id,
                      title: pl.name,
                      description: pl.description ?? 'Personal playlist created by you',
                      artworkUrl: pl.artworkUrl ?? '',
                      songs: pl.songs,
                      isCurated: false,
                      creator: 'You',
                    );
                    PlaylistDetailSheet.show(context, sharedPl);
                  },
                  leading: AuraArtwork(
                    seed: pl.id + pl.name,
                    size: 54,
                    borderRadius: AppDimensions.borderRadiusMd,
                    fallbackIcon: Icons.queue_music_rounded,
                  ),
                  title: Text(
                    pl.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${pl.trackCount} songs${pl.description != null && pl.description!.isNotEmpty ? ' • ${pl.description}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 26,
                  ),
                ),
              ),
            ),
          );
        }

        // Mock playlists
        for (final playlist in MockCatalog.playlists) {
          allPlaylists.add(
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.space12),
              child: Material(
                color: AppColors.surfaceElevated,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusLg,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(AppDimensions.space12),
                  onTap: () {
                    PlaylistDetailSheet.show(context, playlist);
                  },
                  leading: AuraArtwork(
                    seed: playlist.id + playlist.title,
                    size: 54,
                    borderRadius: AppDimensions.borderRadiusMd,
                    fallbackIcon: Icons.queue_music_rounded,
                  ),
                  title: Text(
                    playlist.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${playlist.trackCount} songs • ${playlist.description}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 26,
                  ),
                ),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space8,
          ),
          children: allPlaylists,
        );

      case 3:
        // Downloads
        if (downloadedSongs.isEmpty) {
          return const EmptyState(
            icon: Icons.download_done_rounded,
            title: 'No downloads yet',
            description:
                'Your downloaded songs will appear here for offline playback.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: AppDimensions.space40),
          itemCount: downloadedSongs.length,
          itemBuilder: (context, index) {
            final song = downloadedSongs[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SongTile(
                index: index + 1,
                song: song,
                isPlaying: currentSong?.id == song.id && playerState.isPlaying,
                isFavorite: playerState.isSongFavorite(song.id),
                onFavoriteToggle: () {
                  ref
                      .read(playerNotifierProvider.notifier)
                      .toggleFavorite(song.id);
                },
                onTap: () {
                  ref
                      .read(playerNotifierProvider.notifier)
                      .play(song, queue: downloadedSongs);
                },
              ),
            );
          },
        );

      case 4:
        // Artists
        final artists = ref.watch(featuredArtistsProvider);
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space8,
          ),
          itemCount: artists.length,
          itemBuilder: (context, index) {
            final artist = artists[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: AppColors.surfaceElevated,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: AppDimensions.borderRadiusLg,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                ),
                child: ListTile(
                  onTap: () => ArtistDetailSheet.show(context, artist),
                  leading: AuraArtwork(
                    seed: artist.name,
                    size: 48,
                    borderRadius: BorderRadius.circular(999),
                    fallbackIcon: Icons.person_rounded,
                  ),
                  title: Text(
                    artist.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${artist.genre} • ${artist.formattedListeners}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
              ),
            );
          },
        );

      case 5:
        // Albums
        return GridView.builder(
          padding: const EdgeInsets.all(AppDimensions.space16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: MockCatalog.albums.length,
          itemBuilder: (context, index) {
            final album = MockCatalog.albums[index];
            return AlbumCard(
              album: album,
              onTap: () {
                final pl = shared.Playlist(
                  id: album.id,
                  title: album.title,
                  description: 'Album by ${album.artist} • Released ${album.year}',
                  artworkUrl: album.artworkUrl,
                  songs: album.songs,
                  isCurated: true,
                  creator: album.artist,
                );
                PlaylistDetailSheet.show(context, pl);
              },
            );
          },
        );

      default:
        // All / Overview
        return ListView(
          padding: const EdgeInsets.only(bottom: AppDimensions.space40),
          children: [
            // Stats summary row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.favorite_rounded,
                      title: 'Liked Songs',
                      count: '${likedSongs.length} tracks',
                      accentColor: AppColors.primary,
                      onTap: () => setState(() => _selectedTabIndex = 1),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.download_done_rounded,
                      title: 'Offline',
                      count: '${downloadedSongs.length} tracks',
                      accentColor: AppColors.tertiary,
                      onTap: () => setState(() => _selectedTabIndex = 3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space8),

            // Pinned Playlists (including user created and synced)
            SectionHeader(
              title: 'Playlists',
              subtitle: 'Your curated, synced and custom collections',
              onAction: () => setState(() => _selectedTabIndex = 2),
            ),
            Builder(
              builder: (context) {
                final allPls = [
                  ...dbPlaylists.map(
                    (pl) => shared.Playlist(
                      id: pl.id,
                      title: pl.name,
                      description: pl.description ?? 'Personal playlist',
                      artworkUrl: pl.artworkUrl ?? '',
                      songs: pl.songs,
                      isCurated: false,
                      creator: 'You',
                    ),
                  ),
                  ...MockCatalog.playlists,
                ];

                return SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allPls.length,
                    itemBuilder: (context, index) {
                      final pl = allPls[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: AppDimensions.borderRadiusLg,
                          onTap: () => PlaylistDetailSheet.show(context, pl),
                          child: Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: AppDimensions.borderRadiusLg,
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Row(
                              children: [
                                AuraArtwork(
                                  seed: pl.id + pl.title,
                                  size: 64,
                                  borderRadius: AppDimensions.borderRadiusMd,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pl.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${pl.trackCount} songs',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: AppDimensions.space16),

            // Liked Songs Preview
            SectionHeader(
              title: 'Recently Liked',
              subtitle: 'Quick access to your loved audio',
              onAction: () => setState(() => _selectedTabIndex = 1),
            ),
            ...likedSongs.take(4).map((song) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SongTile(
                  song: song,
                  isPlaying:
                      currentSong?.id == song.id && playerState.isPlaying,
                  isFavorite: true,
                  onFavoriteToggle: () {
                    ref
                        .read(playerNotifierProvider.notifier)
                        .toggleFavorite(song.id);
                  },
                  onTap: () {
                    ref
                        .read(playerNotifierProvider.notifier)
                        .play(song, queue: likedSongs);
                  },
                ),
              );
            }),
          ],
        );
    }
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String count,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.borderRadiusLg,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppDimensions.borderRadiusLg,
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: AppDimensions.space12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              count,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

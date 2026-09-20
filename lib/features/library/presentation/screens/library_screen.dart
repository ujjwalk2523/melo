import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/data/mock_catalog.dart';
import 'package:melo/shared/models/song.dart';
import 'package:melo/shared/widgets/album_card.dart';
import 'package:melo/shared/widgets/aura_artwork.dart';
import 'package:melo/shared/widgets/empty_state.dart';
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

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerNotifierProvider);
    final currentSong = playerState.currentSong;

    final likedSongs = MockCatalog.songs
        .where((s) => playerState.isSongFavorite(s.id))
        .toList();

    final downloadedSongs = MockCatalog.songs
        .where((s) => playerState.downloadedIds.contains(s.id))
        .toList();

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
                  Text(
                    'Your Library',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_rounded, size: 26),
                    color: AppColors.primary,
                    tooltip: 'New Playlist',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Create playlist placeholder (Phase 2 UI)',
                          ),
                          duration: Duration(seconds: 1),
                          backgroundColor: AppColors.surfaceHighlight,
                        ),
                      );
                    },
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
  ) {
    switch (_selectedTabIndex) {
      case 1:
        // Liked Songs
        if (likedSongs.isEmpty) {
          return const EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'No liked songs yet',
            description: 'Songs you tap the heart on will be saved here.',
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
                      .toggleFavorite(song.id);
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
        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space8,
          ),
          children: MockCatalog.playlists.map((playlist) {
            return Padding(
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
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.play_circle_fill_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    onPressed: () {
                      if (playlist.songs.isNotEmpty) {
                        ref
                            .read(playerNotifierProvider.notifier)
                            .play(playlist.songs.first, queue: playlist.songs);
                      }
                    },
                  ),
                ),
              ),
            );
          }).toList(),
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
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space8,
          ),
          itemCount: MockCatalog.artists.length,
          itemBuilder: (context, index) {
            final artist = MockCatalog.artists[index];
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
                  leading: AuraArtwork(
                    seed: artist.id + artist.name,
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
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: const Text(
                      'Following',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Viewing album: ${album.title}'),
                    duration: const Duration(seconds: 1),
                  ),
                );
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

            // Pinned Playlists
            SectionHeader(
              title: 'Playlists',
              subtitle: 'Your curated and saved soundscapes',
              onAction: () => setState(() => _selectedTabIndex = 2),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: MockCatalog.playlists.length,
                itemBuilder: (context, index) {
                  final pl = MockCatalog.playlists[index];
                  return Container(
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
                  );
                },
              ),
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

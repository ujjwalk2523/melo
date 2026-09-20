import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/home/presentation/widgets/home_song_tile.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/data/mock_songs.dart';

/// Primary Library screen managing playlists, favorites, and offline downloads.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['All', 'Liked Songs', 'Playlists', 'Downloads'];

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(playerNotifierProvider).currentSong;
    final downloadableSongs = MockSongs.items
        .where((s) => s.isDownloadable)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space16,
                AppDimensions.space16,
                AppDimensions.space16,
                AppDimensions.space8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Library',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
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
                            'Create playlist will be enabled in Phase 8',
                          ),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Tab Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space8,
              ),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final isSelected = index == _selectedTabIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppDimensions.space8),
                    child: ChoiceChip(
                      label: Text(_tabs[index]),
                      selected: isSelected,
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
            const SizedBox(height: AppDimensions.space8),

            // Library Content Body
            Expanded(
              child: _buildBody(context, currentSong, downloadableSongs),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    dynamic currentSong,
    List<dynamic> downloadableSongs,
  ) {
    switch (_selectedTabIndex) {
      case 1:
        // Liked Songs Tab
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: AppDimensions.space40),
          itemCount: MockSongs.items.sublist(0, 4).length,
          itemBuilder: (context, index) {
            final song = MockSongs.items[index];
            return HomeSongTile(
              song: song,
              isPlaying: currentSong?.id == song.id,
              onTap: () {
                ref.read(playerNotifierProvider.notifier).play(song);
              },
            );
          },
        );

      case 2:
        // Playlists Tab
        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space8,
          ),
          children: [
            _buildLibraryCard(
              title: 'Synthwave Nightride',
              subtitle: '18 tracks • 1 hr 12 min',
              icon: Icons.album_rounded,
              accentColor: AppColors.primary,
            ),
            const SizedBox(height: AppDimensions.space12),
            _buildLibraryCard(
              title: 'Focus & Code',
              subtitle: '34 tracks • 2 hr 05 min',
              icon: Icons.headphones_rounded,
              accentColor: AppColors.secondary,
            ),
          ],
        );

      case 3:
        // Downloads Tab
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: AppDimensions.space40),
          itemCount: downloadableSongs.length,
          itemBuilder: (context, index) {
            final song = downloadableSongs[index];
            return HomeSongTile(
              song: song,
              isPlaying: currentSong?.id == song.id,
              onTap: () {
                ref.read(playerNotifierProvider.notifier).play(song);
              },
            );
          },
        );

      default:
        // All / Overview
        return ListView(
          padding: const EdgeInsets.only(bottom: AppDimensions.space40),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSummaryTile(
                      icon: Icons.favorite_rounded,
                      label: 'Liked Songs',
                      count: '4 tracks',
                      color: AppColors.tertiary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: _buildSummaryTile(
                      icon: Icons.download_done_rounded,
                      label: 'Downloaded',
                      count: '${downloadableSongs.length} tracks',
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space12),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space4,
              ),
              child: Text(
                'Pinned Collections',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            ...MockSongs.items.sublist(0, 5).map((song) {
              return HomeSongTile(
                song: song,
                isPlaying: currentSong?.id == song.id,
                onTap: () {
                  ref.read(playerNotifierProvider.notifier).play(song);
                },
              );
            }),
          ],
        );
    }
  }

  Widget _buildSummaryTile({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppDimensions.borderRadiusMd,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppDimensions.space12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppDimensions.borderRadiusMd,
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space16,
          vertical: AppDimensions.space8,
        ),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            borderRadius: AppDimensions.borderRadiusSm,
          ),
          child: Icon(icon, color: accentColor, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
        ),
        onTap: () {},
      ),
    );
  }
}

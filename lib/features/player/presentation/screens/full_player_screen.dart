import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/core/utils/duration_formatter.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/widgets/aura_artwork.dart';

import '../widgets/queue_sheet.dart';

/// Full-screen immersive player UI for Melo (Melo Dark Aura).
class FullPlayerScreen extends ConsumerWidget {
  const FullPlayerScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const FullPlayerScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final song = playerState.currentSong;

    if (song == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('No song playing')),
      );
    }

    final isFavorite = playerState.isCurrentFavorite;
    final isDownloaded = playerState.isCurrentDownloaded;
    final isPlaying = playerState.isPlaying;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final artworkSize = (availableHeight * 0.38).clamp(200.0, 310.0);

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        iconSize: 32,
                        color: AppColors.textSecondary,
                        tooltip: 'Collapse',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Column(
                        children: [
                          const Text(
                            'PLAYING FROM PLAYLIST',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.album.isNotEmpty
                                ? song.album
                                : 'Melo Daily Flow',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz_rounded),
                        color: AppColors.textSecondary,
                        tooltip: 'Options',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Song Options'),
                              duration: Duration(seconds: 1),
                              backgroundColor: AppColors.surfaceHighlight,
                            ),
                          );
                        },
                      ),
                    ],
                  ),

                  // Center Large Artwork with Radiant Glow
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AuraArtwork(
                      seed: song.id + song.title,
                      imageUrl: song.artworkUrl,
                      size: artworkSize,
                      borderRadius: BorderRadius.circular(24),
                      showGlow: true,
                    ),
                  ),

                  // Metadata & Favorite Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.4,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 28,
                          ),
                          tooltip: isFavorite ? 'Unlike' : 'Like',
                          onPressed: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .toggleFavorite(song.id);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Interactive Progress Scrubber
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.progressTrack,
                          thumbColor: Colors.white,
                          overlayColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        child: Slider(
                          value: playerState.position.inSeconds
                              .toDouble()
                              .clamp(
                                0.0,
                                playerState.duration.inSeconds.toDouble() > 0
                                    ? playerState.duration.inSeconds.toDouble()
                                    : 1.0,
                              ),
                          max: playerState.duration.inSeconds.toDouble() > 0
                              ? playerState.duration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (val) {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .seek(Duration(seconds: val.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DurationFormatter.format(playerState.position),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              DurationFormatter.format(playerState.duration),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Main Playback Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Shuffle Button
                        IconButton(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: playerState.isShuffle
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 24,
                          ),
                          tooltip: 'Shuffle',
                          onPressed: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .toggleShuffle();
                          },
                        ),

                        // Skip Previous
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: AppColors.textPrimary,
                            size: 38,
                          ),
                          tooltip: 'Previous',
                          onPressed: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .previous();
                          },
                        ),

                        // Play/Pause Glowing Button
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .togglePlayPause();
                          },
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.primary, Color(0xFF9333EA)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.45,
                                  ),
                                  blurRadius: 22,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child:
                                (playerState.isLoading ||
                                    playerState.isBuffering)
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                          ),
                        ),

                        // Skip Next
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: AppColors.textPrimary,
                            size: 38,
                          ),
                          tooltip: 'Next',
                          onPressed: () {
                            ref.read(playerNotifierProvider.notifier).next();
                          },
                        ),

                        // Repeat Button
                        IconButton(
                          icon: Icon(
                            playerState.repeatMode == PlaybackRepeatMode.one
                                ? Icons.repeat_one_rounded
                                : Icons.repeat_rounded,
                            color: playerState.isRepeat
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 24,
                          ),
                          tooltip: 'Repeat',
                          onPressed: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .cycleRepeatMode();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action Bar: Hi-Res Badge, Download, Queue
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Audio Quality Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 12,
                                color: AppColors.secondary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Hi-Res Lossless • 24-bit',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            // Download placeholder button
                            IconButton(
                              icon: Icon(
                                isDownloaded
                                    ? Icons.download_done_rounded
                                    : Icons.download_rounded,
                                color: isDownloaded
                                    ? AppColors.tertiary
                                    : AppColors.textSecondary,
                                size: 22,
                              ),
                              tooltip: isDownloaded
                                  ? 'Downloaded (Offline)'
                                  : 'Download',
                              onPressed: () {
                                ref
                                    .read(playerNotifierProvider.notifier)
                                    .toggleDownload(song.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isDownloaded ? 'Removed from downloads' : 'Downloaded for offline playback (mock)',
                                    ),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: AppColors.surfaceHighlight,
                                  ),
                                );
                              },
                            ),

                            // Queue button
                            IconButton(
                              icon: const Icon(
                                Icons.queue_music_rounded,
                                color: AppColors.textSecondary,
                                size: 24,
                              ),
                              tooltip: 'Queue',
                              onPressed: () {
                                QueueSheet.show(context);
                              },
                            ),
                          ],
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
    );
  }
}

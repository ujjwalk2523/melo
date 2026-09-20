import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/player/providers/player_provider.dart';

/// Floating persistent Mini Player displayed directly above the bottom navigation bar.
class MiniPlayer extends ConsumerWidget {
  final VoidCallback? onTap;

  const MiniPlayer({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final currentSong = playerState.currentSong;

    if (currentSong == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      child: Material(
        color: AppColors.miniPlayerBg,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.6),
        borderRadius: AppDimensions.borderRadiusMd,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap:
              onTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening player for: ${currentSong.title}'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppColors.surfaceHighlight,
                  ),
                );
              },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Linear Track Progress Bar
              LinearProgressIndicator(
                value: playerState.progressFraction,
                minHeight: 2.5,
                backgroundColor: AppColors.progressTrack,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.progressActive,
                ),
              ),
              Container(
                height: AppDimensions.miniPlayerHeight,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.surfaceBorder.withValues(alpha: 0.6),
                    width: 0.8,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppDimensions.radiusMd),
                    bottomRight: Radius.circular(AppDimensions.radiusMd),
                  ),
                ),
                child: Row(
                  children: [
                    // Artwork with rounded corners
                    ClipRRect(
                      borderRadius: AppDimensions.borderRadiusSm,
                      child: Image.network(
                        currentSong.artworkUrl,
                        width: AppDimensions.miniPlayerArtworkSize,
                        height: AppDimensions.miniPlayerArtworkSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: AppDimensions.miniPlayerArtworkSize,
                          height: AppDimensions.miniPlayerArtworkSize,
                          color: AppColors.surfaceHighlight,
                          child: const Icon(
                            Icons.music_note_rounded,
                            color: AppColors.textMuted,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),

                    // Title & Artist
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSong.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentSong.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),

                    // Controls: Skip Previous, Play/Pause, Skip Next
                    IconButton(
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: AppColors.textSecondary,
                      ),
                      iconSize: 22,
                      tooltip: 'Previous',
                      onPressed: () {
                        ref.read(playerNotifierProvider.notifier).previous();
                      },
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          playerState.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: AppColors.onPrimary,
                        ),
                        iconSize: 22,
                        tooltip: playerState.isPlaying ? 'Pause' : 'Play',
                        onPressed: () {
                          ref
                              .read(playerNotifierProvider.notifier)
                              .togglePlayPause();
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.textSecondary,
                      ),
                      iconSize: 22,
                      tooltip: 'Next',
                      onPressed: () {
                        ref.read(playerNotifierProvider.notifier).next();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

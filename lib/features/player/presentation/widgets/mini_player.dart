import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/player/presentation/screens/full_player_screen.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/widgets/aura_artwork.dart';

/// Upgraded Floating persistent Mini Player displayed directly above the bottom navigation bar.
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

    final isPlaying = playerState.isPlaying;
    final isFavorite = playerState.isCurrentFavorite;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space12,
        vertical: AppDimensions.space4,
      ),
      child: Material(
        color: AppColors.miniPlayerBg,
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.8),
        borderRadius: AppDimensions.borderRadiusLg,
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppDimensions.borderRadiusLg,
            border: Border.all(color: AppColors.miniPlayerBorder, width: 1.0),
          ),
          child: InkWell(
            onTap: onTap ?? () => FullPlayerScreen.show(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Linear Track Progress Indicator
                LinearProgressIndicator(
                  value: playerState.progressFraction,
                  minHeight: 2.5,
                  backgroundColor: AppColors.progressTrack,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),

                // Player Content Row
                Container(
                  height: AppDimensions.miniPlayerHeight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space12,
                  ),
                  child: Row(
                    children: [
                      // Aura Artwork
                      AuraArtwork(
                        seed: currentSong.id + currentSong.title,
                        imageUrl: currentSong.artworkUrl,
                        size: AppDimensions.miniPlayerArtworkSize,
                        borderRadius: AppDimensions.borderRadiusSm,
                      ),
                      const SizedBox(width: AppDimensions.space12),

                      // Track Metadata
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
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
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      // Quick Favorite Heart
                      IconButton(
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: isFavorite
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                        iconSize: 20,
                        tooltip: isFavorite ? 'Unlike' : 'Like',
                        onPressed: () {
                          ref
                              .read(playerNotifierProvider.notifier)
                              .toggleFavorite(currentSong.id, currentSong);
                        },
                      ),

                      // Skip Previous
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

                      // Play/Pause circular button
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon:
                              (playerState.isLoading || playerState.isBuffering)
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                          iconSize: 22,
                          tooltip: isPlaying ? 'Pause' : 'Play',
                          onPressed: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .togglePlayPause();
                          },
                        ),
                      ),

                      // Skip Next
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
      ),
    );
  }
}

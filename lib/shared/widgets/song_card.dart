import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../models/song.dart';
import 'aura_artwork.dart';

/// Reusable card displaying song artwork, title, artist, and tap-to-play callback.
class SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final bool isPlaying;

  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimensions.songCardSize,
      margin: const EdgeInsets.only(right: AppDimensions.space12),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork Container with overlay if playing
            Stack(
              children: [
                AuraArtwork(
                  seed: song.id + song.title,
                  imageUrl: song.artworkUrl,
                  size: AppDimensions.songCardSize,
                  borderRadius: AppDimensions.borderRadiusLg,
                  showGlow: isPlaying,
                ),
                if (isPlaying)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: AppDimensions.borderRadiusLg,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.equalizer_rounded,
                          color: AppColors.secondary,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                if (song.isDownloadable)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceBorder,
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.download_done_rounded,
                        color: AppColors.tertiary,
                        size: 12,
                      ),
                    ),
                  ),
                // Play button overlay
                if (!isPlaying)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppDimensions.space8),

            // Song Title
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isPlaying ? AppColors.secondary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),

            // Artist & Genre
            Text(
              '${song.artist}${song.genre != null ? " • ${song.genre}" : ""}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

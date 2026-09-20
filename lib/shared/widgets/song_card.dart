import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../models/song.dart';

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
        borderRadius: AppDimensions.borderRadiusMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork Container with overlay if playing
            Stack(
              children: [
                ClipRRect(
                  borderRadius: AppDimensions.borderRadiusMd,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.network(
                      song.artworkUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceHighlight,
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: AppColors.textMuted,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isPlaying)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: AppDimensions.borderRadiusMd,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.equalizer_rounded,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                if (song.isDownloadable)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.download_done_rounded,
                        color: AppColors.primary,
                        size: 14,
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
                color: isPlaying ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),

            // Artist
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

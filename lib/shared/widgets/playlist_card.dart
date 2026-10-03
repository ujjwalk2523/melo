import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../models/playlist.dart';
import 'aura_artwork.dart';

/// Spotify-style visual card displaying a personalized playlist, Daily Mix, or AI Flow.
class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback onPlayTap;
  final double size;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
    required this.onPlayTap,
    this.size = 152.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      margin: const EdgeInsets.only(right: AppDimensions.space12),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Artwork Container with Badge & Quick Play Button
            Stack(
              children: [
                AuraArtwork(
                  seed: playlist.id + playlist.title,
                  imageUrl: playlist.artworkUrl,
                  size: size,
                  borderRadius: AppDimensions.borderRadiusLg,
                  fallbackIcon: Icons.queue_music_rounded,
                ),

                // Top Badge (e.g. DAILY MIX, ARTIST MIX, AI GENERATED)
                if (playlist.badge != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        playlist.badge!,
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Spotify-style Floating Play Button
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onPlayTap,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space8),

            // Playlist Title
            Text(
              playlist.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 3),

            // Spotify-Style Description (e.g. "With Yo Yo Honey Singh, Shubh and more")
            Text(
              playlist.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

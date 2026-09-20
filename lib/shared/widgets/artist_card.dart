import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../models/artist.dart';
import 'aura_artwork.dart';

/// Reusable circular avatar card for musical artists in Melo.
class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;
  final VoidCallback? onFollowToggle;
  final double size;

  const ArtistCard({
    super.key,
    required this.artist,
    required this.onTap,
    this.onFollowToggle,
    this.size = 110.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      margin: const EdgeInsets.only(right: AppDimensions.space12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Column(
          children: [
            // Circular Avatar with glowing border
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: AuraArtwork(
                seed: artist.id + artist.name,
                imageUrl: artist.avatarUrl,
                size: size * 0.8,
                borderRadius: BorderRadius.circular(999),
                fallbackIcon: Icons.person_rounded,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),

            // Artist Name
            Text(
              artist.name,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),

            // Formatted monthly listeners
            Text(
              artist.formattedListeners,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

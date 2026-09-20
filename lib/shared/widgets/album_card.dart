import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../models/album.dart';
import 'aura_artwork.dart';

/// Reusable visual card for displaying an Album in Melo.
class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;
  final double size;

  const AlbumCard({
    super.key,
    required this.album,
    required this.onTap,
    this.size = 140.0,
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
            // Album Artwork with subtle border
            AuraArtwork(
              seed: album.id + album.title,
              imageUrl: album.artworkUrl,
              size: size,
              borderRadius: AppDimensions.borderRadiusLg,
              fallbackIcon: Icons.album_rounded,
            ),
            const SizedBox(height: AppDimensions.space8),

            // Album Title
            Text(
              album.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),

            // Artist & Year
            Text(
              '${album.artist} • ${album.year}',
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

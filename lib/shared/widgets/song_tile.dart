import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/duration_formatter.dart';
import '../models/song.dart';
import 'aura_artwork.dart';

/// Reusable universal list row for displaying a song in playlists, search, and library.
class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final bool isPlaying;
  final int? index;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onMoreOptions;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isPlaying = false,
    this.index,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onMoreOptions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: isPlaying
            ? AppColors.surfaceHighlight.withValues(alpha: 0.8)
            : Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusMd,
          side: isPlaying
              ? BorderSide(color: AppColors.primary.withValues(alpha: 0.3))
              : BorderSide.none,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space12,
            vertical: 2,
          ),
          onTap: onTap,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (index != null) ...[
              SizedBox(
                width: 24,
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isPlaying
                        ? AppColors.secondary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Stack(
              alignment: Alignment.center,
              children: [
                AuraArtwork(
                  seed: song.id + song.title,
                  imageUrl: song.artworkUrl,
                  size: 48,
                  borderRadius: AppDimensions.borderRadiusSm,
                ),
                if (isPlaying)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: AppDimensions.borderRadiusSm,
                    ),
                    child: const Icon(
                      Icons.equalizer_rounded,
                      color: AppColors.secondary,
                      size: 22,
                    ),
                  ),
              ],
            ),
          ],
        ),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: isPlaying ? AppColors.secondary : AppColors.textPrimary,
          ),
        ),
        subtitle: Row(
          children: [
            if (song.isDownloadable) ...[
              const Icon(
                Icons.download_done_rounded,
                size: 13,
                color: AppColors.tertiary,
              ),
              const SizedBox(width: 4),
            ],
            Expanded(
              child: Text(
                '${song.artist} • ${song.album}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary, fontSize: 12),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Duration
            Text(
              DurationFormatter.format(song.duration),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 4),

            // Favorite Icon
            IconButton(
              icon: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavorite ? AppColors.primary : AppColors.textTertiary,
                size: 20,
              ),
              tooltip: isFavorite
                  ? 'Remove from Favorites'
                  : 'Add to Favorites',
              onPressed:
                  onFavoriteToggle ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Updated favorite for "${song.title}"'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.surfaceHighlight,
                      ),
                    );
                  },
            ),

            // More Options
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
              color: AppColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: AppDimensions.borderRadiusMd,
                side: const BorderSide(color: AppColors.surfaceBorder),
              ),
              onSelected: (action) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$action: "${song.title}"'),
                    duration: const Duration(seconds: 1),
                    backgroundColor: AppColors.surfaceHighlight,
                  ),
                );
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'Add to Playlist',
                  child: Row(
                    children: [
                      Icon(
                        Icons.playlist_add_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Add to Playlist',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'View Album',
                  child: Row(
                    children: [
                      Icon(
                        Icons.album_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'View Album',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'View Artist',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'View Artist',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'Share',
                  child: Row(
                    children: [
                      Icon(
                        Icons.share_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Share Song',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}

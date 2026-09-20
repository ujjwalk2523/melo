import 'package:flutter/material.dart';

import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/core/utils/duration_formatter.dart';
import 'package:melo/shared/models/song.dart';

/// Reusable tile for vertical song lists (Trending, Queue, Search results).
class HomeSongTile extends StatelessWidget {
  final int? rank;
  final Song song;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onMore;

  const HomeSongTile({
    super.key,
    this.rank,
    required this.song,
    this.isPlaying = false,
    required this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space4,
      ),
      child: Material(
        color: isPlaying ? AppColors.surfaceHighlight : Colors.transparent,
        borderRadius: AppDimensions.borderRadiusMd,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space12,
          vertical: AppDimensions.space4,
        ),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rank != null) ...[
              SizedBox(
                width: 24,
                child: Text(
                  rank.toString(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isPlaying ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space8),
            ],
            ClipRRect(
              borderRadius: AppDimensions.borderRadiusSm,
              child: Image.network(
                song.artworkUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surfaceElevated,
                  child: const Icon(
                    Icons.music_note,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isPlaying ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${song.artist} • ${song.album}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DurationFormatter.format(song.duration),
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            IconButton(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: onMore ?? () {},
            ),
          ],
        ),
      ),
    ),
  );
}
}

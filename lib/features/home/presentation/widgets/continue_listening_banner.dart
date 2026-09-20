import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/models/song.dart';
import 'package:melo/shared/widgets/aura_artwork.dart';

/// Interactive banner for resuming a recently listened track.
class ContinueListeningBanner extends ConsumerWidget {
  final Song song;

  const ContinueListeningBanner({super.key, required this.song});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final isPlaying =
        playerState.currentSong?.id == song.id && playerState.isPlaying;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          borderRadius: AppDimensions.borderRadiusLg,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF241442), AppColors.surfaceElevated],
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AuraArtwork(
              seed: song.id + song.title,
              imageUrl: song.artworkUrl,
              size: 52,
              borderRadius: AppDimensions.borderRadiusMd,
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CONTINUE LISTENING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
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
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {
                  if (isPlaying) {
                    ref.read(playerNotifierProvider.notifier).pause();
                  } else {
                    ref.read(playerNotifierProvider.notifier).play(song);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

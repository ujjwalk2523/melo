import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/models/song.dart';
import 'package:melo/shared/widgets/aura_artwork.dart';

/// 2-row compact grid of quick-pick songs for instantaneous listening.
class QuickPicksGrid extends ConsumerWidget {
  final List<Song> songs;

  const QuickPicksGrid({super.key, required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final currentSong = playerState.currentSong;

    if (songs.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          mainAxisExtent: 58,
        ),
        itemCount: songs.length.clamp(0, 6),
        itemBuilder: (context, index) {
          final song = songs[index];
          final isPlaying = currentSong?.id == song.id && playerState.isPlaying;

          return InkWell(
            onTap: () {
              ref
                  .read(playerNotifierProvider.notifier)
                  .play(song, queue: songs);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                color: isPlaying
                    ? AppColors.surfaceHighlight
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPlaying
                      ? AppColors.primary
                      : AppColors.surfaceBorder,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  AuraArtwork(
                    seed: song.id + song.title,
                    imageUrl: song.artworkUrl,
                    size: 56,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      bottomLeft: Radius.circular(7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isPlaying)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.graphic_eq_rounded,
                        color: AppColors.secondary,
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

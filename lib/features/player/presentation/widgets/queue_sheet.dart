import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/widgets/song_tile.dart';

/// Modal bottom sheet displaying the current playback queue with reordering and removal.
class QueueSheet extends ConsumerWidget {
  const QueueSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const QueueSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final queue = playerState.queue;
    final currentSong = playerState.currentSong;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.only(top: AppDimensions.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Playback Queue',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                    ),
                    Text(
                      '${queue.length} tracks',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space12),
              const Divider(color: AppColors.surfaceBorder),

              // Queue List
              Expanded(
                child: queue.isEmpty
                    ? const Center(
                        child: Text(
                          'Queue is empty',
                          style: TextStyle(color: AppColors.textTertiary),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: queue.length,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space12,
                          vertical: AppDimensions.space8,
                        ),
                        itemBuilder: (context, index) {
                          final song = queue[index];
                          final isCurrent = song == currentSong;

                          return Dismissible(
                            key: ValueKey('queue-${song.id}-$index'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color: AppColors.error.withValues(alpha: 0.2),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.error,
                              ),
                            ),
                            onDismissed: (_) {
                              ref
                                  .read(playerNotifierProvider.notifier)
                                  .removeFromQueue(index);
                            },
                            child: SongTile(
                              song: song,
                              index: index + 1,
                              isPlaying: isCurrent && playerState.isPlaying,
                              isFavorite: playerState.isSongFavorite(song.id),
                              onFavoriteToggle: () {
                                ref
                                    .read(playerNotifierProvider.notifier)
                                    .toggleFavorite(song.id);
                              },
                              onTap: () {
                                ref
                                    .read(playerNotifierProvider.notifier)
                                    .play(song);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

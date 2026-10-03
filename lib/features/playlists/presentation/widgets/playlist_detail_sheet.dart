import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../shared/models/playlist.dart';
import '../../../../shared/models/song.dart';
import '../../../../shared/widgets/aura_artwork.dart';
import '../../../../shared/widgets/song_tile.dart';
import '../../../player/providers/player_provider.dart';

/// Full Spotify-style Playlist Detail screen/sheet showing rich header,
/// play/shuffle controls, and full tracklist with seamless queue playback.
class PlaylistDetailSheet extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailSheet({super.key, required this.playlist});

  static void show(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => PlaylistDetailSheet(playlist: playlist),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final currentSong = playerState.currentSong;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: CustomScrollView(
        slivers: [
          // Top Bar with Dismiss Handle
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                    color: AppColors.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (playlist.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.secondary),
                          const SizedBox(width: 5),
                          Text(
                            playlist.badge!,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.9,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  const SizedBox(width: 48), // balance back button
                ],
              ),
            ),
          ),

          // Playlist Header Hero Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  // Large Cover Art with Aura Glow
                  AuraArtwork(
                    seed: playlist.id + playlist.title,
                    imageUrl: playlist.artworkUrl,
                    size: 190,
                    borderRadius: BorderRadius.circular(20),
                    showGlow: true,
                    fallbackIcon: Icons.queue_music_rounded,
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    playlist.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    playlist.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadata: Creator & Count
                  Text(
                    '${playlist.creator} • ${playlist.songs.length} tracks • ${DurationFormatter.format(playlist.totalDuration)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons: Play All & Shuffle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Big Play Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 6,
                          shadowColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 22),
                        label: const Text(
                          'Play All',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: () {
                          if (playlist.songs.isNotEmpty) {
                            ref.read(playerNotifierProvider.notifier).play(
                                  playlist.songs.first,
                                  queue: playlist.songs,
                                );
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const SizedBox(width: 14),

                      // Shuffle Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.surfaceBorder),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        icon: const Icon(Icons.shuffle_rounded, size: 18, color: AppColors.secondary),
                        label: const Text('Shuffle', style: TextStyle(fontSize: 13)),
                        onPressed: () {
                          if (playlist.songs.isNotEmpty) {
                            final shuffled = List<Song>.from(playlist.songs)..shuffle();
                            ref.read(playerNotifierProvider.notifier).play(
                                  shuffled.first,
                                  queue: shuffled,
                                );
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Divider(color: AppColors.surfaceBorder),
            ),
          ),

          // Tracklist
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = playlist.songs[index];
                  final isPlaying = currentSong?.id == song.id && playerState.isPlaying;

                  return SongTile(
                    index: index + 1,
                    song: song,
                    isPlaying: isPlaying,
                    isFavorite: playerState.isSongFavorite(song.id),
                    onFavoriteToggle: () {
                      ref.read(playerNotifierProvider.notifier).toggleFavorite(song.id);
                    },
                    onTap: () {
                      ref.read(playerNotifierProvider.notifier).play(
                            song,
                            queue: playlist.songs,
                          );
                    },
                  );
                },
                childCount: playlist.songs.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

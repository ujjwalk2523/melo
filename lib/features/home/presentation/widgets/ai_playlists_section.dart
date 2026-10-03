import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared/models/playlist.dart';
import '../../../../shared/widgets/playlist_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../player/providers/player_provider.dart';
import '../../../playlists/presentation/widgets/playlist_detail_sheet.dart';

/// Horizontally scrollable carousel displaying Spotify-style AI Daily Mixes,
/// Artist Mixes, and Search-reactive playlist flows on the Home screen.
class AiPlaylistsSection extends ConsumerWidget {
  final List<Playlist> playlists;
  final String title;
  final String? subtitle;

  const AiPlaylistsSection({
    super.key,
    required this.playlists,
    this.title = 'Made For You • AI Mixes',
    this.subtitle = 'Playlists synthesized in real-time from your searches & listening',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (playlists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          subtitle: subtitle,
        ),
        SizedBox(
          height: 236,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return PlaylistCard(
                playlist: playlist,
                onTap: () {
                  PlaylistDetailSheet.show(context, playlist);
                },
                onPlayTap: () {
                  if (playlist.songs.isNotEmpty) {
                    ref.read(playerNotifierProvider.notifier).play(
                          playlist.songs.first,
                          queue: playlist.songs,
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.playlist_play_rounded, color: AppColors.secondary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Playing "${playlist.title}" (${playlist.songs.length} tracks)',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

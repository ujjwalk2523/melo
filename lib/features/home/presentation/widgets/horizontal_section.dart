import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/models/song.dart';
import 'package:melo/shared/widgets/section_header.dart';
import 'package:melo/shared/widgets/song_card.dart';

/// Horizontally scrollable list of song cards with a section header.
class HorizontalSection extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final List<Song> songs;
  final VoidCallback? onSeeAll;

  const HorizontalSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.songs,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSong = ref.watch(playerNotifierProvider).currentSong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, subtitle: subtitle, onAction: onSeeAll),
        SizedBox(
          height: 204,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
            ),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongCard(
                song: song,
                isPlaying: activeSong?.id == song.id,
                onTap: () {
                  ref
                      .read(playerNotifierProvider.notifier)
                      .play(song, queue: songs);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

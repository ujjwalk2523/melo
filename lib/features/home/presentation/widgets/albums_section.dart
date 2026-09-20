import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/shared/models/album.dart';
import 'package:melo/shared/widgets/album_card.dart';
import 'package:melo/shared/widgets/section_header.dart';

/// Horizontally scrollable section displaying featured albums.
class AlbumsSection extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final List<Album> albums;
  final VoidCallback? onSeeAll;

  const AlbumsSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.albums,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (albums.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, subtitle: subtitle, onAction: onSeeAll),
        SizedBox(
          height: 198,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
            ),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return AlbumCard(
                album: album,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Viewing album: ${album.title}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

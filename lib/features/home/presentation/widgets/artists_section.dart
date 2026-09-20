import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/shared/models/artist.dart';
import 'package:melo/shared/widgets/artist_card.dart';
import 'package:melo/shared/widgets/section_header.dart';

/// Horizontally scrollable section displaying featured musical artists.
class ArtistsSection extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final List<Artist> artists;
  final VoidCallback? onSeeAll;

  const ArtistsSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.artists,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (artists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, subtitle: subtitle, onAction: onSeeAll),
        SizedBox(
          height: 148,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
            ),
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return ArtistCard(
                artist: artist,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Exploring artist: ${artist.name}'),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/home/presentation/widgets/home_song_tile.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/features/search/providers/search_provider.dart';
import 'package:melo/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:melo/shared/widgets/empty_state.dart';

/// Primary Search screen featuring debounced queries, category filters, and result lists.
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  static const List<String> categories = ['All', 'Tracks', 'Artists', 'Genres'];
  static const List<String> browseGenres = [
    'Synthwave',
    'Electronic',
    'Lo-Fi Chill',
    'Ambient',
    'Techno',
    'Indie Folk',
    'Future Bass',
    'Chillstep',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(searchCategoryFilterProvider);
    final results = ref.watch(searchResultsProvider);
    final currentSong = ref.watch(playerNotifierProvider).currentSong;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.space16,
                AppDimensions.space16,
                AppDimensions.space16,
                AppDimensions.space4,
              ),
              child: Text(
                'Search',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),

            // Search Bar
            SearchBarWidget(
              initialValue: query,
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).state = val;
              },
              onClear: () {
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space16,
                vertical: AppDimensions.space4,
              ),
              child: Row(
                children: categories.map((cat) {
                  final isSelected = cat == selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppDimensions.space8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref
                                  .read(searchCategoryFilterProvider.notifier)
                                  .state =
                              cat;
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppDimensions.space8),

            // Results / Discovery Body
            Expanded(
              child: query.isEmpty
                  ? _buildBrowseGenres(context, ref)
                  : (results.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No results found',
                            description: 'Try searching with a different song title or artist name.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.space40,
                            ),
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final song = results[index];
                              return HomeSongTile(
                                song: song,
                                isPlaying: currentSong?.id == song.id,
                                onTap: () {
                                  ref
                                      .read(playerNotifierProvider.notifier)
                                      .play(song, queue: results);
                                },
                              );
                            },
                          )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseGenres(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore Genres',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.space12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: browseGenres.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.space12,
              mainAxisSpacing: AppDimensions.space12,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final genre = browseGenres[index];
              return InkWell(
                onTap: () {
                  ref.read(searchQueryProvider.notifier).state = genre;
                },
                borderRadius: AppDimensions.borderRadiusMd,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppDimensions.borderRadiusMd,
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      genre,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

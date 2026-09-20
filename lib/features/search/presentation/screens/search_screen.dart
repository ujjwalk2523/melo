import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:melo/features/search/providers/search_provider.dart';
import 'package:melo/shared/widgets/album_card.dart';
import 'package:melo/shared/widgets/artist_card.dart';
import 'package:melo/shared/widgets/empty_state.dart';
import 'package:melo/shared/widgets/section_header.dart';
import 'package:melo/shared/widgets/song_tile.dart';

/// Primary Search screen featuring debounced queries, category filters, and result lists.
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  static const List<String> categories = ['All', 'Songs', 'Artists', 'Albums'];

  static const List<Map<String, dynamic>> genreCards = [
    {
      'name': 'Synthwave',
      'colors': [Color(0xFF7C3AED), Color(0xFF1E1B4B)],
      'icon': Icons.flash_on_rounded,
    },
    {
      'name': 'Lo-Fi Chill',
      'colors': [Color(0xFF06B6D4), Color(0xFF083344)],
      'icon': Icons.coffee_rounded,
    },
    {
      'name': 'Cyber Techno',
      'colors': [Color(0xFF10B981), Color(0xFF022C22)],
      'icon': Icons.memory_rounded,
    },
    {
      'name': 'Deep Ambient',
      'colors': [Color(0xFF3B82F6), Color(0xFF172554)],
      'icon': Icons.nights_stay_rounded,
    },
    {
      'name': 'Electronic',
      'colors': [Color(0xFFEC4899), Color(0xFF500724)],
      'icon': Icons.graphic_eq_rounded,
    },
    {
      'name': 'Future Bass',
      'colors': [Color(0xFFF59E0B), Color(0xFF451A03)],
      'icon': Icons.waves_rounded,
    },
    {
      'name': 'Chillstep',
      'colors': [Color(0xFF8B5CF6), Color(0xFF2E1065)],
      'icon': Icons.air_rounded,
    },
    {
      'name': 'Indie Folk',
      'colors': [Color(0xFF14B8A6), Color(0xFF042F2E)],
      'icon': Icons.nature_rounded,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final selectedCategory = ref.watch(searchCategoryFilterProvider);
    final recentSearches = ref.watch(recentSearchesProvider);

    final songResults = ref.watch(searchSongResultsProvider);
    final artistResults = ref.watch(searchArtistResultsProvider);
    final albumResults = ref.watch(searchAlbumResultsProvider);

    final playerState = ref.watch(playerNotifierProvider);
    final currentSong = playerState.currentSong;
    final isSearching = ref.watch(isSearchLoadingProvider);

    final hasResults =
        songResults.isNotEmpty ||
        artistResults.isNotEmpty ||
        albumResults.isNotEmpty;

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
                  letterSpacing: -0.4,
                ),
              ),
            ),

            // Search Bar
            SearchBarWidget(
              initialValue: query,
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).state = val;
                if (val.trim().isNotEmpty) {
                  ref.read(recentSearchesProvider.notifier).add(val);
                }
              },
              onClear: () {
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),

            // Category Chips (Active when query is present)
            if (query.isNotEmpty)
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
                      padding: const EdgeInsets.only(
                        right: AppDimensions.space8,
                      ),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
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

            if (isSearching)
              const LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.primary,
                backgroundColor: Colors.transparent,
              )
            else
              const SizedBox(height: AppDimensions.space4),

            // Main Content Body
            Expanded(
              child: query.isEmpty
                  ? _buildEmptySearchState(context, ref, recentSearches)
                  : (!hasResults
                        ? const EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No results found',
                            description: 'We could not find any matches. Try searching for a different keyword, artist, or genre.',
                          )
                        : _buildSearchResults(
                            context,
                            ref,
                            selectedCategory,
                            songResults,
                            artistResults,
                            albumResults,
                            currentSong,
                            playerState,
                          )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchState(
    BuildContext context,
    WidgetRef ref,
    List<String> recentSearches,
  ) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppDimensions.space40),
      children: [
        // Recent Searches
        if (recentSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(recentSearchesProvider.notifier).clear();
                  },
                  child: const Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches.map((term) {
                return Chip(
                  backgroundColor: AppColors.surfaceElevated,
                  side: const BorderSide(color: AppColors.surfaceBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  label: InkWell(
                    onTap: () {
                      ref.read(searchQueryProvider.notifier).state = term;
                    },
                    child: Text(
                      term,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  deleteIcon: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  onDeleted: () {
                    ref.read(recentSearchesProvider.notifier).remove(term);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
        ],

        // Browse All Genres & Moods
        const SectionHeader(
          title: 'Browse All Genres',
          subtitle: 'Explore moods, aesthetics, and soundscapes',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space16,
            vertical: AppDimensions.space8,
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: genreCards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppDimensions.space12,
              mainAxisSpacing: AppDimensions.space12,
              childAspectRatio: 2.1,
            ),
            itemBuilder: (context, index) {
              final genre = genreCards[index];
              final colors = genre['colors'] as List<Color>;
              final icon = genre['icon'] as IconData;

              return InkWell(
                onTap: () {
                  ref.read(searchQueryProvider.notifier).state =
                      genre['name'] as String;
                },
                borderRadius: AppDimensions.borderRadiusLg,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    borderRadius: AppDimensions.borderRadiusLg,
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: colors.first.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          genre['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(
                        icon,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 24,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    WidgetRef ref,
    String category,
    List<dynamic> songs,
    List<dynamic> artists,
    List<dynamic> albums,
    dynamic currentSong,
    dynamic playerState,
  ) {
    if (category == 'Artists') {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: artists.length,
        itemBuilder: (context, index) {
          final artist = artists[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ArtistCard(
              artist: artist,
              onTap: () {
                ref.read(searchQueryProvider.notifier).state = artist.name;
              },
            ),
          );
        },
      );
    }

    if (category == 'Albums') {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.78,
        ),
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return AlbumCard(
            album: album,
            onTap: () {
              ref.read(searchQueryProvider.notifier).state = album.title;
            },
          );
        },
      );
    }

    // Default 'All' or 'Songs'
    return ListView(
      padding: const EdgeInsets.only(bottom: AppDimensions.space40),
      children: [
        if (category == 'All' && artists.isNotEmpty) ...[
          const SectionHeader(title: 'Top Artist Match'),
          SizedBox(
            height: 148,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: artists.length,
              itemBuilder: (context, index) {
                final artist = artists[index];
                return ArtistCard(
                  artist: artist,
                  onTap: () {
                    ref.read(searchQueryProvider.notifier).state = artist.name;
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],

        if (category == 'All' && albums.isNotEmpty) ...[
          const SectionHeader(title: 'Matching Albums'),
          SizedBox(
            height: 198,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: albums.length,
              itemBuilder: (context, index) {
                final album = albums[index];
                return AlbumCard(
                  album: album,
                  onTap: () {
                    ref.read(searchQueryProvider.notifier).state = album.title;
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],

        const SectionHeader(title: 'Songs'),
        ...songs.map((song) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SongTile(
              song: song,
              isPlaying: currentSong?.id == song.id && playerState.isPlaying,
              isFavorite: playerState.isSongFavorite(song.id),
              onFavoriteToggle: () {
                ref
                    .read(playerNotifierProvider.notifier)
                    .toggleFavorite(song.id);
              },
              onTap: () {
                ref
                    .read(playerNotifierProvider.notifier)
                    .play(song, queue: List.from(songs));
              },
            ),
          );
        }),
      ],
    );
  }
}

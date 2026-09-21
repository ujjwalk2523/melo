import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/database/database_providers.dart';
import 'package:melo/core/recommendations/domain/recommendation.dart';
import 'package:melo/core/recommendations/providers/recommendation_providers.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/home/presentation/widgets/albums_section.dart';
import 'package:melo/features/home/presentation/widgets/artists_section.dart';
import 'package:melo/features/home/presentation/widgets/continue_listening_banner.dart';
import 'package:melo/features/home/presentation/widgets/greeting_header.dart';
import 'package:melo/features/home/presentation/widgets/horizontal_section.dart';
import 'package:melo/features/home/presentation/widgets/quick_picks_grid.dart';
import 'package:melo/features/home/providers/home_provider.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/widgets/section_header.dart';
import 'package:melo/shared/widgets/song_tile.dart';

/// The primary Home dashboard screen displaying greetings, quick picks, continue listening, and curated sections.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentTracks = ref.watch(recentlyPlayedStreamProvider).value ?? [];
    final quickPicks = recentTracks.length >= 4
        ? recentTracks.take(6).toList()
        : ref.watch(quickPicksProvider);
    final continueListening = recentTracks.isNotEmpty
        ? recentTracks.first
        : ref.watch(continueListeningProvider);
    final trending = ref.watch(trendingSongsProvider);
    final chillLoFi = ref.watch(chillLoFiProvider);
    final freshDiscoveries = ref.watch(freshDiscoveriesProvider);
    final featuredArtists = ref.watch(featuredArtistsProvider);
    final featuredAlbums = ref.watch(featuredAlbumsProvider);

    final recState = ref.watch(recommendationStateProvider);
    final madeForYouRecs = recState.sections[RecommendationSection.madeForYou]?.map((r) => r.song).toList() ?? [];
    final becauseYouLikedRecs = recState.sections[RecommendationSection.becauseYouLiked]?.map((r) => r.song).toList() ?? [];
    final discoverNewArtistsRecs = recState.sections[RecommendationSection.discoverNewArtists]?.map((r) => r.song).toList() ?? [];

    final playerState = ref.watch(playerNotifierProvider);
    final currentSong = playerState.currentSong;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(recommendationStateProvider.notifier).refresh();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              const SliverToBoxAdapter(child: GreetingHeader()),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space8),
              ),

              // Quick Picks
              const SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Quick Picks',
                  subtitle: 'Jump back into your recent rotation',
                ),
              ),
              SliverToBoxAdapter(child: QuickPicksGrid(songs: quickPicks)),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space16),
              ),

              // Continue Listening Banner
              if (continueListening != null) ...[
                SliverToBoxAdapter(
                  child: ContinueListeningBanner(song: continueListening),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.space16),
                ),
              ],

              // Made For You (Personalized recommendations)
              if (madeForYouRecs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: HorizontalSection(
                    title: 'Made For You',
                    subtitle: 'Tailored algorithms aligned with your listening profile',
                    songs: madeForYouRecs,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.space16),
                ),
              ],

              // Because You Liked
              if (becauseYouLikedRecs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: HorizontalSection(
                    title: 'Because You Liked',
                    subtitle: 'Echoing the rhythm and atmosphere of your favorites',
                    songs: becauseYouLikedRecs,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.space16),
                ),
              ],

              // Trending Now
              SliverToBoxAdapter(
                child: HorizontalSection(
                  title: 'Trending Now',
                  subtitle: 'Top charts across the Melo community',
                  songs: trending,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space16),
              ),

              // Chill / Lo-Fi
              SliverToBoxAdapter(
                child: HorizontalSection(
                  title: 'Chill & Lo-Fi Aura',
                  subtitle: 'Downtempo beats and relaxing frequencies',
                  songs: chillLoFi,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space16),
              ),

              // Featured Artists
              SliverToBoxAdapter(
                child: ArtistsSection(
                  title: 'Featured Creators',
                  subtitle: 'Pioneers shaping new sonic horizons',
                  artists: featuredArtists,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space16),
              ),

              // Featured Albums
              SliverToBoxAdapter(
                child: AlbumsSection(
                  title: 'Essential Albums',
                  subtitle: 'Complete conceptual listening experiences',
                  albums: featuredAlbums,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space16),
              ),

              // Fresh Discoveries
              SliverToBoxAdapter(
                child: HorizontalSection(
                  title: 'Fresh Discoveries',
                  subtitle: 'New tracks handpicked for your radar',
                  songs: freshDiscoveries,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space16),
              ),

              // Discover New Artists
              if (discoverNewArtistsRecs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: HorizontalSection(
                    title: 'Discover New Artists',
                    subtitle: 'Step beyond familiar boundaries with emerging creators',
                    songs: discoverNewArtistsRecs,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.space16),
                ),
              ],

              // Top Tracks Ranked List
              const SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Global Top 10',
                  subtitle: 'Most streamed tracks right now',
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final song = trending[index];
                    return SongTile(
                      index: index + 1,
                      song: song,
                      isPlaying:
                          currentSong?.id == song.id && playerState.isPlaying,
                      isFavorite: playerState.isSongFavorite(song.id),
                      onFavoriteToggle: () {
                        ref
                            .read(playerNotifierProvider.notifier)
                            .toggleFavorite(song.id, song);
                      },
                      onTap: () {
                        ref
                            .read(playerNotifierProvider.notifier)
                            .play(song, queue: trending);
                      },
                    );
                  }, childCount: trending.length),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space40),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

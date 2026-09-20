import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/home/presentation/widgets/greeting_header.dart';
import 'package:melo/features/home/presentation/widgets/home_song_tile.dart';
import 'package:melo/features/home/presentation/widgets/horizontal_section.dart';
import 'package:melo/features/home/providers/home_provider.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/widgets/section_header.dart';

/// Primary Home screen for Melo showcasing personalized feeds, trending music, and recent tracks.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayed = ref.watch(recentlyPlayedProvider);
    final recommended = ref.watch(recommendedSongsProvider);
    final trending = ref.watch(trendingSongsProvider);
    final currentSong = ref.watch(playerNotifierProvider).currentSong;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Simulated feed refresh for Phase 1
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: GreetingHeader()),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space8),
              ),

              // Recently Played Section
              SliverToBoxAdapter(
                child: HorizontalSection(
                  title: 'Recently Played',
                  subtitle: 'Jump back into your favorites',
                  songs: recentlyPlayed,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space16),
              ),

              // Recommended For You Section
              SliverToBoxAdapter(
                child: HorizontalSection(
                  title: 'Made For You',
                  subtitle: 'Fresh sounds based on your taste',
                  songs: recommended,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space16),
              ),

              // Trending Tracks Section
              const SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'Trending Tracks',
                  subtitle: 'Most played across the community this week',
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final song = trending[index];
                  return HomeSongTile(
                    rank: index + 1,
                    song: song,
                    isPlaying: currentSong?.id == song.id,
                    onTap: () {
                      ref
                          .read(playerNotifierProvider.notifier)
                          .play(song, queue: trending);
                    },
                  );
                }, childCount: trending.length),
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

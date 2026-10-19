import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/database/database_providers.dart';
import 'package:melo/core/recommendations/domain/recommendation.dart';
import 'package:melo/core/recommendations/providers/ai_playlist_providers.dart';
import 'package:melo/core/recommendations/providers/recommendation_providers.dart';
import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/features/home/presentation/widgets/ai_playlists_section.dart';
import 'package:melo/features/home/presentation/widgets/albums_section.dart';
import 'package:melo/features/home/presentation/widgets/artists_section.dart';
import 'package:melo/features/home/presentation/widgets/continue_listening_banner.dart';
import 'package:melo/features/home/presentation/widgets/greeting_header.dart';
import 'package:melo/features/home/presentation/widgets/horizontal_section.dart';
import 'package:melo/features/home/presentation/widgets/quick_picks_grid.dart';
import 'package:melo/features/home/providers/home_provider.dart';
import 'package:melo/features/onboarding/presentation/screens/onboarding_taste_screen.dart';
import 'package:melo/features/playlists/presentation/widgets/ai_mashup_dialog.dart';
import 'package:melo/features/playlists/presentation/widgets/ai_playlist_creator_dialog.dart';
import 'package:melo/features/playlists/presentation/widgets/youtube_sync_dialog.dart';
import 'package:melo/shared/models/song.dart';
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
    final indianHits = ref.watch(indianHitsProvider);
    final featuredArtists = ref.watch(featuredArtistsProvider);
    final featuredAlbums = ref.watch(featuredAlbumsProvider);
    final aiPlaylists = ref.watch(aiPlaylistsProvider);

    final prefs = ref.watch(userPreferencesNotifierProvider);
    final allowPersonalized = prefs.personalizedRecommendations;

    final recState = ref.watch(recommendationStateProvider);
    final madeForYouRecs = allowPersonalized
        ? (recState.sections[RecommendationSection.madeForYou]
                  ?.map((r) => r.song)
                  .toList() ??
              [])
        : <Song>[];
    final becauseYouLikedRecs = allowPersonalized
        ? (recState.sections[RecommendationSection.becauseYouLiked]
                  ?.map((r) => r.song)
                  .toList() ??
              [])
        : <Song>[];
    final discoverNewArtistsRecs =
        recState.sections[RecommendationSection.discoverNewArtists]
            ?.map((r) => r.song)
            .toList() ??
        [];

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

              // Spotify-Style Taste Onboarding Banner
              if (!prefs.hasCompletedOnboarding)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space16,
                      vertical: AppDimensions.space4,
                    ),
                    child: InkWell(
                      onTap: () => OnboardingTasteScreen.show(context),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tune Your Musical Taste',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Pick your favorite artists & languages for Spotify-style AI mixes.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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

              // Spotify-Style AI Studio & Personalized Blend Hub
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space16,
                    vertical: AppDimensions.space4,
                  ),
                  child: Row(
                    children: [
                      // AI Blend / Mashup Studio
                      Expanded(
                        child: InkWell(
                          onTap: () => AiMashupDialog.show(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.bolt_rounded, color: Colors.white, size: 22),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 16),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'AI Mashup Studio',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Blend two artists / vibes',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),

                      // Personalized AI Playlist
                      Expanded(
                        child: InkWell(
                          onTap: () => AiPlaylistCreatorDialog.show(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14.0),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEC4899), Color(0xFFE11D48)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFEC4899).withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                                    Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 16),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Personalized AI',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Generate vibe playlist',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space4),
              ),

              // YouTube Sync & Taste Re-tuning quick row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.space16,
                    vertical: AppDimensions.space4,
                  ),
                  child: Row(
                    children: [
                      // YouTube Sync Button
                      Expanded(
                        child: InkWell(
                          onTap: () => YouTubeSyncDialog.show(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFF0000).withValues(alpha: 0.35),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: Color(0xFFFF0000),
                                  size: 26,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sync YouTube',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Import playlists & mixes',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),

                      // Re-tune Preferences
                      Expanded(
                        child: InkWell(
                          onTap: () => OnboardingTasteScreen.show(context),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.tune_rounded,
                                  color: AppColors.primary,
                                  size: 26,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Taste Profile',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Artists & languages',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: AppDimensions.space16),
              ),

              // Made For You: Spotify-Style AI Playlists & Daily Mixes
              if (allowPersonalized && aiPlaylists.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: AiPlaylistsSection(
                    playlists: aiPlaylists,
                    title: 'Made For You • AI Mixes',
                    subtitle:
                        'Playlists synthesized in real-time from your searches & listening',
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.space16),
                ),
              ],

              // Made For You (Personalized individual recommendations)
              if (madeForYouRecs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: HorizontalSection(
                    title: 'Recommended Songs',
                    subtitle: 'Tailored tracks aligned with your listening profile',
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
                    subtitle:
                        'Echoing the rhythm and atmosphere of your favorites',
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

              // Desi & Indian Hits (Bollywood, Punjabi, Bhojpuri, Haryanvi, Retro)
              if (indianHits.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: HorizontalSection(
                    title: 'Desi Dhamaka & Indian Hits',
                    subtitle: 'Trending Bollywood, Punjabi, Bhojpuri, Haryanvi & Retro',
                    songs: indianHits,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.space16),
                ),
              ],

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

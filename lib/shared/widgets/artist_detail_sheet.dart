import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/saavn_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../features/player/providers/player_provider.dart';
import '../models/artist.dart';
import '../models/song.dart';
import 'aura_artwork.dart';
import 'song_tile.dart';

/// Full-fidelity bottom sheet presenting an artist's discography, top tracks, and quick playback.
class ArtistDetailSheet extends ConsumerStatefulWidget {
  final Artist artist;

  const ArtistDetailSheet({super.key, required this.artist});

  static Future<void> show(BuildContext context, Artist artist) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ArtistDetailSheet(artist: artist),
    );
  }

  @override
  ConsumerState<ArtistDetailSheet> createState() => _ArtistDetailSheetState();
}

class _ArtistDetailSheetState extends ConsumerState<ArtistDetailSheet> {
  bool _isLoading = true;
  List<Song> _artistTracks = [];
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.artist.isFollowed;
    _loadArtistTracks();
  }

  Future<void> _loadArtistTracks() async {
    try {
      final saavn = ref.read(saavnServiceProvider);
      final tracks = await saavn.searchSongs(widget.artist.name, limit: 12);
      if (mounted) {
        setState(() {
          _artistTracks = tracks;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerNotifierProvider);
    final currentSong = playerState.currentSong;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Pull Bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Scrollable Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20),
                  children: [
                    const SizedBox(height: 12),

                    // Artist Header Avatar & Bio
                    Center(
                      child: Column(
                        children: [
                          AuraArtwork(
                            seed: widget.artist.name,
                            size: 110,
                            borderRadius: BorderRadius.circular(55),
                            fallbackIcon: Icons.person_rounded,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.artist.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.artist.genre} • ${widget.artist.formattedListeners}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Action Buttons Row: Play All & Follow
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                onPressed: _artistTracks.isNotEmpty
                                    ? () {
                                        ref
                                            .read(playerNotifierProvider.notifier)
                                            .play(_artistTracks.first, queue: _artistTracks);
                                      }
                                    : null,
                                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                                label: const Text(
                                  'Play Top Tracks',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: _isFollowing ? AppColors.primary : AppColors.surfaceBorder,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() => _isFollowing = !_isFollowing);
                                },
                                child: Text(
                                  _isFollowing ? 'Following' : 'Follow',
                                  style: TextStyle(
                                    color: _isFollowing ? AppColors.primary : AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Top Tracks Header
                    const Text(
                      'Popular Tracks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else if (_artistTracks.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text(
                            'No tracks available for this artist.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      ...List.generate(_artistTracks.length, (index) {
                        final song = _artistTracks[index];
                        final isPlaying = currentSong?.id == song.id && playerState.isPlaying;

                        return SongTile(
                          index: index + 1,
                          song: song,
                          isPlaying: isPlaying,
                          isFavorite: playerState.isSongFavorite(song.id),
                          onFavoriteToggle: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .toggleFavorite(song.id, song);
                          },
                          onTap: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .play(song, queue: _artistTracks);
                          },
                        );
                      }),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

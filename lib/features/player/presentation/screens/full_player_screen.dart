import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:melo/core/downloads/download_providers.dart';
import 'package:melo/core/downloads/download_state.dart';
import 'package:melo/core/recommendations/providers/recommendation_providers.dart';
import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/core/theme/app_dimensions.dart';
import 'package:melo/core/utils/duration_formatter.dart';
import 'package:melo/features/downloads/domain/download_metadata_repository.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/models/song.dart';
import 'package:melo/shared/widgets/aura_artwork.dart';

import 'package:melo/features/playlists/presentation/widgets/add_to_playlist_sheet.dart';
import '../widgets/queue_sheet.dart';
import '../widgets/realtime_lyrics_sheet.dart';

/// Full-screen immersive player UI for Melo (Melo Dark Aura).
class FullPlayerScreen extends ConsumerWidget {
  const FullPlayerScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const FullPlayerScreen(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerState = ref.watch(playerNotifierProvider);
    final song = playerState.currentSong;

    if (song == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('No song playing')),
      );
    }

    final isFavorite = playerState.isCurrentFavorite;
    final isDownloaded = playerState.isCurrentDownloaded;
    final isPlaying = playerState.isPlaying;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final artworkSize = (availableHeight * 0.38).clamp(200.0, 310.0);

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Navigation Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        iconSize: 32,
                        color: AppColors.textSecondary,
                        tooltip: 'Collapse',
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Column(
                        children: [
                          const Text(
                            'PLAYING FROM PLAYLIST',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.album.isNotEmpty
                                ? song.album
                                : 'Melo Daily Flow',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_horiz_rounded),
                        color: AppColors.textSecondary,
                        tooltip: 'Options',
                        onPressed: () {
                          _showSongOptionsSheet(context, ref, song);
                        },
                      ),
                    ],
                  ),

                  // Center Large Artwork with Radiant Glow
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AuraArtwork(
                      seed: song.id + song.title,
                      imageUrl: song.artworkUrl,
                      size: artworkSize,
                      borderRadius: BorderRadius.circular(24),
                      showGlow: true,
                    ),
                  ),

                  // Metadata & Favorite Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.4,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 28,
                          ),
                          tooltip: isFavorite ? 'Unlike' : 'Like',
                          onPressed: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .toggleFavorite(song.id, song);
                          },
                        ),
                      ],
                    ),
                  ),

                  // Interactive Progress Scrubber
                  Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.progressTrack,
                          thumbColor: Colors.white,
                          overlayColor: AppColors.primary.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        child: Slider(
                          value: playerState.position.inSeconds
                              .toDouble()
                              .clamp(
                                0.0,
                                playerState.duration.inSeconds.toDouble() > 0
                                    ? playerState.duration.inSeconds.toDouble()
                                    : 1.0,
                              ),
                          max: playerState.duration.inSeconds.toDouble() > 0
                              ? playerState.duration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (val) {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .seek(Duration(seconds: val.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DurationFormatter.format(playerState.position),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              DurationFormatter.format(playerState.duration),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Main Playback Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Shuffle Button
                        IconButton(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: playerState.isShuffle
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 24,
                          ),
                          tooltip: 'Shuffle',
                          onPressed: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .toggleShuffle();
                          },
                        ),

                        // Skip Previous
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: AppColors.textPrimary,
                            size: 38,
                          ),
                          tooltip: 'Previous',
                          onPressed: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .previous();
                          },
                        ),

                        // Play/Pause Glowing Button
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .togglePlayPause();
                          },
                          child: Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.primary, Color(0xFF9333EA)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.45,
                                  ),
                                  blurRadius: 22,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child:
                                (playerState.isLoading ||
                                    playerState.isBuffering)
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                          ),
                        ),

                        // Skip Next
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: AppColors.textPrimary,
                            size: 38,
                          ),
                          tooltip: 'Next',
                          onPressed: () {
                            ref.read(playerNotifierProvider.notifier).next();
                          },
                        ),

                        // Repeat Button
                        IconButton(
                          icon: Icon(
                            playerState.repeatMode == PlaybackRepeatMode.one
                                ? Icons.repeat_one_rounded
                                : Icons.repeat_rounded,
                            color: playerState.isRepeat
                                ? AppColors.primary
                                : AppColors.textTertiary,
                            size: 24,
                          ),
                          tooltip: 'Repeat',
                          onPressed: () {
                            ref
                                .read(playerNotifierProvider.notifier)
                                .cycleRepeatMode();
                          },
                        ),
                      ],
                    ),
                  ),

                  // Spotify-Style Mini Lyrics Preview Card
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => RealtimeLyricsSheet.show(context, song),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.lyrics_rounded,
                              color: AppColors.secondary,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Lyrics • Tap for Real-Time Karaoke',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom Action Bar: Hi-Res Badge, Lyrics, Playlist, Download, Queue
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Audio Quality Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.surfaceBorder),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                size: 12,
                                color: AppColors.secondary,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Lossless',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Real-Time Synced Lyrics button
                        IconButton(
                          icon: const Icon(
                            Icons.lyrics_rounded,
                            color: AppColors.secondary,
                            size: 22,
                          ),
                          tooltip: 'Real-Time Lyrics',
                          onPressed: () {
                            RealtimeLyricsSheet.show(context, song);
                          },
                        ),

                        // Add to Playlist button
                        IconButton(
                          icon: const Icon(
                            Icons.playlist_add_rounded,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                          tooltip: 'Add to Playlist',
                          onPressed: () {
                            AddToPlaylistSheet.show(context, song);
                          },
                        ),

                        // Download button with full state support
                        _buildDownloadButton(context, ref, song, isDownloaded),

                        // More Like This button
                        IconButton(
                          icon: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                          tooltip: 'More Like This',
                          onPressed: () {
                            _showSimilarSongsSheet(context, ref, song);
                          },
                        ),

                        // Queue button
                        IconButton(
                          icon: const Icon(
                            Icons.queue_music_rounded,
                            color: AppColors.textSecondary,
                            size: 24,
                          ),
                          tooltip: 'Queue',
                          onPressed: () {
                            QueueSheet.show(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSongOptionsSheet(
    BuildContext context,
    WidgetRef ref,
    Song song,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.playlist_add_rounded, color: AppColors.secondary),
                title: const Text('Add to Playlist', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('Add to an existing or new playlist', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  AddToPlaylistSheet.show(context, song);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lyrics_rounded, color: AppColors.primary),
                title: const Text('Real-Time Lyrics', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('View synced lyrics with auto-scroll', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  RealtimeLyricsSheet.show(context, song);
                },
              ),
              ListTile(
                leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.tertiary),
                title: const Text('More Like This', style: TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('Discover similar recommendations', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showSimilarSongsSheet(context, ref, song);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSimilarSongsSheet(
    BuildContext context,
    WidgetRef ref,
    Song song,
  ) async {
    final engine = ref.read(recommendationEngineProvider);
    final similar = await engine.getSimilarSongs(song, limit: 10);
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'More Like "${song.title}"',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (similar.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No similar tracks found in catalog.',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: similar.length,
                  itemBuilder: (c, i) {
                    final item = similar[i];
                    return ListTile(
                      dense: true,
                      leading: AuraArtwork(
                        seed: item.id,
                        imageUrl: item.artworkUrl,
                        size: 40,
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        item.artist,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          ref.read(playerNotifierProvider.notifier).play(item);
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(
    BuildContext context,
    WidgetRef ref,
    Song song,
    bool isDownloaded,
  ) {
    if (!song.isDownloadable) {
      return IconButton(
        icon: const Icon(
          Icons.download_rounded,
          color: AppColors.textTertiary,
          size: 22,
        ),
        tooltip: "Offline download isn't available for this track.",
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Offline download isn't available for this track."),
              duration: Duration(seconds: 2),
              backgroundColor: AppColors.surfaceHighlight,
            ),
          );
        },
      );
    }

    final downloadAsync = ref.watch(trackDownloadStateProvider(song.id));
    final dlState =
        downloadAsync.valueOrNull ??
        (isDownloaded
            ? TrackDownloadState(
                songId: song.id,
                status: DownloadStatus.completed,
                progress: 1.0,
              )
            : TrackDownloadState.notDownloaded(song.id));

    final manager = ref.read(downloadManagerProvider);

    if (dlState.isDownloading) {
      return SizedBox(
        width: 40,
        height: 40,
        child: IconButton(
          icon: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: dlState.progress > 0 ? dlState.progress : null,
                strokeWidth: 2.2,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.secondary,
                ),
              ),
              Text(
                '${(dlState.progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          tooltip: 'Cancel Download (${(dlState.progress * 100).toInt()}%)',
          onPressed: () => manager.cancelDownload(song.id),
        ),
      );
    }

    if (dlState.isCompleted || isDownloaded) {
      return IconButton(
        icon: const Icon(
          Icons.download_done_rounded,
          color: AppColors.tertiary,
          size: 22,
        ),
        tooltip: 'Downloaded (Offline)',
        onPressed: () {
          showDialog(
            context: context,
            builder: (dialogCtx) => AlertDialog(
              backgroundColor: AppColors.surfaceElevated,
              title: const Text('Remove Download?'),
              content: Text('Remove "${song.title}" from offline downloads?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                  ),
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    manager.removeDownload(song);
                    ref
                        .read(playerNotifierProvider.notifier)
                        .toggleDownload(song.id, song);
                  },
                  child: const Text('Remove'),
                ),
              ],
            ),
          );
        },
      );
    }

    if (dlState.isFailed) {
      return IconButton(
        icon: const Icon(
          Icons.refresh_rounded,
          color: AppColors.error,
          size: 22,
        ),
        tooltip: 'Download failed. Tap to retry.',
        onPressed: () {
          final downloadableSong = song.copyWith(
            isDownloadable: true,
            downloadUrl: (song.downloadUrl != null && song.downloadUrl!.isNotEmpty)
                ? song.downloadUrl
                : song.streamUrl,
          );
          manager.retryDownload(downloadableSong);
        },
      );
    }

    // Not downloaded yet
    return IconButton(
      icon: const Icon(
        Icons.download_rounded,
        color: AppColors.textSecondary,
        size: 22,
      ),
      tooltip: 'Download for offline playback',
      onPressed: () {
        final downloadableSong = song.copyWith(
          isDownloadable: true,
          downloadUrl: (song.downloadUrl != null && song.downloadUrl!.isNotEmpty)
              ? song.downloadUrl
              : song.streamUrl,
        );
        manager.downloadTrack(downloadableSong);
        ref.read(playerNotifierProvider.notifier).toggleDownload(song.id, downloadableSong);
      },
    );
  }
}

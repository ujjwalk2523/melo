import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/youtube/youtube_sync_service.dart';
import '../../../../shared/models/playlist.dart';
import '../../../../shared/widgets/aura_artwork.dart';
import '../../../player/providers/player_provider.dart';
import 'playlist_detail_sheet.dart';

/// Modal dialog allowing users to connect and synchronize their YouTube playlists into Melo.
class YouTubeSyncDialog extends ConsumerStatefulWidget {
  const YouTubeSyncDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const YouTubeSyncDialog(),
    );
  }

  @override
  ConsumerState<YouTubeSyncDialog> createState() => _YouTubeSyncDialogState();
}

class _YouTubeSyncDialogState extends ConsumerState<YouTubeSyncDialog> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  YouTubeSyncResult? _syncResult;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _startSync([String? customUrl]) async {
    final target = (customUrl ?? _urlController.text).trim();
    if (target.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _syncResult = null;
    });

    try {
      final syncService = ref.read(youTubeSyncServiceProvider);
      final playlistRepo = ref.read(playlistRepositoryProvider);

      final result = await syncService.syncPlaylist(
        input: target,
        playlistRepo: playlistRepo,
        ref: ref,
      );

      if (mounted) {
        setState(() {
          _syncResult = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not synchronize playlist: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_circle_fill_rounded,
                      color: Color(0xFFFF0000),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sync YouTube Playlist',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Import your favorite tracks & recommendations',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_syncResult != null) ...[
                // Success View
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFF0000).withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF10B981),
                        size: 36,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _syncResult!.playlistTitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Matched ${_syncResult!.matchedCount} songs with 320kbps Lossless Audio',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Location banner explaining where to find this playlist
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.folder_special_rounded, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: 'Saved in ',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  children: [
                                    TextSpan(
                                      text: 'Library > Playlists',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    TextSpan(text: ' tab for offline play.'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Quick action buttons
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              ),
                              onPressed: () {
                                final pl = Playlist(
                                  id: _syncResult!.createdPlaylistId ?? 'pl_${DateTime.now().millisecondsSinceEpoch}',
                                  title: _syncResult!.playlistTitle,
                                  description: _syncResult!.playlistDescription ?? 'Synced from YouTube Playlist',
                                  artworkUrl: _syncResult!.artworkUrl ?? '',
                                  songs: _syncResult!.songs,
                                  isCurated: false,
                                  creator: 'You',
                                );
                                Navigator.of(context).pop();
                                PlaylistDetailSheet.show(context, pl);
                              },
                              icon: const Icon(Icons.queue_music_rounded, size: 18),
                              label: const Text(
                                'View Playlist',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(color: AppColors.surfaceBorder),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            ),
                            onPressed: () {
                              if (_syncResult!.songs.isNotEmpty) {
                                ref
                                    .read(playerNotifierProvider.notifier)
                                    .play(_syncResult!.songs.first, queue: _syncResult!.songs);
                                Navigator.of(context).pop();
                              }
                            },
                            icon: const Icon(Icons.play_arrow_rounded, size: 18),
                            label: const Text(
                              'Play All',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Tracks in Playlist section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Songs (${_syncResult!.songs.length})',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'Tap any song to play',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Scrollable song list
                Container(
                  height: 230,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Scrollbar(
                    thumbVisibility: true,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _syncResult!.songs.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1,
                        thickness: 0.5,
                        color: AppColors.surfaceBorder,
                      ),
                      itemBuilder: (context, index) {
                        final song = _syncResult!.songs[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              ref
                                  .read(playerNotifierProvider.notifier)
                                  .play(song, queue: _syncResult!.songs);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Playing "${song.title}" • ${_syncResult!.playlistTitle}'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 22,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                  AuraArtwork(
                                    seed: song.id,
                                    imageUrl: song.artworkUrl,
                                    size: 38,
                                    borderRadius: BorderRadius.circular(8),
                                    fallbackIcon: Icons.music_note_rounded,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          song.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          song.artist,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DurationFormatter.format(song.duration),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.play_circle_fill_rounded,
                                    size: 24,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ] else ...[
                // Input Form
                TextField(
                  controller: _urlController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'https://youtube.com/playlist?list=...',
                    hintStyle: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.link_rounded,
                      color: Color(0xFFFF0000),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFFF0000)),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Quick Presets
                const Text(
                  'Or choose popular YouTube charts:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      label: const Text('🇮🇳 Viral Top 50'),
                      backgroundColor: AppColors.surface,
                      onPressed: () {
                        _urlController.text = 'https://youtube.com/playlist?list=PL_viral_india';
                        _startSync('https://youtube.com/playlist?list=PL_viral_india');
                      },
                    ),
                    ActionChip(
                      label: const Text('🔥 Punjabi Beats'),
                      backgroundColor: AppColors.surface,
                      onPressed: () {
                        _urlController.text = 'https://youtube.com/playlist?list=PL_punjabi_trending';
                        _startSync('https://youtube.com/playlist?list=PL_punjabi_trending');
                      },
                    ),
                    ActionChip(
                      label: const Text('💃 Bhojpuri Dhamaka'),
                      backgroundColor: AppColors.surface,
                      onPressed: () {
                        _urlController.text = 'https://youtube.com/playlist?list=PL_bhojpuri_hits';
                        _startSync('https://youtube.com/playlist?list=PL_bhojpuri_hits');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Sync Action Button
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0000),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading ? null : () => _startSync(),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Fetching YouTube Tracks & Matching...',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Sync & Match Playlist',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

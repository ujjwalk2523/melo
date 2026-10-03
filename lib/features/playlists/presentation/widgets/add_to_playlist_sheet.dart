import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/song.dart';
import '../../../../shared/widgets/aura_artwork.dart';
import '../../domain/playlist_models.dart';

/// Modal bottom sheet allowing users to add any track to an existing playlist
/// or create a new playlist on-the-fly.
class AddToPlaylistSheet extends ConsumerStatefulWidget {
  final Song song;

  const AddToPlaylistSheet({super.key, required this.song});

  static Future<void> show(BuildContext context, Song song) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => AddToPlaylistSheet(song: song),
    );
  }

  @override
  ConsumerState<AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends ConsumerState<AddToPlaylistSheet> {
  bool _isCreating = false;

  Future<void> _handleAddToPlaylist(Playlist playlist) async {
    try {
      final repo = ref.read(playlistRepositoryProvider);
      await repo.addSongToPlaylist(playlist.id, widget.song);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Added "${widget.song.title}" to ${playlist.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.surfaceHighlight,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not add to playlist: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showCreatePlaylistDialog() async {
    final textController = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.surfaceBorder),
        ),
        title: const Text(
          'New Playlist',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Playlist Name',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Description (Optional)',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                Navigator.of(dialogCtx).pop(true);
              }
            },
            child: const Text('Create & Add'),
          ),
        ],
      ),
    );

    if (result == true && textController.text.trim().isNotEmpty) {
      final name = textController.text.trim();
      final desc = descController.text.trim().isEmpty ? null : descController.text.trim();

      setState(() => _isCreating = true);
      try {
        final repo = ref.read(playlistRepositoryProvider);
        final newPlaylist = await repo.createPlaylist(name, description: desc);
        await repo.addSongToPlaylist(newPlaylist.id, widget.song);

        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.playlist_add_check_rounded, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Created "$name" and added "${widget.song.title}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.surfaceHighlight,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create playlist: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistsAsync = ref.watch(userPlaylistsStreamProvider);

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Song info preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  AuraArtwork(
                    seed: widget.song.id + widget.song.title,
                    imageUrl: widget.song.artworkUrl,
                    size: 48,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ADD TO PLAYLIST',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          widget.song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.surfaceBorder, height: 20),

            // Action: Create New Playlist
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _isCreating ? null : _showCreatePlaylistDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, Color(0xFF9333EA)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
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
                                'Create New Playlist',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Create and instantly add this song',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Playlists List
            Flexible(
              child: playlistsAsync.when(
                data: (playlists) {
                  if (playlists.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 36, horizontal: 24),
                      child: Center(
                        child: Text(
                          'No existing playlists.\nTap "Create New Playlist" above!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: playlists.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: AppColors.surface.withValues(alpha: 0.5),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceHighlight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.queue_music_rounded,
                              color: AppColors.secondary,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            playlist.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            '${playlist.trackCount} ${playlist.trackCount == 1 ? 'track' : 'tracks'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.add_circle_outline_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onTap: () => _handleAddToPlaylist(playlist),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'Failed to load playlists: $err',
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

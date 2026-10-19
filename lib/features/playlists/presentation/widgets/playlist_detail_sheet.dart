import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../shared/data/mock_catalog.dart';
import '../../../../shared/models/playlist.dart';
import '../../../../shared/models/song.dart';
import '../../../../shared/widgets/aura_artwork.dart';
import '../../../../shared/widgets/song_tile.dart';
import '../../../player/providers/player_provider.dart';

/// Full Spotify-style Playlist Detail screen/sheet showing rich header,
/// play/shuffle controls, full tracklist, and options (Add, Rename, Delete, Save).
class PlaylistDetailSheet extends ConsumerStatefulWidget {
  final Playlist playlist;

  const PlaylistDetailSheet({super.key, required this.playlist});

  static void show(BuildContext context, Playlist playlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => PlaylistDetailSheet(playlist: playlist),
    );
  }

  @override
  ConsumerState<PlaylistDetailSheet> createState() => _PlaylistDetailSheetState();
}

class _PlaylistDetailSheetState extends ConsumerState<PlaylistDetailSheet> {
  String? _customTitle;

  bool get _isUserPlaylist =>
      widget.playlist.id.startsWith('pl_') ||
      !widget.playlist.isCurated ||
      widget.playlist.creator == 'You';

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerNotifierProvider);
    final currentSong = playerState.currentSong;

    // For user playlists, watch the real-time database stream of tracks
    final dbSongs = _isUserPlaylist
        ? ref.watch(playlistSongsStreamProvider(widget.playlist.id)).valueOrNull
        : null;
    final songs = dbSongs ?? widget.playlist.songs;
    final title = _customTitle ?? widget.playlist.title;

    final totalDuration = songs.fold(
      Duration.zero,
      (prev, s) => prev + s.duration,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: CustomScrollView(
        slivers: [
          // Top Bar with Dismiss Handle & Options Menu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 28),
                    color: AppColors.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (widget.playlist.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 12,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.playlist.badge!,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.9,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  // Options Menu Button
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                    color: AppColors.surfaceElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.surfaceBorder),
                    ),
                    onSelected: (val) {
                      switch (val) {
                        case 'add':
                          _showAddSongsSheet(context, widget.playlist.id, title);
                          break;
                        case 'rename':
                          _showRenameDialog(context, widget.playlist.id, title);
                          break;
                        case 'delete':
                          _confirmDeletePlaylist(context, widget.playlist.id, title);
                          break;
                        case 'save':
                          _saveToLibrary(context, title, songs);
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      if (_isUserPlaylist) ...[
                        const PopupMenuItem(
                          value: 'add',
                          child: Row(
                            children: [
                              Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
                              SizedBox(width: 12),
                              Text('Add Songs', style: TextStyle(color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'rename',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, color: AppColors.secondary, size: 20),
                              SizedBox(width: 12),
                              Text('Rename Playlist', style: TextStyle(color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                              SizedBox(width: 12),
                              Text('Delete Playlist', style: TextStyle(color: Colors.redAccent)),
                            ],
                          ),
                        ),
                      ] else ...[
                        const PopupMenuItem(
                          value: 'save',
                          child: Row(
                            children: [
                              Icon(Icons.bookmark_add_rounded, color: AppColors.primary, size: 20),
                              SizedBox(width: 12),
                              Text('Save to My Library', style: TextStyle(color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Playlist Header Hero Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  // Large Cover Art with Aura Glow
                  AuraArtwork(
                    seed: widget.playlist.id + title,
                    imageUrl: widget.playlist.artworkUrl,
                    size: 190,
                    borderRadius: BorderRadius.circular(20),
                    showGlow: true,
                    fallbackIcon: Icons.queue_music_rounded,
                  ),
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  if (widget.playlist.description.isNotEmpty)
                    Text(
                      widget.playlist.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Metadata: Creator & Count & Duration
                  Text(
                    '${widget.playlist.creator} • ${songs.length} tracks • ${DurationFormatter.format(totalDuration)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons: Play All, Shuffle & Add Songs
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Big Play Button
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 6,
                          shadowColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 22),
                        label: const Text(
                          'Play All',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        onPressed: songs.isEmpty
                            ? null
                            : () {
                                ref.read(playerNotifierProvider.notifier).play(
                                      songs.first,
                                      queue: songs,
                                    );
                                Navigator.of(context).pop();
                              },
                      ),
                      const SizedBox(width: 12),

                      // Shuffle Button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.surfaceBorder),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        icon: const Icon(Icons.shuffle_rounded, size: 18, color: AppColors.secondary),
                        label: const Text('Shuffle', style: TextStyle(fontSize: 13)),
                        onPressed: songs.isEmpty
                            ? null
                            : () {
                                final shuffled = List<Song>.from(songs)..shuffle();
                                ref.read(playerNotifierProvider.notifier).play(
                                      shuffled.first,
                                      queue: shuffled,
                                    );
                                Navigator.of(context).pop();
                              },
                      ),

                      if (_isUserPlaylist) ...[
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceHighlight,
                            foregroundColor: AppColors.primary,
                          ),
                          icon: const Icon(Icons.add_rounded, size: 22),
                          tooltip: 'Add songs',
                          onPressed: () => _showAddSongsSheet(context, widget.playlist.id, title),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Divider(color: AppColors.surfaceBorder),
            ),
          ),

          // Tracklist or Empty State
          if (songs.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.queue_music_rounded,
                        size: 56,
                        color: AppColors.textTertiary.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'This playlist is empty',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Add songs from the catalog or your favorites to build your soundscape.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Add Songs Now'),
                        onPressed: () => _showAddSongsSheet(context, widget.playlist.id, title),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final song = songs[index];
                    final isPlaying = currentSong?.id == song.id && playerState.isPlaying;

                    return Dismissible(
                      key: Key('pl_${widget.playlist.id}_${song.id}'),
                      direction: _isUserPlaylist ? DismissDirection.endToStart : DismissDirection.none,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent.withValues(alpha: 0.25),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      ),
                      onDismissed: (_) {
                        if (_isUserPlaylist) {
                          ref.read(playlistRepositoryProvider).removeSongFromPlaylist(widget.playlist.id, song.id);
                        }
                      },
                      child: SongTile(
                        index: index + 1,
                        song: song,
                        isPlaying: isPlaying,
                        isFavorite: playerState.isSongFavorite(song.id),
                        onFavoriteToggle: () {
                          ref.read(playerNotifierProvider.notifier).toggleFavorite(song.id);
                        },
                        onTap: () {
                          ref.read(playerNotifierProvider.notifier).play(
                                song,
                                queue: songs,
                              );
                        },
                      ),
                    );
                  },
                  childCount: songs.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  void _showAddSongsSheet(BuildContext context, String playlistId, String playlistTitle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final catalogSongs = MockCatalog.songs.where((s) {
              if (query.isEmpty) return true;
              final q = query.toLowerCase();
              return s.title.toLowerCase().contains(q) ||
                  s.artist.toLowerCase().contains(q) ||
                  (s.genre?.toLowerCase().contains(q) ?? false);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Songs to "$playlistTitle"',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: AppColors.textSecondary,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    autofocus: false,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search songs or artists...',
                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        query = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: catalogSongs.length,
                      itemBuilder: (c, idx) {
                        final song = catalogSongs[idx];
                        return ListTile(
                          dense: true,
                          leading: AuraArtwork(seed: song.id, imageUrl: song.artworkUrl, size: 42),
                          title: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            song.artist,
                            maxLines: 1,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 24),
                            onPressed: () async {
                              await ref.read(playlistRepositoryProvider).addSongToPlaylist(playlistId, song);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Added "${song.title}" to playlist!'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, String playlistId, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Rename Playlist', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'New playlist name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await ref.read(playlistRepositoryProvider).renamePlaylist(playlistId, newName);
                if (mounted) {
                  setState(() => _customTitle = newName);
                }
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePlaylist(BuildContext context, String playlistId, String playlistTitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Playlist', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete "$playlistTitle"? This cannot be undone.',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await ref.read(playlistRepositoryProvider).deletePlaylist(playlistId);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _saveToLibrary(BuildContext context, String title, List<Song> songs) async {
    final repo = ref.read(playlistRepositoryProvider);
    final newPl = await repo.createPlaylist(title, description: 'Saved from Melo Curated Mix');
    for (final s in songs) {
      await repo.addSongToPlaylist(newPl.id, s);
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved "$title" with ${songs.length} tracks to your Library!'),
          backgroundColor: AppColors.surfaceHighlight,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

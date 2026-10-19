import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melo/core/database/database_providers.dart';
import 'package:melo/core/recommendations/ai_mashup_generator.dart';
import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/models/playlist.dart';
import 'package:melo/shared/widgets/song_tile.dart';

/// Interactive modal sheet allowing users to describe any vibe or pick curated
/// mood presets to generate a 18-20 track Personalized Spotify-style AI playlist.
class AiPlaylistCreatorDialog extends ConsumerStatefulWidget {
  const AiPlaylistCreatorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiPlaylistCreatorDialog(),
    );
  }

  @override
  ConsumerState<AiPlaylistCreatorDialog> createState() =>
      _AiPlaylistCreatorDialogState();
}

class _AiPlaylistCreatorDialogState
    extends ConsumerState<AiPlaylistCreatorDialog> {
  final TextEditingController _promptController = TextEditingController();
  Playlist? _generatedPlaylist;
  bool _isGenerating = false;
  bool _isSaving = false;

  static const List<Map<String, String>> _quickVibes = [
    {
      'label': '🚗 Late Night Drive',
      'prompt': 'Late night drive with soft Punjabi and synthwave beats',
    },
    {
      'label': '⚡ Gym Beast Mode',
      'prompt': 'High BPM energetic workout and intense rap beats',
    },
    {
      'label': '🌧️ Rainy Lo-Fi Study',
      'prompt': 'Rainy afternoon chill lo-fi and calming acoustic frequencies',
    },
    {
      'label': '💫 90s Romantic Bollywood',
      'prompt': 'Nostalgic romantic Bollywood melodies and soulful ballads',
    },
    {
      'label': '💻 Cyberpunk Focus',
      'prompt': 'Deep techno synthwave focus flow for night coding',
    },
    {
      'label': '🕺 Desi Party Bangers',
      'prompt': 'High energy Punjabi pop, Bollywood dance and club hits',
    },
  ];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _generate(String prompt) {
    final clean = prompt.trim();
    if (clean.isEmpty) return;

    setState(() {
      _isGenerating = true;
      _promptController.text = clean;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      final playlist = AiMashupGenerator.generatePersonalizedMoodPlaylist(
        moodPrompt: clean,
      );
      if (mounted) {
        setState(() {
          _generatedPlaylist = playlist;
          _isGenerating = false;
        });
      }
    });
  }

  Future<void> _saveToLibrary() async {
    final pl = _generatedPlaylist;
    if (pl == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(playlistRepositoryProvider);
      var safeTitle = pl.title.trim();
      if (safeTitle.length > 95) {
        safeTitle = '${safeTitle.substring(0, 92).trim()}...';
      }
      final created = await repo.createPlaylist(
        safeTitle,
        description: pl.description,
      );

      for (final song in pl.songs) {
        await repo.addSongToPlaylist(created.id, song);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.secondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Saved "${pl.title}" (${pl.songs.length} tracks) to your Library!',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save playlist: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pl = _generatedPlaylist;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.psychology_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personalized AI Playlist',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Spotify-style mood prompt synthesizer',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textTertiary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.surfaceBorder, height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Text prompt input
                  TextField(
                    controller: _promptController,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. 2 AM drive with soft punjabi & lofi...',
                      hintStyle: const TextStyle(color: AppColors.textTertiary),
                      prefixIcon: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
                        onPressed: () => _generate(_promptController.text),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.surfaceBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    onSubmitted: _generate,
                  ),

                  const SizedBox(height: 14),

                  // Quick Vibe Chips
                  const Text(
                    'POPULAR MOOD PRESETS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _quickVibes.map((vibe) {
                      return ActionChip(
                        label: Text(vibe['label']!),
                        backgroundColor: AppColors.surfaceElevated,
                        side: const BorderSide(color: AppColors.surfaceBorder),
                        labelStyle: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onPressed: () => _generate(vibe['prompt']!),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  if (_isGenerating)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: AppColors.primary),
                            SizedBox(height: 14),
                            Text(
                              'Synthesizing personalized vibe flow...',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (pl != null) ...[
                    // Generated Playlist Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'AI SYNTHESIZED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${pl.songs.length} Tracks',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            pl.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            pl.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (pl.songs.isNotEmpty) {
                                      ref
                                          .read(playerNotifierProvider.notifier)
                                          .play(pl.songs.first, queue: pl.songs);
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Playing "${pl.title}" (${pl.songs.length} tracks)',
                                          ),
                                          duration: const Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 20),
                                  label: const Text(
                                    'Play Now',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.surfaceBorder),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _isSaving ? null : _saveToLibrary,
                                  icon: _isSaving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.bookmark_add_rounded, color: AppColors.primary, size: 18),
                                  label: Text(
                                    _isSaving ? 'Saving...' : 'Save to Library',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Tracks List
                    Text(
                      'Tracks Included (${pl.songs.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    ...pl.songs.map((song) {
                      final isPlaying =
                          ref.watch(playerNotifierProvider).currentSong?.id == song.id;
                      return SongTile(
                        song: song,
                        isPlaying: isPlaying,
                        onTap: () {
                          ref
                              .read(playerNotifierProvider.notifier)
                              .play(song, queue: pl.songs);
                        },
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

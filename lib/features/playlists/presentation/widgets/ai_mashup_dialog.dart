import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melo/core/database/database_providers.dart';
import 'package:melo/core/recommendations/ai_mashup_generator.dart';
import 'package:melo/core/theme/app_colors.dart';
import 'package:melo/features/player/providers/player_provider.dart';
import 'package:melo/shared/widgets/song_tile.dart';

/// Modal bottom sheet allowing users to blend two artists, genres, or vibes into
/// a Spotify-style AI Mashup playlist with instant preview and library persistence.
class AiMashupDialog extends ConsumerStatefulWidget {
  const AiMashupDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiMashupDialog(),
    );
  }

  @override
  ConsumerState<AiMashupDialog> createState() => _AiMashupDialogState();
}

class _AiMashupDialogState extends ConsumerState<AiMashupDialog> {
  int _selectedRecipeIndex = 0;
  AiMashupResult? _currentMashup;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _generateFromPreset(0);
  }

  void _generateFromPreset(int index) {
    final recipe = AiMashupGenerator.presetMashups[index];
    final result = AiMashupGenerator.generateMashup(
      entityA: recipe['entityA'] as String,
      entityB: recipe['entityB'] as String,
      customColors: recipe['colors'] as List<Color>,
    );
    setState(() {
      _selectedRecipeIndex = index;
      _currentMashup = result;
    });
  }

  Future<void> _saveMashupToLibrary() async {
    if (_currentMashup == null || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(playlistRepositoryProvider);
      var safeTitle = _currentMashup!.title.trim();
      if (safeTitle.length > 95) {
        safeTitle = '${safeTitle.substring(0, 92).trim()}...';
      }
      final playlist = await repo.createPlaylist(
        safeTitle,
        description: '${_currentMashup!.description} • ${_currentMashup!.synergyScore}% Synergy Match',
      );

      for (final song in _currentMashup!.songs) {
        await repo.addSongToPlaylist(playlist.id, song);
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
                    'Saved "${_currentMashup!.title}" (${_currentMashup!.songs.length} tracks) to your Library!',
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
    final mashup = _currentMashup;
    final recipe = AiMashupGenerator.presetMashups[_selectedRecipeIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Spotify Blend & AI Mashup',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Harmonized crossover mixing two vibes',
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
                // Preset Recipe Chips
                const Text(
                  'POPULAR BLEND RECIPES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: AiMashupGenerator.presetMashups.length,
                    itemBuilder: (context, index) {
                      final item = AiMashupGenerator.presetMashups[index];
                      final isSelected = index == _selectedRecipeIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(item['name'] as String),
                          selected: isSelected,
                          onSelected: (_) => _generateFromPreset(index),
                          backgroundColor: AppColors.surfaceElevated,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Mashup Synergy Visual Banner
                if (mashup != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          mashup.gradientColors.first.withValues(alpha: 0.85),
                          mashup.gradientColors.last.withValues(alpha: 0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: mashup.gradientColors.first.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                mashup.firstEntity,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.black26,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                mashup.secondEntity,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          recipe['tagline'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Synergy Meter
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                color: Color(0xFFFACC15),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${mashup.synergyScore}% Sonic Synergy Match',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            if (mashup.songs.isNotEmpty) {
                              ref.read(playerNotifierProvider.notifier).play(
                                    mashup.songs.first,
                                    queue: mashup.songs,
                                  );
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Playing "${mashup.title}" (${mashup.songs.length} tracks)',
                                  ),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 22),
                          label: const Text(
                            'Play Mashup',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.surfaceBorder),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isSaving ? null : _saveMashupToLibrary,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.bookmark_add_rounded, color: AppColors.primary, size: 20),
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

                  const SizedBox(height: 20),

                  // Track Preview List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Interleaved Mashup Flow (${mashup.songs.length} Tracks)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'A • B Interleaved',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ...mashup.songs.map((song) {
                    final isPlaying =
                        ref.watch(playerNotifierProvider).currentSong?.id == song.id;
                    return SongTile(
                      song: song,
                      isPlaying: isPlaying,
                      onTap: () {
                        ref.read(playerNotifierProvider.notifier).play(
                              song,
                              queue: mashup.songs,
                            );
                      },
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

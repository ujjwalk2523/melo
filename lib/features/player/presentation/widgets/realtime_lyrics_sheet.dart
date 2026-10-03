import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/lyrics/lyrics_model.dart';
import '../../../../core/lyrics/lyrics_parser.dart';
import '../../../../core/lyrics/lyrics_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/song.dart';
import '../../providers/player_provider.dart';

/// Full-screen Spotify-style real-time synced lyrics viewer.
class RealtimeLyricsSheet extends ConsumerStatefulWidget {
  final Song song;

  const RealtimeLyricsSheet({super.key, required this.song});

  static void show(BuildContext context, Song song) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RealtimeLyricsSheet(song: song),
    );
  }

  @override
  ConsumerState<RealtimeLyricsSheet> createState() => _RealtimeLyricsSheetState();
}

class _RealtimeLyricsSheetState extends ConsumerState<RealtimeLyricsSheet> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};

  int _lastActiveIndex = -1;
  bool _userScrolled = false;
  Timer? _resumeSyncTimer;

  @override
  void dispose() {
    _scrollController.dispose();
    _resumeSyncTimer?.cancel();
    super.dispose();
  }

  void _scrollToActiveLine(int index) {
    if (_userScrolled || !_scrollController.hasClients) return;

    final key = _itemKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.35, // Position active line comfortably around 35% from the top
      );
    }
  }

  void _onUserScrollStart() {
    _userScrolled = true;
    _resumeSyncTimer?.cancel();
    _resumeSyncTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() => _userScrolled = false);
        if (_lastActiveIndex >= 0) {
          _scrollToActiveLine(_lastActiveIndex);
        }
      }
    });
  }

  void _syncImmediately() {
    setState(() => _userScrolled = false);
    _resumeSyncTimer?.cancel();
    if (_lastActiveIndex >= 0) {
      _scrollToActiveLine(_lastActiveIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lyricsAsync = ref.watch(songLyricsProvider(widget.song));
    final playerState = ref.watch(playerNotifierProvider);
    final currentPosition = playerState.position;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF101014),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Ambient glow gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Top navigation bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.mic_rounded, size: 13, color: AppColors.secondary),
                            SizedBox(width: 4),
                            Text(
                              'REAL-TIME LYRICS',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        color: AppColors.textSecondary,
                        iconSize: 28,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // Song Title & Artist banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: AppColors.surfaceBorder, height: 16),

                // Lyrics Content Area
                Expanded(
                  child: lyricsAsync.when(
                    data: (lyrics) {
                      if (!lyrics.hasLyrics) {
                        return _buildEmptyLyricsState();
                      }

                      if (lyrics.isSynced && lyrics.lines.isNotEmpty) {
                        return _buildSyncedLyricsList(lyrics.lines, currentPosition);
                      }

                      // Plain unsynced lyrics fallback
                      return _buildPlainLyricsView(lyrics.plainLyrics ?? '');
                    },
                    loading: () => const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 14),
                          Text(
                            'Fetching live lyrics...',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    error: (err, _) => _buildEmptyLyricsState(errorMessage: err.toString()),
                  ),
                ),
              ],
            ),
          ),

          // Floating "Sync with song" button when user scrolls manually
          if (_userScrolled)
            Positioned(
              bottom: 24,
              right: 20,
              child: FloatingActionButton.extended(
                elevation: 4,
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Sync to song',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                onPressed: _syncImmediately,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSyncedLyricsList(List<LyricLine> lines, Duration currentPosition) {
    final activeIndex = LyricsParser.findActiveIndex(currentPosition, lines);

    // If active line changed and user hasn't scrolled, schedule smooth auto-scroll
    if (activeIndex != _lastActiveIndex) {
      _lastActiveIndex = activeIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && activeIndex >= 0) {
          _scrollToActiveLine(activeIndex);
        }
      });
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification &&
            notification.dragDetails != null) {
          _onUserScrollStart();
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 40),
        itemCount: lines.length,
        itemBuilder: (context, index) {
          final line = lines[index];
          final isActive = index == activeIndex;
          final isPast = index < activeIndex;

          final key = _itemKeys.putIfAbsent(index, () => GlobalKey());

          // Skip completely empty lines if any
          if (line.text.trim().isEmpty) {
            return const SizedBox(height: 16);
          }

          return InkWell(
            key: key,
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              // Tap-to-seek: Seek directly to this line's timestamp!
              ref.read(playerNotifierProvider.notifier).seek(line.time);
              _syncImmediately();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: Text(
                line.text,
                style: TextStyle(
                  fontSize: isActive ? 22 : 18,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  height: 1.35,
                  letterSpacing: -0.2,
                  color: isActive
                      ? Colors.white
                      : (isPast
                          ? Colors.white.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.55)),
                  shadows: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlainLyricsView(String plainLyrics) {
    final lines = plainLyrics.split('\n');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        if (line.trim().isEmpty) return const SizedBox(height: 12);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            line,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.4,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyLyricsState({String? errorMessage}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lyrics_outlined,
              size: 48,
              color: AppColors.textTertiary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            const Text(
              'No lyrics found for this track',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Lyrics are not yet available in the public catalog for this song.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondary,
                side: const BorderSide(color: AppColors.surfaceBorder),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              onPressed: () {
                ref.invalidate(songLyricsProvider(widget.song));
              },
            ),
          ],
        ),
      ),
    );
  }
}

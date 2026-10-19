import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/song.dart';
import '../../../../shared/widgets/aura_artwork.dart';

/// Portrait vertical video / animated motion canvas simulating Spotify Canvas in 9:16 portrait orientation.
class SpotifyCanvasWidget extends StatefulWidget {
  final Song song;
  final bool isPlaying;

  const SpotifyCanvasWidget({
    super.key,
    required this.song,
    required this.isPlaying,
  });

  @override
  State<SpotifyCanvasWidget> createState() => _SpotifyCanvasWidgetState();
}

class _SpotifyCanvasWidgetState extends State<SpotifyCanvasWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(SpotifyCanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 9 / 16,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Canvas Shader / Organic Motion
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _CanvasMotionPainter(
                    progress: _controller.value,
                    seed: widget.song.title.hashCode,
                    accentColor: AppColors.primary,
                  ),
                );
              },
            ),

            // Soft Central Floating Artwork Silhouette
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final scale = 1.0 + 0.04 * math.sin(_controller.value * 2 * math.pi);
                  final rot = math.sin(_controller.value * 2 * math.pi) * 0.05;
                  return Transform.scale(
                    scale: scale,
                    child: Transform.rotate(
                      angle: rot,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AuraArtwork(
                      seed: widget.song.title + widget.song.artist,
                      size: 220,
                      imageUrl: widget.song.artworkUrl,
                    ),
                  ),
                ),
              ),
            ),

            // Top and Bottom Dark Scrim for High Typography Contrast
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.65),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.25, 0.7, 1.0],
                ),
              ),
            ),

            // Canvas Badge
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.movie_filter_rounded, size: 14, color: Colors.white70),
                    SizedBox(width: 4),
                    Text(
                      'CANVAS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CanvasMotionPainter extends CustomPainter {
  final double progress;
  final int seed;
  final Color accentColor;

  _CanvasMotionPainter({
    required this.progress,
    required this.seed,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Dark atmospheric base
    final bgPaint = Paint()..color = const Color(0xFF0F0B1E);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final random = math.Random(seed);
    final hue1 = (seed.abs() % 360).toDouble();
    final hue2 = (hue1 + 80) % 360;

    final color1 = HSVColor.fromAHSV(0.8, hue1, 0.8, 0.5).toColor();
    final color2 = HSVColor.fromAHSV(0.7, hue2, 0.85, 0.4).toColor();

    // Orb 1: Upper oscillating aurora
    final orb1Center = Offset(
      w * 0.4 + (w * 0.3) * math.sin(progress * 2 * math.pi),
      h * 0.35 + (h * 0.15) * math.cos(progress * 2 * math.pi),
    );
    final orb1Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color1.withValues(alpha: 0.7),
          color1.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: orb1Center, radius: w * 0.75));
    canvas.drawCircle(orb1Center, w * 0.75, orb1Paint);

    // Orb 2: Lower counter-oscillating aurora
    final orb2Center = Offset(
      w * 0.6 - (w * 0.35) * math.cos(progress * 2 * math.pi),
      h * 0.65 - (h * 0.2) * math.sin(progress * 2 * math.pi),
    );
    final orb2Paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color2.withValues(alpha: 0.6),
          color2.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: orb2Center, radius: w * 0.85));
    canvas.drawCircle(orb2Center, w * 0.85, orb2Paint);

    // Particle Stars / Fireflies
    final particlePaint = Paint()..color = Colors.white.withValues(alpha: 0.45);
    for (int i = 0; i < 28; i++) {
      final pX = (random.nextDouble() * w + math.sin((progress + i) * math.pi * 2) * 16) % w;
      final pY = (random.nextDouble() * h + math.cos((progress + i * 0.5) * math.pi * 2) * 20) % h;
      final radius = 1.0 + (i % 3) * 0.8;
      canvas.drawCircle(Offset(pX, pY), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(_CanvasMotionPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

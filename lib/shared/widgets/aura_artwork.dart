import 'package:flutter/material.dart';
import 'package:melo/core/theme/app_colors.dart';

/// High-fidelity procedural artwork component for Melo.
///
/// Renders an original ambient gradient and geometric wave texture derived
/// deterministically from the track or album seed string. If a network [imageUrl]
/// is provided, it gracefully displays the image with the procedural artwork as
/// a loading and error fallback.
class AuraArtwork extends StatelessWidget {
  final String seed;
  final String? imageUrl;
  final double size;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool showGlow;
  final IconData? fallbackIcon;

  const AuraArtwork({
    super.key,
    required this.seed,
    this.imageUrl,
    this.size = 56.0,
    this.width,
    this.height,
    this.borderRadius,
    this.showGlow = false,
    this.fallbackIcon,
  });

  // Curated Melo Aura gradient pairs
  static const List<List<Color>> _palettePairs = [
    [
      Color(0xFF7C3AED),
      Color(0xFF3B1D73),
      Color(0xFF12141F),
    ], // Electric Violet
    [Color(0xFF06B6D4), Color(0xFF0E4A56), Color(0xFF090A0F)], // Cyan Glow
    [Color(0xFF10B981), Color(0xFF064E3B), Color(0xFF12141F)], // Emerald Aurora
    [Color(0xFFF43F5E), Color(0xFF4C0519), Color(0xFF1A1D2E)], // Neon Rose
    [
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
      Color(0xFF090A0F),
    ], // Dual Violet-Cyan
    [Color(0xFFF59E0B), Color(0xFF78350F), Color(0xFF12141F)], // Solar Gold
    [Color(0xFF3B82F6), Color(0xFF1E3A8A), Color(0xFF090A0F)], // Deep Oceanic
  ];

  List<Color> get _gradientColors {
    final hash = seed.hashCode.abs();
    return _palettePairs[hash % _palettePairs.length];
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;
    final radius = borderRadius ?? BorderRadius.circular(size > 100 ? 20 : 12);
    final colors = _gradientColors;

    final childWidget = Container(
      width: effectiveWidth,
      height: effectiveHeight,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Procedural ambient pattern
          CustomPaint(
            painter: _AuraPatternPainter(
              accentColor: colors.first.withValues(alpha: 0.35),
              seedHash: seed.hashCode,
            ),
          ),

          // Central icon motif
          Center(
            child: Icon(
              fallbackIcon ?? _selectIconForSeed(seed),
              color: Colors.white.withValues(alpha: 0.75),
              size: (effectiveWidth * 0.38).clamp(16.0, 72.0),
            ),
          ),

          // Network image if provided
          if (imageUrl != null && imageUrl!.isNotEmpty)
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );

    if (showGlow) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.4),
              blurRadius: 32,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(borderRadius: radius, child: childWidget),
      );
    }

    return ClipRRect(borderRadius: radius, child: childWidget);
  }

  IconData _selectIconForSeed(String seed) {
    final code = seed.hashCode.abs() % 5;
    switch (code) {
      case 0:
        return Icons.music_note_rounded;
      case 1:
        return Icons.graphic_eq_rounded;
      case 2:
        return Icons.waves_rounded;
      case 3:
        return Icons.album_rounded;
      default:
        return Icons.headphones_rounded;
    }
  }
}

class _AuraPatternPainter extends CustomPainter {
  final Color accentColor;
  final int seedHash;

  _AuraPatternPainter({required this.accentColor, required this.seedHash});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final maxRadius = size.width * 0.7;

    // Concentric acoustic aura rings
    canvas.drawCircle(center, maxRadius * 0.35, paint);
    canvas.drawCircle(center, maxRadius * 0.65, paint);
    canvas.drawCircle(center, maxRadius * 0.95, paint);

    // Subtle diagonal scanline
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    for (double i = -size.height; i < size.width; i += 16) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AuraPatternPainter oldDelegate) => false;
}

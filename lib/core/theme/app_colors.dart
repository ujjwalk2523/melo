import 'package:flutter/material.dart';

/// Centralized color palette for Melo (Dark Aura theme).
///
/// Designed with an original identity: deep obsidian surfaces paired with
/// electric mint and cyan accents for an immersive, modern music experience.
abstract final class AppColors {
  // Brand & Accent Colors
  static const Color primary = Color(0xFF00E5BF); // Electric Mint / Cyan
  static const Color primaryContainer = Color(0xFF004D40);
  static const Color onPrimary = Color(0xFF00201A);

  static const Color secondary = Color(0xFF818CF8); // Electric Indigo
  static const Color secondaryContainer = Color(0xFF312E81);
  static const Color onSecondary = Color(0xFFFFFFFF);

  static const Color tertiary = Color(0xFFF472B6); // Rose glow accent
  static const Color tertiaryContainer = Color(0xFF831843);

  // Background & Surface Hierarchy
  static const Color background = Color(0xFF090A0C); // Deepest obsidian
  static const Color surface = Color(0xFF12151A); // Base surface
  static const Color surfaceElevated = Color(0xFF1A1E26); // Cards, sheets
  static const Color surfaceHighlight = Color(0xFF242A35); // Hover, active tile
  static const Color surfaceBorder = Color(0xFF2E3543); // Subtle dividers

  // Text & Content Hierarchy
  static const Color textPrimary = Color(0xFFF8FAFC); // High emphasis
  static const Color textSecondary = Color(0xFF94A3B8); // Medium emphasis
  static const Color textMuted = Color(0xFF64748B); // Low emphasis / hints
  static const Color textDisabled = Color(0xFF475569);

  // Status & Utility
  static const Color error = Color(0xFFF43F5E);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF38BDF8);

  // Audio / Player Specific
  static const Color progressTrack = Color(0xFF2D3748);
  static const Color progressActive = Color(0xFF00E5BF);
  static const Color miniPlayerBg = Color(0xE6141820); // Glass-like backdrop
}

import 'package:flutter/material.dart';

/// Centralized color palette for Melo (Melo Dark Aura theme).
///
/// Designed with an original identity: deep obsidian & charcoal indigo surfaces
/// paired with electric violet (#7C3AED) and cyan glow (#06B6D4) accents.
abstract final class AppColors {
  // Background & Surface Hierarchy
  static const Color background = Color(0xFF090A0F); // Deepest obsidian
  static const Color surface = Color(0xFF12141F); // Elevated base surface
  static const Color surfaceElevated = Color(
    0xFF1A1D2E,
  ); // Cards, bottom sheets
  static const Color surfaceHighlight = Color(
    0xFF24283B,
  ); // Active tiles, pressed
  static const Color surfaceBorder = Color(0xFF2E334D); // Subtle dividing lines
  static const Color surfaceBorderLight = Color(
    0x1FFFFFFF,
  ); // 12% translucent white

  // Brand Accents
  static const Color primary = Color(0xFF7C3AED); // Electric Violet
  static const Color primaryContainer = Color(0xFF3B1D73);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryGlow = Color(
    0x407C3AED,
  ); // 25% luminous violet glow

  static const Color secondary = Color(0xFF06B6D4); // Cyan Glow
  static const Color secondaryContainer = Color(0xFF0E4A56);
  static const Color onSecondary = Color(0xFF00151A);
  static const Color secondaryGlow = Color(0x4006B6D4);

  static const Color tertiary = Color(0xFF10B981); // Emerald Success / Liked
  static const Color tertiaryContainer = Color(0xFF064E3B);

  // Text & Typography
  static const Color textPrimary = Color(0xFFF8FAFC); // High emphasis
  static const Color textSecondary = Color(0xFF94A3B8); // Medium emphasis
  static const Color textTertiary = Color(0xFF64748B); // Low emphasis / hints
  static const Color textMuted = Color(0xFF64748B); // Alias for textTertiary
  static const Color textDisabled = Color(0xFF334155);

  // Status & Utility
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF06B6D4);

  // Audio / Player Specific
  static const Color progressTrack = Color(0xFF2E334D);
  static const Color progressActive = Color(0xFF7C3AED);
  static const Color miniPlayerBg = Color(
    0xF212141F,
  ); // 95% opacity dark indigo
  static const Color miniPlayerBorder = Color(
    0x337C3AED,
  ); // subtle violet border
}

import 'package:flutter/material.dart';

/// Nest Design System
/// 
/// Contains core constants for the ClientNest UI redesign, 
/// including the dedicated graph palette and layout spacing.
class NestDesignSystem {
  // === BRAND COLORS ===
  static const Color accent = Color(0xFF4C7CF3); // Refined Blue

  // === DARK THEME COLORS (Primary) ===
  static const Color darkBackground = Color(0xFF0B0D12);
  static const Color darkSurface = Color(0xFF141821);
  static const Color darkElevated = Color(0xFF1A1F2B);
  
  static const Color darkTextPrimary = Color(0xFFE8ECF3);
  static const Color darkTextSecondary = Color(0xFF9AA4B2);
  static const Color darkTextDisabled = Color(0xFF6B7280);

  // === LIGHT THEME COLORS ===
  static const Color lightBackground = Color(0xFFF6F8FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFEEF2F7);
  
  static const Color lightAccent = Color(0xFF3F6AE0); // Softened for light mode

  // === DEDICATED GRAPH PALETTE ===
  // Rules: Each dataset gets a unique color, soft gradients inside only.
  static const Color graphBlue = Color(0xFF4C7CF3);
  static const Color graphCyan = Color(0xFF22C7D6);
  static const Color graphPurple = Color(0xFFA56EFF);
  static const Color graphOrange = Color(0xFFFF9F43);
  static const Color graphPink = Color(0xFFFF6B9A);
  static const Color graphGreen = Color(0xFF2ECC71);

  static const List<Color> graphPalette = [
    graphBlue,
    graphCyan,
    graphPurple,
    graphOrange,
    graphPink,
    graphGreen,
  ];

  // === SEMANTIC COLORS ===
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF4C542);
  static const Color error = Color(0xFFE74C3C);

  // === LAYOUT & SPACING ===
  static const double spacingXS = 8.0;
  static const double spacingS = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 20.0;
  static const double spacingXL = 32.0;

  static const double borderRadius = 12.0;
  static const double borderRadiusL = 24.0;
  
  // === ANIMATIONS ===
  static const Duration animDuration = Duration(milliseconds: 300);
  static const Curve animCurve = Curves.easeInOutCubic;
  static const double tapScale = 0.98;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'nest_design_system.dart';

class AppTheme {
  /// Private helper for typography
  static TextTheme _buildTextTheme(TextTheme base, Color primary, Color secondary) {
    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge: GoogleFonts.outfit(
        color: primary, 
        fontWeight: FontWeight.w700, 
        letterSpacing: -1.5,
        fontSize: 32,
      ),
      displayMedium: GoogleFonts.outfit(
        color: primary, 
        fontWeight: FontWeight.w700, 
        letterSpacing: -1.0,
        fontSize: 28,
      ),
      displaySmall: GoogleFonts.outfit(
        color: primary, 
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      headlineMedium: GoogleFonts.outfit(
        color: primary, 
        fontWeight: FontWeight.w700, 
        letterSpacing: -0.5,
        fontSize: 20,
      ),
      headlineSmall: GoogleFonts.outfit(
        color: primary, 
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleLarge: GoogleFonts.outfit(
        color: primary, 
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleMedium: GoogleFonts.inter(
        color: primary, 
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      titleSmall: GoogleFonts.inter(
        color: primary, 
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      bodyLarge: GoogleFonts.inter(
        color: primary, 
        fontWeight: FontWeight.w400, 
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: primary, 
        fontWeight: FontWeight.w400, 
        fontSize: 14,
      ),
      bodySmall: GoogleFonts.inter(
        color: secondary, 
        fontWeight: FontWeight.w400, 
        fontSize: 12,
      ),
      labelLarge: GoogleFonts.inter(
        color: primary, 
        fontWeight: FontWeight.w600, 
        letterSpacing: 1.2,
        fontSize: 11,
      ),
      labelSmall: GoogleFonts.inter(
        color: secondary, 
        fontWeight: FontWeight.w500, 
        letterSpacing: 1.0,
        fontSize: 10,
      ),
    );
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: NestDesignSystem.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: NestDesignSystem.lightAccent,
      secondary: NestDesignSystem.darkTextSecondary,
      surface: NestDesignSystem.lightSurface,
      surfaceContainerHighest: NestDesignSystem.lightElevated,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: NestDesignSystem.darkBackground,
      error: NestDesignSystem.error,
    ),
    textTheme: _buildTextTheme(
      ThemeData.light().textTheme, 
      NestDesignSystem.darkBackground, 
      NestDesignSystem.darkTextSecondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: NestDesignSystem.darkBackground),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NestDesignSystem.borderRadius),
        ),
        backgroundColor: NestDesignSystem.lightAccent,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NestDesignSystem.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NestDesignSystem.borderRadius),
        borderSide: BorderSide(
          color: NestDesignSystem.darkBackground.withValues(alpha: 0.1), 
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NestDesignSystem.borderRadius),
        borderSide: BorderSide(
          color: NestDesignSystem.darkBackground.withValues(alpha: 0.1), 
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NestDesignSystem.borderRadius),
        borderSide: const BorderSide(color: NestDesignSystem.lightAccent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: NestDesignSystem.darkTextSecondary.withValues(alpha: 0.5)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: NestDesignSystem.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: NestDesignSystem.accent,
      secondary: NestDesignSystem.darkTextSecondary,
      surface: NestDesignSystem.darkSurface,
      surfaceContainerHighest: NestDesignSystem.darkElevated,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: NestDesignSystem.darkTextPrimary,
      error: NestDesignSystem.error,
    ),
    textTheme: _buildTextTheme(
      ThemeData.dark().textTheme, 
      NestDesignSystem.darkTextPrimary, 
      NestDesignSystem.darkTextSecondary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: NestDesignSystem.darkTextPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NestDesignSystem.borderRadius),
        ),
        backgroundColor: NestDesignSystem.accent,
        foregroundColor: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: NestDesignSystem.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NestDesignSystem.borderRadius),
        borderSide: BorderSide(
          color: NestDesignSystem.darkTextPrimary.withValues(alpha: 0.1), 
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NestDesignSystem.borderRadius),
        borderSide: BorderSide(
          color: NestDesignSystem.darkTextPrimary.withValues(alpha: 0.1), 
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(NestDesignSystem.borderRadius),
        borderSide: const BorderSide(color: NestDesignSystem.accent, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: NestDesignSystem.darkTextSecondary.withValues(alpha: 0.5)),
    ),
  );
}

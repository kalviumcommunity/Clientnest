import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Colors
  static const Color _lightPrimary = Color(0xFF6B4CFF); // Deep Indigo/Soft Purple
  static const Color _lightBackground = Color(0xFFF5F7FA);
  static const Color _lightSurface = Colors.white;
  static const Color _lightError = Color(0xFFFF4C4C);
  
  static const Color _darkPrimary = Color(0xFF8B6CFF); // Lighter Purple for Dark Mode
  static const Color _darkBackground = Color(0xFF0E0F13);
  static const Color _darkSurface = Color(0xFF1A1C22);
  static const Color _darkError = Color(0xFFFF4C4C);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B4CFF),
      Color(0xFF8B6CFF),
      Color(0xFF53A9FF),
    ],
  );

  // Text Styles
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -1.0),
    displayMedium: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5),
    displaySmall: TextStyle(fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16),
    bodyMedium: TextStyle(fontSize: 14),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightBackground,
    primaryColor: _lightPrimary,
    
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      surface: _lightSurface,
      /* background: _lightBackground, deprecated */
      error: _lightError,
      onPrimary: Colors.white,
      onSurface: Color(0xFF2D3748),
      /* onBackground: Color(0xFF2D3748), deprecated */
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: Color(0xFF2D3748)),
      titleTextStyle: TextStyle(
        color: Color(0xFF2D3748),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _lightPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _lightError),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _lightPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),

    textTheme: _textTheme.apply(
      bodyColor: const Color(0xFF2D3748),
      displayColor: const Color(0xFF1A202C),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBackground,
    primaryColor: _darkPrimary,

    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      surface: _darkSurface,
      /* background: _darkBackground, deprecated */
      error: _darkError,
      onPrimary: Colors.white,
      onSurface: Color(0xFFE2E8F0),
      /* onBackground: Color(0xFFE2E8F0), deprecated */
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _darkPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: _darkError),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: _darkPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),

    textTheme: _textTheme.apply(
      bodyColor: const Color(0xFFE2E8F0),
      displayColor: Colors.white,
    ),
  );
}

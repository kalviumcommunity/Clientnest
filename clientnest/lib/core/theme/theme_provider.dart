import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Convenience getter used by SettingsScreen.
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  /// Accepts an optional bool so both call sites work:
  ///   - DashboardScreen: toggleTheme()          (no-arg flip)
  ///   - SettingsScreen:  toggleTheme(boolValue) (explicit set)
  // ignore: avoid_positional_boolean_parameters
  void toggleTheme([bool? isDark]) {
    if (isDark != null) {
      setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
    } else if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}

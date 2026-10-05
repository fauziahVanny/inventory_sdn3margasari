import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider untuk mengelola mode tema aplikasi (light / dark)
/// Pilihan tema disimpan secara permanen menggunakan SharedPreferences
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadSavedTheme();
  }

  /// Muat tema yang tersimpan dari SharedPreferences
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    notifyListeners();
  }

  /// Toggle antara light dan dark mode, lalu simpan pilihannya
  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, isDark ? 'dark' : 'light');
  }

  /// Set tema secara eksplisit
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _themeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }
}

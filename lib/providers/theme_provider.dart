import 'package:flutter/material.dart';

/// Provider untuk mengelola mode tema aplikasi (light / dark)
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  /// Toggle antara light dan dark mode
  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Set tema secara eksplisit
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

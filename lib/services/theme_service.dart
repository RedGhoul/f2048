import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f2048/models/theme.dart';

class ThemeService {
  static ThemeService? _instance;
  static const String _currentThemeKey = 'current_theme';
  static const String _unlockedThemesKey = 'unlocked_themes';

  ThemeType _currentTheme = ThemeType.defaultTheme;
  Set<ThemeType> _unlockedThemes = {ThemeType.defaultTheme};

  ThemeService._();

  static ThemeService get instance {
    _instance ??= ThemeService._();
    return _instance!;
  }

  // Get current theme
  ThemeType get currentThemeType => _currentTheme;

  // Get current theme object
  GameTheme get currentTheme {
    final theme = gameThemes[_currentTheme]!;
    return theme.copyWith(isUnlocked: _unlockedThemes.contains(_currentTheme));
  }

  // Initialize and load settings
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Load current theme
    final String? themeString = prefs.getString(_currentThemeKey);
    if (themeString != null) {
      try {
        _currentTheme = ThemeType.values.firstWhere(
          (e) => e.toString() == themeString,
          orElse: () => ThemeType.defaultTheme,
        );
      } catch (e) {
        _currentTheme = ThemeType.defaultTheme;
      }
    }

    // Load unlocked themes
    final String? unlockedJson = prefs.getString(_unlockedThemesKey);
    if (unlockedJson != null) {
      try {
        final List<dynamic> unlockedList = jsonDecode(unlockedJson);
        _unlockedThemes = unlockedList
            .map((e) => ThemeType.values.firstWhere((t) => t.toString() == e))
            .toSet();
        // Ensure default theme is always unlocked
        _unlockedThemes.add(ThemeType.defaultTheme);
      } catch (e) {
        _unlockedThemes = {ThemeType.defaultTheme};
      }
    }
  }

  // Set current theme
  Future<bool> setTheme(ThemeType theme) async {
    if (!_unlockedThemes.contains(theme)) {
      return false;
    }

    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentThemeKey, theme.toString());
    return true;
  }

  // Unlock a theme
  Future<void> unlockTheme(ThemeType theme) async {
    _unlockedThemes.add(theme);
    final prefs = await SharedPreferences.getInstance();
    final List<String> unlockedList =
        _unlockedThemes.map((e) => e.toString()).toList();
    await prefs.setString(_unlockedThemesKey, jsonEncode(unlockedList));
  }

  // Check if a theme is unlocked
  bool isThemeUnlocked(ThemeType theme) {
    return _unlockedThemes.contains(theme);
  }

  // Get all themes with unlock status
  List<GameTheme> getAllThemes() {
    return gameThemes.values.map((theme) {
      return theme.copyWith(isUnlocked: _unlockedThemes.contains(theme.type));
    }).toList();
  }

  // Get unlocked themes count
  int get unlockedCount => _unlockedThemes.length;

  // Get total themes count
  int get totalCount => gameThemes.length;
}

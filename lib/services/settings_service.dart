import 'package:shared_preferences/shared_preferences.dart';

enum DifficultyLevel {
  easy,
  standard,
  hard,
}

class SettingsService {
  static SettingsService? _instance;
  static const String _difficultyKey = 'global_difficulty';

  DifficultyLevel _difficulty = DifficultyLevel.standard;

  SettingsService._();

  static SettingsService get instance {
    _instance ??= SettingsService._();
    return _instance!;
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_difficultyKey);
    if (stored != null) {
      _difficulty = DifficultyLevel.values.firstWhere(
        (level) => level.toString() == stored,
        orElse: () => DifficultyLevel.standard,
      );
    }
  }

  DifficultyLevel get difficulty => _difficulty;

  Future<void> setDifficulty(DifficultyLevel level) async {
    _difficulty = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_difficultyKey, level.toString());
  }
}

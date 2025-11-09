import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f2048/models/game_mode.dart';

class GameModeService {
  static GameModeService? _instance;
  static const String _currentModeKey = 'current_game_mode';
  static const String _modeStatsKey = 'game_mode_stats';

  GameMode _currentMode = GameMode.classic;
  Map<GameMode, GameModeStats>? _modeStats;

  GameModeService._();

  static GameModeService get instance {
    _instance ??= GameModeService._();
    return _instance!;
  }

  // Get current game mode
  GameMode get currentMode => _currentMode;

  // Get config for current mode
  GameModeConfig get currentConfig => gameModeConfigs[_currentMode]!;

  // Initialize and load settings
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final String? modeString = prefs.getString(_currentModeKey);

    if (modeString != null) {
      try {
        _currentMode = GameMode.values.firstWhere(
          (e) => e.toString() == modeString,
          orElse: () => GameMode.classic,
        );
      } catch (e) {
        _currentMode = GameMode.classic;
      }
    }

    await _loadModeStats();
  }

  // Load statistics for all game modes
  Future<void> _loadModeStats() async {
    if (_modeStats != null) return;

    final prefs = await SharedPreferences.getInstance();
    final String? statsJson = prefs.getString(_modeStatsKey);

    _modeStats = {};

    if (statsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(statsJson);
        json.forEach((key, value) {
          final mode = GameMode.values.firstWhere((e) => e.toString() == key);
          _modeStats![mode] = GameModeStats.fromJson(value);
        });
      } catch (e) {
        _modeStats = {};
      }
    }

    // Initialize stats for any missing modes
    for (var mode in GameMode.values) {
      if (!_modeStats!.containsKey(mode)) {
        _modeStats![mode] = GameModeStats(mode: mode);
      }
    }
  }

  // Save mode statistics
  Future<void> _saveModeStats() async {
    if (_modeStats == null) return;

    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> json = {};
    _modeStats!.forEach((key, value) {
      json[key.toString()] = value.toJson();
    });
    final String statsJson = jsonEncode(json);
    await prefs.setString(_modeStatsKey, statsJson);
  }

  // Set current game mode
  Future<void> setGameMode(GameMode mode) async {
    _currentMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentModeKey, mode.toString());
  }

  // Get stats for a specific mode
  GameModeStats getStatsForMode(GameMode mode) {
    if (_modeStats == null) {
      return GameModeStats(mode: mode);
    }
    return _modeStats![mode] ?? GameModeStats(mode: mode);
  }

  // Record a game for the current mode
  Future<void> recordGame(int score, int moves, int bestTile, bool won) async {
    await _loadModeStats();
    final stats = _modeStats![_currentMode]!;
    stats.recordGame(score, moves, bestTile, won);
    await _saveModeStats();
  }

  // Get all mode statistics
  Map<GameMode, GameModeStats> getAllStats() {
    return _modeStats ?? {};
  }
}

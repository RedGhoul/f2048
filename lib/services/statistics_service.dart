import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f2048/models/game_statistics.dart';

class StatisticsService {
  static const String _statsKey = 'game_statistics';
  static StatisticsService? _instance;
  GameStatistics? _statistics;

  StatisticsService._();

  static StatisticsService get instance {
    _instance ??= StatisticsService._();
    return _instance!;
  }

  // Initialize and load statistics
  Future<GameStatistics> loadStatistics() async {
    if (_statistics != null) return _statistics!;

    final prefs = await SharedPreferences.getInstance();
    final String? statsJson = prefs.getString(_statsKey);

    if (statsJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(statsJson);
        _statistics = GameStatistics.fromJson(json);
      } catch (e) {
        // If there's an error parsing, create new statistics
        _statistics = GameStatistics();
      }
    } else {
      _statistics = GameStatistics();
    }

    return _statistics!;
  }

  // Save statistics
  Future<void> saveStatistics() async {
    if (_statistics == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String statsJson = jsonEncode(_statistics!.toJson());
    await prefs.setString(_statsKey, statsJson);
  }

  // Get current statistics (must call loadStatistics first)
  GameStatistics get statistics {
    if (_statistics == null) {
      throw StateError('Statistics not loaded. Call loadStatistics() first.');
    }
    return _statistics!;
  }

  // Record a game
  Future<void> recordGame(GameRecord game) async {
    await loadStatistics();
    _statistics!.recordGame(game);
    await saveStatistics();
  }

  // Update high score if needed
  Future<void> updateHighScore(int score) async {
    await loadStatistics();
    if (score > _statistics!.highScore) {
      _statistics!.highScore = score;
      await saveStatistics();
    }
  }

  // Update best tile if needed
  Future<void> updateBestTile(int tile) async {
    await loadStatistics();
    if (tile > _statistics!.bestTile) {
      _statistics!.bestTile = tile;
      await saveStatistics();
    }
  }

  // Reset all statistics (for debugging/testing)
  Future<void> resetStatistics() async {
    _statistics = GameStatistics();
    await saveStatistics();
  }
}

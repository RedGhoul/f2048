import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f2048/models/achievement.dart';
import 'package:f2048/models/game_statistics.dart';

class AchievementService {
  static const String _achievementsKey = 'achievement_progress';
  static AchievementService? _instance;
  Map<String, AchievementProgress>? _progressMap;

  // Callbacks for achievement unlocks
  final List<Function(Achievement)> _unlockListeners = [];

  AchievementService._();

  static AchievementService get instance {
    _instance ??= AchievementService._();
    return _instance!;
  }

  // Add listener for achievement unlocks
  void addUnlockListener(Function(Achievement) listener) {
    _unlockListeners.add(listener);
  }

  // Remove listener
  void removeUnlockListener(Function(Achievement) listener) {
    _unlockListeners.remove(listener);
  }

  // Initialize and load achievement progress
  Future<Map<String, AchievementProgress>> loadProgress() async {
    if (_progressMap != null) return _progressMap!;

    final prefs = await SharedPreferences.getInstance();
    final String? progressJson = prefs.getString(_achievementsKey);

    _progressMap = {};

    if (progressJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(progressJson);
        json.forEach((key, value) {
          _progressMap![key] = AchievementProgress.fromJson(value);
        });
      } catch (e) {
        // If there's an error parsing, start fresh
        _progressMap = {};
      }
    }

    // Initialize progress for any achievements that don't have progress yet
    for (var achievement in achievements) {
      if (!_progressMap!.containsKey(achievement.id)) {
        _progressMap![achievement.id] = AchievementProgress(achievementId: achievement.id);
      }
    }

    return _progressMap!;
  }

  // Save achievement progress
  Future<void> saveProgress() async {
    if (_progressMap == null) return;

    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> json = {};
    _progressMap!.forEach((key, value) {
      json[key] = value.toJson();
    });
    final String progressJson = jsonEncode(json);
    await prefs.setString(_achievementsKey, progressJson);
  }

  // Get progress for a specific achievement
  AchievementProgress getProgress(String achievementId) {
    if (_progressMap == null) {
      throw StateError('Achievement progress not loaded. Call loadProgress() first.');
    }
    return _progressMap![achievementId]!;
  }

  // Get all unlocked achievements
  List<Achievement> getUnlockedAchievements() {
    if (_progressMap == null) return [];
    return achievements.where((a) => _progressMap![a.id]!.isUnlocked).toList();
  }

  // Check and update achievements based on game completion
  Future<List<Achievement>> checkAchievements(
    GameStatistics stats,
    GameRecord lastGame,
  ) async {
    await loadProgress();
    final List<Achievement> newlyUnlocked = [];

    // Milestone achievements - tile based
    if (lastGame.bestTile >= 2048 && !_progressMap!['first_win']!.isUnlocked) {
      newlyUnlocked.add(_unlockAchievement('first_win'));
    }
    if (lastGame.bestTile >= 4096 && !_progressMap!['power_player']!.isUnlocked) {
      newlyUnlocked.add(_unlockAchievement('power_player'));
    }
    if (lastGame.bestTile >= 8192 && !_progressMap!['master']!.isUnlocked) {
      newlyUnlocked.add(_unlockAchievement('master'));
    }
    if (lastGame.bestTile >= 16384 && !_progressMap!['legend']!.isUnlocked) {
      newlyUnlocked.add(_unlockAchievement('legend'));
    }

    // Milestone achievements - games played
    if (_updateProgress('beginner', stats.totalGamesPlayed)) {
      newlyUnlocked.add(_unlockAchievement('beginner'));
    }
    if (_updateProgress('dedicated', stats.totalGamesPlayed)) {
      newlyUnlocked.add(_unlockAchievement('dedicated'));
    }
    if (_updateProgress('addicted', stats.totalGamesPlayed)) {
      newlyUnlocked.add(_unlockAchievement('addicted'));
    }

    // Skill achievements
    if (lastGame.won &&
        lastGame.moves < 200 &&
        !_progressMap!['efficient_player']!.isUnlocked) {
      newlyUnlocked.add(_unlockAchievement('efficient_player'));
    }
    if (lastGame.won &&
        lastGame.playTimeSeconds < 300 &&
        !_progressMap!['speed_demon']!.isUnlocked) {
      newlyUnlocked.add(_unlockAchievement('speed_demon'));
    }
    if (lastGame.won &&
        !lastGame.usedUndo &&
        !_progressMap!['perfect_game']!.isUnlocked) {
      newlyUnlocked.add(_unlockAchievement('perfect_game'));
    }
    if (stats.currentWinStreak >= 10 &&
        !_progressMap!['strategic_mind']!.isUnlocked) {
      newlyUnlocked.add(_unlockAchievement('strategic_mind'));
    }

    // Collection achievements
    if (_hasAllTilesUpTo2048(stats) &&
        !_progressMap!['tile_collector']!.isUnlocked) {
      newlyUnlocked.add(_unlockAchievement('tile_collector'));
    }
    if (lastGame.score >= 50000 &&
        !_progressMap!['score_hunter']!.isUnlocked) {
      newlyUnlocked.add(_unlockAchievement('score_hunter'));
    }
    if (lastGame.score >= 100000 &&
        !_progressMap!['high_roller']!.isUnlocked) {
      newlyUnlocked.add(_unlockAchievement('high_roller'));
    }

    if (newlyUnlocked.isNotEmpty) {
      await saveProgress();
      // Notify listeners
      for (var achievement in newlyUnlocked) {
        for (var listener in _unlockListeners) {
          listener(achievement);
        }
      }
    }

    return newlyUnlocked;
  }

  // Update progress for incremental achievements
  bool _updateProgress(String achievementId, int currentValue) {
    final progress = _progressMap![achievementId]!;
    if (progress.isUnlocked) return false;

    final achievement = achievements.firstWhere((a) => a.id == achievementId);
    progress.currentProgress = currentValue;

    return currentValue >= achievement.maxProgress;
  }

  // Unlock an achievement
  Achievement _unlockAchievement(String achievementId) {
    final progress = _progressMap![achievementId]!;
    progress.isUnlocked = true;
    progress.unlockedAt = DateTime.now();

    final achievement = achievements.firstWhere((a) => a.id == achievementId);
    final achievementMaxProgress = achievement.maxProgress;
    progress.currentProgress = achievementMaxProgress;

    return achievement;
  }

  // Check if player has created all tiles up to 2048
  bool _hasAllTilesUpTo2048(GameStatistics stats) {
    final requiredTiles = [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048];
    for (var tile in requiredTiles) {
      if ((stats.tilesCreated[tile.toString()] ?? 0) == 0) {
        return false;
      }
    }
    return true;
  }

  // Reset all achievements (for debugging/testing)
  Future<void> resetAchievements() async {
    _progressMap = {};
    for (var achievement in achievements) {
      _progressMap![achievement.id] = AchievementProgress(achievementId: achievement.id);
    }
    await saveProgress();
  }
}

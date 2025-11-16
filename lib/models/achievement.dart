import 'package:flutter/cupertino.dart';

enum AchievementCategory {
  milestone,
  skill,
  collection,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final int maxProgress; // For incremental achievements (e.g., play 10 games)

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.maxProgress = 1,
  });
}

class AchievementProgress {
  final String achievementId;
  int currentProgress;
  bool isUnlocked;
  DateTime? unlockedAt;

  AchievementProgress({
    required this.achievementId,
    this.currentProgress = 0,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  double get progressPercentage => currentProgress / (achievements.firstWhere((a) => a.id == achievementId).maxProgress);

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'currentProgress': currentProgress,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'],
      currentProgress: json['currentProgress'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
    );
  }
}

// Define all achievements
final List<Achievement> achievements = [
  // Milestone Achievements
  Achievement(
    id: 'first_win',
    title: 'First Win',
    description: 'Reach the 2048 tile',
    icon: CupertinoIcons.star_fill,
    category: AchievementCategory.milestone,
  ),
  Achievement(
    id: 'power_player',
    title: 'Power Player',
    description: 'Reach the 4096 tile',
    icon: CupertinoIcons.bolt_fill,
    category: AchievementCategory.milestone,
  ),
  Achievement(
    id: 'master',
    title: 'Master',
    description: 'Reach the 8192 tile',
    icon: CupertinoIcons.flame_fill,
    category: AchievementCategory.milestone,
  ),
  Achievement(
    id: 'legend',
    title: 'Legend',
    description: 'Reach the 16384 tile',
    icon: CupertinoIcons.star_fill,
    category: AchievementCategory.milestone,
  ),
  Achievement(
    id: 'beginner',
    title: 'Complete Beginner',
    description: 'Play 10 games',
    icon: CupertinoIcons.play_fill,
    category: AchievementCategory.milestone,
    maxProgress: 10,
  ),
  Achievement(
    id: 'dedicated',
    title: 'Dedicated',
    description: 'Play 100 games',
    icon: CupertinoIcons.heart_fill,
    category: AchievementCategory.milestone,
    maxProgress: 100,
  ),
  Achievement(
    id: 'addicted',
    title: 'Addicted',
    description: 'Play 1000 games',
    icon: CupertinoIcons.gamecontroller_fill,
    category: AchievementCategory.milestone,
    maxProgress: 1000,
  ),

  // Skill Achievements
  Achievement(
    id: 'efficient_player',
    title: 'Efficient Player',
    description: 'Reach 2048 in under 200 moves',
    icon: CupertinoIcons.speedometer,
    category: AchievementCategory.skill,
  ),
  Achievement(
    id: 'speed_demon',
    title: 'Speed Demon',
    description: 'Reach 2048 in under 5 minutes',
    icon: CupertinoIcons.timer,
    category: AchievementCategory.skill,
  ),
  Achievement(
    id: 'perfect_game',
    title: 'Perfect Game',
    description: 'Reach 2048 without using undo',
    icon: CupertinoIcons.checkmark_seal_fill,
    category: AchievementCategory.skill,
  ),
  Achievement(
    id: 'strategic_mind',
    title: 'Strategic Mind',
    description: 'Win 10 games in a row',
    icon: CupertinoIcons.lightbulb,
    category: AchievementCategory.skill,
  ),

  // Collection Achievements
  Achievement(
    id: 'tile_collector',
    title: 'Tile Collector',
    description: 'Create every tile type up to 2048',
    icon: CupertinoIcons.square_grid_2x2_fill,
    category: AchievementCategory.collection,
  ),
  Achievement(
    id: 'score_hunter',
    title: 'Score Hunter',
    description: 'Reach 50,000 points',
    icon: CupertinoIcons.chart_bar_fill,
    category: AchievementCategory.collection,
  ),
  Achievement(
    id: 'high_roller',
    title: 'High Roller',
    description: 'Reach 100,000 points',
    icon: CupertinoIcons.money_dollar_circle_fill,
    category: AchievementCategory.collection,
  ),
];

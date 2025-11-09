import 'dart:math';

enum ChallengeType {
  scoreTarget, // Reach X points in Y moves
  tileTarget, // Create specific tile in Y moves
  efficiencyChallenge, // Reach goal with minimum moves
  survivalChallenge, // Last X moves without game over
}

class DailyChallenge {
  final String id;
  final DateTime date;
  final ChallengeType type;
  final int seed; // For reproducible board generation
  final String title;
  final String description;
  final int targetScore;
  final int targetTile;
  final int moveLimit;
  final List<List<int>> initialBoard; // Starting board state

  DailyChallenge({
    required this.id,
    required this.date,
    required this.type,
    required this.seed,
    required this.title,
    required this.description,
    this.targetScore = 0,
    this.targetTile = 0,
    this.moveLimit = 0,
    required this.initialBoard,
  });

  bool isToday() {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'type': type.toString(),
      'seed': seed,
      'title': title,
      'description': description,
      'targetScore': targetScore,
      'targetTile': targetTile,
      'moveLimit': moveLimit,
      'initialBoard': initialBoard,
    };
  }

  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      id: json['id'],
      date: DateTime.parse(json['date']),
      type: ChallengeType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      seed: json['seed'],
      title: json['title'],
      description: json['description'],
      targetScore: json['targetScore'] ?? 0,
      targetTile: json['targetTile'] ?? 0,
      moveLimit: json['moveLimit'] ?? 0,
      initialBoard: (json['initialBoard'] as List<dynamic>)
          .map((row) => List<int>.from(row))
          .toList(),
    );
  }
}

class ChallengeResult {
  final String challengeId;
  final DateTime completedAt;
  final int score;
  final int moves;
  final bool completed; // Did the player meet the challenge goal?
  final int stars; // 1-3 stars based on performance

  ChallengeResult({
    required this.challengeId,
    required this.completedAt,
    required this.score,
    required this.moves,
    required this.completed,
    this.stars = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'completedAt': completedAt.toIso8601String(),
      'score': score,
      'moves': moves,
      'completed': completed,
      'stars': stars,
    };
  }

  factory ChallengeResult.fromJson(Map<String, dynamic> json) {
    return ChallengeResult(
      challengeId: json['challengeId'],
      completedAt: DateTime.parse(json['completedAt']),
      score: json['score'],
      moves: json['moves'],
      completed: json['completed'],
      stars: json['stars'] ?? 0,
    );
  }
}

class ChallengeStreak {
  int currentStreak;
  int longestStreak;
  DateTime? lastCompletedDate;
  List<ChallengeResult> completedChallenges;

  ChallengeStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastCompletedDate,
    List<ChallengeResult>? completedChallenges,
  }) : completedChallenges = completedChallenges ?? [];

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
      'completedChallenges': completedChallenges.map((c) => c.toJson()).toList(),
    };
  }

  factory ChallengeStreak.fromJson(Map<String, dynamic> json) {
    return ChallengeStreak(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'])
          : null,
      completedChallenges: (json['completedChallenges'] as List<dynamic>?)
          ?.map((c) => ChallengeResult.fromJson(c))
          .toList() ?? [],
    );
  }

  void recordCompletion(ChallengeResult result) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    // Check if this continues the streak
    if (lastCompletedDate == null) {
      currentStreak = 1;
    } else {
      final lastDate = DateTime(
        lastCompletedDate!.year,
        lastCompletedDate!.month,
        lastCompletedDate!.day,
      );
      if (lastDate.isAtSameMomentAs(yesterday)) {
        currentStreak++;
      } else if (!lastDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
        // Streak broken
        currentStreak = 1;
      }
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    lastCompletedDate = now;
    completedChallenges.insert(0, result);

    // Keep only last 90 days
    if (completedChallenges.length > 90) {
      completedChallenges = completedChallenges.sublist(0, 90);
    }
  }
}

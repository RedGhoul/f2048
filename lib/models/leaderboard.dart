import 'package:f2048/models/game_mode.dart';

enum LeaderboardType {
  allTime,
  monthly,
  weekly,
  daily,
}

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int score;
  final int bestTile;
  final int moves;
  final DateTime timestamp;
  final GameMode gameMode;
  final String? avatarUrl;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.displayName,
    required this.score,
    required this.bestTile,
    required this.moves,
    required this.timestamp,
    required this.gameMode,
    this.avatarUrl,
    this.rank = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'score': score,
      'bestTile': bestTile,
      'moves': moves,
      'timestamp': timestamp.toIso8601String(),
      'gameMode': gameMode.toString(),
      'avatarUrl': avatarUrl,
      'rank': rank,
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'],
      displayName: json['displayName'],
      score: json['score'],
      bestTile: json['bestTile'],
      moves: json['moves'],
      timestamp: DateTime.parse(json['timestamp']),
      gameMode: GameMode.values.firstWhere((e) => e.toString() == json['gameMode']),
      avatarUrl: json['avatarUrl'],
      rank: json['rank'] ?? 0,
    );
  }

  LeaderboardEntry copyWith({int? rank}) {
    return LeaderboardEntry(
      userId: userId,
      displayName: displayName,
      score: score,
      bestTile: bestTile,
      moves: moves,
      timestamp: timestamp,
      gameMode: gameMode,
      avatarUrl: avatarUrl,
      rank: rank ?? this.rank,
    );
  }
}

class Leaderboard {
  final GameMode gameMode;
  final LeaderboardType type;
  final List<LeaderboardEntry> entries;
  final DateTime lastUpdated;

  Leaderboard({
    required this.gameMode,
    required this.type,
    required this.entries,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameMode': gameMode.toString(),
      'type': type.toString(),
      'entries': entries.map((e) => e.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Leaderboard.fromJson(Map<String, dynamic> json) {
    return Leaderboard(
      gameMode: GameMode.values.firstWhere((e) => e.toString() == json['gameMode']),
      type: LeaderboardType.values.firstWhere((e) => e.toString() == json['type']),
      entries: (json['entries'] as List<dynamic>)
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

// Helper to filter entries by time period
class LeaderboardFilter {
  static List<LeaderboardEntry> filterByType(
    List<LeaderboardEntry> entries,
    LeaderboardType type,
  ) {
    final now = DateTime.now();
    DateTime cutoffDate;

    switch (type) {
      case LeaderboardType.daily:
        cutoffDate = DateTime(now.year, now.month, now.day);
        break;
      case LeaderboardType.weekly:
        cutoffDate = now.subtract(const Duration(days: 7));
        break;
      case LeaderboardType.monthly:
        cutoffDate = DateTime(now.year, now.month, 1);
        break;
      case LeaderboardType.allTime:
        return entries;
    }

    return entries.where((entry) => entry.timestamp.isAfter(cutoffDate)).toList();
  }

  static List<LeaderboardEntry> sortAndRank(List<LeaderboardEntry> entries) {
    // Sort by score (descending), then by moves (ascending for ties)
    entries.sort((a, b) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;
      return a.moves.compareTo(b.moves);
    });

    // Assign ranks
    for (int i = 0; i < entries.length; i++) {
      entries[i] = entries[i].copyWith(rank: i + 1);
    }

    return entries;
  }
}

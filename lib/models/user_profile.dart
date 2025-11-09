import 'package:flutter/cupertino.dart';

enum PlayerRank {
  beginner,
  intermediate,
  advanced,
  expert,
  master,
  legend,
}

class UserProfile {
  String userId;
  String displayName;
  String? avatarUrl;
  DateTime createdAt;
  DateTime lastPlayedAt;
  PlayerRank rank;
  int level;
  int totalXP;

  // Statistics summary
  int totalGamesPlayed;
  int totalWins;
  int highestScore;
  int highestTile;

  // Social
  List<String> badges;
  bool isPublic;

  UserProfile({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
    required this.lastPlayedAt,
    this.rank = PlayerRank.beginner,
    this.level = 1,
    this.totalXP = 0,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.highestScore = 0,
    this.highestTile = 0,
    List<String>? badges,
    this.isPublic = true,
  }) : badges = badges ?? [];

  // Calculate rank based on stats
  static PlayerRank calculateRank(int totalGamesPlayed, int highestTile, int totalWins) {
    if (highestTile >= 16384) return PlayerRank.legend;
    if (highestTile >= 8192) return PlayerRank.master;
    if (highestTile >= 4096) return PlayerRank.expert;
    if (highestTile >= 2048 && totalWins >= 10) return PlayerRank.advanced;
    if (totalGamesPlayed >= 50) return PlayerRank.intermediate;
    return PlayerRank.beginner;
  }

  // Calculate level based on XP
  static int calculateLevel(int xp) {
    return (xp / 1000).floor() + 1;
  }

  String get rankName {
    switch (rank) {
      case PlayerRank.beginner:
        return 'Beginner';
      case PlayerRank.intermediate:
        return 'Intermediate';
      case PlayerRank.advanced:
        return 'Advanced';
      case PlayerRank.expert:
        return 'Expert';
      case PlayerRank.master:
        return 'Master';
      case PlayerRank.legend:
        return 'Legend';
    }
  }

  IconData get rankIcon {
    switch (rank) {
      case PlayerRank.beginner:
        return CupertinoIcons.circle;
      case PlayerRank.intermediate:
        return CupertinoIcons.star;
      case PlayerRank.advanced:
        return CupertinoIcons.star_fill;
      case PlayerRank.expert:
        return CupertinoIcons.sparkles;
      case PlayerRank.master:
        return CupertinoIcons.flame_fill;
      case PlayerRank.legend:
        return CupertinoIcons.crown_fill;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastPlayedAt': lastPlayedAt.toIso8601String(),
      'rank': rank.toString(),
      'level': level,
      'totalXP': totalXP,
      'totalGamesPlayed': totalGamesPlayed,
      'totalWins': totalWins,
      'highestScore': highestScore,
      'highestTile': highestTile,
      'badges': badges,
      'isPublic': isPublic,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      lastPlayedAt: DateTime.parse(json['lastPlayedAt']),
      rank: PlayerRank.values.firstWhere((e) => e.toString() == json['rank']),
      level: json['level'] ?? 1,
      totalXP: json['totalXP'] ?? 0,
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      highestScore: json['highestScore'] ?? 0,
      highestTile: json['highestTile'] ?? 0,
      badges: List<String>.from(json['badges'] ?? []),
      isPublic: json['isPublic'] ?? true,
    );
  }

  void updateFromStats(int gamesPlayed, int wins, int highScore, int bestTile, int xpGained) {
    totalGamesPlayed = gamesPlayed;
    totalWins = wins;
    if (highScore > highestScore) highestScore = highScore;
    if (bestTile > highestTile) highestTile = bestTile;
    totalXP += xpGained;
    level = calculateLevel(totalXP);
    rank = calculateRank(totalGamesPlayed, highestTile, totalWins);
    lastPlayedAt = DateTime.now();
  }
}

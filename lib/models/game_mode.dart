import 'package:flutter/cupertino.dart';

enum GameMode {
  classic,
  mini,
  large,
  giant,
  timeAttack,
  zen,
}

class GameModeConfig {
  final GameMode mode;
  final String name;
  final String description;
  final IconData icon;
  final int gridSize;
  final bool hasTimer;
  final int? timeLimit; // seconds
  final bool hasGameOver;
  final bool unlimitedUndo;
  final int winTile;

  GameModeConfig({
    required this.mode,
    required this.name,
    required this.description,
    required this.icon,
    required this.gridSize,
    this.hasTimer = false,
    this.timeLimit,
    this.hasGameOver = true,
    this.unlimitedUndo = false,
    this.winTile = 2048,
  });

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.toString(),
      'name': name,
      'description': description,
      'gridSize': gridSize,
      'hasTimer': hasTimer,
      'timeLimit': timeLimit,
      'hasGameOver': hasGameOver,
      'unlimitedUndo': unlimitedUndo,
      'winTile': winTile,
    };
  }

  factory GameModeConfig.fromJson(Map<String, dynamic> json) {
    return GameModeConfig(
      mode: GameMode.values.firstWhere((e) => e.toString() == json['mode']),
      name: json['name'],
      description: json['description'],
      icon: CupertinoIcons.game_controller_solid, // Default icon
      gridSize: json['gridSize'],
      hasTimer: json['hasTimer'] ?? false,
      timeLimit: json['timeLimit'],
      hasGameOver: json['hasGameOver'] ?? true,
      unlimitedUndo: json['unlimitedUndo'] ?? false,
      winTile: json['winTile'] ?? 2048,
    );
  }
}

// Predefined game mode configurations
final Map<GameMode, GameModeConfig> gameModeConfigs = {
  GameMode.classic: GameModeConfig(
    mode: GameMode.classic,
    name: 'Classic',
    description: 'The original 4x4 grid experience',
    icon: CupertinoIcons.square_grid_2x2,
    gridSize: 4,
  ),
  GameMode.mini: GameModeConfig(
    mode: GameMode.mini,
    name: 'Mini',
    description: 'Faster, more challenging 3x3 grid',
    icon: CupertinoIcons.square_grid_3x2,
    gridSize: 3,
    winTile: 1024, // Lower win condition for smaller grid
  ),
  GameMode.large: GameModeConfig(
    mode: GameMode.large,
    name: 'Large',
    description: 'Strategic 5x5 grid for longer games',
    icon: CupertinoIcons.square_grid_4x3x2,
    gridSize: 5,
    winTile: 4096, // Higher win condition for larger grid
  ),
  GameMode.giant: GameModeConfig(
    mode: GameMode.giant,
    name: 'Giant',
    description: 'Epic 6x6 grid for advanced players',
    icon: CupertinoIcons.square_fill_on_square_fill,
    gridSize: 6,
    winTile: 8192, // Even higher win condition
  ),
  GameMode.timeAttack: GameModeConfig(
    mode: GameMode.timeAttack,
    name: 'Time Attack',
    description: 'Score as many points as possible in 3 minutes',
    icon: CupertinoIcons.timer,
    gridSize: 4,
    hasTimer: true,
    timeLimit: 180, // 3 minutes
    hasGameOver: false, // Game ends when time runs out
  ),
  GameMode.zen: GameModeConfig(
    mode: GameMode.zen,
    name: 'Zen Mode',
    description: 'Relaxed gameplay with unlimited undo',
    icon: CupertinoIcons.cloud_sun,
    gridSize: 4,
    hasGameOver: false, // No game over in zen mode
    unlimitedUndo: true,
    winTile: 2048,
  ),
};

class GameModeStats {
  final GameMode mode;
  int gamesPlayed;
  int highScore;
  int bestTile;
  int totalMoves;
  int wins;

  GameModeStats({
    required this.mode,
    this.gamesPlayed = 0,
    this.highScore = 0,
    this.bestTile = 0,
    this.totalMoves = 0,
    this.wins = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.toString(),
      'gamesPlayed': gamesPlayed,
      'highScore': highScore,
      'bestTile': bestTile,
      'totalMoves': totalMoves,
      'wins': wins,
    };
  }

  factory GameModeStats.fromJson(Map<String, dynamic> json) {
    return GameModeStats(
      mode: GameMode.values.firstWhere((e) => e.toString() == json['mode']),
      gamesPlayed: json['gamesPlayed'] ?? 0,
      highScore: json['highScore'] ?? 0,
      bestTile: json['bestTile'] ?? 0,
      totalMoves: json['totalMoves'] ?? 0,
      wins: json['wins'] ?? 0,
    );
  }

  void recordGame(int score, int moves, int bestTile, bool won) {
    gamesPlayed++;
    totalMoves += moves;
    if (score > highScore) highScore = score;
    if (bestTile > this.bestTile) this.bestTile = bestTile;
    if (won) wins++;
  }
}

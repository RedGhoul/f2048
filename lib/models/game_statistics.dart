class GameStatistics {
  int totalGamesPlayed;
  int totalWins; // reached 2048 tile
  int totalLosses;
  int highScore;
  int bestTile;
  int totalMoves;
  int totalPlayTimeSeconds;
  int currentWinStreak;
  int longestWinStreak;
  int currentLossStreak;
  List<GameRecord> recentGames;
  Map<String, int> tilesCreated; // Track how many times each tile was created

  GameStatistics({
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    this.highScore = 0,
    this.bestTile = 0,
    this.totalMoves = 0,
    this.totalPlayTimeSeconds = 0,
    this.currentWinStreak = 0,
    this.longestWinStreak = 0,
    this.currentLossStreak = 0,
    List<GameRecord>? recentGames,
    Map<String, int>? tilesCreated,
  })  : recentGames = recentGames ?? [],
        tilesCreated = tilesCreated ?? {};

  // Computed properties
  double get winRate => totalGamesPlayed > 0 ? totalWins / totalGamesPlayed : 0.0;

  double get averageScore => totalGamesPlayed > 0
      ? recentGames.fold<int>(0, (sum, game) => sum + game.score) / recentGames.length
      : 0.0;

  double get averageMoves => totalGamesPlayed > 0
      ? totalMoves / totalGamesPlayed
      : 0.0;

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'totalGamesPlayed': totalGamesPlayed,
      'totalWins': totalWins,
      'totalLosses': totalLosses,
      'highScore': highScore,
      'bestTile': bestTile,
      'totalMoves': totalMoves,
      'totalPlayTimeSeconds': totalPlayTimeSeconds,
      'currentWinStreak': currentWinStreak,
      'longestWinStreak': longestWinStreak,
      'currentLossStreak': currentLossStreak,
      'recentGames': recentGames.map((g) => g.toJson()).toList(),
      'tilesCreated': tilesCreated,
    };
  }

  // Create from JSON
  factory GameStatistics.fromJson(Map<String, dynamic> json) {
    return GameStatistics(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      totalWins: json['totalWins'] ?? 0,
      totalLosses: json['totalLosses'] ?? 0,
      highScore: json['highScore'] ?? 0,
      bestTile: json['bestTile'] ?? 0,
      totalMoves: json['totalMoves'] ?? 0,
      totalPlayTimeSeconds: json['totalPlayTimeSeconds'] ?? 0,
      currentWinStreak: json['currentWinStreak'] ?? 0,
      longestWinStreak: json['longestWinStreak'] ?? 0,
      currentLossStreak: json['currentLossStreak'] ?? 0,
      recentGames: (json['recentGames'] as List<dynamic>?)
          ?.map((g) => GameRecord.fromJson(g))
          .toList() ?? [],
      tilesCreated: Map<String, int>.from(json['tilesCreated'] ?? {}),
    );
  }

  // Update statistics after a game
  void recordGame(GameRecord game) {
    totalGamesPlayed++;
    totalMoves += game.moves;
    totalPlayTimeSeconds += game.playTimeSeconds;

    if (game.score > highScore) {
      highScore = game.score;
    }

    if (game.bestTile > bestTile) {
      bestTile = game.bestTile;
    }

    // Track win/loss
    if (game.won) {
      totalWins++;
      currentWinStreak++;
      currentLossStreak = 0;
      if (currentWinStreak > longestWinStreak) {
        longestWinStreak = currentWinStreak;
      }
    } else {
      totalLosses++;
      currentLossStreak++;
      currentWinStreak = 0;
    }

    // Track tiles created
    for (var tile in game.tilesReached) {
      tilesCreated[tile.toString()] = (tilesCreated[tile.toString()] ?? 0) + 1;
    }

    // Keep only last 100 games for efficiency
    recentGames.insert(0, game);
    if (recentGames.length > 100) {
      recentGames = recentGames.sublist(0, 100);
    }
  }
}

class GameRecord {
  final DateTime timestamp;
  final int score;
  final int moves;
  final int bestTile;
  final bool won; // reached 2048
  final int playTimeSeconds;
  final List<int> tilesReached;
  final bool usedUndo;

  GameRecord({
    required this.timestamp,
    required this.score,
    required this.moves,
    required this.bestTile,
    required this.won,
    required this.playTimeSeconds,
    required this.tilesReached,
    this.usedUndo = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'score': score,
      'moves': moves,
      'bestTile': bestTile,
      'won': won,
      'playTimeSeconds': playTimeSeconds,
      'tilesReached': tilesReached,
      'usedUndo': usedUndo,
    };
  }

  factory GameRecord.fromJson(Map<String, dynamic> json) {
    return GameRecord(
      timestamp: DateTime.parse(json['timestamp']),
      score: json['score'],
      moves: json['moves'],
      bestTile: json['bestTile'],
      won: json['won'],
      playTimeSeconds: json['playTimeSeconds'],
      tilesReached: List<int>.from(json['tilesReached'] ?? []),
      usedUndo: json['usedUndo'] ?? false,
    );
  }
}

import 'package:share_plus/share_plus.dart';
import 'package:f2048/models/game_statistics.dart';
import 'package:f2048/models/game_mode.dart';
import 'package:f2048/models/user_profile.dart';

class ShareService {
  static ShareService? _instance;

  ShareService._();

  static ShareService get instance {
    _instance ??= ShareService._();
    return _instance!;
  }

  // Share game result
  Future<void> shareGameResult({
    required int score,
    required int bestTile,
    required int moves,
    required bool won,
    required GameMode gameMode,
    int? timeTaken,
  }) async {
    final modeText = _getModeName(gameMode);
    final tileEmoji = _getTileEmoji(bestTile);
    final statusEmoji = won ? '🏆' : '🎮';

    final message = '''
$statusEmoji ${won ? 'Victory!' : 'Game Over'} $tileEmoji

Mode: $modeText
Score: ${_formatNumber(score)}
Best Tile: $bestTile
Moves: $moves${timeTaken != null ? '\nTime: ${_formatTime(timeTaken)}' : ''}

${won ? 'I reached $bestTile in F2048! 🎉' : 'Playing F2048! Can you beat my score?'}

#F2048 #PuzzleGame
''';

    await Share.share(
      message,
      subject: 'My F2048 Score',
    );
  }

  // Share achievement unlock
  Future<void> shareAchievement({
    required String achievementTitle,
    required String achievementDescription,
  }) async {
    final message = '''
🏅 Achievement Unlocked!

$achievementTitle
$achievementDescription

Playing F2048 - Join me!
#F2048 #Achievement
''';

    await Share.share(
      message,
      subject: 'F2048 Achievement',
    );
  }

  // Share profile stats
  Future<void> shareProfile({
    required UserProfile profile,
    required GameStatistics stats,
  }) async {
    final rankEmoji = _getRankEmoji(profile.rank);
    final winRate = stats.totalGamesPlayed > 0
        ? ((stats.totalWins / stats.totalGamesPlayed) * 100).toStringAsFixed(1)
        : '0.0';

    final message = '''
$rankEmoji My F2048 Profile

Player: ${profile.displayName}
Rank: ${_getRankName(profile.rank)}
Level: ${profile.level}

📊 Career Stats
Games: ${_formatNumber(stats.totalGamesPlayed)}
Wins: ${_formatNumber(stats.totalWins)} ($winRate%)
High Score: ${_formatNumber(stats.highScore)}
Best Tile: ${stats.bestTile} ${_getTileEmoji(stats.bestTile)}
Win Streak: ${stats.bestWinStreak}

Join me in F2048!
#F2048 #PuzzleGame
''';

    await Share.share(
      message,
      subject: 'My F2048 Profile',
    );
  }

  // Share daily challenge result
  Future<void> shareDailyChallengeResult({
    required DateTime challengeDate,
    required int score,
    required int moves,
    required bool completed,
    required int bestTile,
  }) async {
    final dateStr = '${challengeDate.month}/${challengeDate.day}/${challengeDate.year}';
    final statusEmoji = completed ? '✅' : '🎯';

    final message = '''
$statusEmoji Daily Challenge - $dateStr

${completed ? 'Completed!' : 'Attempted'}
Score: ${_formatNumber(score)}
Best Tile: $bestTile ${_getTileEmoji(bestTile)}
Moves: $moves

Can you beat my score?
#F2048 #DailyChallenge
''';

    await Share.share(
      message,
      subject: 'F2048 Daily Challenge',
    );
  }

  // Share leaderboard position
  Future<void> shareLeaderboardRank({
    required int rank,
    required int score,
    required int bestTile,
    required GameMode gameMode,
    required String leaderboardType,
  }) async {
    final rankEmoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '🏆';
    final modeText = _getModeName(gameMode);

    final message = '''
$rankEmoji Rank #$rank on Leaderboard!

Mode: $modeText
Period: $leaderboardType
Score: ${_formatNumber(score)}
Best Tile: $bestTile ${_getTileEmoji(bestTile)}

Think you can beat me?
#F2048 #Leaderboard
''';

    await Share.share(
      message,
      subject: 'F2048 Leaderboard',
    );
  }

  // Helper: Format number with commas
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // Helper: Format time in seconds to MM:SS
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Helper: Get game mode name
  String _getModeName(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return 'Classic 4x4';
      case GameMode.mini:
        return 'Mini 3x3';
      case GameMode.large:
        return 'Large 5x5';
      case GameMode.giant:
        return 'Giant 6x6';
      case GameMode.timeAttack:
        return 'Time Attack';
      case GameMode.zen:
        return 'Zen Mode';
    }
  }

  // Helper: Get emoji for tile value
  String _getTileEmoji(int tile) {
    if (tile >= 16384) return '💎';
    if (tile >= 8192) return '👑';
    if (tile >= 4096) return '🌟';
    if (tile >= 2048) return '🔥';
    if (tile >= 1024) return '⚡';
    if (tile >= 512) return '✨';
    if (tile >= 256) return '💫';
    return '🎯';
  }

  // Helper: Get rank name
  String _getRankName(PlayerRank rank) {
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

  // Helper: Get emoji for rank
  String _getRankEmoji(PlayerRank rank) {
    switch (rank) {
      case PlayerRank.beginner:
        return '🌱';
      case PlayerRank.intermediate:
        return '🎮';
      case PlayerRank.advanced:
        return '⭐';
      case PlayerRank.expert:
        return '💪';
      case PlayerRank.master:
        return '🔥';
      case PlayerRank.legend:
        return '👑';
    }
  }
}

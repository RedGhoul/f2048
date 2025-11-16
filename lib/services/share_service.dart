import 'package:share_plus/share_plus.dart';
import 'package:f2048/models/game_statistics.dart';
import 'package:f2048/models/game_mode.dart';

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
}

import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f2048/models/daily_challenge.dart';

class DailyChallengeService {
  static DailyChallengeService? _instance;
  static const String _streakKey = 'challenge_streak';
  static const String _currentChallengeKey = 'current_challenge';

  ChallengeStreak? _streak;
  DailyChallenge? _currentChallenge;

  DailyChallengeService._();

  static DailyChallengeService get instance {
    _instance ??= DailyChallengeService._();
    return _instance!;
  }

  // Load streak data
  Future<ChallengeStreak> loadStreak() async {
    if (_streak != null) return _streak!;

    final prefs = await SharedPreferences.getInstance();
    final String? streakJson = prefs.getString(_streakKey);

    if (streakJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(streakJson);
        _streak = ChallengeStreak.fromJson(json);
      } catch (e) {
        _streak = ChallengeStreak();
      }
    } else {
      _streak = ChallengeStreak();
    }

    return _streak!;
  }

  // Save streak data
  Future<void> saveStreak() async {
    if (_streak == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String streakJson = jsonEncode(_streak!.toJson());
    await prefs.setString(_streakKey, streakJson);
  }

  // Get today's challenge
  Future<DailyChallenge> getTodaysChallenge() async {
    // Check if we have today's challenge cached
    if (_currentChallenge != null && _currentChallenge!.isToday()) {
      return _currentChallenge!;
    }

    // Try to load from storage
    final prefs = await SharedPreferences.getInstance();
    final String? challengeJson = prefs.getString(_currentChallengeKey);

    if (challengeJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(challengeJson);
        final challenge = DailyChallenge.fromJson(json);
        if (challenge.isToday()) {
          _currentChallenge = challenge;
          return challenge;
        }
      } catch (e) {
        // Error parsing, generate new challenge
      }
    }

    // Generate new challenge for today
    _currentChallenge = _generateDailyChallenge();
    final String newChallengeJson = jsonEncode(_currentChallenge!.toJson());
    await prefs.setString(_currentChallengeKey, newChallengeJson);

    return _currentChallenge!;
  }

  // Generate a daily challenge based on the date
  DailyChallenge _generateDailyChallenge() {
    final now = DateTime.now();
    final dateKey = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

    // Use date as seed for reproducibility
    final seed = int.parse(dateKey);
    final random = Random(seed);

    // Choose challenge type based on day
    final types = ChallengeType.values;
    final type = types[random.nextInt(types.length)];

    String title;
    String description;
    int targetScore = 0;
    int targetTile = 0;
    int moveLimit = 0;

    switch (type) {
      case ChallengeType.scoreTarget:
        targetScore = 1000 + random.nextInt(4000); // 1000-5000
        moveLimit = 50 + random.nextInt(100); // 50-150 moves
        title = 'Score Challenge';
        description = 'Reach $targetScore points in $moveLimit moves or less';
        break;

      case ChallengeType.tileTarget:
        final tiles = [256, 512, 1024];
        targetTile = tiles[random.nextInt(tiles.length)];
        moveLimit = 100 + random.nextInt(100); // 100-200 moves
        title = 'Tile Challenge';
        description = 'Create the $targetTile tile in $moveLimit moves or less';
        break;

      case ChallengeType.efficiencyChallenge:
        targetTile = 256;
        moveLimit = 80;
        title = 'Efficiency Challenge';
        description = 'Reach $targetTile in $moveLimit moves or less';
        break;

      case ChallengeType.survivalChallenge:
        moveLimit = 100;
        title = 'Survival Challenge';
        description = 'Survive for $moveLimit moves';
        break;
    }

    // Generate initial board with some tiles already placed
    final initialBoard = _generateInitialBoard(random);

    return DailyChallenge(
      id: dateKey,
      date: now,
      type: type,
      seed: seed,
      title: title,
      description: description,
      targetScore: targetScore,
      targetTile: targetTile,
      moveLimit: moveLimit,
      initialBoard: initialBoard,
    );
  }

  // Generate initial board state for challenge
  List<List<int>> _generateInitialBoard(Random random) {
    final board = List.generate(4, (_) => List.filled(4, 0));

    // Place 2-4 initial tiles
    final numTiles = 2 + random.nextInt(3);
    final positions = <int>[];

    // Get random positions
    while (positions.length < numTiles) {
      final pos = random.nextInt(16);
      if (!positions.contains(pos)) {
        positions.add(pos);
      }
    }

    // Place tiles
    for (var pos in positions) {
      final row = pos ~/ 4;
      final col = pos % 4;
      // Place 2 or 4
      board[row][col] = random.nextDouble() < 0.9 ? 2 : 4;
    }

    return board;
  }

  // Record challenge completion
  Future<void> recordCompletion(ChallengeResult result) async {
    await loadStreak();
    _streak!.recordCompletion(result);
    await saveStreak();
  }

  // Check if today's challenge has been completed
  Future<bool> isTodayCompleted() async {
    await loadStreak();
    final today = DateTime.now();

    return _streak!.completedChallenges.any((result) {
      final resultDate = result.completedAt;
      return resultDate.year == today.year &&
          resultDate.month == today.month &&
          resultDate.day == today.day;
    });
  }

  // Calculate stars based on performance
  int calculateStars(DailyChallenge challenge, int score, int moves, int bestTile) {
    switch (challenge.type) {
      case ChallengeType.scoreTarget:
        if (score < challenge.targetScore) return 0;
        if (moves <= challenge.moveLimit * 0.7) return 3;
        if (moves <= challenge.moveLimit * 0.85) return 2;
        return 1;

      case ChallengeType.tileTarget:
        if (bestTile < challenge.targetTile) return 0;
        if (moves <= challenge.moveLimit * 0.7) return 3;
        if (moves <= challenge.moveLimit * 0.85) return 2;
        return 1;

      case ChallengeType.efficiencyChallenge:
        if (bestTile < challenge.targetTile) return 0;
        if (moves <= challenge.moveLimit * 0.6) return 3;
        if (moves <= challenge.moveLimit * 0.8) return 2;
        return 1;

      case ChallengeType.survivalChallenge:
        if (moves < challenge.moveLimit) return 0;
        if (score >= 10000) return 3;
        if (score >= 5000) return 2;
        return 1;
    }
  }

  ChallengeStreak get streak => _streak ?? ChallengeStreak();
  DailyChallenge? get currentChallenge => _currentChallenge;
}

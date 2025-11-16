import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f2048/services/achievement_service.dart';
import 'package:f2048/models/achievement.dart';
import 'package:f2048/models/game_statistics.dart';

void main() {
  late AchievementService achievementService;

  setUp(() async {
    // Reset SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
    achievementService = AchievementService.instance;
    await achievementService.resetAchievements();
  });

  group('Milestone Achievements - Tile Based', () {
    test('Achievement 1: First Win - Reach 2048 tile', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 150,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'first_win'), true,
          reason: 'First Win achievement should be unlocked when reaching 2048');
      expect(achievementService.getProgress('first_win').isUnlocked, true);
    });

    test('Achievement 2: Power Player - Reach 4096 tile', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 40000,
        moves: 300,
        bestTile: 4096,
        won: true,
        playTimeSeconds: 800,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'power_player'), true,
          reason: 'Power Player achievement should be unlocked when reaching 4096');
      expect(achievementService.getProgress('power_player').isUnlocked, true);
    });

    test('Achievement 3: Master - Reach 8192 tile', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 80000,
        moves: 500,
        bestTile: 8192,
        won: true,
        playTimeSeconds: 1200,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'master'), true,
          reason: 'Master achievement should be unlocked when reaching 8192');
      expect(achievementService.getProgress('master').isUnlocked, true);
    });

    test('Achievement 4: Legend - Reach 16384 tile', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 150000,
        moves: 800,
        bestTile: 16384,
        won: true,
        playTimeSeconds: 2000,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'legend'), true,
          reason: 'Legend achievement should be unlocked when reaching 16384');
      expect(achievementService.getProgress('legend').isUnlocked, true);
    });
  });

  group('Milestone Achievements - Games Played', () {
    test('Achievement 5: Beginner - Play 10 games', () async {
      final stats = GameStatistics(totalGamesPlayed: 10);
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 5000,
        moves: 100,
        bestTile: 512,
        won: false,
        playTimeSeconds: 300,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'beginner'), true,
          reason: 'Beginner achievement should be unlocked after playing 10 games');
      expect(achievementService.getProgress('beginner').isUnlocked, true);
      expect(achievementService.getProgress('beginner').currentProgress, 10);
    });

    test('Achievement 6: Dedicated - Play 100 games', () async {
      final stats = GameStatistics(totalGamesPlayed: 100);
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 5000,
        moves: 100,
        bestTile: 512,
        won: false,
        playTimeSeconds: 300,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'dedicated'), true,
          reason: 'Dedicated achievement should be unlocked after playing 100 games');
      expect(achievementService.getProgress('dedicated').isUnlocked, true);
      expect(achievementService.getProgress('dedicated').currentProgress, 100);
    });

    test('Achievement 7: Addicted - Play 1000 games', () async {
      final stats = GameStatistics(totalGamesPlayed: 1000);
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 5000,
        moves: 100,
        bestTile: 512,
        won: false,
        playTimeSeconds: 300,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'addicted'), true,
          reason: 'Addicted achievement should be unlocked after playing 1000 games');
      expect(achievementService.getProgress('addicted').isUnlocked, true);
      expect(achievementService.getProgress('addicted').currentProgress, 1000);
    });
  });

  group('Skill Achievements', () {
    test('Achievement 8: Efficient Player - Reach 2048 in under 200 moves', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 199,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'efficient_player'), true,
          reason: 'Efficient Player achievement should be unlocked when reaching 2048 in under 200 moves');
      expect(achievementService.getProgress('efficient_player').isUnlocked, true);
    });

    test('Achievement 8: Efficient Player - Should NOT unlock with 200+ moves', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 200,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'efficient_player'), false,
          reason: 'Efficient Player achievement should NOT be unlocked with 200 or more moves');
      expect(achievementService.getProgress('efficient_player').isUnlocked, false);
    });

    test('Achievement 9: Speed Demon - Reach 2048 in under 5 minutes', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 250,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 299, // 4 minutes 59 seconds
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'speed_demon'), true,
          reason: 'Speed Demon achievement should be unlocked when reaching 2048 in under 5 minutes');
      expect(achievementService.getProgress('speed_demon').isUnlocked, true);
    });

    test('Achievement 9: Speed Demon - Should NOT unlock with 5+ minutes', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 250,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 300, // exactly 5 minutes
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'speed_demon'), false,
          reason: 'Speed Demon achievement should NOT be unlocked at 5 minutes or more');
      expect(achievementService.getProgress('speed_demon').isUnlocked, false);
    });

    test('Achievement 10: Perfect Game - Reach 2048 without using undo', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 250,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'perfect_game'), true,
          reason: 'Perfect Game achievement should be unlocked when reaching 2048 without undo');
      expect(achievementService.getProgress('perfect_game').isUnlocked, true);
    });

    test('Achievement 10: Perfect Game - Should NOT unlock if undo was used', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 250,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: true,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'perfect_game'), false,
          reason: 'Perfect Game achievement should NOT be unlocked if undo was used');
      expect(achievementService.getProgress('perfect_game').isUnlocked, false);
    });

    test('Achievement 11: Strategic Mind - Win 10 games in a row', () async {
      final stats = GameStatistics(currentWinStreak: 10);
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 250,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'strategic_mind'), true,
          reason: 'Strategic Mind achievement should be unlocked after winning 10 games in a row');
      expect(achievementService.getProgress('strategic_mind').isUnlocked, true);
    });

    test('Achievement 11: Strategic Mind - Should NOT unlock with 9 wins', () async {
      final stats = GameStatistics(currentWinStreak: 9);
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 250,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'strategic_mind'), false,
          reason: 'Strategic Mind achievement should NOT be unlocked with only 9 wins');
      expect(achievementService.getProgress('strategic_mind').isUnlocked, false);
    });
  });

  group('Collection Achievements', () {
    test('Achievement 12: Tile Collector - Create every tile up to 2048', () async {
      final stats = GameStatistics(
        tilesCreated: {
          '2': 1,
          '4': 1,
          '8': 1,
          '16': 1,
          '32': 1,
          '64': 1,
          '128': 1,
          '256': 1,
          '512': 1,
          '1024': 1,
          '2048': 1,
        },
      );
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 250,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'tile_collector'), true,
          reason: 'Tile Collector achievement should be unlocked when all tiles up to 2048 are created');
      expect(achievementService.getProgress('tile_collector').isUnlocked, true);
    });

    test('Achievement 12: Tile Collector - Should NOT unlock with missing tiles', () async {
      final stats = GameStatistics(
        tilesCreated: {
          '2': 1,
          '4': 1,
          '8': 1,
          '16': 1,
          '32': 1,
          '64': 1,
          // Missing 128, 256, etc.
        },
      );
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 5000,
        moves: 150,
        bestTile: 512,
        won: false,
        playTimeSeconds: 400,
        tilesReached: [2, 4, 8, 16, 32, 64],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'tile_collector'), false,
          reason: 'Tile Collector achievement should NOT be unlocked with missing tiles');
      expect(achievementService.getProgress('tile_collector').isUnlocked, false);
    });

    test('Achievement 13: Score Hunter - Reach 50,000 points', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 50000,
        moves: 250,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'score_hunter'), true,
          reason: 'Score Hunter achievement should be unlocked when reaching 50,000 points');
      expect(achievementService.getProgress('score_hunter').isUnlocked, true);
    });

    test('Achievement 13: Score Hunter - Should NOT unlock below 50,000', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 49999,
        moves: 250,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'score_hunter'), false,
          reason: 'Score Hunter achievement should NOT be unlocked below 50,000 points');
      expect(achievementService.getProgress('score_hunter').isUnlocked, false);
    });

    test('Achievement 14: High Roller - Reach 100,000 points', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 100000,
        moves: 500,
        bestTile: 4096,
        won: true,
        playTimeSeconds: 900,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'high_roller'), true,
          reason: 'High Roller achievement should be unlocked when reaching 100,000 points');
      expect(achievementService.getProgress('high_roller').isUnlocked, true);
    });

    test('Achievement 14: High Roller - Should NOT unlock below 100,000', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 99999,
        moves: 500,
        bestTile: 4096,
        won: true,
        playTimeSeconds: 900,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      expect(newlyUnlocked.any((a) => a.id == 'high_roller'), false,
          reason: 'High Roller achievement should NOT be unlocked below 100,000 points');
      expect(achievementService.getProgress('high_roller').isUnlocked, false);
    });
  });

  group('Multiple Achievements Unlock', () {
    test('Multiple achievements can unlock in a single game', () async {
      // A perfect game that unlocks multiple achievements
      final stats = GameStatistics(
        totalGamesPlayed: 10,
        currentWinStreak: 10,
        tilesCreated: {
          '2': 1,
          '4': 1,
          '8': 1,
          '16': 1,
          '32': 1,
          '64': 1,
          '128': 1,
          '256': 1,
          '512': 1,
          '1024': 1,
          '2048': 1,
        },
      );
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 50000,
        moves: 150,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 250,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      final newlyUnlocked = await achievementService.checkAchievements(stats, gameRecord);

      // Should unlock multiple achievements
      expect(newlyUnlocked.length >= 5, true,
          reason: 'Multiple achievements should be unlocked in a single exceptional game');

      // Verify specific achievements
      expect(newlyUnlocked.any((a) => a.id == 'first_win'), true);
      expect(newlyUnlocked.any((a) => a.id == 'beginner'), true);
      expect(newlyUnlocked.any((a) => a.id == 'efficient_player'), true);
      expect(newlyUnlocked.any((a) => a.id == 'speed_demon'), true);
      expect(newlyUnlocked.any((a) => a.id == 'perfect_game'), true);
      expect(newlyUnlocked.any((a) => a.id == 'strategic_mind'), true);
      expect(newlyUnlocked.any((a) => a.id == 'tile_collector'), true);
      expect(newlyUnlocked.any((a) => a.id == 'score_hunter'), true);
    });
  });

  group('Achievement Persistence', () {
    test('Achievements persist after being unlocked', () async {
      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 150,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      // Unlock achievement
      await achievementService.checkAchievements(stats, gameRecord);
      expect(achievementService.getProgress('first_win').isUnlocked, true);

      // Check again - should still be unlocked
      final secondCheck = await achievementService.checkAchievements(stats, gameRecord);
      expect(secondCheck.any((a) => a.id == 'first_win'), false,
          reason: 'Already unlocked achievement should not appear in newly unlocked list');
      expect(achievementService.getProgress('first_win').isUnlocked, true);
    });
  });

  group('Achievement Progress Tracking', () {
    test('Progress updates correctly for incremental achievements', () async {
      final stats5 = GameStatistics(totalGamesPlayed: 5);
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 5000,
        moves: 100,
        bestTile: 512,
        won: false,
        playTimeSeconds: 300,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512],
        usedUndo: false,
      );

      await achievementService.checkAchievements(stats5, gameRecord);
      expect(achievementService.getProgress('beginner').currentProgress, 5);
      expect(achievementService.getProgress('beginner').isUnlocked, false);

      // Progress to 10 games
      final stats10 = GameStatistics(totalGamesPlayed: 10);
      await achievementService.checkAchievements(stats10, gameRecord);
      expect(achievementService.getProgress('beginner').currentProgress, 10);
      expect(achievementService.getProgress('beginner').isUnlocked, true);
    });
  });

  group('Achievement Listener Callbacks', () {
    test('Unlock listeners are notified when achievement is unlocked', () async {
      final List<Achievement> unlockedAchievements = [];

      achievementService.addUnlockListener((achievement) {
        unlockedAchievements.add(achievement);
      });

      final stats = GameStatistics();
      final gameRecord = GameRecord(
        timestamp: DateTime.now(),
        score: 20000,
        moves: 150,
        bestTile: 2048,
        won: true,
        playTimeSeconds: 600,
        tilesReached: [2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048],
        usedUndo: false,
      );

      await achievementService.checkAchievements(stats, gameRecord);

      expect(unlockedAchievements.isNotEmpty, true,
          reason: 'Listeners should be notified of newly unlocked achievements');
      expect(unlockedAchievements.any((a) => a.id == 'first_win'), true);
    });
  });
}

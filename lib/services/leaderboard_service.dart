import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f2048/models/leaderboard.dart';
import 'package:f2048/models/game_mode.dart';
import 'package:f2048/services/user_profile_service.dart';

class LeaderboardService {
  static LeaderboardService? _instance;
  static const String _leaderboardKey = 'local_leaderboard';
  static const int _maxEntries = 100; // Keep top 100 scores

  List<LeaderboardEntry> _entries = [];

  LeaderboardService._();

  static LeaderboardService get instance {
    _instance ??= LeaderboardService._();
    return _instance!;
  }

  // Initialize and load leaderboard
  Future<void> loadLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final String? leaderboardJson = prefs.getString(_leaderboardKey);

    if (leaderboardJson != null) {
      try {
        final List<dynamic> json = jsonDecode(leaderboardJson);
        _entries = json.map((e) => LeaderboardEntry.fromJson(e)).toList();
      } catch (e) {
        _entries = [];
      }
    }
  }

  // Save leaderboard
  Future<void> saveLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final String leaderboardJson = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_leaderboardKey, leaderboardJson);
  }

  // Add entry to leaderboard
  Future<void> addEntry({
    required int score,
    required int bestTile,
    required int moves,
    required GameMode gameMode,
  }) async {
    await loadLeaderboard();

    final profile = await UserProfileService.instance.loadProfile();

    final entry = LeaderboardEntry(
      userId: profile.userId,
      displayName: profile.displayName,
      score: score,
      bestTile: bestTile,
      moves: moves,
      timestamp: DateTime.now(),
      gameMode: gameMode,
      avatarUrl: profile.avatarUrl,
    );

    _entries.add(entry);

    // Sort and keep top entries
    _entries = LeaderboardFilter.sortAndRank(_entries);
    if (_entries.length > _maxEntries) {
      _entries = _entries.sublist(0, _maxEntries);
    }

    await saveLeaderboard();
  }

  // Get leaderboard for specific mode and type
  Leaderboard getLeaderboard({
    required GameMode gameMode,
    required LeaderboardType type,
  }) {
    // Filter by game mode
    var modeEntries = _entries.where((e) => e.gameMode == gameMode).toList();

    // Filter by time period
    var filteredEntries = LeaderboardFilter.filterByType(modeEntries, type);

    // Sort and rank
    filteredEntries = LeaderboardFilter.sortAndRank(filteredEntries);

    return Leaderboard(
      gameMode: gameMode,
      type: type,
      entries: filteredEntries,
      lastUpdated: DateTime.now(),
    );
  }

  // Get all-time top scores across all modes
  List<LeaderboardEntry> getTopScores({int limit = 10}) {
    var sorted = List<LeaderboardEntry>.from(_entries);
    sorted = LeaderboardFilter.sortAndRank(sorted);
    return sorted.take(limit).toList();
  }

  // Get player's rank for specific mode
  int? getPlayerRank({
    required String userId,
    required GameMode gameMode,
    required LeaderboardType type,
  }) {
    final leaderboard = getLeaderboard(gameMode: gameMode, type: type);
    final entry = leaderboard.entries.firstWhere(
      (e) => e.userId == userId,
      orElse: () => LeaderboardEntry(
        userId: '',
        displayName: '',
        score: 0,
        bestTile: 0,
        moves: 0,
        timestamp: DateTime.now(),
        gameMode: gameMode,
      ),
    );

    return entry.userId.isNotEmpty ? entry.rank : null;
  }

  // Get player's best score for mode
  LeaderboardEntry? getPlayerBestScore({
    required String userId,
    required GameMode gameMode,
  }) {
    final playerEntries = _entries
        .where((e) => e.userId == userId && e.gameMode == gameMode)
        .toList();

    if (playerEntries.isEmpty) return null;

    playerEntries.sort((a, b) => b.score.compareTo(a.score));
    return playerEntries.first;
  }

  // Get player's position in global leaderboard
  Map<String, dynamic> getPlayerStats(String userId) {
    final playerEntries = _entries.where((e) => e.userId == userId).toList();

    if (playerEntries.isEmpty) {
      return {
        'totalEntries': 0,
        'bestScore': 0,
        'bestRank': null,
        'gamesInTop10': 0,
      };
    }

    playerEntries.sort((a, b) => b.score.compareTo(a.score));
    final bestEntry = playerEntries.first;

    // Count how many times in top 10 across all modes
    int top10Count = 0;
    for (var mode in GameMode.values) {
      final leaderboard = getLeaderboard(
        gameMode: mode,
        type: LeaderboardType.allTime,
      );
      final top10 = leaderboard.entries.take(10);
      if (top10.any((e) => e.userId == userId)) {
        top10Count++;
      }
    }

    return {
      'totalEntries': playerEntries.length,
      'bestScore': bestEntry.score,
      'bestRank': bestEntry.rank,
      'gamesInTop10': top10Count,
    };
  }
}

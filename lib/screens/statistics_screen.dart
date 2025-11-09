import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/services/statistics_service.dart';
import 'package:f2048/models/game_statistics.dart';
import 'package:fl_chart/fl_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  GameStatistics? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final stats = await StatisticsService.instance.loadStatistics();
    setState(() {
      _stats = stats;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IOSColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSColors.systemBackground,
        border: null,
        middle: const Text('Statistics'),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildOverviewCard(),
                  const SizedBox(height: 20),
                  _buildStreaksCard(),
                  const SizedBox(height: 20),
                  _buildProgressCard(),
                  const SizedBox(height: 20),
                  _buildRecentGamesCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Games Played',
                  _stats!.totalGamesPlayed.toString(),
                  CupertinoIcons.game_controller_solid,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Wins',
                  _stats!.totalWins.toString(),
                  CupertinoIcons.checkmark_seal_fill,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'High Score',
                  _stats!.highScore.toString(),
                  CupertinoIcons.star_fill,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Best Tile',
                  _stats!.bestTile.toString(),
                  CupertinoIcons.square_fill,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Win Rate',
                  '${(_stats!.winRate * 100).toStringAsFixed(1)}%',
                  CupertinoIcons.chart_bar_fill,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Avg Moves',
                  _stats!.averageMoves.toStringAsFixed(1),
                  CupertinoIcons.arrow_right_arrow_left,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: IOSColors.systemBlue, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: IOSColors.systemGray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStreaksCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Streaks',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStreakItem(
                  'Current Win Streak',
                  _stats!.currentWinStreak.toString(),
                  IOSColors.systemGreen,
                ),
              ),
              Expanded(
                child: _buildStreakItem(
                  'Longest Win Streak',
                  _stats!.longestWinStreak.toString(),
                  IOSColors.systemOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: IOSColors.systemGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressItem('Total Moves', _stats!.totalMoves),
          const SizedBox(height: 12),
          _buildProgressItem(
            'Play Time',
            _stats!.totalPlayTimeSeconds,
            isTime: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, int value, {bool isTime = false}) {
    String displayValue = value.toString();
    if (isTime) {
      final hours = value ~/ 3600;
      final minutes = (value % 3600) ~/ 60;
      displayValue = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          displayValue,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentGamesCard() {
    if (_stats!.recentGames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Games',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._stats!.recentGames.take(5).map((game) => _buildGameItem(game)),
        ],
      ),
    );
  }

  Widget _buildGameItem(GameRecord game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: IOSColors.systemGray6,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            game.won ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.xmark_circle_fill,
            color: game.won ? IOSColors.systemGreen : IOSColors.systemRed,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score: ${game.score}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Moves: ${game.moves} • Tile: ${game.bestTile}',
                  style: TextStyle(
                    fontSize: 13,
                    color: IOSColors.systemGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

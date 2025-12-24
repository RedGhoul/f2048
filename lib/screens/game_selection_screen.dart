import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/models/game_mode.dart';
import 'package:f2048/models/game_statistics.dart';
import 'package:f2048/screens/daily_challenge_screen.dart';
import 'package:f2048/screens/game_mode_screen.dart';
import 'package:f2048/services/game_mode_service.dart';
import 'package:f2048/services/statistics_service.dart';

class GameSelectionScreen extends StatefulWidget {
  final WidgetBuilder gameBuilder;

  const GameSelectionScreen({Key? key, required this.gameBuilder}) : super(key: key);

  @override
  State<GameSelectionScreen> createState() => _GameSelectionScreenState();
}

class _GameSelectionScreenState extends State<GameSelectionScreen> {
  bool _isLoading = true;
  GameStatistics? _stats;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await GameModeService.instance.initialize();
    _stats = await StatisticsService.instance.loadStatistics();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        backgroundColor: IOSColors.systemBackground,
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    final mode = GameModeService.instance.currentMode;
    final config = gameModeConfigs[mode]!;
    final stats = GameModeService.instance.getStatsForMode(mode);
    final overallStats = _stats;

    return CupertinoPageScaffold(
      backgroundColor: IOSColors.systemBackground,
      child: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Choose Your Game', style: AppTextStyles.displayL),
                      const SizedBox(height: 6),
                      Text(
                        'Pick a mode and jump in.',
                        style: AppTextStyles.body.copyWith(color: IOSColors.systemGray),
                      ),
                      const SizedBox(height: 20),
                      _buildCurrentModeCard(config, stats),
                      const SizedBox(height: 16),
                      if (overallStats != null) _buildStatsOverview(overallStats, stats),
                      if (overallStats != null) const SizedBox(height: 16),
                      _buildSelectModeCard(),
                      const SizedBox(height: 16),
                      _buildDailyChallengeCard(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentModeCard(GameModeConfig config, GameModeStats stats) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _startGame,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card(),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: IOSColors.systemBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                config.icon,
                color: IOSColors.systemBlue,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.name,
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.description,
                    style: AppTextStyles.body.copyWith(color: IOSColors.systemGray),
                  ),
                  if (stats.gamesPlayed > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Mode best: ${stats.highScore} • Played: ${stats.gamesPlayed}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryButton,
                borderRadius: BorderRadius.circular(AppRadii.button),
              ),
              child: const Text(
                'Play',
                style: TextStyle(
                  color: IOSColors.ink900,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.ui,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview(GameStatistics overallStats, GameModeStats modeStats) {
    final winRate = (overallStats.winRate * 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Stats', style: AppTextStyles.title),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatTile('High Score', overallStats.highScore.toString())),
              const SizedBox(width: 12),
              Expanded(child: _buildStatTile('Best Tile', overallStats.bestTile.toString())),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatTile('Games Played', overallStats.totalGamesPlayed.toString())),
              const SizedBox(width: 12),
              Expanded(child: _buildStatTile('Win Rate', '$winRate%')),
            ],
          ),
          if (modeStats.gamesPlayed > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Current mode best: ${modeStats.highScore}',
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: IOSColors.cloud100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: IOSColors.cloud200.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.title,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectModeCard() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () async {
        final result = await Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const GameModeScreen()),
        );
        if (result == true && mounted) {
          setState(() {});
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card(),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: IOSColors.systemPurple.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                CupertinoIcons.slider_horizontal_3,
                color: IOSColors.systemPurple,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(child: Text('Select Game Mode', style: AppTextStyles.title)),
            Icon(
              CupertinoIcons.chevron_right,
              color: IOSColors.systemGray3,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallengeCard() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const DailyChallengeScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppDecorations.card(),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: IOSColors.systemOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                CupertinoIcons.calendar_today,
                color: IOSColors.systemOrange,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Challenge', style: AppTextStyles.title),
                  const SizedBox(height: 4),
                  Text(
                    'Complete today\'s unique puzzle.',
                    style: AppTextStyles.body.copyWith(color: IOSColors.systemGray),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: IOSColors.systemGray3,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _startGame() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: widget.gameBuilder),
    );
  }
}

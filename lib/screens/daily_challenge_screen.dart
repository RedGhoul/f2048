import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/services/daily_challenge_service.dart';
import 'package:f2048/models/daily_challenge.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({Key? key}) : super(key: key);

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  DailyChallenge? _challenge;
  ChallengeStreak? _streak;
  bool _isLoading = true;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadChallenge();
  }

  Future<void> _loadChallenge() async {
    final challenge = await DailyChallengeService.instance.getTodaysChallenge();
    final streak = await DailyChallengeService.instance.loadStreak();
    final completed = await DailyChallengeService.instance.isTodayCompleted();

    setState(() {
      _challenge = challenge;
      _streak = streak;
      _isCompleted = completed;
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
        middle: const Text('Daily Challenge'),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildStreakCard(),
                  const SizedBox(height: 20),
                  _buildChallengeCard(),
                  const SizedBox(height: 20),
                  if (_isCompleted) _buildCompletedCard(),
                  if (!_isCompleted) _buildPlayButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [IOSColors.systemOrange, IOSColors.systemYellow],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: IOSColors.systemOrange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakItem(
            'Current',
            _streak!.currentStreak.toString(),
            CupertinoIcons.flame_fill,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.3),
          ),
          _buildStreakItem(
            'Longest',
            _streak!.longestStreak.toString(),
            CupertinoIcons.star_fill,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeCard() {
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
          Row(
            children: [
              Icon(
                _getChallengeIcon(),
                color: IOSColors.systemBlue,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _challenge!.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _challenge!.description,
            style: const TextStyle(
              fontSize: 17,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _buildChallengeDetails(),
        ],
      ),
    );
  }

  IconData _getChallengeIcon() {
    switch (_challenge!.type) {
      case ChallengeType.scoreTarget:
        return CupertinoIcons.chart_bar_fill;
      case ChallengeType.tileTarget:
        return CupertinoIcons.square_stack_fill;
      case ChallengeType.efficiencyChallenge:
        return CupertinoIcons.speedometer;
      case ChallengeType.survivalChallenge:
        return CupertinoIcons.shield_fill;
    }
  }

  Widget _buildChallengeDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IOSColors.systemGray6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (_challenge!.targetScore > 0)
            _buildDetailRow('Target Score', _challenge!.targetScore.toString()),
          if (_challenge!.targetTile > 0)
            _buildDetailRow('Target Tile', _challenge!.targetTile.toString()),
          if (_challenge!.moveLimit > 0)
            _buildDetailRow('Move Limit', _challenge!.moveLimit.toString()),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard() {
    final todaysResult = _streak!.completedChallenges.firstWhere(
      (r) {
        final now = DateTime.now();
        return r.completedAt.year == now.year &&
            r.completedAt.month == now.month &&
            r.completedAt.day == now.day;
      },
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: IOSColors.systemGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: IOSColors.systemGreen,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.checkmark_seal_fill,
            color: IOSColors.systemGreen,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Challenge Completed!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Score: ${todaysResult.score} • Moves: ${todaysResult.moves}',
            style: TextStyle(
              fontSize: 16,
              color: IOSColors.systemGray,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Icon(
                index < todaysResult.stars
                    ? CupertinoIcons.star_fill
                    : CupertinoIcons.star,
                color: IOSColors.systemYellow,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // TODO: Navigate to challenge game mode
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Daily Challenge'),
            content: const Text(
              'Daily challenge game mode will be implemented in a future update!',
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [IOSColors.systemBlue, IOSColors.systemPurple],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: IOSColors.systemBlue.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              CupertinoIcons.play_fill,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Play Challenge',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

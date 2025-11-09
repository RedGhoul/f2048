import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/services/achievement_service.dart';
import 'package:f2048/models/achievement.dart';
import 'package:share_plus/share_plus.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, AchievementProgress>? _progressMap;
  bool _isLoading = true;
  AchievementCategory _selectedCategory = AchievementCategory.milestone;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final progress = await AchievementService.instance.loadProgress();
    setState(() {
      _progressMap = progress;
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
        middle: const Text('Achievements'),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: Column(
                children: [
                  _buildCategorySelector(),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(20),
                      children: _buildAchievementsList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: CupertinoSlidingSegmentedControl<AchievementCategory>(
        groupValue: _selectedCategory,
        backgroundColor: IOSColors.systemGray6,
        thumbColor: Colors.white,
        children: {
          AchievementCategory.milestone: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Text('Milestones'),
          ),
          AchievementCategory.skill: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Text('Skills'),
          ),
          AchievementCategory.collection: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: const Text('Collection'),
          ),
        },
        onValueChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedCategory = value;
            });
          }
        },
      ),
    );
  }

  List<Widget> _buildAchievementsList() {
    final filteredAchievements = achievements
        .where((a) => a.category == _selectedCategory)
        .toList();

    final unlocked = filteredAchievements
        .where((a) => _progressMap![a.id]!.isUnlocked)
        .length;

    return [
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: IOSColors.systemBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.star_fill, color: IOSColors.systemBlue),
            const SizedBox(width: 8),
            Text(
              '$unlocked / ${filteredAchievements.length} Unlocked',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      ...filteredAchievements.map((achievement) =>
          _buildAchievementCard(achievement, _progressMap![achievement.id]!)),
    ];
  }

  Widget _buildAchievementCard(Achievement achievement, AchievementProgress progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: progress.isUnlocked
            ? () => _showAchievementDetails(achievement, progress)
            : null,
        child: Opacity(
          opacity: progress.isUnlocked ? 1.0 : 0.5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: progress.isUnlocked
                        ? IOSColors.systemYellow.withOpacity(0.2)
                        : IOSColors.systemGray6,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    achievement.icon,
                    color: progress.isUnlocked
                        ? IOSColors.systemYellow
                        : IOSColors.systemGray,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: IOSColors.systemGray,
                        ),
                      ),
                      if (!progress.isUnlocked && achievement.maxProgress > 1) ...[
                        const SizedBox(height: 8),
                        _buildProgressBar(progress, achievement),
                      ],
                    ],
                  ),
                ),
                if (progress.isUnlocked)
                  Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    color: IOSColors.systemGreen,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(AchievementProgress progress, Achievement achievement) {
    final percentage = progress.currentProgress / achievement.maxProgress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${progress.currentProgress} / ${achievement.maxProgress}',
          style: TextStyle(
            fontSize: 12,
            color: IOSColors.systemGray,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: IOSColors.systemGray5,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: IOSColors.systemBlue,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAchievementDetails(Achievement achievement, AchievementProgress progress) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(achievement.icon, color: IOSColors.systemYellow),
            const SizedBox(width: 8),
            Text(achievement.title),
          ],
        ),
        content: Column(
          children: [
            const SizedBox(height: 12),
            Text(achievement.description),
            const SizedBox(height: 8),
            Text(
              'Unlocked on ${_formatDate(progress.unlockedAt!)}',
              style: TextStyle(
                fontSize: 13,
                color: IOSColors.systemGray,
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              _shareAchievement(achievement);
            },
            child: const Text('Share'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _shareAchievement(Achievement achievement) {
    Share.share(
      'I just unlocked the "${achievement.title}" achievement in 2048! 🏆\n${achievement.description}',
      subject: 'Achievement Unlocked!',
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/screens/statistics_screen.dart';
import 'package:f2048/screens/achievements_screen.dart';
import 'package:f2048/screens/daily_challenge_screen.dart';
import 'package:f2048/screens/settings_screen.dart';
import 'package:f2048/screens/game_mode_screen.dart';
import 'package:f2048/screens/theme_selection_screen.dart';
import 'package:f2048/screens/user_profile_screen.dart';
import 'package:f2048/screens/leaderboard_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IOSColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSColors.systemBackground,
        border: null,
        middle: const Text('Menu'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 20),
            _buildMenuCard(
              context,
              'Game Mode',
              'Choose your preferred game mode',
              CupertinoIcons.game_controller_solid,
              IOSColors.systemPurple,
              () async {
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const GameModeScreen(),
                  ),
                );
                // If mode changed, pop with result to refresh game
                if (result == true && context.mounted) {
                  Navigator.pop(context, result);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              'Themes',
              'Customize your board appearance',
              CupertinoIcons.paintbrush_fill,
              IOSColors.systemPink,
              () async {
                final result = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const ThemeSelectionScreen(),
                  ),
                );
                // If theme changed, pop with result to refresh game
                if (result == true && context.mounted) {
                  Navigator.pop(context, result);
                }
              },
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              'Daily Challenge',
              'Complete today\'s unique puzzle',
              CupertinoIcons.calendar_today,
              IOSColors.systemOrange,
              () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const DailyChallengeScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              'Statistics',
              'View your game statistics',
              CupertinoIcons.chart_bar_fill,
              IOSColors.systemBlue,
              () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              'Achievements',
              'Track your accomplishments',
              CupertinoIcons.star_fill,
              IOSColors.systemYellow,
              () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const AchievementsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              'Profile',
              'View your player profile',
              CupertinoIcons.person_crop_circle_fill,
              IOSColors.systemIndigo,
              () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const UserProfileScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              'Leaderboards',
              'Compete with yourself',
              CupertinoIcons.chart_bar_circle_fill,
              IOSColors.systemTeal,
              () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              'Settings',
              'Configure sound and haptics',
              CupertinoIcons.settings_solid,
              IOSColors.systemGray,
              () => Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
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
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: IOSColors.systemGray,
                    ),
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
}

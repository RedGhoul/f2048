import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/models/game_mode.dart';
import 'package:f2048/services/game_mode_service.dart';

class GameModeScreen extends StatefulWidget {
  const GameModeScreen({Key? key}) : super(key: key);

  @override
  State<GameModeScreen> createState() => _GameModeScreenState();
}

class _GameModeScreenState extends State<GameModeScreen> {
  GameMode _selectedMode = GameMode.classic;

  @override
  void initState() {
    super.initState();
    _selectedMode = GameModeService.instance.currentMode;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IOSColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSColors.systemBackground,
        border: null,
        middle: const Text('Game Mode'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await GameModeService.instance.setGameMode(_selectedMode);
            if (context.mounted) {
              Navigator.pop(context, true); // Return true to indicate mode changed
            }
          },
          child: const Text('Done'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            _buildSectionTitle('Board Size'),
            _buildModeCard(GameMode.mini),
            const SizedBox(height: 12),
            _buildModeCard(GameMode.classic),
            const SizedBox(height: 12),
            _buildModeCard(GameMode.large),
            const SizedBox(height: 12),
            _buildModeCard(GameMode.giant),
            const SizedBox(height: 24),
            _buildSectionTitle('Special Modes'),
            _buildModeCard(GameMode.timeAttack),
            const SizedBox(height: 12),
            _buildModeCard(GameMode.zen),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: IOSColors.systemGray,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildModeCard(GameMode mode) {
    final config = gameModeConfigs[mode]!;
    final stats = GameModeService.instance.getStatsForMode(mode);
    final isSelected = _selectedMode == mode;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: IOSColors.systemBlue, width: 2)
              : null,
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
                color: isSelected
                    ? IOSColors.systemBlue.withOpacity(0.15)
                    : IOSColors.systemGray6,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                config.icon,
                color: isSelected ? IOSColors.systemBlue : IOSColors.systemGray,
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? IOSColors.systemBlue
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    config.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: IOSColors.systemGray,
                    ),
                  ),
                  if (stats.gamesPlayed > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatBadge('Best: ${stats.highScore}'),
                        const SizedBox(width: 8),
                        _buildStatBadge('Played: ${stats.gamesPlayed}'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: IOSColors.systemBlue,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: IOSColors.systemGray6,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: CupertinoColors.black,
        ),
      ),
    );
  }
}

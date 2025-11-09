import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/models/theme.dart';
import 'package:f2048/services/theme_service.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ThemeSelectionScreen> createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  List<GameTheme> _themes = [];
  ThemeType _selectedTheme = ThemeType.defaultTheme;

  @override
  void initState() {
    super.initState();
    _loadThemes();
  }

  void _loadThemes() {
    _themes = ThemeService.instance.getAllThemes();
    _selectedTheme = ThemeService.instance.currentThemeType;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IOSColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSColors.systemBackground,
        border: null,
        middle: const Text('Themes'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            final success = await ThemeService.instance.setTheme(_selectedTheme);
            if (success && context.mounted) {
              Navigator.pop(context, true); // Return true to indicate theme changed
            }
          },
          child: const Text('Done'),
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: IOSColors.systemBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.paintbrush_fill,
                      color: IOSColors.systemBlue),
                  const SizedBox(width: 8),
                  Text(
                    '${ThemeService.instance.unlockedCount} / ${ThemeService.instance.totalCount} Unlocked',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ..._themes.map((theme) => _buildThemeCard(theme)),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeCard(GameTheme theme) {
    final isSelected = _selectedTheme == theme.type;
    final isLocked = !theme.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: isLocked
            ? () => _showUnlockDialog(theme)
            : () {
                setState(() {
                  _selectedTheme = theme.type;
                });
              },
        child: Opacity(
          opacity: isLocked ? 0.6 : 1.0,
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
                // Theme preview
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: IOSColors.systemGray4,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.boardBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: GridView.count(
                        crossAxisCount: 2,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(4),
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        children: [
                          _buildPreviewTile(theme.tileColors[2]!),
                          _buildPreviewTile(theme.tileColors[4]!),
                          _buildPreviewTile(theme.tileColors[8]!),
                          _buildPreviewTile(theme.tileColors[16]!),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            theme.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? IOSColors.systemBlue
                                  : CupertinoColors.black,
                            ),
                          ),
                          if (isLocked) ...[
                            const SizedBox(width: 8),
                            Icon(
                              CupertinoIcons.lock_fill,
                              size: 16,
                              color: IOSColors.systemGray,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        theme.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: IOSColors.systemGray,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected && !isLocked)
                  Icon(
                    CupertinoIcons.checkmark_circle_fill,
                    color: IOSColors.systemBlue,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewTile(Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  void _showUnlockDialog(GameTheme theme) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.lock_fill, color: IOSColors.systemOrange),
            const SizedBox(width: 8),
            const Text('Locked Theme'),
          ],
        ),
        content: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              'The "${theme.name}" theme is currently locked.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock themes by completing achievements or through in-app purchases.',
              style: TextStyle(fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
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
  }
}

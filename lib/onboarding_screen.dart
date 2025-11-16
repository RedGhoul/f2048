import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f2048/ios_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: CupertinoIcons.game_controller_solid,
      title: 'Welcome to 2048',
      description: 'Join numbers and get to the 2048 tile!\nSwipe to move tiles in any direction.',
      color: IOSColors.systemBlue,
      type: OnboardingPageType.standard,
    ),
    OnboardingPage(
      icon: CupertinoIcons.arrow_up_down_square,
      title: 'How to Play',
      description: 'Swipe up, down, left, or right to move all tiles.\nWhen two tiles with the same number touch, they merge!',
      color: IOSColors.systemPurple,
      type: OnboardingPageType.standard,
    ),
    OnboardingPage(
      icon: CupertinoIcons.star_fill,
      title: 'Keep Going',
      description: 'Keep playing to reach higher scores.\nUse undo to correct your mistakes!',
      color: IOSColors.systemOrange,
      type: OnboardingPageType.standard,
    ),
    OnboardingPage(
      icon: CupertinoIcons.square_grid_2x2,
      title: 'Multiple Game Modes',
      description: 'Choose from 6 different game modes to match your play style!',
      color: IOSColors.systemTeal,
      type: OnboardingPageType.gameModes,
    ),
    OnboardingPage(
      icon: CupertinoIcons.paintbrush_fill,
      title: 'Beautiful Themes',
      description: 'Unlock stunning themes by earning achievements!',
      color: IOSColors.systemIndigo,
      type: OnboardingPageType.themes,
    ),
    OnboardingPage(
      icon: CupertinoIcons.rosette,
      title: 'Earn Achievements',
      description: 'Complete challenges and unlock rewards as you play!',
      color: IOSColors.systemGreen,
      type: OnboardingPageType.achievements,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IOSColors.systemBackground,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildSkipButton(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index], index);
                    },
                  ),
                ),
                _buildBottomSection(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20, top: 10),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onPressed: _completeOnboarding,
        child: Text(
          'Skip',
          style: TextStyle(
            color: IOSColors.systemGray,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, int index) {
    switch (page.type) {
      case OnboardingPageType.standard:
        return _buildStandardPage(page);
      case OnboardingPageType.gameModes:
        return _buildGameModesPage(page);
      case OnboardingPageType.themes:
        return _buildThemesPage(page);
      case OnboardingPageType.achievements:
        return _buildAchievementsPage(page);
    }
  }

  Widget _buildStandardPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: page.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: page.color.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    page.icon,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 60),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                Text(
                  page.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.black,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  page.description,
                  style: TextStyle(
                    fontSize: 17,
                    color: IOSColors.systemGray,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildGameModesPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(page.icon, size: 60, color: page.color),
          const SizedBox(height: 20),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 17,
              color: IOSColors.systemGray,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildGameModesList(),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildGameModesList() {
    final modes = [
      {'icon': CupertinoIcons.square_grid_2x2, 'name': 'Classic', 'desc': 'Original 4×4'},
      {'icon': CupertinoIcons.timer, 'name': 'Time Attack', 'desc': '3-minute challenge'},
      {'icon': CupertinoIcons.cloud_sun, 'name': 'Zen Mode', 'desc': 'Relaxed gameplay'},
    ];

    return Column(
      children: modes.map((mode) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: IOSColors.systemTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  mode['icon'] as IconData,
                  color: IOSColors.systemTeal,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      mode['desc'] as String,
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
      }).toList(),
    );
  }

  Widget _buildThemesPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(page.icon, size: 60, color: page.color),
          const SizedBox(height: 20),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 17,
              color: IOSColors.systemGray,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildThemePreview(),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildThemePreview() {
    final themes = [
      {'name': 'Classic', 'colors': [Colors.white, const Color(0xFFFFD60A), const Color(0xFFFF9F0A), const Color(0xFFFF6482)]},
      {'name': 'Dark', 'colors': [const Color(0xFF2C2C2E), const Color(0xFF48484A), const Color(0xFF636366), const Color(0xFF8E8E93)]},
      {'name': 'Ocean', 'colors': [const Color(0xFFE0F7FA), const Color(0xFF80DEEA), const Color(0xFF26C6DA), const Color(0xFF00ACC1)]},
    ];

    return Column(
      children: themes.map((theme) {
        final colors = theme['colors'] as List<Color>;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
              Expanded(
                child: Text(
                  theme['name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: colors.map((color) {
                  return Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementsPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Icon(page.icon, size: 60, color: page.color),
          const SizedBox(height: 20),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 17,
              color: IOSColors.systemGray,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildAchievementsList(),
          const SizedBox(height: 20),
          _buildAchievementStats(),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAchievementsList() {
    final achievementSamples = [
      {'icon': CupertinoIcons.star_fill, 'name': 'First Win', 'desc': 'Reach the 2048 tile', 'color': IOSColors.systemYellow},
      {'icon': CupertinoIcons.bolt_fill, 'name': 'Power Player', 'desc': 'Reach the 4096 tile', 'color': IOSColors.systemOrange},
      {'icon': CupertinoIcons.speedometer, 'name': 'Efficient Player', 'desc': 'Win in under 200 moves', 'color': IOSColors.systemBlue},
    ];

    return Column(
      children: achievementSamples.map((achievement) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (achievement['color'] as Color).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  achievement['icon'] as IconData,
                  color: achievement['color'] as Color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement['name'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      achievement['desc'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: IOSColors.systemGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [IOSColors.systemGreen.withOpacity(0.1), IOSColors.systemBlue.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('14', 'Total\nAchievements'),
          Container(width: 1, height: 40, color: IOSColors.systemGray5),
          _buildStatItem('6', 'Unlock\nThemes'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: IOSColors.systemGray,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? IOSColors.systemBlue
                      : IOSColors.systemGray4,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (_currentPage == _pages.length - 1)
            _buildGetStartedButton()
          else
            _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: IOSColors.systemBlue,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: IOSColors.systemBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Next',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: _completeOnboarding,
      child: Container(
        width: double.infinity,
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
        child: const Center(
          child: Text(
            'Get Started',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

enum OnboardingPageType {
  standard,
  gameModes,
  themes,
  achievements,
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final OnboardingPageType type;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.type,
  });
}

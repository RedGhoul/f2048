import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:f2048/grid-properties.dart';
import 'package:f2048/tile.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f2048/services/statistics_service.dart';
import 'package:f2048/services/achievement_service.dart';
import 'package:f2048/services/sound_service.dart';
import 'package:f2048/services/haptic_service.dart';
import 'package:f2048/services/game_mode_service.dart';
import 'package:f2048/services/theme_service.dart';
import 'package:f2048/services/power_up_service.dart';
import 'package:f2048/models/game_statistics.dart';
import 'package:f2048/models/achievement.dart';
import 'package:f2048/models/game_mode.dart';
import 'package:f2048/models/theme.dart';
import 'package:f2048/screens/main_menu_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: IOSColors.systemBackground,
        fontFamily: '.SF Pro Text',
      ),
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isLoading = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    setState(() {
      _showOnboarding = !onboardingComplete;
      _isLoading = false;
    });
  }

  void _completeOnboarding() {
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: IOSColors.systemBackground,
        body: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    }

    return const TwentyFortyEight();
  }
}

enum SwipeDirection { up, down, left, right }

class GameState {
  // this is the grid before the swipe has taken place
  final List<List<Tile>> _previousGrid;
  final SwipeDirection swipe;

  GameState(List<List<Tile>> previousGrid, this.swipe) : _previousGrid = previousGrid;

  // always make a copy so mutations don't screw things up.
  List<List<Tile>> get previousGrid => _previousGrid.map((row) => row.map((tile) => tile.copy()).toList()).toList();
}

class TwentyFortyEight extends StatefulWidget {
  const TwentyFortyEight({Key? key}) : super(key: key);

  @override
  TwentyFortyEightState createState() => TwentyFortyEightState();
}

class TwentyFortyEightState extends State<TwentyFortyEight> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  List<List<Tile>> grid = [];
  List<GameState> gameStates = [];
  List<Tile> toAdd = [];

  // Dynamic grid size based on game mode
  int get gridSize => GameModeService.instance.currentConfig.gridSize;

  Iterable<Tile> get gridTiles => grid.expand((e) => e);
  Iterable<Tile> get allTiles => [gridTiles, toAdd].expand((e) => e);
  List<List<Tile>> get gridCols => List.generate(gridSize, (x) => List.generate(gridSize, (y) => grid[y][x]));

  Timer? aiTimer;

  // Track game session
  DateTime? _gameStartTime;
  bool _usedUndo = false;
  Set<int> _tilesReachedThisGame = {};
  int _highScore = 0;

  // Time Attack mode
  Timer? _gameTimer;
  int _remainingSeconds = 0;

  // Current theme
  GameTheme _currentTheme = gameThemes[ThemeType.defaultTheme]!;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          toAdd.forEach((e) => grid[e.y][e.x].value = e.value);
          gridTiles.forEach((t) => t.resetAnimations());
          toAdd.clear();
        });

        // Check for game over
        _checkGameOver();
      }
    });

    _initializeServices();
    setupNewGame();
  }

  Future<void> _initializeServices() async {
    await SoundService.instance.initialize();
    await HapticService.instance.initialize();
    await StatisticsService.instance.loadStatistics();
    await AchievementService.instance.loadProgress();
    await GameModeService.instance.initialize();
    await ThemeService.instance.initialize();
    await PowerUpService.instance.loadInventory();

    // Set up achievement unlock listener
    AchievementService.instance.addUnlockListener(_onAchievementUnlocked);

    // Load high score
    final stats = StatisticsService.instance.statistics;
    final modeStats = GameModeService.instance.getStatsForMode(GameModeService.instance.currentMode);

    setState(() {
      _highScore = modeStats.highScore > 0 ? modeStats.highScore : stats.highScore;
      _currentTheme = ThemeService.instance.currentTheme;
    });
  }

  void _onAchievementUnlocked(Achievement achievement) {
    SoundService.instance.playSound(SoundEffect.achievementUnlock);
    HapticService.instance.onAchievementUnlock();

    // Show achievement notification
    _showAchievementNotification(achievement);
  }

  void _showAchievementNotification(Achievement achievement) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => CupertinoAlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(achievement.icon, color: IOSColors.systemYellow),
            const SizedBox(width: 8),
            const Text('Achievement Unlocked!'),
          ],
        ),
        content: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(achievement.description),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  void _checkGameOver() {
    if (_isGameOver()) {
      _endGame(false);
    } else if (_hasWon()) {
      _endGame(true);
    }
  }

  bool _isGameOver() {
    final config = GameModeService.instance.currentConfig;

    // Zen mode and Time Attack have no game over
    if (!config.hasGameOver) return false;

    // Check if there are any empty tiles
    if (gridTiles.any((tile) => tile.value == 0)) return false;

    // Check if any adjacent tiles can merge
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final current = grid[y][x].value;
        if (x < gridSize - 1 && grid[y][x + 1].value == current) return false;
        if (y < gridSize - 1 && grid[y + 1][x].value == current) return false;
      }
    }

    return true;
  }

  bool _hasWon() {
    final config = GameModeService.instance.currentConfig;
    return gridTiles.any((tile) => tile.value >= config.winTile);
  }

  Future<void> _endGame(bool won) async {
    // Stop timer if in Time Attack mode
    _gameTimer?.cancel();

    final playTimeSeconds = _gameStartTime != null
        ? DateTime.now().difference(_gameStartTime!).inSeconds
        : 0;

    final bestTile = gridTiles.fold<int>(0, (max, tile) => tile.value > max ? tile.value : max);

    final gameRecord = GameRecord(
      timestamp: DateTime.now(),
      score: score,
      moves: gameStates.length,
      bestTile: bestTile,
      won: won,
      playTimeSeconds: playTimeSeconds,
      tilesReached: _tilesReachedThisGame.toList(),
      usedUndo: _usedUndo,
    );

    // Record game statistics (both global and per-mode)
    await StatisticsService.instance.recordGame(gameRecord);
    await GameModeService.instance.recordGame(score, gameStates.length, bestTile, won);

    // Check achievements
    final stats = StatisticsService.instance.statistics;
    final unlockedAchievements = await AchievementService.instance.checkAchievements(stats, gameRecord);

    // Play sound and haptic
    if (won) {
      SoundService.instance.playSound(SoundEffect.victory);
      HapticService.instance.onAchievementUnlock();
    } else {
      SoundService.instance.playSound(SoundEffect.gameOver);
      HapticService.instance.onGameOver();
    }

    // Update high score display
    final modeStats = GameModeService.instance.getStatsForMode(GameModeService.instance.currentMode);
    if (modeStats.highScore > _highScore) {
      setState(() {
        _highScore = modeStats.highScore;
      });
    }

    // Show game over dialog
    _showGameOverDialog(won, gameRecord, unlockedAchievements);
  }

  void _showGameOverDialog(bool won, GameRecord record, List<Achievement> newAchievements) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: Text(won ? 'Congratulations!' : 'Game Over'),
        content: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              'Score: ${record.score}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Moves: ${record.moves}'),
            Text('Best Tile: ${record.bestTile}'),
            if (newAchievements.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'New Achievements:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...newAchievements.map((a) => Text('🏆 ${a.title}')),
            ],
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              setupNewGame();
            },
            child: const Text('New Game'),
          ),
        ],
      ),
    );
  }

  int get score => gridTiles.fold(0, (sum, tile) => sum + tile.value);

  @override
  Widget build(BuildContext context) {
    final config = GameModeService.instance.currentConfig;
    double contentPadding = 20;
    double borderSize = 6;
    double boardSize = MediaQuery.of(context).size.width - contentPadding * 2;
    double tileSize = (boardSize - borderSize * 2) / gridSize;
    List<Widget> stackItems = [];
    stackItems.addAll(gridTiles.map((t) => TileWidget(
        x: tileSize * t.x,
        y: tileSize * t.y,
        containerSize: tileSize,
        size: tileSize - borderSize * 2,
        color: _currentTheme.tileEmpty)));
    stackItems.addAll(allTiles.map((tile) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) => tile.animatedValue.value == 0
            ? const SizedBox()
            : TileWidget(
                x: tileSize * tile.animatedX.value,
                y: tileSize * tile.animatedY.value,
                containerSize: tileSize,
                size: (tileSize - borderSize * 2) * tile.size.value,
                color: _currentTheme.tileColors[tile.animatedValue.value] ?? _currentTheme.tileColors[2048]!,
                child: Center(child: TileNumber(
                  tile.animatedValue.value,
                  textColor: _currentTheme.tileTextColors[tile.animatedValue.value] ?? Colors.white,
                ))))));

    return Scaffold(
        backgroundColor: _currentTheme.backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // iOS-style Navigation Bar
              _buildNavigationBar(),
              // Score Card (and Timer for Time Attack)
              _buildScoreCard(),
              const SizedBox(height: 20),
              // Game Board
              Expanded(
                child: Center(
                  child: Swiper(
                      up: () => merge(SwipeDirection.up),
                      down: () => merge(SwipeDirection.down),
                      left: () => merge(SwipeDirection.left),
                      right: () => merge(SwipeDirection.right),
                      child: Container(
                          height: boardSize,
                          width: boardSize,
                          padding: EdgeInsets.all(borderSize),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: _currentTheme.boardBackground,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: stackItems,
                          ))),
                ),
              ),
              // Control Buttons
              _buildControlButtons(),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '2048',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
              letterSpacing: -1,
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => const MainMenuScreen(),
                    ),
                  );
                  // If game mode or theme changed, refresh the game
                  if (result == true && mounted) {
                    setState(() {
                      _currentTheme = ThemeService.instance.currentTheme;
                    });
                    setupNewGame();
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: IOSColors.systemGray5,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.line_horizontal_3,
                    color: IOSColors.systemGray,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showInfoDialog(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: IOSColors.systemGray5,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.info,
                    color: IOSColors.systemGray,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    final config = GameModeService.instance.currentConfig;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (config.hasTimer && config.timeLimit != null) ...[
            _buildScoreItem('TIME', _formatTime(_remainingSeconds)),
            Container(
              width: 1,
              height: 40,
              color: IOSColors.systemGray5,
            ),
          ],
          _buildScoreItem('SCORE', score),
          Container(
            width: 1,
            height: 40,
            color: IOSColors.systemGray5,
          ),
          _buildScoreItem('BEST', _highScore),
          if (!config.hasTimer) ...[
            Container(
              width: 1,
              height: 40,
              color: IOSColors.systemGray5,
            ),
            _buildScoreItem('MOVES', gameStates.length),
          ],
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildScoreItem(String label, dynamic value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: IOSColors.systemGray,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: IOSButton(
              label: "Undo",
              icon: CupertinoIcons.arrow_uturn_left,
              color: IOSColors.systemBlue,
              onPressed: gameStates.isEmpty ? null : undoMove,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: IOSButton(
              label: "Restart",
              icon: CupertinoIcons.refresh,
              color: IOSColors.systemOrange,
              onPressed: setupNewGame,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('How to Play'),
        content: const Text(
          '\nSwipe in any direction to move tiles.\n\nWhen two tiles with the same number touch, they merge into one!\n\nGoal: Create a tile with the number 2048.',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void undoMove() {
    final config = GameModeService.instance.currentConfig;
    if (gameStates.isEmpty) return;

    // In Zen mode, undo is always allowed
    // In other modes, we track that undo was used
    if (!config.unlimitedUndo) {
      _usedUndo = true;
    }

    HapticService.instance.onButtonPress();
    SoundService.instance.playSound(SoundEffect.buttonClick);

    GameState previousState = gameStates.removeLast();
    bool Function() mergeFn;
    switch (previousState.swipe) {
      case SwipeDirection.up:
        mergeFn = mergeUp;
        break;
      case SwipeDirection.down:
        mergeFn = mergeDown;
        break;
      case SwipeDirection.left:
        mergeFn = mergeLeft;
        break;
      case SwipeDirection.right:
        mergeFn = mergeRight;
        break;
    }
    setState(() {
      this.grid = previousState.previousGrid;
      mergeFn();
      controller.reverse(from: .99).then((_) {
        setState(() {
          this.grid = previousState.previousGrid;
          gridTiles.forEach((t) => t.resetAnimations());
        });
      });
    });
  }

  void merge(SwipeDirection direction) {
    bool Function() mergeFn;
    switch (direction) {
      case SwipeDirection.up:
        mergeFn = mergeUp;
        break;
      case SwipeDirection.down:
        mergeFn = mergeDown;
        break;
      case SwipeDirection.left:
        mergeFn = mergeLeft;
        break;
      case SwipeDirection.right:
        mergeFn = mergeRight;
        break;
    }
    List<List<Tile>> gridBeforeSwipe = grid.map((row) => row.map((tile) => tile.copy()).toList()).toList();
    setState(() {
      if (mergeFn()) {
        gameStates.add(GameState(gridBeforeSwipe, direction));
        addNewTiles([2]);
        controller.forward(from: 0);

        // Play sound and haptic feedback
        HapticService.instance.onTileSlide();
        SoundService.instance.playSound(SoundEffect.tileSlide);

        // Track tiles reached
        for (var tile in gridTiles) {
          if (tile.value > 0) {
            _tilesReachedThisGame.add(tile.value);
          }
        }
      }
    });
  }

  bool mergeLeft() => grid.map((e) => mergeTiles(e)).toList().any((e) => e);

  bool mergeRight() => grid.map((e) => mergeTiles(e.reversed.toList())).toList().any((e) => e);

  bool mergeUp() => gridCols.map((e) => mergeTiles(e)).toList().any((e) => e);

  bool mergeDown() => gridCols.map((e) => mergeTiles(e.reversed.toList())).toList().any((e) => e);

  bool mergeTiles(List<Tile> tiles) {
    bool didChange = false;
    bool didMerge = false;
    for (int i = 0; i < tiles.length; i++) {
      for (int j = i; j < tiles.length; j++) {
        if (tiles[j].value != 0) {
          Tile? mergeTile;
          try {
            mergeTile = tiles.skip(j + 1).firstWhere((t) => t.value != 0);
          } catch (e) {
            mergeTile = null;
          }
          if (mergeTile != null && mergeTile.value != tiles[j].value) {
            mergeTile = null;
          }
          if (i != j || mergeTile != null) {
            didChange = true;
            int resultValue = tiles[j].value;
            tiles[j].moveTo(controller, tiles[i].x, tiles[i].y);
            if (mergeTile != null) {
              didMerge = true;
              resultValue += mergeTile.value;
              mergeTile.moveTo(controller, tiles[i].x, tiles[i].y);
              mergeTile.bounce(controller);
              mergeTile.changeNumber(controller, resultValue);
              mergeTile.value = 0;
              tiles[j].changeNumber(controller, 0);

              // Play merge sound with pitch based on tile value
              SoundService.instance.playMergeSound(resultValue);
              HapticService.instance.onTileMerge();
            }
            tiles[j].value = 0;
            tiles[i].value = resultValue;
          }
          break;
        }
      }
    }
    return didChange;
  }

  void addNewTiles(List<int> values) {
    List<Tile> empty = gridTiles.where((t) => t.value == 0).toList();
    empty.shuffle();
    for (int i = 0; i < values.length; i++) {
      toAdd.add(Tile(empty[i].x, empty[i].y, values[i])..appear(controller));
    }
  }

  void setupNewGame() {
    final config = GameModeService.instance.currentConfig;

    setState(() {
      // Initialize grid with dynamic size
      grid = List.generate(gridSize, (y) => List.generate(gridSize, (x) => Tile(x, y, 0)));

      gameStates.clear();
      gridTiles.forEach((t) {
        t.value = 0;
        t.resetAnimations();
      });
      toAdd.clear();
      addNewTiles([2, 2]);
      controller.forward(from: 0);

      // Reset game session tracking
      _gameStartTime = DateTime.now();
      _usedUndo = false;
      _tilesReachedThisGame = {2};

      // Set up timer for Time Attack mode
      _gameTimer?.cancel();
      if (config.hasTimer && config.timeLimit != null) {
        _remainingSeconds = config.timeLimit!;
        _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _remainingSeconds--;
            if (_remainingSeconds <= 0) {
              timer.cancel();
              _endGame(false); // Time's up
            }
          });
        });
      }
    });

    HapticService.instance.onButtonPress();
    SoundService.instance.playSound(SoundEffect.buttonClick);
  }

  @override
  void dispose() {
    controller.dispose();
    _gameTimer?.cancel();
    super.dispose();
  }
}

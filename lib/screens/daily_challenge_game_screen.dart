import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:f2048/grid-properties.dart';
import 'package:f2048/tile.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/models/daily_challenge.dart';
import 'package:f2048/services/daily_challenge_service.dart';
import 'package:f2048/services/sound_service.dart';
import 'package:f2048/services/haptic_service.dart';
import 'package:f2048/services/theme_service.dart';
import 'package:f2048/services/share_service.dart';
import 'package:f2048/models/theme.dart';

enum SwipeDirection { up, down, left, right }

class GameState {
  final List<List<Tile>> _previousGrid;
  final SwipeDirection swipe;

  GameState(List<List<Tile>> previousGrid, this.swipe) : _previousGrid = previousGrid;

  List<List<Tile>> get previousGrid => _previousGrid.map((row) => row.map((tile) => tile.copy()).toList()).toList();
}

class DailyChallengeGameScreen extends StatefulWidget {
  final DailyChallenge challenge;

  const DailyChallengeGameScreen({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  State<DailyChallengeGameScreen> createState() => _DailyChallengeGameScreenState();
}

class _DailyChallengeGameScreenState extends State<DailyChallengeGameScreen> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  List<List<Tile>> grid = [];
  List<GameState> gameStates = [];
  List<Tile> toAdd = [];

  int gridSize = 4; // Daily challenges always use 4x4 grid
  Iterable<Tile> get gridTiles => grid.expand((e) => e);
  Iterable<Tile> get allTiles => [gridTiles, toAdd].expand((e) => e);
  List<List<Tile>> get gridCols => List.generate(gridSize, (x) => List.generate(gridSize, (y) => grid[y][x]));

  // Challenge progress tracking
  DateTime? _gameStartTime;
  Set<int> _tilesReachedThisGame = {};
  bool _challengeCompleted = false;
  bool _challengeFailed = false;

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

        // Check challenge status after each move
        _checkChallengeStatus();
      }
    });

    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await SoundService.instance.initialize();
    await HapticService.instance.initialize();
    await ThemeService.instance.initialize();

    setState(() {
      _currentTheme = ThemeService.instance.currentTheme;
    });

    setupChallengeGame();
  }

  void setupChallengeGame() {
    setState(() {
      // Initialize grid from challenge's initial board
      grid = List.generate(gridSize, (y) => List.generate(gridSize, (x) => Tile(x, y, 0)));

      gameStates.clear();
      toAdd.clear();

      // Load initial board state from challenge
      for (int y = 0; y < gridSize; y++) {
        for (int x = 0; x < gridSize; x++) {
          final value = widget.challenge.initialBoard[y][x];
          grid[y][x].value = value;
          if (value > 0) {
            _tilesReachedThisGame.add(value);
          }
        }
      }

      gridTiles.forEach((t) => t.resetAnimations());
      controller.forward(from: 0);

      // Reset game tracking
      _gameStartTime = DateTime.now();
      _challengeCompleted = false;
      _challengeFailed = false;
    });

    HapticService.instance.onButtonPress();
  }

  void _checkChallengeStatus() {
    if (_challengeCompleted || _challengeFailed) return;

    final movesUsed = gameStates.length;
    final currentScore = score;
    final bestTile = gridTiles.fold<int>(0, (max, tile) => tile.value > max ? tile.value : max);

    switch (widget.challenge.type) {
      case ChallengeType.scoreTarget:
        // Check if score target reached
        if (currentScore >= widget.challenge.targetScore) {
          _completeChallenge(true);
        } else if (movesUsed >= widget.challenge.moveLimit) {
          _completeChallenge(false);
        } else if (_isGridFull() && _noMovesAvailable()) {
          _completeChallenge(false);
        }
        break;

      case ChallengeType.tileTarget:
        // Check if tile target reached
        if (bestTile >= widget.challenge.targetTile) {
          _completeChallenge(true);
        } else if (movesUsed >= widget.challenge.moveLimit) {
          _completeChallenge(false);
        } else if (_isGridFull() && _noMovesAvailable()) {
          _completeChallenge(false);
        }
        break;

      case ChallengeType.efficiencyChallenge:
        // Check if tile target reached
        if (bestTile >= widget.challenge.targetTile) {
          _completeChallenge(true);
        } else if (movesUsed >= widget.challenge.moveLimit) {
          _completeChallenge(false);
        } else if (_isGridFull() && _noMovesAvailable()) {
          _completeChallenge(false);
        }
        break;

      case ChallengeType.survivalChallenge:
        // Check if survived required moves
        if (movesUsed >= widget.challenge.moveLimit) {
          _completeChallenge(true);
        } else if (_isGridFull() && _noMovesAvailable()) {
          _completeChallenge(false);
        }
        break;
    }
  }

  bool _isGridFull() {
    return !gridTiles.any((tile) => tile.value == 0);
  }

  bool _noMovesAvailable() {
    // Check if any adjacent tiles can merge
    for (int y = 0; y < gridSize; y++) {
      for (int x = 0; x < gridSize; x++) {
        final current = grid[y][x].value;
        if (current == 0) return false;
        if (x < gridSize - 1 && grid[y][x + 1].value == current) return false;
        if (y < gridSize - 1 && grid[y + 1][x].value == current) return false;
      }
    }
    return true;
  }

  Future<void> _completeChallenge(bool success) async {
    setState(() {
      if (success) {
        _challengeCompleted = true;
      } else {
        _challengeFailed = true;
      }
    });

    final bestTile = gridTiles.fold<int>(0, (max, tile) => tile.value > max ? tile.value : max);
    final stars = DailyChallengeService.instance.calculateStars(
      widget.challenge,
      score,
      gameStates.length,
      bestTile,
    );

    final result = ChallengeResult(
      challengeId: widget.challenge.id,
      completedAt: DateTime.now(),
      score: score,
      moves: gameStates.length,
      completed: success,
      stars: stars,
    );

    // Record completion
    await DailyChallengeService.instance.recordCompletion(result);

    // Play sound and haptic
    if (success) {
      SoundService.instance.playSound(SoundEffect.victory);
      HapticService.instance.onAchievementUnlock();
    } else {
      SoundService.instance.playSound(SoundEffect.gameOver);
      HapticService.instance.onGameOver();
    }

    // Show results after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showResultsDialog(success, result);
      }
    });
  }

  void _showResultsDialog(bool success, ChallengeResult result) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: Text(success ? '🎉 Challenge Complete!' : 'Challenge Failed'),
        content: Column(
          children: [
            const SizedBox(height: 16),
            if (success) _buildStarRating(result.stars),
            const SizedBox(height: 16),
            _buildResultsStats(result),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () async {
              await ShareService.instance.shareChallengeResult(
                challengeTitle: widget.challenge.title,
                score: result.score,
                moves: result.moves,
                stars: result.stars,
                completed: result.completed,
              );
            },
            child: const Text('Share'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to challenge screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(int stars) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? CupertinoIcons.star_fill : CupertinoIcons.star,
          color: index < stars ? IOSColors.systemYellow : IOSColors.systemGray3,
          size: 32,
        );
      }),
    );
  }

  Widget _buildResultsStats(ChallengeResult result) {
    return Column(
      children: [
        Text(
          'Score: ${result.score}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('Moves: ${result.moves}'),
        const SizedBox(height: 12),
        Text(
          widget.challenge.description,
          style: TextStyle(fontSize: 13, color: IOSColors.systemGray),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  int get score => gridTiles.fold(0, (sum, tile) => sum + tile.value);

  int get movesUsed => gameStates.length;

  int get movesRemaining {
    if (widget.challenge.moveLimit == 0) return 0;
    return (widget.challenge.moveLimit - movesUsed).clamp(0, widget.challenge.moveLimit);
  }

  @override
  Widget build(BuildContext context) {
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
              _buildNavigationBar(),
              _buildChallengeInfo(),
              const SizedBox(height: 16),
              _buildProgressIndicators(),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
            ],
          ),
        ));
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Quit Challenge?'),
                  content: const Text('Your progress will be lost.'),
                  actions: [
                    CupertinoDialogAction(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to challenge screen
                      },
                      child: const Text('Quit'),
                    ),
                  ],
                ),
              );
            },
            child: Row(
              children: const [
                Icon(CupertinoIcons.back, size: 20),
                SizedBox(width: 4),
                Text('Back', style: TextStyle(fontSize: 17)),
              ],
            ),
          ),
          Text(
            widget.challenge.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 60), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildChallengeInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: IOSColors.systemBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            widget.challenge.description,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildProgressCard(
              'Score',
              score.toString(),
              widget.challenge.type == ChallengeType.scoreTarget
                  ? '/ ${widget.challenge.targetScore}'
                  : '',
              Icons.star,
              IOSColors.systemYellow,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildProgressCard(
              'Moves',
              movesUsed.toString(),
              widget.challenge.moveLimit > 0 ? '/ ${widget.challenge.moveLimit}' : '',
              CupertinoIcons.arrow_swap,
              IOSColors.systemBlue,
            ),
          ),
          if (widget.challenge.type == ChallengeType.tileTarget ||
              widget.challenge.type == ChallengeType.efficiencyChallenge) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _buildProgressCard(
                'Target',
                widget.challenge.targetTile.toString(),
                '',
                CupertinoIcons.square_grid_2x2,
                IOSColors.systemPurple,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressCard(String label, String value, String suffix, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: IOSColors.systemGray,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (suffix.isNotEmpty)
                Text(
                  suffix,
                  style: TextStyle(
                    fontSize: 14,
                    color: IOSColors.systemGray,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Game logic methods - similar to main game
  void merge(SwipeDirection direction) {
    if (_challengeCompleted || _challengeFailed) return;

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

    setState(() {
      if (mergeFn()) {
        // Save state for potential undo (though not used in challenges)
        gameStates.add(GameState(grid, direction));
        addNewTiles([2]);
        controller.forward(from: 0);
        SoundService.instance.playSound(SoundEffect.merge);
        HapticService.instance.onTileMove();
      }
    });
  }

  bool mergeLeft() => grid.map((e) => mergeList(e)).toList().any((e) => e);
  bool mergeRight() => grid.map((e) => mergeList(e.reversed.toList())).toList().any((e) => e);
  bool mergeUp() => gridCols.map((e) => mergeList(e)).toList().any((e) => e);
  bool mergeDown() => gridCols.map((e) => mergeList(e.reversed.toList())).toList().any((e) => e);

  bool mergeList(List<Tile> tiles) {
    bool changed = false;
    for (int i = 0; i < tiles.length; i++) {
      for (int j = i; j < tiles.length; j++) {
        if (tiles[j].value != 0) {
          Tile mergeTile = tiles
              .skip(j + 1)
              .firstWhere((t) => t.value != 0, orElse: () => Tile(0, 0, 0));
          if (mergeTile.value != 0 && mergeTile.value != tiles[j].value) {
            break;
          }
          if (tiles[i].value == 0) {
            tiles[i].value = tiles[j].value;
            tiles[j].value = 0;
            tiles[i].moveTo(controller, tiles[j]);
            changed = true;
          } else {
            if (tiles[i].value != tiles[j].value) {
              if (i + 1 == j) {
                break;
              }
              tiles[i + 1].value = tiles[j].value;
              tiles[j].value = 0;
              tiles[i + 1].moveTo(controller, tiles[j]);
              changed = true;
            } else {
              tiles[i].value = tiles[i].value + tiles[j].value;
              tiles[j].value = 0;
              tiles[i].bounce(controller);
              tiles[i].moveTo(controller, tiles[j], merge: true);
              changed = true;

              // Track tiles reached
              _tilesReachedThisGame.add(tiles[i].value);

              if (i + 1 < tiles.length) {
                tiles[i + 1].value = mergeTile.value;
                mergeTile.value = 0;
                if (tiles[i + 1].value != 0) {
                  tiles[i + 1].moveTo(controller, mergeTile);
                }
              }
              break;
            }
          }
        }
      }
    }
    return changed;
  }

  void addNewTiles(List<int> values) {
    List<Tile> empty = gridTiles.where((t) => t.value == 0).toList();
    if (empty.isEmpty) return;

    empty.shuffle();
    for (int i = 0; i < values.length && i < empty.length; i++) {
      toAdd.add(Tile(empty[i].x, empty[i].y, values[i])..appear(controller));
      _tilesReachedThisGame.add(values[i]);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

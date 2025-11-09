import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/models/leaderboard.dart';
import 'package:f2048/models/game_mode.dart';
import 'package:f2048/services/leaderboard_service.dart';
import 'package:f2048/services/user_profile_service.dart';
import 'package:intl/intl.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  GameMode _selectedMode = GameMode.classic;
  LeaderboardType _selectedType = LeaderboardType.allTime;
  Leaderboard? _leaderboard;
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      await LeaderboardService.instance.loadEntries();
      final profile = await UserProfileService.instance.loadProfile();
      _currentUserId = profile.userId;

      final leaderboard = LeaderboardService.instance.getLeaderboard(
        gameMode: _selectedMode,
        type: _selectedType,
      );

      setState(() {
        _leaderboard = leaderboard;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onModeChanged(GameMode? mode) {
    if (mode != null) {
      setState(() => _selectedMode = mode);
      _loadLeaderboard();
    }
  }

  void _onTypeChanged(LeaderboardType? type) {
    if (type != null) {
      setState(() => _selectedType = type);
      _loadLeaderboard();
    }
  }

  String _getModeName(GameMode mode) {
    switch (mode) {
      case GameMode.classic:
        return 'Classic';
      case GameMode.mini:
        return 'Mini';
      case GameMode.large:
        return 'Large';
      case GameMode.giant:
        return 'Giant';
      case GameMode.timeAttack:
        return 'Time Attack';
      case GameMode.zen:
        return 'Zen';
    }
  }

  String _getTypeName(LeaderboardType type) {
    switch (type) {
      case LeaderboardType.allTime:
        return 'All Time';
      case LeaderboardType.monthly:
        return 'Monthly';
      case LeaderboardType.weekly:
        return 'Weekly';
      case LeaderboardType.daily:
        return 'Daily';
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Color(0xFFFFD700); // Gold
    if (rank == 2) return Color(0xFFC0C0C0); // Silver
    if (rank == 3) return Color(0xFFCD7F32); // Bronze
    return IOSColors.systemGray;
  }

  IconData _getRankIcon(int rank) {
    if (rank == 1) return CupertinoIcons.star_fill;
    if (rank == 2) return CupertinoIcons.star_circle_fill;
    if (rank == 3) return CupertinoIcons.star;
    return CupertinoIcons.number;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IOSColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSColors.systemBackground,
        border: null,
        middle: const Text('Leaderboards'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildFilters(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CupertinoActivityIndicator())
                  : _leaderboard == null || _leaderboard!.entries.isEmpty
                      ? _buildEmptyState()
                      : _buildLeaderboardList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Game Mode Filter
          Row(
            children: [
              Icon(
                CupertinoIcons.game_controller_solid,
                size: 20,
                color: IOSColors.systemGray,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: IOSColors.systemGray6,
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () => _showModePicker(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getModeName(_selectedMode),
                        style: const TextStyle(
                          fontSize: 15,
                          color: CupertinoColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: IOSColors.systemGray,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Time Period Filter
          Row(
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 20,
                color: IOSColors.systemGray,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  color: IOSColors.systemGray6,
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () => _showTypePicker(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getTypeName(_selectedType),
                        style: const TextStyle(
                          fontSize: 15,
                          color: CupertinoColors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 16,
                        color: IOSColors.systemGray,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showModePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: GameMode.values.indexOf(_selectedMode),
            ),
            onSelectedItemChanged: (int selectedItem) {
              _onModeChanged(GameMode.values[selectedItem]);
            },
            children: GameMode.values.map((mode) {
              return Center(
                child: Text(_getModeName(mode)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showTypePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 200,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: LeaderboardType.values.indexOf(_selectedType),
            ),
            onSelectedItemChanged: (int selectedItem) {
              _onTypeChanged(LeaderboardType.values[selectedItem]);
            },
            children: LeaderboardType.values.map((type) {
              return Center(
                child: Text(_getTypeName(type)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chart_bar,
            size: 64,
            color: IOSColors.systemGray3,
          ),
          const SizedBox(height: 16),
          Text(
            'No entries yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: IOSColors.systemGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Play some games to appear here!',
            style: TextStyle(
              fontSize: 14,
              color: IOSColors.systemGray2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _leaderboard!.entries.length,
      itemBuilder: (context, index) {
        final entry = _leaderboard!.entries[index];
        final isCurrentUser = entry.userId == _currentUserId;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildLeaderboardEntry(entry, isCurrentUser),
        );
      },
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry, bool isCurrentUser) {
    final rankColor = _getRankColor(entry.rank);
    final dateFormatter = DateFormat('MMM d, y');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? IOSColors.systemBlue.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
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
          // Rank Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: entry.rank <= 3
                  ? Icon(
                      _getRankIcon(entry.rank),
                      color: rankColor,
                      size: 24,
                    )
                  : Text(
                      '${entry.rank}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: rankColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // Player Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isCurrentUser
                              ? IOSColors.systemBlue
                              : CupertinoColors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: IOSColors.systemBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'YOU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      size: 12,
                      color: IOSColors.systemGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormatter.format(entry.achievedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: IOSColors.systemGray,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      CupertinoIcons.arrow_right_arrow_left,
                      size: 12,
                      color: IOSColors.systemGray,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.moves} moves',
                      style: TextStyle(
                        fontSize: 12,
                        color: IOSColors.systemGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Score and Tile
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat('#,###').format(entry.score),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser
                      ? IOSColors.systemBlue
                      : CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: IOSColors.systemOrange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.flame_fill,
                      size: 12,
                      color: IOSColors.systemOrange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.bestTile}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: IOSColors.systemOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

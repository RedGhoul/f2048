import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/models/user_profile.dart';
import 'package:f2048/services/user_profile_service.dart';
import 'package:f2048/services/statistics_service.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await UserProfileService.instance.loadProfile();
      setState(() {
        _profile = profile;
        _nameController.text = profile.displayName;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateDisplayName() async {
    if (_nameController.text.trim().isEmpty) return;

    await UserProfileService.instance.updateDisplayName(_nameController.text.trim());
    await _loadProfile();

    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Profile Updated'),
          content: const Text('Your display name has been updated.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Color _getRankColor(PlayerRank rank) {
    switch (rank) {
      case PlayerRank.beginner:
        return IOSColors.systemGray;
      case PlayerRank.intermediate:
        return IOSColors.systemGreen;
      case PlayerRank.advanced:
        return IOSColors.systemBlue;
      case PlayerRank.expert:
        return IOSColors.systemPurple;
      case PlayerRank.master:
        return IOSColors.systemOrange;
      case PlayerRank.legend:
        return IOSColors.systemRed;
    }
  }

  String _getRankTitle(PlayerRank rank) {
    switch (rank) {
      case PlayerRank.beginner:
        return 'Beginner';
      case PlayerRank.intermediate:
        return 'Intermediate';
      case PlayerRank.advanced:
        return 'Advanced';
      case PlayerRank.expert:
        return 'Expert';
      case PlayerRank.master:
        return 'Master';
      case PlayerRank.legend:
        return 'Legend';
    }
  }

  IconData _getRankIcon(PlayerRank rank) {
    switch (rank) {
      case PlayerRank.beginner:
        return CupertinoIcons.smallcircle_fill_circle;
      case PlayerRank.intermediate:
        return CupertinoIcons.circle_fill;
      case PlayerRank.advanced:
        return CupertinoIcons.star_circle_fill;
      case PlayerRank.expert:
        return CupertinoIcons.star_fill;
      case PlayerRank.master:
        return CupertinoIcons.flame_fill;
      case PlayerRank.legend:
        return CupertinoIcons.star_fill;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IOSColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSColors.systemBackground,
        border: null,
        middle: const Text('Profile'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _profile == null
              ? const Center(child: Text('Failed to load profile'))
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileHeader(),
                      const SizedBox(height: 24),
                      _buildRankCard(),
                      const SizedBox(height: 24),
                      _buildXPProgress(),
                      const SizedBox(height: 24),
                      _buildStatsGrid(),
                      const SizedBox(height: 24),
                      _buildBadgesSection(),
                      const SizedBox(height: 24),
                      _buildEditNameSection(),
                      const SizedBox(height: 24),
                      _buildPrivacyToggle(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getRankColor(_profile!.rank).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getRankIcon(_profile!.rank),
              color: _getRankColor(_profile!.rank),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _profile!.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Player since ${_formatDate(_profile!.createdAt)}',
            style: TextStyle(
              fontSize: 14,
              color: IOSColors.systemGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard() {
    final rankColor = _getRankColor(_profile!.rank);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rankColor.withOpacity(0.8),
            rankColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _getRankIcon(_profile!.rank),
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Rank',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getRankTitle(_profile!.rank),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Lv. ${_profile!.level}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPProgress() {
    final currentLevelXP = _profile!.level * 1000;
    final nextLevelXP = (_profile!.level + 1) * 1000;
    final xpInCurrentLevel = _profile!.totalXP - currentLevelXP;
    final xpNeededForNextLevel = nextLevelXP - currentLevelXP;
    final progress = xpInCurrentLevel / xpNeededForNextLevel;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Experience',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
              Text(
                '$xpInCurrentLevel / $xpNeededForNextLevel XP',
                style: TextStyle(
                  fontSize: 14,
                  color: IOSColors.systemGray,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: IOSColors.systemGray5,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getRankColor(_profile!.rank),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toInt()}% to Level ${_profile!.level + 1}',
            style: TextStyle(
              fontSize: 12,
              color: IOSColors.systemGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Career Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.black,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Games',
                _profile!.totalGamesPlayed.toString(),
                CupertinoIcons.game_controller_solid,
                IOSColors.systemBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Wins',
                _profile!.totalWins.toString(),
                CupertinoIcons.checkmark_seal_fill,
                IOSColors.systemGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'High Score',
                _profile!.highestScore.toString(),
                CupertinoIcons.star_fill,
                IOSColors.systemYellow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Best Tile',
                _profile!.highestTile.toString(),
                CupertinoIcons.flame_fill,
                IOSColors.systemOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Badges',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
              Text(
                '${_profile!.badges.length} earned',
                style: TextStyle(
                  fontSize: 14,
                  color: IOSColors.systemGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _profile!.badges.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(
                          CupertinoIcons.star,
                          size: 48,
                          color: IOSColors.systemGray3,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No badges yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: IOSColors.systemGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete achievements to earn badges',
                          style: TextStyle(
                            fontSize: 12,
                            color: IOSColors.systemGray2,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _profile!.badges.map((badge) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: IOSColors.systemPurple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: IOSColors.systemPurple.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.star_fill,
                            size: 16,
                            color: IOSColors.systemPurple,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            badge,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: IOSColors.systemPurple,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildEditNameSection() {
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
          const Text(
            'Display Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: CupertinoColors.black,
            ),
          ),
          const SizedBox(height: 12),
          CupertinoTextField(
            controller: _nameController,
            placeholder: 'Enter your name',
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: IOSColors.systemGray6,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: IOSColors.systemBlue,
              borderRadius: BorderRadius.circular(8),
              onPressed: _updateDisplayName,
              child: const Text(
                'Update Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyToggle() {
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
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Public Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Show profile on leaderboards',
                  style: TextStyle(
                    fontSize: 14,
                    color: IOSColors.systemGray,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: _profile!.isPublic,
            onChanged: (value) async {
              await UserProfileService.instance.togglePrivacy();
              await _loadProfile();
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

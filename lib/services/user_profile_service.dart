import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:f2048/models/user_profile.dart';
import 'package:uuid/uuid.dart';

class UserProfileService {
  static UserProfileService? _instance;
  static const String _profileKey = 'user_profile';

  UserProfile? _profile;

  UserProfileService._();

  static UserProfileService get instance {
    _instance ??= UserProfileService._();
    return _instance!;
  }

  // Initialize and load profile
  Future<UserProfile> loadProfile() async {
    if (_profile != null) return _profile!;

    final prefs = await SharedPreferences.getInstance();
    final String? profileJson = prefs.getString(_profileKey);

    if (profileJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(profileJson);
        _profile = UserProfile.fromJson(json);
      } catch (e) {
        // If there's an error parsing, create new profile
        _profile = _createDefaultProfile();
      }
    } else {
      _profile = _createDefaultProfile();
    }

    return _profile!;
  }

  // Create default profile for new user
  UserProfile _createDefaultProfile() {
    final uuid = const Uuid();
    return UserProfile(
      userId: uuid.v4(),
      displayName: 'Player',
      createdAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
    );
  }

  // Save profile
  Future<void> saveProfile() async {
    if (_profile == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String profileJson = jsonEncode(_profile!.toJson());
    await prefs.setString(_profileKey, profileJson);
  }

  // Get current profile
  UserProfile get profile {
    if (_profile == null) {
      throw StateError('Profile not loaded. Call loadProfile() first.');
    }
    return _profile!;
  }

  // Update display name
  Future<void> updateDisplayName(String name) async {
    await loadProfile();
    _profile!.displayName = name;
    await saveProfile();
  }

  // Update profile from statistics
  Future<void> updateFromGameStats({
    required int totalGamesPlayed,
    required int totalWins,
    required int highScore,
    required int bestTile,
    required int scoreThisGame,
  }) async {
    await loadProfile();

    // Calculate XP gained (based on score)
    int xpGained = (scoreThisGame / 100).round();

    _profile!.updateFromStats(
      totalGamesPlayed,
      totalWins,
      highScore,
      bestTile,
      xpGained,
    );

    await saveProfile();
  }

  // Add badge to profile
  Future<void> addBadge(String badgeId) async {
    await loadProfile();
    if (!_profile!.badges.contains(badgeId)) {
      _profile!.badges.add(badgeId);
      await saveProfile();
    }
  }

  // Toggle profile privacy
  Future<void> togglePrivacy() async {
    await loadProfile();
    _profile!.isPublic = !_profile!.isPublic;
    await saveProfile();
  }

  // Check if profile exists
  Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_profileKey);
  }
}

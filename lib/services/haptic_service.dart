import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum HapticIntensity {
  light,
  medium,
  heavy,
  success,
}

class HapticService {
  static HapticService? _instance;
  static const String _hapticEnabledKey = 'haptic_enabled';

  bool _hapticEnabled = true;
  bool _canVibrate = false;

  HapticService._();

  static HapticService get instance {
    _instance ??= HapticService._();
    return _instance!;
  }

  // Initialize and load settings
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _hapticEnabled = prefs.getBool(_hapticEnabledKey) ?? true;

    // Check if device can vibrate
    _canVibrate = await Vibrate.canVibrate;
  }

  // Trigger haptic feedback
  Future<void> trigger(HapticIntensity intensity) async {
    if (!_hapticEnabled || !_canVibrate) return;

    try {
      switch (intensity) {
        case HapticIntensity.light:
          await HapticFeedback.lightImpact();
          break;
        case HapticIntensity.medium:
          await HapticFeedback.mediumImpact();
          break;
        case HapticIntensity.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case HapticIntensity.success:
          await HapticFeedback.mediumImpact();
          // Wait a bit and trigger again for success pattern
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.lightImpact();
          break;
      }
    } catch (e) {
      // Haptic feedback not supported or error occurred
      print('Error triggering haptic feedback: $e');
    }
  }

  // Specific haptic feedback for game events
  Future<void> onTileSlide() async {
    await trigger(HapticIntensity.light);
  }

  Future<void> onTileMerge() async {
    await trigger(HapticIntensity.medium);
  }

  Future<void> onGameOver() async {
    await trigger(HapticIntensity.heavy);
  }

  Future<void> onAchievementUnlock() async {
    await trigger(HapticIntensity.success);
  }

  Future<void> onButtonPress() async {
    await trigger(HapticIntensity.light);
  }

  // Enable/disable haptic feedback
  Future<void> setHapticEnabled(bool enabled) async {
    _hapticEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticEnabledKey, enabled);
  }

  bool get isHapticEnabled => _hapticEnabled;
  bool get canVibrate => _canVibrate;
}

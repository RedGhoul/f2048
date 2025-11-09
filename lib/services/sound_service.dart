import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundEffect {
  tileSlide,
  tileMerge,
  achievementUnlock,
  gameOver,
  victory,
  buttonClick,
}

class SoundService {
  static SoundService? _instance;
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _volumeKey = 'sound_volume';

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;
  double _volume = 0.7;

  SoundService._();

  static SoundService get instance {
    _instance ??= SoundService._();
    return _instance!;
  }

  // Initialize and load settings
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool(_soundEnabledKey) ?? true;
    _volume = prefs.getDouble(_volumeKey) ?? 0.7;
    await _audioPlayer.setVolume(_volume);
  }

  // Play a sound effect
  Future<void> playSound(SoundEffect effect) async {
    if (!_soundEnabled) return;

    // Since we don't have actual sound files yet, we'll prepare the structure
    // When sound files are added, uncomment and implement:
    /*
    String soundFile;
    switch (effect) {
      case SoundEffect.tileSlide:
        soundFile = 'assets/sounds/slide.mp3';
        break;
      case SoundEffect.tileMerge:
        soundFile = 'assets/sounds/merge.mp3';
        break;
      case SoundEffect.achievementUnlock:
        soundFile = 'assets/sounds/achievement.mp3';
        break;
      case SoundEffect.gameOver:
        soundFile = 'assets/sounds/game_over.mp3';
        break;
      case SoundEffect.victory:
        soundFile = 'assets/sounds/victory.mp3';
        break;
      case SoundEffect.buttonClick:
        soundFile = 'assets/sounds/click.mp3';
        break;
    }

    try {
      await _audioPlayer.play(AssetSource(soundFile));
    } catch (e) {
      // Sound file not found or other error
      print('Error playing sound: $e');
    }
    */
  }

  // Play merge sound with pitch based on tile value
  Future<void> playMergeSound(int tileValue) async {
    if (!_soundEnabled) return;

    // Different pitch/sound for different tile values
    // This will be implemented when we have actual sound files
    await playSound(SoundEffect.tileMerge);
  }

  // Enable/disable sound
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(_volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, _volume);
  }

  bool get isSoundEnabled => _soundEnabled;
  double get volume => _volume;

  // Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
}

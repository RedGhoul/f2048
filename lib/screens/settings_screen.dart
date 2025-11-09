import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:f2048/ios_theme.dart';
import 'package:f2048/services/sound_service.dart';
import 'package:f2048/services/haptic_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _soundEnabled = true;
  bool _hapticEnabled = true;
  double _volume = 0.7;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _soundEnabled = SoundService.instance.isSoundEnabled;
      _hapticEnabled = HapticService.instance.isHapticEnabled;
      _volume = SoundService.instance.volume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: IOSColors.systemBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: IOSColors.systemBackground,
        border: null,
        middle: const Text('Settings'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle('Audio'),
            _buildSettingsCard([
              _buildSwitchRow(
                'Sound Effects',
                _soundEnabled,
                (value) async {
                  await SoundService.instance.setSoundEnabled(value);
                  setState(() {
                    _soundEnabled = value;
                  });
                },
                CupertinoIcons.speaker_2_fill,
              ),
              if (_soundEnabled) ...[
                const Divider(height: 1),
                _buildSliderRow(
                  'Volume',
                  _volume,
                  (value) async {
                    await SoundService.instance.setVolume(value);
                    setState(() {
                      _volume = value;
                    });
                  },
                  CupertinoIcons.volume_up,
                ),
              ],
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('Haptics'),
            _buildSettingsCard([
              _buildSwitchRow(
                'Haptic Feedback',
                _hapticEnabled,
                (value) async {
                  await HapticService.instance.setHapticEnabled(value);
                  setState(() {
                    _hapticEnabled = value;
                  });
                  if (value) {
                    HapticService.instance.onButtonPress();
                  }
                },
                CupertinoIcons.hand_point_left_fill,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('About'),
            _buildSettingsCard([
              _buildInfoRow('Version', '1.0.0'),
              const Divider(height: 1),
              _buildInfoRow('Developer', 'f2048 Team'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
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

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
        children: children,
      ),
    );
  }

  Widget _buildSwitchRow(
    String label,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: IOSColors.systemBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderRow(
    String label,
    double value,
    Function(double) onChanged,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: IOSColors.systemBlue, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  fontSize: 17,
                  color: IOSColors.systemGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          CupertinoSlider(
            value: value,
            onChanged: onChanged,
            min: 0.0,
            max: 1.0,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              color: IOSColors.systemGray,
            ),
          ),
        ],
      ),
    );
  }
}

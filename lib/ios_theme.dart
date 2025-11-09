import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// iOS-native color palette inspired by Apple's design language
class IOSColors {
  // Primary iOS system colors
  static const Color systemBackground = Color(0xFFF2F2F7);
  static const Color secondarySystemBackground = Color(0xFFFFFFFF);
  static const Color tertiarySystemBackground = Color(0xFFFFFFFF);

  // iOS system grays
  static const Color systemGray = Color(0xFF8E8E93);
  static const Color systemGray2 = Color(0xFFAEAEB2);
  static const Color systemGray3 = Color(0xFFC7C7CC);
  static const Color systemGray4 = Color(0xFFD1D1D6);
  static const Color systemGray5 = Color(0xFFE5E5EA);
  static const Color systemGray6 = Color(0xFFF2F2F7);

  // iOS accent colors
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemTeal = Color(0xFF5AC8FA);
  static const Color systemYellow = Color(0xFFFFCC00);

  // Custom tile colors with iOS aesthetics
  static const Color tileEmpty = Color(0xFFE5E5EA);
  static const Color tile2 = Color(0xFFFFFFFF);
  static const Color tile4 = Color(0xFFF2F2F7);
  static const Color tile8 = Color(0xFFFFD60A);
  static const Color tile16 = Color(0xFFFF9F0A);
  static const Color tile32 = Color(0xFFFF6482);
  static const Color tile64 = Color(0xFFFF375F);
  static const Color tile128 = Color(0xFFFFD60A);
  static const Color tile256 = Color(0xFFFFCC00);
  static const Color tile512 = Color(0xFFFFC400);
  static const Color tile1024 = Color(0xFFFFB800);
  static const Color tile2048 = Color(0xFFFFAA00);

  // Board colors
  static const Color boardBackground = Color(0xFFBBB0A3);
  static const Color cardBackground = Color(0xFFCDC1B4);
}

// Tile color mapping
const Map<int, Color> iosTileColors = {
  2: IOSColors.tile2,
  4: IOSColors.tile4,
  8: IOSColors.tile8,
  16: IOSColors.tile16,
  32: IOSColors.tile32,
  64: IOSColors.tile64,
  128: IOSColors.tile128,
  256: IOSColors.tile256,
  512: IOSColors.tile512,
  1024: IOSColors.tile1024,
  2048: IOSColors.tile2048,
};

// Text colors for tiles
const Map<int, Color> iosTileTextColors = {
  2: Color(0xFF776E65),
  4: Color(0xFF776E65),
  8: Colors.white,
  16: Colors.white,
  32: Colors.white,
  64: Colors.white,
  128: Colors.white,
  256: Colors.white,
  512: Colors.white,
  1024: Colors.white,
  2048: Colors.white,
};

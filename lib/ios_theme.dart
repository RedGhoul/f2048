import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppFonts {
  static const String display = 'Fraunces';
  static const String ui = 'Manrope';
}

class IOSColors {
  // Core neutrals
  static const Color ink900 = Color(0xFF121112);
  static const Color ink800 = Color(0xFF1E1C1E);
  static const Color ink600 = Color(0xFF3A353A);
  static const Color cloud200 = Color(0xFFE8E2DD);
  static const Color cloud100 = Color(0xFFF3EFEA);
  static const Color cloud050 = Color(0xFFFAF7F2);

  // Primary surfaces
  static const Color systemBackground = cloud050;
  static const Color secondarySystemBackground = cloud100;
  static const Color tertiarySystemBackground = cloud200;

  // Soft grays
  static const Color systemGray = ink600;
  static const Color systemGray2 = Color(0xFF5A5459);
  static const Color systemGray3 = Color(0xFF7A7379);
  static const Color systemGray4 = Color(0xFFCFC7C1);
  static const Color systemGray5 = cloud200;
  static const Color systemGray6 = cloud100;

  // Accent colors
  static const Color systemBlue = Color(0xFFF07D4E); // Ember
  static const Color systemGreen = Color(0xFF69C6C2); // Sea
  static const Color systemIndigo = Color(0xFF6D4CA6);
  static const Color systemOrange = Color(0xFFF5C36A); // Gold
  static const Color systemPink = Color(0xFFE88BA1); // Rose
  static const Color systemPurple = Color(0xFF8E4C9F);
  static const Color systemRed = Color(0xFFE65E5A);
  static const Color systemTeal = Color(0xFF69C6C2);
  static const Color systemYellow = Color(0xFFF5C36A);

  // Tile colors
  static const Color tileEmpty = cloud100;
  static const Color tile2 = Color(0xFFF8EFE2);
  static const Color tile4 = Color(0xFFF2E1C8);
  static const Color tile8 = Color(0xFFF6C997);
  static const Color tile16 = Color(0xFFF4A36B);
  static const Color tile32 = Color(0xFFEF7C4E);
  static const Color tile64 = Color(0xFFE65E5A);
  static const Color tile128 = Color(0xFFD94E7B);
  static const Color tile256 = Color(0xFFB8498A);
  static const Color tile512 = Color(0xFF8E4C9F);
  static const Color tile1024 = Color(0xFF6D4CA6);
  static const Color tile2048 = Color(0xFF4C4AA9);
  static const Color tile4096 = Color(0xFF3E3CA0);
  static const Color tile8192 = Color(0xFF2F2D90);

  // Board colors
  static const Color boardBackground = Color(0xB3FAF7F2);
  static const Color cardBackground = cloud050;

  // Effects
  static const Color glowHighlight = Color(0x66FFD9A3);
  static const Color edgeLight = Color(0x59FFFFFF);
  static const Color edgeDark = Color(0x26121112);
}

class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF7EFE3),
      Color(0xFFEEDCC6),
      Color(0xFFE8C9A7),
    ],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      IOSColors.systemBlue,
      IOSColors.systemOrange,
    ],
  );
}

class AppRadii {
  static const double tile = 16;
  static const double card = 16;
  static const double board = 24;
  static const double button = 20;
}

class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x24121112),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> board = [
    BoxShadow(
      color: Color(0x2E121112),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];

  static const List<BoxShadow> tile = [
    BoxShadow(
      color: Color(0x29121112),
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
  ];
}

class AppTextStyles {
  static const TextStyle displayXL = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 34,
    height: 40 / 34,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w600,
    color: IOSColors.ink900,
  );

  static const TextStyle displayL = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 28,
    height: 34 / 28,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w600,
    color: IOSColors.ink900,
  );

  static const TextStyle title = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: -0.1,
    fontWeight: FontWeight.w600,
    color: IOSColors.ink900,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.ui,
    fontSize: 16,
    height: 22 / 16,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    color: IOSColors.ink800,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.ui,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w500,
    color: IOSColors.ink600,
  );
}

class AppDecorations {
  static BoxDecoration card({Color? color}) {
    return BoxDecoration(
      color: color ?? IOSColors.cardBackground,
      borderRadius: BorderRadius.circular(AppRadii.card),
      border: Border.all(color: IOSColors.cloud200.withOpacity(0.6)),
      boxShadow: AppShadows.card,
    );
  }

  static BoxDecoration board({Color? color}) {
    return BoxDecoration(
      color: color ?? IOSColors.boardBackground,
      borderRadius: BorderRadius.circular(AppRadii.board),
      border: Border.all(color: IOSColors.cloud200.withOpacity(0.6)),
      boxShadow: AppShadows.board,
    );
  }

  static BoxDecoration tile(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(AppRadii.tile),
      border: Border.all(color: IOSColors.edgeLight),
      boxShadow: AppShadows.tile,
    );
  }
}

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppGradients.background,
      ),
      child: child,
    );
  }
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
  4096: IOSColors.tile4096,
  8192: IOSColors.tile8192,
};

// Text colors for tiles
const Map<int, Color> iosTileTextColors = {
  2: IOSColors.ink900,
  4: IOSColors.ink900,
  8: IOSColors.ink900,
  16: IOSColors.ink900,
  32: IOSColors.ink900,
  64: IOSColors.ink900,
  128: IOSColors.cloud050,
  256: IOSColors.cloud050,
  512: IOSColors.cloud050,
  1024: IOSColors.cloud050,
  2048: IOSColors.cloud050,
  4096: IOSColors.cloud050,
  8192: IOSColors.cloud050,
};

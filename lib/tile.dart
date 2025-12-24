import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:f2048/grid-properties.dart';
import 'package:f2048/ios_theme.dart';

class Tile {
  final int x;
  final int y;

  int value;

  late Animation<double> animatedX;
  late Animation<double> animatedY;
  late Animation<double> size;

  late Animation<int> animatedValue;

  Tile(this.x, this.y, this.value) {
    resetAnimations();
  }

  void resetAnimations() {
    animatedX = AlwaysStoppedAnimation(x.toDouble());
    animatedY = AlwaysStoppedAnimation(y.toDouble());
    size = AlwaysStoppedAnimation(1.0);
    animatedValue = AlwaysStoppedAnimation(value);
  }

  void moveTo(Animation<double> parent, int x, int y) {
    Animation<double> curved = CurvedAnimation(parent: parent, curve: Interval(0.0, moveInterval));
    animatedX = Tween(begin: this.x.toDouble(), end: x.toDouble()).animate(curved);
    animatedY = Tween(begin: this.y.toDouble(), end: y.toDouble()).animate(curved);
  }

  void bounce(Animation<double> parent) {
    size = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 1.0),
    ]).animate(CurvedAnimation(parent: parent, curve: Interval(moveInterval, 1.0)));
  }

  void changeNumber(Animation<double> parent, int newValue) {
    animatedValue = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(value), weight: .01),
      TweenSequenceItem(tween: ConstantTween(newValue), weight: .99),
    ]).animate(CurvedAnimation(parent: parent, curve: Interval(moveInterval, 1.0)));
  }

  void appear(Animation<double> parent) {
    size = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: parent, curve: Interval(moveInterval, 1.0)));
  }

  Tile copy() {
    Tile t = Tile(x, y, value);
    t.resetAnimations();
    return t;
  }
}

class TileWidget extends StatelessWidget {
  final double x;
  final double y;
  final double containerSize;
  final double size;
  final Color color;
  final Widget? child;

  const TileWidget({Key? key, required this.x, required this.y, required this.containerSize, required this.size, required this.color, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => Positioned(
      left: x,
      top: y,
      child: Container(
          width: containerSize,
          height: containerSize,
          child: Center(
              child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadii.tile),
                    color: color,
                    border: Border.all(color: IOSColors.edgeLight),
                    boxShadow: color != IOSColors.tileEmpty ? AppShadows.tile : null,
                  ),
                  child: child))));
}

class TileNumber extends StatelessWidget {
  final int val;
  final Color? textColor;

  const TileNumber(this.val, {Key? key, this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double baseFontSize;
    if (val >= 2048) {
      baseFontSize = 24;
    } else if (val >= 512) {
      baseFontSize = 28;
    } else if (val >= 128) {
      baseFontSize = 32;
    } else {
      baseFontSize = 36;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = constraints.biggest.shortestSide * 0.08;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "$val",
              style: TextStyle(
                color: textColor ?? iosTileTextColors[val] ?? Colors.white,
                fontSize: baseFontSize,
                fontWeight: FontWeight.w600,
                fontFamily: AppFonts.display,
                letterSpacing: -0.2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class IOSButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final void Function()? onPressed;

  const IOSButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: onPressed == null ? IOSColors.systemGray4 : null,
            borderRadius: BorderRadius.circular(AppRadii.button),
            gradient: onPressed != null ? AppGradients.primaryButton : null,
            boxShadow: onPressed != null ? AppShadows.card : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: IOSColors.ink900,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: IOSColors.ink900,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.ui,
                ),
              ),
            ],
          ),
        ),
      );
}

class Swiper extends StatelessWidget {
  final Function() up;
  final Function() down;
  final Function() left;
  final Function() right;
  final Widget child;

  const Swiper({Key? key, required this.up, required this.down, required this.left, required this.right, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dy < -250) {
          up();
        } else if (details.velocity.pixelsPerSecond.dy > 250) {
          down();
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < -1000) {
          left();
        } else if (details.velocity.pixelsPerSecond.dx > 1000) {
          right();
        }
      },
      child: child);
}
